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
    CAVCButtonTagOk = 1000,
    CAVCButtonTagCancel,
    CAVCButtonTagResume,
    CAVCButtonTagPage1,
};

enum {
    CAVCSaveAlert = 1,
    CAVCSaveConfirmAlert,
    CAVCClearAlert,
    CAVCResumeAlert,
    CAVCNoNetwork,
    CAVCLeaveAppWebsite,
    CAVCLeaveAppAppStore,
    CAVCBadEmailAddress,
    CAVCSubscribeSuccess,
    CAVCSubscribeError
};

@class CustomAlertViewController;

@protocol CustomAlertViewControllerDelegate
@required
//- (void) CustomAlertViewController:(CustomAlertViewController *)alert wasDismissedWithValue:(NSString *)value;
- (void) CustomAlertViewController:(CustomAlertViewController *)alert wasDismissedWithValue:(NSInteger)dismissedValue;

@optional
- (void) CAVCWasCancelled:(CustomAlertViewController *)alert;
@end


@interface CustomAlertViewController : UIViewController <UITextFieldDelegate>
{
    UIView *alertView;
    UIView *backgroundView;
    UITextField *inputField;
    NSInteger alertType;
    BOOL fade;
    
    id<NSObject, CustomAlertViewControllerDelegate> delegate;
}
@property (nonatomic, retain) IBOutlet UIView *alertView;
@property (nonatomic, retain) IBOutlet UIView *backgroundView;
@property (nonatomic, retain) IBOutlet UITextField *inputField;
@property NSInteger alertType;
@property BOOL fade;

@property (nonatomic, assign) IBOutlet id<CustomAlertViewControllerDelegate, NSObject> delegate;

- (void) show:(UIView*)starter alertType:(NSInteger)value;
- (IBAction)dismiss:(id)sender;
@end