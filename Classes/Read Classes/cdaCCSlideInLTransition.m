//
//  cdaCCSlideInLTransition.m
//  Angelina-New-Teacher-Universal
//
//  Created by Radif Sharafullin on 5/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cdaCCSlideInLTransition.h"


@implementation cdaCCSlideInLTransition

-(void) draw
{
    [outScene_ visit];
    [inScene_ visit];
}
 
@end
@implementation cdaCCTransitionFadeL
-(CCActionInterval*) actionWithSize: (ccGridSize) v
{
	return [cdaCCFadeOutLTiles actionWithSize:v duration:duration_];
}
@end
#pragma mark cdaCCFadeOutLTiles

@implementation cdaCCFadeOutLTiles

-(float)testFunc:(ccGridSize)pos time:(ccTime)time
{
	CGPoint	n = ccpMult(ccp(gridSize_.x, gridSize_.y), time);
	if ( n.y == 0 )
		return 1.0f;
	
	return powf( pos.x / n.x, 6 );
}

@end

@implementation cdaCCTransitionFadeR
-(CCActionInterval*) actionWithSize: (ccGridSize) v
{
	return [cdaCCFadeOutRTiles actionWithSize:v duration:duration_];
}

@end
#pragma mark cdaCCFadeOutRTiles

@implementation cdaCCFadeOutRTiles

-(float)testFunc:(ccGridSize)pos time:(ccTime)time
{
	CGPoint	n = ccpMult(ccp(gridSize_.x, gridSize_.y), (1.0f - time));
	//if ( pos.y == 0 )//this covers the last row
	//	return 0.0f;
	
	return powf( n.x / pos.x, 6 );
}

@end