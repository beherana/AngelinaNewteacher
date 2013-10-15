//
//  PuzzleDelegate.h
//  The Bird & The Snail - Knock Knock - Slide Puzzle
//
//  Created by Henrik Nord on 3/24/09.
//  Copyright Haunted House 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Angelina_AppDelegate.h"
#import "ThomasRootViewController.h"

@class ThomasRootViewController;
@class PuzzleViewController;
@class jigsawViewController;

@interface PuzzleDelegate : UIViewController <UIApplicationDelegate> {

	ThomasRootViewController *myRoot;
	
	UIView *puzzleView;
	
    PuzzleViewController *myPuzzleViewController;
	jigsawViewController *myJigsawViewController;
	
	BOOL jigsawMode;
	
	BOOL setToGo;
	BOOL setForNextImage;
	
	int currentPuzzle;
	
	int numLoadedCards;
	
	int numCompletedCards;
	
	BOOL preventFirstMenuClick;
	BOOL fingerLifted;
	
	//NSNumber *levelOfDifficulty;
	int levelOfDifficulty;
    int variant;
	
	BOOL iPhoneMode;

}

@property (nonatomic, retain) IBOutlet UIView *puzzleView;

- (void) initWithParent: (id) parent;

- (void) cleanCurrentlySelectedPuzzle;
//
- (void) startJigsaw;
- (void)preStartJigsawPuzzle: (int)tag;
//
- (IBAction) exitFromJigsawToMenu: (id)sender;
- (void) runExitFromJigsawToMenu;
- (IBAction) exitToMainMenu: (id)sender;

- (void) removeFinishedPuzzleMovie;

- (id) getCurrentSlidePuzzle;
-(int) getCurrentPuzzle;

-(BOOL) setJigsawMode;
-(BOOL) getJigsawMode;

-(void) retractPuzzleMenu;
-(void) restorePuzzleMenu;

-(int) getLevelOfDifficulty;
-(void) setLevelOfDifficulty:(int)diff;

-(void)hidePuzzleSubMenu;

@end

