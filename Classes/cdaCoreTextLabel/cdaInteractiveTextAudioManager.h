//
//  cdaInteractiveTextAudioManager.h

//
//  Created by Radif Sharafullin on 2/3/11.
//  Copyright 2011 Callaway Digital Arts. All rights reserved.
//

#import <Foundation/Foundation.h>


#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVAudioRecorder.h>
#import "AVQueueManager.h"

#define kRecordingFolderPath @"$DOCUMENTS/InteractiveTextUserRecordings"

@class cdaInteractiveTextAudioManager;


@protocol cdaInteractiveTextAudioManagerDelegate <NSObject>
@optional

//playback
- (void)cdaInteractiveTextAudioManagerDidStartPlaying:(cdaInteractiveTextAudioManager *)interactiveTextAudioManager;
- (void)cdaInteractiveTextAudioManagerDidFinishPlaying:(cdaInteractiveTextAudioManager *)interactiveTextAudioManager successfully:(BOOL)flag;
- (void)cdaInteractiveTextAudioManagerWillRestartPlaying:(cdaInteractiveTextAudioManager *)interactiveTextAudioManager;
- (void)cdaInteractiveTextAudioManagerDecodeErrorDidOccur:(cdaInteractiveTextAudioManager *)interactiveTextAudioManager error:(NSError *)error;


//record
- (void)cdaInteractiveTextAudioManagerRecordingDidStart:(cdaInteractiveTextAudioManager *)interactiveTextAudioManager forKey:(NSString *)key;
- (void)cdaInteractiveTextAudioManagerDidFinishRecording:(cdaInteractiveTextAudioManager *)interactiveTextAudioManager successfully:(BOOL)flag;
- (void)cdaInteractiveTextAudioManagerEncodeErrorDidOccur:(cdaInteractiveTextAudioManager *)interactiveTextAudioManager error:(NSError *)error;

//interruption
- (void)cdaInteractiveTextAudioManagerBeginInterruption:(cdaInteractiveTextAudioManager *)interactiveTextAudioManager;
- (void)cdaInteractiveTextAudioManagerEndInterruption:(cdaInteractiveTextAudioManager *)interactiveTextAudioManager withFlags:(NSUInteger)flags;

@end

@protocol cdaInteractiveTextAudioManagerCurrentTimeObserver <NSObject>
-(void)cdaInteractiveTextAudioManager:(cdaInteractiveTextAudioManager *)audioManager isPlayingCurrentTime:(NSTimeInterval)currentTime;
@end


@interface cdaInteractiveTextAudioManager : NSObject <AVAudioPlayerDelegate> {
	
	id <cdaInteractiveTextAudioManagerDelegate> delegate;
	id <cdaInteractiveTextAudioManagerCurrentTimeObserver> nativeAudioObserver;
	
	NSString *currentPlayRecordKey;
	NSString *currentPlayRecordFileName;
	
	@private
	NSTimer *playerTimer;
	float volume;
	AVAudioRecorder *recorder;
    AVQueueItem *queueItem;

}
@property (nonatomic, assign) id <cdaInteractiveTextAudioManagerDelegate> delegate;
@property (nonatomic, assign) id <cdaInteractiveTextAudioManagerCurrentTimeObserver> nativeAudioObserver;
@property (nonatomic, assign) float volume;
@property (nonatomic, retain) NSString *currentPlayRecordKey;
@property (nonatomic, retain) NSString *currentPlayRecordFileName;
@property (nonatomic, retain) AVAudioPlayer *player;


+(id)sharedAudioManager;
+(void)audioManagerRetain;
+(void)audioManagerRelease;

//play recording
-(void)playAudioWithPath:(NSString *)filePath observer:(id)observer;//used for the native recordings
-(void)playAudioFile:(NSString *)filePath;
-(void)pause;
-(void)unpause;
-(void)restart:(NSString *)filePath observer:(id)observer;
-(void)stop;
-(BOOL)playRecordingForKey:(NSString *)key;
-(NSArray *)recordingKeys;
-(BOOL)deleteRecordingForKey:(NSString *)key;
-(void)deleteRecordingsForAllKeys;

//record
-(void)recordVoiceForKey:(NSString *)key;
-(void)stopRecordingAndSave:(BOOL)save;

//states
-(BOOL)isPlayingNativeAudio;
-(BOOL)isPlayingRecordedAudio;
-(BOOL)isRecording;

-(NSTimeInterval)currentPlaybackTime;
-(NSTimeInterval)currentRecordingTime;

@end
