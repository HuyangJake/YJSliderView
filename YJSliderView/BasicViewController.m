//
//  BasicViewController.m
//  YJSliderView
//
//  Created by Jake on 2017/5/22.
//  Copyright © 2017年 Jake. All rights reserved.
//

#import "BasicViewController.h"
#import "SliderContentViewController.h"
#import "YJSliderView.h"

@interface BasicViewController ()<YJSliderViewDelegate>
@property (nonatomic, strong) YJSliderView *sliderView;
@property (nonatomic, strong) NSArray *contentArray;
@property (nonatomic, strong) NSArray *titleArray;
@end

@implementation BasicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //需要将UIView的自动调整ScrollViewInset关闭
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"Slider";
    self.sliderView = [[YJSliderView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height)];
    self.sliderView.delegate = self;
    self.titleArray = @[@"灰色", @"黄色黄色黄色黄色黄色黄色", @"紫", @"橘色", @"蓝色"];
    [self.view addSubview:self.sliderView];
}

- (NSInteger)numberOfItemsInYJSliderView:(YJSliderView *)sliderView {
    return 4;
}

- (UIView *)yj_SliderView:(YJSliderView *)sliderView viewForItemAtIndex:(NSInteger)index {
    SliderContentViewController *vc = [[SliderContentViewController alloc] init];
    if (index == 0) {
        vc.view.backgroundColor = [UIColor lightGrayColor];
    } else if (index == 1) {
        vc.view.backgroundColor = [UIColor yellowColor];
    } else if (index == 2) {
        vc.view.backgroundColor = [UIColor purpleColor];
    } else {
        vc.view.backgroundColor = [UIColor orangeColor];
    }
    return vc.view;
}

- (NSString *)yj_SliderView:(YJSliderView *)sliderView titleForItemAtIndex:(NSInteger)index {
    return self.titleArray[index];
}

- (NSInteger)initialzeIndexFoYJSliderView:(YJSliderView *)sliderView {
    return 3;
}

@end
