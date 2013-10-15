//
//  MoreAppsAppView.h
//  Day-Of-The-Deisels-Universal
//
//  Created by Martin Kamara on 2011-10-11.
//  Copyright 2011 Commind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cdaXSellApp.h"
#import "CustomAlertViewController.h"
#import "LandingPageTabsViewController.h"

@interface MoreAppsAppView : UIView <CustomAlertViewControllerDelegate> {

    UILabel *headerLabel;
    UILabel *descriptionLabel;
    UILabel *downloadHereLabel;
    UIImageView *iconImageView;
    UIButton *button;
    NSURL * appURL;
    NSString *sectionName;
    LandingPageTabsViewController *containerView;
}

@property(nonatomic,retain) UILabel *headerLabel;
@property(nonatomic,retain) UILabel *descriptionLabel;
@property(nonatomic,retain) UILabel *downloadHereLabel;
@property(nonatomic,retain) UIImageView *iconImageView;
@property(nonatomic,retain) UIButton *button;
@property(nonatomic,retain) NSURL *appURL;
@property(nonatomic,retain) LandingPageTabsViewController *containerView;
@property(nonatomic,retain) NSString *sectionName;

-(void)reloadImage:(NSNotification*)notification;

-(CGFloat) sizeLabelToFit:(UILabel *) sizeLabel;
-(CGFloat) sizeContentToFit;
-(id) setAppValues:(cdaXSellApp *)app;
-(void) setImageViewFromApp:(cdaXSellApp *)app forSize:(NSString const*) size;
-(void) appTapped;


@end
