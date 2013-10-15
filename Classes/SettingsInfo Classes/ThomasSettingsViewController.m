//
//  ThomasSettingsViewController.m
//  ThomasSettings
//
//  Created by Radif Sharafullin on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ThomasSettingsViewController.h"
#import "ThomasRootViewController.h"

@implementation ThomasSettingsViewController


-(void) initWithParent: (id) parent
{
	/**/
	NSLog(@"init with parent called in Settings");
	myParent=parent;
	return;
}
-(void) unloadSettings {
	NSLog(@"Calling root");
	[myParent playFXEventSound:@"mainmenu"];

	[myParent navigateFromMainMenuWithItem:2];
}
-(NSString*)getCurrentLanguage {
	return [myParent getCurrentLanguage];
}
/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	SettingsViewController_iPhone *c=[[SettingsViewController_iPhone alloc]initWithNibName:@"SettingsViewController" bundle:[NSBundle mainBundle]];
	[c initWithParent:self];
	c.view.frame=self.view.bounds;
	c.view.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:c.view];
}



/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)||(interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
