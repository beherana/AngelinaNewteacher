//
//  SelectPuzzleSingleThumbViewController.h
//  The Bird & The Snail - Knock Knock - Paint Full
//
//  Created by Henrik Nord on 6/14/09.
//  Copyright 2009 Haunted House. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PuzzleViewController.h"
#import "PuzzleDelegate.h"

@interface SelectPuzzleSingleThumbViewController : UIViewController {
	
	PuzzleDelegate *myParent;
	
	int mybase;
	float thexpos;
	float theypos;
	NSString *state;
	NSString *name;
}
- (id)initWithThumb:(int)thumb myx:(float)myx myy:(float)myy mystate:(NSString *)mystate mypuzzzlepiece:(NSString *)mypuzzzlepiece;

- (void) initWithParent: (id) parent;

- (void) replaceMyImage;

@end
