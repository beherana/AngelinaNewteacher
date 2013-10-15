//
//  ThomasSettingsTVC_iPhone.h
//  ThomasSettings
//
//  Created by Radif Sharafullin on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThomasSwitch.h"

@interface ThomasSettingsTVC_iPhone : UITableViewCell {
	ThomasSwitch *s;
	UILabel *accessoryLabel;
	
}
@property (nonatomic, readonly) ThomasSwitch *s;
-(void)setSwitchTarget:(id)target selector:(SEL)selector;
@end
