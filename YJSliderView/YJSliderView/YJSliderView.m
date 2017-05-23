//
//  YJSliderView.m
//  YJSliderView
//
//  Created by Jake on 2017/5/22.
//  Copyright © 2017年 Jake. All rights reserved.
//

#import "YJSliderView.h"
#import "Masonry.h"
#import "MJRefresh.h"

static const CGFloat topViewHeight = 42;
static CGFloat scaleSize = 1.3;

typedef NS_ENUM(NSUInteger, CollectionViewType) {
    TITLE,
    CONTENT
};

/*============== SliderTitleCell ===================*/

@interface YJSliderTitleCell : UICollectionViewCell
@property (nonatomic , strong) UIButton *titleButton;
@property (nonatomic, copy) void (^onTapBtn)();

- (void)initCellStyleWithButton:(UIButton *)btn Status:(BOOL)isSelected TapCompletetionHandle:(void(^)())completeHandle;
@end

@implementation YJSliderTitleCell

- (void)initCellStyleWithButton:(UIButton *)btn Status:(BOOL)isSelected TapCompletetionHandle:(void(^)())completeHandle {
    while (self.subviews.count) {
        [self.subviews.lastObject removeFromSuperview];
    }
    self.titleButton = btn;
    [self.titleButton addTarget:self action:@selector(tapBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.titleButton.selected = isSelected;
    self.titleButton.enabled = !isSelected;
    [self addSubview:self.titleButton];
    [self.titleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(1);
    }];
    self.onTapBtn = completeHandle;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)tapBtn:(UIButton *)sender {
    if (self.onTapBtn) {
        self.onTapBtn();
    }
}

@end


/*============== SliderView ===================*/

@interface YJSliderView ()<UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>
@property (nonatomic, assign, readwrite) NSInteger currentIndex;
@property (nonatomic, strong) UICollectionView *titleCollectionView;
@property (nonatomic, strong) UICollectionView *contentCollectionView;
@property (nonatomic, strong) NSMutableDictionary *statusDic;
@property (nonatomic, strong) UIView *sliderLine;
@property (nonatomic, strong) NSMutableArray *buttonArray;
@end

@implementation YJSliderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)reloadData {
    [self.contentCollectionView reloadData];
    [self.titleCollectionView reloadData];
    [self setUpButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"YJSliderContentCell"];
    [self.titleCollectionView registerClass:[YJSliderTitleCell class] forCellWithReuseIdentifier:@"YJSliderTitleCell"];
    NSAssert(scaleSize >= 1, @"YJSliderView -- Title放大倍数需要不小于1");
    [self setUpButton];
}

- (void)setUpButton {
    self.buttonArray = [NSMutableArray new];
    for (NSInteger index = 0; index < [self.delegate numberOfItemsInYJSliderView:self]; index ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.titleLabel.font = [UIFont systemFontOfSize:self.fontSize ? self.fontSize : 15.0];
        [btn setTitle:[self.delegate yj_SliderView:self titleForItemAtIndex:index] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [btn setTitleColor:self.themeColor ? self.themeColor : [UIColor colorWithRed:0.15 green:0.71 blue:0.96 alpha:1.00] forState:UIControlStateSelected | UIControlStateDisabled];
        [self.buttonArray addObject:btn];

    }
}

/**
 *  更新下划线位置
 *
 *  @param index 当前位置
 */
- (void)updateSliderLinePosition:(CGFloat)index {
//    NSNumber *indexNum = [NSNumber numberWithFloat:index];
    UICollectionViewFlowLayout *topLayout = (UICollectionViewFlowLayout *)self.titleCollectionView.collectionViewLayout;
//    UIButton *button = self.buttonArray[indexNum.integerValue];
//    NSDictionary *attrs = @{NSFontAttributeName : button.titleLabel.font};
//    CGSize size = [[self.delegate yj_SliderView:self titleForItemAtIndex:indexNum.integerValue] sizeWithAttributes:attrs];
//    CGFloat precent = (index - indexNum.integerValue);
    [self.sliderLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(index * topLayout.itemSize.width);
//        make.width.mas_equalTo( size.width);
        make.width.mas_equalTo(topLayout.itemSize.width);
    }];
}

