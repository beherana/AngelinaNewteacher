//
//  IntroViewController.h
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/15/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>


@interface IntroViewController : UIViewController {

	MPMoviePlayerController *moviePlayer;
    NSURL *mMovieURL;
	
	BOOL movieIsPlaying;
	
	BOOL movieEndedByItself;
	
	IBOutlet UIButton *exitmovie;
	
	
	NSTimer *checkEnd;
	
	float movieDuration;
	float movieCounter;
	
	BOOL forcedEnd;
	
}

@property (readwrite, retain) MPMoviePlayerController *moviePlayer;
@property (nonatomic, retain) NSTimer *checkEnd;

-(IBAction)exitWatchMovie:(id)sender;
//-(void)stopMovie;

@end
