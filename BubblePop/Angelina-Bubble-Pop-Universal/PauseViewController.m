//
//  PauseViewController.m
//  Angelina-Bubble-Pop-Universal
//
//  Created by Karl Söderström on 2011-08-03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PauseViewController.h"
#import "AngelinaScene.h"
#import "AudioHelper.h"
#import "Animations.h"
#import "FlurryGameEvent.h"

@implementation PauseViewController

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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

#ifdef ANGELINA_BUBBLE_POP_INAPP
    btnContinue.hidden = YES;
    btnRestart.hidden = YES;
    btnQuit.hidden = YES;
    btnAudio.hidden = YES;
#endif // ANGELINA_BUBBLE_POP_INAPP
    
    [[Animations sharedInstance] startAnimation:@"Angelina_Pause" onNode:[AngelinaScene getCurrent].angelina];
    
    btnAudio.selected = ![AudioHelper audioIsEnabled];
    [AudioHelper pauseBackgroundAudio];
    
    for (UIView *v in self.view.subviews) {
        v.exclusiveTouch = YES;
    }
}

- (void)viewDidUnload
{
    [btnAudio release];
    btnAudio = nil;
    [btnContinue release];
    btnContinue = nil;
    [btnRestart release];
    btnRestart = nil;
    [btnQuit release];
    btnQuit = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [AudioHelper resumeBackgroundAudio];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (IBAction)btnContinueAction:(id)sender {
    if (!self.view.userInteractionEnabled) {
        return;
    }
    self.view.userInteractionEnabled = NO;
    [FlurryGameEvent logEventPrefixWithMode:@"Pause Screen" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"continue", @"tap", nil]];

    [[Animations sharedInstance] startAnimation:@"Angelina_Continue" onNode:[AngelinaScene getCurrent].angelina];
    [[AngelinaScene getCurrent] resume];
    [AudioHelper resumeBackgroundAudio];
}

- (IBAction)btnRestartAction:(id)sender {
    if (!self.view.userInteractionEnabled) {
        return;
    }
    self.view.userInteractionEnabled = NO;
    [FlurryGameEvent logEventPrefixWithMode:@"Pause Screen" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"restart", @"tap", nil]];
    [FlurryGameEvent logEventPrefixWithMode:@"Pause Screen" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"restart", @"tap", nil]];
    [FlurryGameEvent logEvent:@"vs. Pause Screen Play Again"];
    
    [[Animations sharedInstance] startAnimation:@"Angelina_Restart" onNode:[AngelinaScene getCurrent].angelina];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0e9*0.7)), dispatch_get_main_queue(), ^(void){
        [[AngelinaScene getCurrent] reset];
        [[AngelinaScene getCurrent] resume];
        [AudioHelper playBackgroundAudio:AngelinaGameAudio_GameMusic];
    });
}


- (IBAction)btnAudioAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    if (button.selected) {
        [AudioHelper disableAudio];
    } else {
        [AudioHelper enableAudio];
    }
}

- (IBAction)btnQuitAction:(id)sender {
    if (!self.view.userInteractionEnabled) {
        return;
    }
    self.view.userInteractionEnabled = NO;
    [FlurryGameEvent logEventPrefixWithMode:@"Pause Screen" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"quit", @"tap", nil]];
    [FlurryGameEvent logEvent:@"vs. Pause Screen Quit Game"];


    [[Animations sharedInstance] startAnimation:@"Angelina_Quit" onNode:[AngelinaScene getCurrent].angelina];
    [[NSNotificationCenter defaultCenter] postNotificationName:AngelinaGame_GameDidEnd object:nil];
}

- (void)dealloc {
    [btnAudio release];
    [btnContinue release];
    [btnRestart release];
    [btnQuit release];
    [super dealloc];
}
@end
