//
//  LivesIndicator.h
//  AngelinaGame
//
//  Created by Karl Söderström on 2011-06-27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface LivesIndicator : CCLayer {
@private
    CCLayer *_livesLayer;
    int _lives;
}

@property (nonatomic,assign) CCLayer *livesLayer;
@property (nonatomic,assign) int lives;

- (void)decrement;
- (void)increment;

- (void)setColor:(ccColor3B)color;

@end
