//
//  PuzzleViewController_iPhone.h
//
//  Created by Henrik Nord on 2/14/11.
//  Copyright 2011 Haunted House. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Misty_Island_Rescue_iPadAppDelegate.h"
#import "SelectPuzzleSingleThumbViewController.h"

@class PuzzleDelegate;

@interface PuzzleViewController_iPhone : UIViewController <UIApplicationDelegate> {
    PuzzleDelegate *myParent;
}

- (void) initWithParent: (id) parent;

@end
