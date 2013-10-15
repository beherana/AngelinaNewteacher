//
//  AudioQueueManager.m
//  Angelina-New-Teacher-Universal
//
//  Created by Karl Söderström on 2011-05-26.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AVQueueManager.h"

@interface AVQueueItem ()
@property (nonatomic, retain) AVAudioPlayer *player;
@property (nonatomic, retain) cdaMoviePlayerView *moviePlayer;
@end

@implementation AVQueueItem

@synthesize player = _player;
@synthesize moviePlayer = _moviePlayer;
@synthesize url = _url;
@synthesize prio = _prio;
@synthesize exclusive = _exclusive;
@synthesize userData = _userData;
@synthesize finishedSuccessfully = _finishedSuccessfully;

- (void)play
{
    if (self.player != nil) {
        if (playerCurrentTime) {
            self.player.currentTime = playerCurrentTime;
            [self.player play];
        }
        else {
            [self.player play];
        }
    } else {
        self.moviePlayer.movieURL = self.url;
        [self.moviePlayer play];
    }
}

- (void)pause
{
    if (self.player != nil) {
        playerCurrentTime = self.player.currentTime;
        [self.player stop];
    } else {
        [self.moviePlayer pause];
    }
}

- (void)stop
{
    if (self.player != nil) {
        [self.player stop];
        playerCurrentTime = 0;
    } else {
        self.moviePlayer.delegate = nil;
        [self.moviePlayer stop];
        [self.moviePlayer removeFromSuperview];
        [self.moviePlayer removeTimeObserver];
    }
}

//play audio from start without stopping first
- (void)restart {
    if (self.player != nil) {
        self.player.currentTime = 0;
    } else {
        self.moviePlayer.currentPosition = 0;
    }

    if (!self.playing) {
        [self play];
    }
}

- (BOOL)playing
{
    if (self.player != nil) {
        return self.player.playing;
    } else {
        return self.moviePlayer.isPlaying;
    }
}

- (NSTimeInterval)currentTime
{
    if (self.player != nil) {
        return self.player.currentTime;
    } else {
        return self.moviePlayer.currentPosition;
    }
}

- (void)dealloc
{
    self.player = nil;
    self.moviePlayer = nil;
    self.url = nil;
    self.userData = nil;
    [super dealloc];
}

@end

@interface AVQueueManager()
@property (nonatomic, retain) NSMutableArray *queue;
@property (nonatomic, assign) BOOL paused;
@end

@implementation AVQueueManager

@synthesize queue = _queue;
@synthesize paused = _paused;

static AVQueueManager *sharedAVQueueManager = nil;

+ (AVQueueManager*)sharedAVQueueManager
{
    if (sharedAVQueueManager == nil) {
        sharedAVQueueManager = [[super allocWithZone:NULL] init];
    }
    return sharedAVQueueManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedAVQueueManager] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

- (id)init
{
    if ((self = [super init])) {
        self.queue = [NSMutableArray array];
    }
    return self;
}

- (void)playItem:(AVQueueItem *)item
{
    BOOL unpaused = (item.currentTime > 0);
    [item play];
    if (unpaused) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kAVManagerItemUnpaused object:self userInfo:[NSDictionary dictionaryWithObject:item forKey:@"item"]];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kAVManagerItemStartedPlaying object:self userInfo:[NSDictionary dictionaryWithObject:item forKey:@"item"]];
    }
}

- (void)pauseItem:(AVQueueItem *)item
{
    [item pause];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAVManagerItemPaused object:self userInfo:[NSDictionary dictionaryWithObject:item forKey:@"item"]];
}


- (void)stopItem:(AVQueueItem *)item withFinishSuccessfullyStatus:(BOOL) finished
{
    item.finishedSuccessfully = finished;
    [item stop];
    [item retain];
    [self.queue removeObject:item];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAVManagerItemStoppedPlaying object:self userInfo:[NSDictionary dictionaryWithObject:item forKey:@"item"]];
    [item release];
}

- (void)stopItem:(AVQueueItem *)item {
    [self stopItem:item withFinishSuccessfullyStatus:NO];
}

