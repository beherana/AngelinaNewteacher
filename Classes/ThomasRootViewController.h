//
//  ThomasRootViewController.h
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/10/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "cocos2d.h"
#import "ReadOverlayView.h"
#import "PopoverImageViewController.h"
#import "CustomAlertViewController.h"
#import "ReadOverlayViewController.h"
#import "BubblePopRootViewController.h"
#import "EndPageViewController.h"
#import "EndPageMoreAppsViewController.h"

//the different menu choices
#define NAV_MAIN   2
#define NAV_READ   3
#define NAV_WATCH  4
#define NAV_PAINT  5
#define NAV_PUZZLE 6
#define NAV_PLAY 8

//Notification
#define kNavigateFromMainMenu @"NavigateFromMainMenu"

@class PuzzleDelegate;
@class ThomasSettingsViewController;
@class SubMenuViewController;
@class PaintMenuViewController;
@class LandingPageViewController;
@class ReadController;
@class PaintHolderLandscapeViewController;
@class WatchMainViewController;
@class DotViewController;
@class IntroViewController;
@class MatchMenuViewController;
@class MatchViewController;
@class BookScene;

@interface ThomasRootViewController : UIViewController <UIApplicationDelegate, CustomAlertViewControllerDelegate, BubblePopDelegate> {

	LandingPageViewController *myLandingpageViewController;
	PuzzleDelegate *myPuzzleDelegate;
	PaintHolderLandscapeViewController *myPaintHolder;
	SubMenuViewController *mySubViewController;
	WatchMainViewController *myWatchMainViewController;
	ReadController *myReadController;
	DotViewController *myDotViewController;
	IntroViewController *myIntroViewController;
	PaintMenuViewController *myPaintMenuViewController;
	MatchMenuViewController *myMatchMenuViewController;
	ThomasSettingsViewController *mySettingsViewController;
    MatchViewController *myMatchViewController;
    PopoverImageViewController *popoverImageViewController;
    ReadOverlayViewController *readOverlayViewController;
	BubblePopRootViewController *bubblePopRootViewController;
    IBOutlet UIImageView *fakeloadingpage;
	IBOutlet UIImageView *landingpage;
    UIButton *homeButton;

	
	BOOL projectInit;
	BOOL menusoundInit;
	
	int currentNavigationItem;
	int savedNavigationItem;
	NSArray *sceneData;
	
	int currentPaintImage;
	int currentPuzzle;
	int currentDotImage;
	int currentDotState;
    int currentMatchState;
	
    BOOL currentNarrationSetting;
	BOOL currentMusicSetting;
	
	EAGLView *glview;
	BookScene *currentScene;
	BookScene *nextScene;
	BOOL cocosInit;
	BOOL cocosShown;
	BOOL cocosPaused;
	BOOL queueClear;
	BOOL turningPage;
	BOOL landscapeRight;
	
	BOOL readViewIsPaused;
	
	NSTimer *readSceneDelay;
	float fullSpeakerDelayTime;
	NSDate *speakerDelayStart;
	NSDate *speakerDelayPaused;
	BOOL speakerIsDelayed;

	BOOL showingEndPageView;
	UIImageView *endview;

	BOOL speakerWhileOff;
	
	UIView *hotspotHolder;
	
	BOOL iPhoneMode;
	int lastVisitedMenuItem;
    
    BOOL resumePage;
	
	//@private
	ReadOverlayView *readOverlayView;
    
    //Used when speaker audio is missing
    BOOL useSpeakerSilence;
    
    
    ///TEMP
    //int goingToReadPageTransitionFix;
}

@property (nonatomic, readonly) PuzzleDelegate *myPuzzleDelegate;
@property (nonatomic,retain) SubMenuViewController *mySubViewController;
@property (nonatomic,retain) ReadOverlayViewController *readOverlayViewController;
@property (nonatomic,retain) PopoverImageViewController *popoverImageViewController;
@property (retain) EndPageViewController *endPageViewController;
@property (retain) EndPageMoreAppsViewController *endPageMoreAppsViewController;

@property (nonatomic, retain) IBOutlet UIButton *homeButton;

@property (nonatomic, retain) NSArray *sceneData;
@property (nonatomic,readonly) BookScene *currentScene;
@property (nonatomic,readonly) BOOL landscapeRight;

@property (nonatomic, retain) NSTimer *readSceneDelay;
@property (nonatomic, retain) NSDate *speakerDelayStart;

@property (nonatomic, retain) UIImageView *endview;

@property (nonatomic, retain) UIView *hotspotHolder;
@property (retain) NSString *landingpagePreviousAnimation;

