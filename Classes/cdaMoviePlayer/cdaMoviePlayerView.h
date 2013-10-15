//
//  cdaMoviePlayerView.h
//
//  Created by Radif Sharafullin on 1/31/11.
//  Copyright 2011 Callaway Digital Arts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CMTime.h>
@class AVPlayer;
@class cdaMoviePlayerView;
@protocol cdaMoviePlayerViewDelegate

@optional

//Queue
/*!
 This delegate method is called after each movie in Queue is finished, before the next one is started. You can set the queue by calling -(void)playMoviesInArray:(NSArray *)movies
 */
-(void)cdaMoviePlayerViewDidFinishMovieInQueue:(cdaMoviePlayerView *)moviePlayerView;
/*!
This delegate method is called after the queue is done 
 */
-(void)cdaMoviePlayerViewDidFinishQueue:(cdaMoviePlayerView *)moviePlayerView;
//Playback
-(BOOL)cdaMoviePlayerViewShouldStartPlayback:(cdaMoviePlayerView *)moviePlayerView;
-(void)cdaMoviePlayerViewWillStartPlayback:(cdaMoviePlayerView *)moviePlayerView;
-(void)cdaMoviePlayerViewDidStartPlayback:(cdaMoviePlayerView *)moviePlayerView;
-(void)cdaMoviePlayerViewActualPlaybackDidStart:(cdaMoviePlayerView *)moviePlayerView;
//Pause
-(BOOL)cdaMoviePlayerViewShouldPausePlayback:(cdaMoviePlayerView *)moviePlayerView;
-(void)cdaMoviePlayerViewWillPausePlayback:(cdaMoviePlayerView *)moviePlayerView;
-(void)cdaMoviePlayerViewDidPausePlayback:(cdaMoviePlayerView *)moviePlayerView;
//Stop
-(BOOL)cdaMoviePlayerViewShouldStopPlayback:(cdaMoviePlayerView *)moviePlayerView;
-(void)cdaMoviePlayerViewDidStopPlayback:(cdaMoviePlayerView *)moviePlayerView finished:(BOOL)finished;
-(void)cdaMoviePlayerViewDidFinishedPlayback:(cdaMoviePlayerView *)moviePlayerView;
//Effects
-(void)cdaMoviePlayerViewWillFadeIn:(cdaMoviePlayerView *)moviePlayerView;
-(void)cdaMoviePlayerViewDidFadeIn:(cdaMoviePlayerView *)moviePlayerView;

-(void)cdaMoviePlayerViewWillFadeOut:(cdaMoviePlayerView *)moviePlayerView;
-(void)cdaMoviePlayerViewDidFadeOut:(cdaMoviePlayerView *)moviePlayerView;
@end


@interface cdaMoviePlayerView : UIView {
	float volume;
	NSTimeInterval fadeInDuration;
	NSTimeInterval fadeOutDuration;

	UIView *superView;
	BOOL showsSpinnerWhenLoadingMovie;
	
	NSString * moviePath;
	NSURL * movieURL;
	
	
	BOOL isPlayingArray;
	NSArray *moviesArray;
	int currentlyPlayingMovieInArray;
	
	AVPlayer* player;
	id <NSObject, cdaMoviePlayerViewDelegate> delegate;
	UIActivityIndicatorView *spinner;
	UIActivityIndicatorViewStyle spinnerStyle;
	id mTimeObserver;

@private
	BOOL startedActualPlayback;
	
	BOOL isFadingInVolumeOnActualStart;
	BOOL isFadingInOnActualStart;
	
	BOOL isFadingIn;
	BOOL isFadingOut;
	BOOL isFadingInVolume;
	BOOL isFadingOutVolume;

    BOOL isPaused;
}
@property (nonatomic, assign) UIView *superView;
@property (nonatomic, assign) id <NSObject, cdaMoviePlayerViewDelegate> delegate;
@property (nonatomic, retain) NSArray *moviesArray;
@property (nonatomic, readwrite) float volume;
@property (nonatomic, readonly) BOOL isPlaying;
@property (nonatomic, retain) NSString * moviePath;
@property (nonatomic, retain) NSURL * movieURL;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readwrite) NSTimeInterval currentPosition;
@property (nonatomic, readonly) BOOL isPlayingArray;
@property (nonatomic, readonly) int currentlyPlayingMovieInArray;
@property (nonatomic, assign) BOOL showsSpinnerWhenLoadingMovie;
@property (nonatomic, retain) AVPlayer* player;
@property (nonatomic, readwrite) UIActivityIndicatorViewStyle spinnerStyle;
@property (nonatomic) BOOL isPaused;


