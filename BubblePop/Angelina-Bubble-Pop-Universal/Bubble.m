//
//  Bubble.m
//  AngelinaGame
//
//  Created by Karl Söderström on 2011-06-27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Bubble.h"
#import "GameParameters.h"
#import "AngelinaScene.h"
#import "ThoughtBubble.h"
#import "GameState.h"
#import "AudioHelper.h"
#import "Animations.h"

@interface CCNode (Opacity)
-(void) setOpacity: (GLubyte) opacity;
@end

@implementation CCNode (Opacity)

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

@end

@interface Bubble()

@property (nonatomic, assign) CCSprite *sprite;
@property (nonatomic, assign) CCSprite *bonusSprite;
@property (nonatomic, assign) BubbleType type;
@property (nonatomic, assign) int flowerType;
@property (nonatomic, assign) float originalX;
@end

@implementation Bubble

@synthesize sprite = _sprite;
@synthesize bonusSprite = _bonusSprite;
@synthesize type = _type;
@synthesize flowerType = _flowerType;
@synthesize originalX = _originalX;

+(Bubble *) bubbleWithType:(BubbleType)type flowerType:(int)flowerType
{
    return [[[Bubble alloc] initWithType:type flowerType:flowerType] autorelease];
}

-(id) initWithType:(BubbleType)type flowerType:(int)flowerType;
{
    if( (self=[super init])) {
        self.originalX = -1;
        self.type = type;
        self.flowerType = -1;
        self.sprite = [CCSprite spriteWithFile:@"bubble.png"];
        
        NSString *imageSpriteName = nil;
        switch (type) {
            case BubbleType_Flower:
            {
                GameState *state = [GameState sharedInstance];
                int maxOfSameFlowerInRow = [[[GameParameters params] objectForKey:@"maxOfSameFlowerInRow"] intValue];
                int maxTimeUntilFlowerIsForced = [[[GameParameters params] objectForKey:@"maxTimeUntilFlowerIsForced"] intValue];
                NSArray *flowers = [[GameParameters params] objectForKey:@"flowers"];
                if (flowerType < 0) {
                    int newType = [AngelinaScene getCurrent].thoughtBubble.nextType;
                    
                    NSTimeInterval intervalSinceLastCorrect = [[NSDate date] timeIntervalSinceDate:state.timeOfLastCorrectBubbleSpawn];
                    if (intervalSinceLastCorrect > maxTimeUntilFlowerIsForced) {
                        self.flowerType = [AngelinaScene getCurrent].thoughtBubble.flowerType;
                        NSLog(@"%f seconds since last correct bubble (%d). Forcing it", intervalSinceLastCorrect, self.flowerType);
                    } else {
                        do {
                            self.flowerType = arc4random() % [flowers count];
                        } while (self.flowerType == newType
                             || (self.flowerType == state.lastFlowerType
                                 && state.numOfLastFlowerType >= maxOfSameFlowerInRow));
                        NSLog(@"Randomized new bubble of type %d", self.flowerType);
                    }
                } else {
                    self.flowerType = flowerType;
                }
                imageSpriteName = [flowers objectAtIndex:self.flowerType];
                
                if (self.flowerType == state.lastFlowerType) {
                    state.numOfLastFlowerType = state.numOfLastFlowerType + 1;
                } else {
                    state.lastFlowerType = self.flowerType;
                    state.numOfLastFlowerType = 1;
                }
                if (self.flowerType == [AngelinaScene getCurrent].thoughtBubble.flowerType) {
                    state.timeOfLastCorrectBubbleSpawn = [NSDate date];
                }
                
                break;
            }
            case BubbleType_Bee:
            {
                imageSpriteName = @"star.png";
                self.bonusSprite = [CCSprite spriteWithFile:@"bonusbubble.png"];
                
                break;
            }
            case BubbleType_Butterfly:
            {
                imageSpriteName = @"pink_slippers.png";
                self.bonusSprite = [CCSprite spriteWithFile:@"bonusbubble.png"];
                break;
            }
            default:
                break;
        }
        
        CCSprite *imageSprite = [CCSprite spriteWithFile:imageSpriteName];
        imageSprite.position = ccp(self.sprite.contentSize.width/2, self.sprite.contentSize.height/2);
        
        // Set individual scaling of items
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"item_scaling" ofType:@"plist"]];
        NSDictionary *scaling = [dict objectForKey:@"scaling"];
        imageSprite.scale = [[scaling objectForKey:imageSpriteName] floatValue];
        NSDictionary *offsetDict = [dict objectForKey:@"offset"];
        CGPoint offset = CGPointFromString([offsetDict objectForKey:imageSpriteName]);
        imageSprite.positionInPixels = ccpAdd(imageSprite.positionInPixels, scaleCGPointToScreen(offset));
        
        [self.sprite addChild:imageSprite];
        
        [self addChild:self.sprite];
        
        if (self.bonusSprite != nil) {
            self.bonusSprite.scale = self.sprite.scale;
            self.bonusSprite.position = self.sprite.position;
            [self addChild:self.bonusSprite];
            if (![GameState sharedInstance].tutorialMode) {
                CCFadeTo *fadeOut = [CCFadeTo actionWithDuration:0.75 opacity:50];
                CCFadeTo *fadeIn = [CCFadeTo actionWithDuration:0.75 opacity:255];
                CCSequence *seq = [CCSequence actions:[CCEaseExponentialInOut actionWithAction:fadeOut], [CCEaseExponentialInOut actionWithAction:fadeIn], nil];
        
                [self.bonusSprite runAction:[CCRepeatForever actionWithAction:seq]];
            }
        }
        
        if (![GameState sharedInstance].tutorialMode) {
            [self scheduleUpdate];
        }
    }
    return self;
}

