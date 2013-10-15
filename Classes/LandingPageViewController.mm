    //
//  LandingPageViewController.m
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/15/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import "LandingPageViewController.h"
#import "Angelina_AppDelegate.h"
#import "cdaAnalytics.h"

@interface LandingPageViewController ()
-(void) triggerRandomAnimations;
-(void) randomAnimateAngelina;
-(void) animateAngelina:(NSString *)name;
@end

@implementation LandingPageViewController

@synthesize navController;
//@synthesize readButton, paintButton, puzzleButton, watchButton, playButton;
@synthesize tabs = _tabs;
@synthesize animationInterval = _animationInterval;
@synthesize animations = _animations;
@synthesize animationBlinkCounter = _animationBlinkCounter;
@synthesize initialKeepAliveDelay = _initialKeepAliveDelay;
@synthesize previousAnimation = _previousAnimation;
@synthesize keepAliveAnimations = _keepAliveAnimations, keepAliveVoiceAnimations = _keepAliveVoiceAnimations;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

- (void)viewWillAppear:(BOOL)animated {
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

    
    angelinaImage.alpha = 0.0;
    [UIView animateWithDuration:0.8
                          delay:0.2
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         angelinaImage.alpha = 1.0;
                     }
                     completion:nil];
/*
    logoImage.alpha = 0.0;
    [UIView animateWithDuration:0.8
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         logoImage.alpha = 1.0;
                     }
                     completion:nil];    
  */  
    ribbonImage.alpha = 0.0;
    [UIView animateWithDuration:1.2
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         ribbonImage.alpha = 1.0;
                     }
                     completion:nil];  
    
    CGAffineTransform smallTransform = CGAffineTransformMakeScale(0.01, 0.01);
    CGAffineTransform normalTransform = CGAffineTransformMakeScale(1.0, 1.0);
    
    readButton.exclusiveTouch = YES;
    paintButton.exclusiveTouch = YES;
    puzzleButton.exclusiveTouch = YES;
    watchButton.exclusiveTouch = YES;
    playButton.exclusiveTouch = YES;
    infoButton.exclusiveTouch = YES;
    moreAppsButton.exclusiveTouch = YES;
    
    readButton.tag = NAV_READ;
    paintButton.tag = NAV_PAINT;
    puzzleButton.tag = NAV_PUZZLE;
    watchButton.tag = NAV_WATCH;
    playButton.tag = NAV_PLAY;
    infoButton.tag = INFO_BTN;
    moreAppsButton.tag = MOREAPPS_BTN;
    
    readButton.transform = smallTransform;
    paintButton.transform = smallTransform;
    puzzleButton.transform = smallTransform;
    playButton.transform = smallTransform;
    infoButton.transform = smallTransform;
    watchButton.transform = smallTransform;
    moreAppsButton.transform = smallTransform;
    readButton.alpha = 0.0;
    paintButton.alpha = 0.0;
    puzzleButton.alpha = 0.0;
    watchButton.alpha = 0.0;
    infoButton.alpha = 0.0;
    moreAppsButton.alpha = 0.0;    
    [UIView animateWithDuration:0.4
                          delay:0.4
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         readButton.alpha = 1.0;
                         readButton.transform = normalTransform;
                     }
                     completion:nil]; 
    [UIView animateWithDuration:0.4
                          delay:0.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         paintButton.alpha = 1.0;
                         paintButton.transform = normalTransform;
                     }
                     completion:nil];
    [UIView animateWithDuration:0.4
                          delay:0.6
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         puzzleButton.alpha = 1.0;
                         puzzleButton.transform = normalTransform;
                     }
                     completion:nil];
    [UIView animateWithDuration:0.4
                          delay:0.7
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         watchButton.alpha = 1.0;
                         watchButton.transform = normalTransform;
                     }
                     completion:nil];
    [UIView animateWithDuration:0.4
                          delay:0.8
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         playButton.alpha = 1.0;
                         playButton.transform = normalTransform;
                     }
                     completion:nil];
    [UIView animateWithDuration:0.4
                          delay:0.8
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         infoButton.alpha = 1.0;
                         infoButton.transform = normalTransform;
                     }
                     completion:nil];
     
    //set up and start the keep alive animations
    [self setupKeepAliveAnimations];
    [UIView animateWithDuration:0.4
                          delay:0.8
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         moreAppsButton.alpha = 1.0;
                         moreAppsButton.transform = normalTransform;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
    //Trigger the keep alive animations. Delay them so the page will have loaded and presentation have been played
    Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
    if ([appDelegate voicePresentationPlayed]) {
        self.animationInterval = [NSTimer scheduledTimerWithTimeInterval:1.2 target:self selector:@selector(randomAnimateAngelina) userInfo:nil repeats:NO];
    } else {
        self.animationInterval = [NSTimer scheduledTimerWithTimeInterval:9.2 target:self selector:@selector(triggerRandomAnimations) userInfo:nil repeats:NO];
    }
    
    self.animationBlinkCounter = 0;
    
    //self.tabs = [[[LandingPageTabsViewController alloc] initWithNibName:@"LandingPageTabsViewController" bundle:nil] autorelease];
    
}

