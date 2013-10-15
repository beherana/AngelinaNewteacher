//
//  ReadOverlayViewController.m
//  Angelina-New-Teacher-Universal
//
//  Created by Martin Kamara on 2011-09-04.
//  Copyright 2011 Commind. All rights reserved.
//

#import "ReadOverlayViewController.h"
#import "ReadOverlayUIView.h"
#import "Angelina_AppDelegate.h"
#import "ImageAnimations.h"


@implementation ReadOverlayViewController
@synthesize repeatNarrationButton, danceButton;
@synthesize popoverName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        ReadOverlayUIView *customView = (ReadOverlayUIView *)self.view;
        customView.repeatNarrationButton = repeatNarrationButton;
        customView.danceButton = danceButton;
    
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

//animate the narration button to capture the users attention
-(void) narrationAttention {
    [ImageAnimations spinLayer:repeatNarrationButton.layer duration:1 direction:1];
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [danceButton setHidden:YES];
    [super viewDidLoad];
}


- (void)viewDidUnload
{
    [danceButton release];
    danceButton = nil;
    [repeatNarrationButton release];
    repeatNarrationButton = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) enableNavigation {
    danceButton.userInteractionEnabled = YES;
    repeatNarrationButton.userInteractionEnabled = YES;
}

-(void) disableNavigation {
    danceButton.userInteractionEnabled = NO;
    repeatNarrationButton.userInteractionEnabled = NO;    
}

-(void) hideNavigation {
    if (self.repeatNarrationButton.frame.origin.x > 0) {
        self.repeatNarrationButton.frame = CGRectMake(self.repeatNarrationButton.frame.origin.x-self.view.frame.size.width, self.repeatNarrationButton.frame.origin.y, self.repeatNarrationButton.frame.size.width, self.repeatNarrationButton.frame.size.height);
    }
    if (self.danceButton.frame.origin.x > 0) {
        self.danceButton.frame = CGRectMake(self.danceButton.frame.origin.x-self.view.frame.size.width, self.danceButton.frame.origin.y, self.danceButton.frame.size.width, self.danceButton.frame.size.height);
    }
}

-(void) showNavigation {
    if (self.repeatNarrationButton.frame.origin.x < 0) {
        self.repeatNarrationButton.frame = CGRectMake(self.repeatNarrationButton.frame.origin.x+self.view.frame.size.width, self.repeatNarrationButton.frame.origin.y, self.repeatNarrationButton.frame.size.width, self.repeatNarrationButton.frame.size.height);
    }
    if (self.danceButton.frame.origin.x < 0) {
        self.danceButton.frame = CGRectMake(self.danceButton.frame.origin.x+self.view.frame.size.width, self.danceButton.frame.origin.y, self.danceButton.frame.size.width, self.danceButton.frame.size.height);
    }
}

- (void)dealloc {
    [repeatNarrationButton release];
    [danceButton release];
    [super dealloc];
}
- (IBAction)btnDanceAction:(id)sender {
    CGPoint dummy = CGPointMake(0, 0);
    [[[Angelina_AppDelegate get] currentRootViewController] showPopoverImage:self.popoverName withSourcePosition:dummy];
}

- (IBAction)btnRepeatAction:(id)sender {
    [[[Angelina_AppDelegate get] currentRootViewController] restartNarrationOnScene];
}
@end