- (BOOL)containsTouchLocation:(UITouch *)touch
{
	if (![self.sprite visible]) return NO;
	return CGRectContainsPoint([self.sprite boundingBox], [self.sprite.parent convertTouchToNodeSpace:touch]);
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if ( ![self containsTouchLocation:touch] ) return NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AngelinaGame_BubblePopped object:self];
    
    AngelinaScene *scene = [AngelinaScene getCurrent];
    NSString *rewardType = nil;
    CCNode *scoreNode = nil;
    NSString *audio = nil;
    NSString *animation = nil;
    bool showCross = false;
    
    switch (self.type) {
        case BubbleType_Flower:
        {
            ThoughtBubble *thoughtBubble = scene.thoughtBubble;
            if (thoughtBubble.flowerType != self.flowerType) {
                [GameState sharedInstance].livesLostWithoutScore += 1;
                [[GameState sharedInstance] incrementBubbleStats:@"Incorrect Bubble"];
                [scene.scoreHandler applyScore];
                switch ([GameState sharedInstance].gameMode) {
                    case AngelinaGameMode_Classic:
                        [scene.livesIndicator decrement];
                        break;
                    case AngelinaGameMode_Clock:
                        [scene.scoreHandler decreaseScore];
                        break;
                    default:
                        NSAssert(FALSE, @"Invalid game mode");
                        break;
                }
                audio = AngelinaGameAudio_DefaultPop;
                showCross = true;
                // Play negative feedback
                if (scene.livesIndicator == nil || scene.livesIndicator.lives > 0) {
                    if ([GameState sharedInstance].livesLostWithoutScore > 1) {
                        NSArray *animations = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"negative_feedback" ofType:@"plist"]];
                        NSUInteger index = arc4random() % [animations count];
                        animation = [animations objectAtIndex:index];
                    } else {
                        animation = @"Angelina_RememberOnlyTouchTheBubblesIThinkAbout";
                    }
                }
            } else {
                [GameState sharedInstance].livesLostWithoutScore = 0;
                [scene.scoreHandler increaseScore];
                scoreNode = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"+%d", scene.scoreHandler.currentIncrease] fntFile:@"yellow_font.fnt"];
                int currentIncrease = [scene.scoreHandler currentIncrease];
                int scoreIncrease = [[[[GameParameters params] objectForKey:@"score"] objectForKey:@"scoreIncrease"] intValue];
                if (currentIncrease > scoreIncrease && (currentIncrease % (scoreIncrease * 5) == 0)) {
                    rewardType = @"BubbleReward3";
                    audio = AngelinaGameAudio_PopBubble3;

                    // play positive animation
                    NSArray *animations = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"positive_feedback" ofType:@"plist"]];
                    NSUInteger index = arc4random() % [animations count];
                    animation = [animations objectAtIndex:index];
                    
                } else if (currentIncrease > scoreIncrease && (currentIncrease % (scoreIncrease * 2) == 0)) {
                    rewardType = @"BubbleReward3";
                    audio = AngelinaGameAudio_PopBubble2;
                } else {
                    rewardType = @"BubbleReward2";
                    audio = AngelinaGameAudio_PopBubble1;
                }
            }
            break;
        }
        case BubbleType_Bee:
        {
            switch ([GameState sharedInstance].gameMode) {
                case AngelinaGameMode_Classic:
                    [scene.livesIndicator increment];
                    scoreNode = [CCSprite spriteWithSpriteFrameName:@"1up.png"];
                    break;
                case AngelinaGameMode_Clock:
                {
                    NSUInteger seconds = (1 + (arc4random() % 4)) * 5;
                    if (scene.timeHandler.timeLeft < 10) {
                        seconds = MAX(10, seconds);
                    }
                    switch (seconds) {
                        case 5:
                            animation = @"Angelina_5sec";
                            break;
                        case 10:
                            animation = @"Angelina_10sec";
                            break;
                        case 15:
                            animation = @"Angelina_15sec";
                            break;
                        case 20:
                            animation = @"Angelina_20sec";
                            break;
                        default:
                            break;
                    }
                    
                    [scene.timeHandler increaseTimeWith:seconds];
                    scoreNode = [CCNode node];
                    CCLabelBMFont *label = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"+%d", seconds] fntFile:@"yellow_font.fnt"];
                    [scoreNode addChild:label];
                    CCSprite *sec = [CCSprite spriteWithSpriteFrameName:@"sec.png"];
                    [scoreNode addChild:sec];
                    label.anchorPoint = ccp(0,1);
                    label.positionInPixels = ccp(0,50);
                    sec.anchorPoint = ccp(0,1);
                    sec.positionInPixels = ccp(50,-30);
                    break;
                }
                default:
                    NSAssert(FALSE, @"Invalid game mode");
                    break;
            }
            [[GameState sharedInstance] incrementBubbleStats:@"Bee"];
            rewardType = @"ButterflyReward";
            audio = AngelinaGameAudio_BumblebeePop;
            break;
        }
        case BubbleType_Butterfly:
        {
            [[GameState sharedInstance] incrementBubbleStats:@"Butterfly"];
            [scene.scoreHandler increaseBonusScore];
            scoreNode = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"+%d!", scene.scoreHandler.currentBonusScore] fntFile:@"yellow_font.fnt"];
            rewardType = @"ButterflyReward";
            audio = AngelinaGameAudio_BumblebeePop;
            break;
        }
        default:
            break;
    }
    
    // Play audio
    if (audio != nil) {
        [AudioHelper playAudio:audio];
    }
    
    // Show particle effect
    if (rewardType != nil) {
        NSString *file = [[NSBundle mainBundle] pathForResource:rewardType ofType:@"plist"];
        CCParticleSystemQuad *particle = [CCParticleSystemQuad particleWithFile:file];
        particle.autoRemoveOnFinish = YES;
        particle.position = self.position;
        particle.scale = self.sprite.scale;
        [self.parent addChild:particle];
    }
    if (scoreNode != nil) {
        scoreNode.position = self.position;
        scoreNode.scale = 0.01;
        [self.parent addChild:scoreNode];
        
        // movement
        CCMoveBy *move = [CCMoveBy actionWithDuration:2 position:ccp(scaleValueToScreen(100), scaleValueToScreen(100))];
        CCCallFuncN *callFunc = [CCCallFuncN actionWithTarget:self selector:@selector(removeNode:)];
        [scoreNode runAction:[CCSequence actionOne:move two:callFunc]];
        
        // grow, fade
        CCScaleTo *scale = [CCScaleTo actionWithDuration:0.2 scale:scaleOfScreen];
        CCDelayTime *delay = [CCDelayTime actionWithDuration:0.5];
        CCFadeOut *fade = [CCFadeOut actionWithDuration:0.5];
        [scoreNode runAction:[CCSequence actions:scale, delay, fade, nil]];
    }
    if (animation != nil && [animation length] > 0) {
        [[Animations sharedInstance] startAnimation:animation onNode:scene.angelina];
    }
    
    CGPoint position = self.position;
    CCNode *parent = self.parent;
    
    [self pop];
    
    if (showCross) {
        CCSprite *cross = [CCSprite spriteWithFile:@"x.png"];
        cross.opacity = 0;
        cross.scale = scaleOfScreen;
        cross.position = position;
        [parent addChild:cross z:150];
        
        CCFadeIn *fadeIn = [CCFadeIn actionWithDuration:0.2];
        CCDelayTime *delay = [CCDelayTime actionWithDuration:0.5];
        CCFadeOut *fadeOut = [CCFadeOut actionWithDuration:0.2];
        CCCallBlockN *remove = [CCCallBlockN actionWithBlock:^(CCNode *node) {
            [node removeFromParentAndCleanup:YES];
        }];
        CCSequence *seq = [CCSequence actions:fadeIn, delay, fadeOut, remove, nil];
        [cross runAction:seq];
    }    
	return YES;
}

