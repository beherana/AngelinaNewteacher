//
//  PopoverImage.h
//  Angelina-New-Teacher-Universal
//
//  Created by Karl Söderström on 2011-05-24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <MediaPlayer/MediaPlayer.h>
#import "cdaMoviePlayerView.h"

@interface PopoverImageViewController : UIViewController <AVAudioPlayerDelegate,cdaMoviePlayerViewDelegate>{
    IBOutlet UIView *overlayView;
    IBOutlet UIView *contentView;
    IBOutlet UIImageView *textContentImageView;
    IBOutlet UIImageView *bgImageView;
    
    //Animations
    cdaMoviePlayerView *moviePlayer;
    IBOutlet UIView *movieFrameSize;
    IBOutlet UIView *moviePlayerView;
    IBOutlet UIImageView *movieStillImage;

    IBOutlet UIImageView *refreshImage;
    IBOutlet UIButton *refreshBtn;
    IBOutlet UIButton *repeatAnimationButton;
    IBOutlet UIButton *closeButton;
    //MPMoviePlayerController *moviePlayer;
    //cdaMoviePlayerView *moviePlayer;
    NSURL *mMovieURL;
    
	IBOutlet UIActivityIndicatorView *preLoadMovieActivityIndicator;
	
	NSTimer *checkEnd;
	
	float movieDuration;
	float movieCounter;    
    
@private
    NSString *_filePath;
    CGPoint _sourcePosition;
    AVAudioPlayer *_player;
    NSDictionary *_popover;
    BOOL _forceNarration;
    BOOL _forceRemoveNarration;
}

//@property (nonatomic, retain) 
@property (nonatomic, retain) cdaMoviePlayerView *moviePlayer;
@property (nonatomic, retain) NSTimer *checkEnd;
@property (nonatomic, assign) BOOL forceNarration;
@property (nonatomic, retain) UIButton *closeButton;
@property (nonatomic, retain) UIView *contentView;
@property (nonatomic, retain) UIImageView *bgImageView;
//@property (nonatomic, assign) BOOL forceRemoveNarration;

- (id)initWithImageFilePath:(NSString *)filePath withSourcePosition:(CGPoint)position;
- (void)showPopover:(BOOL)animated;
- (IBAction)closeButtonAction;
- (void)stopAudio;
- (void)playAudio;
- (void)stopAV;

@end
