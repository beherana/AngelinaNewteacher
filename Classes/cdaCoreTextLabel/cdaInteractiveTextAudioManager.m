//
//  cdaInteractiveTextAudioManager.m

//
//  Created by Radif Sharafullin on 2/3/11.
//  Copyright 2011 Callaway Digital Arts. All rights reserved.
//

#import "cdaInteractiveTextAudioManager.h"
#import "cdaGlobalFunctions.h"

static cdaInteractiveTextAudioManager * sharedInstance;

@interface cdaInteractiveTextAudioManager (topSecret)
//observing player values
-(void)beginObservingPlayerTime;
-(void)stopObservingPlayerTime;
-(void)playerTick;
@end


@implementation cdaInteractiveTextAudioManager
@synthesize volume, delegate,nativeAudioObserver, currentPlayRecordKey, currentPlayRecordFileName;
@synthesize player;

#pragma mark Singleton Piping
+(id)sharedAudioManager{
	if (sharedInstance) return sharedInstance;
	
	sharedInstance=[[self new] autorelease];
	return sharedInstance;
}
-(id)init{
	self=[super init];
	//init player
	self.volume=1.0f;
    
    /*
     [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(AVManagerItemStartedPlaying:)
     name:kAVManagerItemStartedPlaying
     object:[AVQueueManager sharedAVQueueManager]];
    */
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(AVManagerItemStoppedPlaying:)
     name:kAVManagerItemStoppedPlaying
     object:[AVQueueManager sharedAVQueueManager]];
    /*
     [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(AVManagerItemPaused:)
     name:kAVManagerItemPaused
     object:[AVQueueManager sharedAVQueueManager]];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(AVManagerItemUnpaused:)
     name:kAVManagerItemUnpaused
     object:[AVQueueManager sharedAVQueueManager]];    
    */
	return self;
}
-(void)dealloc{
	CDA_LOG_METHOD_NAME;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[self stop];
	[self stopRecordingAndSave:YES];
	[super dealloc];
}
+(void)audioManagerRetain{
	[[[self class]sharedAudioManager] retain];
}
+(void)audioManagerRelease{
	if (sharedInstance) {
		if ([sharedInstance retainCount]>0) {
			if ([sharedInstance retainCount]==1) {
				[sharedInstance release];
				sharedInstance=nil;
			}else {
				[sharedInstance release];
			}
		}
	}
}


//*************************

#pragma mark -
#pragma mark play

-(void)playAudioWithPath:(NSString *)filePath observer:(id)observer{
	if (!filePath || ![filePath length]) return;
	if ([self isRecording]) return;
	[self playAudioFile:filePath];
	self.nativeAudioObserver=observer;
	[self beginObservingPlayerTime];
}
-(void)playAudioFile:(NSString *)filePath{
	if (!filePath || ![filePath length]) return;
	[self stop];
    
    queueItem = [[AVQueueManager sharedAVQueueManager] enqueueAudioFileUrl:[NSURL fileURLWithPath:filePath] withPrio:50 exclusive:YES userData:@"narration"];
    
	//FIXME player.volume=self.volume;
	self.currentPlayRecordFileName=filePath;
	if ([delegate respondsToSelector:@selector(cdaInteractiveTextAudioManagerDidStartPlaying:)]) 
		 [delegate cdaInteractiveTextAudioManagerDidStartPlaying:self];
}
-(void)pause{
	//if(player) [player pause]; else
    if(recorder) [recorder pause];
}
-(void)unpause{
	//if(player) [player play]; else
    if(recorder) [recorder record];
}
//Unless the item was paused restart
-(void)restart:(NSString *)filePath observer:(id)observer {
    if (queueItem == nil) {
        if ([delegate respondsToSelector:@selector(cdaInteractiveTextAudioManagerWillRestartPlaying:)]) 
            [delegate cdaInteractiveTextAudioManagerWillRestartPlaying:self];
        
        [self playAudioWithPath:filePath observer:observer];
    }
    else {
        if (queueItem.playing) {
            if ([delegate respondsToSelector:@selector(cdaInteractiveTextAudioManagerWillRestartPlaying:)]) 
                [delegate cdaInteractiveTextAudioManagerWillRestartPlaying:self];

            [queueItem restart];
        }
        else {
            //item paused
            [[AVQueueManager sharedAVQueueManager] play];
        }
    }
}
-(void)stop{
    [[AVQueueManager sharedAVQueueManager] removeFromQueue:@"narration"];
    queueItem = nil;
    [self stopObservingPlayerTime];
    self.nativeAudioObserver=nil;
    self.currentPlayRecordKey=nil;
    self.currentPlayRecordFileName=nil;
}
-(BOOL)playRecordingForKey:(NSString *)key{
	if (!key || ![key length]) return NO;
	[self stop];
	[self stopRecordingAndSave:YES];
	
	NSString *audioFile=nil;
	NSArray *keys=[self recordingKeys];
	for (NSDictionary *recording in keys) {
		if ([[recording objectForKey:@"key"] isEqualToString:key]) {
			audioFile=[recording objectForKey:@"audioFilePath"];
		}
	}
	if (audioFile) {
		self.currentPlayRecordKey=key;
		
		[self playAudioFile:audioFile];
		
		if ([delegate respondsToSelector:@selector(cdaInteractiveTextAudioManagerRecordingDidStart:forKey:)]) 
			[delegate cdaInteractiveTextAudioManagerRecordingDidStart:self forKey:key];	
		return YES;
	}
	
	return NO;
}
#pragma mark Misc


