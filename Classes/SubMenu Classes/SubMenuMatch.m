    //
//  subMenuMatch.m
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/22/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import "SubMenuMatch.h"

@implementation SubMenuMatch

@synthesize matchesArr;
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/
-(void)initWithParent:(id)parent {
	myparent = parent;
	levelOfDifficulty = [myparent getMatchDifficulty];
    //define matches array
    numberIBCards = 10;
    NSMutableArray *mymatchesarr = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i<numberIBCards; i++) {
        [mymatchesarr addObject:[NSNull null]];
        [mymatchesarr replaceObjectAtIndex:i withObject:[self.view viewWithTag:i+10]];
    }
    self.matchesArr = mymatchesarr;
    [mymatchesarr release];
    
    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"matchgame" ofType:@"plist"];
    NSDictionary *matchData = [[NSDictionary alloc] initWithContentsOfFile:thePath];
    NSDictionary *mybasicseasy = [[[NSDictionary alloc] initWithDictionary:[matchData objectForKey:@"easy"]] autorelease];
    numberOfEasyCards = [[mybasicseasy valueForKey:@"numberOfCards"] integerValue]; 
    NSDictionary *mybasicshard = [[[NSDictionary alloc] initWithDictionary:[matchData objectForKey:@"hard"]] autorelease];
    numberOfHardCards = [[mybasicshard valueForKey:@"numberOfCards"] integerValue];
    
	easyimage = [UIImage imageNamed:@"easy_button_unselected_match.png"];
	easyimageSelected = [UIImage imageNamed:@"easy_button_selected_match.png"];
	hardimage = [UIImage imageNamed:@"difficult_unselected_match.png"];
	hardimageSelected = [UIImage imageNamed:@"difficult_selected_match.png"];
    
    useCollectedCards = NO;
    for (unsigned i=0; i<[matchesArr count]; i++) {
        [[matchesArr objectAtIndex:i] setHidden:YES];
    }
    
	if (levelOfDifficulty == 0) {
		easybutton.image = easyimageSelected;
		hardbutton.image = hardimage;
        /*
        for (unsigned i=0; i<numberIBCards; i++) {
            if (i<numberOfEasyCards/2) {
                [[matchesArr objectAtIndex:i] setHidden:NO];
            } else {
                [[matchesArr objectAtIndex:i] setHidden:YES];
            }
        }
         */
	} else {
		hardbutton.image = hardimageSelected;
		easybutton.image = easyimage;
        /*
        for (unsigned i=0; i<numberIBCards; i++) {
            if (i<numberOfHardCards/2) {
                [[matchesArr objectAtIndex:i] setHidden:NO];
            } else {
                [[matchesArr objectAtIndex:i] setHidden:YES];
            }
        }
         */
	}
    [matchData release];
    //[myparent hideShowSubMenu:NO];
    
    numberOfMatchedCards = 0;
}
/*
*/
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	//change this later so that is gets the latest selected value
}

-(void) setMatchingCard:(int)match {
    if (match == -1) {
        useCollectedCards = YES;
        //show cards
        if (levelOfDifficulty == 0) {
            for (unsigned i=0; i<numberIBCards; i++) {
                if (i<numberOfEasyCards/2) {
                    [[matchesArr objectAtIndex:i] setHidden:NO];
                } else {
                    [[matchesArr objectAtIndex:i] setHidden:YES];
                }
            }
        } else {
            for (unsigned i=0; i<numberIBCards; i++) {
                if (i<numberOfHardCards/2) {
                    [[matchesArr objectAtIndex:i] setHidden:NO];
                } else {
                    [[matchesArr objectAtIndex:i] setHidden:YES];
                }
            }
        }
    }
    if (!useCollectedCards) return;
    numberOfMatchedCards++;
    if (levelOfDifficulty == 0) {
        if (numberOfMatchedCards > numberOfEasyCards/2) {
            return;
        }
    } else {
        if (numberOfMatchedCards > numberOfHardCards/2) {
            return;
        }
    }
    NSString *matchpath = [NSString stringWithFormat:@"finalcard%i.png", match];
    UIImage *newmatch = [UIImage imageNamed:matchpath];
    [[matchesArr objectAtIndex:numberOfMatchedCards-1] setImage:newmatch];
}
-(void) resetMatchingCards {
    if (!useCollectedCards) return;
    for (unsigned i=0; i<numberIBCards; i++) {
        UIImage *newmatch = [UIImage imageNamed:@"finalcard_backside.png"];
        [[matchesArr objectAtIndex:i] setImage:newmatch];
    }
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	int tag = touch.view.tag;
	if (tag == 7) {
		if (levelOfDifficulty == 1) {
			levelOfDifficulty = 0;
			easybutton.image = easyimageSelected;
			hardbutton.image = hardimage;
			//[myparent hideShowSubMenu:YES];
			[myparent setMatchLevelOfDifficulty:levelOfDifficulty];
            if (useCollectedCards) {
                for (unsigned i=0; i<numberIBCards; i++) {
                    if (i<numberOfEasyCards/2) {
                        [[matchesArr objectAtIndex:i] setHidden:NO];
                    } else {
                        [[matchesArr objectAtIndex:i] setHidden:YES];
                    }
                    UIImage *newmatch = [UIImage imageNamed:@"finalcard_backside.png"];
                    [[matchesArr objectAtIndex:i] setImage:newmatch];
                }
                numberOfMatchedCards = 0;
            }
		}
	} else if (tag == 8) {
		if (levelOfDifficulty == 0) {
			levelOfDifficulty = 1;
			hardbutton.image = hardimageSelected;
			easybutton.image = easyimage;
			//[myparent hideShowSubMenu:YES];
			[myparent setMatchLevelOfDifficulty:levelOfDifficulty];
		}
        if (useCollectedCards) {
            for (unsigned i=0; i<numberIBCards; i++) {
                if (i<numberOfHardCards/2) {
                    [[matchesArr objectAtIndex:i] setHidden:NO];
                } else {
                    [[matchesArr objectAtIndex:i] setHidden:YES];
                }
                UIImage *newmatch = [UIImage imageNamed:@"finalcard_backside.png"];
                [[matchesArr objectAtIndex:i] setImage:newmatch];
            }
            numberOfMatchedCards = 0;
        }
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[easybutton release];
	[hardbutton release];
    [match1 release];
    [match2 release];
    [match3 release];
    [match4 release];
    [match5 release];
    [match6 release];
    [match7 release];
    [match8 release];
    [match9 release];
    [match10 release];
    [matchesArr release];
    [super dealloc];
}


@end
