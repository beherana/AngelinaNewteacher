//
//  ReadTextZoomViewController.m
//  Angelina-New-Teacher-Universal
//
//  Created by Martin Kamara on 2011-09-05.
//  Copyright (c) 2011 Commind. All rights reserved.
//

#import "ReadTextZoomViewController.h"
#import "Angelina_AppDelegate.h"
#import "ImageAnimations.h"
#import "cdaInteractiveTextItem.h"
#import "AVQueueManager.h"
#import "SimpleAudioEngine.h"

@implementation ReadTextZoomViewController

@synthesize textView, popoverImageViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self hideAnimated:NO];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"dance_twinkle.wav"];
    }
    return self;
}

- (void) show {
    [[self.view superview] bringSubviewToFront:self.view];
    
    self.view.hidden = NO;
    
    [UIView animateWithDuration:0.3
                          delay:0.1
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         self.view.alpha = 1.0f;
                     }
                     completion:^(BOOL completed) {
                         
                     }
     ];
}

-(void) hideAnimated:(BOOL) animated {
    
    if (animated) {
        [UIView animateWithDuration:0.15
                              delay:0.0
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             self.view.alpha = 0.0f;
                         }
                         completion:^(BOOL completed) {
                             self.view.hidden = YES;
                         }
         ];
    }
    else {
        self.view.hidden = YES;
        self.view.alpha = 0.0f;
    }
}

- (IBAction)btnCloseAction:(id)sender {
    [self hideAnimated:YES];
}

- (IBAction)btnRepeatAction:(id)sender {
    [[[Angelina_AppDelegate get] currentRootViewController] restartNarrationOnScene];
}

- (void) narrationAttention {
    [ImageAnimations spinLayer:repeatButton.layer duration:1 direction:1];
}

-(void) showDancePopover {
    //add dance popover sub view to frame
    [contentView addSubview:[self.popoverImageViewController.view viewWithTag:self.popoverImageViewController.contentView.tag]];
    
    /* manipulate the view that is going to slide in */
    self.popoverImageViewController.bgImageView.image = nil;
    self.popoverImageViewController.bgImageView.backgroundColor = [UIColor whiteColor];
    [self.popoverImageViewController.closeButton setImage:[UIImage imageNamed:@"back_read.png"] forState:UIControlStateNormal];
    //remove all targets from button and use local hideDancePopover function
    [self.popoverImageViewController.closeButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.popoverImageViewController.closeButton addTarget:self action:@selector(hideDancePopover) forControlEvents:UIControlEventTouchUpInside];
    
    //place the view outside the content view
    self.popoverImageViewController.contentView.frame = CGRectMake(contentView.frame.size.width, -30, self.popoverImageViewController.contentView.frame.size.width, self.popoverImageViewController.contentView.frame.size.height);
    
    //play twinke sound
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"dance_twinkle.wav"];
    [[SimpleAudioEngine sharedEngine] playEffect:@"dance_twinkle.wav"];

    //slide in the view
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         //set negative offset to align the views
                         CGRect frame = self.popoverImageViewController.contentView.frame;
                         self.popoverImageViewController.contentView.frame = CGRectMake(-34, -30, frame.size.width, frame.size.height);
                     }
                     completion:^(BOOL completed) {
                         [[AVQueueManager sharedAVQueueManager] pause];
                         [self.popoverImageViewController showPopover:NO];
                     }
     ];
}

-(void) hideDancePopover {
    //remove dance popover from frame
    //slide out and remove
    [self.popoverImageViewController stopAV];
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         self.popoverImageViewController.contentView.frame = CGRectMake(contentView.frame.size.width, -30, self.popoverImageViewController.contentView.frame.size.width, self.popoverImageViewController.contentView.frame.size.height);
                     }
                     completion:^(BOOL completed) {
                         self.popoverImageViewController.view = nil;
                         [self.popoverImageViewController.contentView removeFromSuperview];
                         self.popoverImageViewController = nil;
                         [self narrationAttention];
                     }
     ];
}

- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event 
{
    UITouch *touch=[[event allTouches] anyObject];
	UIView *touchedView=[touch view];
    
	if ([touchedView isKindOfClass:[cdaInteractiveTextItem class]]) {
        cdaInteractiveTextItem *wordItem = (cdaInteractiveTextItem *) touchedView;
        if (wordItem.popoverImageFilePath != nil) {
            self.popoverImageViewController = [[[PopoverImageViewController alloc] initWithImageFilePath:(NSString *)wordItem.popoverImageFilePath withSourcePosition:CGPointMake(0, 0)] autorelease];
            
            [self showDancePopover];
        }
    }
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
    self.textView = nil;
    [closeButton release];
    closeButton = nil;
    [repeatButton release];
    repeatButton = nil;
    [contentView release];
    contentView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    self.textView = nil;
    if (self.popoverImageViewController != nil) {
        [self.popoverImageViewController.contentView removeFromSuperview];
        self.popoverImageViewController.view = nil;
        self.popoverImageViewController = nil;
    }
    
    [closeButton release];
    [repeatButton release];

    [contentView release];
    [super dealloc];
}

@end
