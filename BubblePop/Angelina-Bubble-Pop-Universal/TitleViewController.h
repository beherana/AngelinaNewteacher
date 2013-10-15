//
//  TitleViewController.h
//  Angelina-Bubble-Pop-Universal
//
//  Created by Karl Söderström on 2011-08-19.
//  Copyright 2011 Commind AB. All rights reserved.
//

#import "BubblePopRootViewController.h"
#import "BubblePopLandingPageTabsViewController.h"

@protocol BubblePopDelegate;

@interface TitleViewController : UIViewController <BubblePopLandingPageTabsViewControllerDelegate> {

    BubblePopLandingPageTabsViewController *_tabs;
    
    IBOutlet UIButton *btnHowto;
    IBOutlet UIImageView *imgVerticalRule;
    IBOutlet UIButton *btnAudio;
    IBOutlet UIButton *moreAppsButton;
    IBOutlet UIButton *infoButton;
    IBOutlet UIButton *btnClassic;
    IBOutlet UIButton *btnClock;
    IBOutlet UIButton *btnHome;
    IBOutlet UIView *startBubbleView;
    
    bool _classicFirstTime;
    bool _clockFirstTime;
    
    id<BubblePopDelegate> _delegate;
}

@property (nonatomic, retain) BubblePopLandingPageTabsViewController *tabs;
@property bool classicFirstTime;
@property bool clockFirstTime;
@property (nonatomic, assign) id<BubblePopDelegate> delegate;

- (IBAction)btnHowtoAction:(id)sender;
- (IBAction)btnAudioAction:(id)sender;
- (IBAction)btnClassicAction:(id)sender;
- (IBAction)btnClockAction:(id)sender;
- (IBAction)btnTabsAction:(id)sender;
- (IBAction)btnHomeAction:(id)sender;


@end
