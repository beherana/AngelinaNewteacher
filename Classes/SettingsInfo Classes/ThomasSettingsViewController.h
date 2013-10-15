//
//  ThomasSettingsViewController.h
//  ThomasSettings
//
//  Created by Radif Sharafullin on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController_iPhone.h"
@class ThomasRootViewController;

@interface ThomasSettingsViewController : UIViewController {

	ThomasRootViewController *myParent;
	
}

- (void) initWithParent: (id) parent;
-(void) unloadSettings;
-(NSString*)getCurrentLanguage;

@end

