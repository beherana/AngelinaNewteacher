//
//  ThoughtBubble.m
//  AngelinaGame
//
//  Created by Karl Söderström on 2011-06-27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ThoughtBubble.h"
#import "GameParameters.h"
#import "AngelinaScene.h"
#import "GameState.h"
#import "AudioHelper.h"

@interface ThoughtBubble ()
@property (nonatomic, assign) CCSprite *flowerSprite;
@property (nonatomic, assign) CCSprite *bubble;
@property (nonatomic, assign) CCSprite *highlightedBubble;
@end

@implementation ThoughtBubble

@synthesize flowerSprite = _flowerSprite;
@synthesize bubble = _bubble;
@synthesize flowerType = _flowerType;
@synthesize nextType = _nextType;
@synthesize highlightedBubble = _highlightedBubble;

- (float)randomizeInterval
{
    float min = [[[GameParameters params] objectForKey:@"flowerChangeRateMin"] floatValue];
    float max = [[[GameParameters params] objectForKey:@"flowerChangeRateMax"] floatValue];
    return min + (arc4random() % ((int)max - (int)min));
}

- (id)init
{
    if( (self=[super init])) {
        CGPoint p;
        
        self.bubble = [CCSprite spriteWithFile:@"thought_bubble4.png"];
        self.bubble.anchorPoint = ccp(0.5,0.5);
        p = CGPointFromString([[GameParameters layout] objectForKey:@"thoughtBubble"]);
        self.bubble.positionInPixels = scaleCGPointToScreen(p);
        self.bubble.scale = scaleValueToScreen(0.9);
        [self addChild:self.bubble];
        
        self.highlightedBubble = [CCSprite spriteWithFile:@"thought_bubble3.png"];
        self.highlightedBubble.anchorPoint = ccp(0.5,0.5);
        p = CGPointFromString([[GameParameters layout] objectForKey:@"thoughtBubble"]);
        self.highlightedBubble.positionInPixels = scaleCGPointToScreen(p);
        self.highlightedBubble.scale = scaleValueToScreen(0.9);
        self.highlightedBubble.opacity = 0;
        [self addChild:self.highlightedBubble];
        
        self.flowerSprite = [CCSprite node];
        self.flowerSprite.scale = scaleValueToScreen(0.9);
        self.flowerSprite.anchorPoint = ccp(0.5,0.5);
        p = CGPointFromString([[GameParameters layout] objectForKey:@"thoughtBubbleFlower"]);
        self.flowerSprite.positionInPixels = scaleCGPointToScreen(p);

        
        [self addChild:self.flowerSprite z:10];
    }
    return self;
}

- (void)onEnter
{
    [super onEnter];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGameStarted:) name:AngelinaGame_GameDidStart object:nil];
}

