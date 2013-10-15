//
//  JigsawPuzzlePieceController.h
//  The Bird & The Snail - Knock Knock - Deluxe
//
//  Created by Henrik Nord on 6/29/09.
//  Copyright 2009 Haunted House. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "jigsawViewController.h"

@interface JigsawPuzzlePieceController : UIViewController  <UIApplicationDelegate> {

	jigsawViewController *myJigParent;
	
	int theCurrentPuzzle;
	int myPiece;
	NSString *mySize;
	float xcompensation;
	float ycompensation;
	
	UIImageView *_imageView;

	int currentOrientation;
	int previousOrientation;
	float compensatex;
	float compensatey;
}
@property (nonatomic, retain) UIImageView *imageView;

- (id)initWithJigsawPiece:(int)piece size:(NSString *)size;
- (void) initWithParent: (id) parent;
- (void) repositionLockedJigsawPiece;
- (void) scrambleJigsawPuzzle;

@end
