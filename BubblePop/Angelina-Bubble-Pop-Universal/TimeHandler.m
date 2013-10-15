//
//  TimeHandler.m
//  Angelina-Bubble-Pop-Universal
//
//  Created by Karl Söderström on 2011-08-24.
//  Copyright 2011 Commind AB. All rights reserved.
//

#import "TimeHandler.h"
#import "GameParameters.h"
#import "AngelinaScene.h"
#import "AudioHelper.h"
#import "Animations.h"

@interface TimeHandler ()
- (NSString *)formatTimeString:(NSTimeInterval)time;
@end

@implementation TimeHandler
@synthesize timeLeft = _timeLeft;
@synthesize timeLabel = _timeLabel;

- (id)init
{
    self = [super init];
    if (self) {
        self.timeLeft = [[[GameParameters params] objectForKey:@"beatTheClockStartTime"] floatValue];
        
        CGSize winSize = [CCDirector sharedDirector].winSizeInPixels;
        
        CCSprite *timeRemaining = [CCSprite spriteWithSpriteFrameName:@"time_remaining.png"];
        timeRemaining.anchorPoint = ccp(1,1);
        timeRemaining.positionInPixels = ccp(winSize.width - scaleValueToScreen(10), winSize.height - scaleValueToScreen(10));
        timeRemaining.scale = scaleOfScreen;
        [self addChild:timeRemaining];
        
        self.timeLabel = [CCLabelBMFont labelWithString:[self formatTimeString:self.timeLeft] fntFile:@"score.fnt"];
        self.timeLabel.anchorPoint = ccp(1,1);
        self.timeLabel.scale = scaleOfScreen;
        self.timeLabel.positionInPixels = ccp(winSize.width - scaleValueToScreen(30), winSize.height - scaleValueToScreen(40));
        [self addChild:self.timeLabel];
        
    }
    
    return self;
}

- (void)onEnter
{
    [super onEnter];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startCountdown) name:AngelinaGame_GameDidStart object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gamePaused) name:AngelinaGame_GamePaused object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameResumed) name:AngelinaGame_GameResumed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameReset) name:AngelinaGame_GameReset object:nil];
}

- (void)onExit
{
    [super onExit];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startCountdown
{
    [self schedule:@selector(updateTime:)];
}

- (void)increaseTime
{
    NSTimeInterval increase = [[[GameParameters params] objectForKey:@"beatTheClockTimeIncrease"] floatValue];
    self.timeLeft = self.timeLeft + increase;
}

- (void)gamePaused
{
    if (_audio) {
        [AudioHelper pauseAudio:_audio];
    }
}

- (void)gameResumed
{
    if (_audio) {
        [AudioHelper resumeAudio:_audio];
    }
}

- (void)gameReset
{
    if (_audio) {
        [AudioHelper stopAudio:_audio];
        _audio = 0;
    }
}


- (void)decreaseTime
{
    NSTimeInterval decrease = [[[GameParameters params] objectForKey:@"beatTheClockTimeDecrease"] floatValue];
    self.timeLeft = self.timeLeft - decrease;    
}

- (void)increaseTimeWith:(NSUInteger)seconds
{
    self.timeLeft = self.timeLeft + seconds;
    [AudioHelper stopAudio:_audio];
    _audio = 0;
}

- (NSString *)formatTimeString:(NSTimeInterval)time
{
    NSUInteger t = round(time);
    
    NSUInteger min = t / 60;
    NSUInteger sec = t % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d", min, sec];
}

-(void) updateTime:(ccTime)dt { 
    self.timeLeft = self.timeLeft - dt;
    
    if (_audio == 0 && self.timeLeft < 10) {
        _audio = [AudioHelper playAudio:AngelinaGameAudio_TimeOut];
    }
    
    if (self.timeLeft + dt > 10 && self.timeLeft <= 10) {
        [[Animations sharedInstance] startAnimation:@"Angelina_Hurry10secLeft" onNode:[AngelinaScene getCurrent].angelina];
    }
    if (self.timeLeft + dt > 5 && self.timeLeft <= 5) {
        [[Animations sharedInstance] startAnimation:@"Angelina_Only5secLeft" onNode:[AngelinaScene getCurrent].angelina];
    }
    if (self.timeLeft + dt > 30 && self.timeLeft <= 30) {
        NSArray *animations = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"clock_feedback" ofType:@"plist"]];
        NSUInteger index = arc4random() % [animations count];
        NSString *animation = [animations objectAtIndex:index];
        [[Animations sharedInstance] startAnimation:animation onNode:[AngelinaScene getCurrent].angelina];
    }
    
    
    if (self.timeLeft < 0) {
        self.timeLeft = 0;
    }
    
    [self.timeLabel setString:[self formatTimeString:self.timeLeft]];
    
    if (self.timeLeft <= 0) {
        [self unscheduleAllSelectors];
        [[AngelinaScene getCurrent].scoreHandler applyScore];
        [[NSNotificationCenter defaultCenter] postNotificationName:AngelinaGame_LastLifeLost
                                                            object:self];
    }
}

- (void)setColor:(ccColor3B)color
{
    for (CCNode *node in self.children) {
        if ([node conformsToProtocol:@protocol(CCRGBAProtocol)]) {
            [(id<CCRGBAProtocol>) node setColor:color];
        }
    }
}


@end
