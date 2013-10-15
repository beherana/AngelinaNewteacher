    //
//  ThomasRootViewController.m
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/10/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import "ThomasRootViewController.h"
#import "Angelina_AppDelegate.h"
#import "ThomasSettingsViewController.h"
#import "PlaySoundAction.h"
#import "cdaAnalytics.h"
#import "SubMenuViewController.h"
#import "PuzzleDelegate.h"
#import "PaintHolderLandscapeViewController.h"
#import "PaintViewController.h"
#import "WatchMainViewController.h"
#import "LandingPageViewController.h"
#import "Angelina_AppDelegate.h"
#import "BookScene.h"
#import "ReadController.h"
#import "DotViewController.h"
#import "IntroViewController.h"
#import "PaintMenuViewController.h"
#import "MatchMenuViewController.h"
#import "MatchViewController.h"
#import "cdaCCSlideInLTransition.h"
#import "AVQueueManager.h"
#import "CustomAlertViewController.h"
#import "PageTurnWithBackground.h"

@interface ThomasRootViewController (PrivateMethods)
-(void)playIntroMovie;
-(void)loadSubMenu;
-(void)unloadSubMenu;
-(void)openLandingpage;
-(void)openPuzzles;
-(void)openMatch;
-(void)openPaint;
-(void)openSettings;
-(void)openPaintOnIPhone;
-(void)openWatch;
-(void)openDots;
-(void) preOpenRead;
-(void)leaveFromWatch;
-(void)openRead;
-(void)openPlay;
-(void)initCocos;
@end

@implementation ThomasRootViewController

@synthesize homeButton;
@synthesize currentScene,landscapeRight, sceneData;
@synthesize myPuzzleDelegate;
@synthesize readSceneDelay, speakerDelayStart;
@synthesize endview;
@synthesize hotspotHolder;
@synthesize resumePage;
@synthesize mySubViewController, readOverlayViewController, popoverImageViewController;
@synthesize landingpagePreviousAnimation = _landingpagePreviousAnimation;
@synthesize endPageViewController = _endPageViewController;
@synthesize endPageMoreAppsViewController = _endPageMoreAppsViewController;

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

- (void)setResumePage:(BOOL)_resumePage {
    if (_resumePage && [PageHandler defaultHandler].currentPage != 1){
        resumePage = YES;
    }
    else {
        resumePage = NO;
    }
}

/**/
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self homeButtonHidden:YES];
    
    //Used when all speaker sounds are not in place - we play silence on all scenes to avoid crashes due to missing audio
    useSpeakerSilence = NO;
    
	NSLog(@"Called viewDidLoad");
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		iPhoneMode = YES;
	} else {
		iPhoneMode = NO;
	}

    // AVQueueManager notifications
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(AVManagerItemStartedPlaying:)
     name:kAVManagerItemStartedPlaying
     object:[AVQueueManager sharedAVQueueManager]];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(AVManagerItemStoppedPlaying:)
     name:kAVManagerItemStoppedPlaying
     object:[AVQueueManager sharedAVQueueManager]];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(AVManagerItemPaused:)
     name:kAVManagerItemPaused
     object:[AVQueueManager sharedAVQueueManager]];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(AVManagerItemUnpaused:)
     name:kAVManagerItemUnpaused
     object:[AVQueueManager sharedAVQueueManager]];
    
    // PageHandler notifications
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(currentPageDidChange:)
     name:kCurrentPageDidChange
     object:nil];
    
    // Show page resume alert
    self.resumePage = YES;
    
	//start by getting the puzzles in there.
	//[self openPuzzles];
	//[self openPaint];
	projectInit = YES;
	menusoundInit = YES;
	cocosInit=NO;
	cocosShown=NO;
	cocosPaused=NO;
	queueClear=NO;
	turningPage=NO;
	
	//get scene data
	NSString *thePath = [[NSBundle mainBundle] pathForResource:@"scenenav" ofType:@"plist"];
	sceneData = [[NSArray alloc] initWithContentsOfFile:thePath];
	//Set to 0 to be able to restore without being blocked by allready having that value and use savedNavigationItem for startup
	currentNavigationItem = 0;
	//restore saved prefs
	Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
	savedNavigationItem = [appDelegate getSaveSelectedAppSection];
	currentPaintImage = [appDelegate getSaveCurrentPaintImage];
	currentDotImage = [appDelegate getSaveCurrentDotImage];
	currentDotState = [appDelegate getSaveDotDifficulty];
    currentMatchState = [appDelegate getSaveMatchDifficulty];
	currentNarrationSetting=[appDelegate getSaveNarrationSetting];
	
	//if ([appDelegate getIntroPresentationPlayed]) {
	//	[self loadSubMenu];
	//	[self loadMainMenu];
		//[self playIntroMovie];
	//} else {
		//play intro

    [self loadSubMenu];
    [self playIntroMovie];
    
    readOverlayViewController = [[ReadOverlayViewController alloc] initWithNibName:@"ReadOverlayView" bundle:nil];
    readOverlayViewController.view.hidden = YES;
    [self.view addSubview:readOverlayViewController.view];
        
	//}
}
#pragma mark -
#pragma mark INTRO
-(void)playIntroMovie {
	if (myIntroViewController == nil) {
		myIntroViewController = [[IntroViewController alloc] initWithNibName:@"IntroViewController" bundle:nil];
		[self.view addSubview:myIntroViewController.view];
        //intro fix
        [self.view bringSubviewToFront:fakeloadingpage];
        //
	}
}
-(void) removeFakeLoadingPage {
    
    [UIView animateWithDuration:0.8
                     animations:^{fakeloadingpage.alpha = 0.0;}
                     completion:^(BOOL finished){
                         fakeloadingpage.hidden = YES;
                         [fakeloadingpage removeFromSuperview];
                         [fakeloadingpage release];
                         fakeloadingpage = nil;
                         [myIntroViewController.moviePlayer play];
                     }];
    
}
-(void)introFadedIn:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	//[self stopRunway];
}
-(void)introFinishedPlaying {
	if (myIntroViewController != nil) {
//        Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
//		if (iPhoneMode) {
//			[self navigateFromMainMenuWithItem:[appDelegate getSaveSelectedAppSection]];
//			[myIntroViewController.view removeFromSuperview];
//			[myIntroViewController release];
//			myIntroViewController = nil;
//			//TEMP - use only if intro doesn't contain a langing page, otherwise landing page handles this
//			[appDelegate setIntroPresentationPlayed:YES];
//			//
//		} else {
            [self navigateFromMainMenuWithItem:[self getSavedNavigationItem]]; //temp here
			[myIntroViewController.view removeFromSuperview];
			[myIntroViewController release];
			myIntroViewController = nil;
			landingpage.hidden = YES;
            [landingpage removeFromSuperview];
            [landingpage release];
            landingpage = nil;
            //[appDelegate setIntroPresentationPlayed:YES];
//		}
	}
}

