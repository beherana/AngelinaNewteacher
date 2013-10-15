//
//  SelectSinglePaintThumbViewController.h
//  The Bird & The Snail - Knock Knock - Paint Full
//
//  Created by Henrik Nord on 6/14/09.
//  Copyright 2009 Haunted House. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
//#import "PaintMenuViewController.h"

@class PaintMenuViewController;

@interface SelectSinglePaintThumbViewController : UIViewController {
	
	PaintMenuViewController *myParent;
	
	int mybase;
	float thexpos;
	float theypos;
	NSString *name;
}
- (id)initWithThumb:(int)thumb myx:(float)myx myy:(float)myy mypuzzzlepiece:(NSString *)mypuzzzlepiece;

- (void) initWithParent: (id) parent;

@end
