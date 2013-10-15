//
//  MemoryMatchViewController.h
//  The Bird & The Snail - Knock Knock - Memory Match
//
//  Created by Henrik Nord on 3/24/09.
//  Copyright Haunted House 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MatchMenuViewController.h"

@class CardViewController;

@interface MemoryMatchViewController : UIViewController {
	
	MatchMenuViewController *myParent;
	
	CardViewController *cardViewController;
	
	IBOutlet UIButton *matchBackToMenuButton;
	IBOutlet UIImageView *matchtitle;
	
	NSMutableArray *cardControllers;
	NSMutableArray *cardSelectArr;
    NSMutableArray *cardRotationArr;
	
	int numberOfImages;
	float matchOpacity;
	NSString *cardimage;
	int matchlevel;
	int numcolumns;
	int numrows;
	float cardwidth;
	float cardheight;
	float xgridoffset;
	float ygridoffset;
	float xoffset;
	float yoffset;
    BOOL isRotated;
    BOOL useCollectedCards;
	
	int imageone;
	int imagetwo;
	int currentcardOne;
	int currentcardTwo;
	
	int numLoadedCards;
	
	int numCompletedCards;
	
	BOOL cardsAreActive;
	BOOL endPage;
	
	NSDictionary *matchData;
	
	int mylevel;
    
    BOOL iPhoneMode;
	
}

@property (nonatomic, retain) NSMutableArray *cardControllers;
@property (nonatomic, retain) NSMutableArray *cardSelectArr;
@property (nonatomic, retain) NSMutableArray *cardRotationArr;
@property (nonatomic, retain) NSDictionary *matchData;


-(float)getcardwidth;
-(float)getcardheight;
-(float)getMatchOpacity;

-(id) initWithParentAndLevel:(id)parent level:(int)level;

- (IBAction)removeMemoryMatch:(id)sender;

- (void) cardFlipped:(int)card cardid:(int)cardid;
- (void) registerCard;
//soundstuff
- (void)playCardSound:(int)sound;

@end

