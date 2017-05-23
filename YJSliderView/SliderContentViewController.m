//
//  SliderContentViewController.m
//  YJSliderView
//
//  Created by Jake on 2017/5/22.
//  Copyright © 2017年 Jake. All rights reserved.
//

#import "SliderContentViewController.h"

@interface SliderContentViewController ()

@end

@implementation SliderContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"打印出来执行");
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        self.view.backgroundColor = [UIColor redColor];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"%@", self.view.backgroundColor);
    [self show];
}

- (void)show {
    NSLog(@"jake");
}

@end
