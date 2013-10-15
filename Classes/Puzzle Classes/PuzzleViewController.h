//
//  PuzzleViewController.h
//  The Bird & The Snail - Knock Knock - Slide Puzzle
//
//  Created by Henrik Nord on 3/24/09.
//  Copyright Haunted House 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Angelina_AppDelegate.h"
#import "SelectPuzzleSingleThumbViewController.h"

@class PuzzleDelegate;

@interface PuzzleViewController : UIViewController <UIApplicationDelegate> {
	
	PuzzleDelegate *myParent;
	
	CGPoint		gestureStartPoint;
	
	UIView *menuHolder;
	
	NSMutableArray *jigsawButtonsHolder;

	BOOL easyPuzzle;
	
	int currentSelectedJigsaw;
	int previousSelectedJigsaw;
	
	IBOutlet UIButton *easyPuzzleButton;
	IBOutlet UIButton *hardPuzzleButton;
}

@property (nonatomic, retain) NSMutableArray *jigsawButtonsHolder;
@property (nonatomic, retain) UIView *menuHolder;
@property (nonatomic, retain) IBOutlet UIButton *easyPuzzleButton;
@property (nonatomic, retain) IBOutlet UIButton *hardPuzzleButton;
@property (nonatomic, readonly) int currentSelectedJigsaw;
@property (nonatomic, readonly) int previousSelectedJigsaw;


- (void) redrawMenu:(int)puzzle;
- (void) animateMenu;
- (void) zoomSelectedJigsaw:(int)myselcted;

- (void) initWithParent: (id) parent;

- (void) cleanUpMenu;

- (IBAction) setDifficulty:(id)sender;

-(void) changePuzzleDifficulty:(int) difficulty;

@end

