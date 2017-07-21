//
//  DotCountLabel.m
//  YJSliderView
//
//  Created by Jake on 17/2/6.
//  Copyright © 2017年 Jake. All rights reserved.
//

#import "DotCountLabel.h"


@interface DotCountLabel ()
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, strong) UIColor *backColor;
@end

@implementation DotCountLabel

- (void)drawRect:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    [_backColor set];
    [path fill];
    [super drawRect:rect];
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithFrame:(CGRect)frame fontWight:(CGFloat)fontWight {
    if (self = [super initWithFrame:frame]) {
        self.layer.masksToBounds = YES;
        self.textAlignment = NSTextAlignmentCenter;
        self.fontWight = fontWight;
        self.textColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor redColor];
        self.fontWight = _fontWight == 0 ? 15 : _fontWight;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    NSAssert(NO, @"DotCountLabel----请调用initWithFrame: fontWight:初始化方法");
    return nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.layer.masksToBounds = YES;
        self.textAlignment = NSTextAlignmentCenter;
        self.fontWight = _fontWight == 0 ? 15 : _fontWight;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize size = [self.text sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:self.fontWight]}];
    size.width += self.fontWight / 2;
    if (size.width < size.height) {
        size.width = size.height;
    }
    CGRect originFrame = self.frame;
    originFrame.size.width = size.width;
    originFrame.size.height = size.height;
    self.frame = originFrame;
    self.cornerRadius = size.height / 2;
}


- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
}

- (void)setFontWight:(CGFloat)fontWight {
    _fontWight = fontWight;
    self.font = [UIFont systemFontOfSize:fontWight];
}

- (void)setCountNum:(NSInteger)countNum {
    _countNum = countNum;
    self.hidden = countNum == 0 ? YES : NO;
    if (countNum < self.maxCountNum) {
        self.text = [NSString stringWithFormat:@"%ld", (long)countNum];
    } else {
        self.text = [NSString stringWithFormat:@"%ld+", (long)self.maxCountNum - 1];
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backColor = backgroundColor;
}

- (NSInteger)maxCountNum {
    if (_maxCountNum == 0) {
        _maxCountNum = 100;
    }
    return _maxCountNum;
}

@end
