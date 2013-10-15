//
//  subMenuMatch.h
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/22/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubMenuViewController.h"

@class SubMenuViewController;

@interface SubMenuMatch : UIViewController {
	
	SubMenuViewController *myparent;
	
	IBOutlet UIImageView *easybutton;
	IBOutlet UIImageView *hardbutton;
    
    IBOutlet UIImageView *match1;
    IBOutlet UIImageView *match2;
    IBOutlet UIImageView *match3;
    IBOutlet UIImageView *match4;
    IBOutlet UIImageView *match5;
    IBOutlet UIImageView *match6;
    IBOutlet UIImageView *match7;
    IBOutlet UIImageView *match8;
    IBOutlet UIImageView *match9;
    IBOutlet UIImageView *match10;
    
    NSMutableArray *matchesArr;
	
	UIImage *easyimage;
	UIImage *easyimageSelected;
	UIImage *hardimage;
	UIImage *hardimageSelected;
	
	BOOL isEasy;
	
	int levelOfDifficulty;
    
    int numberIBCards;
    int numberOfEasyCards;
    int numberOfHardCards;
    
    int numberOfMatchedCards;
	
    BOOL useCollectedCards;
}

@property (nonatomic, retain) NSMutableArray *matchesArr;

-(void)initWithParent:(id)parent;

-(void) setMatchingCard:(int)match;
-(void) resetMatchingCards;

@end