-(void)introFadedOut:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	[myIntroViewController.view removeFromSuperview];
	[myIntroViewController release];
	myIntroViewController = nil;
}
-(void)showFakeLandingPage {
	landingpage.hidden = NO;
}
#pragma mark -
#pragma mark Navigation
- (void)playFXEventSound:(NSString *)sound {
	if (menusoundInit == NO) {
		Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
		[appDelegate playFXEventSound:sound];
	} else {
		menusoundInit = NO;
	}

}
-(void)returnFromMainMenuToLastItem {
	if (lastVisitedMenuItem) {
		[self playFXEventSound:@"mainmenu"];

		[self navigateFromMainMenuWithItem:lastVisitedMenuItem];
	}
}
-(NSString*)itemToString:(int)item {
    NSString *strItem = @"";
    switch (item) {
        case NAV_MAIN:
            strItem = @"Main Menu";
            break;
        case NAV_PAINT:
            strItem = @"Paint";
            break;
        case NAV_PUZZLE:
            strItem = @"Puzzle";
            break;
        case NAV_READ:
            strItem = @"Read";
            break;
        case NAV_WATCH:
            strItem = @"Watch";
            break;
            
        default:
            //NSLog(@"EMPTY value:%i",item);
            strItem = @"EMPTY";
            break;
    }
    return strItem;
}
-(void)navigateFromMainMenuWithItem:(int)item {
	
    // Post Notification with navItem as userInfo
    NSDictionary *userInfo = 
    [NSDictionary dictionaryWithObjectsAndKeys:
     [NSNumber numberWithInt:item], @"navItem", nil];
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:kNavigateFromMainMenu object:self userInfo:userInfo];
    
	Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];

	/* OLD Code - no difference in navigation between iPhone and iPad
	if (iPhoneMode) {
		if (currentNavigationItem == item) return;

		if (item != NAV_MAIN) {
			lastVisitedMenuItem = item;
		}
		
		currentNavigationItem = item;

		//dismiss any popover that might be present in the landingpage
		[myLandingpageViewController killPopoversOnSight];
		//
		[self unloadCurrentNavigationItem];
		
		
		[self removePendingSceneDelay];
		
        if (item == NAV_MAIN) {
            
            
        }
		else if (item == NAV_READ) {
			//read
			[self openRead];
			//FLURRY
			[[cdaAnalytics sharedInstance] trackEvent:@"Read tapped in Main Menu"];
			[[cdaAnalytics sharedInstance] trackEvent:@"Read tapped in Main Menu"];
		} else if (item == NAV_WATCH) {
			//watch
			[self openWatch];
			//FLURRY
			[[cdaAnalytics sharedInstance] trackEvent:@"Watch tapped in Main Menu"];
			[[cdaAnalytics sharedInstance] trackEvent:@"Watch tapped in Main Menu"];
		} else if (item == NAV_PAINT) {
			//paint
			[self openPaintOnIPhone];
			//FLURRY
			[[cdaAnalytics sharedInstance] trackEvent:@"Paint tapped in Main Menu"];
			[[cdaAnalytics sharedInstance] trackEvent:@"Paint tapped in Main Menu"];
		} else if (item == NAV_PUZZLE) {
			//puzzle
			[self openPuzzles];
			//FLURRY
			[[cdaAnalytics sharedInstance] trackEvent:@"Puzzle tapped in Main Menu"];
			[[cdaAnalytics sharedInstance] trackEvent:@"Puzzle tapped in Main Menu"];
		} else if (item == 7) {
			//memory match
			[self openMatch];
			//FLURRY
			[[cdaAnalytics sharedInstance] trackEvent:@"Memory match tapped in Main Menu"];
			[[cdaAnalytics sharedInstance] trackEvent:@"Memory match tapped in Main Menu"];
		} else if (item == 8) {
			//paint
			[self openPaint];
			//FLURRY
			//[[cdaAnalytics sharedInstance] trackEvent:@"Paint tapped in Main Menu on iPhone"];
			//[[cdaAnalytics sharedInstance] trackEvent:@"Paint tapped in Main Menu on iPhone"];
		} else if (item == 9) {
			//settings + info
			[self openSettings];
			//FLURRY
			[[cdaAnalytics sharedInstance] trackEvent:@"Settings+info tapped in Main Menu"];
			[[cdaAnalytics sharedInstance] trackEvent:@"Settings+info tapped in Main Menu"];
		}
		
		[mySubViewController addInterfaceToSubMenu:item];
		
		////adjust menu z-depth and visiblilty
		[self adjustNavigation];
		//save navigation item
		if (item != 0) {
			[appDelegate setSaveSelectedAppSection:item];
			[appDelegate setSaveLastVisitedMenuItem:lastVisitedMenuItem];
		}
		
	} else {
     */
    if (currentNavigationItem == item) return;
    
    currentNavigationItem = item;
    
    //dismiss any popover that might be present in the landingpage
    [myLandingpageViewController killPopoversOnSight];
    //
    [self unloadCurrentNavigationItem];
    
    [self removePendingSceneDelay];
    
    if (item == NAV_MAIN) {
        //home/landingpage
        [self openLandingpage];
    } else if (item == NAV_READ) {
        //read
        //[self preOpenRead];
        [self openRead];
    } else if (item == NAV_WATCH) {
        //watch
        [self openWatch];
    } else if (item == NAV_PAINT) {
        //paint
        [self openPaint];
    } else if (item == NAV_PUZZLE) {
        //puzzle
        [self openPuzzles];
    } else if (item == 7) {
        //Memory Match
        [self openMatch];
        //FLURRY
        //[[cdaAnalytics sharedInstance] trackEvent:@"Match tapped in Main Menu"];
        //[[cdaAnalytics sharedInstance] trackEvent:@"Match tapped in Main Menu"];
    } else if (item == NAV_PLAY) {
        [self openPlay];
    }
    
    [mySubViewController addInterfaceToSubMenu:item];
    //adjust menu z-depth and visiblilty
    [self adjustNavigation];
    //save navigation item
    if (item != 0) {
        [appDelegate setSaveSelectedAppSection:item];
    }
}

-(void)unloadCurrentNavigationItem {
    Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];

/*XXX-mk old end page
    if (endPageIsDisplayed) {
        [appDelegate stopEndSound];
        [appDelegate stopInterfaceAudio];
        [self.endview removeFromSuperview];
        endPageIsDisplayed = NO;
    }*/
    
	if (myPuzzleDelegate != nil) {
		[myPuzzleDelegate cleanCurrentlySelectedPuzzle];
		[myPuzzleDelegate.view removeFromSuperview];
		[myPuzzleDelegate release];
		myPuzzleDelegate = nil;
	}
	if (myMatchMenuViewController != nil) {
		[myMatchMenuViewController.view removeFromSuperview];
		[myMatchMenuViewController release];
		myMatchMenuViewController = nil;
	}
	if (myPaintMenuViewController != nil) {
		[myPaintMenuViewController.view removeFromSuperview];
		[myPaintMenuViewController release];
		myPaintMenuViewController = nil;
	}
	if (myPaintHolder != nil) {
		[myPaintHolder.view removeFromSuperview];
		[myPaintHolder release];
		myPaintHolder = nil;
	}
	if (myLandingpageViewController != nil) {
        [myLandingpageViewController viewWillDisappear:NO];
		[myLandingpageViewController.view removeFromSuperview];
		[myLandingpageViewController autorelease];
		myLandingpageViewController = nil;
	}
	/*
	if (myDotViewController!=nil) {
		[myDotViewController.view removeFromSuperview];
		[myDotViewController release];
		myDotViewController=nil;
	}
     */
	if (mySettingsViewController!=nil) {
		[mySettingsViewController.view removeFromSuperview];
		[mySettingsViewController release];
		mySettingsViewController=nil;
	}
    if (myWatchMainViewController!=nil) {
		[myWatchMainViewController.view removeFromSuperview];
		[myWatchMainViewController release];
		myWatchMainViewController=nil;
	}
    if (bubblePopRootViewController != nil) {
        [bubblePopRootViewController stopGame];
        [bubblePopRootViewController.view removeFromSuperview];
        [bubblePopRootViewController release];
        bubblePopRootViewController = nil;
        glview.frame = CGRectMake(0, 0, 1024, 768);
        [[CCDirector sharedDirector] reshapeProjection:CGSizeMake(1024, 768)];
        [self pauseCocos];
        [self clearCocos];
    }
    
	if (myReadController !=nil) {
		//clear audio file
        [self stopNarrationOnScene];
        
        //stop everything in the audio queue
        [[AVQueueManager sharedAVQueueManager] stop];
        
		[appDelegate stopReadSpeakerPlayback];
		[appDelegate cleanUpReadSpeaker];
		[self removePendingSceneDelay];
        
        [[CCTouchDispatcher sharedDispatcher] removeDelegate:currentScene];
        
        [self pauseCocos];
		//[appDelegate unloadReadMusic];
		[self clearCocos];

		[myReadController removeSwipe];
		[myReadController.view removeFromSuperview];
		[myReadController release];
		myReadController=nil;
        readOverlayViewController.view.hidden = YES;
        glview.layer.transform=CATransform3DIdentity;
	}

    [self removeEndPage];
}

-(void)homeButtonPressed:(id)sender {
    if ([self getEndPageIsDisplayed]) {
        [[PageHandler defaultHandler] forcePage:1];
    }
        
    [self navigateFromMainMenuWithItem:NAV_MAIN];
}

-(void)adjustNavigation {
    
    [self.view bringSubviewToFront:readOverlayViewController.view];
    [self.view bringSubviewToFront:mySubViewController.fadeOverlayView];
    [self.view bringSubviewToFront:self.homeButton];
    [self.view bringSubviewToFront:mySubViewController.view];

}

//show or hide the homebutton - wrapped incase it should fade or something fancy
-(void)homeButtonHidden:(BOOL)hidden {
    self.homeButton.hidden = hidden;
}
/* OLD Thomas stuff 
-(void)adjustMainMenu {
	if (iPhoneMode && currentNavigationItem == NAV_READ) {
		[self.view bringSubviewToFront:mySubViewController.view];
	} else {
		if (currentNavigationItem == NAV_WATCH) {
			myMainMenuController.view.hidden = YES;
		} else {
			if (myMainMenuController.view.hidden) myMainMenuController.view.hidden = NO;
			//bring interface to top
			[self.view bringSubviewToFront:mySubViewController.view];
			[self.view bringSubviewToFront:myMainMenuController.view];
		}
	}
}*/
-(void)leaveFromWatch {
	//go to landing page
	[self navigateFromMainMenuWithItem:2];
}
#pragma mark -

