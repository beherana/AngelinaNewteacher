//
//  SceneComponent.h
//  Thomas
//
//  Created by Johannes Amilon on 11/5/10.
//  Copyright 2010 Vitamin Se Media AB. All rights reserved.
//

#import "cocos2d.h"
#import "cdaMoviePlayerView.h"


@interface SceneComponent : NSObject <cdaMoviePlayerViewDelegate> {
	NSString *name;
	NSString *filename;
	CCSprite *sprite;
	NSMutableArray *startTranslateAnimations;
	NSMutableArray *clickTranslateAnimations;
	NSMutableArray *startFrameAnimations;
	NSMutableArray *clickFrameAnimations;
    NSDictionary *startMovieAnimation;
	CCNode *node;
	int z;
	int isAnimating;
	BOOL interactiveDuringIntro;
	NSArray *animationTrigger;
	int triggerState;
	BOOL isSmoke;
	BOOL hasSound;
	CGRect clickBox;
	BOOL clickable;
    BOOL isMovie;
    CGPoint adjustNodeOffset;
}

@property(readonly) NSString *name;
@property(readonly) NSString *filename;
@property(readonly) int z;
@property(readonly) CCSprite *sprite;

+(id) componentWithDictionary:(NSDictionary *)dict:(int)tag;

-(id) initWithDictionary:(NSDictionary *)dict:(int)tag;
+ (void)precacheComponent:(NSDictionary *)dict;
-(void) runStartAnimations;
-(CCNode *) getCocosNode;
-(void) stopAnimations;
-(void) stopMovies;
-(BOOL) handleTouch:(CGPoint)point;
-(void)triggerAnimations;
-(BOOL) isTouched:(CGPoint)point;
-(void) animationDone;
-(void) killAnimations;

@end
