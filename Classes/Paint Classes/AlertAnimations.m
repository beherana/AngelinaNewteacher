//
//  AlertAnimations.m
//  Angelina-New-Teacher-Universal
//
//  Created by Max Ehle on 2011-06-03.
//  Copyright 2011 Commind AB. All rights reserved.
//

#include "AlertAnimations.h"
#import <QuartzCore/QuartzCore.h>

#define kAnimationDuration  0.2555

@implementation UIView(AlertAnimations)

- (void)doPopInAnimation {
    [self doPopInAnimationWithDelegate:nil];
}

- (void)doPopInAnimationWithDelegate:(id)animationDelegate {
    CALayer *viewLayer = self.layer;
    CAKeyframeAnimation* popInAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    popInAnimation.duration = kAnimationDuration;
    popInAnimation.values = [NSArray arrayWithObjects:
                             [NSNumber numberWithFloat:0.6],
                             [NSNumber numberWithFloat:1.1],
                             [NSNumber numberWithFloat:.9],
                             [NSNumber numberWithFloat:1],
                             nil];
    popInAnimation.keyTimes = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0],
                               [NSNumber numberWithFloat:0.6],
                               [NSNumber numberWithFloat:0.8],
                               [NSNumber numberWithFloat:1.0], 
                               nil];    
    popInAnimation.delegate = animationDelegate;
    
    [viewLayer addAnimation:popInAnimation forKey:@"transform.scale"];  
}

- (void)doFadeInAnimation {
    [self doFadeInAnimationWithDelegate:nil];
}

- (void)doFadeInAnimationWithDelegate:(id)animationDelegate {
//    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
//    float comps[8] = {0, 0, 0, .3, 0, 0, 0, 0.6};
//    float locs[2] = {0, 1};
//    CGGradientRef gradient = CGGradientCreateWithColorComponents(space, comps, locs, 2);
//    
//    float x = [self bounds].size.width / 2.0;
//    float y = [self bounds].size.height / 2.0;
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGContextDrawRadialGradient(ctx, 
//                                gradient, 
//                                CGPointMake(x, y), 0, 
//                                CGPointMake(x, y), 160, 
//                                kCGGradientDrawsAfterEndLocation);
//    CGColorSpaceRelease(space);
//    CGGradientRelease(gradient);
    
    CALayer *viewLayer = self.layer;
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    fadeInAnimation.toValue = [NSNumber numberWithFloat:1.0];
    fadeInAnimation.duration = kAnimationDuration;
    fadeInAnimation.delegate = animationDelegate;
    [viewLayer addAnimation:fadeInAnimation forKey:@"opacity"];
    
}

@end