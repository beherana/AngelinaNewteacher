//
//  ReadTextZoomViewController.h
//  Angelina-New-Teacher-Universal
//
//  Created by Martin Kamara on 2011-09-05.
//  Copyright (c) 2011 Commind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopoverImageViewController.h"

@interface ReadTextZoomViewController : UIViewController {
    
    IBOutlet UIView *textView;
    IBOutlet UIButton *closeButton;
    IBOutlet UIButton *repeatButton;
    IBOutlet UIView *contentView;
    
    PopoverImageViewController *popoverImageViewController;
}

@property (retain,nonatomic) UIView *textView;
@property (nonatomic,retain) PopoverImageViewController *popoverImageViewController;

- (IBAction)btnCloseAction:(id)sender;
- (IBAction)btnRepeatAction:(id)sender;

- (void) hideAnimated:(BOOL) animated;
- (void) show;
- (void) showDancePopover;
- (void) hideDancePopover;
- (void) narrationAttention;

@end
