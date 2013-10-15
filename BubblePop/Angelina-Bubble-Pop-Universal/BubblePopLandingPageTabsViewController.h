//
//  LandingPageTabsViewController.h
//  Misty-Island-Rescue-Universal
//
//  Created by Karl Söderström on 2011-08-04.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BubblePopCustomAlertViewController.h"
#import <MessageUI/MFMailComposeViewController.h>

@class BubblePopLandingPageTabsViewController;

@protocol BubblePopLandingPageTabsViewControllerDelegate <NSObject>
@optional
- (void) tabDismissed;
@end

typedef enum {
    BubblePopLandingPage_TabShown_None = 0,
    BubblePopLandingPage_TabShown_Info,
    BubblePopLandingPage_TabShown_MoreApps
} BubblePopLandingPage_TabShown;

@interface BubblePopLandingPageTabsViewController : UIViewController <BubblePopCustomAlertViewControllerDelegate,MFMailComposeViewControllerDelegate> {

    IBOutlet UIView *overlay;
    IBOutlet UIView *infoTab;
    IBOutlet UIView *moreAppsTab;
    IBOutlet UIScrollView *infoScrollView;
    IBOutlet UIImageView *infoImage;
    IBOutlet UIImageView *noConnectionImage;
    IBOutlet UIButton *infoButton;
    IBOutlet UIButton *infoTabCloseButton;
    IBOutlet UIButton *moreAppsButton;
    IBOutlet UIButton *moreAppsTabCloseButton;
    UIActivityIndicatorView *xSellActivityIndicator;
    IBOutlet UITableView *xSellTableView;

    NSArray* xSellApps;
    MFMailComposeViewController *mailComposerController;

    id <BubblePopLandingPageTabsViewControllerDelegate> delegate;
    
BubblePopLandingPage_TabShown tabShown;

NSURL *_willOpenUrl;
}

@property (retain) id delegate;
@property (nonatomic, retain) NSURL *willOpenUrl;
@property (nonatomic, retain) NSArray* xSellApps;
@property (nonatomic, retain) UIActivityIndicatorView *xSellActivityIndicator;
@property (nonatomic, retain) MFMailComposeViewController *mailComposerController;



- (IBAction)btnInfoTabAction:(id)sender;
- (IBAction)btnMoreAppsTabAction:(id)sender;
- (IBAction)btnFacebookAction:(id)sender;
- (IBAction)btnTwitterAction:(id)sender;
- (IBAction)btnCallawayAction:(id)sender;
- (IBAction)btnHITAction:(id)sender;
- (IBAction)btnGiftAction:(id)sender;
- (IBAction)btnEmailSupport:(id)sender;

-(void)addVersionLabelToFollowView;
-(void)openUrl:(NSURL *)url;
-(void)reloadXSell;
-(void)displayComposerSheet;
-(void) showAlert:(NSString*)title message:(NSString*)message;


@end
