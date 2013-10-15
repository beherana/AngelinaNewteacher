//
//  Bubble.h
//  AngelinaGame
//
//  Created by Karl Söderström on 2011-06-27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum {
    BubbleType_Unknown = 0,
    
    BubbleType_Flower,
    BubbleType_Bee,
    BubbleType_Butterfly,
    
    BubbleType_Last
} BubbleType;

@interface Bubble : CCLayer {
@private
    CCSprite *_sprite;
    CCSprite *_bonusSprite;
    BubbleType _type;
    int _flowerType;
    float _originalX;
}

@property (nonatomic, readonly) BubbleType type;
@property (nonatomic, readonly) int flowerType;
@property (nonatomic, readonly) CCSprite *sprite;
@property (nonatomic, readonly) CCSprite *bonusSprite;

+(Bubble *) bubbleWithType:(BubbleType)type flowerType:(int)flowerType;
-(id) initWithType:(BubbleType)type flowerType:(int)flowerType;

- (void)pop;
- (void)setColor:(ccColor3B)color;
- (BOOL)containsTouchLocation:(UITouch *)touch;

@end
