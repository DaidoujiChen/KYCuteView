//
//  KYCuteView.h
//  KYCuteViewDemo
//
//  Created by Kitten Yang on 2/26/15.
//  Copyright (c) 2015 Kitten Yang. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface KYCuteView : UIView

//汽泡上要顯示的文字
//the label on the bubble
@property (nonatomic, strong) NSString *text;

//气泡粘性系数，越大可以拉得越长
//viscosity of the bubble,the bigger you set,the longer you drag
@property (nonatomic, assign) CGFloat viscosity;

//气泡颜色
//bubble's color
@property (nonatomic, strong) UIColor *bubbleColor;

//設定是否需要像是 GameCenter 的漂浮移動
// default 值是 YES
@property (nonatomic, assign) BOOL isNeedGameCenterMotionEffect;

- (id)initWithCenter:(CGPoint)center width:(CGFloat)width;

@end
