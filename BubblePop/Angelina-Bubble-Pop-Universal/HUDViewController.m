//
//  HUDViewController.m
//  Angelina-Bubble-Pop-Universal
//
//  Created by Karl Söderström on 2011-08-03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HUDViewController.h"
#import "AngelinaScene.h"
#import "FlurryGameEvent.h"

@implementation HUDViewController
@synthesize btnPause;

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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGamePaused:) name:AngelinaGame_GameOver object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGamePaused:) name:AngelinaGame_GamePaused object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGameResumed:) name:AngelinaGame_GameResumed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGameDidStart:) name:AngelinaGame_GameDidStart object:nil];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setBtnPause:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (IBAction)btnPauseAction:(id)sender {
    [FlurryGameEvent logEventPrefixWithMode:@"Game Play Pause" withParameters:nil];
     
    [[AngelinaScene getCurrent] pause];
}

- (void)handleGamePaused:(NSNotification *) notification
{
    [UIView animateWithDuration:0.2 animations:^{
        self.btnPause.alpha = 0.0;
    }];
}

- (void)handleGameResumed:(NSNotification *) notification
{
    [UIView animateWithDuration:0.2 animations:^{
        self.btnPause.alpha = 1.0;
    }];
}

- (void)handleGameDidStart:(NSNotification *) notification
{
    [UIView animateWithDuration:0.2 animations:^{
        self.btnPause.alpha = 1.0;
    }];
}

- (void)dealloc {
    [btnPause release];
    [super dealloc];
}
@end
