//
//  SetPropsAction.m
//  Thomas Animation Example
//
//  Created by Henrik Nord on 10/25/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "SetPropsAction.h"


@implementation CCSetFrame

+(id)actionWithSpriteFrame:(CCSpriteFrame *)frame_
{
	return [[[self alloc] initWithSpriteFrame:frame_] autorelease];
}

-(id)initWithSpriteFrame:(CCSpriteFrame *)frame_
{
	if( (self = [super init]) )
	{
		frame = frame_;
		[frame retain];
	}
	
	return self;
}

-(void)startWithTarget:(id)target
{
	[super startWithTarget:target];
	[(CCSprite *)target setDisplayFrame:frame];
	
}
			 
-(void)dealloc
{
	[frame release];
	frame = nil;
	
	[super dealloc];
}

@end


@implementation CCSetProps 


-(id)initWithPosition:(CGPoint)position_ 
				rotation:(float)rotation_ 
				  scaleX:(float)scaleX_ 
				  scaleY:(float)scaleY_ 
			 anchorPoint:(CGPoint)anchorPoint_
{
	if( (self = [super init]) )
	{
		
		position = position_;
		rotation = rotation_;
		scaleX = scaleX_;
		scaleY = scaleY_;
		anchorPoint = anchorPoint_;
	}
	
	return self;
}

+(id)actionWithPosition:(CGPoint)position_ 
				  rotation:(float)rotation_ 
					scaleX:(float)scaleX_ 
					scaleY:(float)scaleY_ 
			   anchorPoint:(CGPoint)anchorPoint_
{
	return [[[self alloc]    initWithPosition:position_ 
									 rotation:rotation_ 
									   scaleX:scaleX_ 
									   scaleY:scaleY_ 
								  anchorPoint:anchorPoint_
			 ] autorelease];
}

-(void)startWithTarget:(id)target
{
	[super startWithTarget:target];
	
	((CCSprite *)target).position = position;
	((CCSprite *)target).rotation = rotation;
	((CCSprite *)target).scaleX = scaleX;
	((CCSprite *)target).scaleY = scaleY;
	((CCSprite *)target).anchorPoint = anchorPoint;
	
}


-(void)dealloc
{
	[super dealloc];
}

@end