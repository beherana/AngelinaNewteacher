//
//  PopoverImage.m
//  Angelina-New-Teacher-Universal
//
//  Created by Karl Söderström on 2011-05-24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PopoverImageViewController.h"
#import "Angelina_AppDelegate.h"
#import "AVQueueManager.h"
#import "SimpleAudioEngine.h"

#define M_PI   3.14159265358979323846264338327950288   /* pi */

@interface PopoverImageViewController()
@property (nonatomic,copy) NSString *filePath;
@property (nonatomic) CGPoint sourcePosition;
@property (nonatomic,retain) AVAudioPlayer *player;
@property (nonatomic,retain) NSDictionary *popover;

- (void)handleAudioStoped:(NSNotification *)notification;
@end

@implementation PopoverImageViewController

@synthesize filePath = _filePath;
@synthesize sourcePosition = _sourcePosition;
@synthesize player = _player;
@synthesize popover = _popover;
@synthesize checkEnd;
@synthesize moviePlayer;
@synthesize forceNarration = _forceNarration;
@synthesize closeButton, contentView, bgImageView;
//@synthesize forceRemoveNarration = _forceRemoveNarration;

- (id)initWithImageFilePath:(NSString *)filePath withSourcePosition:(CGPoint)position
{
    self = [super initWithNibName:@"PopoverImage" bundle:nil];
    if (self) {
        self.filePath = filePath;
        //self.filePath = @"popover_7_Grand-Jete";
        self.sourcePosition = position;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:kAVManagerItemStoppedPlaying];
    [self.player stop];
    self.player = nil;
    self.filePath = nil;
    [self.moviePlayer stop];
    self.moviePlayer.delegate = nil;
    self.moviePlayer = nil;
    self.popover = nil;
    self.closeButton = nil;
    [textContentImageView release];
    [moviePlayerView release];
    [movieStillImage release];
    [bgImageView release];
    [movieFrameSize release];
    [refreshBtn release];
    [refreshImage release];
    [repeatAnimationButton release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)showPopover:(BOOL)animated
{
    if (animated) {
        float alpha = overlayView.alpha;
        overlayView.alpha = 0.0;
        contentView.transform = CGAffineTransformMakeScale(.01,.01);
        contentView.alpha = 0.0;
        
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"dance_twinkle.wav"];
        [[SimpleAudioEngine sharedEngine] playEffect:@"dance_twinkle.wav"];
        
        [UIView animateWithDuration:0.2// * 100
                              delay:0.0
                            options:UIViewAnimationCurveEaseOut
                         animations:^{
                             overlayView.alpha = alpha;
                             contentView.transform = CGAffineTransformMakeScale(1.1,1.1);
                             contentView.alpha = 1.0;
                         }
                         completion:^(BOOL completed) {
                             [UIView animateWithDuration:0.1// * 100
                                                   delay:0.0
                                                 options:UIViewAnimationCurveEaseOut
                                              animations:^{
                                                  contentView.transform = CGAffineTransformMakeScale(1.0,1.0);
                                              }
                                              completion:^(BOOL completed) {
                                                  [self.moviePlayer play];
                                                  self.moviePlayer.delegate = self;
                                              }]; 
                             
                         }
         ];
    }
    else {
     [self.moviePlayer play];
     self.moviePlayer.delegate = self;
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAudioStoped:) name:kAVManagerItemStoppedPlaying object:nil];
    
    NSDictionary *popoverList = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"popover" ofType:@"plist"]];
    self.popover = [popoverList objectForKey:self.filePath];
    
    
    //imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", self.filePath]];
    //load images
    textContentImageView.image = [UIImage imageNamed:[self.popover objectForKey:@"textImage"]];
    movieStillImage.image = [UIImage imageNamed:[self.popover objectForKey:@"startImageMovie"]];
    
    UITapGestureRecognizer *recognizer = 
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    [recognizer setNumberOfTouchesRequired:1];
    [overlayView addGestureRecognizer:recognizer];
    [recognizer release];
    
    //CGRect movieframe = CGRectMake(338.0, 97.0, 346.0, 254.0);
    
    [moviePlayerView setHidden:YES];
    //NSString *name = [NSString stringWithFormat:@"%@-movie", self.filePath];
    //NSURL *url = [[NSBundle mainBundle] URLForResource:name withExtension:@"mp4"];
    NSURL *url = [[NSBundle mainBundle] URLForResource:[self.popover objectForKey:@"movie"] withExtension:nil];
    
    self.moviePlayer = [cdaMoviePlayerView playerOnView:moviePlayerView frame:movieFrameSize.frame];
        
    //[self.moviePlayer setFadesOutOnEnd:YES fadesoutVolume:NO duration:0.5];
    self.moviePlayer.movieURL = url;
    
    // Mute movie if narration is turned off
    if (![[Angelina_AppDelegate get].currentRootViewController getNarrationValue]) {
        self.moviePlayer.volume = 0;
    }
    
    NSDictionary *refresh = [self.popover objectForKey:@"refreshBtn"];
    float x = [[refresh valueForKey:@"x"] floatValue];
    float y = [[refresh valueForKey:@"y"] floatValue];
    CGRect frame = CGRectMake(x - refreshImage.frame.size.width/2,
                              y - refreshImage.frame.size.height/2,
                              refreshImage.frame.size.width,
                              refreshImage.frame.size.height);
    refreshImage.frame = frame;
    refreshImage.hidden = YES;
    
    frame = CGRectMake(x - refreshBtn.frame.size.width/2,
                       y - refreshBtn.frame.size.height/2,
                       refreshBtn.frame.size.width,
                       refreshBtn.frame.size.height);
    refreshBtn.frame = frame;
    [refreshBtn setUserInteractionEnabled:NO];
    [repeatAnimationButton setUserInteractionEnabled:NO];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:kAVManagerItemStoppedPlaying];
    [textContentImageView release];
    textContentImageView = nil;
    [moviePlayerView release];
    moviePlayerView = nil;
    [movieStillImage release];
    movieStillImage = nil;
    [bgImageView release];
    bgImageView = nil;
    [movieFrameSize release];
    movieFrameSize = nil;
    [refreshBtn release];
    refreshBtn = nil;
    [refreshImage release];
    refreshImage = nil;
    [repeatAnimationButton release];
    repeatAnimationButton = nil;
    self.closeButton = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Animation

