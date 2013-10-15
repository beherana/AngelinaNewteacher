//
//  Animations.m
//  Angelina-Bubble-Pop-Universal
//
//  Created by Karl Söderström on 2011-07-01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KeepAliveAnimations.h"
#import "AudioHelper.h"

@interface KeepAliveAnimations ()
@property (nonatomic, retain) NSDictionary *animations;
@property (nonatomic, retain) UIImageView *currentAnimation;
@property (nonatomic, retain) NSString *currentAudio;
@end


@implementation KeepAliveAnimations
@synthesize animations = _animations;
@synthesize currentAnimation = _currentAnimation;
@synthesize currentAudio = _currentAudio;

- (id)init
{
    if ((self = [super init])) {
        self.animations = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"keepAliveAnimations" ofType:@"plist"]];
    }
    return self;
}

- (void)startAnimation:(NSString *)name onView:(UIView *)animationView
{
    NSDictionary *anim = [self.animations objectForKey:name];
    if (anim == nil) {
        NSLog(@"Unknown animation: %@", name);
        return;
    }
    
    [self stopCurrentAnimation];
    
    NSDictionary *position = [anim objectForKey:@"position"];
    float x = [[position objectForKey:@"x"] floatValue];
    float y = [[position objectForKey:@"y"] floatValue];

    // Find the frames being used
    NSMutableArray *frames = [NSMutableArray array];
    for (NSString *frame in [anim objectForKey:@"frames"]) {
        //NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:frame];
        [frames addObject:[UIImage imageNamed:frame]];
    }
    
    bool first = YES;
    for (UIView *subview in animationView.subviews) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            first = NO;
            if ([(UIImageView*)subview isAnimating]) {
                [(UIImageView*)subview stopAnimating];
            }
            self.currentAnimation = (UIImageView*)subview;
        }
    }
    if (first) {
        self.currentAnimation = [[UIImageView alloc] initWithImage:[frames objectAtIndex:0]];
        [animationView addSubview:self.currentAnimation];
        
        [self.currentAnimation release];
    }
    
    //[imageView setImage:[frames objectAtIndex:0]];
    [self.currentAnimation setAnimationImages:frames];
    
    CGRect frame = self.currentAnimation.frame;
    frame.origin.x = x;
    frame.origin.y = y;
    self.currentAnimation.frame = frame;
    
    [self.currentAnimation setAnimationDuration:((2.0/24.0)*[frames count])];
    [self.currentAnimation setAnimationRepeatCount:1];
    
    [self.currentAnimation startAnimating];
    
    self.currentAudio = [anim objectForKey:@"audio"];
    if (self.currentAudio != nil && [self.currentAudio length] > 0) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:self.currentAudio withExtension:nil];
        AVQueueItem *audioItem = [[AVQueueManager sharedAVQueueManager] enqueueAudioFileUrl:url withPrio:200 exclusive:YES userData:self.currentAudio];
        [audioItem play];
    }
}

- (void)stopCurrentAnimation
{
    if (self.currentAnimation != nil) {
        [self.currentAnimation stopAnimating];
        [self.currentAnimation removeFromSuperview];
        self.currentAnimation = nil;
    }
    if (self.currentAudio != nil) {
        [[AVQueueManager sharedAVQueueManager] removeFromQueue:self.currentAudio];
        self.currentAudio = nil;
    }
}

- (void)dealloc
{
    [self stopCurrentAnimation];
    self.animations = nil;
    [super dealloc];
}

@end
