    //
//  MainMenuController.m
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/14/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import "MainMenuController.h"
#import "ThomasRootViewController.h"
#import "cdaAnalytics.h"

CGFloat RotationDegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

@interface MainMenuController (PrivateMethods)

@end

@implementation MainMenuController

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
-(void) initWithParent: (id) parent {
	NSLog(@"Got an initcall from RootViewController in main menu");
	myparent = parent;
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone) {
		self.view.transform = CGAffineTransformRotate(self.view.transform, RotationDegreesToRadians(-90));
		randr.transform = CGAffineTransformRotate(randr.transform, RotationDegreesToRadians(90));
		[myparent navigateFromMainMenuWithItem:[myparent getSavedNavigationItem]];
	} else {
		[self setReturnImage];
	}
	//NSLog(@"This is the current Navigation item: %i", [myparent getSavedNavigationItem]);
	//[myparent navigateFromMainMenuWithItem:[myparent getSavedNavigationItem]];
	return;
}
/**/
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSLog(@"Main menu view did load");
    [super viewDidLoad];
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone) {
		self.view.layer.anchorPoint = CGPointMake(0.065, 0.5);
		randr.layer.anchorPoint = CGPointMake(0.5, 0.5);
		menuIsVisible = NO;
	} else {
		/*
		//NSBundle *bundle = [NSBundle mainBundle];
		//NSString *imagePath = [bundle pathForResource:[NSString stringWithFormat:@"mainmenubutton"] ofType:@"png"];
		UIImageView *tempView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainmenubutton_iPhone.png"]];
		CGRect titleframe = CGRectMake(0,5,49,45);
		tempView.frame = titleframe;
		[self.view addSubview:tempView];
		[tempView release];
		 */
	}
}

-(void)setReturnImage {
	NSBundle *bundle = [NSBundle mainBundle];
	//keeping the code for the future here - but right now, all faded images in the iPhone Main Menu are going to be the landing page...
	//NSString *imagePath = [bundle pathForResource:[NSString stringWithFormat:@"fademenu_%i", [myparent getLastVisitedMenuItem]] ofType:@"png"];
	int landingpage = 3;
	NSString *imagePath = [bundle pathForResource:[NSString stringWithFormat:@"fademenu_%i", landingpage] ofType:@"png"];
	UIImage *myimage = [UIImage imageWithContentsOfFile:imagePath];
	iPhoneReturnImage.image = myimage;
	iPhoneReturnImage.alpha = 0.0;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.8];
	iPhoneReturnImage.alpha = 0.1;
	[UIView commitAnimations];
}

-(IBAction)menuButtonPressed:(id)sender {
	int tag = [(UIButton *)sender tag];
	if (tag == 0) {
		//return button on iPhone
		[myparent returnFromMainMenuToLastItem];
	} else if (tag == 1) {
		[self hideShowMainMenu:menuIsVisible];
	} else {
		//send to rootviewcontroller
		[myparent navigateFromMainMenuWithItem:tag];
	}


}
-(void)hideShowMainMenu:(BOOL)hide {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		return;
	}
	[myparent playFXEventSound:@"mainmenu"];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.8];
	if (hide) {
		//NSLog(@"Hides it");
		menuIsVisible = NO;
		self.view.transform = CGAffineTransformRotate(self.view.transform, RotationDegreesToRadians(-90));
		randr.transform = CGAffineTransformRotate(randr.transform, RotationDegreesToRadians(90));
	} else {
		//NSLog(@"Shows it");
		menuIsVisible = YES;
		self.view.transform = CGAffineTransformIdentity;
		randr.transform = CGAffineTransformIdentity;
	}
	[UIView commitAnimations];
}
#pragma mark -
#pragma mark Getters Setters
-(BOOL)getMenuIsVisible {
	return menuIsVisible;
}
#pragma mark -
#pragma mark Application related
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
	NSLog(@"main menu is dealloced");
	[randr release];
	[randrReturn release];
	[iPhoneReturnImage release];
	//iPhoneReturnImage = nil;
    [super dealloc];
}


@end
