//
//  MenuTouchPassthroughView.m
//  Angelina-New-Teacher-Universal
//
//  Created by Karl Söderström on 2011-11-22.
//  Copyright (c) 2011 Commind AB. All rights reserved.
//

#import "MenuTouchPassthroughView.h"

@implementation MenuTouchPassthroughView

-(id)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    id hitView = [super hitTest:point withEvent:event];
    if (hitView == self) return nil;
    else return hitView;
}

@end
