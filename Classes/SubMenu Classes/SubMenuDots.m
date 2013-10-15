    //
//  SubMenuPuzzles.m
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/22/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import "SubMenuDots.h"

@implementation SubMenuDots


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
	//start up a puzzle
	//start a puzzle
	/*
	srandom(time(NULL));
	int chosen = random() %  3;
	[myparent preStartDots:chosen+1];	
	UIView *selected = [self.view viewWithTag:chosen+1];
	selectframe.center = selected.center;
	 */
	
	levelOfDifficulty = [myparent getDotDifficulty];
	easyimage = [UIImage imageNamed:@"easy_button_unselected_dots.png"];
	easyimageSelected = [UIImage imageNamed:@"easy_button_selected_dots.png"];
	hardimage = [UIImage imageNamed:@"difficult_unselected_dots.png"];
	hardimageSelected = [UIImage imageNamed:@"difficult_selected_dots.png"];
	if (levelOfDifficulty == 0) {
		easybutton.image = easyimageSelected;
		hardbutton.image = hardimage;
		thumb1.image = [UIImage imageNamed:@"connect_easy_1.png"];
		thumb2.image = [UIImage imageNamed:@"connect_easy_2.png"];
		thumb3.image = [UIImage imageNamed:@"connect_easy_3.png"];
	} else {
		hardbutton.image = hardimageSelected;
		easybutton.image = easyimage;
		thumb1.image = [UIImage imageNamed:@"connect_hard_1.png"];
		thumb2.image = [UIImage imageNamed:@"connect_hard_2.png"];
		thumb3.image = [UIImage imageNamed:@"connect_hard_3.png"];
	}
	
	[self menuTappedWithThumb:[myparent getCurrentDotsPage]];
	[myparent updatePuzzleTrain:[myparent getCurrentDotsPage]];
}

/*
*/
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	//change this later so that is gets the latest selected value
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	int tag = touch.view.tag;
	if (tag > 0 && tag < 7) {
		[self menuTappedWithThumb:tag];
		[myparent updatePuzzleTrain:tag];
	} else if (tag == 7) {
		if (levelOfDifficulty == 1) {
			levelOfDifficulty = 0;
			easybutton.image = easyimageSelected;
			hardbutton.image = hardimage;
			//change the thumbs
			thumb1.image = [UIImage imageNamed:@"connect_easy_1.png"];
			thumb2.image = [UIImage imageNamed:@"connect_easy_2.png"];
			thumb3.image = [UIImage imageNamed:@"connect_easy_3.png"];
			[myparent hideShowSubMenu:YES];
			[myparent setDotLevelOfDifficulty:levelOfDifficulty];
		}
	} else if (tag == 8) {
		if (levelOfDifficulty == 0) {
			levelOfDifficulty = 1;
			hardbutton.image = hardimageSelected;
			easybutton.image = easyimage;
			//change the thumbs
			thumb1.image = [UIImage imageNamed:@"connect_hard_1.png"];
			thumb2.image = [UIImage imageNamed:@"connect_hard_2.png"];
			thumb3.image = [UIImage imageNamed:@"connect_hard_3.png"];
			[myparent hideShowSubMenu:YES];
			[myparent setDotLevelOfDifficulty:levelOfDifficulty];
		}
	}
	
	//Angelina_AppDelegate *appDelegate = (Angelina_AppDelegate *)[[UIApplication sharedApplication] delegate];
	//[appDelegate preStartJigsawPuzzle:mybase];
}

-(void)menuTappedWithThumb:(int)thumb {
	UIView *tapped = [self.view viewWithTag:thumb];
	selectframe.center = tapped.center;
	selectedDots = thumb;
	[myparent hideShowSubMenu:YES];
	[myparent preStartDots:thumb];
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
	[selectframe release];
	[easybutton release];
	[hardbutton release];
	[thumb1 release];
	[thumb2 release];
	[thumb3 release];
    [super dealloc];
}


@end
