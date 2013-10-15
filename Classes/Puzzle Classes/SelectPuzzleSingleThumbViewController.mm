//
//  SelectPuzzleSingleThumbViewController.m
//  The Bird & The Snail - Knock Knock - Paint Full
//
//  Created by Henrik Nord on 6/14/09.
//  Copyright 2009 Haunted House. All rights reserved.
//

#import "SelectPuzzleSingleThumbViewController.h"
#import "PuzzleDelegate.h"

@implementation SelectPuzzleSingleThumbViewController

- (id)initWithThumb:(int)thumb myx:(float)myx myy:(float)myy mystate:(NSString*)mystate mypuzzzlepiece:(NSString *)mypuzzzlepiece {
    if ((self = [super init])) {
        mybase = thumb;
        thexpos = myx;
        theypos = myy;
        state = mystate;
        name = mypuzzzlepiece;
    }
	return self;
}

-(void) initWithParent: (id) parent
{
	self=[super init];
	if (self){
		myParent=parent;
	}
	return;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	if ([state isEqualToString:@"0"]) {
		/*
		NSString *iphoneadd = @"";
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
			iphoneadd = @"_iPhone";
		}
		 */
		NSBundle *bundle = [NSBundle mainBundle];
		//NSString *imagePath = [bundle pathForResource:[NSString stringWithFormat:@"%@" "%@" "%i" "%@", state, name, mybase, iphoneadd] ofType:@"png"];
		NSString *imagePath = [bundle pathForResource:[NSString stringWithFormat:@"%@" "%@" "%i", state, name, mybase] ofType:@"png"];
		UIImageView *tempView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imagePath]];
		tempView.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.000].CGColor;
		tempView.layer.shadowOpacity = 0.4;
		tempView.layer.shouldRasterize = YES;
		tempView.layer.shadowOffset = CGSizeMake(0.0,3.0);
		tempView.layer.shadowRadius = 2.0;
		[self.view addSubview:tempView];
		[tempView release];
		tempView = nil;
	}
}

- (void) replaceMyImage {
	if ([[self.view subviews] count] > 0) {
		[[[self.view subviews] objectAtIndex:0] removeFromSuperview];
	}
	
	NSBundle *bundle = [NSBundle mainBundle];
	
	NSString *imagePath = [bundle pathForResource:[NSString stringWithFormat:@"1%@" "%i", name, mybase] ofType:@"png"];
	UIImageView *tempView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imagePath]];
	[self.view addSubview:tempView];
	[tempView release];
	tempView = nil;
	
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"tapped jigsaw icon number: %i", mybase);
	[myParent preStartJigsawPuzzle:mybase];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}


@end
