//
//  cdaMoviePlayerViewController.h
//  demoVideo
//
//  Created by Radif Sharafullin on 2/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cdaMoviePlayerControlledView.h"

@interface cdaMoviePlayerViewController : UIViewController {
	cdaMoviePlayerControlledView *player;
}
@property(nonatomic, assign) BOOL showsAndHidesTransportControlsOnTouch;
@property (nonatomic, assign) id <NSObject, cdaMoviePlayerViewDelegate> delegate;
@property (nonatomic, readwrite) float volume;
@property (nonatomic, readonly) BOOL isPlaying;
@property (nonatomic, retain) NSString * moviePath;
@property (nonatomic, retain) NSURL * movieURL;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readwrite) NSTimeInterval currentPosition;
@property (nonatomic, readonly) BOOL isPlayingArray;
@property (nonatomic, readonly) int currentlyPlayingMovieInArray;
@property (nonatomic, assign) BOOL showsSpinnerWhenLoadingMovie;
@property (nonatomic, readwrite) UIActivityIndicatorViewStyle spinnerStyle;


-(void)fadeInTransportControls;
-(void)fadeOutTransportControls;
-(BOOL)isScrubbing;
-(void)setTransportControlsHidden:(BOOL)hidden;

-(id)initWithContentsOfFile:(NSString *)movPath;
-(id)initWithContentsOfURL:(NSURL *)movURL;
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

-(void)cancelMoviesInArrayPlayback;

//getters
-(NSTimeInterval)duration;
-(NSTimeInterval)currentPosition;
-(float)volume;//currently not working!
-(BOOL)isPlaying;
-(BOOL)isPlayingArray;
-(NSString *)moviePath;//returns the movie path of the currently playing media


//setters
-(void)setCurrentPosition:(NSTimeInterval)pos;
-(void)scrubToEnd;
-(void)setVolume:(float)vol;//currently not working!

//effects:
-(void)setFadesInOnStart:(BOOL)fadesIn fadesInVolume:(BOOL)fadesInVolume duration:(NSTimeInterval)duration;
-(void)setFadesInOnActualStart:(BOOL)fadesIn fadesInVolume:(BOOL)fadesInVolume duration:(NSTimeInterval)duration;
-(void)setFadesOutOnEnd:(BOOL)fadesOut fadesoutVolume:(BOOL)fadesOutVolume duration:(NSTimeInterval)duration;
-(void)cancelFadesInAndOut;

-(void)fadeInWithDuration:(NSTimeInterval)duration;
-(void)fadeOutWithDuration:(NSTimeInterval)duration;
-(void)stopSpinner;
@end
