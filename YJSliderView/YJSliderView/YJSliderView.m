//
//  YJSliderView.m
//  YJSliderView
//
//  Created by Jake on 2017/5/22.
//  Copyright © 2017年 Jake. All rights reserved.
//

#import "YJSliderView.h"
#import "Masonry.h"

static const CGFloat topViewHeight = 42;
static CGFloat scaleSize = 1.3;

typedef NS_ENUM(NSUInteger, CollectionViewType) {
    TITLE,
    CONTENT
};

/*============== SliderTitleCell ===================*/

@interface YJSliderTitleCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *labelContentView;//作为label的容器，方便在autolayout下使用修改label的transform属性
@property (nonatomic, strong) UIColor *themeColor;

- (void)bindStyleLabel:(UILabel *)label status:(BOOL)isSelected;

@end

@implementation YJSliderTitleCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.titleLabel.userInteractionEnabled = NO;
}

- (void)bindStyleLabel:(UILabel *)label status:(BOOL)isSelected {
    [self.titleLabel setText:label.text];
    [self.titleLabel setTextColor:isSelected ?  self.themeColor ? self.themeColor : [UIColor colorWithRed:0.15 green:0.71 blue:0.96 alpha:1.00] : [UIColor lightGrayColor]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.frame = self.labelContentView.frame;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor lightGrayColor];
        [self.labelContentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIView *)labelContentView {
    if (!_labelContentView) {
        _labelContentView = [[UIView alloc] init];
        _labelContentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_labelContentView];
        [_labelContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }
    return _labelContentView;
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
@property (nonatomic, strong) NSMutableArray *labelArray; //标题数组
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
    [self setUpLabels];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"YJSliderContentCell"];
    [self.titleCollectionView registerClass:[YJSliderTitleCell class] forCellWithReuseIdentifier:@"YJSliderTitleCell"];
    NSAssert(scaleSize >= 1, @"YJSliderView -- Title放大倍数需要不小于1的值");
    [self setUpLabels];
}


- (void)setUpLabels {
    self.labelArray = [NSMutableArray new];
    for (NSInteger index = 0; index < [self.delegate numberOfItemsInYJSliderView:self]; index ++) {
        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:self.fontSize ? self.fontSize : 15.0];
        label.text = [self.delegate yj_SliderView:self titleForItemAtIndex:index];
        label.textColor = self.themeColor ? self.themeColor : [UIColor colorWithRed:0.15 green:0.71 blue:0.96 alpha:1.00];
        [self.labelArray addObject:label];
    }
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
    YJSliderTitleCell *cell = (YJSliderTitleCell *)[self collectionView:self.titleCollectionView cellForItemAtIndexPath:indexPath];
    CGRect cellFrame = [self.titleCollectionView convertRect:cell.frame toView:self.titleCollectionView];
    CGFloat labelWidth = [self yj_calculateItemWithAtIndex:indexPath.row];
    CGFloat startPointX = cellFrame.origin.x + (cellFrame.size.width - labelWidth) / 2;
    
    YJSliderTitleCell *preCell = (YJSliderTitleCell *)[self collectionView:self.titleCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:preIndex inSection:0]];
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
    YJSliderTitleCell *cell = (YJSliderTitleCell *)[self collectionView:self.titleCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    CGRect cellFrame = [self.titleCollectionView convertRect:cell.frame toView:self.titleCollectionView];
    CGFloat labelWidth = [self yj_calculateItemWithAtIndex:index];
    
    [self.sliderLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(labelWidth);
        make.left.mas_equalTo(cellFrame.origin.x + (cellFrame.size.width - labelWidth) / 2);
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
            cell.themeColor = self.themeColor;
            BOOL isSelected = [[self.statusDic objectForKey:[NSNumber numberWithInteger:indexPath.row]] boolValue];
            [cell bindStyleLabel:self.labelArray[indexPath.item] status:isSelected];
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
        [self.contentCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
        [self.titleCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        [self.titleCollectionView reloadData];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.titleCollectionView) {
        NSInteger totalNum = [self.delegate numberOfItemsInYJSliderView:self];
        CGFloat width = 0;
        if ( totalNum <= 4) {
            width = self.frame.size.width / totalNum;
        } else {
            width = self.frame.size.width / 4;
        }
        CGFloat calcWidth = [self yj_calculateItemWithAtIndex:indexPath.row] + 20;//加上左右各10的边距
        if (calcWidth > width) {
            width = calcWidth;
        }
        return CGSizeMake(width, topViewHeight);
    } else {
        return CGSizeMake(self.frame.size.width, self.frame.size.height - topViewHeight);
    }
}

- (CGFloat)yj_calculateItemWithAtIndex:(NSInteger)index {
    NSString *title = [self.delegate yj_SliderView:self titleForItemAtIndex:index];
    NSDictionary *attrs = @{NSFontAttributeName: [UIFont systemFontOfSize:self.fontSize ? self.fontSize : 15.0]};
    CGFloat itemWidth = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attrs context:nil].size.width;
    return ceil(itemWidth);
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
        [self updateSliderLinePosition:indexValue fromIndex:self.currentIndex];
        [self updateLabelInCellAtIndex:indexValue fromIndex:self.currentIndex];
        /*
        NSInteger index = (NSInteger)indexValue;
        CGFloat lagerScale = scaleSize - (indexValue - index) * (scaleSize - 1);
        CGFloat smallScale = (indexValue - index) * (scaleSize - 1)  + 1;
        UILabel *currentLabel;
        UILabel *nextLabel;
        if (index < self.currentIndex) {
            currentLabel = self.labelArray[index + 1];
            nextLabel = self.labelArray[index];
            currentLabel.transform = CGAffineTransformMakeScale(smallScale, smallScale);
            nextLabel.transform = CGAffineTransformMakeScale(lagerScale, lagerScale);
            [self changeLabelColor:currentLabel To:[UIColor lightGrayColor] WithScale:(1 - (indexValue - index))];
            [self changeLabelColor:nextLabel To:self.themeColor ? self.themeColor : [UIColor colorWithRed:0.15 green:0.71 blue:0.96 alpha:1.00] WithScale:(1 - (indexValue - index))];
            
        } else {
            currentLabel = self.labelArray[index];
            currentLabel.transform = CGAffineTransformMakeScale(lagerScale, lagerScale);
            if (index + 1 == self.labelArray.count) {
                nextLabel = nil;
            } else {
                nextLabel = self.labelArray[index + 1];
                nextLabel.transform = CGAffineTransformMakeScale(smallScale, smallScale);
            }
            [self changeLabelColor:currentLabel To:[UIColor lightGrayColor] WithScale:(indexValue - index)];
            [self changeLabelColor:nextLabel To:self.themeColor ? self.themeColor : [UIColor colorWithRed:0.15 green:0.71 blue:0.96 alpha:1.00] WithScale:(indexValue - index)];
        }
         */
    }
}

