//
//  SlowWarp.h
//  Thomas
//
//  Created by Johannes Amilon on 11/17/10.
//  Copyright 2010 Vitamin Se Media AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface SlowWarp : CCShaky3D {
	ccTime timeElapsed;
	ccTime frameTime;
}

-(id)initWithRange:(int)range shakeZ:(BOOL)sz grid:(ccGridSize)gSize duration:(ccTime)d frameRate:(float)framerate;

+(id)actionWithRange:(int)range shakeZ:(BOOL)shakeZ grid:(ccGridSize)gridSize duration:(ccTime)d frameRate:(float)framerate;

@end
