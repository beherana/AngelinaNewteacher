//
//  StartViewController.m
//  Book
//
//  Created by Henrik Nord on 9/14/08.
//  Copyright 2008 Haunted House. All rights reserved.
//

#import "PaintViewController.h"


@implementation PaintViewController


-(void)viewDidLoad {
    [super viewDidLoad];
	NSLog(@" paintviewcontroller loaded");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void) dealloc
{
	//[myParent release];
	//NSLog(@"PaintViewController released");
	[super dealloc];
}


@end
