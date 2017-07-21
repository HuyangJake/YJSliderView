//
//  DotCountLabel.h
//  YJSliderView
//
//  Created by Jake on 17/2/6.
//  Copyright © 2017年 Jake. All rights reserved.
//

#import <UIKit/UIKit.h>



IB_DESIGNABLE
@interface DotCountLabel : UILabel

/**
 字体大小
 */
@property (nonatomic, assign) IBInspectable CGFloat fontWight;//默认 15

/**
 红点显示数量
 */
@property (nonatomic, assign) IBInspectable NSInteger countNum;


/**
 最大显示数量（不包含）
 */
@property (nonatomic, assign) IBInspectable NSInteger maxCountNum;//最大的红点数，默认100，超过显示 “99+”

//默认白字红底(若使用IB需要自行设定颜色)
- (instancetype _Nonnull)initWithFrame:(CGRect)frame fontWight:(CGFloat)fontWight;
@end
