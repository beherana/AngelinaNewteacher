//
//  jigsawViewController.h
//  The Bird & The Snail - Knock Knock - Deluxe
//
//  Created by Henrik Nord on 6/29/09.
//  Copyright 2009 Haunted House. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PuzzleDelegate.h"
#import "FinishedPuzzleMovieController.h"
#import "FinishedPuzzleViewController.h"

#define kNumberOfJigsawPieces 6
//#define kNumberOfHardJigsawPieces 9
#define kNumberOfHardJigsawPieces 12

@class JigsawPuzzlePieceController;
@class FinishedPuzzleMovieController;
@class FinishedPuzzleViewController;

@interface jigsawViewController : UIViewController {
	
	PuzzleDelegate *myParent;
	
	UIView *_unfinishedPieces;
    UIView *_finishedPieces;
	
	FinishedPuzzleMovieController *myFinishedPuzzleMovieController;
	FinishedPuzzleViewController *_finishedPuzzleAnimation;
    
	//IBOutlet UILabel *tapToStart;
	IBOutlet UIImageView *tapToStart;
	IBOutlet UIImageView *puzzleBKG;
	
    IBOutlet UIImageView *overlayFrame;
	IBOutlet UIButton *backButton;
	
	NSMutableArray *largeJigsawPieces;
	
	NSMutableArray *finalDestination;
	NSMutableArray *startDestinationLandscape;
	
	NSMutableArray *finalHardDestination;
	NSMutableArray *startHardDestinationLandscape;
	
	NSMutableArray *completedPieces;
	
	BOOL firstRun;
	BOOL firstMovieRun;
	BOOL unscrambled;
	BOOL movieIsPlaying;
	int levelOfDifficulty; //0 == easy, increment for harder
    int _variant; // 0 - (kNumberOfJigsawVariants-1)
	
	NSMutableArray *rotationHolder;
	
	int mymovie;
    
    UIImage *_image;
	
}

@property (nonatomic, retain) NSMutableArray *rotationHolder;

@property (nonatomic, retain) UIView *unfinishedPieces;
@property (nonatomic, retain) UIView *finishedPieces;

@property (nonatomic, retain) NSMutableArray *finalDestination;
@property (nonatomic, retain) NSMutableArray *startDestinationLandscape;

@property (nonatomic, retain) NSMutableArray *finalHardDestination;
@property (nonatomic, retain) NSMutableArray *startHardDestinationLandscape;

@property (nonatomic, retain) NSMutableArray *largeJigsawPieces;

@property (nonatomic, retain) NSMutableArray *completedPieces;
@property (nonatomic, retain) UIImage *image;

@property (nonatomic, retain) FinishedPuzzleViewController *finishedPuzzleAnimation;

@property (nonatomic, assign) NSInteger variant;

- (void)switchToBig:(int)piece;
- (void) returnToSmall: (int)piece;
- (void) switchDepth: (int)piece direction:(int)dir;

- (BOOL) getUnscrambled;
- (BOOL) setUnscrambled;

- (void) scrambelPuzzlePieces;
- (void) checkJigsawCompletion;
- (void)finished:(JigsawPuzzlePieceController *)piece;

- (int) getMyJigsawPuzzle;
-(int) getCurrentPuzzle;
- (void) cleanupFinishedMovie;
- (void)finishedPuzzledAnimationFinished;
- (void) initWithParent: (id) parent;

- (void) leavePuzzle;
- (IBAction) leavePuzzlePressed: (id) sender;

@end
