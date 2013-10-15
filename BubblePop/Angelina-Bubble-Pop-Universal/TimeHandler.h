//
//  TimeHandler.h
//  Angelina-Bubble-Pop-Universal
//
//  Created by Karl Söderström on 2011-08-24.
//  Copyright 2011 Commind AB. All rights reserved.
//

#import "cocos2d.h"

@interface TimeHandler : CCLayer {
    NSTimeInterval _timeLeft;
    CCLabelBMFont *_timeLabel;
    NSUInteger _audio;
}

@property (nonatomic, assign) NSTimeInterval timeLeft;
@property (nonatomic, assign) CCLabelBMFont *timeLabel;
- (void)startCountdown;
- (void)gamePaused;
- (void)gameResumed;
- (void)increaseTime;
- (void)decreaseTime;
- (void)increaseTimeWith:(NSUInteger)seconds;

- (void)setColor:(ccColor3B)color;
@end