/* old thomas stuff
#pragma mark Main Menu
-(void)loadMainMenu {
	if (myMainMenuController == nil) {
		//myMainMenuController = [[MainMenuController alloc] initWithNibName:@"MainMenuController" bundle:nil];
		myMainMenuController = [[MainMenuController alloc] initWithNibName:@"MainMenuController" bundle:nil];
		if (!iPhoneMode) {
			myMainMenuController.view.center = CGPointMake(myMainMenuController.view.center.x-(myMainMenuController.view.frame.size.width/2-60.0), myMainMenuController.view.center.y+18.0);
		}
		//
		[self.view addSubview:myMainMenuController.view];
		[myMainMenuController initWithParent:self];
		//drop shadow -removed since it forces hi res retina resources to draw as low rez - go figure...
		//drop shadow should only apply to the menu on the iPad
		if (!iPhoneMode) {
			myMainMenuController.view.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.000].CGColor;
			myMainMenuController.view.layer.shadowOpacity = 0.3;
			myMainMenuController.view.layer.shouldRasterize = YES;
			myMainMenuController.view.layer.shadowOffset = CGSizeMake(2.16,2.16);
			myMainMenuController.view.layer.shadowRadius = 3.0;
		}
		//
		myMainMenuController.view.alpha = 0.0;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(mainMenuLoaded:finished:context:)];
		[UIView setAnimationDuration:0.5];
		myMainMenuController.view.alpha = 1.0;
		[UIView commitAnimations];
	}
}

-(void)mainMenuLoaded:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	//
}
-(void)unloadMainMenu {
	if (myMainMenuController != nil) {
		[myMainMenuController.view removeFromSuperview];
		[myMainMenuController release];
		myMainMenuController = nil;
	}
}
 */
//
#pragma mark -
#pragma mark Sub Menu
-(void)loadSubMenu {
	if (mySubViewController == nil) {
		//[self closeOpenPages];
		mySubViewController = [[SubMenuViewController alloc] initWithNibName:@"SubMenuViewController" bundle:nil];
        
        //create a overlay view that is faded in and out behind the menu
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        background.backgroundColor = [UIColor blackColor];
        background.alpha = 0.0;
        [background setUserInteractionEnabled:NO];
        [self.view addSubview:background];
        //intro fix
        [self.view bringSubviewToFront:fakeloadingpage];
        //
        mySubViewController.fadeOverlayView = background;
        [background release];
        
		if (iPhoneMode) {
			mySubViewController.view.frame = CGRectMake(0, 262, mySubViewController.view.frame.size.width, mySubViewController.view.frame.size.height);
		} else {
			mySubViewController.view.center = CGPointMake(mySubViewController.view.center.x, self.view.frame.size.height - mySubViewController.view.frame.size.height/2+(23+mySubViewController.view.frame.size.height/2));
		}
		//myMainMenuController.view.center = CGPointMake(myMainMenuController.view.center.x+17.0, myMainMenuController.view.center.y+17.0);
		[self.view addSubview:mySubViewController.view];
		[mySubViewController initWithParent:self];
		mySubViewController.view.alpha = 0.0;
		/*
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(subMenuLoaded:finished:context:)];
		[UIView setAnimationDuration:0.5];
		mySubViewController.view.alpha = 1.0;
		[UIView commitAnimations];
		*/
		//[myRootViewController updateInterfaceIcons:1];
	}
}

-(void)subMenuLoaded:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	//NSLog(@"Sub menu shoud be visible");
}

-(void)unloadSubMenu {
	if (mySubViewController != nil) {
        [mySubViewController.fadeOverlayView release];
		[mySubViewController.view removeFromSuperview];
		[mySubViewController release];
		mySubViewController = nil;
	}
}

-(BOOL)isNavButtonsEnabled
{
    return (mySubViewController != nil && [mySubViewController isNavButtonsEnabled]);
}

#pragma mark -
#pragma mark Landingpage 
-(void)openLandingpage {
	if (myLandingpageViewController == nil) {
		//[self closeOpenPages];
		myLandingpageViewController = [[LandingPageViewController alloc] initWithNibName:@"LandingPageViewController" bundle:nil];
        myLandingpageViewController.navController = self;
		[self.view addSubview:myLandingpageViewController.view];
		if (projectInit) {
			myLandingpageViewController.view.alpha = 1.0;
		} else {
			myLandingpageViewController.view.alpha = 0.0;
		}
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(landingpageFadedIn:finished:context:)];
		[UIView setAnimationDuration:0.5];
		myLandingpageViewController.view.alpha = 1.0;
		[UIView commitAnimations];
		
		//[myRootViewController updateInterfaceIcons:1];
        [self homeButtonHidden:YES];
	}
}

-(void)landingpageFadedIn:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	if (projectInit) {
		projectInit = NO;
	}
	Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
	if ([appDelegate getIntroPresentationPlayed] == NO) {
        [appDelegate setIntroPresentationPlayed:YES];
    }
    
    [appDelegate playVoicePresentation];
	
	landingpage.hidden = YES;
}
#pragma mark -
#pragma mark Puzzles 
-(void)openPuzzles {
	if (myPuzzleDelegate == nil) {
		//[self closeOpenPages];
		myPuzzleDelegate = [[PuzzleDelegate alloc] initWithNibName:@"PuzzleMainView" bundle:nil];
		[self.view addSubview:myPuzzleDelegate.view];
		[myPuzzleDelegate initWithParent:self];
		myPuzzleDelegate.view.alpha = 0.0;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(puzzlesFadedIn:finished:context:)];
		[UIView setAnimationDuration:0.5];
		myPuzzleDelegate.view.alpha = 1.0;
		[UIView commitAnimations];
        
        [self homeButtonHidden:NO];

		
		//[myRootViewController updateInterfaceIcons:1];
	}
}

-(void)puzzlesFadedIn:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	//[self stopRunway];
}

-(void)preStartJigsawPuzzle:(int)puzzle {
	[myPuzzleDelegate preStartJigsawPuzzle:puzzle];
}

-(int) getPuzzleDifficulty {
	return [myPuzzleDelegate getLevelOfDifficulty];
}
-(void) setPuzzleLevelOfDifficulty:(int)diff {
	[myPuzzleDelegate setLevelOfDifficulty:diff];
}
-(void)hidePuzzleSubMenu {
	[mySubViewController hideShowSubMenu:YES];
}
#pragma mark -
#pragma mark Match
-(void)openMatch {
   // if(iPhoneMode) {
	if (myMatchMenuViewController == nil) {
		myMatchMenuViewController = [[MatchMenuViewController alloc] initWithNibName:@"MatchMenuViewController" bundle:nil];
		[myMatchMenuViewController initWithParent:self];
		[self.view addSubview:myMatchMenuViewController.view];
		myMatchMenuViewController.view.alpha = 0.0;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(matchFadedIn:finished:context:)];
		[UIView setAnimationDuration:0.5];
		myMatchMenuViewController.view.alpha = 1.0;
		[UIView commitAnimations];
	}
   /* } else {
        if(myMatchViewController == nil) {
            myMatchViewController = [[MatchViewController alloc] initWithNibName:@"MatchViewController" bundle:nil];
            [self.view addSubview:myMatchViewController.view];
            myMatchViewController.view.alpha = 0.0;
            [UIView animateWithDuration:0.5
                             animations:^{myMatchViewController.view.alpha = 1.0;}
                             completion:^(BOOL finished){ NSLog(@"Match faded in"); }];
        }
    }*/
}

-(void)matchFadedIn:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	//
}
-(void)preStartMatch:(int)dot {
	Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
	[appDelegate setSaveMatchDifficulty:currentMatchState];
	//[myMatchViewController initMatch:currentMatchState];
}
-(int) getMatchDifficulty {
	return [self getCurrentMatchState];
}
-(void) setMatchLevelOfDifficulty:(int)diff {
	Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
	currentMatchState=diff;
	[appDelegate setSaveMatchDifficulty:currentMatchState];
	[myMatchMenuViewController setDifficulty:diff];
}
-(void) setMatchingCard:(int)match {
    [mySubViewController setMatchingCard:match];
}
-(void) resetMatchingCards {
    [mySubViewController resetMatchingCards];
}
-(void)hideShowMatchSubmenu:(BOOL)hide; {
    [mySubViewController hideShowMatchSubmenu:hide];
}
-(BOOL) subMenuIsVisible {
    return [mySubViewController subMenuIsVisible];
}
#pragma mark -
#pragma mark Settings + info 
-(void)openSettings {
	if (mySettingsViewController == nil) {
		mySettingsViewController = [[ThomasSettingsViewController alloc] initWithNibName:@"ThomasSettingsViewController" bundle:nil];
		[mySettingsViewController initWithParent:self];
		[self.view addSubview:mySettingsViewController.view];
		mySettingsViewController.view.alpha = 0.0;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(settingsFadedIn:finished:context:)];
		[UIView setAnimationDuration:0.5];
		mySettingsViewController.view.alpha = 1.0;
		[UIView commitAnimations];
	}
}