#pragma mark - UICollectionViewDelegate & DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.delegate numberOfItemsInYJSliderView:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewType type = collectionView.tag;
    switch (type) {
        case TITLE: {
            YJSliderTitleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YJSliderTitleCell" forIndexPath:indexPath];
            BOOL isSelected = [[self.statusDic objectForKey:[NSNumber numberWithInteger:indexPath.row]] boolValue];
            __weak typeof(self)weakSelf = self;
            [cell initCellStyleWithButton:self.buttonArray[indexPath.item] Status:isSelected TapCompletetionHandle:^{
                [weakSelf manageButtonStatus:indexPath.item];
                [weakSelf.contentCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
                [weakSelf.titleCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
                [weakSelf.titleCollectionView reloadData];
            }];
            return cell;
        }
        case CONTENT: {
            UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YJSliderContentCell" forIndexPath:indexPath];
            while (cell.contentView.subviews.count) {
                [cell.contentView.subviews.lastObject removeFromSuperview];
            }
            UIView *view = [self.delegate yj_SliderView:self viewForItemAtIndex:indexPath.row];
            [cell.contentView addSubview:view];
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(0);
            }];
            return cell;
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView.tag == CONTENT) {
        NSInteger index = (NSInteger)(scrollView.contentOffset.x / [UIScreen mainScreen].bounds.size.width);
        self.currentIndex = index;
        [self.titleCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        [self manageButtonStatus:index];
        [self.titleCollectionView reloadData];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.tag == CONTENT) {
        [self scrollViewDidEndScrollingAnimation:scrollView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tag == CONTENT) {
        CGFloat indexValue = (CGFloat)(scrollView.contentOffset.x / [UIScreen mainScreen].bounds.size.width);
        [self updateSliderLinePosition:indexValue];
        NSInteger index = (NSInteger)indexValue;
        CGFloat lagerScale = scaleSize - (indexValue - index) * (scaleSize - 1);
        CGFloat smallScale = (indexValue - index) * (scaleSize - 1)  + 1;
        UIButton *currentBtn;
        UIButton *nextBtn;
        if (index < self.currentIndex) {
            currentBtn = self.buttonArray[index + 1];
            nextBtn = self.buttonArray[index];
            currentBtn.transform = CGAffineTransformMakeScale(smallScale, smallScale);
            nextBtn.transform = CGAffineTransformMakeScale(lagerScale, lagerScale);
            [self changeButtonColor:currentBtn To:[UIColor lightGrayColor] WithScale:(1 - (indexValue - index))];
            [self changeButtonColor:nextBtn To:self.themeColor ? self.themeColor : [UIColor colorWithRed:0.15 green:0.71 blue:0.96 alpha:1.00] WithScale:(1 - (indexValue - index))];
            
        } else {
            currentBtn = self.buttonArray[index];
            currentBtn.transform = CGAffineTransformMakeScale(lagerScale, lagerScale);
            if (index + 1 == self.buttonArray.count) {
                nextBtn = nil;
            } else {
                nextBtn = self.buttonArray[index + 1];
                nextBtn.transform = CGAffineTransformMakeScale(smallScale, smallScale);
            }
            [self changeButtonColor:currentBtn To:[UIColor lightGrayColor] WithScale:(indexValue - index)];
            [self changeButtonColor:nextBtn To:self.themeColor ? self.themeColor : [UIColor colorWithRed:0.15 green:0.71 blue:0.96 alpha:1.00] WithScale:(indexValue - index)];
        }
    }
}

#pragma mark - Actions

/**
 *  线性改变按钮颜色
 *
 *  @param button  改色按钮
 *  @param toColor 改变后的颜色
 *  @param scale   改色进度
 */
- (void)changeButtonColor:(UIButton *)button To:(UIColor *)toColor WithScale:(CGFloat)scale {
    CGFloat originRed, originGreen, originBlue;
    [button.currentTitleColor getRed:&originRed green:&originGreen blue:&originBlue alpha:nil];
    CGFloat targetRed, targetGreen, targetBlue;
    [toColor getRed:&targetRed green:&targetGreen blue:&targetBlue alpha:nil];
    CGFloat currentRed, currentGreen, currentBlue;
    currentRed = originRed + (targetRed - originRed) * scale;
    currentGreen = originGreen + (targetGreen - originGreen) * scale;
    currentBlue = originBlue + (targetBlue - originBlue) * scale;
    button.titleLabel.textColor = [UIColor colorWithRed:currentRed green:currentGreen blue:currentBlue alpha:1];
}

#pragma mark - Collection Init

- (UICollectionView *)titleCollectionView {
    if (_titleCollectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _titleCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, topViewHeight) collectionViewLayout:layout];
        _titleCollectionView.tag = TITLE;
        _titleCollectionView.bounces = NO;
        _titleCollectionView.showsHorizontalScrollIndicator = NO;
        _titleCollectionView.pagingEnabled = YES;
        _titleCollectionView.delegate = self;
        _titleCollectionView.dataSource = self;
        [self addSubview:_titleCollectionView];
    }
    
    UICollectionViewFlowLayout *topLayout = (UICollectionViewFlowLayout *)_titleCollectionView.collectionViewLayout;
    NSInteger totalNum = [self.delegate numberOfItemsInYJSliderView:self];
    if ( totalNum <= 4) {
        topLayout.itemSize = CGSizeMake(self.frame.size.width / totalNum, topViewHeight);
    } else {
        topLayout.itemSize = CGSizeMake(self.frame.size.width / 4, topViewHeight);
    }
    
    return _titleCollectionView;
}