-(void)cdaMoviePlayerViewDidFinishedPlayback:(cdaMoviePlayerView *)moviePlayer {
    movieStillImage.image = [UIImage imageNamed:[self.popover objectForKey:@"endImageMovie"]];

    if (self.forceNarration || [[Angelina_AppDelegate get].currentRootViewController getNarrationValue]) {
        [self playAudio];
    } else {
        [self handleAudioStoped:nil];
    }
    [moviePlayerView setHidden:YES];
}

-(void)cdaMoviePlayerViewActualPlaybackDidStart:(cdaMoviePlayerView *)view {
    [moviePlayerView setHidden:NO];
}

#pragma mark - Audio

-(void)playAudio
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:[self.popover objectForKey:@"audio"]withExtension:nil];
    AVQueueItem *audioItem = [[AVQueueManager sharedAVQueueManager] enqueueAudioFileUrl:url withPrio:200 exclusive:YES userData:self.popover];
    [audioItem play];
}

-(void) stopAudio
{
    [[AVQueueManager sharedAVQueueManager] removeFromQueue:self.popover];
}

#pragma mark - Button callbacks

- (BOOL)alphaHitTest:(UIImage *)image withPoint:(CGPoint)point
{
    unsigned char pixel[1] = {0};
    CGContextRef context = CGBitmapContextCreate(pixel, 
                                                 1, 1, 8, 1, NULL,
                                                 kCGImageAlphaOnly);
    CGContextDrawImage(context, CGRectMake(-point.x, 
                                           -point.y, 
                                           CGImageGetWidth(image.CGImage), 
                                           CGImageGetHeight(image.CGImage)), 
                       image.CGImage);
    CGContextRelease(context);
    CGFloat alpha = pixel[0]/255.0;
    return alpha < 0.5;
}

- (void)backgroundTapped:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (CGRectContainsPoint(bgImageView.frame, [gestureRecognizer locationInView:self.view])) {
            if ([self alphaHitTest:bgImageView.image withPoint:[gestureRecognizer locationInView:bgImageView]]) {
                [self closeButtonAction];
            }
        } else {
            [self closeButtonAction];
        }
    }
}

- (void)handleAudioStoped:(NSNotification *)notification
{
    refreshImage.hidden = NO;
    [refreshBtn setUserInteractionEnabled:YES];
    [repeatAnimationButton setUserInteractionEnabled:YES];
    // Setup the animation
    CABasicAnimation *fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    fullRotation.fromValue = [NSNumber numberWithFloat:0];
    fullRotation.toValue = [NSNumber numberWithFloat:((360*M_PI)/180)];
    fullRotation.duration = 0.5;
    fullRotation.repeatCount = 2;
    [refreshImage.layer addAnimation:fullRotation forKey:@"360"];
}

//stop both audio and video
-(void) stopAV {
    self.moviePlayer.delegate = nil;
    [self.moviePlayer stop];
    [self.moviePlayer trashPlayer];
    [self stopAudio];  
}

- (IBAction)closeButtonAction
{
    [self stopAV];

    [UIView animateWithDuration:0.15// * 100
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         contentView.transform = CGAffineTransformMakeScale(1.1,1.1);
                         refreshImage.alpha = 0;
                     }
                     completion:^(BOOL completed) {
                         [UIView animateWithDuration:0.08// * 100
                                               delay:0.0
                                             options:UIViewAnimationCurveEaseIn
                                          animations:^{
                                              contentView.transform = CGAffineTransformMakeScale(.01,.01);
                                              contentView.alpha = 0.0;
                                              overlayView.alpha = 0.0;
                                          }
                                          completion:^(BOOL completed) {
                                              [[[Angelina_AppDelegate get]
                                                currentRootViewController]
                                               removePopoverImage];
                                          }];
                     }];
}

- (IBAction)repeatAction:(id)sender {
    refreshImage.hidden = YES;
    [refreshBtn setUserInteractionEnabled:NO];
    [repeatAnimationButton setUserInteractionEnabled:NO];
    
    self.forceNarration = YES;
    //self.forceRemoveNarration = NO;

    cdaMoviePlayerView *oldPlayer = [self.moviePlayer retain];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:[self.popover objectForKey:@"movie"] withExtension:nil];
    self.moviePlayer = [cdaMoviePlayerView playerOnView:moviePlayerView frame:movieFrameSize.frame];
    //[self.moviePlayer setFadesOutOnEnd:YES fadesoutVolume:NO duration:0.5];
    self.moviePlayer.delegate = self;
    self.moviePlayer.movieURL = url;
    [self.moviePlayer play];
    
    oldPlayer.delegate = nil;
    [oldPlayer stop];
    [oldPlayer trashPlayer];
    [oldPlayer release];
}

@end
