//
//  PhysicsSprite.m
//  Thomas
//
//  Created by Johannes Amilon on 11/16/10.
//  Copyright 2010 Vitamin Se Media AB. All rights reserved.
//

#import "PhysicsSprite.h"


@implementation PhysicsSprite

@synthesize spriteOffset,preventRotation,canGrab,startPosition,startVelocity,startRotation,startSpin;

-(id) init{
	if ((self=[super init])) {
		spriteOffset=CGSizeMake(0, 0);
		preventRotation=NO;
		canGrab=NO;
		startPosition=CGPointMake(0, 0);
		startVelocity=CGPointMake(0, 0);
		startRotation=0;
	}
	return self;
}

@end
