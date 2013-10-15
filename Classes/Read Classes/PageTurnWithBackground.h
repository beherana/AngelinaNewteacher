//
//  PageTurnWithBackground.h
//  Angelina-New-Teacher-Universal
//
//  Created by Karl Söderström on 2011-09-13.
//  Copyright 2011 Commind AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


@interface Grid3dWithBackground : CCGrid3D {
	float	animationProgress;
}
@end

@interface Grid3dWithBackgroundAction : CCGrid3DAction
-(void)setProgress:(float)progress;
@end



@interface PageTurn3dWithBackground : Grid3dWithBackgroundAction {
	CGSize			winSize;
	NSInteger		turnCorner;
}

+(id) actionWithSize:(ccGridSize)size duration:(ccTime)d fromCorner:(NSInteger)fromCorner;
-(id) initWithSize:(ccGridSize)gSize duration:(ccTime)d fromCorner:(NSInteger)fromCorner;

@end

@interface TransitionPageTurnWithBackground : CCTransitionScene {
	BOOL			back_;
}

+(id) transitionWithDuration:(ccTime)t scene:(CCScene*)s backwards:(BOOL) back;
+(id) transitionWithDuration:(ccTime)t scene:(CCScene*)s;

-(id) initWithDuration:(ccTime)t scene:(CCScene*)s backwards:(BOOL)back;

-(CCActionInterval*) actionWithSize:(ccGridSize) vector;

@end
