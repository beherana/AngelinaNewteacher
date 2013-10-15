//
//  SettingsViewController_iPhone.h
//  ThomasSettings
//
//  Created by Radif Sharafullin on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsInformationScroll_iPhone.h"

@class ThomasSettingsViewController;

@interface SettingsViewController_iPhone : UIViewController <UITableViewDelegate, UITableViewDataSource>{
	
	ThomasSettingsViewController *myParent;
	
	IBOutlet UITableView * tv;
	IBOutlet UIButton *backButton;
	IBOutlet UILabel *sectionLabel;
	SettingsInformationScroll_iPhone *infoScrollView;
    
    
@private
	CGRect tvIndentFrame;
	
}

- (void) initWithParent: (id) parent;

-(IBAction)backPressed:(UIButton *)sender;
-(NSString*)imagePathForResolution:(NSString*)path;


@end
