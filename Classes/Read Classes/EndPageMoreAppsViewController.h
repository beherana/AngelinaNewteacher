//
//  EndPageMoreAppsViewController.h
//  Angelina-New-Teacher-Universal
//
//  Created by Martin Kamara on 2011-11-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomAlertViewController.h"


@interface EndPageMoreAppsViewController : UIViewController<CustomAlertViewControllerDelegate> {
    UIImageView *noConnectionImage;
    UIActivityIndicatorView *xSellActivityIndicator;
    UITableView *xSellTableView;
    UIScrollView *xSellScrollView;
}

@property (nonatomic, retain) IBOutlet UIImageView *noConnectionImage;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *xSellActivityIndicator;
@property (retain) NSArray* xSellApps;
@property (nonatomic, retain) IBOutlet UITableView *xSellTableView;
@property (nonatomic, retain) IBOutlet UIScrollView *xSellScrollView;
@property (retain) NSURL *willOpenUrl;
@property (retain, nonatomic) IBOutlet UIView *fadeView;

- (IBAction)backButtonAction:(id)sender;
- (IBAction)giftButtonAction:(id)sender;

-(void) xSellDidReload;
-(void)reloadXSell;
-(void)openUrl:(NSURL *)url;
- (void)showLeavingAppAlert;
-(void)setScrollView;
-(void) resetScroll;

@end
