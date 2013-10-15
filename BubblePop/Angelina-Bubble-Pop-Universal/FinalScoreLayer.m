//
//  FinalScoreLayer.m
//  Angelina-Bubble-Pop-Universal
//
//  Created by Karl Söderström on 2011-08-17.
//  Copyright 2011 Commind AB. All rights reserved.
//

#import "FinalScoreLayer.h"
#import "ScoreIncrementAction.h"
#import "AngelinaScene.h"
#import "AudioHelper.h"
#import "Animations.h"

@implementation FinalScoreLayer
@synthesize label = _label;
- (id)init
{
    self = [super init];
    if (self) {
        self.label = [CCLabelBMFont labelWithString:@"" fntFile:@"score_big.fnt"];
        CGSize winSize = [CCDirector sharedDirector].winSize;
        self.label.anchorPoint = ccp(0.5,0.5);
        self.label.position = ccp(winSize.width/2, winSize.height/1.5);
        self.label.scale = scaleOfScreen;
        [self addChild:self.label z:90];
        
        CCSprite *text = [CCSprite spriteWithSpriteFrameName:@"your_score.png"];
        text.anchorPoint = ccp(0.5, 0.5);
        text.position = ccp(winSize.width/2, winSize.height/1.45);
        text.scale = scaleOfScreen;
        [self addChild:text];
        
    }
    
    return self;
}

- (void)onEnter
{
    [super onEnter];
    
    [[Animations sharedInstance] stopCurrentAnimation];
    
    NSUInteger score = [AngelinaScene getCurrent].scoreHandler.score;
    BOOL playAudio = NO;
    float duration;
    if (score < 100) {
        duration = 0.5;
        playAudio = YES;
    } else if (score < 1000) {
        duration = 1.5;
        [AudioHelper playAudio:AngelinaGameAudio_TickTack_1_5s];
    } else {
        duration = 2.0;
        [AudioHelper playAudio:AngelinaGameAudio_TickTack_2s];
    }
    
    ScoreIncrementAction *action = [ScoreIncrementAction actionWithDuration:duration fromScore:0 toScore:score withAudio:playAudio];
    CCCallFunc *func = [CCCallFunc actionWithTarget:self selector:@selector(countingFinished)];
    CCDelayTime *delay = [CCDelayTime actionWithDuration:1];
    CCEaseSineOut *sine = [CCEaseSineOut actionWithAction:action];
    CCSequence *seq = [CCSequence actions:sine, delay, func, nil];
    [self.label runAction:seq];
}

- (void)countingFinished
{
    [[NSNotificationCenter defaultCenter] postNotificationName:AngelinaGame_GameOver object:self];
}

@end
