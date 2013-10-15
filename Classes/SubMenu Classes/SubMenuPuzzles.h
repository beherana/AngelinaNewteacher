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

@interface SubMenuPuzzles : UIViewController {
	
	SubMenuViewController *myparent;
	
	IBOutlet UIButton *easybutton;
	IBOutlet UIButton *hardbutton;
	
	int levelOfDifficulty;
	int selectedPuzzle;
	
    NSArray *sceneData;
    UIView *thumbholder;
	NSMutableArray *thumbControllers;
}

-(void)initWithParent:(id)parent;
- (NSArray*)getThumbnails;

- (IBAction)easyButtonAction:(id)sender;
- (IBAction)hardButtonAction:(id)sender;

@end
