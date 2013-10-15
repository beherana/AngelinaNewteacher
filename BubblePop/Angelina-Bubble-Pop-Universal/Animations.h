//
//  Animations.h
//  Angelina-Bubble-Pop-Universal
//
//  Created by Karl Söderström on 2011-07-01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Animations : CCLayer {
@private
    NSDictionary *_animations;
    NSUInteger _currentAudio;
    CCSprite *_currentAnimation;
    BOOL _playOnlyHighPrio;
}

- (void)startAnimation:(NSString *)name onNode:(CCNode *)node;
- (void)stopCurrentAnimation;
- (void)preloadAnimation:(NSString *)name;
+ (Animations *)sharedInstance;

@end
