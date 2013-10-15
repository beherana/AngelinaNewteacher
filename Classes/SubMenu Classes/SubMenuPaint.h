//
//  SubMenuPaint.h
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/22/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubMenuViewController.h"
//#import "subThumbViewController.h"

@class SubMenuViewController;

@interface SubMenuPaint : UIViewController <UIScrollViewDelegate> {
	
	SubMenuViewController *myparent;
	
	IBOutlet UIImageView *selectframe;
	IBOutlet UIScrollView *thumbScroller;
	
	UIView *thumbholder;
    NSArray *sceneData;
	int selectedPaintImage;
	
}

@property (nonatomic, retain) UIView *thumbholder;

-(void)initWithParent:(id)parent;
- (NSArray*)getThumbnails;

@end
