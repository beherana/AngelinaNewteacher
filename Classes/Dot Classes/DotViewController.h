//
//  DotViewController.h
//  Misty-Island-Rescue-iPad
//
//  Created by Johannes Amilon on 11/25/10.
//  Copyright 2010 Vitamin Se Media AB. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DotView;

@interface DotViewController : UIViewController {
	DotView *dotView;
}

-(void)setPuzzle:(int)puzzle;
-(void)setDifficulty:(BOOL)ezMode;
-(void)initPuzzle:(int)puzzle:(BOOL)ezMode;
-(int)getDifficulty;

@end
