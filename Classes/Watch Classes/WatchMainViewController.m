//
//  WatchMainViewController.m
//  Angelina-New-Teacher-Universal
//
//  Created by Oskar Håkansson on 5/30/11.
//  Copyright 2011 Commind AB. All rights reserved.
//

#import "WatchMainViewController.h"
#import "WatchViewController.h"
#import "Angelina_AppDelegate.h"

#define kIconPadding 17

static NSString *movie1 = @"Dancing Butterfly";
static NSString *movie2 = @"Best Toe Forward";
static NSString *movie3 = @"Song for Ms. Mimi";
static NSString *movie4 = @"I Will Be a Star";
static NSString *movie5 = @"Friendship is Forever";

@implementation ForwardingUIView

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self) {
        view = [self.subviews objectAtIndex:0];
    }
    
    return view;
}

@end

@implementation WatchMainViewController
@synthesize viewAnimate;
@synthesize scrollView;
@synthesize scrollContentView;
@synthesize firstIcon;
@synthesize lastIcon;

-(IBAction) mainMovieNav:(UIButton*)sender {
    NSString* path = nil;
    
    switch (sender.tag) {
        case 1:
            path = movie1;
            break;
        case 2:
            path = movie2;
            break;
        case 3:
            path = movie3;
            break;
        case 4:
            path = movie4;
            break;
        case 5:
            path = movie5;
            break;
        default:
            break;
    }
    if (path != nil) {
        //tell app what movie is currently selected
        [[Angelina_AppDelegate get] setSavedSelectedWatchMovie:sender.tag];
        myWatchViewController = [[WatchViewController alloc] init:path];
        [myWatchViewController initWithParent:self];
		[self.view addSubview:myWatchViewController.view];
		myWatchViewController.view.alpha = 0.0;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(watchFadedIn:finished:context:)];
		[UIView setAnimationDuration:0.5];
		myWatchViewController.view.alpha = 1.0;
		[UIView commitAnimations];
        
        //[myWatchViewController playMovieAtURL:path];
    //[myWatchViewController release];
        //[self homeButtonHidden:NO];
    }
    
}
-(void) restoreOngoingMovie:(int)select {
    NSString* path = nil;
    
    switch (select) {
        case 1:
            path = movie1;
            break;
        case 2:
            path = movie2;
            break;
        case 3:
            path = movie3;
            break;
        case 4:
            path = movie4;
            break;
        case 5:
            path = movie5;
            break;
        default:
            break;
    }
    if (path != nil) {
        //tell app what movie is currently selected
        [[Angelina_AppDelegate get] setSavedSelectedWatchMovie:select];
        myWatchViewController = [[WatchViewController alloc] init:path];
        [myWatchViewController initWithParent:self];
		[self.view addSubview:myWatchViewController.view];
		myWatchViewController.view.alpha = 0.0;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(watchFadedIn:finished:context:)];
		[UIView setAnimationDuration:0.5];
		myWatchViewController.view.alpha = 1.0;
		[UIView commitAnimations];
        
        //[myWatchViewController playMovieAtURL:path];
        //[myWatchViewController release];
        //[self homeButtonHidden:YES];
    }
    
}
/*- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

-(void) releaseWatchViewController{
    //tell app no movie is currently selected
    [[Angelina_AppDelegate get] setSavedSelectedWatchMovie:0];
    resumeCover.hidden = YES;
    [myWatchViewController release];
    myWatchViewController = nil;
}
- (void)dealloc
{
    [self releaseWatchViewController];
    [firstIcon release];
    [lastIcon release];
    [resumeCover release];
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
    
    //check if there should be a running movie
    if ([[Angelina_AppDelegate get] getSavedSelectedWatchMovie] != 0) {
        [self restoreOngoingMovie:[[Angelina_AppDelegate get] getSavedSelectedWatchMovie]];
        resumeCover.hidden = NO;
    } else {
        resumeCover.hidden = YES;
    }
    
    for(UIButton *buttons in viewAnimate.subviews){
        float delay = 0.0;
        switch (buttons.tag) {
            case 1:
                delay = 0.1;
                break;
            case 2:
                delay = 0.3;
                break;
            case 3:
                delay = 0.0;
                break;
            case 4:
                delay = 0.2;
                break;
            case 5:
                delay = 0.4;
                break;
            default:
                break;
        }
        
        buttons.transform = CGAffineTransformMakeScale(0.01, 0.01);
        buttons.alpha = 0.0;
        [UIView animateWithDuration:0.4
                              delay:delay
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             buttons.alpha = 1.0;
                             buttons.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         }
                         completion:nil]; 
        

    }
    
    // Setup scrollview for iPhone only
    if (self.scrollView) {
        [self.scrollView addSubview:self.scrollContentView];
        self.scrollView.contentSize = self.scrollContentView.frame.size;
        
        //the scroll view is should loop semlessly so first element is padded with the last elements.
        //scroll to first elements at beginning
        [self.scrollView scrollRectToVisible:CGRectMake(self.firstIcon.frame.origin.x + kIconPadding, self.firstIcon.frame.origin.y, self.firstIcon.frame.size.width, self.firstIcon.frame.size.height) animated:NO];
    }
}

- (void)viewDidUnload
{
    
    [self setFirstIcon:nil];
    [self setLastIcon:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.scrollView = nil;
    self.scrollContentView = nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(float) actualContentWidth {
    float contentWidth = ((self.lastIcon.frame.origin.x + self.lastIcon.frame.size.width + kIconPadding) - (self.firstIcon.frame.origin.x-kIconPadding));
    return contentWidth;
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)sv {
    //if we are before the first icon jump to the end
    if (sv.contentOffset.x < (self.firstIcon.frame.origin.x - kIconPadding)) {
        [sv scrollRectToVisible:CGRectMake((sv.contentOffset.x + [self actualContentWidth]) + kIconPadding*2, 0, self.firstIcon.frame.size.width, self.firstIcon.frame.size.height) animated:NO];
    }
    else if (sv.contentOffset.x > (self.lastIcon.frame.origin.x - kIconPadding)) {
        //jump back to the beginning
        [sv scrollRectToVisible:CGRectMake((sv.contentOffset.x - [self actualContentWidth]), 0, self.lastIcon.frame.size.width, self.lastIcon.frame.size.height) animated:NO];
    }
}


@end
