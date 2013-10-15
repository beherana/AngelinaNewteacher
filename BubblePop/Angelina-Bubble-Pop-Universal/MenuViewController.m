//
//  MenuViewController.m
//  Angelina-Bubble-Pop-Universal
//
//  Created by Karl Söderström on 2011-09-02.
//  Copyright (c) 2011 Commind AB. All rights reserved.
//

#import "MenuViewController.h"
#import "AudioHelper.h"
#import "AngelinaScene.h"
#import "Animations.h"
#import "GameState.h"
#import "cdaAnalytics.h"

@interface MenuViewController ()
@property (nonatomic, assign) BOOL willPause;
@property (nonatomic, assign) BOOL willResume;
@end

@implementation MenuViewController
@synthesize isShowing = _isShowing;
@synthesize willPause = _willPause;
@synthesize willResume = _willResume;
@synthesize icon = _icon;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)setAudioButtonEnabled:(BOOL)enable
{
    btnSound.hidden = !enable;
    btnSoundDisabled.hidden = enable;
}

- (void)enableButton:(UIButton *)button
{
    button.enabled = YES;
    button.alpha = 1.0;
}

- (void)disableButton:(UIButton *)button
{
    button.enabled = NO;
    button.alpha = 0.5;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGameOver:) name:AngelinaGame_GameOver object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGamePaused:) name:AngelinaGame_GamePaused object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGameResumed:) name:AngelinaGame_GameResumed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGameWillStart:) name:AngelinaGame_GameWillStart object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGameDidStart:) name:AngelinaGame_GameDidStart object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGameDidEnd:) name:AngelinaGame_GameDidEnd object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTutorialStarted:) name:AngelinaGame_TutorialStarted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTutorialEnded:) name:AngelinaGame_TutorialEnded object:nil];
    
    [self disableButton:btnContinue];
    [self disableButton:btnRestart];
    [self disableButton:btnQuit];
    
    [self setAudioButtonEnabled:[AudioHelper audioIsEnabled]];
    [self setIsShowing:NO animated:NO];
    [self setIcon:AngelinaGameMenuIcon_Star];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [imgIcon release];
    imgIcon = nil;
    [imgSubmenu release];
    imgSubmenu = nil;
    [btnContinue release];
    btnContinue = nil;
    [btnRestart release];
    btnRestart = nil;
    [btnQuit release];
    btnQuit = nil;
    [btnTutorial release];
    btnTutorial = nil;
    [btnSound release];
    btnSound = nil;
    [btnSoundDisabled release];
    btnSoundDisabled = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)handleGameDidEnd:(NSNotification *)notification
{
    self.willResume = NO;
    self.willPause = NO;
    [self disableButton:btnContinue];
    [self disableButton:btnRestart];
    [self disableButton:btnQuit];
    [self enableButton:btnTutorial];
}

- (void)handleGameOver:(NSNotification *)notification
{
    self.willResume = NO;
    self.willPause = NO;
    [self disableButton:btnContinue];
}

- (void)handleGamePaused:(NSNotification *)notification
{
    self.willResume = YES;
    self.willPause = NO;
}

- (void)handleGameResumed:(NSNotification *)notification
{
    self.willResume = NO;
    self.willPause = YES;
}

- (void)handleGameWillStart:(NSNotification *)notification
{
    self.view.userInteractionEnabled = NO;
}

- (void)handleGameDidStart:(NSNotification *)notification
{
    self.view.userInteractionEnabled = YES;
    self.willResume = NO;
    self.willPause = YES;
    [self enableButton:btnContinue];
    [self enableButton:btnRestart];
    [self enableButton:btnQuit];
}

- (void)handleTutorialStarted:(NSNotification *)notification
{
    self.willResume = NO;
    self.willPause = NO; 
    [self disableButton:btnContinue];
    [self disableButton:btnRestart];
    [self disableButton:btnTutorial];
    [self enableButton:btnQuit];
}

- (void)handleTutorialEnded:(NSNotification *)notification
{
    self.willResume = NO;
    self.willPause = NO;
    [self disableButton:btnQuit];
    [self enableButton:btnTutorial];
}

- (IBAction)btnToggleAction:(id)sender
{
    [self setIsShowing:!self.isShowing animated:YES];
    if (self.isShowing && self.willPause) {
        [[AngelinaScene getCurrent] pause];
        self.icon = AngelinaGameMenuIcon_Play;
    } else if (!self.isShowing && self.willResume) {
        [[AngelinaScene getCurrent] resume];
        self.icon = AngelinaGameMenuIcon_Pause;
    }
}

