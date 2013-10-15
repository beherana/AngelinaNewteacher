//
//  DotView.h
//  Misty-Island-Rescue-iPad
//
//  Created by Johannes Amilon on 11/25/10.
//  Copyright 2010 Vitamin Se Media AB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DotImageView.h"
#import "Dot.h"

#define RGB(a,b,c) [UIColor colorWithRed: a /255.0f green: b / 255.0f blue: c / 255.0f alpha:1]

@interface DotView : UIView {
	NSMutableArray *lines;
	NSMutableArray *dots;
	NSMutableArray *dotImages;
	int nextDot;
	BOOL isEZMode;
	UIImageView *fade;
	UIImage *red;
	UIImage *blue;
	UIImage *black;
	UIImage *blue_active;
	UIImageView *startHere;
	int touchBeganDot;
	int currentPuzzle;
	UIImageView *slate;
	int furthestDot;
	NSTimer *timer;
	int errors;
}

@property (readonly) BOOL isEZMode;
@property (nonatomic, retain) UIImageView *slate;

-(void)initPuzzle:(int)puzzle:(BOOL)ezMode;
-(void)setPuzzle:(int)puzzle;
-(void) setDifficulty:(BOOL)ezMode;

-(void)dotTouchBegan:(DotImageView *)dot;
-(void)dotTouchEnded:(DotImageView *)dot;

-(void)restoreRedDot:(Dot*)dot;

-(void)setFurthestDot;
-(void)run;
-(void) playSound:(int) sound;

@end
