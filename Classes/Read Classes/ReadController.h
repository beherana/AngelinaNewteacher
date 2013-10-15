//
//  ReadController.h
//  Misty-Island-Rescue-iPad
//
//  Created by Johannes Amilon on 11/19/10.
//  Copyright 2010 Vitamin Se Media AB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReadController : UIViewController {
	UISwipeGestureRecognizer *leftSwipe;
	UISwipeGestureRecognizer *rightSwipe;
}

-(void) setupSwipe;
-(void) removeSwipe;
//iphone
-(IBAction)returnToMainMenuFromRead:(id)sender;

@end
