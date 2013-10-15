//
//  TitleScene.m
//  Angelina-Bubble-Pop-Universal
//
//  Created by Karl Söderström on 2011-08-02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TitleScene.h"
#import "AngelinaScene.h"
#import "TutorialViewController.h"
#import "AudioHelper.h"
#import "GameState.h"
#import "GameParameters.h"
#import "cdaAnalytics.h"

@interface EmptyBubble : CCSprite <CCTargetedTouchDelegate> {
    float _originalX;
}
+ (EmptyBubble *)sprite;
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)pop;
@end

@implementation EmptyBubble
+ (EmptyBubble *)sprite
{
    return [EmptyBubble spriteWithFile:@"bubble.png"];
}

-(id)init {
    if ((self = [super init])) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        _originalX = -1;
        self.position = ccp(arc4random() % (int)winSize.width, winSize.height + 50);
        float size = ((arc4random() % 100) / 80.0) + 0.2;
        self.scale = scaleValueToScreen(size);
        [self scheduleUpdate];
    }
    return self;
}

- (void)onEnter {
    [super onEnter];
    float baseSpeed = 4.0 + ((arc4random() % 20) / 10.0);
    [self runAction:[CCMoveTo actionWithDuration:(baseSpeed - self.scale) position:ccp(self.position.x, -100)]];
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
}

- (void)onExit {
    [super onExit];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
}

-(void) update:(ccTime)dt {
    if (_originalX < 0) {
        _originalX = self.position.x;
    }    
    float amplitude = 10 * self.scale;
	float frequency = 0.01;
    float x = _originalX + (amplitude * sin(frequency * (_originalX + self.position.y)));
    self.position = ccp(x, self.position.y);
    
    if ([self numberOfRunningActions] == 0) {
        [self removeFromParentAndCleanup:YES];
    }
}
- (BOOL)containsTouchLocation:(UITouch *)touch
{
	if (![self visible]) return NO;
	return CGRectContainsPoint([self boundingBox], [self.parent convertTouchToNodeSpace:touch]);
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if ( ![self containsTouchLocation:touch] ) return NO;
    
    [[cdaAnalytics sharedInstance] trackEvent:flurryEventPrefix(@"Landing Page: Pop background bubble")];
    
    [self pop];
    [AudioHelper playAudio:AngelinaGameAudio_DefaultPop];
	return YES;
}

- (void)pop {
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    
    NSString *file = [[NSBundle mainBundle] pathForResource:@"BubbleExplosion" ofType:@"plist"];
    CCParticleSystemQuad *particle = [CCParticleSystemQuad particleWithFile:file];
    particle.autoRemoveOnFinish = YES;
    particle.position = self.position;
    particle.scale = self.scale;
    [self.parent addChild:particle];
    
    [self removeFromParentAndCleanup:YES];
}



@end


@implementation TitleScene

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	TitleScene *layer = [[[TitleScene alloc] init] autorelease];
    layer.tag = ANGELINA_TITLE_TAG;
	[scene addChild: layer];
	return scene;
}


-(void)addBubble:(ccTime)dt
{
    [self addChild:[EmptyBubble sprite] z:(arc4random() % 3) + 3];
}

-(id) init
{
	if( (self=[super init])) {
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        _background = [CCLayer node];
        [self addChild:_background z:0];
        
        // Background image
        NSString *backgroundFile = @"background.png";
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            backgroundFile = @"background_iphone.png";
        }
        CCSprite *background = [CCSprite spriteWithFile:backgroundFile];
        background.scale = scaleOfScreen;
		background.position =  ccp(winSize.width/2, winSize.height/2);
        [_background addChild:background z:0];
        
        /*
        // Flowerbed image
        CCSprite *flowerbed = [CCSprite spriteWithFile:@"flowerbed.png"];
        flowerbed.scale = scaleOfScreen;
        CGPoint p = CGPointFromString([[GameParameters layout] objectForKey:@"flowerbed"]);
        flowerbed.positionInPixels = scaleCGPointToScreen(p);
        [_background addChild:flowerbed z:10];
         */
	}
	return self;
}

- (void)onEnterTransitionDidFinish
{
    //[self schedule:@selector(addBubble:) interval:0.3];
}

- (void)onExit
{
    [self unscheduleAllSelectors];
}

-(void)popAllBubbles
{
    NSMutableArray *bubbles = [NSMutableArray array];
    
    for (CCNode *node in [self children]) {
        if ([node isKindOfClass:[EmptyBubble class]]) {
            [bubbles addObject:node];
        }
    }
    
    for (EmptyBubble *bubble in bubbles) {
        [bubble pop];
    }
}

- (void)switchScene
{
    //[[CCDirector sharedDirector] replaceScene:[AngelinaScene scene]];
}


@end
