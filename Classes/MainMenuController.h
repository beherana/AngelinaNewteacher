//
//  MainMenuController.h
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/14/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class ThomasRootViewController;

@interface MainMenuController : UIViewController {

	ThomasRootViewController *myparent;
	
	IBOutlet UIButton *randr;
	IBOutlet UIButton *randrReturn;
	
	IBOutlet UIImageView *iPhoneReturnImage;
	
	BOOL menuIsVisible;
}

-(void) initWithParent: (id) parent;

-(void)hideShowMainMenu:(BOOL)hide;
-(IBAction)menuButtonPressed:(id)sender;

-(void)setReturnImage;


//getters
-(BOOL)getMenuIsVisible;

@end
