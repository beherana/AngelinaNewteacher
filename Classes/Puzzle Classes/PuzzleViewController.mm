//
//  PuzzleViewController.m
//  The Bird & The Snail - Knock Knock - Slide Puzzle
//
//  Created by Henrik Nord on 3/24/09.
//  Copyright Haunted House 2009. All rights reserved.
//

#import "PuzzleViewController.h"
#import "PuzzleDelegate.h"

#import "cdaAnalytics.h"

#define kNumberOfButtons 4
#define kNumberOfOrientations 4

#define kMinimumGestureLength	25
#define kMaximumVariance		5

@interface PuzzleViewController (PrivateMethods)
- (void)redrawJigsawMenu;
@end

CGFloat slidePuzzleDegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

@implementation PuzzleViewController


@synthesize jigsawButtonsHolder;
@synthesize menuHolder;
@synthesize easyPuzzleButton;
@synthesize hardPuzzleButton;
@synthesize currentSelectedJigsaw;
@synthesize previousSelectedJigsaw;

-(void) initWithParent: (id) parent
{
	NSLog(@"init with parent called");
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
		[self redrawMenu:0];
	} else {
		currentSelectedJigsaw = 1;
		previousSelectedJigsaw = 0;
		
		easyPuzzleButton.alpha = 0.4;
	}
	//[self redrawMenu:puzzle];
	
}
-(void) changePuzzleDifficulty:(int) difficulty {
	[myParent preStartJigsawPuzzle:currentSelectedJigsaw];
}
- (IBAction) setDifficulty:(id)sender {
	int button = [(UIButton *)sender tag];
	if (button == 1) {
		//easy
		//NSLog(@"Pressed easy button");
		if ([myParent getLevelOfDifficulty] == 0) return;
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDuration:0.3];
		easyPuzzleButton.alpha = 0.4;
		hardPuzzleButton.alpha = 1.0;
		[UIView commitAnimations];
		
	} else if (button == 2) {
		//hard
		//NSLog(@"Pressed hard button");
		if ([myParent getLevelOfDifficulty] == 1) return;
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDuration:0.3];
		easyPuzzleButton.alpha = 1.0;
		hardPuzzleButton.alpha = 0.4;
		[UIView commitAnimations];
		
	}
	[myParent setLevelOfDifficulty:button-1];
	
	[myParent preStartJigsawPuzzle:currentSelectedJigsaw];
}

- (void) redrawMenu:(int)puzzle {
	
	if (puzzle == 1) {
		easyPuzzle = NO;
	} else {
		easyPuzzle = YES;
	}
	
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	//add view for holding menu for puzzles
	menuHolder = [[UIView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:menuHolder];
	//
	float mywidth = self.view.bounds.size.width;
	//add title
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *imagePath = [bundle pathForResource:[NSString stringWithFormat:@"selectapuzzle_iPhone"] ofType:@"png"];
	UIImageView *tempView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imagePath]];
	CGRect titleframe = CGRectMake((mywidth - tempView.frame.size.width)/2-3, 19.0, tempView.frame.size.width, tempView.frame.size.height);
	tempView.frame = titleframe;
	[menuHolder addSubview:tempView];
	[tempView release];
	//add main menu button
	UIButton *homebutton = [UIButton buttonWithType:UIButtonTypeCustom];
	//---> Jumps back to this menu ---> [homebutton addTarget:myParent action:@selector(runExitFromJigsawToMenu:) forControlEvents:UIControlEventTouchUpInside];
	[homebutton addTarget:myParent action:@selector(exitToMainMenu:) forControlEvents:UIControlEventTouchUpInside];
	NSString *buttonImagePath = [bundle pathForResource:[NSString stringWithFormat:@"mainmenubutton_iPhone"] ofType:@"png"];
	[homebutton setBackgroundImage:[UIImage imageWithContentsOfFile:buttonImagePath] forState:UIControlStateNormal];
	CGRect homebuttonframe = CGRectMake(-1, 4, 51, 47);
	homebutton.frame = homebuttonframe;
	[menuHolder addSubview:homebutton];
	
	//add buttons
	NSString *buttonstate;
	NSMutableArray *jigsawpuzzlebuttons = [[NSMutableArray alloc] init];
	for (unsigned i = 0; i < kNumberOfButtons; i++) {
		[jigsawpuzzlebuttons addObject:[NSNull null]];
	}
	
	self.jigsawButtonsHolder = jigsawpuzzlebuttons;
	[jigsawpuzzlebuttons release];
	jigsawpuzzlebuttons = nil;

	//New positions - Draw initial menu as regular portrait for now...
	//positioning variables
	float startslidex = 99;
	float startslidey = 82;
	float buttonwidth = 132;
	float buttonheight = 98;
	float columnpadding = 18;
	
	for (unsigned i = 0; i < kNumberOfButtons/2; i++) {
		for (unsigned j = 0; j < kNumberOfButtons/2; j++) {
			
			int button = (i * 2 + j);
			NSLog(@"This is my button: %i", button);
			
			float sx;
			float sy;
			
			sx = startslidex + ((columnpadding+buttonwidth)*i);
			sy = startslidey + ((columnpadding+buttonheight)*j);
			
			buttonstate = [NSString stringWithFormat:@"0"];		
			SelectPuzzleSingleThumbViewController *jcontroller = [[SelectPuzzleSingleThumbViewController alloc] initWithThumb:(button+1) myx:0 myy:0 mystate:buttonstate mypuzzzlepiece:@"selectjigsaw"];
			jcontroller.view.tag = button+1;
			CGRect jigframe = CGRectMake(sx, sy, buttonwidth, buttonheight);
			jcontroller.view.frame = jigframe;
			[jcontroller initWithParent:myParent];
			//jcontroller.view.alpha = 0.0;
			//jcontroller.view.transform = CGAffineTransformScale(jcontroller.view.transform, 0.1, 0.1);
			
			[menuHolder addSubview:jcontroller.view];
			[jigsawButtonsHolder replaceObjectAtIndex:button withObject:jcontroller];
			
			[jcontroller release];
			jcontroller = nil;
		}
	}
	
	//float newx = 512;
	//float newy = 768.0 - (menuHolder.frame.size.height)/2;
	//menuHolder.center = CGPointMake(newx, newy);
	
	//[self animateMenu];
	//temp
	[[UIApplication sharedApplication] endIgnoringInteractionEvents];
}


