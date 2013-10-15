//
//  WatchViewController.h
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/15/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "WatchMainViewController.h"

@interface WatchViewController : UIViewController {

	MPMoviePlayerController *moviePlayer;
    NSURL *mMovieURL;
	NSString* mMoviepath;
    
	BOOL movieIsPlaying;
	
	BOOL movieEndedByItself;
    BOOL movieShouldStayPaused;
	WatchMainViewController *myParent;
	
	IBOutlet UIButton *exitmovie;
	
}

@property (readwrite, retain) MPMoviePlayerController *moviePlayer;

-(IBAction)exitWatchMovie:(id)sender;
- (id) init:(NSString*)moviepath;
- (void) initWithParent: (id) parent;
@end
