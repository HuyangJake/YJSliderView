//
//  YJSliderView.m
//  YJSliderView
//
//  Created by Jake on 2017/5/22.
//  Copyright © 2017年 Jake. All rights reserved.
//

#import "YJSliderView.h"
#import "Masonry.h"
#import "DotCountLabel.h"

static const CGFloat topViewHeight = 50;
static CGFloat scaleSize = 1.0;

typedef NS_ENUM(NSUInteger, CollectionViewType) {
    TITLE,
    CONTENT
};

/*============== SliderTitleCell ===================*/

@interface YJSliderTitleCell : UICollectionViewCell
@property (nonatomic, strong) UIButton *titleButton;
@property (nonatomic, strong) UIColor *themeColor;

- (void)bindStyleButton:(UIButton *)btn redNum:(NSInteger)redNum status:(BOOL)isSelected;

@end

@implementation YJSliderTitleCell

- (void)bindStyleButton:(UIButton *)btn redNum:(NSInteger)redNum status:(BOOL)isSelected {
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    self.titleButton = btn;
    self.titleButton.userInteractionEnabled = NO;
    [self.titleButton setTitle:btn.titleLabel.text forState:UIControlStateNormal];
    [self.titleButton setTitleColor:isSelected ?  self.themeColor ? self.themeColor : [UIColor colorWithRed:0.15 green:0.71 blue:0.96 alpha:1.00] : [UIColor lightGrayColor] forState:UIControlStateNormal];
    [self addSubview:self.titleButton];
    DotCountLabel *label = [[DotCountLabel alloc] initWithFrame:CGRectMake(0, 0, 15, 15) fontWight:12];
    [self addSubview:label];
    [self.titleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(8);
    }];
    label.countNum = redNum;
}

@end


/*============== SliderView ===================*/

@interface YJSliderView ()<UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic, assign, readwrite) NSInteger currentIndex;  //当前位置
@property (nonatomic, assign) NSInteger preIndex;//上一次的位置
@property (nonatomic, strong) UICollectionView *titleCollectionView;  //标题
@property (nonatomic, strong) UICollectionView *contentCollectionView; //内容
@property (nonatomic, strong) NSMutableDictionary *statusDic;   //位置选择状态
@property (nonatomic, strong) UIView *sliderLine;   //title底部滚动条
@property (nonatomic, strong) NSMutableArray *buttonArray; //标题数组

@property (nonatomic, strong) NSMutableDictionary *titleWidthCache;//标题文字宽度缓存
@end

@implementation YJSliderView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.maxCountInScreen = 4;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.maxCountInScreen = 4;
    }
    return self;
}

- (void)setMaxCountInScreen:(NSInteger)maxCountInScreen {
    _maxCountInScreen = maxCountInScreen;
}

- (void)reloadData {
    [self.contentCollectionView reloadData];
    [self.titleCollectionView reloadData];
    [self setUpButtons];
    [self.titleWidthCache removeAllObjects];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"YJSliderContentCell"];
    [self.titleCollectionView registerClass:[YJSliderTitleCell class] forCellWithReuseIdentifier:@"YJSliderTitleCell"];
    NSAssert(scaleSize >= 1, @"YJSliderView -- Title放大倍数需要不小于1的值");
    [self setUpButtons];
}

