//
//  CustomAlertViewController.m
//  Angelina-New-Teacher-Universal
//
//  Created by Max Ehle on 2011-06-03.
//  Copyright 2011 Commind AB. All rights reserved.
//

#import "CustomAlertViewController.h"
#import "AlertAnimations.h"
#import <QuartzCore/QuartzCore.h>
#import "Angelina_AppDelegate.h"

@interface CustomAlertOverlayWindow : UIWindow
{
}
@property (nonatomic,retain) UIWindow* oldKeyWindow;
@property BOOL fadeOut;
@end

@implementation  CustomAlertOverlayWindow
@synthesize oldKeyWindow;
@synthesize fadeOut;

- (void) makeKeyAndVisible
{
	self.oldKeyWindow = [[UIApplication sharedApplication] keyWindow];
	self.windowLevel = UIWindowLevelAlert;
	[super makeKeyAndVisible];
}

- (void) resignKeyWindow
{
	[super resignKeyWindow];
	[self.oldKeyWindow makeKeyWindow];
}

- (void) drawRect: (CGRect) rect
{
	// render the radial gradient behind the alertview
	
	CGFloat width			= self.frame.size.width;
	CGFloat height			= self.frame.size.height;
	CGFloat locations[3]	= { 0.0, 0.5, 1.0 	};
	CGFloat components[12]	= {	1, 1, 1, 0.5,
		0, 0, 0, 0.5,
		0, 0, 0, 0.7	};
	
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef backgroundGradient = CGGradientCreateWithColorComponents(colorspace, components, locations, 3);
	CGColorSpaceRelease(colorspace);
	
	CGContextDrawRadialGradient(UIGraphicsGetCurrentContext(), 
								backgroundGradient, 
								CGPointMake(width/2, height/2), 0,
								CGPointMake(width/2, height/2), width,
								0);
	
	CGGradientRelease(backgroundGradient);
}

- (void) dealloc
{
	self.oldKeyWindow = nil;
	
	NSLog( @"TSAlertView: TSAlertOverlayWindow dealloc" );
	
	[super dealloc];
}

@end

@interface CustomAlertViewLayoutController : UIViewController
{
}
@end

@implementation CustomAlertViewLayoutController
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
	//return YES;
}

//- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
//{
//	UIView* av = [self.view.subviews lastObject];
//
//	// resize the alertview if it wants to make use of any extra space (or needs to contract)
//	[UIView animateWithDuration:duration 
//					 animations:^{
//						 [av sizeToFit];
//						 av.center = CGPointMake( CGRectGetMidX( self.view.bounds ), CGRectGetMidY( self.view.bounds ) );;
//						 av.frame = CGRectIntegral( av.frame );
//					 }];
//}

- (void) dealloc
{
	NSLog( @"TSAlertView: TSAlertViewController dealloc" );
	[super dealloc];
}

@end

@interface CustomAlertViewController()
- (void)enteredBackground:(NSNotification *)notification;
@end

@implementation CustomAlertViewController
@synthesize alertView;
@synthesize backgroundView;
@synthesize inputField;
@synthesize alertType;
@synthesize fade;

@synthesize delegate;

