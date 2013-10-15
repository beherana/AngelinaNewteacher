//
//  LivesIndicator.m
//  AngelinaGame
//
//  Created by Karl Söderström on 2011-06-27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LivesIndicator.h"
#import "GameParameters.h"
#import "AngelinaScene.h"
#import "AudioHelper.h"
#import "GameState.h"

@implementation LivesIndicator
@synthesize livesLayer = _livesLayer;
@synthesize lives = _lives;

- (id)init
{
    if( (self=[super init])) {
        self.livesLayer = [CCLayer node];
        [self addChild:self.livesLayer];
        int numLives = [[[GameParameters params] objectForKey:@"numLives"] intValue];
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        for (int i = 0; i < numLives; i++) {
            CCSprite *star = [CCSprite spriteWithFile:@"star_full.png"];
            star.scale = scaleOfScreen;
            CGPoint pos = CGPointZero;
            pos.y = winSize.height - scaleValueToScreen(star.contentSize.height);
            pos.x = winSize.width - (scaleValueToScreen(star.contentSize.width) * 1.2 * (numLives - i));
            star.position = pos;
            [self.livesLayer addChild:star];
        }
        self.lives = numLives;
    }
    return self;
}

-(void)removeAllActiveAnimations
{
    NSMutableArray *nodesToRemove = [NSMutableArray array];
    for (CCNode *node in self.children) {
        if (node != self.livesLayer) {
            [nodesToRemove addObject:node];
        }
    }
    for (CCNode *node in nodesToRemove) {
        [node removeFromParentAndCleanup:YES];
    }
}

-(void) setLives:(int)lives
{
    int oldLives = _lives;
    _lives = lives;
    for (CCSprite *sprite in self.livesLayer.children) {
        [sprite setTexture:[[CCTextureCache sharedTextureCache] addImage:@"star_empty.png"]];
        sprite.visible = YES;
    }
    for (int i = 0; i < lives; i++) {
        CCSprite *sprite = [self.livesLayer.children objectAtIndex:i];
        [sprite setTexture:[[CCTextureCache sharedTextureCache] addImage:@"star_full.png"]];
    }
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:oldLives],
                              @"old",
                              [NSNumber numberWithInt:lives],
                              @"new",
                              nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:AngelinaGame_LivesChanged
                                                        object:self
                                                      userInfo:userInfo];
    if (self.lives == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AngelinaGame_LastLifeLost
                                                            object:self];
    }
    
}

- (void)decrement
{
    if (self.lives > 0) {
        self.lives = self.lives - 1;
        
        NSMutableArray *frames = [NSMutableArray arrayWithCapacity:23];
        for (int i = 0; i <= 22; i++) {
            NSString *file = [NSString stringWithFormat:@"Lose_Life_%02d.png", i];
            NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:file];
            CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:path];
            CCSpriteFrame *f = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(0, 0, texture.contentSize.width, texture.contentSize.height)];
            [frames addObject:f];
        }
        [self removeAllActiveAnimations];
        CCAnimation *animation = [CCAnimation animationWithFrames:frames delay:1.0/15.0];
        CCNode *star = [self.livesLayer.children objectAtIndex:self.lives];
        star.visible = NO;
        CCSprite *sprite = [CCSprite spriteWithSpriteFrame:[frames objectAtIndex:0]];
        sprite.scale = star.scale;
        [self addChild:sprite];
        sprite.anchorPoint = ccp(0.5, 0.5);
        sprite.position = star.position;
        
        CCSequence *seq = [CCSequence actionOne:[CCAnimate actionWithAnimation:animation]
                                            two:[CCCallBlockN actionWithBlock:^(CCNode *node) {
            [node removeFromParentAndCleanup:YES];
            star.visible = YES;
        }]];
        [sprite runAction:seq];
        //[AudioHelper playAudio:AngelinaGameAudio_StretchAndPop];

    }
}

- (void)increment
{
    int numLives = [[[GameParameters params] objectForKey:@"numLives"] intValue];
    if (self.lives < numLives) {
        self.lives = self.lives + 1;
        
        NSMutableArray *frames = [NSMutableArray arrayWithCapacity:26];
        for (int i = 0; i <= 25; i++) {
            NSString *file = [NSString stringWithFormat:@"Gain_Life_%02d.png", i];
            NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:file];
            CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:path];
            CCSpriteFrame *f = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(0, 0, texture.contentSize.width, texture.contentSize.height)];
            [frames addObject:f];
        }
        [self removeAllActiveAnimations];
        CCAnimation *animation = [CCAnimation animationWithFrames:frames delay:1.0/15.0];
        CCNode *star = [self.livesLayer.children objectAtIndex:self.lives - 1];
        star.visible = NO;
        CCSprite *sprite = [CCSprite spriteWithSpriteFrame:[frames objectAtIndex:0]];
        sprite.scale = star.scale;
        [self addChild:sprite];
        sprite.anchorPoint = ccp(0.5, 0.5);
        sprite.position = star.position;
        
        CCSequence *seq = [CCSequence actionOne:[CCAnimate actionWithAnimation:animation]
                                            two:[CCCallBlockN actionWithBlock:^(CCNode *node) {
            [node removeFromParentAndCleanup:YES];
            star.visible = YES;
        }]];
        [sprite runAction:seq];
        [AudioHelper playAudio:AngelinaGameAudio_AscendStar];
    }
}

- (void)setColor:(ccColor3B)color
{
    for (CCNode *node in self.livesLayer.children) {
        if ([node conformsToProtocol:@protocol(CCRGBAProtocol)]) {
            [(id<CCRGBAProtocol>) node setColor:color];
        }
    }
}

@end