- (void) cleanUpMenu {
	[jigsawButtonsHolder removeAllObjects];
	//[jigsawButtonsHolder release];
	[menuHolder removeFromSuperview];
	//[menuHolder release];

}

- (void) enabelMenu:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	/*
	srandom(time(NULL));
	int chosen = random() %  [[menuHolder subviews] count];
	[myParent preStartJigsawPuzzle:chosen+1];
	*/
	[[UIApplication sharedApplication] endIgnoringInteractionEvents];
	
}
- (void) animateMenu {
	
	srandom(time(NULL));
	
	menuHolder.alpha = 1.0;
	/*
	NSMutableArray *offrotation = [[NSMutableArray arrayWithObjects:
							 [NSNumber numberWithFloat:-4.5],
							 [NSNumber numberWithFloat:4.5],
							 [NSNumber numberWithFloat:-5.0],
							 [NSNumber numberWithFloat:4.0],
							 [NSNumber numberWithFloat:-5.5],
							 [NSNumber numberWithFloat:3.5],
							 nil] retain];
	*/
	NSMutableArray *offrotation = [[NSMutableArray arrayWithObjects:
									[NSNumber numberWithFloat:0],
									[NSNumber numberWithFloat:0],
									[NSNumber numberWithFloat:0],
									[NSNumber numberWithFloat:0],
									[NSNumber numberWithFloat:0],
									[NSNumber numberWithFloat:0],
									nil] retain];
	for (unsigned i = 0; i < kNumberOfButtons; i++) {
		SelectPuzzleSingleThumbViewController *jigsaw = [jigsawButtonsHolder objectAtIndex:i];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		if (i == 0) {
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(enabelMenu:finished:context:)];
		}
		[UIView setAnimationDelay:0.5+(i*0.05)];
		[UIView setAnimationDuration:0.2];
		CGFloat rotation = 0.0;
		float offdegree = [[offrotation objectAtIndex:i] floatValue];
		rotation += offdegree;
		CATransform3D rotationTransform = CATransform3DIdentity;
		rotationTransform = CATransform3DRotate(rotationTransform, slidePuzzleDegreesToRadians(rotation), 0.0, 0.0, 1.0);
		jigsaw.view.layer.transform = rotationTransform;
		jigsaw.view.alpha = 1.0;
		[UIView commitAnimations];
	}
}

- (void) zoomSelectedJigsaw:(int)myselcted {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		//unload menu
		[self cleanUpMenu];
	} else {
		if (previousSelectedJigsaw > 0) {
			//Un-disable previous puzzle
			SelectPuzzleSingleThumbViewController *controller = [jigsawButtonsHolder objectAtIndex:previousSelectedJigsaw-1];
			controller.view.alpha = 1.0;
		}
		
		SelectPuzzleSingleThumbViewController *controller = [jigsawButtonsHolder objectAtIndex:myselcted-1];
		controller.view.alpha = 0.2;
	}
	currentSelectedJigsaw = myselcted;
	
	[myParent startJigsaw];
	previousSelectedJigsaw = myselcted;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[jigsawButtonsHolder release];
	[menuHolder release];
	[easyPuzzleButton release];
	[hardPuzzleButton release];
    [super dealloc];
}

@end