#pragma mark -
- (id) init 
{
	if ( ( self = [super init] ) )
	{
		[[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(enteredBackground:) 
                                                     name: UIApplicationDidEnterBackgroundNotification
                                                   object: nil];
	}
	return self;
}


#pragma mark IBActions
- (void)show:(UIView*)starter alertType:(NSInteger)value{
    // Retaining self is odd, but we do it to make this "fire and forget"
    NSLog(@"---show alert view---");
    [self retain];
    
	[[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate:[NSDate date]];
    
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
	if (!window || ![window isKindOfClass:[CustomAlertOverlayWindow class]]) {
	
        CustomAlertViewLayoutController* avc = [[[CustomAlertViewLayoutController alloc] init] autorelease];
        avc.view.backgroundColor = [UIColor clearColor];
        
        // $important - the window is released only when the user clicks an alert view button
        CustomAlertOverlayWindow* ow = [[CustomAlertOverlayWindow alloc] initWithFrame: [UIScreen mainScreen].bounds];
        ow.alpha = 0.0;
        ow.backgroundColor = [UIColor clearColor];
        ow.rootViewController = avc;
        [ow makeKeyAndVisible];
        
        // fade in the window
        ow.fadeOut = YES;
        [UIView animateWithDuration: 0.2 animations: ^{
            ow.alpha = 1;
        }];
        
        // add and pulse the alertview
        // add the alertview
        [avc.view addSubview: self.view];
    }
    else {
        [window.rootViewController.view addSubview: self.view];
    }

//	self.center = CGPointMake( CGRectGetMidX( avc.view.bounds ), CGRectGetMidY( avc.view.bounds ) );;
//	self.frame = CGRectIntegral( self.frame );
//	[self pulse];
//	
//	if ( self.style == TSAlertViewStyleInput )
//	{
//		[self layoutSubviews];
//		[self.inputTextField becomeFirstResponder];
//	}    
    
    // We need to add it to the window, which we can get from the delegate
    //id appDelegate = [[UIApplication sharedApplication] delegate];
    //UIWindow *window = [appDelegate window];
    //UIViewController *rootViewController = [appDelegate rootViewController];
    
//    Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
//    ThomasRootViewController *rootViewController = [appDelegate myRootViewController];
    
    //[window addSubview:self.view];
    
//    [rootViewController.view addSubview:self.view];
//    [rootViewController.view bringSubviewToFront:self.view];
    
    // Make sure the alert covers the whole window
    //self.view.frame = rootViewController.view.frame;
    //self.view.center = rootViewController.view.center;
    
//    [starter addSubview:self.view];
//    [starter bringSubviewToFront:self.view];
    
    //set view
    self.alertType = value;
    NSArray *alertViews = [NSMutableArray arrayWithArray:[[NSBundle mainBundle] 
													 loadNibNamed:@"CustomAlertViewController" 
													 owner:self options:nil]];
    [self.view addSubview:[alertViews objectAtIndex:self.alertType]];
    
    // "Pop in" animation for alert
    [alertView doPopInAnimationWithDelegate:self];
    
    // "Fade in" animation for background
//    self.fade = YES;
//    for (UIView *subview in window.subviews) {
//        if (subview.tag == 9999) {
//            self.fade = NO;
//            UIView *bview = [subview.subviews objectAtIndex:0];
//            bview.alpha = 0.0;
//            self.backgroundView.alpha = 1.0;    
//        }
//    }
//    if (self.fade) {
//        [self.backgroundView doFadeInAnimation];
//    }
    

}

- (IBAction)dismiss:(id)sender {

    [UIView animateWithDuration: 0.2 
                     animations: ^{
                         self.view.alpha = 0;
                     }
                     completion: ^(BOOL finished) {
//                         [self.view removeFromSuperview];
//                         [self autorelease];
                     }];
    [UIView commitAnimations];
    
    if ([sender tag] == CAVCButtonTagCancel) {
        if ([self.delegate respondsToSelector:@selector(CAVCWasCancelled:)])
            [self.delegate CAVCWasCancelled:self];
    }
    else {
        [self.delegate CustomAlertViewController:self wasDismissedWithValue:[sender tag]];
    }
    
    self.fade = YES;
    // self.view.window
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    for (UIView *subview in window.rootViewController.view.subviews) {
        if (subview.tag == 9999 && subview != self.view) {
            self.fade = NO;
        }
    }
    
    if (self.fade) {
        window.backgroundColor = [UIColor clearColor];
        window.alpha = 1;
        
        [UIView animateWithDuration: 0.3 
                          animations: ^{
                              [window resignKeyWindow];
                              window.alpha = 0;
                          }
                          completion: ^(BOOL finished) {
                              [self.view removeFromSuperview];
                              [window release];
                              [self autorelease];
                          }];
        [UIView commitAnimations];
    }
    else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self.view removeFromSuperview];
        //[window release];
        [self autorelease];
    }

}

#pragma mark -
- (void)viewDidUnload {
    [super viewDidUnload];
    self.alertView = nil;
    self.backgroundView = nil;
    self.inputField = nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [alertView release];
    [backgroundView release];
    [inputField release];

    [super dealloc];
}

#pragma mark -
#pragma mark Private Methods
- (void)enteredBackground:(NSNotification *)notification {    
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    [window resignKeyWindow];
    [self.view removeFromSuperview];
    if (!self.fade) {
        [window release];
        [self autorelease];
    }
}


#pragma mark -
#pragma mark CAAnimation Delegate Methods
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    [self.inputField becomeFirstResponder];
}

#pragma mark -
#pragma mark Text Field Delegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self dismiss:self];
    return YES;
}

@end
