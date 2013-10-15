    //
//  WatchViewController.m
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/15/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import "WatchViewController.h"
#import "Angelina_AppDelegate.h"
//#import "CDAudioManager.h"

@interface WatchViewController (PrivateMethods) 
-(void) playMovieAtURL:(NSString*)moviepath;
-(void) movieDone;
@end
@interface MPMoviePlayerController (airplay)
-(void)setAllowsAirPlay:(BOOL)allows;

@end


@implementation WatchViewController

@synthesize moviePlayer;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

/*- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}*/

-(void) initWithParent: (id) parent
{
	self=[super init];
	if (self){
		myParent=parent;
	}
	return;
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/
-(id) init:(NSString *)moviepath{
    mMoviepath = moviepath;
    return self;
}
-(void) playMovieAtURL:(NSString*)moviepath {
	//NSLog(@"movie started");
	movieEndedByItself = NO;
	
    //[[CDAudioManager sharedManager] audioSessionInterrupted];
    
	MPMoviePlayerController *mp =[[MPMoviePlayerController alloc] init];
    
	NSString *cleanpath = [[NSBundle mainBundle] pathForResource:moviepath ofType: @"mp4"];
    NSString *path = [Angelina_AppDelegate getLocalizedAssetName:cleanpath];
	
	if (mp)
	{		
		// save the movie player object
		self.moviePlayer = mp;
		[mp release];
		self.moviePlayer.backgroundView.backgroundColor = [UIColor blackColor];
		// set the movie content
		[self.moviePlayer setContentURL:[NSURL fileURLWithPath: path]];
		self.moviePlayer.shouldAutoplay = NO;
		
		if ([self.moviePlayer respondsToSelector:@selector(setAllowsAirPlay:)]) [self.moviePlayer setAllowsAirPlay:YES];
		
		//fullscreen
		if ([[[Angelina_AppDelegate get] currentRootViewController] getIPhoneMode]) {
			CGRect scaleup = CGRectMake(self.view.bounds.origin.x-25, self.view.bounds.origin.y-30, self.view.bounds.size.width+50, self.view.bounds.size.height+40);
			self.moviePlayer.view.frame = scaleup;
            
			self.moviePlayer.view.frame = self.view.bounds;			
			
		} else {
			self.moviePlayer.view.frame = self.view.bounds;
		}
		
		
		
		
		// make sure the movie resizes when the parentView adjusts (due to rotation)
		self.moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		// Add view to parentview to give a frame to movie within the view
		[self.view addSubview:self.moviePlayer.view];
		
		
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(myMovieFinishedCallback:) 
													 name:MPMoviePlayerPlaybackDidFinishNotification 
												   object:self.moviePlayer]; 
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(myMoviePreloadState:) 
													 name:MPMoviePlayerLoadStateDidChangeNotification 
												   object:self.moviePlayer];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(exitFullScreenCloseMovie:) 
													 name:MPMoviePlayerDidExitFullscreenNotification 
												   object:self.moviePlayer];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(enterFullScreenMovie:) 
													 name:MPMoviePlayerWillEnterFullscreenNotification
												   object:self.moviePlayer];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(enterFullScreenMovie:) 
													 name:MPMoviePlayerDidEnterFullscreenNotification
												   object:self.moviePlayer];
		
		
		self.moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
		//self.moviePlayer.controlStyle = MPMovieControlStyleDefault;
		[self.moviePlayer setFullscreen:NO];

		//Radif set it to yes. The cocos sounds were disappearing if it is set to no.
		self.moviePlayer.useApplicationAudioSession = YES;
		
		[self.view bringSubviewToFront:exitmovie];
		
		
		
		
	}
	
	
}
-(void)enterFullScreenMovie:(NSNotification*)aNotification {
    if (movieEndedByItself == NO) {
        movieShouldStayPaused = YES;
    }
	self.moviePlayer.fullscreen=NO;
}
-(void)exitFullScreenCloseMovie:(NSNotification*)aNotification {
	if (movieEndedByItself == NO && !movieShouldStayPaused) {
		[self.moviePlayer play];
	}
}

-(void)myMoviePreloadState:(NSNotification*)aNotification {
	if ( (self.moviePlayer.loadState & MPMovieLoadStatePlayable) == MPMovieLoadStatePlayable && self.moviePlayer.playbackState == MPMoviePlaybackStateStopped) {
	//if ( (self.moviePlayer.loadState & MPMovieLoadStatePlayable) == MPMovieLoadStatePlayable && self.moviePlayer.playbackState == MPMoviePlaybackStateStopped) {
		
		self.moviePlayer=[aNotification object]; 
		[[NSNotificationCenter defaultCenter] removeObserver:self 
														name:MPMoviePlayerNowPlayingMovieDidChangeNotification 
													  object:self.moviePlayer];
		[self.moviePlayer play];
		
		exitmovie.hidden = NO;
		
		
		//hiding the fullscreen button
		/*
		CGRect maskFrame=CGRectMake(self.moviePlayer.view.frame.size.width-60, self.moviePlayer.view.frame.size.height-30, 60, 30);
		//maskFrame=[self.moviePlayer.view convertRect:maskFrame toView:self.view];
		UIView *maskView=[[[UIView alloc]initWithFrame:maskFrame]autorelease];
		maskView.backgroundColor=[UIColor blackColor];
		[self.moviePlayer.view addSubview:maskView];
		*/
		
	}
}

// When the movie is done,release the controller. 
-(void)myMovieFinishedCallback:(NSNotification*)aNotification {
	//NSLog(@"This means I'm calling movieDone twice");
    NSLog(@"myMovieFinishedCallback");

    
	moviePlayer=[aNotification object]; 
	[[NSNotificationCenter defaultCenter] removeObserver:self ]; 
	movieEndedByItself = YES;
	//[self movieDone];
    //[NSTimer scheduledTimerWithTimeInterval:0.7 target:self selector:@selector(movieDone) userInfo:nil repeats:NO];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.7];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(movieDone)];
    self.moviePlayer.view.alpha = 0.0;
    [UIView commitAnimations];
}

-(IBAction)exitWatchMovie:(id)sender {

    NSLog(@"exitWatchMovie");
	//[[Angelina_AppDelegate get].myRootViewController playFXEventSound:@"mainmenu"];

	//[self.moviePlayer pause];
	//[self.moviePlayer stop];
	[self movieDone];
    //[[CDAudioManager sharedManager] audioSessionResumed];
}

-(void)movieDone {
    if (self.moviePlayer != nil) {
        NSLog(@"movieDone");
        [[NSNotificationCenter defaultCenter] removeObserver:self ]; 
        [self.moviePlayer stop];
        //[self.moviePlayer.view removeFromSuperview];
        [self.view removeFromSuperview];
        [[Angelina_AppDelegate get].myRootViewController homeButtonHidden:NO];
        moviePlayer = nil;
        [moviePlayer release];
        [myParent releaseWatchViewController];
        //[[CDAudioManager sharedManager] audioSessionResumed];
        
        //[[Angelina_AppDelegate get] videoFinishedPlaying];
    }
    else {
        NSLog(@"movieDone called again!!!");
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[Angelina_AppDelegate get].myRootViewController homeButtonHidden:YES];
	//exitmovie.hidden = YES;
	[self playMovieAtURL:mMoviepath];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
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
	//[[NSNotificationCenter defaultCenter] removeObserver:self];
	//exitmovie = nil;
	//[exitmovie release];
	exitmovie = nil;
    [super dealloc];
}


@end
