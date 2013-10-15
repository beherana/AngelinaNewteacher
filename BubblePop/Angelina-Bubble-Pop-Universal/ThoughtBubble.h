//
//  ThoughtBubble.h
//  AngelinaGame
//
//  Created by Karl Söderström on 2011-06-27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface ThoughtBubble : CCLayer {
@private
    CCSprite *_flowerSprite;
    CCSprite *_bubble;
    CCSprite *_highlightedBubble;
    int _flowerType;
    int _nextType;
}

@property (nonatomic, assign) int flowerType;
@property (nonatomic, assign) int nextType;

- (void)randomizeNextFlowerType;
- (void)updateFlowerType;

- (void)setColor:(ccColor3B)color;
-(void) setOpacity: (GLubyte) opacity;

@end
