//
//  BubbleLayer.h
//  AngelinaGame
//
//  Created by Karl Söderström on 2011-06-27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Bubble.h"

@interface BubbleLayer : CCLayer {
@private
    NSArray *_layerProperties;
    float _currentBubbleSpeed;
}

- (BOOL)hasBubbleOfFlowerType:(int)type;
- (Bubble *)addBubbleWithType:(BubbleType)type;
- (Bubble *)addBubbleWithType:(BubbleType)type flowerType:(int)flowerType;
- (void)popAllBubbles;
@end