-(void)setVolume:(float)vol{
	volume=vol;
	//set volume here
	//if (player) player.volume=vol;
}
#pragma mark recording
-(void)recordVoiceForKey:(NSString *)key{
	if (!key || ![key length]) return;
	[self stop];
	[self stopRecordingAndSave:YES];
	
	NSString *path;
	
	NSString *audioFile=nil;
	NSString *keyFile;
	
	//check if the key exist first
	NSArray *keys=[self recordingKeys];
	for (NSDictionary *recording in keys) {
		if ([[recording objectForKey:@"key"] isEqualToString:key]) {
			audioFile=[recording objectForKey:@"audioFilePath"];
		}
	}

	
	if (!audioFile) {//new key and audio file path
		//create directory
		NSString *dirPath=[cdaGlobalFunctions cdaPath:kRecordingFolderPath];
		[[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];	
		do {
			path=[dirPath stringByAppendingPathComponent:[cdaGlobalFunctions uniqueTimestampID]];
			
			audioFile=[path stringByAppendingPathExtension:@"caf"];
			keyFile=[path stringByAppendingPathExtension:@"key"];
			
		} while ([[NSFileManager defaultManager] fileExistsAtPath:audioFile]);
		
		
		
		//create the key file
		[key writeToFile:keyFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
	}
	
	
	self.currentPlayRecordKey=key;
	self.currentPlayRecordFileName=audioFile;
	
	//create the audio file
	recorder=[[AVAudioRecorder alloc]initWithURL:[NSURL fileURLWithPath:audioFile] settings:nil error:nil];
	[recorder record];
	
}
-(void)stopRecordingAndSave:(BOOL)save{	
	
	if (recorder) {
		recorder.delegate=nil;
		[recorder stop];
		CDA_RELEASE_SAFELY(recorder);
		if (!save) [self deleteRecordingForKey:self.currentPlayRecordKey];
		self.currentPlayRecordKey=nil;
		self.currentPlayRecordFileName=nil;
	}
}
-(BOOL)deleteRecordingForKey:(NSString *)key{
	BOOL success=NO;
	NSArray *keys=[self recordingKeys];
	for (NSDictionary *recording in keys) {
		if ([[recording objectForKey:@"key"] isEqualToString:key]) {
			NSString * audioFilePath=[recording objectForKey:@"audioFilePath"];
			NSString *key=[recording objectForKey:@"key"];
			
			NSString *dirPath=[cdaGlobalFunctions cdaPath:kRecordingFolderPath];
			
			NSString *keyFilePath=[[dirPath stringByAppendingPathComponent:key] stringByAppendingPathExtension:@"key"];
			
			[[NSFileManager defaultManager] removeItemAtPath:audioFilePath error:nil];
			[[NSFileManager defaultManager] removeItemAtPath:keyFilePath error:nil];
			success=YES;
		}
	}
	return success;
}

-(void)deleteRecordingsForAllKeys{
	NSString *dirPath=[cdaGlobalFunctions cdaPath:kRecordingFolderPath];
	[[NSFileManager defaultManager] removeItemAtPath:dirPath error:nil];
}
-(NSArray *)recordingKeys{
	NSString *dirPath=[cdaGlobalFunctions cdaPath:kRecordingFolderPath];
	NSArray*directoryContent=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil];
	if (![directoryContent count]) return nil;
	
	NSMutableArray *keys=[NSMutableArray array];
	for (NSString *fileName in directoryContent) {
		if ([[fileName pathExtension] isEqualToString:@"key"]) {
			NSString * key=[NSString stringWithContentsOfFile:[dirPath stringByAppendingPathComponent:fileName]
													 encoding:NSUTF8StringEncoding 
														error:nil];
			NSString * audioFilePath=[[[dirPath stringByAppendingPathComponent:fileName] stringByDeletingPathExtension] stringByAppendingPathExtension:@"caf"];
			
			if ([[NSFileManager defaultManager] fileExistsAtPath:audioFilePath]) {
				
				NSMutableDictionary *dict=[NSMutableDictionary dictionary];
				[dict setObject:key	forKey:@"key"];
				[dict setObject:audioFilePath forKey:@"audioFilePath"];
				
				[keys addObject:dict];
			}
		}
	}
	if (!keys.count) return nil;
	return keys;
}

#pragma mark states
-(BOOL)isPlayingNativeAudio{
	if (queueItem != nil && nativeAudioObserver) return [queueItem playing];
	return NO;
}
-(BOOL)isPlayingRecordedAudio{
	if (queueItem != nil && self.currentPlayRecordKey) return [queueItem playing];
	return NO;
}

-(BOOL)isRecording{
	if (recorder) return recorder.recording;
	return NO;
}

-(NSTimeInterval)currentPlaybackTime{
	return (queueItem != nil) ? [queueItem currentTime] : 0;
}
-(NSTimeInterval)currentRecordingTime{
    return recorder.currentTime;
}

#pragma mark observing player values
-(void)beginObservingPlayerTime{
	playerTimer=[NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(playerTick) userInfo:nil repeats:YES];
}
-(void)stopObservingPlayerTime{
	CDA_INVALIDATE_TIMER(playerTimer);
}
-(void)playerTick{
	[[self nativeAudioObserver] cdaInteractiveTextAudioManager:self isPlayingCurrentTime:[self currentPlaybackTime]];
}
#pragma mark playerDelegates
- (void) AVManagerItemStoppedPlaying:(NSNotification *) notification
{
    AVQueueItem *item = [[notification userInfo] objectForKey:@"item"];
    if ([item.userData isEqual:@"narration"]) {
        [self stop];
        
        if ([delegate respondsToSelector:@selector(cdaInteractiveTextAudioManagerDidFinishPlaying:successfully:)]) 
            [delegate cdaInteractiveTextAudioManagerDidFinishPlaying:self successfully:YES];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
	[self stop];
	if ([delegate respondsToSelector:@selector(cdaInteractiveTextAudioManagerDidFinishPlaying:successfully:)]) 
		 [delegate cdaInteractiveTextAudioManagerDidFinishPlaying:self successfully:flag];
}


- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
	if ([delegate respondsToSelector:@selector(cdaInteractiveTextAudioManagerDecodeErrorDidOccur:error:)]) 
		[delegate cdaInteractiveTextAudioManagerDecodeErrorDidOccur:self error:error];
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player{
	if ([delegate respondsToSelector:@selector(cdaInteractiveTextAudioManagerBeginInterruption:)]) 
		[delegate cdaInteractiveTextAudioManagerBeginInterruption:self];
}


- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withFlags:(NSUInteger)flags{
	if ([delegate respondsToSelector:@selector(cdaInteractiveTextAudioManagerEndInterruption:withFlags:)]) 
		[delegate cdaInteractiveTextAudioManagerEndInterruption:self withFlags:flags];
	
}


#pragma mark recorderDelegates
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{

	if ([delegate respondsToSelector:@selector(cdaInteractiveTextAudioManagerDidFinishRecording:successfully:)]) 
		[delegate cdaInteractiveTextAudioManagerDidFinishRecording:self successfully:flag];

}
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error{
	if ([delegate respondsToSelector:@selector(cdaInteractiveTextAudioManagerEncodeErrorDidOccur:error:)]) 
		[delegate cdaInteractiveTextAudioManagerEncodeErrorDidOccur:self error:error];
}

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder{
	if ([delegate respondsToSelector:@selector(cdaInteractiveTextAudioManagerBeginInterruption:)]) 
		[delegate cdaInteractiveTextAudioManagerBeginInterruption:self];
}
- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withFlags:(NSUInteger)flags{
	if ([delegate respondsToSelector:@selector(cdaInteractiveTextAudioManagerEndInterruption:withFlags:)]) 
		[delegate cdaInteractiveTextAudioManagerEndInterruption:self withFlags:flags];
}
@end
