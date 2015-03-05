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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    KYCuteView *cuteView = [[KYCuteView alloc] initWithCenter:CGPointMake(25, 505) width:35];
    cuteView.viscosity  = 20;
    cuteView.bubbleColor = [UIColor colorWithRed:0 green:0.722 blue:1 alpha:1];
    cuteView.text = @"13";
    [self.view addSubview:cuteView];
    
    KYCuteView *otherCuteView = [[KYCuteView alloc] initWithCenter:CGPointMake(0, 160) width:35];
    otherCuteView.viscosity  = 20;
    otherCuteView.bubbleColor = [UIColor colorWithRed:0 green:0.722 blue:1 alpha:1];
    otherCuteView.text = @"17";
    [self.view addSubview:otherCuteView];
}

@end
