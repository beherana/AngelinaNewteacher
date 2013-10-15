    //
//  ReadController.m
//  Misty-Island-Rescue-iPad
//
//  Created by Johannes Amilon on 11/19/10.
//  Copyright 2010 Vitamin Se Media AB. All rights reserved.
//

#import "ReadController.h"
#import "Angelina_AppDelegate.h"
#import "ThomasRootViewController.h"
#import "BookScene.h"
#import "cdaAnalytics.h"

@implementation ReadController

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
	
	if ([[[Angelina_AppDelegate get] currentRootViewController].currentScene isDraggingObject]) {
		return;
	}
	if ([[Angelina_AppDelegate get] getReadViewIsPaused]) {
		return;
	}
	if ([[Angelina_AppDelegate get] getSwipeInReadIsTurnedOff]) {
		return;
	}
    if (![[[Angelina_AppDelegate get] currentRootViewController] isNavButtonsEnabled]) {
        return;
    }
    
	if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        [[cdaAnalytics sharedInstance] trackEvent:@"forward" inCategory:flurryEventPrefix(@"READ: swipe") withLabel:@"direction" andValue:-1];
		[[[Angelina_AppDelegate get] currentRootViewController] turnpage:YES];
	} else {
        [[cdaAnalytics sharedInstance] trackEvent:@"backward" inCategory:flurryEventPrefix(@"READ: swipe") withLabel:@"direction" andValue:-1];
		[[[Angelina_AppDelegate get] currentRootViewController] turnpage:NO];
    }
	 
}

-(void) setupSwipe{
	/**/
	rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
	rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
	[self.view addGestureRecognizer:rightSwipe];
	
	leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
	leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
	[self.view addGestureRecognizer:leftSwipe];
	 
}

-(void) removeSwipe{
	/**/
	[self.view removeGestureRecognizer:leftSwipe];
	[self.view removeGestureRecognizer:rightSwipe];
	 
}
#pragma mark iPhone related
-(IBAction)returnToMainMenuFromRead:(id)sender {
	[[Angelina_AppDelegate get].myRootViewController playFXEventSound:@"mainmenu"];

	[[Angelina_AppDelegate get].myRootViewController navigateFromMainMenuWithItem:2];
}

#pragma mark dealloc
-(void) dealloc{
	[leftSwipe release];
	[rightSwipe release];
	[super dealloc];
}


@end
