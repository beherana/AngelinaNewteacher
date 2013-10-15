//
//  cdaMoviePlayerView.m
//
//  Created by Radif Sharafullin on 1/31/11.
//  Copyright 2011 Callaway Digital Arts. All rights reserved.
//

#import "cdaMoviePlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import "cdaGlobalFunctions.h"
#import <QuartzCore/QuartzCore.h>
static NSString* const cdaPlayerPlaybackViewRateObservationContext = @"cdaPlayerPlaybackViewRateObservationContext";
static NSString* const cdaPlayerPlaybackViewDurationObservationContext = @"cdaPlayerPlaybackViewDurationObservationContext";

@interface cdaMoviePlayerView (topSecret)
-(BOOL)playNextMovieInArray;
@end


@implementation cdaMoviePlayerView
@synthesize superView,
delegate,
moviesArray,
volume,
isPlaying,
isPaused,
currentlyPlayingMovieInArray,
isPlayingArray,
duration,
currentPosition,
showsSpinnerWhenLoadingMovie,
player,
moviePath,
movieURL,
spinnerStyle;


+(float)cdaVersion{
    return .5;
}

+ (Class)layerClass{
	return [AVPlayerLayer class];
}
- (id)init{
    
    self = [super init];
    if (self) {
        // Initialization code.
		self.backgroundColor=[UIColor clearColor];
		self.spinnerStyle=UIActivityIndicatorViewStyleWhite;
        [self initPlayer];
		[self syncButtons];
    }
    return self;
}

-(void)initPlayer {
    AVPlayer *newPlayer = [[AVPlayer alloc] init];
    self.player = newPlayer;
    [newPlayer release];
    [self.player addObserver:self forKeyPath:@"rate" options:0 context:cdaPlayerPlaybackViewRateObservationContext];
    [self.player addObserver:self forKeyPath:@"currentItem.asset.duration" options:0 context:cdaPlayerPlaybackViewDurationObservationContext];
    [self setTimeObserverWithTolerance:.1];
    [(AVPlayerLayer *)self.layer setPlayer:self.player];
    
}

-(void)trashPlayer {
	if (player != nil) {
        [player removeObserver:self forKeyPath:@"rate"];
        [player removeObserver:self forKeyPath:@"currentItem.asset.duration"];
        [self removeTimeObserver];
        [player release];
        player = nil;
	}    
}


- (void)dealloc {
	[self trashPlayer];
	self.moviesArray=nil;
	CDA_RELEASE_SAFELY(moviePath);
	CDA_RELEASE_SAFELY(movieURL);
	CDA_RELEASE_SAFELY(spinner);
	CDA_LOG_METHOD_NAME;

    
    [super dealloc];
}

//alloc
+(id)playerOnView:(UIView *)view{
	return [[self newPlayerOnView:view] autorelease];
}
+(id)newPlayerOnView:(UIView *)view{
	cdaMoviePlayerView *player=[self new];
	[player setFrame:view.bounds];
	[view addSubview:player];
	player.superView=view;
	return player;
}
+(id)playerOnView:(UIView *)view frame:(CGRect)frame{
	return [[self newPlayerOnView:view frame:frame]autorelease];
}
+(id)newPlayerOnView:(UIView *)view frame:(CGRect)frame{
	cdaMoviePlayerView *player=[self new];
	[player setFrame:frame];
	[view addSubview:player];
	player.superView=view;
	return player;
}
+(id)playMoviesInArray:(NSArray *)movies onView:(UIView *)view{
	cdaMoviePlayerView * player=[[self new] autorelease];
	[player setFrame:view.frame];
	[view addSubview:player];
	player.superView=view;
	[player playMoviesInArray:movies];
	return player;
}

