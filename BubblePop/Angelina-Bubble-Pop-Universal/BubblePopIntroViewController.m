//
//  IntroViewController.m
//  Angelina-Bubble-Pop-Universal
//
//  Created by Karl Söderström on 2011-08-23.
//  Copyright 2011 Commind AB. All rights reserved.
//

#import "BubblePopIntroViewController.h"
#import "AngelinaScene.h"
#import "cdaAnalytics.h"

@implementation BubblePopIntroViewController
@synthesize player = _player;
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
    
    NSURL *url = nil;
    if ([[[UIDevice currentDevice] model] rangeOfString:@"iPad"].location != NSNotFound)
    {
        // ipad
        url = [[NSBundle mainBundle] URLForResource:@"Angelina_bubble_pop_intro_iPad" withExtension:@"m4v"];

    } else {
        if([[UIScreen mainScreen] respondsToSelector:@selector(scale)]
           && [[UIScreen mainScreen] scale] == 2)
        {
            // retina
            url = [[NSBundle mainBundle] URLForResource:@"Angelina_bubble_pop_intro_iPad" withExtension:@"m4v"];              
        } else {
            // iphone
            url = [[NSBundle mainBundle] URLForResource:@"Angelina_bubble_pop_intro_iPhone" withExtension:@"m4v"];              
        }
    }
    
    self.player = [[MPMoviePlayerController alloc] initWithContentURL:url];
    self.player.backgroundView.backgroundColor = [UIColor clearColor];
    self.player.view.backgroundColor = [UIColor clearColor];
    self.player.shouldAutoplay = NO;
    self.player.view.frame = CGRectMake(0, 0, 1152, 768);
    self.player.controlStyle = MPMovieControlStyleNone;
    self.player.useApplicationAudioSession = YES;
    self.player.view.center = self.view.center;
    self.player.view.transform = CGAffineTransformMakeScale(scaleOfUIKitScreen, scaleOfUIKitScreen);
    [self.view addSubview:self.player.view];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieEnded:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.player];
}

- (void)dealloc
{
    self.player = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)movieEnded:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:AngelinaGame_IntroMovieDidFinish object:self];    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [[cdaAnalytics sharedInstance] trackEvent:flurryEventPrefix(@"Intro Movie: Skip intro")];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.player pause];
    [[NSNotificationCenter defaultCenter] postNotificationName:AngelinaGame_IntroMovieDidFinish object:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.player pause];
    self.player = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)play
{
    [self.player play];
}

@end
