//
//  LandingPageViewController.h
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/15/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfoPopoverController.h"
#import "ThomasRootViewController.h"
#import "LandingPageTabsViewController.h"
#import "KeepAliveAnimations.h"

#define INFO_BTN        21
#define MOREAPPS_BTN    22

@interface LandingPageViewController : UIViewController <UIPopoverControllerDelegate,LandingPageTabsViewControllerDelegate>{
    
    ThomasRootViewController *navController;
	InfoPopoverController *popoverContent;
	UIPopoverController *popover;
    
    IBOutlet UIButton *readButton;
    IBOutlet UIButton *paintButton;
    IBOutlet UIButton *puzzleButton;
    IBOutlet UIButton *watchButton;
    IBOutlet UIButton *playButton;
    IBOutlet UIButton *infoButton;
    IBOutlet UIButton *moreAppsButton;
    
    IBOutlet UIImageView *logoImage;
    IBOutlet UIImageView *ribbonImage;
    IBOutlet UIImageView *angelinaImage;
    
    IBOutlet UIView *angelinaAnimationView;
    
    LandingPageTabsViewController *_tabs;
    NSTimer *_animationInterval;
    KeepAliveAnimations *_animations;
    NSInteger _animationBlinkCounter;
    NSTimeInterval _initialKeepAliveDelay;
}

//-(IBAction) infoButtonClicked:(id)sender;
/* old thomas stuff
 -(IBAction) speakTitleButtonTapped:(id)sender;
-(IBAction) speakTitleThomasButtonTapped:(id)sender;
-(IBAction) speakTitleHiroButtonTapped:(id)sender;
*/
-(IBAction) mainMenuNav:(id)sender;

@property (nonatomic, retain) ThomasRootViewController *navController;
//@property (nonatomic, retain) IBOutlet UIButton *readButton;
//@property (nonatomic, retain) IBOutlet UIButton *paintButton;
//@property (nonatomic, retain) IBOutlet UIButton *puzzleButton;
//@property (nonatomic, retain) IBOutlet UIButton *watchButton;
//@property (nonatomic, retain) IBOutlet UIButton *playButton;

@property (nonatomic, retain) LandingPageTabsViewController *tabs;
@property (nonatomic, retain) NSTimer *animationInterval;
@property (nonatomic, retain) KeepAliveAnimations *animations;
@property (nonatomic, assign) NSInteger animationBlinkCounter;
@property (nonatomic, assign) NSTimeInterval initialKeepAliveDelay;
@property (retain) NSString *previousAnimation;
@property (retain) NSArray *keepAliveAnimations;
@property (retain) NSArray *keepAliveVoiceAnimations;

-(void)killPopoversOnSight;
-(void) setupKeepAliveAnimations;

@end
