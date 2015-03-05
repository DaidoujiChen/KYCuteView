//
//  KYCuteView.m
//  KYCuteViewDemo
//
//  Created by Kitten Yang on 2/26/15.
//  Copyright (c) 2015 Kitten Yang. All rights reserved.
//


#import "KYCuteView.h"

#define defaultViscosity 20.0f

@interface KYCuteView ()

//同步系統幀數
@property (nonatomic, strong) CADisplayLink *displayLink;

//內部實際呈現的兩個子 view
@property (nonatomic, strong) UIView *frontView;
@property (nonatomic, strong) UIView *backView;

//記錄原先 bubble 的位置
@property (nonatomic, assign) CGRect originalBackViewFrame;
@property (nonatomic, assign) CGPoint originalBackViewCenter;

//气泡上显示数字的label
//the label on the bubble
@property (nonatomic, strong) UILabel *bubbleLabel;

//气泡的直径
//bubble's diameter
@property (nonatomic, assign) CGFloat bubbleWidth;

//拉扯時會用到的顯示圖層
@property (nonatomic, strong) CAShapeLayer *shapeLayer;

//主要用於計算拉扯時後 layer 的顯示
@property (nonatomic, assign) CGFloat r1;
@property (nonatomic, assign) CGFloat r2;
@property (nonatomic, assign) CGPoint pointA;
@property (nonatomic, assign) CGPoint pointB;
@property (nonatomic, assign) CGPoint pointC;
@property (nonatomic, assign) CGPoint pointD;
@property (nonatomic, assign) CGPoint pointO;
@property (nonatomic, assign) CGPoint pointP;

@end

@implementation KYCuteView

@synthesize bubbleColor = _bubbleColor;

#pragma mark - implement setters / getters

- (void)setText:(NSString *)text {
    if (!self.bubbleLabel) {
        self.bubbleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frontView.bounds.size.width, self.frontView.bounds.size.height)];
        self.bubbleLabel.textColor = [UIColor whiteColor];
        self.bubbleLabel.textAlignment = NSTextAlignmentCenter;
        [self.frontView insertSubview:self.bubbleLabel atIndex:0];
    }
    self.bubbleLabel.text = text;
}

- (NSString *)text {
    return self.bubbleLabel.text;
}

- (void)setBubbleColor:(UIColor *)bubbleColor {
    self.frontView.backgroundColor = bubbleColor;
    self.backView.backgroundColor = bubbleColor;
    _bubbleColor = bubbleColor;
}

- (UIColor *)bubbleColor {
    return _bubbleColor;
}

#pragma mark - private

#pragma mark * init

//初始化基本的變數
- (void)setupInitValues:(CGFloat)width {
    self.backgroundColor = [UIColor clearColor];
    self.shapeLayer = [CAShapeLayer layer];
    self.bubbleWidth = width;
    self.viscosity = defaultViscosity;
    self.isNeedGameCenterMotionEffect = YES;
}

//添加主要的兩個 view
- (void)initInternalViewsAtPoint:(CGPoint)point {
    
    //初始化 frontView
    self.frontView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bubbleWidth, self.bubbleWidth)];
    self.r2 = self.frontView.bounds.size.width / 2;
    self.frontView.layer.cornerRadius = self.r2;
    [self addSubview:self.frontView];
    
    //初始化 backView
    self.backView = [[UIView alloc] initWithFrame:self.frontView.frame];
    self.r1 = self.backView.bounds.size.width / 2;
    self.backView.layer.cornerRadius = self.r1;
    self.backView.hidden = YES; //为了看到frontView的气泡晃动效果，需要展示隐藏backView
    [self addSubview:self.backView];
    
    self.originalBackViewFrame = self.backView.frame;
    self.originalBackViewCenter = self.backView.center;
    
    if (self.isNeedGameCenterMotionEffect) {
        [self addAniamtionLikeGameCenterBubble];
    }
}

//加入手勢
- (void)addGestureRecognizer {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragView:)];
    [self addGestureRecognizer:pan];
}

//加入當 backView hidden 變動時的 observer
- (void)addKVOObserver {
    [self addObserver:self forKeyPath:@"backView.hidden" options:0 context:NULL];
}

#pragma mark * CADisplayLink 每隔一帧刷新屏幕的定时器

//加上 displayLink
- (void)addDisplayLink {
    if (!self.displayLink) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction:)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

