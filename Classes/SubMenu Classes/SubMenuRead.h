//
//  SubMenuRead.h
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/22/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubMenuViewController.h"

@class SubMenuViewController;

@interface SubMenuRead : UIViewController <UIScrollViewDelegate> {
	
	SubMenuViewController *myparent;
	
	IBOutlet UIImageView *selectframe;
	IBOutlet UIScrollView *thumbScroller;
	
	IBOutlet UISwitch *narrationSwitch;
	//IBOutlet UISwitch *musicSwitch;
	IBOutlet UISwitch *swipeSwitch;
    
    IBOutlet UIButton *narrationButton;
    IBOutlet UIButton *swipeButton;
	
	UIView *thumbholder;
	
	int selectedScene;
	
	NSArray *sceneData;
	
	BOOL currentNarrationSetting;
	BOOL currentMusicSetting;
	BOOL currentSwipeSetting;
	
	NSMutableArray *thumbControllers;
	
	BOOL iPhoneMode;
}

@property (nonatomic, retain) UIView *thumbholder;
@property (nonatomic, retain) NSArray *sceneData;
@property (nonatomic, retain) NSMutableArray *thumbControllers;
@property (nonatomic, retain) IBOutlet UIButton *narrationButton;
@property (nonatomic, retain) IBOutlet UIButton *swipeButton;

-(void)initWithParent:(id)parent;

- (NSArray*)getThumbnails;

-(IBAction)narrationButtonPressed:(id)sender;
-(IBAction)swipeButtonPressed:(id)sender;



-(void) updateColorsOnLabels:(BOOL)black;

@end
