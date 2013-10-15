//
//  MatchViewController.m
//  Hero-Of-The-Rails-Universal
//
//  Created by Henrik Nord on 3/27/11.
//  Copyright 2011 Haunted House. All rights reserved.
//

#import "MatchViewController.h"


@implementation MatchViewController

-(void) initMatch:(int)value {
    //NSLog(@"initMatch called in iPad");
}
-(void) setDifficulty:(BOOL)value {
    //NSLog(@"setDifficulty called in iPad");
}

- (void)dealloc
{
    [super dealloc];
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
    //NSLog(@"Match on iPad loaded");
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

@end
