//
//  ScoreHandler.m
//  AngelinaGame
//
//  Created by Karl Söderström on 2011-06-28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScoreHandler.h"
#import "GameParameters.h"
#import "AngelinaScene.h"
#import "GameState.h"

#define BubblePopHighScoreClassicUserDefault @"BubblePopHighScoreClassic"
#define BubblePopHighScoreClockUserDefault @"BubblePopHighScoreClock"

@interface ScoreHandler ()
@property (nonatomic, assign) NSUInteger score;
@property (nonatomic, assign) NSUInteger currentIncrease;
@property (nonatomic, assign) NSUInteger currentDecrease;
@property (nonatomic, assign) NSUInteger currentBonusScore;
@property (nonatomic, assign) NSUInteger increaseValue;
@property (nonatomic, assign) NSUInteger bonusIncreaseValue;
@property (nonatomic, assign) NSUInteger highScore;
@end

@implementation ScoreHandler

@synthesize score = _score;
@synthesize currentIncrease = _currentIncrease;
@synthesize currentDecrease = _currentDecrease;
@synthesize currentBonusScore = _currentBonusScore;
@synthesize increaseValue = _increaseValue;
@synthesize bonusIncreaseValue = _bonusIncreaseValue;
@synthesize currentLevel;
@synthesize highScore = _highScore;

+ (ScoreHandler *)scoreHandler
{
    return [[[ScoreHandler alloc] init] autorelease];
}

- (id)init
{
    if ((self = [super init])) {
        NSDictionary *params = [[GameParameters params] objectForKey:@"score"];
        self.increaseValue = [[params objectForKey:@"scoreIncrease"] intValue];
        self.bonusIncreaseValue = [[params objectForKey:@"bonusScoreIncrease"] intValue];
        
        // Load high score        
        switch ([GameState sharedInstance].gameMode) {
            case AngelinaGameMode_Classic:
                self.highScore = [[NSUserDefaults standardUserDefaults] integerForKey:BubblePopHighScoreClassicUserDefault];              
                break;
            case AngelinaGameMode_Clock:
                self.highScore = [[NSUserDefaults standardUserDefaults] integerForKey:BubblePopHighScoreClockUserDefault];  
                break;
            default:
                break;
        }        
    }
    return self;
}

- (void)sendNotification:(NSUInteger)score oldScore:(NSUInteger)oldScore
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:score],
                              @"score",
                              [NSNumber numberWithInt:oldScore],
                              @"oldScore",
                              nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:AngelinaGame_ScoreChanged
                                                        object:self
                                                      userInfo:userInfo];
}

- (void)increaseScore
{
    NSUInteger oldScore = self.score;
    self.currentIncrease = self.currentIncrease + self.increaseValue;
    self.score += self.currentIncrease;
    [self sendNotification:self.score oldScore:oldScore];
    self.currentDecrease = 0;
}

- (void)increaseBonusScore
{
    NSUInteger oldScore = self.score;
    self.currentBonusScore = self.currentBonusScore + self.bonusIncreaseValue;
    self.score += self.currentBonusScore;
    [self sendNotification:self.score oldScore:oldScore];
}

- (void)decreaseScore
{
    NSUInteger oldScore = self.score;
    self.currentDecrease = self.currentDecrease + self.increaseValue;
    if (self.score < self.currentDecrease) {
        self.score = 0;
    } else {
        self.score -= self.currentDecrease;        
    }
    [self sendNotification:self.score oldScore:oldScore];
}

- (void)applyBonusScore
{
    self.currentBonusScore = 0;
}

- (void)applyScore
{
    self.currentIncrease = 0;
    self.currentBonusScore = 0;
    if (self.score > self.highScore) {
        self.highScore = self.score;
        // Save high score
        switch ([GameState sharedInstance].gameMode) {
            case AngelinaGameMode_Classic:
                [[NSUserDefaults standardUserDefaults] setInteger:self.highScore forKey:BubblePopHighScoreClassicUserDefault];
                break;
            case AngelinaGameMode_Clock:
                [[NSUserDefaults standardUserDefaults] setInteger:self.highScore forKey:BubblePopHighScoreClockUserDefault];
                break;
            default:
                NSAssert(FALSE, @"Invalid game mode");
                break;
        } 
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSUInteger)getCurrentLevel
{
    return self.currentIncrease / self.increaseValue;
}

@end