@property (nonatomic, assign) BOOL resumePage;

-(void) removeFakeLoadingPage;

-(IBAction) homeButtonPressed:(id)sender;
-(void) homeButtonHidden:(BOOL)hidden;

-(void)navigateFromMainMenuWithItem:(int)item;
-(void)returnFromMainMenuToLastItem;
-(void)unloadCurrentNavigationItem;
-(void)adjustNavigation;
-(void)videoFinishedPlaying;
-(void)introFinishedPlaying;
-(void)showFakeLandingPage;

-(void)preStartJigsawPuzzle:(int)puzzle;

-(int) getCurrentPaintPage;
-(void) setCurrentPaintPage:(int)page;
-(int) getCurrentDotsPage;
-(int) getCurrentDotsState;
-(int) getCurrentMatchState;
-(int) getNumberOfReadPages;
-(BOOL)getEndPageIsDisplayed;
-(BOOL)getIPhoneMode;
-(NSString*)getCurrentLanguage;

-(int) getCurrentNavigationItem;
-(int) getLastVisitedMenuItem;

-(void) turnpage:(BOOL)forwards;
-(void) sceneTransitionDone;
-(void) sceneCleanup;
-(void) fullCleanup;
-(void) pauseCocos;
-(void) resumeCocos;
//pause and resume with fade down on scene
-(void)unPauseReadView;
-(BOOL)getReadViewIsPaused;
-(void) pauseCocos:(BOOL)fade;
-(void) resumeCocos:(BOOL)fade;
-(BOOL)getCocosPaused;
//
-(void) stopCocos;
-(void) startCocos;
-(void) clearCocos;
-(void) killCocos;
-(void) resetCocos;

-(int) getSavedNavigationItem;
-(int) getPuzzleDifficulty;
-(void) setPuzzleLevelOfDifficulty:(int)diff;
-(void)hidePuzzleSubMenu;

-(void)preStartDots:(int)dot;
-(int) getDotDifficulty;
-(void) setDotLevelOfDifficulty:(int)diff;
-(void)hideDotsSubMenu;

-(int) getMatchDifficulty;
-(void) setMatchLevelOfDifficulty:(int)diff;
-(void) setMatchingCard:(int)match;
-(void) resetMatchingCards;
-(void)preStartMatch:(int)dot;
-(void)hideShowMatchSubmenu:(BOOL)hide;
-(BOOL) subMenuIsVisible;

-(BOOL)getNarrationValue;
-(void)setNarrationValue:(int)value;
-(int)getMusicValue;
-(void)setMusicValue:(int)value;
-(BOOL)getSwipeValue;
-(void)setSwipeValue:(BOOL)value;

-(void)playNarrationOnScene;
-(void)pauseNarrationOnScene;
-(void)resumeNarrationOnScene;
-(void)stopNarrationOnScene;
-(void)restartNarrationOnScene;

-(void)setReplayVisibleOnScene;
-(void)setReplayHiddenOnScene;

-(void)refreshPaintImage:(int)image;
-(void) updatePaintTrain:(int)image;
-(void) updatePuzzleTrain:(int)image;
-(void) updateDotTrain:(int)image;
-(void) checkForSceneDelayActions;
-(void)removePendingSceneDelay;
-(void) doSceneDelayActions;
-(void)hotspotsFadedIn;
//-(void)hotspotsFadedIn:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context;
-(void) showHotspotIndicators;

-(void)narrationFinished;

-(void)checkIfNarrationDateIsDelayed;
-(BOOL)getSpeakerIsDelayed;
-(void) setSpeakerIsDelayed:(BOOL)delayed;

-(void) displayEndPage;
-(void) removeEndPage;
-(void) showMoreApps;
-(void) hideMoreApps;

- (void)showPopoverImage:(NSString*)imageFilePath withSourcePosition:(CGPoint)position;
- (void)removePopoverImage;

- (void)playFXEventSound:(NSString *)sound;
- (void)playCardSound:(int)sound;
- (void)pauseReadPlayback;
- (void)startReadPlayback;

-(void) forceNarrationOnScene;
//<<----- HAVE A LOOK AT THIS - DO IT CONDITIONAL INSIDE READ?
//-(void)showReadOverlayViewWithText:(NSString *)text style:(int)style;
-(void)showReadOverlayViewWithText:(NSString *)text style:(ReadOverlayViewStyle)style;
//<<<<----
-(void)setPopover:(NSString *)popover;

-(BOOL)isNavButtonsEnabled;

- (void)bubblePopHomeButtonPressed;

@end
