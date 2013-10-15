//
//  RootViewController.m
//  AngelinaGame
//
//  Created by Karl Söderström on 2011-06-27.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

//
// RootViewController + iAd
// If you want to support iAd, use this class as the controller of your iAd
//

#import "cocos2d.h"

#import "BubblePopRootViewController.h"
#import "AngelinaScene.h"
#import "GameConfig.h"
#import "TutorialViewController.h"
#import "FinalScoreLayer.h"
#import "TitleScene.h"
#import "ScoreIncrementAction.h"
#import "StarAnimationViewController.h"
#import "AudioHelper.h"
#import "GameState.h"
#import "Animations.h"
#import "FlurryGameEvent.h"


@implementation BubblePopRootViewController

@synthesize gameOverViewController = _gameOverViewController;
@synthesize hudViewController = _hudViewController;
@synthesize pauseViewController = _pauseViewController;
@synthesize tutorialViewController = _tutorialViewController;
@synthesize titleViewController = _titleViewController;
@synthesize starAnimationViewController = _starAnimationViewController;
@synthesize introViewController = _introViewController;
@synthesize menuViewController = _menuViewController;
@synthesize delegate = _delegate;
@synthesize whiteglyphs = _whiteglyphs;
@synthesize texture_sheet = _texture_sheet;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLastLifeLost:) name:AngelinaGame_LastLifeLost object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGameOver:) name:AngelinaGame_GameOver object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGamePaused:) name:AngelinaGame_GamePaused object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGameResumed:) name:AngelinaGame_GameResumed object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTutorialStarted:) name:AngelinaGame_TutorialStarted object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTutorialEnded:) name:AngelinaGame_TutorialEnded object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScoreChange:) name:AngelinaGame_ScoreChanged object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGameWillStart:) name:AngelinaGame_GameWillStart object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleIntroMovieDidFinish:) name:AngelinaGame_IntroMovieDidFinish object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGameDidStart:) name:AngelinaGame_GameDidStart object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGameDidEnd:) name:AngelinaGame_GameDidEnd object:nil];
	}
    
	return self;
}

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
    
    
}

- (void)fadeOutCurrentView
{
    if (self.gameOverViewController != nil) {
        UIViewController *vc = [self.gameOverViewController retain];
        self.gameOverViewController = nil;
        [UIView animateWithDuration:0.4 animations:^{
            vc.view.alpha = 0;
        } completion:^(BOOL finished) {
            [vc.view removeFromSuperview];
            [vc viewDidDisappear:YES];
            [vc release];
        }];
    }
    if (self.pauseViewController != nil) {
        UIViewController *vc = [self.pauseViewController retain];
        self.pauseViewController = nil;
        [UIView animateWithDuration:0.4 animations:^{
            vc.view.alpha = 0;
        } completion:^(BOOL finished) {
            [vc.view removeFromSuperview];
            [vc viewDidDisappear:YES];
            [vc release];
        }];
    }
    if (self.tutorialViewController != nil) {
        UIViewController *vc = [self.tutorialViewController retain];
        self.tutorialViewController = nil;
        [UIView animateWithDuration:0.4 animations:^{
            if ([vc isViewLoaded]) {
                vc.view.alpha = 0;
            }
        } completion:^(BOOL finished) {
            [vc.view removeFromSuperview];
            [vc viewDidDisappear:YES];
            [vc release];
        }];
    }
    if (self.titleViewController != nil) {
        UIViewController *vc = [self.titleViewController retain];
        self.titleViewController = nil;
        [UIView animateWithDuration:0.4 animations:^{
            vc.view.alpha = 0;
        } completion:^(BOOL finished) {
            [vc.view removeFromSuperview];
            [vc viewDidDisappear:YES];
            [vc release];
        }];
    }
    if (self.starAnimationViewController != nil) {
        UIViewController *vc = [self.starAnimationViewController retain];
        self.starAnimationViewController = nil;
        [UIView animateWithDuration:0.4 animations:^{
            vc.view.alpha = 0;
        } completion:^(BOOL finished) {
            [vc.view removeFromSuperview];
            [vc viewDidDisappear:YES];
            [vc release];
        }];
    }
}

