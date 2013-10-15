//
//  ScoreHandler.h
//  AngelinaGame
//
//  Created by Karl Söderström on 2011-06-28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ScoreHandler : NSObject {
@private
    NSUInteger _score;
    NSUInteger _currentIncrease;
    NSUInteger _currentBonusScore;
    NSUInteger _currentDecrease;
    NSUInteger _increaseValue;
    NSUInteger _bonusIncreaseValue;
    
    NSUInteger _highScore;
}

@property (nonatomic, readonly) NSUInteger score;
@property (nonatomic, readonly) NSUInteger currentLevel;
@property (nonatomic, readonly) NSUInteger currentIncrease;
@property (nonatomic, readonly) NSUInteger currentDecrease;
@property (nonatomic, readonly) NSUInteger currentBonusScore;
@property (nonatomic, readonly) NSUInteger highScore;

+ (ScoreHandler *)scoreHandler;

- (void)increaseScore;
- (void)increaseBonusScore;
- (void)decreaseScore;
- (void)applyBonusScore;
- (void)applyScore;

@end
