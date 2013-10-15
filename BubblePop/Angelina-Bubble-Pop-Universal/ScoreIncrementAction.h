//
//  ScoreIncrementAction.h
//  Angelina-Bubble-Pop-Universal
//
//  Created by Karl Söderström on 2011-08-17.
//  Copyright 2011 Commind AB. All rights reserved.
//

#import "cocos2d.h"

@interface ScoreIncrementAction : CCActionInterval {
@private
    NSUInteger _fromScore;
    NSUInteger _toScore;
    NSInteger _delta;
    BOOL _audio;
}

+(id) actionWithDuration:(ccTime)t fromScore:(NSUInteger) fromScore toScore:(NSUInteger)toScore withAudio:(BOOL)audio;
-(id) initWithDuration:(ccTime)t fromScore:(NSUInteger) fromScore toScore:(NSUInteger)toScore withAudio:(BOOL)audio;
@end
