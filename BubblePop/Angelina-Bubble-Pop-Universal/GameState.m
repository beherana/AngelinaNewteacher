//
//  GameState.m
//  Angelina-Bubble-Pop-Universal
//
//  Created by Karl Söderström on 2011-08-16.
//  Copyright 2011 Commind AB. All rights reserved.
//

#import "GameState.h"

static GameState *sharedGameState;

@implementation GameState
@synthesize tutorialMode = _tutorialMode;
@synthesize timeOfLastCorrectBubbleSpawn = _timeOfLastCorrectBubbleSpawn;
@synthesize lastFlowerType = _lastFlowerType;
@synthesize numOfLastFlowerType = _numOfLastFlowerType;
@synthesize gameMode = _gameMode;
@synthesize livesLostWithoutScore = _livesLostWithoutScore;
@synthesize bubbleStats = _bubbleStats;

+ (GameState *)sharedInstance
{
    if (sharedGameState == nil) {
        sharedGameState = [[GameState alloc] init];
    }
    return sharedGameState;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.tutorialMode = NO;
    }
    
    return self;
}

//Keep track of number of bubbles poped in game
- (void) incrementBubbleStats:(NSString *) bubbleTypeKey {
    if (self.bubbleStats == nil) {
        self.bubbleStats = [[[NSMutableDictionary alloc] init] autorelease];
    }
    
    NSNumber *bubbleCount = [self.bubbleStats valueForKey:bubbleTypeKey];
    
    if (bubbleCount == nil) {
        bubbleCount = [NSNumber numberWithInt:1];
    }
    else {
        int value = [bubbleCount intValue];
        bubbleCount = [NSNumber numberWithInt:value+1];
    }
    
    [self.bubbleStats setValue:bubbleCount forKey:bubbleTypeKey];
}

- (void)dealloc {
    self.timeOfLastCorrectBubbleSpawn = nil;
    self.bubbleStats = nil;
    
    [super dealloc];
}


@end
