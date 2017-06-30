//
//  YJSliderView.h
//  YJSliderView
//
//  Created by Jake on 2017/5/22.
//  Copyright © 2017年 Jake. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YJSliderView;
/**
 代理方法用于初始化界面（模仿UITableViewDataSource）和实现刷新的操作
 */
@protocol YJSliderViewDelegate <NSObject>

@required
- (NSInteger)numberOfItemsInYJSliderView:(YJSliderView *)sliderView;

- (UIView *)yj_SliderView:(YJSliderView *)sliderView viewForItemAtIndex:(NSInteger)index;

- (NSString *)yj_SliderView:(YJSliderView *)sliderView titleForItemAtIndex:(NSInteger)index;

@optional
/**
 初始化的位置
 
 @param sliderView 当前sliderView
 @return 初始化显示的位置
 */
- (NSInteger)initialzeIndexFoYJSliderView:(YJSliderView *)sliderView;


@end

@interface YJSliderView : UIView

@property (nonatomic, weak) id<YJSliderViewDelegate> delegate;

@property (nonatomic, assign, readonly) NSInteger currentIndex;

@property (nonatomic, strong) UIColor *themeColor;

@property (nonatomic, assign) CGFloat fontSize;

- (void)reloadData;

@end