- (void)handleGameOver:(NSNotification *) notification
{
    [FlurryGameEvent logEventPrefixWithMode:@"Bubbles per Game" withParameters:[GameState sharedInstance].bubbleStats];
    [FlurryGameEvent endTimedEventPrefixWithMode:@"Time per Game"];
    
    [self.starAnimationViewController.view removeFromSuperview];
    self.starAnimationViewController = nil;
    self.gameOverViewController = [[[GameOverViewController alloc] initWithNibName:@"GameOverViewController" bundle:nil] autorelease];
    self.gameOverViewController.view.alpha = 0.0;
    [self.view addSubview:self.gameOverViewController.view];
    [UIView animateWithDuration:0.2 animations:^{
        self.gameOverViewController.view.alpha = 1.0;
    }];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.4 scene:[TitleScene scene]]]; 
    [self.menuViewController setIsShowing:YES animated:YES];
    [self.menuViewController bringToFront];
}

- (void)handleLastLifeLost
{
    [[AngelinaScene getCurrent].bubbleLayer popAllBubbles];
    [[AngelinaScene getCurrent].bubbleLayer unscheduleAllSelectors]; 
    [[AngelinaScene getCurrent].thoughtBubble unscheduleAllSelectors]; 
    [[AngelinaScene getCurrent] addChild:[FinalScoreLayer node]];
    
    self.starAnimationViewController = [[[StarAnimationViewController alloc] init] autorelease];
    CGSize winSize = [CCDirector sharedDirector].winSize;
    self.starAnimationViewController.view.center = CGPointMake(winSize.width/2, winSize.height/3);
    CGAffineTransform transform = CGAffineTransformMakeScale(scaleOfUIKitScreen, scaleOfUIKitScreen);
    self.starAnimationViewController.view.transform = transform;
    [self.view addSubview:self.starAnimationViewController.view];
    [self.starAnimationViewController startAnimation];
    [self.menuViewController bringToFront];
    
}

- (void)handleLastLifeLost:(NSNotification *) notification
{
    [self performSelectorOnMainThread:@selector(handleLastLifeLost) withObject:nil waitUntilDone:NO];
}

- (void)handleGamePaused:(NSNotification *) notification
{
    self.pauseViewController = [[[PauseViewController alloc] initWithNibName:@"PauseViewController" bundle:nil] autorelease];
    self.pauseViewController.view.alpha = 0.0;
    [self.view addSubview:self.pauseViewController.view];
    [UIView animateWithDuration:0.2 animations:^{
        self.pauseViewController.view.alpha = 1.0;
    }];
    [self.menuViewController setIsShowing:YES animated:YES];
    [self.menuViewController bringToFront];
    
}

- (void)handleGameResumed:(NSNotification *) notification
{
    [self fadeOutCurrentView];
    [self setupHUDView];
    [self.menuViewController setIsShowing:NO animated:YES];
    [self.menuViewController bringToFront];
}

- (void)handleTutorialStarted:(NSNotification *) notification
{
    [self fadeOutCurrentView];
    [AudioHelper playBackgroundAudio:AngelinaGameAudio_MenuMusic];
    self.tutorialViewController = [[[TutorialViewController alloc] initWithNibName:@"TutorialViewController" bundle:nil] autorelease];
    
    [self.view addSubview:self.tutorialViewController.view];
    [self.view bringSubviewToFront:self.tutorialViewController.view];
    
    if ([[notification.userInfo objectForKey:@"GameType"] isEqual:@"Classic"]) {
        [self.tutorialViewController.chooseTutorialView setAlpha:0];
        [self.tutorialViewController btnClassicAction:nil];
    }
    else if ([[notification.userInfo objectForKey:@"GameType"] isEqual:@"Clock"]) {
        [self.tutorialViewController.chooseTutorialView setAlpha:0];
        [self.tutorialViewController btnClockAction:nil];
    }
    [self.menuViewController setIsShowing:NO animated:YES];
    [self.menuViewController bringToFront];
}

- (void)handleTutorialEnded:(NSNotification *) notification
{
    [self fadeOutCurrentView];
    
    if (notification.userInfo != nil) {
        if ([[notification.userInfo objectForKey:@"nextScene"] isEqual:@"title"]) {
            [self showTitleAnimated:YES];
        } else {
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.4 scene:[AngelinaScene scene]]];
        }
    }
    [self.menuViewController setIsShowing:NO animated:YES];
    [self.menuViewController bringToFront];
}

