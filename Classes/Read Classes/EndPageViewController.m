//
//  EndPageViewController.m
//  Angelina-New-Teacher-Universal
//
//  Created by Martin Kamara on 2011-11-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EndPageViewController.h"
#import "Angelina_AppDelegate.h"

@implementation EndPageViewController
@synthesize moreAppsViewController = _moreAppsViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (IBAction)moreAppsButtonAction:(id)sender {
    [[[Angelina_AppDelegate get] currentRootViewController] showMoreApps];
}

@end
