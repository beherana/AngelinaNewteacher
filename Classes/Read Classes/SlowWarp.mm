//
//  SlowWarp.mm
//  Thomas
//
//  Created by Johannes Amilon on 11/17/10.
//  Copyright 2010 Vitamin Se Media AB. All rights reserved.
//

#import "SlowWarp.h"


@implementation SlowWarp

+(id)actionWithRange:(int)range shakeZ:(BOOL)shakeZ grid:(ccGridSize)gridSize duration:(ccTime)d frameRate:(float)framerate{
	return [[[self alloc] initWithRange:range shakeZ:shakeZ grid:gridSize duration:d frameRate:framerate] autorelease];
}

-(id)initWithRange:(int)range shakeZ:(BOOL)sz grid:(ccGridSize)gSize duration:(ccTime)d frameRate:(float)framerate
{
	if ( (self = [super initWithRange:range shakeZ:sz grid:gSize duration:d]) )
	{
		frameTime=1.0/(d*framerate);
		timeElapsed=0;
	}
	
	return self;
}

-(void)update:(ccTime)time{
	if (time-timeElapsed>=frameTime) {
		timeElapsed+=frameTime;
		[super update:time];
	}
}

@end
