//
//  PaintMenuViewController.h
//  Misty-Island-Rescue-Universal
//
//  Created by Henrik Nord on 2/17/11.
//  Copyright 2011 Haunted House. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ThomasRootViewController;

@interface PaintMenuViewController : UIViewController <UIApplicationDelegate>{
	ThomasRootViewController *myParent;
	
	UIView *menuHolder;
}
@property (nonatomic, retain) UIView *menuHolder;

- (void) initWithParent: (id) parent;

- (void) redrawMenu;
- (void) animateMenu;
- (void) cleanUpMenu;

- (void) zoomSelectedPaint:(int)myselected;

- (IBAction) returnToMainMenuFromPaint:(id)sender;

@end
