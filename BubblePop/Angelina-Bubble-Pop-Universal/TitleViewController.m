//
//  TitleViewController.m
//  Angelina-Bubble-Pop-Universal
//
//  Created by Karl Söderström on 2011-08-19.
//  Copyright 2011 Commind AB. All rights reserved.
//

#import "TitleViewController.h"
#import "AngelinaScene.h"
#import "TitleScene.h"
#import "AudioHelper.h"
#import "GameState.h"
#import "GameParameters.h"
#import "Animations.h"
#import "cdaAnalytics.h"

#define BubblePopClassicFirstTimeUserDefault @"BubblePopClassicFirstTime"
#define BubblePopClockFirstTimeUserDefault @"BubblePopClockFirstTime"

@interface PlayerView : UIView {
}
@property (nonatomic, retain) AVPlayer *player;
@end

@implementation PlayerView
+ (Class)layerClass {
    return [AVPlayerLayer class];
}
- (AVPlayer*)player {
    return [(AVPlayerLayer *)[self layer] player];
}
- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}
@end


@implementation TitleViewController

@synthesize tabs = _tabs;
@synthesize classicFirstTime = _classicFirstTime;
@synthesize clockFirstTime = _clockFirstTime;
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.classicFirstTime = [[NSUserDefaults standardUserDefaults] boolForKey:BubblePopClassicFirstTimeUserDefault];              
        
        self.clockFirstTime = [[NSUserDefaults standardUserDefaults] boolForKey:BubblePopClockFirstTimeUserDefault]; 
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    for (UIView *v in self.view.subviews) {
        v.exclusiveTouch = YES;
    }
    
    btnAudio.selected = ![AudioHelper audioIsEnabled];
    
#ifdef ANGELINA_BUBBLE_POP_INAPP
    btnAudio.hidden = YES;
    moreAppsButton.hidden = YES;
    infoButton.hidden = YES;
    btnHowto.hidden = YES;
    imgVerticalRule.hidden = YES;
    btnClassic.hidden = YES;
    btnClock.hidden = YES;
    startBubbleView.hidden = YES;
    btnHome.hidden = NO;
    
    /*
    UITapGestureRecognizer *gestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnClassicAction:)] autorelease];
    [startBubbleView addGestureRecognizer:gestureRecognizer];
    */
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"InTheSpotlight_Title" withExtension:@"mp4"];
    AVPlayer *player = [AVPlayer playerWithURL:url];
    player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    PlayerView *playerView = [[[PlayerView alloc] initWithFrame:self.view.frame] autorelease];
    playerView.player = player;
    playerView.alpha = 0.0;
    
    [self.view addSubview:playerView];
    [self.view sendSubviewToBack:playerView];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(playerItemDidReachEnd:)
     name:AVPlayerItemDidPlayToEndTimeNotification
     object:[player currentItem]];
    
    [UIView animateWithDuration:0.2 animations:^{
        playerView.alpha = 1.0;
    }];
    
    [player play];
    
    
#endif // ANGELINA_BUBBLE_POP_INAPP
    
    
    [self performSelector:@selector(playAnimation) withObject:nil afterDelay:1.0];
}

- (void)playAnimation
{
    [[Animations sharedInstance] startAnimation:@"Angelina_WillYouHelpMe" onNode:[AngelinaScene getCurrent].angelina]; 
}
             
- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *item = notification.object;
    [item seekToTime:kCMTimeZero];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [btnAudio release];
    btnAudio = nil;
    if (self.tabs != nil) {
        [self.tabs.view removeFromSuperview];
        self.tabs = nil;
    }
    
    [moreAppsButton release];
    moreAppsButton = nil;
    [infoButton release];
    infoButton = nil;
    [btnHowto release];
    btnHowto = nil;
    [imgVerticalRule release];
    imgVerticalRule = nil;
    [btnClassic release];
    btnClassic = nil;
    [btnClock release];
    btnClock = nil;
    [btnHome release];
    btnHome = nil;
    [startBubbleView release];
    startBubbleView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (IBAction)btnHowtoAction:(id)sender {
    [[cdaAnalytics sharedInstance] trackEvent:@"How-To" inCategory:flurryEventPrefix(@"Landing Page") withLabel:@"tap" andValue:-1];
    
    self.view.userInteractionEnabled = NO;

    UIButton *button = (UIButton *)sender;
    [button removeTarget:self action:@selector(btnHowtoAction:) forControlEvents:UIControlEventTouchUpInside];
    
    TitleScene *title = (TitleScene *)[[CCDirector sharedDirector].runningScene getChildByTag:ANGELINA_TITLE_TAG];
    [title unscheduleAllSelectors];
    [title popAllBubbles];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0e9*0.2)), dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:0.2 animations:^(void) {
            self.view.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
        }];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:AngelinaGame_TutorialStarted object:self];
    });
}

- (IBAction)btnAudioAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    if (button.selected) {
        [[cdaAnalytics sharedInstance] trackEvent:@"Sound button" inCategory:flurryEventPrefix(@"Landing Page") withLabel:@"tap" andValue:-1];

        [AudioHelper disableAudio];
    } else {
        [[cdaAnalytics sharedInstance] trackEvent:@"Sound button" inCategory:flurryEventPrefix(@"Landing Page") withLabel:@"tap" andValue:-1];

        [AudioHelper enableAudio];
    }
}

- (void)launchGame {
    
    [GameParameters reset];
    
    TitleScene *title = (TitleScene *)[[CCDirector sharedDirector].runningScene getChildByTag:ANGELINA_TITLE_TAG];
    [title unscheduleAllSelectors];
    [title popAllBubbles];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0e9*0.2)), dispatch_get_main_queue(), ^(void){
        [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.4 scene:[AngelinaScene scene]]];
        [UIView animateWithDuration:0.2 animations:^(void) {
            self.view.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
        }];
    });
}