-(void)settingsFadedIn:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	//
}

#pragma mark -
#pragma mark Paint  
-(void)openPaintOnIPhone {
	if (myPaintMenuViewController == nil) {
		myPaintMenuViewController = [[PaintMenuViewController alloc] initWithNibName:@"PaintMenuViewController" bundle:nil];
		[myPaintMenuViewController initWithParent:self];
		[self.view addSubview:myPaintMenuViewController.view];
		myPaintMenuViewController.view.alpha = 0.0;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(paintMenuIPhoneFadedIn:finished:context:)];
		[UIView setAnimationDuration:0.5];
		myPaintMenuViewController.view.alpha = 1.0;
		[UIView commitAnimations];
        
        [self homeButtonHidden:NO];

	}
}
-(void)paintMenuIPhoneFadedIn:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	//
}
-(void)openPaint {
	if (myPaintHolder == nil) {
		myPaintHolder = [[PaintHolderLandscapeViewController alloc] initWithNibName:@"PaintHolderLandscapeView" bundle:nil];
		[self.view addSubview:myPaintHolder.view];
		myPaintHolder.view.alpha = 0.0;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(paintFadedIn:finished:context:)];
		[UIView setAnimationDuration:0.5];
		myPaintHolder.view.alpha = 1.0;
		[UIView commitAnimations];
        
        [self homeButtonHidden:NO];

	}
}
-(void)paintFadedIn:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	//
}
-(void)refreshPaintImage:(int)image {
	//save selection
	Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
	[appDelegate setSaveCurrentPaintImage:image];
	//relay to paintholdercontroller
	[myPaintHolder refreshPaintImage:image];
}
#pragma mark -
#pragma mark Watch Movie
-(void)openWatch {
	if (myWatchMainViewController == nil) {
		myWatchMainViewController = [[WatchMainViewController alloc] initWithNibName:@"WatchMainViewController" bundle:nil];
		[self.view addSubview:myWatchMainViewController.view];
        if ([[Angelina_AppDelegate get] getSavedSelectedWatchMovie] != 0) {
            [self homeButtonHidden:YES];
        } else {
            [self homeButtonHidden:NO];
            myWatchMainViewController.view.alpha = 0.0;
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(watchFadedIn:finished:context:)];
            [UIView setAnimationDuration:0.5];
            myWatchMainViewController.view.alpha = 1.0;
            [UIView commitAnimations];
        }
        
		//[myRootViewController updateInterfaceIcons:1];
	}
}
-(void)watchFadedIn:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	//[self stopRunway];
}
-(void)videoFinishedPlaying {
	if (myWatchMainViewController != nil) {
		[myWatchMainViewController.view removeFromSuperview];
		[myWatchMainViewController release];
		myWatchMainViewController = nil;
		projectInit = YES;
		[self navigateFromMainMenuWithItem:NAV_WATCH];
		//[self openLandingpage];
		//[self adjustMainMenu];
	}
}
#pragma mark -
#pragma mark READ 
-(void) preOpenRead {


    /*CustomAlertViewController *alert = [[CustomAlertViewController alloc]init];
    alert.delegate = self;
    [alert show:self.view alertType:CAVCResumeAlert];
    [alert release];*/
    [currentScene startAnimation];
    [self checkForSceneDelayActions];
    //hack for showing the teaser
    mySubViewController.teaserWasShown = 1;
    [mySubViewController hideShowSubMenu:YES];
    //[currentScene startAnimation];
    //[self checkForSceneDelayActions];
   // mySubViewController.teaserWasShown = 1;
    //[mySubViewController hideShowSubMenu:YES];

    
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Do you want to go to the first page of the story or resume from this one?" delegate:self cancelButtonTitle:@"Page 1" otherButtonTitles:@"Resume", nil];
//	[alert show];
//	[alert release];
}
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//	if (buttonIndex == 0) {
//		//NSLog(@"This is button 0");
//		[PageHandler defaultHandler].currentPage = 1;
//	} else if (buttonIndex == 1) {
//		//NSLog(@"This is button 1");
//		//NSLog(@"Just stay on page");
//		[currentScene startAnimation];
//		[self checkForSceneDelayActions];
//	}
//}

- (void) CustomAlertViewController:(CustomAlertViewController *)alert wasDismissedWithValue:(NSInteger)value {
    if(alert.alertType == CAVCResumeAlert) {
        if (value == CAVCButtonTagResume) {
            [currentScene startAnimation];
            [self checkForSceneDelayActions];
            //hack for showing the teaser
            mySubViewController.teaserWasShown = 1;
        }
        else if (value == CAVCButtonTagPage1) {
            [PageHandler defaultHandler].currentPage = 1;
        }
        [mySubViewController hideShowSubMenu:YES];
    }
}

- (void)openPlay {
    //if cocos has not benn initialized, do so
    if (!cocosInit) {
        [self initCocos];
        cocosInit=YES;
        cocosShown=YES;
    }
    
    //if cocos is stopeed, start it up again
    if (!cocosShown) {
        [self startCocos];
    }
    
    CGRect bounds = [self.view bounds];
    NSLog(@"openPlay: bounds: w=%f h=%f", bounds.size.width, bounds.size.height);
    NSLog(@"orientation: %d", [CCDirector sharedDirector].deviceOrientation);
        
    glview.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
    
    [[CCDirector sharedDirector] reshapeProjection:CGSizeMake(bounds.size.width, bounds.size.height)];
    
    [glview layoutSubviews];
    
    [[CCDirector sharedDirector] setAnimationInterval:1.0/60];
    
    [self.view addSubview:glview];
    bubblePopRootViewController = [[BubblePopRootViewController alloc] initWithNibName:nil bundle:nil];
    bubblePopRootViewController.delegate = self;
    bubblePopRootViewController.wantsFullScreenLayout = YES;

    [bubblePopRootViewController setView:[CCDirector sharedDirector].openGLView];
    [bubblePopRootViewController startGame];
    [self homeButtonHidden:YES];
    [[CCDirector sharedDirector] resume];
    
}

-(void)openRead{
	if (myReadController==nil) {
		//if cocos has not benn initialized, do so
		if (!cocosInit) {
			[self initCocos];
			cocosInit=YES;
			cocosShown=YES;
		}
		//if cocos is stopeed, start it up again
		if (!cocosShown) {
			[self startCocos];
		}
        
		//get cocos view
		myReadController=[[ReadController alloc] init];
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {

			glview.layer.transform=CATransform3DIdentity;
			glview.layer.transform=CATransform3DMakeScale(0.9375/2, 0.9375/2, 1);
			glview.layer.transform=CATransform3DTranslate(glview.layer.transform, -580, -480+37, 0);
		}
        
        [glview layoutSubviews];
        
		myReadController.view.frame=glview.bounds;
		[myReadController.view addSubview:glview];
        turningPage=YES;
		[myReadController setupSwipe];
		
		//set first page
		currentScene=nil;
		nextScene=[[BookScene node] retain];
        
        [nextScene setPage:[PageHandler defaultHandler].currentPage];
		[[CCDirector sharedDirector] replaceScene:nextScene];
		
        //see if we need to replace the submenu fade
		[mySubViewController setSubmenuFade];
		
		[self.view addSubview:myReadController.view];
		myReadController.view.alpha = 0.0;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(readFadedIn:finished:context:)];
		[UIView setAnimationDuration:0.5];
		myReadController.view.alpha = 1.0;
		[UIView commitAnimations];
        
        [self homeButtonHidden:NO];
	} else {
        if ([nextScene page] != [PageHandler defaultHandler].currentPage) {
            nextScene=[[BookScene node] retain];
            [nextScene setPage:[PageHandler defaultHandler].currentPage];
            [[CCDirector sharedDirector] replaceScene:nextScene];
        }
    }
    readOverlayViewController.view.hidden = NO;
}
-(void)readFadedIn:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:currentScene priority:0 swallowsTouches:YES];
	//[currentScene startAnimation];
	//[self sceneCleanup];
	turningPage=NO;
	
    //dont resume if we are already on first page
    if (resumePage) {
        [self preOpenRead];
    }
    else {
        [currentScene startAnimation];
		[self checkForSceneDelayActions];
    }

    //reset the resume page variable
    self.resumePage = NO;
    //check for narration
	//if (currentNarrationSetting) {
    //Play the speaker
    //NSLog(@"Play speaker on scene: %i", [[sceneData objectAtIndex:currentReadPage] integerValue]);
	//	[self playNarrationOnScene];
	//}
	
	/*
	Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
	if ([appDelegate getSaveMusicSetting]) {
		[appDelegate loadReadMusic];
	}
	 */
	//Enable arrow navigation
	[mySubViewController enableTappedNavButton];
}


