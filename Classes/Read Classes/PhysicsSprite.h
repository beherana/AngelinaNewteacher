//
//  PhysicsSprite.h
//  Thomas
//
//  Created by Johannes Amilon on 11/16/10.
//  Copyright 2010 Vitamin Se Media AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface PhysicsSprite : CCSprite {
	CGSize spriteOffset;
	BOOL preventRotation;
	BOOL canGrab;
	CGPoint startPosition;
	CGPoint startVelocity;
	float startRotation;
	float startSpin;
}

@property(nonatomic) CGSize spriteOffset;
@property(nonatomic) BOOL preventRotation;
@property(nonatomic) BOOL canGrab;
@property(nonatomic) CGPoint startPosition;
@property(nonatomic) CGPoint startVelocity;
@property(nonatomic) float startRotation;
@property(nonatomic) float startSpin;

@end