- (IBAction)btnClassicAction:(id)sender {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[cdaAnalytics sharedInstance] trackEvent:@"Classic" inCategory:flurryEventPrefix(@"Landing Page") withLabel:@"tap" andValue:-1];
    
    [[cdaAnalytics sharedInstance] trackEvent:@"Classic" inCategory:flurryEventPrefix(@"vs. Landing Page Game Mode") withLabel:@"mode" andValue:-1];
    self.view.userInteractionEnabled = NO;
    
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        [button removeTarget:self action:@selector(btnClassicAction:) forControlEvents:UIControlEventTouchUpInside];
    }
#ifdef ANGELINA_BUBBLE_POP_INAPP
    [[Animations sharedInstance] startAnimation:@"Angelina_Start" onNode:nil];
#else // ANGELINA_BUBBLE_POP_INAPP
    [[Animations sharedInstance] startAnimation:@"Angelina_Classic" onNode:nil];
#endif // ANGELINA_BUBBLE_POP_INAPP
    
    [GameState sharedInstance].gameMode = AngelinaGameMode_Classic;

    if (self.classicFirstTime) {
        [self launchGame];
    }
    else {
        TitleScene *title = (TitleScene *)[[CCDirector sharedDirector].runningScene getChildByTag:ANGELINA_TITLE_TAG];
        [title unscheduleAllSelectors];
        [title popAllBubbles];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0e9*0.2)), dispatch_get_main_queue(), ^(void){
            [UIView animateWithDuration:0.2 animations:^(void) {
                self.view.alpha = 0.0;
            } completion:^(BOOL finished) {
                [self.view removeFromSuperview];
            }];
            
            NSDictionary *info = [NSDictionary dictionaryWithObject:@"Classic" forKey:@"GameType"];
            [[NSNotificationCenter defaultCenter] postNotificationName:AngelinaGame_TutorialStarted object:self userInfo:info];
            
        });
        
        self.classicFirstTime = YES;
        [[NSUserDefaults standardUserDefaults] setBool:self.classicFirstTime forKey:BubblePopClassicFirstTimeUserDefault];
        [[NSUserDefaults standardUserDefaults] synchronize];

    }
    
}

- (IBAction)btnClockAction:(id)sender {
    [[cdaAnalytics sharedInstance] trackEvent:@"Beat the Clock" inCategory:flurryEventPrefix(@"Landing Page") withLabel:@"tap" andValue:-1];
    [[cdaAnalytics sharedInstance] trackEvent:@"Beat the Clock" inCategory:flurryEventPrefix(@"vs. Landing Page Game Mode") withLabel:@"mode" andValue:-1];

    self.view.userInteractionEnabled = NO;
    
    UIButton *button = (UIButton *)sender;
    [button removeTarget:self action:@selector(btnClockAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [[Animations sharedInstance] startAnimation:@"Angelina_BeatTheClock" onNode:nil];
    
    [GameState sharedInstance].gameMode = AngelinaGameMode_Clock;

    
    if (self.clockFirstTime) {
        [self launchGame];
    }
    else {
        TitleScene *title = (TitleScene *)[[CCDirector sharedDirector].runningScene getChildByTag:ANGELINA_TITLE_TAG];
        [title unscheduleAllSelectors];
        [title popAllBubbles];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0e9*0.2)), dispatch_get_main_queue(), ^(void){
            [UIView animateWithDuration:0.2 animations:^(void) {
                self.view.alpha = 0.0;
            } completion:^(BOOL finished) {
                [self.view removeFromSuperview];
            }];
            
            NSDictionary *info = [NSDictionary dictionaryWithObject:@"Clock" forKey:@"GameType"];
            [[NSNotificationCenter defaultCenter] postNotificationName:AngelinaGame_TutorialStarted object:self userInfo:info];
            
        });
        
        self.clockFirstTime = YES;
        [[NSUserDefaults standardUserDefaults] setBool:self.clockFirstTime forKey:BubblePopClockFirstTimeUserDefault];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

- (IBAction)btnTabsAction:(id)sender {
    //create the tabs when clicked
    if (self.tabs == nil) {
        self.tabs = [[[BubblePopLandingPageTabsViewController alloc] initWithNibName:@"LandingPageTabsViewController" bundle:nil] autorelease];
        [self.tabs setDelegate:self];
        [self.view addSubview:self.tabs.view];

    }

    //open the specific tab - both in same controller
    if (sender == infoButton) {
        [[cdaAnalytics sharedInstance] trackEvent:@"Information" inCategory:flurryEventPrefix(@"Landing Page") withLabel:@"tap" andValue:-1];
        [self.tabs btnInfoTabAction:nil];
    }
    else if (sender == moreAppsButton) {
        [[cdaAnalytics sharedInstance] trackEvent:@"Other Apps" inCategory:flurryEventPrefix(@"Landing Page") withLabel:@"tap" andValue:-1];
        [self.tabs btnMoreAppsTabAction:nil];
    }
}

- (IBAction)btnHomeAction:(id)sender {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (self.delegate != nil) {
        [self.delegate bubblePopHomeButtonPressed];
    }
}

- (void)tabDismissed {
    [infoButton setHidden:NO];
    [moreAppsButton setHidden:NO];
    
    self.tabs.delegate = nil;
    [self.tabs.view removeFromSuperview];
    self.tabs = nil;
}


- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [btnAudio release];
    self.tabs = nil;
    
    [moreAppsButton release];
    [infoButton release];
    [btnHowto release];
    [imgVerticalRule release];
    [btnClassic release];
    [btnClock release];
    [btnHome release];
    [startBubbleView release];
    [super dealloc];
}

@end
