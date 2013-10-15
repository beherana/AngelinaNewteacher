    //
//  cdaMoviePlayerViewController.m
//  demoVideo
//
//  Created by Radif Sharafullin on 2/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cdaMoviePlayerViewController.h"
#import "cdaGlobalFunctions.h"


@implementation cdaMoviePlayerViewController
@synthesize showsAndHidesTransportControlsOnTouch,
delegate,
volume,
isPlaying,
moviePath,
movieURL,
duration,
currentPosition,
isPlayingArray,
currentlyPlayingMovieInArray,
showsSpinnerWhenLoadingMovie,
spinnerStyle;
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	player=[cdaMoviePlayerControlledView newPlayerOnView:self.view];
	[player setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
	
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	CDA_RELEASE_SAFELY(player);
    [super dealloc];
}

#pragma mark Player support

-(void)fadeInTransportControls{
	[player fadeInTransportControls];
}
-(void)fadeOutTransportControls{
	[player fadeOutTransportControls];
}
-(BOOL)isScrubbing{
	return [player isScrubbing];
}
-(void)setTransportControlsHidden:(BOOL)hidden{
	[player setTransportControlsHidden:hidden];
}


-(id)initWithContentsOfFile:(NSString *)movPath{
	self=[[self class]new];
	if (self) {
		[self setMoviePath:movPath];
	}
	
	
	return self;
}
-(id)initWithContentsOfURL:(NSURL *)movURL{
	self=[[self class]new];
	if (self) {
		[self setMovieURL:movURL];
	}
	
	
	return self;	
}
-(void)setMoviePath:(NSString *)mp{
	[player setMoviePath:mp];
}
-(void)setMovieURL:(NSURL *)mu{

	[player setMovieURL:mu];
}
//playing
-(void)playMoviesInArray:(NSArray *)movies{
	[player playMoviesInArray:movies];
}
-(void)playMoviesInPlist:(NSString *)plistPath{
	[player playMoviesInPlist:plistPath];
}
-(void)playMovieWithContentsOfPath:(NSString *)movPath{
	[player playMovieWithContentsOfPath:movPath];
}
-(void)playMovieWithContentsOfURL:(NSURL *)movURL{
	[player playMovieWithContentsOfURL:movURL];
}


-(void)setShowsSpinnerWhenLoadingMovie:(BOOL)showsSpinner{
	[player setShowsSpinnerWhenLoadingMovie:showsSpinner];
}
-(BOOL)showsSpinnerWhenLoadingMovie{
	return [player showsSpinnerWhenLoadingMovie];
}
-(void)setSpinnerStyle:(UIActivityIndicatorViewStyle)sStyle{
	[player setSpinnerStyle:spinnerStyle];
}
-(UIActivityIndicatorViewStyle)spinnerStyle{
	return [player spinnerStyle];
}

-(int)currentlyPlayingMovieInArray{
	return [player currentlyPlayingMovieInArray];
}
-(void)play{
	[player play];
}
-(void)pause{
	[player pause];
}
-(void)stop{
	[player stop];
}
-(void)setDelegate:(id<NSObject, cdaMoviePlayerViewDelegate>)del{
	[player setDelegate:del];
}
-(void)cancelMoviesInArrayPlayback{
	[player cancelMoviesInArrayPlayback];
}

//getters
-(NSTimeInterval)duration{
	return [player duration];
}
-(NSTimeInterval)currentPosition{
	return [player currentPosition];

}
-(float)volume;//currently not working!
{
	return [player volume];
}
-(BOOL)isPlaying{
	return [player isPlaying];
}
-(BOOL)isPlayingArray{
	return [player isPlayingArray];
}
-(NSString *)moviePath;//returns the movie path of the currently playing media
{
	return [player moviePath];
}
-(NSURL *)movieURL;//returns the movie URL of the currently playing media
{
	return [player movieURL];
}

//setters
-(void)setCurrentPosition:(NSTimeInterval)pos{
	[player setCurrentPosition:pos];
}
-(void)scrubToEnd{
	[player scrubToEnd];
}
-(void)setVolume:(float)vol;//currently not working!
{
	[player setVolume:vol];
}

//effects:
-(void)setFadesInOnStart:(BOOL)fadesIn fadesInVolume:(BOOL)fadesInVolume duration:(NSTimeInterval)d{
	[player setFadesInOnStart:fadesIn fadesInVolume:fadesInVolume duration:d];
}
-(void)setFadesInOnActualStart:(BOOL)fadesIn fadesInVolume:(BOOL)fadesInVolume duration:(NSTimeInterval)d{
	[player setFadesInOnActualStart:fadesIn fadesInVolume:fadesInVolume duration:d];
}
-(void)setFadesOutOnEnd:(BOOL)fadesOut fadesoutVolume:(BOOL)fadesOutVolume duration:(NSTimeInterval)d{
	[player setFadesInOnStart:fadesOut fadesInVolume:fadesOutVolume duration:d];
}
-(void)cancelFadesInAndOut{
	[player cancelFadesInAndOut];
}

-(void)fadeInWithDuration:(NSTimeInterval)d{
	[player fadeInWithDuration:d];
}
-(void)fadeOutWithDuration:(NSTimeInterval)d{
	[player fadeOutWithDuration:d];
}
-(void)stopSpinner{
	[player stopSpinner];
}

@end
