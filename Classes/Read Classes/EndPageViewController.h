//
//  EndPageViewController.h
//  Angelina-New-Teacher-Universal
//
//  Created by Martin Kamara on 2011-11-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EndPageMoreAppsViewController.h"

@interface EndPageViewController : UIViewController

@property (retain) EndPageMoreAppsViewController *moreAppsViewController;
- (IBAction)moreAppsButtonAction:(id)sender;



@end