//XXX-mk could this all potetialy be cleaned up?
-(void) checkForSceneDelayActions {
	//NSLog(@"checkForSceneDelayActions");
	NSString *thePath = [[NSBundle mainBundle] pathForResource:@"scenedelay" ofType:@"plist"];
	NSArray *delaycheck = [[NSArray alloc] initWithContentsOfFile:thePath];
	NSDictionary *scenedelay = [NSDictionary dictionaryWithDictionary:[delaycheck objectAtIndex:[PageHandler defaultHandler].currentPage - 1]];
    
    Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
    
	//SPEAKER DELAY
	float delay = [[scenedelay objectForKey:@"delay"] floatValue];
	speakerIsDelayed = YES;
	[appDelegate setNarrationTime:delay];
	readSceneDelay = [[NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(doSceneDelayActions) userInfo:nil repeats:NO] retain];    
    
	[delaycheck release];
}
-(void)removePendingSceneDelay {
	//NSLog(@"removePendingSceneDelay");
	if (readSceneDelay != nil) {
		if ([readSceneDelay isValid]) {
			speakerIsDelayed = NO;
			[speakerDelayStart release];
			[readSceneDelay invalidate];
			readSceneDelay = nil;
		}
	}
}
-(void) doSceneDelayActions {
	//NSLog(@"doSceneDelayActions");
	if (speakerIsDelayed == NO) return;
	speakerIsDelayed = NO;
    [self showHotspotIndicators];
	if ([self getNarrationValue]) {
		//Play the speaker
		[self playNarrationOnScene];
	}
	if (speakerWhileOff) {
		//[self forceNarrationOnScene]; <--Not In Angelina
	}else {
		//[self playNarrationOnScene]; <--Not In Angelina
	}
    [readSceneDelay release];
    readSceneDelay = nil;

    if ([self getEndPageIsDisplayed]) {
        [self displayEndPage];
    }
}

//Display the hotspot indicators for the scene
-(void) showHotspotIndicators {
    //only display hotspots under some circumstances
    if ([currentScene isScreenshot] or [mySubViewController subMenuIsVisible] or [[AVQueueManager sharedAVQueueManager] itemInQueue:@"hotspot_movie"]) {
        return;
    }
    
    NSArray *hotspotIndicators = [currentScene getHotspotIndicators];
    if ([hotspotIndicators count]>0) {
        CGRect myframe = CGRectMake(0, 0, 1024, 768);
		UIView *myhotspotholder = [[UIView alloc] initWithFrame:myframe];
        myhotspotholder.userInteractionEnabled = NO;
		myhotspotholder.backgroundColor = [UIColor clearColor];
        float animationDuration = 0.0;
		for (unsigned i=0; i<[hotspotIndicators count]; i++) {
			//add hotspots...
			//NSLog(@"Adding hotspot");
            
            int hotspotIndicator = (i % 2) + 1;
            int numImages = 20;
            
            NSMutableArray *images = [NSMutableArray array];
            CGSize size;
            for (int j = 1; j <= numImages; j++) {
                NSString *filename = [NSString stringWithFormat:@"HotspotIndicator%i_%02i.png", hotspotIndicator, j];
                UIImage *image = [UIImage imageNamed:filename];
                [images addObject:image];
                size = image.size;
            }
            
			UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
            imageView.animationImages = images;
            imageView.animationDuration = numImages * (1.0/25.0);
            animationDuration = imageView.animationDuration;
            imageView.animationRepeatCount = 1;
            [imageView startAnimating];
			NSDictionary *getpos = [NSDictionary dictionaryWithDictionary:[hotspotIndicators objectAtIndex:i]];
			float myx = [[getpos objectForKey:@"x"] floatValue];
			float myy = [[getpos objectForKey:@"y"] floatValue];
			
            //adjust for offset
			CGPoint sceneoffset = [currentScene getLayerOffset];
            myx -= sceneoffset.x;
            myy -= sceneoffset.y;
            //
            
			if (iPhoneMode) {
				myx*=kiPhoneLayerScale;
				myy*=kiPhoneLayerScale;
			}
			imageView.center = CGPointMake(myx, myy);
			if (myx>0 || myy>0) [myhotspotholder addSubview:imageView];
			[imageView release];
		}
		[self.view addSubview:myhotspotholder];
		self.hotspotHolder = myhotspotholder;
        [myhotspotholder release];
        [self performSelector:@selector(hotspotsFadedIn) withObject:nil afterDelay:animationDuration];
        /*
		[myhotspotholder release];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(hotspotsFadedIn:finished:context:)];
		[UIView setAnimationDuration:2.0];
		self.hotspotHolder.alpha = 1.0;
		self.hotspotHolder.alpha = 0.0;
		[UIView commitAnimations];
         */
        [self adjustNavigation];
	}
}
/*
-(void)hotspotsFadedIn:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
*/
-(void)hotspotsFadedIn {
    [self.hotspotHolder removeFromSuperview];
	//respawn hotspots
	//readHotspotRespawnTimer = [[NSTimer scheduledTimerWithTimeInterval:7 target:self selector:@selector(respawnHotspots) userInfo:nil repeats:NO] retain];
}

-(void)checkIfNarrationDateIsDelayed {
	//NSLog(@"checkIfNarrationDateIsDelayed");
	Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
	if (speakerIsDelayed) {
		//kill timer
		if ([readSceneDelay isValid]) {
			[speakerDelayStart release];
			[readSceneDelay invalidate];
			readSceneDelay = nil;
		}
		//get new time
		NSDate *old = [appDelegate getNarrationTime];
		NSDate *now = [NSDate date];
		NSTimeInterval difference = [now timeIntervalSinceDate:old];
		//NSLog(@"This is the difference: %f", float(difference));
		if (fullSpeakerDelayTime >= 0) {
			[appDelegate setSavedDelaytime:difference];
		}
	}
}

-(BOOL)getSpeakerIsDelayed {
	return speakerIsDelayed;
}
-(void) setSpeakerIsDelayed:(BOOL)delayed {
	speakerIsDelayed = delayed;
}
- (void)pauseReadPlayback {
	Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
	[appDelegate pauseReadPlayback];
}
- (void)startReadPlayback {
	Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
	[appDelegate startReadPlayback];
}
-(void) displayEndPage {
    // allocate end page ticket view
    if (self.endPageViewController == nil) {
        self.endPageViewController = [[[EndPageViewController alloc] initWithNibName:@"EndPageViewController" bundle:nil] autorelease];
    }
    if (self.endPageMoreAppsViewController == nil) {
        self.endPageMoreAppsViewController = [[[EndPageMoreAppsViewController alloc] initWithNibName:@"EndPageMoreAppsViewController" bundle:nil] autorelease];
        self.endPageMoreAppsViewController.view.alpha = 1.0;
    }
    
    self.endPageViewController.view.alpha = 0.0f;
    [self.view addSubview:self.endPageViewController.view];
    
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.3];
	self.endPageViewController.view.alpha = 1.0f;
	[UIView commitAnimations];
    
    [self adjustNavigation];
}

-(void) showNavigation {
    if (self.homeButton.frame.origin.x < 0) {
        self.homeButton.frame = CGRectMake(self.homeButton.frame.origin.x+self.view.frame.size.width, self.homeButton.frame.origin.y, self.homeButton.frame.size.width, self.homeButton.frame.size.height);
    }

    [[self readOverlayViewController] showNavigation]; 
    [mySubViewController showNavigation];
}

-(void) hideNavigation {
    if (self.homeButton.frame.origin.x > 0) {
        self.homeButton.frame = CGRectMake(self.homeButton.frame.origin.x-self.view.frame.size.width, self.homeButton.frame.origin.y, self.homeButton.frame.size.width, self.homeButton.frame.size.height);
    }

    [[self readOverlayViewController] hideNavigation];
    [mySubViewController hideNavigation];

}

-(void) removeEndPage {
    if (self.endPageViewController != nil) {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.endPageViewController.view.alpha = 0.0f;
                             self.endPageMoreAppsViewController.view.alpha = 0.0f;
                         }
                         completion:^(BOOL finished) {
                             [self.endPageViewController.view removeFromSuperview];
                             self.endPageViewController = nil;
                             
                             [self.endPageMoreAppsViewController.view removeFromSuperview];
                             self.endPageMoreAppsViewController = nil;
                             
                             //reset values that might have been changed in slide replace view
                             [self showNavigation];
                         }];        
    }

}


-(void) slideReplaceView:(UIView *)oldView withView:(UIView *)newView forward:(BOOL) forward {    
    //add subview outside window
    newView.frame = CGRectMake(newView.frame.size.width*(forward ? 1.0f : -1.0f), newView.frame.origin.y, newView.frame.size.width, newView.frame.size.height);
    [[self view] addSubview:newView];
    
    //animate push on complete remove from superview
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         newView.frame = CGRectMake(0, newView.frame.origin.y, newView.frame.size.width, newView.frame.size.height);
                         oldView.frame = CGRectMake(oldView.frame.size.width*(forward ? -1.0f : 1.0f), oldView.frame.origin.y, oldView.frame.size.width, oldView.frame.size.height);
                         if (forward) {
                             [self hideNavigation];
                         }
                         else {
                             [self showNavigation];
                         }
                     }
                     completion:^(BOOL finished) {
                         [oldView removeFromSuperview];
                     }];
}