- (void)setUpButtons {
    self.buttonArray = [NSMutableArray new];
    self.titleWidthCache = [NSMutableDictionary new];
    for (NSInteger index = 0; index < [self.delegate numberOfItemsInYJSliderView:self]; index ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:self.fontSize ? self.fontSize : 15.0]];
        [btn.titleLabel setText:[self.delegate yj_SliderView:self titleForItemAtIndex:index]];
        [btn setTitleColor: self.themeColor ? self.themeColor : [UIColor colorWithRed:0.15 green:0.71 blue:0.96 alpha:1.00] forState:UIControlStateNormal];
        [self.buttonArray addObject:btn];
    }
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
            cell.themeColor = self.themeColor;
            BOOL isSelected = [[self.statusDic objectForKey:[NSNumber numberWithInteger:indexPath.row]] boolValue];
            if ([self.delegate respondsToSelector:@selector(yj_SliderView:redDotNumForItemAtIndex:)]) {
                [cell bindStyleButton:self.buttonArray[indexPath.item] redNum:[self.delegate yj_SliderView:self redDotNumForItemAtIndex:indexPath.row] status:isSelected];
            } else {
                [cell bindStyleButton:self.buttonArray[indexPath.item] redNum:0 status:isSelected];
            }
            
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewType type = collectionView.tag;
    if (type == TITLE) {
        [self manageButtonStatus:indexPath.item];
        [self.contentCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        [self.titleCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        [self updateSliderLinePosition:indexPath.item];
        [self.titleCollectionView reloadData];
        self.currentIndex = indexPath.item;
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.titleCollectionView) {
        NSInteger totalNum = [self.delegate numberOfItemsInYJSliderView:self];
        CGFloat width = 0;
        if ( totalNum <= self.maxCountInScreen) {
            width = self.frame.size.width / totalNum;
        } else {
            width = self.frame.size.width / self.maxCountInScreen;
        }
        CGFloat calcWidth = [self yj_calculateItemWithAtIndex:indexPath.row] + 30;//加上左右各10的边距
        if (calcWidth > width) {
            width = calcWidth;
        }
        return CGSizeMake(width, topViewHeight);
    } else {
        return CGSizeMake(self.frame.size.width, self.frame.size.height - topViewHeight);
    }
}

- (CGFloat)yj_calculateItemWithAtIndex:(NSInteger)index {
    NSNumber *width = [self.titleWidthCache objectForKey:[NSString stringWithFormat:@"%ld", index]];
    if (width) {
        return [width doubleValue];
    } else {
        NSString *title = [self.delegate yj_SliderView:self titleForItemAtIndex:index];
        NSDictionary *attrs = @{NSFontAttributeName: [UIFont systemFontOfSize:self.fontSize ? self.fontSize : 15.0]};
        CGFloat itemWidth = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attrs context:nil].size.width;
        [self.titleWidthCache setObject:@(itemWidth) forKey:[NSString stringWithFormat:@"%ld", index]];
        return ceil(itemWidth);
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
//    self.titleCollectionView.userInteractionEnabled = YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    self.titleCollectionView.userInteractionEnabled = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.tag == CONTENT) {
        [self scrollViewDidEndScrollingAnimation:scrollView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tag == CONTENT) {
        CGFloat indexValue = (CGFloat)(scrollView.contentOffset.x / [UIScreen mainScreen].bounds.size.width);
        CGFloat currentIndexValue = 0.00;
        if (indexValue > self.currentIndex) {
           currentIndexValue = floor(indexValue);
        } else {
            currentIndexValue = ceil(indexValue);
        }
        [self updateSliderLinePosition:indexValue fromIndex:currentIndexValue];
        [self updateLabelInCellAtIndex:currentIndexValue nextIndex:indexValue];
    }
}

#pragma mark - Actions

//更新Cell中Label的颜色和大小
- (void)updateLabelInCellAtIndex:(CGFloat)index nextIndex:(CGFloat)nextIndex {
    NSIndexPath *indexPath;
    if (index == nextIndex) {return;}
    if (index > nextIndex) {
        indexPath = [NSIndexPath indexPathForItem:index - 1 inSection:0];
    } else if (index < nextIndex){
        indexPath = [NSIndexPath indexPathForItem:index + 1 inSection:0];
    }
    CGFloat rate = fabs(index - nextIndex);
    CGFloat lagerScale = scaleSize - rate * (scaleSize - 1);
    CGFloat smallScale = rate * (scaleSize - 1) + 1;
    
    UIButton *nextBtn = self.buttonArray[indexPath.row];
    UIButton *currentBtn = self.buttonArray[(int)index];
    
    [self changeButtonColor:nextBtn To:self.themeColor ? self.themeColor : [UIColor colorWithRed:0.15 green:0.71 blue:0.96 alpha:1.00] WithScale:rate];
    [self changeButtonColor:currentBtn To:[UIColor lightGrayColor] WithScale:rate];
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:1.0];
    nextBtn.transform = CGAffineTransformMakeScale(smallScale, smallScale);
    currentBtn.transform = CGAffineTransformMakeScale(lagerScale, lagerScale);
    [CATransaction commit];
    
}

/**
 *  线性改变UIButton颜色
 *
 *  @param btn  改色btn
 *  @param toColor 改变后的颜色
 *  @param scale   改色进度
 */
- (void)changeButtonColor:(UIButton *)btn To:(UIColor *)toColor WithScale:(CGFloat)scale {
    CGFloat originRed, originGreen, originBlue;
    [btn.titleLabel.textColor getRed:&originRed green:&originGreen blue:&originBlue alpha:nil];
    CGFloat targetRed, targetGreen, targetBlue;
    [toColor getRed:&targetRed green:&targetGreen blue:&targetBlue alpha:nil];
    CGFloat currentRed, currentGreen, currentBlue;
    currentRed = originRed + (targetRed - originRed) * scale;
    currentGreen = originGreen + (targetGreen - originGreen) * scale;
    currentBlue = originBlue + (targetBlue - originBlue) * scale;
    [btn setTitleColor:[UIColor colorWithRed:currentRed green:currentGreen blue:currentBlue alpha:1] forState:UIControlStateNormal];
}

