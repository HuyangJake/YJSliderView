//
//  IBBasicViewController.m
//  YJSliderView
//
//  Created by jakey on 2017/6/30.
//  Copyright © 2017年 Jake. All rights reserved.
//

#import "IBBasicViewController.h"
#import "YJSliderView.h"

@interface IBBasicViewController ()<YJSliderViewDelegate>
@property (weak, nonatomic) IBOutlet YJSliderView *sliderView;
@property (nonatomic, strong) NSArray *viewsArray;
@end

@implementation IBBasicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sliderView.delegate = self;
    self.viewsArray = [NSArray new];
    UIView *view = [[UIView alloc] initWithFrame:self.view.frame];
    view.backgroundColor = [UIColor lightGrayColor];
    UIView *view2 = [[UIView alloc] initWithFrame:self.view.frame];
    view2.backgroundColor = [UIColor yellowColor];
    UIView *view3 = [[UIView alloc] initWithFrame:self.view.frame];
    view3.backgroundColor = [UIColor yellowColor];
    self.viewsArray = @[view, view2, view3];
}

- (IBAction)tapScrollBtn:(UIBarButtonItem *)sender {
    [self.sliderView scrollToIndex:2 animated:YES];
}

- (NSInteger)numberOfItemsInYJSliderView:(YJSliderView *)sliderView {
    return 3;
}

- (UIView *)yj_SliderView:(YJSliderView *)sliderView viewForItemAtIndex:(NSInteger)index {
    //因为没有写重用的逻辑，建议在控制器中定义view的数组，在此处取出展示(注意在此处定义控制器传入它的view，view中的子视图最好使用约束进行布局)
    return self.viewsArray[index];
}

- (NSString *)yj_SliderView:(YJSliderView *)sliderView titleForItemAtIndex:(NSInteger)index {
    return index? @"First" : @"Other";
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