+(id)playMoviesInPlist:(NSString *)plistPath onView:(UIView *)view{

//Array (plist) format:
/*
 array of dictionaries:
 dictionary: key: "path"
 dictionary: key: "frame"
 */
	NSArray *plistContents=[NSArray arrayWithContentsOfFile:plistPath];
	return [self playMoviesInArray:plistContents onView:view];
}
//playing
-(void)playMoviesInArray:(NSArray *)movies{
	self.moviesArray=movies;
	//initiateArrayPlayback:
	
	currentlyPlayingMovieInArray=-1;
	[self playNextMovieInArray];
	
}
-(BOOL)playNextMovieInArray{
	currentlyPlayingMovieInArray++;
	if (currentlyPlayingMovieInArray>=([self.moviesArray count])){
		self.moviesArray=nil;
		currentlyPlayingMovieInArray=0;
		return NO;
	}
	
	
	NSDictionary *dict=[self.moviesArray objectAtIndex:self.currentlyPlayingMovieInArray];
	float prevAlpha=self.alpha;
	[CATransaction begin];
	[CATransaction setAnimationDuration:0];
	self.alpha=0.0f;
	
	if([dict objectForKey:@"movie_path"]){
		self.moviePath=[dict objectForKey:@"movie_path"];
	}else {
		self.movieURL=[dict objectForKey:@"movie_url"];
	}

	
	if ([dict objectForKey:@"movie_frame"]){
		self.frame=[[dict objectForKey:@"movie_frame"] CGRectValue];
	
	}
	
	

	self.alpha=prevAlpha;

	[CATransaction commit];
	[self play];

	return YES;
}

-(void)playMoviesInPlist:(NSString *)plistPath{
	NSArray *plistContents=[NSArray arrayWithContentsOfFile:plistPath];
	[self playMoviesInArray:plistContents];
}
-(void)playMovieWithContentsOfPath:(NSString *)movPath{

	self.moviePath=movPath;
	[self play];
}
-(void)playMovieWithContentsOfURL:(NSURL *)movURL{
	
	self.movieURL=movURL;
	[self play];
}


-(void)stopSpinner{
	if(spinner){
		[spinner removeFromSuperview];
		[spinner stopAnimating];
	}
	CDA_RELEASE_SAFELY(spinner);

}
-(void)play{
	startedActualPlayback=NO;
	[self stopSpinner];
    self.isPaused = NO;

	BOOL shouldPlay=YES;
	if ([delegate respondsToSelector:@selector(cdaMoviePlayerViewShouldStartPlayback:)]) shouldPlay=[delegate cdaMoviePlayerViewShouldStartPlayback:self];	
	if (!shouldPlay) return;
	
	
	if (isFadingIn) [self fadeInWithDuration:fadeInDuration];
	
	if ([delegate respondsToSelector:@selector(cdaMoviePlayerViewWillStartPlayback:)]) [delegate cdaMoviePlayerViewWillStartPlayback:self];	

	if (self.showsSpinnerWhenLoadingMovie) {
		
		spinner=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:self.spinnerStyle];
		spinner.center=CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
		[spinner setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
		[self addSubview:spinner];
		[spinner startAnimating];
	}
	
	[self.player play];
	if ([delegate respondsToSelector:@selector(cdaMoviePlayerViewDidStartPlayback:)]) [delegate cdaMoviePlayerViewDidStartPlayback:self];

}
-(void)pause{
	BOOL shouldPause=YES;
    self.isPaused = YES;
	if ([delegate respondsToSelector:@selector(cdaMoviePlayerViewShouldPausePlayback:)]) shouldPause=[delegate cdaMoviePlayerViewShouldPausePlayback:self];	
	if (!shouldPause) return;
	
	if ([delegate respondsToSelector:@selector(cdaMoviePlayerViewWillPausePlayback:)]) [delegate cdaMoviePlayerViewWillPausePlayback:self];
	[player pause];
	if ([delegate respondsToSelector:@selector(cdaMoviePlayerViewDidPausePlayback:)]) [delegate cdaMoviePlayerViewDidPausePlayback:self];
}
-(void)stop{
	BOOL shouldStop=YES;
    self.isPaused = NO; 
	if ([delegate respondsToSelector:@selector(cdaMoviePlayerViewShouldStopPlayback:)]) shouldStop=[delegate cdaMoviePlayerViewShouldStopPlayback:self];	
	if (!shouldStop) return;
	
	[player pause];

    //trash the player after stopping
    [self trashPlayer];
    [self initPlayer];
    
	if ([delegate respondsToSelector:@selector(cdaMoviePlayerViewDidStopPlayback:finished:)]) [delegate cdaMoviePlayerViewDidStopPlayback:self finished:NO];
}
-(void)timeUpdated:(CMTime)time{
//subclass this method for scrubber progress
}
-(void)setMoviePath:(NSString *)movPath{
	CDA_RELEASE_SAFELY(moviePath);
	if(!movPath) return;
	moviePath=[movPath copyWithZone:[self zone]];
	[self setMovieURL:[NSURL fileURLWithPath:self.moviePath]];
}
-(void)setMovieURL:(NSURL *)movURL{
	if (movURL != movieURL)
	{
		CDA_RELEASE_SAFELY(movieURL);
		CDA_RELEASE_SAFELY(moviePath);
		if(!movURL) return;
		movieURL = [movURL copyWithZone:[self zone]];
		moviePath=[[movURL absoluteString] copyWithZone:[self zone]];
		[self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:self.movieURL]];
	}	

}
-(void)cancelMoviesInArrayPlayback{
	self.moviesArray=nil;
}