//create animations from plists
-(void) setupKeepAliveAnimations {
    self.keepAliveAnimations = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"keepAlives" ofType:@"plist"]] objectForKey:@"animations"];
    
    //only get non empty elements. Assume that the first element is a none voice animation so start at i=1
    NSMutableArray *voiceAnimations = [[NSMutableArray alloc] init];
    for (int i = 1; i < [self.keepAliveAnimations count]; i++) {
        NSString *animationName = [self.keepAliveAnimations objectAtIndex:i];
        if ([animationName length] > 0) {
            [voiceAnimations addObject:animationName];
        }
    }

    self.keepAliveVoiceAnimations = [NSArray arrayWithArray:voiceAnimations];
    [voiceAnimations release];
    
    //get previous animation from last session
    self.previousAnimation = [[[Angelina_AppDelegate get] currentRootViewController] landingpagePreviousAnimation];
}

//run a random voice keep alive followed by random animations callback
-(void) triggerRandomAnimations {
    //grab a random voice animation
    int animationIndex = arc4random() % ([self.keepAliveVoiceAnimations count]-1);
    
    //increment blink counter so it is possible to get a blink
    self.animationBlinkCounter++;

    //run the animation directly
    NSString *name = [self.keepAliveVoiceAnimations objectAtIndex:animationIndex];
    [self animateAngelina:name];
    self.previousAnimation = name;
    
    //seed a new chain of animations
    int t = 6 + (arc4random() % 3);
    self.animationInterval = [NSTimer scheduledTimerWithTimeInterval:t target:self selector:@selector(randomAnimateAngelina) userInfo:nil repeats:NO];
}

-(NSString *) uniqueAnimation {
    NSString *animationName;
    //get an animation
    int currentAnimationIndex = arc4random() % ([self.keepAliveVoiceAnimations count]);
    animationName = [self.keepAliveVoiceAnimations objectAtIndex:currentAnimationIndex];
    
    //if the animation is non empty find a voice animation that is different from the previous one. Only if we have more than one animation to alter between.
    if ([animationName length] > 0 && ([self.keepAliveVoiceAnimations count] > 1)) {
        while([animationName isEqualToString:self.previousAnimation]) {
            //NSLog(@"animation is not unique. %@ vs %@", animationName, self.previousAnimation);
            currentAnimationIndex = arc4random() % ([self.keepAliveVoiceAnimations count]);
            animationName = [self.keepAliveVoiceAnimations objectAtIndex:currentAnimationIndex];
        }
        self.previousAnimation = animationName;
    }

    return animationName;
}

-(void) randomAnimateAngelina {
    // Run animation index 0 every 4-6 seconds
    // Run animation index 1 and up (randomized) instead of every third blink, i.e. every 12-18 seconds 
    NSString *animationName;
    if (self.animationBlinkCounter % 3 == 0) {
        //dont run the same animation twice
        animationName = [self uniqueAnimation];
    }
    else {
        //blink animation
        animationName = [self.keepAliveAnimations objectAtIndex:0];
    }
    self.animationBlinkCounter++;

    [self animateAngelina:animationName];
    int t = 4 + (arc4random() % 3);
    self.animationInterval = [NSTimer scheduledTimerWithTimeInterval:t target:self selector:@selector(randomAnimateAngelina) userInfo:nil repeats:NO];
}