- (void)handleScoreChange:(NSNotification *)notification
{
    NSUInteger oldScore = [[[notification userInfo] objectForKey:@"oldScore"] intValue];
    NSUInteger score = [[[notification userInfo] objectForKey:@"score"] intValue];
    ScoreIncrementAction *action = [ScoreIncrementAction actionWithDuration:0.5 fromScore:oldScore toScore:score withAudio:NO];
    CCEaseSineOut *sine = [CCEaseSineOut actionWithAction:action];
    [[AngelinaScene getCurrent].scoreLabel runAction:sine];
    
    if (score > oldScore) {
        if ((score % 500) < (oldScore % 500)) {
            //[AudioHelper playAudio:AngelinaGameAudio_500p];
            CCScaleBy *scaleUp = [CCScaleTo actionWithDuration:0.2 scale:scaleValueToScreen(1.2)];
            CCScaleBy *scaleDown = [CCScaleTo actionWithDuration:0.2 scale:scaleOfScreen];
            CCSequence *seq = [CCSequence actionOne:scaleUp two:scaleDown];
            [[AngelinaScene getCurrent].scoreLabel runAction:seq];        
        } else if ((score % 100) < (oldScore % 100)) {
            //[AudioHelper playAudio:AngelinaGameAudio_100p];
            CCScaleBy *scaleUp = [CCScaleTo actionWithDuration:0.2 scale:scaleValueToScreen(1.2)];
            CCScaleBy *scaleDown = [CCScaleTo actionWithDuration:0.2 scale:scaleOfScreen];
            CCSequence *seq = [CCSequence actionOne:scaleUp two:scaleDown];
            [[AngelinaScene getCurrent].scoreLabel runAction:seq];
        }
    }
}

- (void)handleGameWillStart:(NSNotification *)notification
{
    AngelinaScene *scene = notification.object;
    
    [AudioHelper playBackgroundAudio:AngelinaGameAudio_GameMusic];
    [self fadeOutCurrentView];
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    UIImageView *ready = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ready.png"]] autorelease];
    ready.center = CGPointMake(winSize.width/2, winSize.height/2);
    ready.alpha = 0;
    
    UIImageView *go = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"go.png"]] autorelease];
    go.center = ready.center;
    go.alpha = 0;
    
    StarAnimationViewController *animation = [[[StarAnimationViewController alloc] init] autorelease];
    animation.view.center = CGPointMake(ready.center.x, ready.center.y - 50);
    
    [self.view addSubview:ready];
    [self.view addSubview:go];
    [self.view addSubview:animation.view];
    
    CGAffineTransform transform = CGAffineTransformMakeScale(scaleOfUIKitScreen, scaleOfUIKitScreen);
    ready.transform = transform;
    go.transform = transform;
    animation.view.transform = transform;
    
    [[Animations sharedInstance] preloadAnimation:@"Angelina_Ready"];
    [[Animations sharedInstance] preloadAnimation:@"Angelina_HereWeGo"];
    
    [UIView animateWithDuration:0.2 animations:^(void) {
        ready.alpha = 1;
    } completion:^(BOOL finished) {
        [[Animations sharedInstance] startAnimation:@"Angelina_Ready" onNode:scene.angelina];
        [animation performSelector:@selector(startAnimation) withObject:nil afterDelay:1.8];
        [UIView animateWithDuration:0.5 delay:1.5 options:UIViewAnimationCurveEaseIn animations:^(void) {
            ready.alpha = 0;
        } completion:^(BOOL finished) {
            [[Animations sharedInstance] startAnimation:@"Angelina_HereWeGo" onNode:scene.angelina];
            [UIView animateWithDuration:0.4 animations:^(void) {
                go.alpha = 1;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.4 delay:0.8 options:UIViewAnimationCurveEaseIn animations:^(void) {
                    go.alpha = 0;
                    animation.view.alpha = 0;
                } completion:^(BOOL finished) {
                    [ready removeFromSuperview];
                    [go removeFromSuperview];
                    [animation.view removeFromSuperview];
                }];
                [[NSNotificationCenter defaultCenter] postNotificationName:AngelinaGame_GameDidStart object:self];
            }];
        }];
    }];
    [self.menuViewController setIsShowing:NO animated:YES];
    [self.menuViewController bringToFront];
}


- (void)handleIntroMovieDidFinish:(NSNotification *)notification
{
    [UIView animateWithDuration:0.4 animations:^(void) {
        self.introViewController.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.introViewController.view removeFromSuperview];
        self.introViewController = nil;
    }];
    [self startGame];
}

- (void)startGame
{
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    [[CCDirector sharedDirector] setProjection:kCCDirectorProjection2D];
    
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    
    [AudioHelper setup];
    [Scaling sharedInstance];
    
    self.whiteglyphs = [[CCTextureCache sharedTextureCache] addImage:@"ab_whiteglyphs_texture.png"];
    self.texture_sheet = [[CCTextureCache sharedTextureCache] addImage:@"ab_texture_sheet.png"];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"ab_whiteglyphs_texture.plist" texture:self.whiteglyphs];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"ab_texture_sheet.plist" texture:self.texture_sheet];
    
    if ([CCDirector sharedDirector].runningScene == nil) {
        [[CCDirector sharedDirector] runWithScene: [TitleScene scene]];
    } else {
        [[CCDirector sharedDirector] replaceScene:[TitleScene scene]];
    }
    [self showTitleAnimated:NO];
    
    [AudioHelper playBackgroundAudio:AngelinaGameAudio_MenuMusic];
    