//getters
-(NSTimeInterval)duration{
	//return self.player.duration;
	AVAsset* asset = [[self.player currentItem] asset];
	if (!asset) return 0;
	return CMTimeGetSeconds([asset duration]);
}
-(NSTimeInterval)currentPosition{	
	return CMTimeGetSeconds([self.player currentTime]);
}
-(float)volume{
	//TODO: make volume work!
	return 0;
	AVPlayerItem* currentItem = [self.player currentItem];
	if (!currentItem) return 0;
	
	AVAudioMix *audioMix=[currentItem audioMix];
	NSLog(@"%@",[audioMix inputParameters]);
	
	//AVMutableAudioMixInputParameters *audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParameters];
	//return [audioInputParams volume];
	
	return 0;
}
-(BOOL)isPlaying{
return [self.player rate] != 0.f;
}
-(BOOL)isPlayingArray{
	return self.moviesArray? YES:NO;
}



//setters
-(void)setCurrentPosition:(NSTimeInterval)pos{
	AVAsset* asset = [[self.player currentItem] asset];
	
	if (!asset) return;
	
	double d = CMTimeGetSeconds([asset duration]);
	
	if (isfinite(d))
	{
		[self.player seekToTime:CMTimeMakeWithSeconds(pos, NSEC_PER_SEC) toleranceBefore:CMTimeMakeWithSeconds(3, NSEC_PER_SEC) toleranceAfter:CMTimeMakeWithSeconds(3, NSEC_PER_SEC)];
	}
	
}
-(void)scrubToEnd{
	AVAsset* asset = [[self.player currentItem] asset];
	if (!asset) return;
	double d = CMTimeGetSeconds([asset duration]);
	
	if (isfinite(d))
	{
		[self.player seekToTime:CMTimeMakeWithSeconds(d, NSEC_PER_SEC) toleranceBefore:CMTimeMakeWithSeconds(3, NSEC_PER_SEC) toleranceAfter:CMTimeMakeWithSeconds(3, NSEC_PER_SEC)];
	}
}
-(void)setVolume:(float)vol{
    NSArray *audioTracks = [player.currentItem.asset tracksWithMediaType:AVMediaTypeAudio];
    
    NSMutableArray *allAudioParams = [NSMutableArray array];
    for (AVAssetTrack *track in audioTracks) {
        AVMutableAudioMixInputParameters *audioInputParams =[AVMutableAudioMixInputParameters audioMixInputParameters];
        [audioInputParams setVolume:volume atTime:kCMTimeZero];
        [audioInputParams setTrackID:[track trackID]];
        [allAudioParams addObject:audioInputParams];
    }
    AVMutableAudioMix *audioZeroMix = [AVMutableAudioMix audioMix];
    [audioZeroMix setInputParameters:allAudioParams];    
	
	[[[self player] currentItem] setAudioMix:audioZeroMix];
}