//移除 displayLink
- (void)removeDisplayLink {
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

// displayLink 運行時, call 回來的 method
- (void)displayLinkAction:(CADisplayLink *)displayLink {
    [self calculateForShapeLayer];
    [self drawShapeLayer];
}

//計算要畫出 shape layer 時需要的相關變數
- (void)calculateForShapeLayer {
    CGFloat x1 = self.backView.center.x;
    CGFloat y1 = self.backView.center.y;
    CGFloat x2 = self.frontView.center.x;
    CGFloat y2 = self.frontView.center.y;
    
    CGFloat deltaX = (x2 - x1);
    CGFloat deltaY = (y2 - y1);
    CGFloat centerDistance = sqrtf(powf(deltaX, 2) + pow(deltaY, 2));
    CGFloat cosDigree = 1;
    CGFloat sinDigree = 0;
    if (centerDistance) {
        cosDigree = deltaY / centerDistance;
        sinDigree = deltaX / centerDistance;
    }
    
    self.r1 = self.originalBackViewFrame.size.width / 2 - centerDistance / self.viscosity;
    self.pointA = CGPointMake(x1 - self.r1 * cosDigree, y1 + self.r1 * sinDigree);
    self.pointB = CGPointMake(x1 + self.r1 * cosDigree, y1 - self.r1 * sinDigree);
    self.pointD = CGPointMake(x2 - self.r2 * cosDigree, y2 + self.r2 * sinDigree);
    self.pointC = CGPointMake(x2 + self.r2 * cosDigree, y2 - self.r2 * sinDigree);
    self.pointO = CGPointMake(self.pointA.x + (centerDistance / 2) * sinDigree, self.pointA.y + (centerDistance / 2) * cosDigree);
    self.pointP = CGPointMake(self.pointB.x + (centerDistance / 2) * sinDigree, self.pointB.y + (centerDistance / 2) * cosDigree);
}

//畫出被拉扯時的效果, 以及原來的地方圈圈縮小的狀態
- (void)drawShapeLayer {
    self.backView.center = self.originalBackViewCenter;
    self.backView.bounds = CGRectMake(0, 0, self.r1 * 2, self.r1 * 2);
    self.backView.layer.cornerRadius = self.r1;
    
    if (!self.backView.hidden) {
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        [bezierPath moveToPoint:self.pointA];
        [bezierPath addQuadCurveToPoint:self.pointD controlPoint:self.pointO];
        [bezierPath addLineToPoint:self.pointC];
        [bezierPath addQuadCurveToPoint:self.pointB controlPoint:self.pointP];
        [bezierPath moveToPoint:self.pointA];
        self.shapeLayer.path = [bezierPath CGPath];
        self.shapeLayer.fillColor = (self.backView.hidden) ? [[UIColor clearColor] CGColor] : [self.bubbleColor CGColor];
        [self.layer insertSublayer:self.shapeLayer below:self.frontView.layer];
    }
}

#pragma mark * 響應手勢操作

- (void)dragView:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint dragLocationInView = [panGestureRecognizer locationInView:self];
    
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.backView.hidden = NO;
            break;
            
        case UIGestureRecognizerStateChanged:
            self.frontView.center = dragLocationInView;
            if (self.r1 <= 6) {
                self.backView.hidden = YES;
            }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            self.backView.hidden = YES;
            [UIView animateWithDuration:0.5 delay:0.0f usingSpringWithDamping:0.4f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveEaseInOut animations: ^{
                self.frontView.center = self.originalBackViewCenter;
            } completion: ^(BOOL finished) {
                if (finished && self.isNeedGameCenterMotionEffect) {
                    [self addAniamtionLikeGameCenterBubble];
                }
            }];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark * Key-Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    //當 self.backView.hidden 有更動時
    if ([keyPath isEqual:@"backView.hidden"]) {
        if (self.backView.hidden) {
            [self.shapeLayer removeFromSuperlayer];
            [self removeDisplayLink];
        }
        else {
            [self removeAniamtionLikeGameCenterBubble];
            [self addDisplayLink];
        }
    }
}

- (void)removeKVOObserver {
    [self removeObserver:self forKeyPath:@"backView.hidden"];
}

#pragma mark * 汽泡晃動效果

- (void)addAniamtionLikeGameCenterBubble {
    [self.frontView.layer addAnimation:[self defaultBubbleMovingAnimation] forKey:@"bubbleMoveAnimation"];
    [self.frontView.layer addAnimation:[self defaultBubbleScalingAnimationDuration:1.0f forKeyPath:@"transform.scale.x"] forKey:@"bubbleScaleXAnimation"];
    [self.frontView.layer addAnimation:[self defaultBubbleScalingAnimationDuration:1.5f forKeyPath:@"transform.scale.y"] forKey:@"bubbleScaleYAnimation"];
}

- (void)removeAniamtionLikeGameCenterBubble {
    [self.frontView.layer removeAllAnimations];
}

//基本泡泡移動動畫
- (CAKeyframeAnimation *)defaultBubbleMovingAnimation {
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.repeatCount = INFINITY;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    pathAnimation.duration = 5.0;
    
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGRect circleContainer = CGRectInset(self.frontView.frame, self.frontView.bounds.size.width / 2 - 3, self.frontView.bounds.size.width / 2 - 3);
    CGPathAddEllipseInRect(curvedPath, NULL, circleContainer);
    
    pathAnimation.path = curvedPath;
    CGPathRelease(curvedPath);
    return pathAnimation;
}

//基本泡泡縮放動畫
- (CAKeyframeAnimation *)defaultBubbleScalingAnimationDuration:(NSTimeInterval)duration forKeyPath:(NSString *)keyPath {
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
    scaleAnimation.duration = duration;
    scaleAnimation.values = @[@1.0, @1.1, @1.0];
    scaleAnimation.keyTimes = @[@0.0, @0.5, @1.0];
    scaleAnimation.repeatCount = INFINITY;
    scaleAnimation.autoreverses = YES;
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return scaleAnimation;
}

#pragma mark - life cycle

- (id)initWithCenter:(CGPoint)center width:(CGFloat)width {
    //設定泡泡的中心點
    CGRect frame = CGRectMake(center.x - width / 2, center.y - width / 2, width, width);
    self = [super initWithFrame:frame];
    if (self) {
        [self setupInitValues:width];
        [self initInternalViewsAtPoint:center];
        [self addGestureRecognizer];
        [self addKVOObserver];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        [self removeDisplayLink];
        [self removeKVOObserver];
    }
}

@end