#ifdef ANGELINA_BUBBLE_POP_INAPP
    self.menuViewController = [[[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil] autorelease];
    [self.view addSubview:self.menuViewController.view];
#endif // ANGELINA_BUBBLE_POP_INAPP
}

- (void)stopGame
{
    [AudioHelper stopBackgroundAudio];
    [[Animations sharedInstance] stopCurrentAnimation];
    TitleScene *titleScene = (TitleScene *)[[CCDirector sharedDirector].runningScene getChildByTag:ANGELINA_TITLE_TAG];
    [[CCDirector sharedDirector] replaceScene:[CCScene node]];
    [titleScene removeFromParentAndCleanup:YES];
    [[CCDirector sharedDirector] setProjection:kCCDirectorProjection3D];
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    [self.gameOverViewController.view removeFromSuperview];
    [self.hudViewController.view removeFromSuperview];
    [self.pauseViewController.view removeFromSuperview];
    [self.tutorialViewController.view removeFromSuperview];
    [self.titleViewController.view removeFromSuperview];
    [self.starAnimationViewController.view removeFromSuperview];
    [self.introViewController.view removeFromSuperview];
    [self.menuViewController.view removeFromSuperview];
    self.gameOverViewController = nil;
    self.hudViewController = nil;
    self.pauseViewController = nil;
    self.tutorialViewController = nil;
    self.titleViewController = nil;
    self.starAnimationViewController = nil;
    self.introViewController = nil;
    self.menuViewController = nil;
    [Scaling reset];
}


- (void)handleGameDidStart:(NSNotification *)notification
{ 
    [self fadeOutCurrentView];
    [FlurryGameEvent logEventPrefixWithMode:@"Time per Game" withParameters:nil timed:YES];
#ifdef ANGELINA_BUBBLE_POP_INAPP
    [self.menuViewController setIcon:AngelinaGameMenuIcon_Pause];
#endif // ANGELINA_BUBBLE_POP_INAPP
    
    [self setupHUDView];
    [self.menuViewController setIsShowing:NO animated:YES];
    [self.menuViewController bringToFront];
}

- (void)handleGameDidEnd:(NSNotification *)notification
{
    [FlurryGameEvent endTimedEventPrefixWithMode:@"Time per Game"];
    
    [self fadeOutCurrentView];
    
#ifdef ANGELINA_BUBBLE_POP_INAPP
    [self.menuViewController setIcon:AngelinaGameMenuIcon_Star];
#endif // ANGELINA_BUBBLE_POP_INAPP
    
    [AudioHelper playBackgroundAudio:AngelinaGameAudio_MenuMusic];
    [self showTitleAnimated:YES];
    [self.menuViewController setIsShowing:NO animated:YES];
    [self.menuViewController bringToFront];
}

- (void)showIntroMovie
{
    self.introViewController = [[[BubblePopIntroViewController alloc] init] autorelease];
    [self.view addSubview:self.introViewController.view];
    [self.introViewController play];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW,0);
    dispatch_async(queue,^{
        // Preload audio
        [AudioHelper preloadAudio];
    });
}

- (void)setupHUDView
{
#ifndef ANGELINA_BUBBLE_POP_INAPP
    if (self.hudViewController == nil) {
        self.hudViewController = [[[HUDViewController alloc] initWithNibName:@"HUDViewController" bundle:nil] autorelease];
        // The HUD should always be just above the gl view
        [self.view insertSubview:self.hudViewController.view atIndex:0];
    }
#endif // ANGELINA_BUBBLE_POP_INAPP    
}

