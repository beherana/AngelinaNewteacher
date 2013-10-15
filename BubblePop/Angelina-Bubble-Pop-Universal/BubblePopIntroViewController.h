//
//  IntroViewController.h
//  Angelina-Bubble-Pop-Universal
//
//  Created by Karl Söderström on 2011-08-23.
//  Copyright 2011 Commind AB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>


@interface BubblePopIntroViewController : UIViewController {
@private
    MPMoviePlayerController *_player;
}

@property (nonatomic, retain) MPMoviePlayerController *player;

- (void)play;

@end
