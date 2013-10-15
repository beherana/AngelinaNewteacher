//
//  MatchMenuViewController.m
//  Misty-Island-Rescue-Universal
//
//  Created by Henrik Nord on 2/19/11.
//  Copyright 2011 Haunted House. All rights reserved.
//

#import "MatchMenuViewController.h"
#import "MemoryMatchViewController.h"
#import "ThomasRootViewController.h"

#import "cdaAnalytics.h"

@implementation MatchMenuViewController

@synthesize menuHolder, memoryholder;

-(void) initWithParent: (id) parent
{
	//NSLog(@"init with parent called in Match");
	self=[super init];
	if (self){
		myParent=parent;
	}
	return;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		iPhoneMode = YES;
        [self redrawMenu];
    } else {
        [self zoomSelectedMatch:[myParent getCurrentMatchState]];
    }
}

-(BOOL) getIPhoneMode {
    return iPhoneMode;
}
-(void) setDifficulty:(int)value {
    if (memoryloaded) {
		//[FlurryAnalytics endTimedEvent:@"Playing_Match_game" withParameters:nil];
        [[cdaAnalytics sharedInstance] endTimedEvent:@"Playing_Match_game"];
		memoryloaded = NO;
		[self.memoryholder removeFromSuperview];
	}
    [self zoomSelectedMatch:[myParent getCurrentMatchState]];
}
- (void) redrawMenu {
	
	if (memoryloaded) {
		//[FlurryAnalytics endTimedEvent:@"Playing_Match_game" withParameters:nil];
        [[cdaAnalytics sharedInstance] endTimedEvent:@"Playing_Match_game"];
		memoryloaded = NO;
		[self.memoryholder removeFromSuperview];
		//[memoryholder release];
		//self.memoryholder = nil;
	}
	
    if (!iPhoneMode) {
        [myParent resetMatchingCards];
        [self zoomSelectedMatch:[myParent getCurrentMatchState]];
        [self hideShowMatchSubmenu:NO];
        return;
    }
	/**/
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	//add view for holding menu for buttons
	menuHolder = [[UIView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:menuHolder];
	//
	float mywidth = self.view.bounds.size.width;
	float myheight = self.view.bounds.size.height;
	//add title
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *imagePath = [bundle pathForResource:[NSString stringWithFormat:@"selectmatchlevel"] ofType:@"png"];
	UIImageView *tempView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imagePath]];
	CGRect titleframe = CGRectMake((mywidth - tempView.frame.size.width)/2, 19.0, tempView.frame.size.width, tempView.frame.size.height);
	tempView.frame = titleframe;
	[menuHolder addSubview:tempView];
	[tempView release];
	//add main menu button
	UIButton *homebutton = [UIButton buttonWithType:UIButtonTypeCustom];
	[homebutton addTarget:self action:@selector(returnToMainMenuFromMatch:) forControlEvents:UIControlEventTouchUpInside];
	NSString *buttonImagePath = [bundle pathForResource:[NSString stringWithFormat:@"mainmenubutton_iPhone"] ofType:@"png"];
	[homebutton setBackgroundImage:[UIImage imageWithContentsOfFile:buttonImagePath] forState:UIControlStateNormal];
	CGRect homebuttonframe = CGRectMake(-1, 4, 51, 47);
	homebutton.frame = homebuttonframe;
	[menuHolder addSubview:homebutton];
	/**/
	//add buttons
	float leftedgedistance = 99.0;
	float rightedgedistance = 99.0;
	float bottomedgedistance = 76.0;
	float buttonwidth = 90.0;
	float buttonheight = 129.0;
	
	UIButton *easymatch = [UIButton buttonWithType:UIButtonTypeCustom];
	[easymatch addTarget:self action:@selector(easyMatchSelected:) forControlEvents:UIControlEventTouchUpInside];
	NSString *easyImagePath = [bundle pathForResource:[NSString stringWithFormat:@"easymatchbutton"] ofType:@"png"];
	[easymatch setBackgroundImage:[UIImage imageWithContentsOfFile:easyImagePath] forState:UIControlStateNormal];
	CGRect easybuttonframe = CGRectMake(leftedgedistance, myheight - (bottomedgedistance+buttonheight) , buttonwidth, buttonheight);
	easymatch.frame = easybuttonframe;
	[menuHolder addSubview:easymatch];
	//
	UIButton *hardmatch = [UIButton buttonWithType:UIButtonTypeCustom];
	[hardmatch addTarget:self action:@selector(hardMatchSelected:) forControlEvents:UIControlEventTouchUpInside];
	NSString *hardImagePath = [bundle pathForResource:[NSString stringWithFormat:@"hardmatchbutton"] ofType:@"png"];
	[hardmatch setBackgroundImage:[UIImage imageWithContentsOfFile:hardImagePath] forState:UIControlStateNormal];
	CGRect hardbuttonframe = CGRectMake(mywidth - (rightedgedistance + buttonwidth), myheight - (bottomedgedistance+buttonheight) , buttonwidth, buttonheight);
	hardmatch.frame = hardbuttonframe;
	[menuHolder addSubview:hardmatch];
	//
	//[self animateMenu];
	//temp
	[[UIApplication sharedApplication] endIgnoringInteractionEvents];
	
}
- (void) animateMenu {
	
}
- (void) cleanUpMenu {
    if(iPhoneMode) {
        [menuHolder removeFromSuperview];
    } else {
        //hide submenu
    }
}
-(void)hideShowMatchSubmenu:(BOOL)hide {
    [myParent hideShowMatchSubmenu:hide];
}
- (void) zoomSelectedMatch:(int)myselected {
	/*MemoryMatchViewController *memoryMatch = [[MemoryMatchViewController alloc] initWithParentAndLevel:self level:myselected];
	memoryloaded = YES;
	[self cleanUpMenu];
	[self.view addSubview:memoryMatch.view];
	 */
    
    [[cdaAnalytics sharedInstance] trackEvent:[NSString stringWithFormat:@"MATCH started with level of difficulty: %i", myselected]];

    [[cdaAnalytics sharedInstance] trackEvent:@"Playing_Match_game" timed:YES];
	//
	MemoryMatchViewController *memoryMatch = [[MemoryMatchViewController alloc] initWithParentAndLevel:self level:myselected];
	self.memoryholder = memoryMatch.view;
	[memoryMatch.view release];
   // [memoryMatch release];//<----
	memoryloaded = YES;
	[self cleanUpMenu];
	[self.view addSubview:memoryholder];
	
}

-(IBAction) easyMatchSelected:(id)sender {
	[self zoomSelectedMatch:0];
}
-(IBAction) hardMatchSelected:(id)sender {
	[self zoomSelectedMatch:1];
}

- (IBAction) returnToMainMenuFromMatch:(id)sender {
	[myParent playFXEventSound:@"mainmenu"];

	[myParent navigateFromMainMenuWithItem:2];
}
-(void) setMatchingCard:(int)match {
    [myParent setMatchingCard:match];
}

-(void)playFXEventSound:(NSString*)sound {
	[myParent playFXEventSound:sound];
}
- (void)playCardSound:(int)sound {
	[myParent playCardSound:sound];
}
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
	[menuHolder release];
	[memoryholder release];
	//NSLog(@"released?");
    [super dealloc];
}


@end