- (void)showTitleAnimated:(BOOL)animated
{
    if (animated) {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.2 scene:[TitleScene scene]]];
        [[CCDirector sharedDirector] resume];
    } else {
        [[CCDirector sharedDirector] replaceScene:[TitleScene scene]];            
    }
    self.titleViewController = [[[TitleViewController alloc] initWithNibName:@"TitleViewController" bundle:nil] autorelease];
    self.titleViewController.delegate = self.delegate;
    self.titleViewController.view.alpha = 0;
    self.titleViewController.view.userInteractionEnabled = NO;
    [self.view addSubview:self.titleViewController.view];
    [UIView animateWithDuration:0.4 animations:^(void) {
        self.titleViewController.view.alpha = 1;
    } completion:^(BOOL finished) {
        self.titleViewController.view.userInteractionEnabled = YES;
    }];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
	//
	// There are 2 ways to support auto-rotation:
	//  - The OpenGL / cocos2d way
	//     - Faster, but doesn't rotate the UIKit objects
	//  - The ViewController way
	//    - A bit slower, but the UiKit objects are placed in the right place
	//
	
#if GAME_AUTOROTATION==kGameAutorotationNone
	//
	// EAGLView won't be autorotated.
	// Since this method should return YES in at least 1 orientation, 
	// we return YES only in the Portrait orientation
	//
	return ( interfaceOrientation == UIInterfaceOrientationPortrait );
	
#elif GAME_AUTOROTATION==kGameAutorotationCCDirector
	//
	// EAGLView will be rotated by cocos2d
	//
	// Sample: Autorotate only in landscape mode
	//
	if( interfaceOrientation == UIInterfaceOrientationLandscapeLeft ) {
		[[CCDirector sharedDirector] setDeviceOrientation: kCCDeviceOrientationLandscapeRight];
	} else if( interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		[[CCDirector sharedDirector] setDeviceOrientation: kCCDeviceOrientationLandscapeLeft];
	}
	
	// Since this method should return YES in at least 1 orientation, 
	// we return YES only in the Portrait orientation
	return ( interfaceOrientation == UIInterfaceOrientationPortrait );
	
#elif GAME_AUTOROTATION == kGameAutorotationUIViewController
	//
	// EAGLView will be rotated by the UIViewController
	//
	// Sample: Autorotate only in landscpe mode
	//
	// return YES for the supported orientations
	
	return ( UIInterfaceOrientationIsLandscape( interfaceOrientation ) );
	
#else
#error Unknown value in GAME_AUTOROTATION
	
#endif // GAME_AUTOROTATION
	
	
	// Shold not happen
	return NO;
}

//
// This callback only will be called when GAME_AUTOROTATION == kGameAutorotationUIViewController
//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	//
	// Assuming that the main window has the size of the screen
	// BUG: This won't work if the EAGLView is not fullscreen
	///
	CGRect screenRect = [[UIScreen mainScreen] bounds];
	CGRect rect = CGRectZero;
	
	if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)		
		rect = screenRect;
	
	else if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
		rect.size = CGSizeMake( screenRect.size.height, screenRect.size.width );
	
	CCDirector *director = [CCDirector sharedDirector];
	EAGLView *glView = [director openGLView];
	float contentScaleFactor = [director contentScaleFactor];
	
	if( contentScaleFactor != 1 ) {
		rect.size.width *= contentScaleFactor;
		rect.size.height *= contentScaleFactor;
	}
	glView.frame = rect;
}
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [self.gameOverViewController.view removeFromSuperview];
    [self.hudViewController.view removeFromSuperview];
    [self.pauseViewController.view removeFromSuperview];
    [self.tutorialViewController.view removeFromSuperview];
    [self.titleViewController.view removeFromSuperview];
    [self.starAnimationViewController.view removeFromSuperview];
    [self.introViewController.view removeFromSuperview];
    [self.menuViewController.view removeFromSuperview];
    self.gameOverViewController = nil;
    self.hudViewController = nil;
    self.pauseViewController = nil;
    self.tutorialViewController = nil;
    self.titleViewController = nil;
    self.starAnimationViewController = nil;
    self.introViewController = nil;
    self.menuViewController = nil;    
    self.whiteglyphs = nil;
    self.texture_sheet = nil;
}


- (void)dealloc {
    [self.gameOverViewController.view removeFromSuperview];
    [self.hudViewController.view removeFromSuperview];
    [self.pauseViewController.view removeFromSuperview];
    [self.tutorialViewController.view removeFromSuperview];
    [self.titleViewController.view removeFromSuperview];
    [self.starAnimationViewController.view removeFromSuperview];
    [self.introViewController.view removeFromSuperview];
    [self.menuViewController.view removeFromSuperview];
    self.gameOverViewController = nil;
    self.hudViewController = nil;
    self.pauseViewController = nil;
    self.tutorialViewController = nil;
    self.titleViewController = nil;
    self.starAnimationViewController = nil;
    self.introViewController = nil;
    self.menuViewController = nil;  
    self.whiteglyphs = nil;
    self.texture_sheet = nil;    
    [super dealloc];
}


@end

