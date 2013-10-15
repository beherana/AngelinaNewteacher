//
//  SubMenuViewController.h
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/21/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubMenuPuzzles.h"
#import "SubMenuMatch.h"
#import "SubMenuPaint.h"
#import "SubMenuRead.h"


@class ThomasRootViewController;
@class SubMenuPuzzles;
@class SubMenuMatch;
@class SubMenuPaint;
@class SubMenuRead;

#define kThumbHolderTag 100

#define kSubMenuHidden @"SubMenuHidden"
#define kSubMenuActive @"SubMenuActive"

@interface SubMenuViewController : UIViewController {

	ThomasRootViewController *myparent;
	SubMenuPuzzles *mySubMenuPuzzles;
	SubMenuMatch *mySubMenuMatch;
	SubMenuPaint *mySubMenuPaint;
	SubMenuRead *mySubMenuRead;
	
	IBOutlet UIView *subContentHolder;
	IBOutlet UIView *train;
	IBOutlet UIImageView *tracksLeftRight;
	IBOutlet UIImageView *trainlight;
	IBOutlet UIImageView *traindark;
	IBOutlet UIView *wagon;
	
	IBOutlet UIButton *leftnavRead;
	IBOutlet UIButton *rightnavRead;
    
    IBOutlet UIButton *navToReadButton;
    IBOutlet UIButton *navToPaintButton;
    IBOutlet UIButton *navToPuzzleButton;
    
    IBOutlet UIImageView  *readIndicatorImage;
    IBOutlet UIImageView  *paintIndicatorImage;
    IBOutlet UIImageView  *puzzleIndicatorImage;

	
	IBOutlet UIImageView *blackSubmenuFade;
	IBOutlet UIImageView *whiteSubmenuFade;
    
    IBOutlet UIImageView *fullTrack;
	
	IBOutlet UILabel *pageNumber;
    
    IBOutlet UIScrollView *thumbScrollView;
    IBOutlet UIImageView *selectedThumbImageView;
	
    //shows a dimmed fade on the parent view
    UIView *fadeOverlayView;
    
	BOOL subMenuIsVisible;
	BOOL subMenuIsRemoved;
    BOOL teaserWasShown; //tease and hide the sub menu again.
    
    BOOL pausedQueue;
	
	int visibleInterface;
	
	BOOL iPhoneMode;
@private
    NSMutableArray *_thumbControllers;
	
}

@property (nonatomic, retain) IBOutlet UILabel *pageNumber;
@property (nonatomic, retain) IBOutlet UIView *train;

@property (nonatomic, retain) IBOutlet UIButton *navToReadButton;
@property (nonatomic, retain) IBOutlet UIButton *navToPaintButton;
@property (nonatomic, retain) IBOutlet UIButton *navToPuzzleButton;

@property (nonatomic, retain) IBOutlet UIImageView *readIndicatorImage;
@property (nonatomic, retain) IBOutlet UIImageView *paintIndicatorImage;
@property (nonatomic, retain) IBOutlet UIImageView *puzzleIndicatorImage;

@property (nonatomic, retain) IBOutlet UIScrollView *thumbScrollView;
@property (nonatomic, retain) IBOutlet UIImageView *selectedThumbImageView;

@property (nonatomic, retain) UIView *fadeOverlayView;

@property (readonly) BOOL subMenuIsVisible;
@property (nonatomic) BOOL teaserWasShown;
@property (nonatomic) BOOL pausedQueue;

-(void) initWithParent: (id) parent;

-(void)hideSubMenu;
-(void)hideShowSubMenu:(BOOL)hide;
-(void)hideShowSubMenu:(BOOL)hide withDuration:(CFTimeInterval) duration;


-(void)addInterfaceToSubMenu:(int)interface;
-(void)removeInterfaceFromSubMenu;

-(void)setSubmenuFade;
-(void)restoreSubmenuFade;

-(void)disableTappedNavButton;
-(void)enableTappedNavButton;
-(BOOL)isNavButtonsEnabled;
-(IBAction)navLeftInRead:(id)sender;
-(IBAction)navRightInRead:(id)sender;
// nav between read, paint and puzzle
-(IBAction)navFunctionality:(id)sender;

//style the menu acroding to choice
-(void)highlightRead;
-(void)highlightPaint;
-(void)highlightPuzzle;
-(void)selectReadButton;
-(void)selectPaintButton;
-(void)selectPuzzleButton;

-(void)hideShowNavButtons;
-(void)hideBothNavButtonsAnimated;
-(void)showBothNavButtonsAnimated;
-(void)showNavigation;
-(void)hideNavigation;

-(void)preStartJigsawPuzzle:(int)puzzle;
-(int) getPuzzleDifficulty;
-(void) setPuzzleLevelOfDifficulty:(int)diff;

-(void)preStartDots:(int)dot;
-(int) getDotDifficulty;
-(void) setDotLevelOfDifficulty:(int)diff;

-(void)preStartMatch:(int)dot;
-(int) getMatchDifficulty;
-(void) setMatchLevelOfDifficulty:(int)diff;
-(void) setMatchingCard:(int)match;
-(void) resetMatchingCards;
-(void)hideShowMatchSubmenu:(BOOL)hide;
-(void)fadeInOverlayView;
-(void)fadeOutOverlayView;

-(BOOL)getNarrationValue;
-(void)setNarrationValue:(BOOL)value;
-(BOOL)getMusicValue;
-(void)setMusicValue:(BOOL)value;
-(BOOL)getSwipeValue;
-(void)setSwipeValue:(BOOL)value;
-(void)playNarrationOnScene;
-(void)stopNarrationOnScene;

-(void)refreshPaintImage:(int)image;
-(int) getCurrentPaintPage;

-(int) getCurrentDotsPage;
//pause and resume with fade down on scene
-(void) pauseCocos:(BOOL)fade;
-(void) resumeCocos:(BOOL)fade;

-(void)refreshPaintTrain:(int)image;
-(void) updatePuzzleTrain:(int)image;

-(BOOL) getIPhoneMode;

-(void)menuTappedWithThumb:(int)thumb;
- (IBAction)menuButtonTouchCancelled:(id)sender;
- (IBAction)menuButtonTouchDown:(id)sender;

//Flurry
-(void)updateFlurryForNavigationThumbs:(int)section fromThumb:(int)fromThumb toThumb:(int)toThumb;

@end

@interface SubmenuViewIPhone : UIImageView
{
	
}


@end

