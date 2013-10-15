//
//  SetPropsAction.h
//  Thomas Animation Example
//
//  Created by Henrik Nord on 10/25/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "cocos2d.h"

@interface CCSetFrame : CCActionInstant
{
	CCSpriteFrame *frame;
}

+(id)actionWithSpriteFrame:(CCSpriteFrame *)frame_;
-(id)initWithSpriteFrame:(CCSpriteFrame *)frame_;

@end


@interface CCSetProps : CCActionInstant
{
	CGPoint position;
	float rotation;
	float scaleX;
	float scaleY;
	CGPoint anchorPoint;
}

+(id)actionWithPosition:(CGPoint)position_ 
				  rotation:(float)rotation_ 
					scaleX:(float)scaleX_ 
					scaleY:(float)scaleY_ 
			   anchorPoint:(CGPoint)anchorPoint_;

-(id)initWithPosition:(CGPoint)position_ 
				  rotation:(float)rotation_ 
					scaleX:(float)scaleX_ 
				    scaleY:(float)scaleY_ 
			   anchorPoint:(CGPoint)anchorPoint_;

@end