-(IBAction)easterEggAction:(id)sender {
    
    //Reset latest random animation.
    [self.animationInterval invalidate];

    NSString *name = [self uniqueAnimation];
    [self animateAngelina:name];
    
    int t = (arc4random() % (15 - 7)) + 7;
    self.animationInterval = [NSTimer scheduledTimerWithTimeInterval:t target:self selector:@selector(randomAnimateAngelina) userInfo:nil repeats:NO];
}

-(void) animateAngelina:(NSString *)name {
    
    if (self.animations == nil) {
        self.animations = [[[KeepAliveAnimations alloc] init] autorelease];
    }
    [self.animations startAnimation:name onView:angelinaAnimationView];
}

-(IBAction) mainMenuNav:(id)sender {
    
    int tag = [(UIButton *)sender tag];
    
    switch (tag) {
        case INFO_BTN:
            [[cdaAnalytics sharedInstance] trackEvent:@"Information" inCategory:flurryEventPrefix(@"Landing Page") withLabel:@"tap" andValue:-1];

            self.tabs = [[[LandingPageTabsViewController alloc] initWithNibName:@"LandingPageTabsViewController" bundle:nil] autorelease];
            [self.tabs setDelegate:self];
            //[moreAppsButton setHidden:YES];
            [self.view addSubview:self.tabs.view];
            [self.tabs btnInfoTabAction:nil];
            //[infoButton setHidden:YES];
            break;
        case MOREAPPS_BTN:
            [[cdaAnalytics sharedInstance] trackEvent:@"More Apps" inCategory:flurryEventPrefix(@"Landing Page") withLabel:@"tap" andValue:-1];

            self.tabs = [[[LandingPageTabsViewController alloc] initWithNibName:@"LandingPageTabsViewController" bundle:nil] autorelease];
            [self.tabs setDelegate:self];
            //[infoButton setHidden:YES];
            [self.view addSubview:self.tabs.view];
            [self.tabs btnMoreAppsTabAction:nil];
            //[moreAppsButton setHidden:YES];
            break;    
        default:
            /* Flurry for landing page */
            switch (tag) {
                case NAV_READ:
                    [[cdaAnalytics sharedInstance] trackEvent:@"Read" inCategory:flurryEventPrefix(@"Landing Page") withLabel:@"tap" andValue:-1];
                    break;
                    
                case NAV_PAINT:
                    [[cdaAnalytics sharedInstance] trackEvent:@"Paint" inCategory:flurryEventPrefix(@"Landing Page") withLabel:@"tap" andValue:-1];
                    break;
                    
                case NAV_PUZZLE:
                    [[cdaAnalytics sharedInstance] trackEvent:@"Puzzle" inCategory:flurryEventPrefix(@"Landing Page") withLabel:@"tap" andValue:-1];
                    break;
                    
                case NAV_WATCH:
                    [[cdaAnalytics sharedInstance] trackEvent:@"Watch" inCategory:flurryEventPrefix(@"Landing Page") withLabel:@"tap" andValue:-1];
                    break;
                    
                case NAV_PLAY:
                    [[cdaAnalytics sharedInstance] trackEvent:@"Play" inCategory:flurryEventPrefix(@"Landing Page") withLabel:@"tap" andValue:-1];
                    break;
                    
            }

            self.view.userInteractionEnabled = NO;
            
            Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
            
            if (appDelegate.introPresentation.playing) [appDelegate stopIntroPresentation];
            appDelegate.myRootViewController.resumePage = YES;
            [self.navController navigateFromMainMenuWithItem:tag];
            break;
    }
    
    // Remove the timer
    [self.animationInterval invalidate];
    self.animationInterval = nil;
    
    /*
    if (sender == self.readButton) {
        if (appDelegate.introPresentation.playing) [appDelegate stopIntroPresentation];
        appDelegate.myRootViewController.resumePage = YES;
        [appDelegate.myRootViewController updateFlurryForNavigationButtons:@"Main Menu" target:NAV_READ];
        [self.navController navigateFromMainMenuWithItem:NAV_READ];
    }
    else if (sender == self.paintButton) {
        if (appDelegate.introPresentation.playing) [appDelegate stopIntroPresentation];
        [appDelegate.myRootViewController updateFlurryForNavigationButtons:@"Main Menu" target:NAV_PAINT];
        [self.navController navigateFromMainMenuWithItem:NAV_PAINT];
    }
    else if (sender == self.puzzleButton) {
        if (appDelegate.introPresentation.playing) [appDelegate stopIntroPresentation];
        [appDelegate.myRootViewController updateFlurryForNavigationButtons:@"Main Menu" target:NAV_PUZZLE];
        [self.navController navigateFromMainMenuWithItem:NAV_PUZZLE];
    }
    else if (sender == self.watchButton) {
        if (appDelegate.introPresentation.playing) [appDelegate stopIntroPresentation];
        [appDelegate.myRootViewController updateFlurryForNavigationButtons:@"Main Menu" target:NAV_WATCH];
        [self.navController navigateFromMainMenuWithItem:NAV_WATCH];
    }
     */
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}
/* old thomas stuff
-(IBAction) speakTitleButtonTapped:(id)sender {
	Angelina_AppDelegate *appDelegate = (Angelina_AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate playintroPresentation];
}

-(IBAction) speakTitleThomasButtonTapped:(id)sender {
	Angelina_AppDelegate *appDelegate = (Angelina_AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate playIntroThomasWhistle];
}

-(IBAction) speakTitleHiroButtonTapped:(id)sender {
	Angelina_AppDelegate *appDelegate = (Angelina_AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate playIntroHiroWhistle];
}
 */