-(void)syncButtons{
	;//subclass this
}
-(void)setTimeObserverWithTolerance:(float)tolerance{
	mTimeObserver = [[self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:
					  ^(CMTime time) {
						  //NSLog(@"time: %f",CMTimeGetSeconds(time));
						  if (CMTimeGetSeconds(time) && !startedActualPlayback) {
							  startedActualPlayback=YES;
							  [self stopSpinner];
							  if ([delegate respondsToSelector:@selector(cdaMoviePlayerViewActualPlaybackDidStart:)]) [delegate cdaMoviePlayerViewActualPlaybackDidStart:self];
							  if (isFadingInOnActualStart) [self fadeInWithDuration:fadeInDuration];
						  }
						  [self timeUpdated:time];
					  }] retain];
}
-(void)removeTimeObserver{
	if (mTimeObserver){
		[self.player removeTimeObserver:mTimeObserver];
		CDA_RELEASE_SAFELY(mTimeObserver);
	}
}
#pragma mark effects:
-(void)setFadesInOnStart:(BOOL)fadesIn fadesInVolume:(BOOL)fadesInVolume duration:(NSTimeInterval)d{
	isFadingIn=fadesIn;
	isFadingInVolume=fadesInVolume;
	fadeInDuration=d;
	
}
-(void)setFadesInOnActualStart:(BOOL)fadesIn fadesInVolume:(BOOL)fadesInVolume duration:(NSTimeInterval)d{
	isFadingInOnActualStart=fadesIn;
	isFadingInVolumeOnActualStart=fadesInVolume;
	fadeInDuration=d;
	
}

-(void)setFadesOutOnEnd:(BOOL)fadesOut fadesoutVolume:(BOOL)fadesOutVolume duration:(NSTimeInterval)d{
	isFadingOut=fadesOut;
	isFadingOutVolume=fadesOutVolume;
	fadeOutDuration=d;
}

-(void)cancelFadesInAndOut{
	isFadingIn=NO;
	isFadingOut=NO;
	isFadingInVolume=NO;
	isFadingOutVolume=NO;
}

-(void)fadeInWithDuration:(NSTimeInterval)d{
	if ([delegate respondsToSelector:@selector(cdaMoviePlayerViewWillFadeIn:)]) [delegate cdaMoviePlayerViewWillFadeIn:self];
	if (self.alpha==1.0f) [self setAlpha:0.0];
	[UIView animateWithDuration:d
						  delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 self.alpha=1.0f; 
						 
					 } completion:^(BOOL finished){
						 if ([delegate respondsToSelector:@selector(cdaMoviePlayerViewDidFadeIn:)]) [delegate cdaMoviePlayerViewDidFadeIn:self];
					 }
	 ];
}
 -(void)fadeOutWithDuration:(NSTimeInterval)d{

	 if ([delegate respondsToSelector:@selector(cdaMoviePlayerViewWillFadeOut:)]) [delegate cdaMoviePlayerViewWillFadeOut:self];
	 [UIView animateWithDuration:d
						   delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
					  animations:^{
						 self.alpha=0.0f; 
						  
					  } completion:^(BOOL finished){
						  	 if ([delegate respondsToSelector:@selector(cdaMoviePlayerViewDidFadeOut:)]) [delegate cdaMoviePlayerViewDidFadeOut:self];
					  }
	  ];
}

#pragma mark Observations
- (void)observeValueForKeyPath:(NSString*)path ofObject:(id) object change:(NSDictionary*)change context:(void*)context
{
	if (context == cdaPlayerPlaybackViewRateObservationContext)
	{
		dispatch_async(dispatch_get_main_queue(),
					   ^{
						   [self syncButtons];
						   //CDA_LOG_METHOD_NAME;
						   if (!self.isPlaying && self.moviesArray) {
							   
							   if([self playNextMovieInArray]){
								   
								   if ([delegate respondsToSelector:@selector(cdaMoviePlayerViewDidFinishMovieInQueue:)]) [delegate cdaMoviePlayerViewDidFinishMovieInQueue:self];
								   return;//we don't want to fade out when there is more movies
							   }else {

								   if ([delegate respondsToSelector:@selector(cdaMoviePlayerViewDidFinishQueue:)]) [delegate cdaMoviePlayerViewDidFinishQueue:self];
							   }

						   }
						   if ((!self.isPlaying) && !self.isPaused && isFadingOut ) {
                               [self fadeOutWithDuration:fadeOutDuration];   
                           }
                           if (!self.isPlaying && !self.isPaused && startedActualPlayback ) {
                               if ([delegate respondsToSelector:@selector(cdaMoviePlayerViewDidFinishedPlayback:)]) [delegate cdaMoviePlayerViewDidFinishedPlayback:self];
                           }
						   
						  
					   });
	}
	else if (context == cdaPlayerPlaybackViewDurationObservationContext)
	{
		dispatch_async(dispatch_get_main_queue(),
					   ^{
						   
						  // CDA_LOG_METHOD_NAME;
					   });
	}
	else
		[super observeValueForKeyPath:path ofObject:object change:change context:context];
}
@end