- (UICollectionView *)contentCollectionView {
    if (_contentCollectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(self.frame.size.width, self.frame.size.height - topViewHeight - 0.5);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _contentCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.titleCollectionView.frame.size.height + 0.5, self.frame.size.width, self.frame.size.height - topViewHeight - 0.5) collectionViewLayout:layout];
        _contentCollectionView.tag = CONTENT;
        _contentCollectionView.bounces = NO;
        _contentCollectionView.showsHorizontalScrollIndicator = NO;
        _contentCollectionView.pagingEnabled = YES;
        _contentCollectionView.delegate = self;
        _contentCollectionView.dataSource = self;
        [self addSubview:_contentCollectionView];
    }
    return _contentCollectionView;
}

- (void)manageButtonStatus:(NSInteger)index {
    for (NSNumber *number in self.statusDic.allKeys) {
        if ([number integerValue] == index) {
            [self.statusDic setObject:[NSNumber numberWithBool:YES] forKey:number];
        } else {
            [self.statusDic setObject:[NSNumber numberWithBool:NO] forKey:number];
        }
    }
}

/**
 *  存储初始化选择状态
 *
 *  @return 状态字典
 */
- (NSMutableDictionary *)statusDic {
    if (_statusDic == nil) {
        _statusDic = [[NSMutableDictionary alloc] init];
        for (int num = 0; num < [self.delegate numberOfItemsInYJSliderView:self]; num ++) {
            [_statusDic setObject:[NSNumber numberWithBool:NO] forKey:[NSNumber numberWithInt:num]];
            //带指定页面的初始化
            NSInteger initializeIndex = 0;
            if ([self.delegate respondsToSelector:@selector(initialzeIndexFoYJSliderView:)]) {
                initializeIndex = [self.delegate initialzeIndexFoYJSliderView:self];
            }
            if (num == initializeIndex) {
                self.currentIndex = num;
                [_statusDic setObject:[NSNumber numberWithBool:YES] forKey:[NSNumber numberWithInt:num]];
                [self.contentCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:num inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
                [self updateSliderLinePosition:num];
                UIButton *btn = self.buttonArray[num];
                btn.transform = CGAffineTransformMakeScale(scaleSize, scaleSize);
            }
        }
    }
    return _statusDic;
}

- (UIView *)sliderLine {
    if (_sliderLine == nil) {
        _sliderLine = [[UIView alloc] init];
        _sliderLine.backgroundColor = self.themeColor ? self.themeColor : [UIColor colorWithRed:0.15 green:0.71 blue:0.96 alpha:1.00];
        [self.titleCollectionView addSubview:_sliderLine];
        UICollectionViewFlowLayout *topLayout = (UICollectionViewFlowLayout *)self.titleCollectionView.collectionViewLayout;
        [_sliderLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(2);
            make.top.mas_equalTo(self.titleCollectionView.mas_top).mas_offset(topViewHeight-2);
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(topLayout.itemSize.width);
        }];
    }
    return _sliderLine;
}

@end
