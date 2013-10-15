//
//  SubMenuPuzzles.h
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/22/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubMenuViewController.h"

@class SubMenuViewController;

@interface SubMenuDots : UIViewController {
	
	SubMenuViewController *myparent;
	
	IBOutlet UIImageView *selectframe;
	
	IBOutlet UIImageView *easybutton;
	IBOutlet UIImageView *hardbutton;
	
	UIImage *easyimage;
	UIImage *easyimageSelected;
	UIImage *hardimage;
	UIImage *hardimageSelected;
	
	IBOutlet UIImageView *thumb1;
	IBOutlet UIImageView *thumb2;
	IBOutlet UIImageView *thumb3;
	
	
	BOOL isEasy;
	
	int levelOfDifficulty;
	
	int selectedDots;
	
}

-(void)initWithParent:(id)parent;

-(void)menuTappedWithThumb:(int)thumb;

@end