- (void)insertQueueItem:(AVQueueItem *)newItem
{
    int i;
    for (i = 0; i < [self.queue count]; i++) {
        AVQueueItem *item = [self.queue objectAtIndex:i];
        if (newItem.prio > item.prio) {
            break;
        }
    }
    
    if (i < [self.queue count]) {
        [self.queue insertObject:newItem atIndex:i];
    } else {
        [self.queue addObject:newItem];
    }
    i++;
    if (newItem.exclusive) {
        for (;i < [self.queue count]; i++) {
            AVQueueItem *item = [self.queue objectAtIndex:i];
            if (item.playing) {
                [self pauseItem:item];
            }
        }
    }
}

- (void)playQueue
{
    if (self.paused) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        for (AVQueueItem *item in self.queue) {
            if (!item.playing) {
                [self playItem:item];
            }
            if (item.exclusive) {
                break;
            }
        }
    });
}

- (AVQueueItem *)enqueueAudioFileUrl:(NSURL*)url withPrio:(int)prio exclusive:(BOOL)exclusive userData:(id)userData
{
    AVQueueItem *item = [[[AVQueueItem alloc] init] autorelease];
    NSError *error;
    item.player = [[[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error] autorelease];
    item.player.delegate = self;
    item.url = url;
    item.prio = prio;
    item.exclusive = exclusive;
    item.userData = userData;
    
    [self insertQueueItem:item];
    [self playQueue];
    return item;
}

- (AVQueueItem *)enqueueVideoFileUrl:(NSURL*)url onView:(UIView *)view frame:(CGRect)frame withPrio:(int)prio exclusive:(BOOL)exclusive userData:(id)userData
{
    AVQueueItem *item = [[[AVQueueItem alloc] init] autorelease];
    item.moviePlayer = [cdaMoviePlayerView playerOnView:view frame:frame];
    [item.moviePlayer setFadesOutOnEnd:YES fadesoutVolume:NO duration:0.5];
    item.moviePlayer.delegate = self;
    item.url = url;
    item.prio = prio;
    item.exclusive = exclusive;
    item.userData = userData;
    
    [self insertQueueItem:item];
    [self playQueue]; 
    return item;
}

- (void)removeFromQueue:(id)userData
{
    for (int i = 0; i < [self.queue count]; i++) {
        AVQueueItem *item = [self.queue objectAtIndex:i];
        if ([item.userData isEqual:userData]) {
            [self stopItem:item];
            i--; // item is removed. this is to handle the modified array
        }
    }
    [self playQueue];
}

-(AVQueueItem*) itemInQueue:(id)userData {
    AVQueueItem *queueItem = nil;
    
    for (int i = 0; i < [self.queue count]; i++) {
        AVQueueItem *item = [self.queue objectAtIndex:i];
        if ([item.userData isEqual:userData]) {
            queueItem = item;
        }
    }
    
    return queueItem;
}

- (void)pause
{
    self.paused = YES;
    for (AVQueueItem *item in self.queue) {
        if (item.playing) {
            [self pauseItem:item];
        }
    }
}

- (void)play
{
    self.paused = NO;
    [self playQueue];
}

-(void)stop
{
    self.paused = NO;
    
    for (int i = 0; i < [self.queue count]; i++) {
        AVQueueItem *item = [self.queue objectAtIndex:i];
        [self stopItem:item];
        i--; // item is removed. this is to handle the modified array
    }
}

#pragma mark - callbacks

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    for (AVQueueItem *item in self.queue) {
        if (item.player == player) {
            [self stopItem:item withFinishSuccessfullyStatus:flag];
            break;
        }
    }
    [self playQueue];
}

-(void)cdaMoviePlayerViewDidFadeOut:(cdaMoviePlayerView *)moviePlayerView
{
    for (AVQueueItem *item in self.queue) {
        if (item.moviePlayer == moviePlayerView) {
            [self stopItem:item withFinishSuccessfullyStatus:YES];
            break;
        }
    }
    [self playQueue];
}

@end
