//
//  PaintMenuViewController.m
//  Misty-Island-Rescue-Universal
//
//  Created by Henrik Nord on 2/17/11.
//  Copyright 2011 Haunted House. All rights reserved.
//

#import "PaintMenuViewController.h"
#import "SelectSinglePaintThumbViewController.h"
#import "ThomasRootViewController.h"
//#import "Angelina_AppDelegate.h"

#import "cdaAnalytics.h"

#define kNumberOfPaintThumbs 18

@implementation PaintMenuViewController

@synthesize menuHolder;

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
	//init menu
	[self redrawMenu];
}

- (void) redrawMenu {
	/**/
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	//add view for holding menu for buttons
	menuHolder = [[UIView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:menuHolder];
	//
	float mywidth = self.view.bounds.size.width;
	//float myheight = self.view.bounds.size.height;
	//add title
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *imagePath = [bundle pathForResource:[NSString stringWithFormat:@"selectapainting"] ofType:@"png"];
	UIImageView *tempView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imagePath]];
	CGRect titleframe = CGRectMake((mywidth - tempView.frame.size.width)/2-3, 17.0, tempView.frame.size.width, tempView.frame.size.height);
	tempView.frame = titleframe;
	[menuHolder addSubview:tempView];
	[tempView release];
	//add main menu button
	UIButton *homebutton = [UIButton buttonWithType:UIButtonTypeCustom];
	[homebutton addTarget:self action:@selector(returnToMainMenuFromPaint:) forControlEvents:UIControlEventTouchUpInside];
	NSString *buttonImagePath = [bundle pathForResource:[NSString stringWithFormat:@"mainmenubutton_iPhone"] ofType:@"png"];
	[homebutton setBackgroundImage:[UIImage imageWithContentsOfFile:buttonImagePath] forState:UIControlStateNormal];
	CGRect homebuttonframe = CGRectMake(-1, 4, 51, 47);
	homebutton.frame = homebuttonframe;
	[menuHolder addSubview:homebutton];
	/**/
	//add buttons
	//positioning variables
	float startslidex = 24;
	float startslidey = 82;
	float buttonwidth = 132;
	float buttonheight = 98;
	float columnpadding = 18;
	
	for (unsigned i = 0; i < kNumberOfPaintThumbs/2; i++) {
		for (unsigned j = 0; j < kNumberOfPaintThumbs/3; j++) {
			
			int button = (i * 2 + j);
			
			float sx;
			float sy;
			
			sx = startslidex + ((columnpadding+buttonwidth)*i);
			sy = startslidey + ((columnpadding+buttonheight)*j);
			/*	*/
			SelectSinglePaintThumbViewController *jcontroller = [[SelectSinglePaintThumbViewController alloc] initWithThumb:(button+1) myx:0 myy:0 mypuzzzlepiece:@"paintthumb_"];
			jcontroller.view.tag = button+1;
			CGRect jigframe = CGRectMake(sx, sy, buttonwidth, buttonheight);
			jcontroller.view.frame = jigframe;
			[jcontroller initWithParent:self];
			
			[menuHolder addSubview:jcontroller.view];
			
			//[jcontroller release];
			//jcontroller = nil;
			 
		}
	}
	
	//float newx = 512;
	//float newy = 768.0 - (menuHolder.frame.size.height)/2;
	//menuHolder.center = CGPointMake(newx, newy);
	
	//[self animateMenu];
	//temp
	[[UIApplication sharedApplication] endIgnoringInteractionEvents];
	 
}
- (void) animateMenu {
	
}
- (void) cleanUpMenu {
	[menuHolder removeFromSuperview];
}
- (void) zoomSelectedPaint:(int)myselected {
	[myParent setCurrentPaintPage:myselected];
	[myParent navigateFromMainMenuWithItem:8];
}

- (IBAction) returnToMainMenuFromPaint:(id)sender {
	[myParent playFXEventSound:@"mainmenu"];

	[myParent navigateFromMainMenuWithItem:2];
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
    [super dealloc];
}


@end
