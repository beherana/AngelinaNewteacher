//
//  CardViewController.h
//  The Bird and The Snail - Knock Knock - Memory Match
//
//  Created by Henrik Nord on 3/24/09.
//  Copyright 2009 Haunted House. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MemoryMatchViewController.h"

@interface CardViewController : UIViewController {

	MemoryMatchViewController *myParent;
	
	int cardNumber;
	int cardID;
	UIImageView *frontside;
	UIImageView *backside;
	NSString *cardimagename;
	
	BOOL cardLockedDown;
	
}

@property (nonatomic, retain) UIImageView *frontside;
@property (nonatomic, retain) UIImageView *backside;

- (id)initWithCardNumber:(int)card cardid:(int)thisId parent:(id)parent imagename:(NSString*)imagename;

- (void)switchCards;
- (void)lockCard;
- (void)removeCard;
- (void)hideCard;

@end
