    //
//  DotViewController.m
//  Misty-Island-Rescue-iPad
//
//  Created by Johannes Amilon on 11/25/10.
//  Copyright 2010 Vitamin Se Media AB. All rights reserved.
//

#import "DotViewController.h"
#import "DotView.h"
#import <QuartzCore/QuartzCore.h>

@implementation DotViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	self.view.frame=CGRectMake(0, 0, 1024, 768);
	dotView=[[DotView alloc] initWithFrame:CGRectMake(45, 114, 933, 568)];
	//[self.view addSubview:[[[UIImageView alloc] initWithImage:
	//						[UIImage imageWithContentsOfFile:
	//						 [[NSBundle mainBundle] pathForResource:@"sky_background" ofType:@"png"]]] autorelease]];
	
	//UIImageView *mybkg = [[[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sky_background" ofType:@"png"]] autorelease];
	
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *imageName = [bundle pathForResource:[NSString stringWithFormat:@"sky_background"] ofType:@"png"];
	UIImageView *mybkg = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imageName]];
	[self.view addSubview:mybkg];
	[mybkg release];
	dotView.slate=[[[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"dotframe" ofType:@"png"]]] autorelease];
	dotView.slate.layer.shadowColor = [RGB(0,0,0) CGColor];
	dotView.slate.layer.shadowOpacity = 0.5;
	dotView.slate.layer.shouldRasterize = YES;
	dotView.slate.layer.shadowOffset = CGSizeMake(8,8);
	dotView.slate.layer.shadowRadius = 8.0;
	dotView.slate.frame=dotView.frame;
	[self.view addSubview:dotView.slate];
	
	UIImageView *text=[[[UIImageView alloc] initWithImage:
					   [UIImage imageWithContentsOfFile:
						[[NSBundle mainBundle] pathForResource:@"dotscounttext" ofType:@"png"]]] autorelease];
	text.frame=CGRectMake(702, 48, text.frame.size.width, text.frame.size.height);
	[self.view addSubview:text];
	
	[self.view addSubview:dotView];
}

-(void)setPuzzle:(int)puzzle{
	[dotView setPuzzle:puzzle];
}

-(void)setDifficulty:(BOOL)ezMode{
	[dotView setDifficulty:ezMode];
}

-(void)initPuzzle:(int)puzzle :(BOOL)ezMode{
	[dotView initPuzzle:puzzle :ezMode];
}

-(int)getDifficulty{
	return dotView.isEZMode?0:1;
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[dotView release];
    [super dealloc];
}


@end