- (void) showMoreApps {
    
    UIView *newView = self.endPageMoreAppsViewController.view;
    UIView *oldView = self.endPageViewController.view;
    
    [self.endPageMoreAppsViewController resetScroll];
    
    [self slideReplaceView:oldView withView:newView forward:YES];    
    
    if (!iPhoneMode && [mySubViewController subMenuIsVisible]) {
        [mySubViewController hideShowSubMenu:YES withDuration:0.3f];
    }

    [self adjustNavigation];
}
-(void) hideMoreApps {
    UIView *newView = self.endPageViewController.view;
    UIView *oldView = self.endPageMoreAppsViewController.view;
    
    [self slideReplaceView:oldView withView:newView forward:NO];
    
    if (!iPhoneMode && ![mySubViewController subMenuIsVisible]) {
        [mySubViewController hideShowSubMenu:NO withDuration:0.3f];
    }
    
    [self adjustNavigation];
}

- (void)showPopoverImage:(NSString*)imageFilePath withSourcePosition:(CGPoint)position;
{
    self.popoverImageViewController = [[[PopoverImageViewController alloc] initWithImageFilePath:imageFilePath withSourcePosition:position] autorelease];
    [self.view addSubview:self.popoverImageViewController.view];
    [self.popoverImageViewController showPopover:YES];
    [[AVQueueManager sharedAVQueueManager] pause];
//    [[AVQueueManager sharedAVQueueManager] removeFromQueue:@"narration"];
}

- (void)removePopoverImage
{

    if (self.popoverImageViewController == nil) {
        return;
    }
    
    [self.popoverImageViewController.view removeFromSuperview];
    [self.popoverImageViewController stopAudio];
    self.popoverImageViewController = nil;
    
    // only play hotspots directly after popover
    if (([[AVQueueManager sharedAVQueueManager] itemInQueue:@"hotspot_movie"]) != nil) {
        [[AVQueueManager sharedAVQueueManager] play];
    }
    else {
        //if not hotspot show the replay button at close
        [self setReplayVisibleOnScene];
    }
}

#pragma mark ReadOverlayView
/*
-(void)showReadOverlayViewWithText:(NSString *)text style:(int)style{
	;//don't worry about it, it is for the iPhone
}
 */
-(void)showReadOverlayViewWithText:(NSString *)text style:(ReadOverlayViewStyle)style{
	NSLog(@"This is current read page: %i", 
          [PageHandler defaultHandler].currentPage);
	if(readOverlayView || [PageHandler defaultHandler].currentPage == 0 || 
       [PageHandler defaultHandler].currentPage == ((int)[sceneData count])-1) return;
	readOverlayView=[[[ReadOverlayView alloc]initWithFrame:self.view.bounds text:text style:style]autorelease];
	[readOverlayView setTarget:self selector:@selector(setOverlayViewToNil)];
	[readOverlayView presentInViewAnimated:self.view];
}

-(void)setPopover:(NSString *)popover {
    if (popover) {
        if (readOverlayViewController.danceButton.hidden == YES) {
            [readOverlayViewController.danceButton setAlpha:0.0];
            [readOverlayViewController.danceButton setHidden:NO];
            [UIView animateWithDuration:1.0// * 100
                                  delay:0.0
                                options:UIViewAnimationCurveEaseOut
                             animations:^{
                                 readOverlayViewController.danceButton.alpha = 1.0;
                             }
                             completion:^(BOOL finished){}
             ];
        }
    }
    else {
        [UIView animateWithDuration:1.0// * 100
                              delay:0.0
                            options:UIViewAnimationCurveEaseOut
                         animations:^{
                             readOverlayViewController.danceButton.alpha = 0.0;
                         }
                         completion:^(BOOL finished){[readOverlayViewController.danceButton setHidden:YES];}
         ];
    }
    [readOverlayViewController setPopoverName:popover];
}

#pragma mark -
#pragma mark COUNT THE DOTS
//Will be replaced with Match
-(void)openDots {
	if (myDotViewController ==nil) {
		//[self closeOpenPages];
		myDotViewController = [[DotViewController alloc] init];
		[self.view addSubview:myDotViewController.view];
		myDotViewController.view.alpha = 0.0;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(dotsFadedIn:finished:context:)];
		[UIView setAnimationDuration:0.5];
		myDotViewController.view.alpha = 1.0;
		[UIView commitAnimations];
		
		//[myRootViewController updateInterfaceIcons:1];
	}
	
}

-(void)dotsFadedIn:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	
}

-(void)preStartDots:(int)dot {
	Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
	[appDelegate setSaveDotDifficulty:currentDotState];
	[appDelegate setSaveCurrentDotImage:dot];
	//[myDotViewController setPuzzle:(dot-1)%3];
	[myDotViewController initPuzzle:(dot-1)%3 :currentDotState==0];
}
-(int) getDotDifficulty {
	//return [myDotViewController getDifficulty];
	return [self getCurrentDotsState];
}
-(void) setDotLevelOfDifficulty:(int)diff {
	Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
	currentDotState=diff;
	[appDelegate setSaveDotDifficulty:currentDotState];
	[myDotViewController setDifficulty:diff==0];
}
-(void)hideDotsSubMenu {
	//Call this from Dots if needed to hide the submenu for dots
	[mySubViewController hideShowSubMenu:YES];	
}
 
#pragma mark -
#pragma mark TRAIN UPDATES in other sections
-(void) updatePaintTrain:(int)image {
	int thepage = image;
	int startposx = -25;
	int tracklength = 963;
	int numpuzzles = 10;
	
	float thumbwidth = 129;
	float trainwidth = 110;
	float compensate = (thumbwidth-trainwidth)/2;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.8];
	mySubViewController.train.center = CGPointMake(startposx+((tracklength/numpuzzles)*thepage)-compensate, mySubViewController.train.center.y);
	[UIView commitAnimations];
	
	//4.0 specific - doesn't work on 3.2
	/*
	[UIView animateWithDuration:0.8
					 animations:^{mySubViewController.train.center = CGPointMake(startposx+((tracklength/numpuzzles)*thepage)-compensate, mySubViewController.train.center.y);}
					 completion:^(BOOL finished){ NSLog(@"Paint train finished moving"); }];
	 */
}
-(void) updatePuzzleTrain:(int)image {
    int thepage = image;
	int startposx = -146.3;
	int tracklength = 1081.3;
	int numpuzzles = 5;
	
	float thumbwidth = 129;
	float trainwidth = 110;
	float compensate = (thumbwidth-trainwidth)/2;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.8];
	mySubViewController.train.center = CGPointMake(startposx+((tracklength/numpuzzles)*thepage)-compensate, mySubViewController.train.center.y);
	[UIView commitAnimations];
    //CODE BELOW POSITIONS TRAIN ABOVE RESPECTIVE PUZZLE THUMBNAIL
    /*--->
	int thepage = [myPuzzleDelegate getCurrentPuzzle];
	
	int startposx = -36;
	int tracklength = 760;
	float thumbwidth = 129;
	float trainwidth = 66;
	float compensate = (thumbwidth-trainwidth)/2;
	int numpuzzles = 5;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.8];
	mySubViewController.train.center = CGPointMake(startposx+((tracklength/numpuzzles)*thepage)-compensate, mySubViewController.train.center.y);
	[UIView commitAnimations];
	*/
	//<----
	/*--> ANIMT
	[UIView animateWithDuration:0.8
					 animations:^{mySubViewController.train.center = CGPointMake(startposx+((tracklength/numpuzzles)*thepage)-compensate, mySubViewController.train.center.y);}
					 completion:^(BOOL finished){ NSLog(@"Puzzle train finished moving"); }];
	 */
	/*
	int startposx = 20;
	int tracklength = 963;
	int numpuzzles = 6;
	
	float thumbwidth = 129;
	float trainwidth = 66;
	float compensate = (thumbwidth-trainwidth)/2;
	
	
	[UIView animateWithDuration:0.8
					 animations:^{mySubViewController.train.center = CGPointMake(startposx+((tracklength/numpuzzles)*thepage)-compensate, mySubViewController.train.center.y);}
					 completion:^(BOOL finished){ NSLog(@"Puzzle train finished moving"); }];
	 */
}
-(void) updateDotTrain:(int)image {
	int thepage = image;
	int startposx = -36;
	int tracklength = 445;
	float thumbwidth = 129;
	float trainwidth = 66;
	float compensate = (thumbwidth-trainwidth)/2;
	int numpuzzles = 3;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.8];
	mySubViewController.train.center = CGPointMake(startposx+((tracklength/numpuzzles)*thepage)-compensate, mySubViewController.train.center.y);
	[UIView commitAnimations];
	
	/*
	[UIView animateWithDuration:0.8
					 animations:^{mySubViewController.train.center = CGPointMake(startposx+((tracklength/numpuzzles)*thepage)-compensate, mySubViewController.train.center.y);}
					 completion:^(BOOL finished){ NSLog(@"Dots train finished moving"); }];
	 */
}
#pragma mark -
#pragma mark Getter and Setters
-(int) getCurrentNavigationItem {
	return currentNavigationItem;
}
-(int) getLastVisitedMenuItem {
	NSLog(@"This is the lastVisited in returFromMain: %i", lastVisitedMenuItem);
	return lastVisitedMenuItem;
}
-(int) getSavedNavigationItem {
	return savedNavigationItem;
}

