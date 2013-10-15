//
//  subThumbViewController.h
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/27/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "SubMenuPaint.h"

@class SubMenuViewController;

@interface subThumbViewController : UIViewController {
	
	SubMenuViewController *myparent;
	
	int myThumbNumber;
	
	IBOutlet UILabel *myThumbNumberLabel;

}


-(id) initWithThumb:(UIImage *)thumbnail parent:(id)parent thumbid:(int)thumbid labelnum:(int)labelnum;
-(void)recolorTextLabel:(BOOL)black;

@end
