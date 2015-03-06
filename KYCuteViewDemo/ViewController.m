//
//  ViewController.m
//  KYCuteViewDemo
//
//  Created by Kitten Yang on 2/26/15.
//  Copyright (c) 2015 Kitten Yang. All rights reserved.
//


#import "ViewController.h"
#import "KYCuteView.h"

@interface ViewController ()

@property (nonatomic, strong) KYCuteView *cuteView;
@property (nonatomic, assign) int bubbleCount;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bubbleCount = 0;
    
    self.cuteView = [[KYCuteView alloc] initWithCenter:CGPointMake(25, 505) width:35];
    self.cuteView.viscosity  = 20;
    self.cuteView.bubbleColor = [UIColor colorWithRed:0 green:0.722 blue:1 alpha:1];
    self.cuteView.text = [NSString stringWithFormat:@"%d", self.bubbleCount++];
    [self.view addSubview:self.cuteView];
    
    [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(countLoop) userInfo:nil repeats:YES];
}

- (void)countLoop {
    self.cuteView.text = [NSString stringWithFormat:@"%d", self.bubbleCount++];
}

@end
