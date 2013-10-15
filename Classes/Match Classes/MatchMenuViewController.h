//
//  MatchMenuViewController.h
//  Misty-Island-Rescue-Universal
//
//  Created by Henrik Nord on 2/19/11.
//  Copyright 2011 Haunted House. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ThomasRootViewController;

@interface MatchMenuViewController : UIViewController {

	ThomasRootViewController *myParent;
	
	UIView *menuHolder;
	UIView *memoryholder;
	
	BOOL memoryloaded;
    
    BOOL iPhoneMode;
}
@property (nonatomic, retain) UIView *menuHolder;
@property (nonatomic, retain) UIView *memoryholder;

- (void) initWithParent: (id) parent;

-(BOOL) getIPhoneMode;

-(void) setDifficulty:(int)value;

- (void) redrawMenu;
- (void) animateMenu;
- (void) cleanUpMenu;
-(void)hideShowMatchSubmenu:(BOOL)hide;

- (void) zoomSelectedMatch:(int)myselected;

-(IBAction) easyMatchSelected:(id)sender;
-(IBAction) hardMatchSelected:(id)sender;

- (IBAction) returnToMainMenuFromMatch:(id)sender;

-(void)playFXEventSound:(NSString*)sound;
- (void)playCardSound:(int)sound;

-(void) setMatchingCard:(int)match;

@end
