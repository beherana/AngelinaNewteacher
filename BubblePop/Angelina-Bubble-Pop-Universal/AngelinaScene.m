//
//  AngelinaScene.m
//  AngelinaGame
//
//  Created by Karl Söderström on 2011-06-27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AngelinaScene.h"
#import "Animations.h"
#import "ScoreIncrementAction.h"
#import "GameState.h"
#import "GameParameters.h"

@implementation AngelinaScene

@synthesize bubbleLayer = _bubbleLayer;
@synthesize thoughtBubble = _thoughtBubble;
@synthesize livesIndicator = _livesIndicator;
@synthesize scoreLabel = _scoreLabel;
@synthesize highScoreLabel = _highScoreLabel;
@synthesize scoreHandler = _scoreHandler;
@synthesize angelina = _angelina;
@synthesize timeHandler = _timeHandler;
@synthesize best = _best;

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
    AngelinaScene *layer = [AngelinaScene node];
    layer.tag = ANGELINA_SCENE_TAG;
	[scene addChild: layer];
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CGPoint p;
        
        // Background image
        NSString *backgroundFile = @"background.png";
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            backgroundFile = @"background_iphone.png";
        }
        CCSprite *background = [CCSprite spriteWithFile:backgroundFile];
        background.scale = scaleOfScreen;
        background.position =  ccp(winSize.width/2, winSize.height/2);
        [self addChild:background z:0];
        
        /*
        // Flowerbed image
        CCSprite *flowerbed = [CCSprite spriteWithFile:@"flowerbed.png"];
        flowerbed.scale = scaleOfScreen;
        p = CGPointFromString([[GameParameters layout] objectForKey:@"flowerbed"]);
        flowerbed.positionInPixels = scaleCGPointToScreen(p);
        [self addChild:flowerbed z:10];
        */
        // Angelina image
        self.angelina = [CCSprite spriteWithFile:@"angelina.png"];
        self.angelina.scale = scaleOfScreen;
        p = CGPointFromString([[GameParameters layout] objectForKey:@"angelina"]);
        self.angelina.positionInPixels = scaleCGPointToScreen(p);
        [self addChild:self.angelina z:11];
        
        // Thought bubble
        self.thoughtBubble = [ThoughtBubble node];
        [self.thoughtBubble setOpacity:0];
        [self addChild:self.thoughtBubble z:15];
        
        self.bubbleLayer = [BubbleLayer node];
        [self addChild:self.bubbleLayer z:3];
        
        if (![GameState sharedInstance].tutorialMode) {
            switch ([GameState sharedInstance].gameMode) {
                case AngelinaGameMode_Classic:
                    self.livesIndicator = [LivesIndicator node];
                    [self addChild:self.livesIndicator z:20];                
                    break;
                case AngelinaGameMode_Clock:
                    self.timeHandler = [TimeHandler node];
                    [self addChild:self.timeHandler z:20];
                    break;
                default:
                    break;
            }
        }
        
        // Score
        CCLayer *score = [CCNode node];
        score.anchorPoint = ccp(0,1);
        score.position = ccp(0, winSize.height);
        score.contentSize = winSize;
        [self addChild:score];
        
        CGSize winSizeInPixels = [CCDirector sharedDirector].winSizeInPixels;
        
        self.scoreLabel = [CCLabelBMFont labelWithString:@"0" fntFile:@"score.fnt"];
        self.scoreLabel.anchorPoint = ccp(0,1);
        self.scoreLabel.positionInPixels = ccp(scaleValueToScreen(20), winSizeInPixels.height - scaleValueToScreen(20));
        [score addChild:self.scoreLabel z:20];
        self.scoreLabel.scale = scaleOfScreen;
        
        self.best = [CCSprite spriteWithSpriteFrameName:@"best.png"];
        self.best.anchorPoint = ccp(0,1);
        self.best.positionInPixels = ccp(scaleValueToScreen(15), winSizeInPixels.height - scaleValueToScreen(60));
        self.best.scale = scaleOfScreen;
        [score addChild:self.best];
        
        self.highScoreLabel = [CCLabelBMFont labelWithString:@"0" fntFile:@"score_small.fnt"];
        self.highScoreLabel.anchorPoint = ccp(0,1);
        self.highScoreLabel.positionInPixels = ccp(scaleValueToScreen(85), winSizeInPixels.height - scaleValueToScreen(66));
        [score addChild:self.highScoreLabel];
        self.highScoreLabel.scale = scaleOfScreen;
        
        self.scoreHandler = [ScoreHandler scoreHandler];
        [self.highScoreLabel runAction:[ScoreIncrementAction actionWithDuration:0 fromScore:self.scoreHandler.highScore toScore:self.scoreHandler.highScore withAudio:NO]];
        
        // animate scores and lives
        CGPoint pos = score.position;
        score.position = ccp(pos.x, pos.y + 50);
        [score runAction:[CCMoveTo actionWithDuration:0.3 position:pos]];
        
        pos = self.livesIndicator.position;
        self.livesIndicator.position = ccp(pos.x, pos.y + 50);
        [self.livesIndicator runAction:[CCMoveTo actionWithDuration:0.3 position:pos]];
        
        pos = self.timeHandler.position;
        self.timeHandler.position = ccp(pos.x, pos.y + 50);
        [self.timeHandler runAction:[CCMoveTo actionWithDuration:0.3 position:pos]];
        
        //TEMP
        //[self schedule:@selector(runTestAnimation) interval:5];
        //[self runTestAnimation];
        
	}
	return self;
}

- (void)onEnter {
    [super onEnter];

    [[CCDirector sharedDirector] resume];
    
    if (![GameState sharedInstance].tutorialMode) {
        [GameState sharedInstance].bubbleStats = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:AngelinaGame_GameWillStart object:self];
    }
}

- (void)onExit {
    [super onExit];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
}

- (void)setColor:(ccColor3B)color
{
    for (CCNode *node in self.children) {
        if ([node conformsToProtocol:@protocol(CCRGBAProtocol)]) {
            [(id<CCRGBAProtocol>) node setColor:color];
        }
    }
}

- (void)runTestAnimation
{
    [[Animations sharedInstance] startAnimation:@"Angelina_Fantastic" onNode:self.angelina];
}

+(AngelinaScene *) getCurrent
{
    CCScene *scene = [[CCDirector sharedDirector] runningScene];
    return (AngelinaScene *) [scene getChildByTag:ANGELINA_SCENE_TAG];
}

-(void) reset
{
    [[CCTouchDispatcher sharedDispatcher] removeAllDelegates];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.4 scene:[AngelinaScene scene]]];
    [self cleanup];
    [[NSNotificationCenter defaultCenter] postNotificationName:AngelinaGame_GameReset object:self];
}

-(void) pause
{
    [[CCDirector sharedDirector] pause];
    [[NSNotificationCenter defaultCenter] postNotificationName:AngelinaGame_GamePaused object:self];
}

-(void) resume
{
    [[CCDirector sharedDirector] resume];
    [[NSNotificationCenter defaultCenter] postNotificationName:AngelinaGame_GameResumed object:self];
}

- (void) dealloc
{
    self.scoreHandler = nil;
	
    [super dealloc];
}

@end