- (void)bringToFront
{
    [self.view.superview bringSubviewToFront:self.view];
}

- (void)setIsShowing:(BOOL)isShowing animated:(BOOL)animated
{
    CGFloat y = 0;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        y = isShowing ? 589 : 706;
    } else {
        y = isShowing ? 189 : 287;
    }
    if (animated) {
        if (isShowing != self.isShowing) {
            CGRect frame = self.view.frame;
            frame.origin.y = y;
            [UIView animateWithDuration:0.3 animations:^{
                self.view.frame = frame;                
            }];
        }
    } else {
        CGRect frame = self.view.frame;
        frame.origin.y = y;
        self.view.frame = frame;
    }
    self.isShowing = isShowing;
    
}

- (void)setIcon:(AngelinaGameMenuIcon)icon
{
    _icon = icon;
    NSString *file = nil;
    switch (icon) {
        case AngelinaGameMenuIcon_Star:
            file = @"submenu_star.png";
            break;
        case AngelinaGameMenuIcon_Play:
            file = @"submenu_play.png";
            break;
        case AngelinaGameMenuIcon_Pause:
            file = @"submenu_pause.png";
            break;
        default:
            break;
    }
    [imgSubmenu setImage:[UIImage imageNamed:file]];
}

- (IBAction)btnContinueAction:(id)sender {
    [[cdaAnalytics sharedInstance] trackEvent:@"continue" inCategory:flurryEventPrefix(@"Submenu") withLabel:@"tap" andValue:-1];
    
    [[Animations sharedInstance] startAnimation:@"Angelina_Continue" onNode:[AngelinaScene getCurrent].angelina];
    
    if (self.isShowing) {
        [self btnToggleAction:self];
    }
}

- (IBAction)btnRestartAction:(id)sender {
    [[cdaAnalytics sharedInstance] trackEvent:@"restart" inCategory:flurryEventPrefix(@"Submenu") withLabel:@"tap" andValue:-1];

    [[Animations sharedInstance] startAnimation:@"Angelina_Restart" onNode:[AngelinaScene getCurrent].angelina];
    [GameState sharedInstance].tutorialMode = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0e9*0.7)), dispatch_get_main_queue(), ^(void){
        if ([AngelinaScene getCurrent] != nil) {
            [[AngelinaScene getCurrent] reset];
            [[AngelinaScene getCurrent] resume];
        } else {
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.4 scene:[AngelinaScene scene]]];
        }
        [AudioHelper playBackgroundAudio:AngelinaGameAudio_GameMusic];
    });
}

- (IBAction)btnQuitAction:(id)sender {
    [[cdaAnalytics sharedInstance] trackEvent:@"quit" inCategory:flurryEventPrefix(@"Submenu") withLabel:@"tap" andValue:-1];

    [[Animations sharedInstance] startAnimation:@"Angelina_Quit" onNode:[AngelinaScene getCurrent].angelina];
    [GameState sharedInstance].tutorialMode = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:AngelinaGame_GameDidEnd object:self];
    [self setIsShowing:NO animated:YES];
}

- (IBAction)btnTutorialAction:(id)sender {
    [[cdaAnalytics sharedInstance] trackEvent:@"tutorial" inCategory:flurryEventPrefix(@"Submenu") withLabel:@"tap" andValue:-1];

    [[NSNotificationCenter defaultCenter] postNotificationName:AngelinaGame_TutorialStarted object:self userInfo:[NSDictionary dictionaryWithObject:@"Classic" forKey:@"GameType"]];
    [self setIsShowing:NO animated:YES];
}
     
- (IBAction)btnSoundAction:(id)sender {
    [[cdaAnalytics sharedInstance] trackEvent:@"sound" inCategory:flurryEventPrefix(@"Submenu") withLabel:@"tap" andValue:-1];

    BOOL enable = (sender == btnSoundDisabled);
    
    if (enable) {
        [AudioHelper enableAudio];
    } else {
        [AudioHelper disableAudio];
    }
    
    [self setAudioButtonEnabled:enable];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [imgIcon release];
    [imgSubmenu release];
    [btnContinue release];
    [btnRestart release];
    [btnQuit release];
    [btnTutorial release];
    [btnSound release];
    [btnSoundDisabled release];
    [super dealloc];
}
@end
