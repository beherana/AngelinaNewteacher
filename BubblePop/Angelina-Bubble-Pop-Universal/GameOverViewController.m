//
//  GameOverViewController.m
//  Angelina-Bubble-Pop-Universal
//
//  Created by Karl Söderström on 2011-06-30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameOverViewController.h"
#import "AngelinaScene.h"
#import "AudioHelper.h"
#import "Animations.h"
#import "FlurryGameEvent.h"
#import "cdaAnalytics.h"
#import "GameState.h"

@implementation GameOverViewController
@synthesize starAnimationViewController = _starAnimationViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    self.starAnimationViewController = nil;
    [imgGameOver release];
    [btnRestart release];
    [btnQuit release];
    [super dealloc];
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
    btnRestart.hidden = YES;
    btnQuit.hidden = YES;
#endif // ANGELINA_BUBBLE_POP_INAPP
    
    for (UIView *v in self.view.subviews) {
        v.exclusiveTouch = YES;
    }
    
    NSString *file = @"gameover_feedback";
    
    ScoreHandler *scoreHandler = [AngelinaScene getCurrent].scoreHandler;
    if (scoreHandler.score == scoreHandler.highScore) {
        imgGameOver.image = [UIImage imageNamed:@"high_score.png"];
                
        self.starAnimationViewController = [[[StarAnimationViewController alloc] init] autorelease];
        CGAffineTransform transform = CGAffineTransformMakeScale(scaleOfUIKitScreen, scaleOfUIKitScreen);
        self.starAnimationViewController.view.transform = transform;
        self.starAnimationViewController.view.center = imgGameOver.center;
        [self.view insertSubview:self.starAnimationViewController.view belowSubview:imgGameOver] ;
        [self.starAnimationViewController startAnimation];

        [AudioHelper playAudio:AngelinaGameAudio_Highscore];
        file = @"highscore_feedback";
        
        //record highscore in Flurry
        switch ([GameState sharedInstance].gameMode) {
            case AngelinaGameMode_Classic:
                [[cdaAnalytics sharedInstance] trackEvent:[NSString stringWithFormat:@"%i",scoreHandler.highScore] inCategory:flurryEventPrefix(@"World Highscore: Classic") withLabel:@"score" andValue:-1];
                break;
            case AngelinaGameMode_Clock:
                [[cdaAnalytics sharedInstance] trackEvent:[NSString stringWithFormat:@"%i",scoreHandler.highScore] inCategory:flurryEventPrefix(@"World Highscore: Beat the Clock") withLabel:@"score" andValue:-1];
                break;
            default:
                [[cdaAnalytics sharedInstance] trackEvent:[NSString stringWithFormat:@"%i",scoreHandler.highScore] inCategory:flurryEventPrefix(@"World Highscore: Unknown Game Mode") withLabel:@"score" andValue:-1];
                break;
        }
    }
    
    NSArray *animations = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:file ofType:@"plist"]];
    NSUInteger index = arc4random() % [animations count];
    NSString *animation = [animations objectAtIndex:index];
    [[Animations sharedInstance] startAnimation:animation onNode:nil];
}

- (void)viewDidUnload
{
    [imgGameOver release];
    imgGameOver = nil;
    [btnRestart release];
    btnRestart = nil;
    [btnQuit release];
    btnQuit = nil;
    [super viewDidUnload];
    self.starAnimationViewController = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (IBAction)btnRestartAction:(id)sender {
    if (!self.view.userInteractionEnabled) {
        return;
    }
    self.view.userInteractionEnabled = NO;
    [FlurryGameEvent logEventPrefixWithMode:@"Game Over Screen" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"restart", @"tap", nil]];
    [FlurryGameEvent logEvent:@"vs. Game Over Screen Restart Game"];


    [[Animations sharedInstance] startAnimation:@"Angelina_Restart" onNode:[AngelinaScene getCurrent].angelina];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0e9*0.7)), dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:0.2 animations:^{
            self.view.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
        }];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.4 scene:[AngelinaScene scene]]];
    });
    
    
}

- (IBAction)btnQuitAction:(id)sender {
    if (!self.view.userInteractionEnabled) {
        return;
    }
    self.view.userInteractionEnabled = NO;
    [FlurryGameEvent logEventPrefixWithMode:@"Game Over Screen" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"quit", @"tap", nil]];
    [FlurryGameEvent logEvent:@"vs. Game Over Screen Quit Game"];


    [[Animations sharedInstance] startAnimation:@"Angelina_Quit" onNode:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:AngelinaGame_GameDidEnd object:nil];
}

@end
