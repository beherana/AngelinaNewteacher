//
//  Animations.m
//  Angelina-Bubble-Pop-Universal
//
//  Created by Karl Söderström on 2011-07-01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Animations.h"
#import "AudioHelper.h"
#import "UIDevice-Hardware.h"

@interface Animations ()
@property (nonatomic, retain) NSDictionary *animations;
@property (nonatomic, assign) NSUInteger currentAudio;
@property (nonatomic, retain) CCSprite *currentAnimation;
@property (nonatomic, assign) BOOL playOnlyHighPrio;
@end

static Animations *sharedAnimations;

@implementation Animations
@synthesize animations = _animations;
@synthesize currentAudio = _currentAudio;
@synthesize currentAnimation = _currentAnimation;
@synthesize playOnlyHighPrio = _playOnlyHighPrio;

+ (Animations *)sharedInstance
{
    if (sharedAnimations == nil) {
        sharedAnimations = [[Animations alloc] init];
    }
    return sharedAnimations;
}

- (id)init
{
    if ((self = [super init])) {
        self.animations = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"animations" ofType:@"plist"]];
        NSUInteger platformType = [[UIDevice currentDevice] platformType];
        switch (platformType) {                
            case UIDevice1GiPhone:
            case UIDevice3GiPhone:
            case UIDevice1GiPod:
            case UIDevice2GiPod:
                self.playOnlyHighPrio = YES;
                break;
            default:
                self.playOnlyHighPrio = NO;
                break;
        }
    }
    return self;
}

- (void)startAnimation:(NSString *)name onNode:(CCNode *)node
{
    NSDictionary *anim = [self.animations objectForKey:name];
    if (anim == nil) {
        NSLog(@"Unknown animation: %@", name);
        return;
    }
    
    if (self.playOnlyHighPrio && ![[anim objectForKey:@"highPrio"] boolValue]) {
        return;
    }
    
    [self stopCurrentAnimation];


    if (node != nil) {
        NSDictionary *position = [anim objectForKey:@"position"];
        float x = [[position objectForKey:@"x"] floatValue];
        float y = [[position objectForKey:@"y"] floatValue];
        float fps = [[anim objectForKey:@"fps"] floatValue];

        // Find the frames being used
        NSMutableArray *frames = [NSMutableArray array];
        for (NSString *frame in [anim objectForKey:@"frames"]) {
            NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:frame];
            CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:path];
            CCSpriteFrame *f = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(0, 0, texture.contentSize.width, texture.contentSize.height)];
            [frames addObject:f];
        }
        
        if ([frames count] > 0) {
            CCAnimation *animation = [CCAnimation animationWithFrames:frames delay:1.0/(fps > 0 ? fps : 30.0)];
        
            self.currentAnimation = [CCSprite spriteWithSpriteFrame:[frames objectAtIndex:0]];
            [node addChild:self.currentAnimation];
            self.currentAnimation.anchorPoint = ccp(0.5, 0.5);
            CGPoint p = CGPointMake(x, y);
            self.currentAnimation.positionInPixels = p;//scaleCGPointToScreen(p);
        
            CCSequence *seq = [CCSequence actionOne:[CCAnimate actionWithAnimation:animation] two:[CCCallBlockN actionWithBlock:
                                    ^(CCNode *node) {
                                        [node removeFromParentAndCleanup:YES];
                                        self.currentAnimation = nil;
                                    }]];
            [self.currentAnimation runAction:seq];
        }
    }
    NSString *audio = [anim objectForKey:@"audio"];
    if (audio != nil && [audio length] > 0) {
        self.currentAudio = [AudioHelper playAudio:audio];
    }
}

- (void)stopCurrentAnimation
{
    if (self.currentAnimation != nil) {
        [self.currentAnimation removeFromParentAndCleanup:YES];
        self.currentAnimation = nil;
    }
    if (self.currentAudio > 0) {
        [AudioHelper stopAudio:self.currentAudio];
        self.currentAudio = 0;
    }
}

- (void)preloadAnimation:(NSString *)name
{
    NSDictionary *anim = [self.animations objectForKey:name];
    if (anim == nil) {
        NSLog(@"Unknown animation: %@", name);
        return;
    }
    for (NSString *frame in [anim objectForKey:@"frames"]) {
        NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:frame];
        [[CCTextureCache sharedTextureCache] addImage:path];
    }
    NSString *audio = [anim objectForKey:@"audio"];
    if (audio != nil && [audio length] > 0) {
        [AudioHelper preloadAudioFile:audio];
    }
}

@end
