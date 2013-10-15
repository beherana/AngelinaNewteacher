//
//  CustomAlertViewController.h
//  Angelina-New-Teacher-Universal
//
//  Created by Max Ehle on 2011-06-03.
//  Copyright 2011 Commind AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

enum 
{
    BubblePopCAVCButtonTagOk = 1000,
    BubblePopCAVCButtonTagCancel,
    BubblePopCAVCButtonTagResume,
    BubblePopCAVCButtonTagPage1,
};

enum {
    BubblePopCAVCNoNetwork = 1,
    BubblePopCAVCLeaveApp,
};

@class BubblePopCustomAlertViewController;

@protocol BubblePopCustomAlertViewControllerDelegate
@required
//- (void) CustomAlertViewController:(CustomAlertViewController *)alert wasDismissedWithValue:(NSString *)value;
- (void) CustomAlertViewController:(BubblePopCustomAlertViewController *)alert wasDismissedWithValue:(NSInteger)dismissedValue;

@optional
- (void) CAVCWasCancelled:(BubblePopCustomAlertViewController *)alert;
@end


@interface BubblePopCustomAlertViewController : UIViewController <UITextFieldDelegate>
{
    UIView *alertView;
    UIView *backgroundView;
    UITextField *inputField;
    NSInteger alertType;
    BOOL fade;
    
    id<NSObject, BubblePopCustomAlertViewControllerDelegate> delegate;
}
@property (nonatomic, retain) IBOutlet UIView *alertView;
@property (nonatomic, retain) IBOutlet UIView *backgroundView;
@property (nonatomic, retain) IBOutlet UITextField *inputField;
@property NSInteger alertType;
@property BOOL fade;

@property (nonatomic, assign) IBOutlet id<BubblePopCustomAlertViewControllerDelegate, NSObject> delegate;

- (void) show:(UIView*)starter alertType:(NSInteger)value;
- (IBAction)dismiss:(id)sender;
@end