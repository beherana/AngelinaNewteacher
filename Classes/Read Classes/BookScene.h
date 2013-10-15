//
//  BookScene.h
//  Thomas
//
//  Created by Johannes Amilon on 11/4/10.
//  Copyright 2010 Vitamin Se Media AB. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"
#import "AccelerometerDelegateLayer.h"
#import "FluidField.h"
#import "ReadOverlayView.h"
#import "cdaInteractiveTextView.h"
#import "ReadTextZoomViewController.h"

#define iTextViewTag 82575799

@interface BookScene : CCScene <CCTargetedTouchDelegate, cdaInteractiveTextViewDelegate>{
	AccelerometerDelegateLayer *layer;
	int page;
	NSMutableArray *components;
	NSMutableDictionary *componentsByName;
	BOOL animating;
	BOOL hasPhysics;
	b2World *world;
	BOOL useAccelerometer;
	int touchedElement;
	b2MouseJoint *mouseJoint;
	b2Vec2 touchPoint;
	b2Body *groundBody;
	CGRect physicsBox;
	BOOL respawnObjects;
	BOOL hasFog;
	FluidField *fog;
	CCTexture2D *fogTexture;
	float fogRevealStart;
	float fogRevealDuration;
	float fogRevealTimer;
	BOOL fogReveal;
	BOOL landscapeRight;
	NSString *bgSound;
	float bgVolume;
	BOOL bgRepeat;
	CCSprite *repeatButton;
	float fogX;
	BOOL isScreenshot;
	CCLabelTTF *label;
	CGPoint layerOffset;
@private
	NSString *text;
	ReadOverlayViewStyle style;
    cdaInteractiveTextView *iTextView;
    ReadTextZoomViewController *readTextZoomViewController;
    
    NSArray *hotspotIndicators;
}

@property (readonly) int page;
@property (readonly) NSMutableArray *components;
@property (retain, nonatomic) NSArray *hotspotIndicators;
@property (readonly) BOOL isScreenshot;
@property (retain, nonatomic) ReadTextZoomViewController *readTextZoomViewController;

-(void)setPage:(int)newPage;
- (void)precache:(int)scene;
-(void)stopAnimation;
-(void)startAnimation;
-(void)cocosDidStop;
-(void)triggerAnimationByName:(NSString *)name;
-(void)addRecursive:(NSDictionary *)data:(CCNode *)currentNode;
-(void)removeRecursive:(CCNode *)node;
-(void)setupPhysics;
-(void)setupFog:(NSDictionary *)fogDict;
-(void)update:(ccTime) dt;
-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration;
-(void)orientationChanged:(BOOL)isLandscapeRight;

-(void)setReplayVisible;
-(void)setReplayHidden;
-(BOOL) isDraggingObject;
-(void)turnIntoScreenshot;

-(CGPoint)getLayerOffset;

-(NSArray *)getHotspotIndicators;

-(BOOL) isAnimating;

-(void)showText;
//interactive text should be displayed over video
-(void)popTextOverVideo;

-(void)showStarsR;
-(void)showStarsL;

- (void)pauseAudio;
- (void)unpauseAudio;
- (void)restartAudio;
- (void)playAudio;
- (void)stopAudio;
- (BOOL)isPlayingAudio;

@end
