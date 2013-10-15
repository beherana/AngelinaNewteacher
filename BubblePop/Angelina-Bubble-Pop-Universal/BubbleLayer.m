//
//  BubbleLayer.m
//  AngelinaGame
//
//  Created by Karl Söderström on 2011-06-27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BubbleLayer.h"
#import "Bubble.h"
#import "GameParameters.h"
#import "AngelinaScene.h"
#import "GameState.h"
#import "AudioHelper.h"
#import "Animations.h"

@interface BubbleLayer ()
@property (nonatomic, retain) NSArray *layerProperties;
@property (nonatomic, assign) float currentBubbleSpeed;

- (void)scheduleBeeSpawning;
- (void)scheduleButterflySpawning;

@end

@implementation BubbleLayer
@synthesize layerProperties = _layerProperties;
@synthesize currentBubbleSpeed = _currentBubbleSpeed;
- (id)init
{
    if( (self=[super init])) {
        self.layerProperties = [[GameParameters params] objectForKey:@"layers"];
        
        for (int i = 0; i < [self.layerProperties count]; i++) {
            CCLayer *layer = [CCLayer node];
            [self addChild:layer];
        }
        self.currentBubbleSpeed = [[[GameParameters params] objectForKey:@"bubbleInitialSpeed"] floatValue];
        
        if (![GameState sharedInstance].tutorialMode) {
            [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        }
    }
    return self;
}

- (void)dealloc
{
    self.layerProperties = nil;
    [super dealloc];
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
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
}

- (void)onGameStarted:(NSNotification *)notification
{
    float time = [[[GameParameters params] objectForKey:@"flowerSpawnRate"] floatValue];
    [self schedule:@selector(addFlowerBubble) interval:time];
    [self schedule:@selector(update:) interval:0.1];
    
    [self scheduleBeeSpawning];
    [self scheduleButterflySpawning];
}


-(void) update:(ccTime)dt
{
    AngelinaScene *scene = [AngelinaScene getCurrent];
    ThoughtBubble *thoughtBubble = scene.thoughtBubble;

    NSMutableArray *bubblesToPop = [NSMutableArray array];
    
    BOOL playFeedback = NO;
    
    for (CCLayer *layer in self.children) {
        for (Bubble *bubble in layer.children) {
            if ([bubble isKindOfClass:[Bubble class]] && [bubble numberOfRunningActions] == 0) {
                [bubblesToPop addObject:bubble];
                switch (bubble.type) {
                    case BubbleType_Flower:
                        if (thoughtBubble.flowerType == bubble.flowerType) {
                            [scene.scoreHandler applyScore];
                            switch ([GameState sharedInstance].gameMode) {
                                case AngelinaGameMode_Classic:
                                    playFeedback = YES;
                                    [GameState sharedInstance].livesLostWithoutScore += 1;
                                    [scene.livesIndicator decrement];
                                    break;
                                case AngelinaGameMode_Clock:
                                    break;
                                default:
                                    NSAssert(FALSE, @"Invalid game mode");
                                    break;
                            }
                            
                            CCSprite *cross = [CCSprite spriteWithFile:@"x.png"];
                            cross.opacity = 0;
                            cross.scale = scaleOfScreen;
                            cross.position = bubble.position;
                            [self.parent addChild:cross z:150];
                            
                            CCFadeIn *fadeIn = [CCFadeIn actionWithDuration:0.2];
                            CCDelayTime *delay = [CCDelayTime actionWithDuration:0.5];
                            CCFadeOut *fadeOut = [CCFadeOut actionWithDuration:0.2];
                            CCCallFuncN *remove = [CCCallFuncN actionWithTarget:self selector:@selector(removeNode:)];
                            CCSequence *seq = [CCSequence actions:fadeIn, delay, fadeOut, remove, nil];
                            [cross runAction:seq];
                            
                            [AudioHelper playAudio:AngelinaGameAudio_FlowerBushPop];
                        }
                        break;
                    case BubbleType_Bee:
                        [GameState sharedInstance].livesLostWithoutScore += 1;
                        playFeedback = YES;
                        switch ([GameState sharedInstance].gameMode) {
                            case AngelinaGameMode_Classic:
                                [scene.livesIndicator decrement];
                                break;
                            case AngelinaGameMode_Clock:
                                //[scene.timeHandler decreaseTime];
                                break;
                            default:
                                NSAssert(FALSE, @"Invalid game mode");
                                break;
                        }
                        break;
                    case BubbleType_Butterfly:
                        [GameState sharedInstance].livesLostWithoutScore += 1;
                        playFeedback = YES;
                        [scene.scoreHandler applyBonusScore];
                        break;
                    default:
                        break;
                }
            }
        }
    }

    for (Bubble *bubble in bubblesToPop) {
        [bubble pop];
    }
    
    if (scene.livesIndicator != nil && scene.livesIndicator.lives == 0) {
        // Don't play any feedback if it's the last life lost
        playFeedback = NO;
    }
    
    if (playFeedback) {
        NSArray *animations = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"negative_feedback" ofType:@"plist"]];
        NSUInteger index = arc4random() % [animations count];
        NSString *animation = [animations objectAtIndex:index];
        [[Animations sharedInstance] startAnimation:animation onNode:scene.angelina];
    }
                             
}

- (void)removeNode:(CCNode *)node
{
    [node removeFromParentAndCleanup:YES];
}

- (CGPoint) randomSpawnPoint
{
    int min = scaleValueToScreen([[[GameParameters params] objectForKey:@"bubbleSpawnXMin"] intValue]);
    int max = scaleValueToScreen([[[GameParameters params] objectForKey:@"bubbleSpawnXMax"] intValue]);
    int x = (arc4random() % (max - min)) + min;
    int y = [[CCDirector sharedDirector] winSizeInPixels].height + 50;
    return CGPointMake(x, y);
}

