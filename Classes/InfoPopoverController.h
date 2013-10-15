//
//  InfoPopoverController.h
//  Misty-Island-Rescue-iPad
//
//  Created by Johannes Amilon on 12/2/10.
//  Copyright 2010 Vitamin Se Media AB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "CustomAlertViewController.h"
#import "TouchableScrollView.h"
@interface InfoPopoverController : UIViewController <MFMailComposeViewControllerDelegate, CustomAlertViewControllerDelegate, UIScrollViewDelegate, UITextFieldDelegate> {
	IBOutlet TouchableScrollView *scroller;
    IBOutlet TouchableScrollView *scrollerRight;
	IBOutlet UIImageView *infotext;
    
    UIViewController *parent;
    
	UIImage *info;
    IBOutlet UITextField *emailTextField;
	//UIImage *info_uk;
    
    IBOutlet UILabel *versionLabel;
    
    NSURL *_willOpenUrl;
}

- (IBAction)show:(UIView*)starter;
-(IBAction) close:(id)sender;
-(IBAction) emailSupport:(id)sender;
-(IBAction) getAppFromAppstore:(id)sender;
- (IBAction)subscribeAction:(id)sender;
- (IBAction)facebookAction:(id)sender;
- (IBAction)twitterAction:(id)sender;
- (IBAction)giftAction:(id)sender;

@property (nonatomic, retain) NSURL *willOpenUrl;
-(void)hideKeyboard;
@end
