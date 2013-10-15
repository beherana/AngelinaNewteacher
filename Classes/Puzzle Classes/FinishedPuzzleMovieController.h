//
//  WatchViewController.h
//  The Bird & The Snail
//
//  Created by Henrik Nord on 1/27/09.
//  Copyright 2009 Haunted House. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "jigsawViewController.h"

@interface FinishedPuzzleMovieController : UIViewController <UIApplicationDelegate> {
	
	jigsawViewController *myParent;
	
	MPMoviePlayerController *moviePlayer;
    NSURL *mMovieURL;
	
	IBOutlet UIActivityIndicatorView *preLoadMovieActivityIndicator;
	
	IBOutlet UIButton *returnButton;
	
	int theCurrentPuzzle;
	
	NSTimer *checkEnd;
	
	float movieDuration;
	float movieCounter;

}
//@property (readwrite, retain) MPMoviePlayerController *moviePlayer;
@property (nonatomic, retain) MPMoviePlayerController *moviePlayer;
@property (nonatomic, retain) NSTimer *checkEnd;

- (void) initWithParent: (id) parent;
-(void)stopMovie;

@end