- (Bubble *)addBubbleWithType:(BubbleType)type
{
    return [self addBubbleWithType:type flowerType:-1];
}

- (Bubble *)addBubbleWithType:(BubbleType)type flowerType:(int)flowerType
{
    int layerIndex = arc4random() % [self.layerProperties count];
    if ([GameState sharedInstance].tutorialMode) {
        layerIndex = 0;
    }
    NSDictionary *layerProp = [self.layerProperties objectAtIndex:layerIndex];
    Bubble *bubble = [Bubble bubbleWithType:type flowerType:flowerType];
    bubble.sprite.scale = scaleValueToScreen([[layerProp objectForKey:@"scale"] floatValue]);
    bubble.bonusSprite.scale = bubble.sprite.scale;
    bubble.positionInPixels = [self randomSpawnPoint];
    [[self.children objectAtIndex:layerIndex] addChild:bubble];
    float speed = self.currentBubbleSpeed * [[layerProp objectForKey:@"speed"] floatValue];
    
    if (type == BubbleType_Bee) {
        speed *= [[[GameParameters params] objectForKey:@"beeSpeedRatio"] floatValue];
    } else if (type == BubbleType_Butterfly) {
        speed *= [[[GameParameters params] objectForKey:@"butterflySpeedRatio"] floatValue];
    }
    
    if (![GameState sharedInstance].tutorialMode) {
        NSUInteger y = [[[GameParameters layout] objectForKey:@"flowerbedPopY"] intValue];
        [bubble runAction:[CCMoveTo actionWithDuration:speed position:ccp(bubble.position.x, scaleValueToScreen(y) / [CCDirector sharedDirector].contentScaleFactor)]];
    }
    float max = [[[GameParameters params] objectForKey:@"bubbleMaxSpeed"] floatValue];
    float decr = [[[GameParameters params] objectForKey:@"bubbleSpeedIncrease"] floatValue];
    self.currentBubbleSpeed = MAX(max, self.currentBubbleSpeed - decr);
    return bubble;
}

- (void)addFlowerBubble
{
    [self addBubbleWithType:BubbleType_Flower];
}

- (void)scheduleBeeSpawning
{
    int min = [[[GameParameters params] objectForKey:@"beeSpawnTimeMin"] intValue];
    int max = [[[GameParameters params] objectForKey:@"beeSpawnTimeMax"] intValue];
    int time = min + (arc4random() % (max - min));
    [self schedule:@selector(addBeeBubble) interval:time];
}

- (void)addBeeBubble
{
    [self unschedule:@selector(addBeeBubble)];
    [self addBubbleWithType:BubbleType_Bee];
    [self scheduleBeeSpawning];
}

- (void)scheduleButterflySpawning
{
    int min = [[[GameParameters params] objectForKey:@"butterflySpawnTimeMin"] intValue];
    int max = [[[GameParameters params] objectForKey:@"butterflySpawnTimeMax"] intValue];
    int time = min + (arc4random() % (max - min));
    [self schedule:@selector(addButterflyBubble) interval:time];
}

- (void)addButterflyBubble
{
    [self unschedule:@selector(addButterflyBubble)];
    [self addBubbleWithType:BubbleType_Butterfly];
    [self scheduleButterflySpawning];
}


- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ([[CCDirector sharedDirector] isPaused]) {
        return NO;
    }
    
    BOOL res = NO;
    NSMutableArray *tappedBubbles = [NSMutableArray array];
    int numTappedPositiveBubbles = 0;
    int correctFlower = [AngelinaScene getCurrent].thoughtBubble.flowerType;

    for (CCLayer *layer in self.children) {
        for (Bubble *bubble in layer.children) {
            if ([bubble isKindOfClass:[Bubble class]]) {
                if ([bubble containsTouchLocation:touch]) {
                    [tappedBubbles addObject:bubble];
                    if (bubble.type != BubbleType_Flower || bubble.flowerType == correctFlower) {
                        numTappedPositiveBubbles++;
                    }
                }
            }
        }
    }
    
    BOOL tapOnlyPositiveBubbles = numTappedPositiveBubbles > 0;
    for (Bubble *bubble in tappedBubbles) {
        if (!tapOnlyPositiveBubbles || bubble.type != BubbleType_Flower || bubble.flowerType == correctFlower) {
            res = [bubble ccTouchBegan:touch withEvent:event];
        }
    }
    
    if (res) {
        return res;
    }   

    
    if ([[[GameParameters params] objectForKey:@"tappingOutsideBubbleDecreasesLife"] boolValue]) {
        // Missed any of the bubbles -> decrease lives
        AngelinaScene *scene = [AngelinaScene getCurrent];
        [scene.livesIndicator decrement];
        [scene.scoreHandler applyScore];
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)hasBubbleOfFlowerType:(int)type
{
    for (CCLayer *layer in self.children) {
        for (Bubble *bubble in layer.children) {
            if ([bubble isKindOfClass:[Bubble class]] &&
                 bubble.type == BubbleType_Flower &&
                 bubble.flowerType == type) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)popAllBubbles
{
    NSMutableArray *bubbles = [NSMutableArray array];
    for (CCLayer *layer in self.children) {
        for (Bubble *bubble in layer.children) {
            if ([bubble isKindOfClass:[Bubble class]]) {
                [bubbles addObject:bubble];
            }
        }
    }
    for (Bubble *bubble in bubbles) {
        [bubble pop];
    }
}

@end