-(int) getNumberOfReadPages {
	return sceneData.count;
}
-(BOOL)getEndPageIsDisplayed {
    //last page is the endpage
    return sceneData.count == [PageHandler defaultHandler].currentPage;
}
-(int) getCurrentPaintPage {
	Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
	currentPaintImage = [appDelegate getSaveCurrentPaintImage];
	return currentPaintImage;
}
-(void) setCurrentPaintPage:(int)page {
	Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
	[appDelegate setSaveCurrentPaintImage:page];
}

- (int) getCurrentDotsPage {
	Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
	currentDotImage = [appDelegate getSaveCurrentDotImage];
	return currentDotImage;
}
-(int)getCurrentDotsState{
	Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
	currentDotState = [appDelegate getSaveDotDifficulty];
	return currentDotState;
}
-(int)getCurrentMatchState {
    Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
	currentMatchState = [appDelegate getSaveMatchDifficulty];
    NSLog(@"This is currentMatchState: %i", currentMatchState);
	return currentMatchState;
}
-(BOOL)getNarrationValue {
	Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
	return [appDelegate getSaveNarrationSetting];
}
-(void)setNarrationValue:(int)value {
	Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
	speakerWhileOff=NO;
	if (!turningPage && currentScene!=nil && value==0 && !speakerWhileOff) {
		//[currentScene setReplayVisible];
	} else if (!turningPage && currentScene!=nil&& !speakerWhileOff) {
		//[currentScene setReplayHidden];
	}

	[appDelegate setSaveNarrationSetting:value]; 
}
-(int)getMusicValue {
	Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
	currentMusicSetting = [appDelegate getSaveMusicSetting];
	return currentMusicSetting;
}
-(void)setMusicValue:(int)value {
	Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
	[appDelegate setSaveMusicSetting:value];
}
-(BOOL)getSwipeValue {
	Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
	return [appDelegate getSwipeInReadIsTurnedOff];
}
-(void)setSwipeValue:(BOOL)value {
	Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
	[appDelegate setSwipeInReadIsTurnedOff:value];
}
-(BOOL) getIPhoneMode {
	return iPhoneMode;
}
-(NSString*)getCurrentLanguage {
	return [[Angelina_AppDelegate get] getCurrentLanguage];
}
#pragma mark -
#pragma mark COCOS 
-(void)initCocos{
	if (![CCDirector setDirectorType:kCCDirectorTypeDisplayLink]) {
		[CCDirector setDirectorType:kCCDirectorTypeNSTimer];
	}	
	CCDirector *director = [CCDirector sharedDirector];
	[director setDisplayFPS:NO];
	[director setAnimationInterval:1.0/60];
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
	//CGRect eagleframe = CGRectMake(0, 0, 480, 360);
	glview = [EAGLView viewWithFrame:CGRectMake(0, 0, 1024, 768)
						 pixelFormat:kEAGLColorFormatRGBA8
						 depthFormat:GL_DEPTH_COMPONENT24_OES];
	[director setOpenGLView:glview];	
	[glview setMultipleTouchEnabled:NO];
	glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
	[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
	currentScene=nil;
	nextScene=nil;
	CCScene *scene=[CCScene node];
	//[scene addChild:[CCColorLayer layerWithColor:ccc4(255, 0, 0, 255)]];
	[director runWithScene: scene];
}

-(void) turnpage:(BOOL)forwards{
	if (turningPage) {
		return;
	}
    if (forwards && [self getEndPageIsDisplayed]) {
        return;
    }
    if (!forwards && [PageHandler defaultHandler].currentPage == 1) {
        return;
    }
	//disable arrow temporary
	[mySubViewController disableTappedNavButton];
	if (forwards) {
        [PageHandler defaultHandler].currentPage = [PageHandler defaultHandler].currentPage + 1;
	}else {
        [PageHandler defaultHandler].currentPage = [PageHandler defaultHandler].currentPage - 1;
	}
}


-(void) sceneTransitionDone{
	[[CCDirector sharedDirector] setDepthTest:NO];
	BOOL first=currentScene==nil;
	//NSLog(@"scene transition done");
	//switch scene
	if (nextScene!=nil) {
		[currentScene release];
		currentScene=nextScene;
		nextScene=nil;
	}
	//if cocos is shutting down, cancel
	if (queueClear) {
		queueClear=NO;
		[self clearCocos];
		return;
	}
	//if it's not the first page, start it up and clean up old resources
	//(if it's the first page it will be started in readFadedIn instead)
	if (!first){
		[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:currentScene priority:0 swallowsTouches:YES];
		[currentScene startAnimation];
		//[self performSelector:@selector(sceneCleanup) withObject:nil afterDelay:0.2f];
		turningPage=NO;
		//check for narration
		//if (currentNarrationSetting) {
			//Play the speaker
			//NSLog(@"Play speaker on scene: %i", [[sceneData objectAtIndex:currentReadPage] integerValue]);
		//	[self playNarrationOnScene];
		//}
		//Enable arrow navigation
		//[mySubViewController enableTappedNavButton];
		//check for scene delays
		[self checkForSceneDelayActions];
		
	}
	//check for narration - moved to scene delay
	//if (currentNarrationSetting) {
		//Play the speaker
	//	NSLog(@"Play speaker on scene: %i", [[sceneData objectAtIndex:currentReadPage] integerValue]);
	//	[self playNarrationOnScene];
	//}
	//Enable arrow navigation
	[mySubViewController enableTappedNavButton];
    
    if ([self getEndPageIsDisplayed] && !iPhoneMode) {
        [mySubViewController hideShowSubMenu:NO];
    }
    
    [currentScene precache:currentScene.page + 1];
    
}

-(void) sceneCleanup{
	//release cocos data
	//[[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
}

-(void) fullCleanup{
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
	[[CCTextureCache sharedTextureCache] removeAllTextures];
}

#pragma mark -
#pragma mark AUDIO
-(void)playNarrationOnScene {
    //skip resume if narration is disabled
    if (![self getNarrationValue]) return;
	//NSLog(@"playNarrationOnScene");
	//if ([PageHandler defaultHandler].currentPage == 0 && iPhoneMode) return;
	//if ((currentReadPage == 0 || currentReadPage == [sceneData count]-1) && iPhoneMode) return;
	if (currentNavigationItem != NAV_READ) return;
    
    [currentScene playAudio];

    /* Old thomas stuff
	Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
	if ([appDelegate getSaveNarrationSetting]) {
		if (appDelegate.speakerPlayer.playing) [appDelegate stopReadSpeakerPlayback];
		NSString *mypath = @"";
        if (useSpeakerSilence) {
            mypath = @"silence";
        } else {
            if ([[appDelegate getCurrentLanguage] isEqualToString:@"en_GB"]) {
                mypath = [NSString stringWithFormat:@"Speaker_Scene_%i" "_UK", [[sceneData objectAtIndex:currentReadPage] integerValue]];
            } else {
                mypath = [NSString stringWithFormat:@"Speaker_Scene_%i", [[sceneData objectAtIndex:currentReadPage] integerValue]];
            }
        }
		NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:mypath ofType:@"m4a"]];
		AVAudioPlayer *thePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
		[fileURL release];
		if (thePlayer) {
			appDelegate.speakerPlayer = thePlayer;
			[thePlayer release];
			appDelegate.speakerPlayer.volume = 1.0;
			[appDelegate startReadSpeakerPlayback];
			if (!turningPage && currentScene!=nil){
				[currentScene setReplayHidden];
			}
		}
	}*/
}

-(void)forceNarrationOnScene {
	//NSLog(@"forceNarrationOnScene");
	if (currentNavigationItem != NAV_READ) return;
    [[cdaAnalytics sharedInstance] trackEvent:@"READ reload narration"];
    [[cdaAnalytics sharedInstance] trackEvent:@"READ reload narration"];

    //stop playback of hotspot
    [[AVQueueManager sharedAVQueueManager] removeFromQueue:@"hotspot_movie"];

    AVQueueItem *queueItem = [[AVQueueManager sharedAVQueueManager] itemInQueue:@"narration"];
    
    if (queueItem == nil) {
        speakerWhileOff=YES;
        Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
        [[self currentScene] playAudio];
        [appDelegate forceReadSpeakerPlayback];
    }
    else {
        [[AVQueueManager sharedAVQueueManager] play];
    }
}

-(void)stopNarrationOnScene {
    [[self currentScene] stopAudio];
}

-(void)pauseNarrationOnScene {
    [self.currentScene pauseAudio];
}

-(void)restartNarrationOnScene {
    //stop playback of hotspot
    [[AVQueueManager sharedAVQueueManager] removeFromQueue:@"hotspot_movie"];

    [self.currentScene restartAudio];
}

-(void)resumeNarrationOnScene {
	//NSLog(@"resumeNarrationOnScene");
	if (currentNavigationItem != NAV_READ) return;
    //skip resume if narration is disabled
    if (![self getNarrationValue]) return;
        
	Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
	if (speakerIsDelayed) {
		float thetime = [appDelegate getSavedDelaytime];
		//NSLog(@"Should be some time here: %f", thetime);
        [readSceneDelay release];
		readSceneDelay = [[NSTimer scheduledTimerWithTimeInterval:thetime target:self selector:@selector(doSceneDelayActions) userInfo:nil repeats:NO] retain];
	} else {
        [self.currentScene unpauseAudio];
	}
}
-(void)narrationFinished{
	speakerWhileOff=NO;
	//Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
	if (!turningPage && currentScene!=nil){
		//[currentScene setReplayVisible];
	}
}
- (void)playCardSound:(int)sound {
	Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
	[appDelegate playCardSound:sound];
}
#pragma mark -
#pragma mark Application related

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	landscapeRight=toInterfaceOrientation==UIInterfaceOrientationLandscapeRight;
	[currentScene orientationChanged:landscapeRight];
	[nextScene orientationChanged:landscapeRight];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[currentScene release];
	[nextScene release];
	[[CCDirector sharedDirector] release];
	[sceneData release];
	[myPuzzleDelegate release];
	[readSceneDelay release];
	[speakerDelayStart release];
	[endview release];
	[hotspotHolder release];
    [readOverlayViewController release];
    self.mySubViewController = nil;
    self.popoverImageViewController = nil;
    self.landingpagePreviousAnimation = nil;

    self.endPageViewController = nil;
    self.endPageMoreAppsViewController = nil;
    
    [super dealloc];
}

