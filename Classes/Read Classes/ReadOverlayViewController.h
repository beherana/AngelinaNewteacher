//
//  ReadOverlayViewController.h
//  Angelina-New-Teacher-Universal
//
//  Created by Martin Kamara on 2011-09-04.
//  Copyright 2011 Commind. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReadOverlayViewController : UIViewController {
    
    IBOutlet UIButton *repeatNarrationButton;
    IBOutlet UIButton *danceButton;
    
    NSString *popoverName;
}

@property (nonatomic, retain) UIButton *repeatNarrationButton;
@property (nonatomic, retain) UIButton *danceButton;
@property (nonatomic, retain) NSString *popoverName;

- (IBAction)btnDanceAction:(id)sender;
- (IBAction)btnRepeatAction:(id)sender;

- (void) narrationAttention;

-(void) disableNavigation;
-(void) enableNavigation;

-(void) hideNavigation;
-(void) showNavigation;

@end