#pragma mark - Actions

//更新Cell中Label的颜色和大小
- (void)updateLabelInCellAtIndex:(CGFloat)index fromIndex:(CGFloat)preIndex {
    NSIndexPath *indexPath;
    if (index == preIndex) {return;}
    if (index > preIndex) {
        indexPath = [NSIndexPath indexPathForItem:preIndex + 1 inSection:0];
    } else if (index < preIndex){
        indexPath = [NSIndexPath indexPathForItem:preIndex - 1 inSection:0];
    }
    CGFloat rate = fabs(index - preIndex);
    CGFloat lagerScale = scaleSize - rate * (scaleSize - 1);
    CGFloat smallScale = rate * (scaleSize - 1)  + 1;
    YJSliderTitleCell *cell = (YJSliderTitleCell *)[self collectionView:self.titleCollectionView cellForItemAtIndexPath:indexPath];
    cell.titleLabel.transform = CGAffineTransformMakeScale(smallScale, smallScale);
    
    YJSliderTitleCell *preCell = (YJSliderTitleCell *)[self collectionView:self.titleCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:preIndex inSection:0]];
    preCell.titleLabel.transform = CGAffineTransformMakeScale(lagerScale, lagerScale);
    
    [self changeLabelColor:cell.titleLabel To:self.themeColor ? self.themeColor : [UIColor colorWithRed:0.15 green:0.71 blue:0.96 alpha:1.00] WithScale:rate];
    [self changeLabelColor:preCell.titleLabel To:[UIColor lightGrayColor] WithScale:rate];
    
}

/**
 *  线性改变Label颜色
 *
 *  @param label  改色label
 *  @param toColor 改变后的颜色
 *  @param scale   改色进度
 */
- (void)changeLabelColor:(UILabel *)label To:(UIColor *)toColor WithScale:(CGFloat)scale {
    CGFloat originRed, originGreen, originBlue;
    [label.textColor getRed:&originRed green:&originGreen blue:&originBlue alpha:nil];
    CGFloat targetRed, targetGreen, targetBlue;
    [toColor getRed:&targetRed green:&targetGreen blue:&targetBlue alpha:nil];
    CGFloat currentRed, currentGreen, currentBlue;
    currentRed = originRed + (targetRed - originRed) * scale;
    currentGreen = originGreen + (targetGreen - originGreen) * scale;
    currentBlue = originBlue + (targetBlue - originBlue) * scale;
    label.textColor = [UIColor colorWithRed:currentRed green:currentGreen blue:currentBlue alpha:1];
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
        layout.itemSize = CGSizeMake(self.frame.size.width, self.frame.size.height - topViewHeight);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _contentCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.titleCollectionView.frame.size.height, self.frame.size.width, self.frame.size.height - topViewHeight) collectionViewLayout:layout];
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
                UILabel *label = self.labelArray[num];
                label.transform = CGAffineTransformMakeScale(scaleSize, scaleSize);
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