/**
 *  更新下划线位置
 *
 *  @param index 当前位置
 */
- (void)updateSliderLinePosition:(CGFloat)index fromIndex:(CGFloat)preIndex{
    NSIndexPath *indexPath;
    if (index == preIndex) {return;}
    if (index > preIndex) {
        indexPath = [NSIndexPath indexPathForItem:preIndex + 1 inSection:0];
    } else if (index < preIndex){
        indexPath = [NSIndexPath indexPathForItem:preIndex - 1 inSection:0];
    }
    
    YJSliderTitleCell *cell = [self.titleCollectionView dequeueReusableCellWithReuseIdentifier:@"YJSliderTitleCell" forIndexPath:indexPath];
    CGRect cellFrame = [self.titleCollectionView convertRect:cell.frame toView:self.titleCollectionView];
    CGFloat labelWidth = [self yj_calculateItemWithAtIndex:indexPath.row];
    CGFloat startPointX = cellFrame.origin.x + (cellFrame.size.width - labelWidth) / 2;
    
    YJSliderTitleCell *preCell = [self.titleCollectionView dequeueReusableCellWithReuseIdentifier:@"YJSliderTitleCell" forIndexPath:[NSIndexPath indexPathForItem:preIndex inSection:0]];
    CGRect preCellFrame = [self.titleCollectionView convertRect:preCell.frame toView:self.titleCollectionView];
    CGFloat preLabelWidth = [self yj_calculateItemWithAtIndex:preIndex];
    CGFloat preStartPointX = preCellFrame.origin.x + (preCellFrame.size.width - preLabelWidth) / 2;
    
    CGFloat rate = fabs(index - preIndex);
    [self.sliderLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(preLabelWidth + (labelWidth - preLabelWidth) * rate);
        make.left.mas_equalTo(preStartPointX + (startPointX - preStartPointX) * rate);
    }];
}

- (void)updateSliderLinePosition:(CGFloat)index {
    YJSliderTitleCell *cell = [self.titleCollectionView dequeueReusableCellWithReuseIdentifier:@"YJSliderTitleCell" forIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    CGRect cellFrame = [self.titleCollectionView convertRect:cell.frame toView:self.titleCollectionView];
    CGFloat labelWidth = [self yj_calculateItemWithAtIndex:index];
    
    [self.sliderLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(labelWidth);
        make.left.mas_equalTo(cellFrame.origin.x + (cellFrame.size.width - labelWidth) / 2);
    }];
}

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [self manageButtonStatus:indexPath.item];
    [self.contentCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:animated];
    [self.titleCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
    [self updateSliderLinePosition:indexPath.item fromIndex:self.currentIndex];
    [self.titleCollectionView reloadData];
    self.currentIndex = indexPath.item;
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
        _titleCollectionView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_titleCollectionView];
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_titleCollectionView.frame), CGRectGetWidth(self.frame), 0.5)];
        lineView.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.00];
        [self addSubview:lineView];
        
    }
    
    UICollectionViewFlowLayout *topLayout = (UICollectionViewFlowLayout *)_titleCollectionView.collectionViewLayout;
    NSInteger totalNum = [self.delegate numberOfItemsInYJSliderView:self];
    if ( totalNum <= self.maxCountInScreen) {
        topLayout.itemSize = CGSizeMake(self.frame.size.width / totalNum, topViewHeight);
    } else {
        topLayout.itemSize = CGSizeMake(self.frame.size.width / self.maxCountInScreen, topViewHeight);
    }
    
    return _titleCollectionView;
}

- (UICollectionView *)contentCollectionView {
    if (_contentCollectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(self.frame.size.width, self.frame.size.height - topViewHeight);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _contentCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.titleCollectionView.frame.size.height+0.5, self.frame.size.width, self.frame.size.height - topViewHeight) collectionViewLayout:layout];
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
    if ([self.delegate respondsToSelector:@selector(switchedToIndex:)]) {
        [self.delegate switchedToIndex:index];
    }
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
            if ([self.delegate respondsToSelector:@selector(initialzeIndexForYJSliderView:)]) {
                initializeIndex = [self.delegate initialzeIndexForYJSliderView:self];
            }
            if (num == initializeIndex) {
                self.currentIndex = num;
                [_statusDic setObject:[NSNumber numberWithBool:YES] forKey:[NSNumber numberWithInt:num]];
                [self.contentCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:num inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
                [self.titleCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:num inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
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
