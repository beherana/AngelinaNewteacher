//
//  AudioQueueManager.h
//  Angelina-New-Teacher-Universal
//
//  Created by Karl Söderström on 2011-05-26.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "cdaMoviePlayerViewController.h"

/*
 * Notifications are sent using NSNotificationCenter
 * An AudioItem is sent as dictionary item 'item'
 */
#define kAVManagerItemStartedPlaying @"AVManagerItemStartedPlaying"
#define kAVManagerItemStoppedPlaying @"AVManagerItemStoppedPlaying"
#define kAVManagerItemPaused @"AVManagerItemPaused"
#define kAVManagerItemUnpaused @"AVManagerItemUnpaused"


@interface AVQueueItem : NSObject {
@private
    AVAudioPlayer *_player;
    cdaMoviePlayerView *_moviePlayer;
    NSURL *_url;
    int _prio;
    BOOL _exclusive;
    BOOL _finishedSuccessfully;
    id _userData;
    NSTimeInterval playerCurrentTime;
}
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, assign) int prio;
@property (nonatomic, assign) BOOL exclusive;
@property (nonatomic, assign) BOOL finishedSuccessfully;
@property (nonatomic, retain) id userData;

- (NSTimeInterval)currentTime;
- (BOOL)playing;
- (void)play;
- (void)restart;

@end


@class AVQueueItem;

@interface AVQueueManager : NSObject <AVAudioPlayerDelegate,cdaMoviePlayerViewDelegate> {
@private
    NSMutableArray *_queue;
    BOOL _paused;
}

@property (nonatomic, readonly) BOOL paused;

+ (AVQueueManager*)sharedAVQueueManager;

- (AVQueueItem *)enqueueAudioFileUrl:(NSURL*)url withPrio:(int)prio exclusive:(BOOL)exclusive userData:(id)userData;
- (AVQueueItem *)enqueueVideoFileUrl:(NSURL*)url onView:(UIView *)view frame:(CGRect)frame withPrio:(int)prio exclusive:(BOOL)exclusive userData:(id)userData;
- (void)removeFromQueue:(id)userData;
- (AVQueueItem*)itemInQueue:(id)userData;
- (void)pause;
- (void)play;
- (void)stop;

@end