- (void)onExit
{
    [super onExit];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onGameStarted:(NSNotification *)notification
{
    [self runAction:[CCFadeIn actionWithDuration:0.4]];
    [self randomizeNextFlowerType];
}

- (void)randomizeNextFlowerType
{
    [self unschedule:@selector(randomizeNextFlowerType)];
    
    if ([GameState sharedInstance].tutorialMode) {
        return;
    }
    
    NSArray *flowers = [[GameParameters params] objectForKey:@"flowers"];
    int newType = self.flowerType;
    while(newType == self.flowerType) {
        newType = arc4random() % [flowers count];
    }
    NSLog(@"Next flower type will be %d", newType);
    
    self.nextType = newType;
    
    id blink = [CCBlink actionWithDuration:1 blinks:2];
    [self.flowerSprite runAction: [CCRepeatForever actionWithAction: blink]];
    
    CCFadeIn *fadeIn = [CCFadeIn actionWithDuration:0.4];
    CCFadeOut *fadeOut = [CCFadeOut actionWithDuration:0.4];
    CCSequence *seq = [CCSequence actionOne:fadeIn two:fadeOut];
    [self.highlightedBubble runAction:[CCRepeatForever actionWithAction:seq]];
    
    {
        CCScaleBy *scaleUp = [CCScaleTo actionWithDuration:0.4 scale:scaleValueToScreen(1.1)];
        CCScaleBy *scaleDown = [CCScaleTo actionWithDuration:0.4 scale:scaleValueToScreen(0.8)];
        CCSequence *seq2 = [CCSequence actionOne:scaleUp two:scaleDown];
        [self.bubble runAction:[CCRepeatForever actionWithAction:seq2]];
        
    }
    {
        CCScaleBy *scaleUp = [CCScaleTo actionWithDuration:0.4 scale:scaleValueToScreen(1.1)];
        CCScaleBy *scaleDown = [CCScaleTo actionWithDuration:0.4 scale:scaleValueToScreen(0.8)];
        CCSequence *seq2 = [CCSequence actionOne:scaleUp two:scaleDown];
        [self.highlightedBubble runAction:[CCRepeatForever actionWithAction:seq2]];
        
    }
    
    [AudioHelper playAudio:AngelinaGameAudio_ThoughtBubbleChange];
    
    [self schedule:@selector(updateFlowerType) interval:2];
}

- (void)updateFlowerType
{
    [self unschedule:@selector(updateFlowerType)];
    if (![GameState sharedInstance].tutorialMode && [[AngelinaScene getCurrent].bubbleLayer hasBubbleOfFlowerType:self.nextType]) {
        NSLog(@"Flower of type %d shown on screen. Waiting to update...", self.nextType);
        [self schedule:@selector(updateFlowerType) interval:1];
        
    } else {
        [self.flowerSprite stopAllActions];
        [self.highlightedBubble stopAllActions];
        [self.bubble stopAllActions];
        [self.highlightedBubble runAction:[CCFadeOut actionWithDuration:0.4]];
        [self.highlightedBubble runAction:[CCScaleTo actionWithDuration:0.4 scale:scaleValueToScreen(0.9)]];
        [self.bubble runAction:[CCScaleTo actionWithDuration:0.4 scale:scaleValueToScreen(0.9)]];
        
        self.flowerSprite.visible = YES;
        NSLog(@"Updating to flower type %d", self.nextType);
        self.flowerType = self.nextType;
        self.nextType = -1;
        NSArray *flowers = [[GameParameters params] objectForKey:@"flowers"];
        CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:[flowers objectAtIndex:self.flowerType]];
        [self.flowerSprite setTexture:texture];
        CGRect rect = CGRectZero;
        rect.size = texture.contentSize;
        [self.flowerSprite setTextureRect:rect];
        
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"item_scaling" ofType:@"plist"]];
        CGPoint p = CGPointFromString([[GameParameters layout] objectForKey:@"thoughtBubbleFlower"]);
        self.flowerSprite.positionInPixels = scaleCGPointToScreen(p);
        NSDictionary *offsetDict = [dict objectForKey:@"thoughtbubble_offset"];
        CGPoint offset = CGPointFromString([offsetDict objectForKey:[flowers objectAtIndex:self.flowerType]]);
        self.flowerSprite.positionInPixels = ccpAdd(self.flowerSprite.positionInPixels, scaleCGPointToScreen(offset));
        
        NSDictionary *scalingDict = [dict objectForKey:@"thoughtbubble_scaling"];
        CGFloat scale = [[scalingDict objectForKey:[flowers objectAtIndex:self.flowerType]] floatValue];
        
        self.flowerSprite.scale = scaleValueToScreen(scale);
        if (![GameState sharedInstance].tutorialMode) {
            [self schedule:@selector(randomizeNextFlowerType) interval:[self randomizeInterval]];
        }
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:self.flowerType] forKey:@"flowerType"];
        [[NSNotificationCenter defaultCenter] postNotificationName:AngelinaGame_ThoughtBubbleChanged object:self userInfo:userInfo];
        if ([GameState sharedInstance].tutorialMode) {
            [AudioHelper playAudio:AngelinaGameAudio_ChangeFlowerLow];
        } else {
            [AudioHelper playAudio:AngelinaGameAudio_ChangeFlower];
        }
    }
    
}

// Set the opacity of all of our children that support it
-(void) setOpacity: (GLubyte) opacity
{
    for( CCNode *node in [self children] )
    {
        if( [node conformsToProtocol:@protocol( CCRGBAProtocol)] )
        {
            [(id<CCRGBAProtocol>) node setOpacity: opacity];
        }
    }
}

- (void)setColor:(ccColor3B)color
{
    for (CCNode *node in self.children) {
        if ([node conformsToProtocol:@protocol(CCRGBAProtocol)]) {
            [(id<CCRGBAProtocol>) node setColor:color];
        }
    }
}

@end