- (void)removeNode:(CCNode *)node
{
    [node removeFromParentAndCleanup:YES];
}

- (void)pop {
    NSString *animation = nil;
    switch (self.type) {
        case BubbleType_Bee:
            animation = @"star";
            break;
        case BubbleType_Butterfly:
            animation = @"pink_slippers";
            break;
        case BubbleType_Flower:
        {
            NSArray *flowers = [[GameParameters params] objectForKey:@"flowers"];
            animation = [[flowers objectAtIndex:self.flowerType] stringByDeletingPathExtension];
            break;
        }
    }
    
    // Create fading out bubble
    {
        CCSprite *bubble = [CCSprite spriteWithFile:@"bubble.png"];
        bubble.position = self.position;
        bubble.scale = self.sprite.scale;
        CCSequence *seq = [CCSequence actions:[CCFadeOut actionWithDuration:0.5], [CCCallBlockN actionWithBlock:^(CCNode *node) {
            [node removeFromParentAndCleanup:YES];
        }], nil];
        [bubble runAction:seq];
        [self.parent addChild:bubble];
    }
    
    // Create rotating item
    {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"item_scaling" ofType:@"plist"]];
        
        NSString *imageName = [NSString stringWithFormat:@"%@.png", animation];
        CCSprite *item = [CCSprite spriteWithFile:imageName];
        item.position = self.position;
        NSDictionary *scalingDict = [dict objectForKey:@"scaling"];
        item.scale = self.sprite.scale * [[scalingDict objectForKey:imageName] floatValue];

        NSDictionary *offsetDict = [dict objectForKey:@"offset"];
        CGPoint offset = CGPointFromString([offsetDict objectForKey:imageName]);
        item.positionInPixels = ccpAdd(item.positionInPixels, scaleCGPointToScreen(offset));
        
        CCAnimation *anim = [CCAnimation animation];
        for (int i = 0; i <= 9; i++) {
            [anim addFrameWithFilename:[NSString stringWithFormat:@"%@_%02d.png", animation, i]];
        }
        anim.delay = 1.0/15.0;
        CCSequence *seq = [CCSequence actions:[CCAnimate actionWithAnimation:anim], [CCCallBlockN actionWithBlock:^(CCNode *node) {
            [node removeFromParentAndCleanup:YES];
        }], nil];
        [item runAction:seq];
        [self.parent addChild:item];
    }
        
    [self removeFromParentAndCleanup:YES];
}

-(void) update:(ccTime)dt {    
    if (self.originalX < 0) {
        self.originalX = self.position.x;
    }
    
    float amplitude = 10 * self.sprite.scale;
	float frequency = 0.01;
    float x = self.originalX + (amplitude * sin(frequency * (self.originalX + self.position.y)));
    
    self.position = ccp(x, self.position.y);
}

- (void)setColor:(ccColor3B)color
{
    for (CCNode *node in self.children) {
        if ([node conformsToProtocol:@protocol(CCRGBAProtocol)]) {
            [(id<CCRGBAProtocol>) node setColor:color];
        }
    }
    for (CCNode *node in self.sprite.children) {
        if ([node conformsToProtocol:@protocol(CCRGBAProtocol)]) {
            [(id<CCRGBAProtocol>) node setColor:color];
        }
    }
}

@end
