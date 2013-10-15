//
//  SettingsInformationScroll_iPhone.h
//  ThomasSettings
//
//  Created by Radif Sharafullin on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface SettingsInformationScroll_iPhone : UIView <MFMailComposeViewControllerDelegate>  {
	UIScrollView *sv;
	UIImageView *imgView;
	UIViewController *vc;
}
@property (nonatomic, readonly)UIImageView *imgView;
@property (nonatomic, assign) UIViewController *vc;
-(void)setContentsImage:(UIImage *)contents;
-(void)addEmailButton;
-(void)addMoreAppsButton;
@end
