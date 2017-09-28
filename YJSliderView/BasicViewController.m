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
@property (nonatomic, strong) NSMutableArray *contentArray;
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
    self.contentArray = [NSMutableArray new];
    for (NSInteger index = 0; index < 5; index ++) {
        SliderContentViewController *vc = [[SliderContentViewController alloc] init];
        [self.contentArray addObject:vc];
    }
}

- (NSInteger)numberOfItemsInYJSliderView:(YJSliderView *)sliderView {
    return 4;
}

- (UIView *)yj_SliderView:(YJSliderView *)sliderView viewForItemAtIndex:(NSInteger)index {
    //因为没有写重用的逻辑，建议在控制器中定义view的数组，在此处取出展示(注意在此处定义控制器传入它的view，view中的子视图最好使用约束进行布局)
    SliderContentViewController *vc = self.contentArray[index];
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

- (NSInteger)initialzeIndexForYJSliderView:(YJSliderView *)sliderView {
    return 3;
}

- (NSInteger)yj_SliderView:(YJSliderView *)sliderView redDotNumForItemAtIndex:(NSInteger)index {
    return 0;
}

- (void)switchedToIndex:(NSInteger)index {
    NSLog(@"切换到位置%ld", index);
}

@end