-(void) pauseCocos{
	if (cocosInit && cocosShown && !cocosPaused) {
		cocosPaused=YES;
		[PlaySoundAction pauseSounds];
		[[CCDirector sharedDirector] pause];
	}	
}
-(void) resumeCocos{
	if (cocosInit && cocosShown && cocosPaused) {
		cocosPaused=NO;
		[PlaySoundAction resumeSounds];
		[[CCDirector sharedDirector] resume];
	}
}
//pause and resume with fade down on scene
-(void) pauseCocos:(BOOL)fade {
	if (cocosInit && cocosShown && !cocosPaused) {
		if (fade) {
//			glview.alpha = 0.5;
			readViewIsPaused = YES;
		}
		cocosPaused=YES;
		[PlaySoundAction pauseSounds];
		[[CCDirector sharedDirector] pause];
	}	
}
-(void) resumeCocos:(BOOL)fade {
	if (cocosInit && cocosShown && cocosPaused) {
		if (fade) {
			glview.alpha = 1.0;
			readViewIsPaused = NO;
		}
		cocosPaused=NO;
		[PlaySoundAction resumeSounds];
		[[CCDirector sharedDirector] resume];
	}
}
-(void)unPauseReadView {
	if (readViewIsPaused) {
		//unpause
		readViewIsPaused = NO;
		[mySubViewController hideShowSubMenu:YES];
	}
}
-(BOOL)getReadViewIsPaused {
	return readViewIsPaused;
}
-(BOOL)getCocosPaused {
	return cocosPaused;
}
-(void) stopCocos{
	//NSLog(@"stopCocos");
	if (cocosInit && cocosShown) {
		cocosShown=NO;
		[[CCDirector sharedDirector] stopAnimation];
        [currentScene cocosDidStop];
	}
}

-(void) startCocos{
	//NSLog(@"startCocos");
	if (cocosInit && !cocosShown) {
		cocosShown=YES;
		[[CCDirector sharedDirector] startAnimation];
	}
}

-(void) clearCocos{
	NSLog(@"clearCocos");
	if (!cocosInit || !cocosShown) {
		return;
	}
	
	if (nextScene!=nil) {
		queueClear=YES;
		return;
	}
	
	NSLog(@"clearCocos - wasn't returned");
	
	[PlaySoundAction stopSounds];
	[PlaySoundAction clearSounds];
	[PlaySoundAction setSoundsPrevented:NO];
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:currentScene];
	[currentScene stopAnimation];
	[currentScene release];
	currentScene=nil;
	
	CCScene *scene=[CCScene node];
	[scene addChild:[CCColorLayer layerWithColor:ccc4(255, 255, 255, 255)]];
	[[CCDirector sharedDirector] replaceScene:scene];
    [self stopCocos];
    [self sceneCleanup];
	//[self performSelector:@selector(sceneCleanup) withObject:nil afterDelay:0.2f];
	//[self performSelector:@selector(stopCocos) withObject:nil afterDelay:0.3f];
}

-(void) killCocos{
	if (cocosInit) {
		[[CCDirector sharedDirector] end];
	}
}
-(void) resetCocos{
	if (cocosInit) {
		[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
	}
}

- (void) setReplayHiddenOnScene {
    [currentScene setReplayHidden];
}

-(void) setReplayVisibleOnScene {
    [currentScene setReplayVisible];

}

- (void)AVManagerItemStartedPlaying:(NSNotification *)notification
{
    AVQueueItem *item = [[notification userInfo] objectForKey:@"item"];
    if ([item.userData isEqual:@"narration"]) {
        [currentScene setReplayHidden];
    }
}

- (void)AVManagerItemStoppedPlaying:(NSNotification *)notification
{
    AVQueueItem *item = [[notification userInfo] objectForKey:@"item"];
    if ([item.userData isEqual:@"narration"]) {
        [self setReplayVisibleOnScene];
    }
    if ([item.userData isEqual:@"hotspot_movie"]) {
        [[AVQueueManager sharedAVQueueManager] pause];
    }
}

- (void)AVManagerItemPaused:(NSNotification *)notification
{
    AVQueueItem *item = [[notification userInfo] objectForKey:@"item"];
    if ([item.userData isEqual:@"narration"]) {
        [self setReplayVisibleOnScene];
    }
}

- (void)AVManagerItemUnpaused:(NSNotification *)notification
{
    AVQueueItem *item = [[notification userInfo] objectForKey:@"item"];
    if ([item.userData isEqual:@"narration"]) {
        [currentScene setReplayHidden];
    }
}

- (void)currentPageDidChange:(NSNotification *)notification
{
    int currentPage = [[[notification userInfo] objectForKey:@"currentPage"] intValue];

    // Read
    if (currentNavigationItem == NAV_READ) {
        if (!currentScene.isScreenshot) {
            [currentScene turnIntoScreenshot];
            nextScene=[[BookScene node] retain];
            [nextScene setPage:currentPage];
            [[CCDirector sharedDirector] setDepthTest:YES];
            [[CCDirector sharedDirector] replaceScene:[TransitionPageTurnWithBackground transitionWithDuration:1.0f scene:nextScene backwards:(currentPage<currentScene.page)]];
            
            [mySubViewController disableTappedNavButton];
            [[CCTouchDispatcher sharedDispatcher] removeDelegate:currentScene];
        }
        [[AVQueueManager sharedAVQueueManager] stop];
        
        if (![self getEndPageIsDisplayed]) {
            [self removeEndPage];
        }
    } else {
        //[[CCDirector sharedDirector] replaceScene:nextScene];
    }
    
    // Puzzle
    [self preStartJigsawPuzzle:currentPage];
    if (currentNavigationItem == NAV_PUZZLE) {
        [mySubViewController enableTappedNavButton];
    }
    // Paint
    else if (currentNavigationItem == NAV_PAINT) {
        [mySubViewController enableTappedNavButton];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:mySubViewController.fadeOverlayView];
    
    if (CGRectContainsPoint(mySubViewController.fadeOverlayView.frame, touchLocation) && mySubViewController.fadeOverlayView.userInteractionEnabled) {
        NSLog(@"Tapped fadeOverlayView");
        if (mySubViewController.pausedQueue) {
            [[AVQueueManager sharedAVQueueManager] play];
        }
        [mySubViewController hideShowSubMenu:YES];
    }    
}

- (void)bubblePopHomeButtonPressed
{
    [self navigateFromMainMenuWithItem:NAV_MAIN];
}

@end
