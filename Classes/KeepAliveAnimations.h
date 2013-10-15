//
//  Animations.h
//  Angelina-Bubble-Pop-Universal
//
//  Created by Karl Söderström on 2011-07-01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AVQueueManager.h"

@interface KeepAliveAnimations : UIView {
@private
    NSDictionary *_animations;
    UIImageView *_currentAnimation;
    NSString *_currentAudio;
}

- (void)startAnimation:(NSString *)name onView:(UIView *)animationView;
- (void)stopCurrentAnimation;

@end