-(void)initPlayer;
-(void)trashPlayer;
/*!
 returns the current version
 */
+(float)cdaVersion;

//alloc methods

/*!
 returns an autoreleased object, adds player on top of view and sizes it to view's bounds
 */
+(id)playerOnView:(UIView *)view;
/*!
 you need to release this, adds player on top of view and sizes it to view's bounds
 */
+(id)newPlayerOnView:(UIView *)view;
/*!
 returns autoreleased object, adds player on top of view and sizes it to provided frame
 */
+(id)playerOnView:(UIView *)view frame:(CGRect)frame;
/*!
 you need to release this, adds player on top of view and sizes it to provided frame
 */
+(id)newPlayerOnView:(UIView *)view frame:(CGRect)frame;
/*!
 returns autoreleased object, adds player on top of view and sizes it to view's bounds, start playing array
 */
+(id)playMoviesInArray:(NSArray *)movies onView:(UIView *)view;
/*!
 returns autoreleased object, adds player on top of view and sizes it to view's bounds, start playing array from plist
 Array (plist) format:
 
 array of dictionaries:
 dictionary: key: "movie_path" or "movie_url"
 dictionary: key: "movie_frame" is optional. will set the frame in regards to it's superview
 */
+(id)playMoviesInPlist:(NSString *)plistPath onView:(UIView *)view;


-(void)setMoviePath:(NSString *)moviePath;
//playing
-(void)playMoviesInArray:(NSArray *)movies;
-(void)playMoviesInPlist:(NSString *)plistPath;
-(void)playMovieWithContentsOfPath:(NSString *)movPath;
-(void)playMovieWithContentsOfURL:(NSURL *)movURL;


-(void)setShowsSpinnerWhenLoadingMovie:(BOOL)showsSpinner;

-(void)play;
-(void)pause;
-(void)stop;
/*!
 this will cancel queue and make the currently playing movie the last in the queue. if you want to stop it as well, just call [stop]
 */
-(void)cancelMoviesInArrayPlayback;

//getters
/*!
 returns the duration of the currently playing movie in seconds
 */
-(NSTimeInterval)duration;
/*!
 returns the current position of the currently playing movie in seconds
 */
-(NSTimeInterval)currentPosition;
/*!
 currently not working!
 */
-(float)volume;
/*!
 returns yes if it is playing and no if it is paused or stopped
 */
-(BOOL)isPlaying;
/*!
 returns yes if the queue is playing
 */
-(BOOL)isPlayingArray;
/*!
 returns the movie path of the currently playing media
 */
-(NSString *)moviePath;



//setters

/*!
 set the position of the movie in seconds
 */
-(void)setCurrentPosition:(NSTimeInterval)pos;
/*!
 move to the end of the movie clip
 */
-(void)scrubToEnd;
/*!
 currently not working!
 */
-(void)setVolume:(float)vol;

//effects:
-(void)setFadesInOnStart:(BOOL)fadesIn fadesInVolume:(BOOL)fadesInVolume duration:(NSTimeInterval)duration;
-(void)setFadesInOnActualStart:(BOOL)fadesIn fadesInVolume:(BOOL)fadesInVolume duration:(NSTimeInterval)duration;
-(void)setFadesOutOnEnd:(BOOL)fadesOut fadesoutVolume:(BOOL)fadesOutVolume duration:(NSTimeInterval)duration;
-(void)cancelFadesInAndOut;

-(void)fadeInWithDuration:(NSTimeInterval)duration;
-(void)fadeOutWithDuration:(NSTimeInterval)duration;
-(void)stopSpinner;
//subclassing support
-(void)timeUpdated:(CMTime)time;
-(void)syncButtons;
-(void)setTimeObserverWithTolerance:(float)tolerance;
-(void)removeTimeObserver;
@end