//-(IBAction) infoButtonClicked:(id)sender{
//    [[cdaAnalytics sharedInstance] trackEvent:@"Info tapped in Main Menu"];
//    [[cdaAnalytics sharedInstance] trackEvent:@"Info tapped in Main Menu"];
//
//    Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
//    if (appDelegate.introPresentation.playing) [appDelegate stopIntroPresentation];
//    
////	popoverContent=[[InfoPopoverController alloc] initWithNibName:@"InfoPopoverController" bundle:nil];
////	popover = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
////	[popover setDelegate:self];
////	[popover setPopoverContentSize:CGSizeMake(989,545)];
////	popoverContent.contentSizeForViewInPopover=popoverContent.view.bounds.size;
////	[popover presentPopoverFromRect:((UIView *)sender).frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//    popoverContent =[[InfoPopoverController alloc] initWithNibName:@"InfoPopoverController" bundle:nil];
//    [popoverContent show:self.view];
//    [popoverContent release]; 
//    
//
//    //[popover setDelegate:self];
//    
//    
//}

- (void)popoverControllerDidDismissPopover:(UIPopoverController*)popoverController{
	if (popover) {
		[popover dismissPopoverAnimated:YES];
		[popover release];
		popover=nil;
		if (popoverContent != nil) {
			[popoverContent release];
			popoverContent = nil;
		}
	}
}
-(void)killPopoversOnSight {
	if (popover) {
		[popover dismissPopoverAnimated:NO];
	}
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)tabDismissed {
    [infoButton setHidden:NO];
    [moreAppsButton setHidden:NO];
    
    [self.tabs.view removeFromSuperview];
    //[self.tabs release];
    self.tabs = nil;
}

- (void)viewDidUnload {
    [ribbonImage release];
    ribbonImage = nil;
    [angelinaImage release];
    angelinaImage = nil;
//    [logoImage release];
//    logoImage = nil;
    self.previousAnimation = nil;
    [self.tabs.view removeFromSuperview];
    self.tabs = nil;
    self.animations = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.animationInterval invalidate];
    self.animationInterval = nil;
}

- (void)dealloc {
	if (popover) {
		[popover release];
		popover=nil;
	}
	if (popoverContent != nil) {
		popoverContent = nil;
	}
    self.navController = nil;
    self.animations = nil;
    self.tabs = nil;
    [self.animationInterval invalidate];
    self.animationInterval = nil;
    [[[Angelina_AppDelegate get] currentRootViewController] setLandingpagePreviousAnimation:self.previousAnimation];
    self.previousAnimation = nil;
    [readButton release];
    [paintButton release];
    [puzzleButton release];
    [watchButton release];
    [playButton release];
    [infoButton release];
    [moreAppsButton release];
    [logoImage release];
    [ribbonImage release];
    [angelinaImage release];
    [angelinaAnimationView release];
    
    
//    [logoImage release];
    [super dealloc];
}


@end
