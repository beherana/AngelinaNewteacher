//
//  PaintHolderLandscapeViewController.m
//  Book
//
//  Created by Henrik Nord on 9/14/08.
//  Copyright 2008 Haunted House. All rights reserved.
//

#import "PaintHolderLandscapeViewController.h"
#import "Angelina_AppDelegate.h"
#import "PaintView.h"
#import "cdaAnalytics.h"
#import "PaintViewController.h"
#import "SubMenuViewController.h"
#import "CustomAlertViewController.h"

#define kNumberOfPaintImages 18
// Colors inc eraser
#define kNumberOfColors 14
#define kNumberOfPaintImagesOnIphone 18

#define kAlertViewOne 1
#define kAlertViewTwo 2

@interface PaintHolderLandscapeViewController (PrivateMethods)
- (void) setPaintStartValues;
-(void) createImageArr;
-(void)wantsToSave;
-(void) resetText;
-(void) hideIPhonePaintPalette;
@end

@implementation PaintHolderLandscapeViewController

@synthesize imageSelectArr;
@synthesize lineart;

#pragma mark -
#pragma mark INIT 

- (void)viewDidLoad {
	/**/
	//NSLog(@"PaintHolderLandscapeView has loaded");
    [super viewDidLoad];
	
	Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
	// set start brushsize and start color
	int brush = [appDelegate getSaveCurrentPaintBrush];

	NSString *selectpath = [NSString stringWithFormat:@"brushsize_%i" "_select.png", brush];
	UIImage *tempSelectImage = [UIImage imageNamed:selectpath];
	switch (brush) {
		case 1:
			brushsize1.image = tempSelectImage;
			break;
		case 2:
			brushsize2.image = tempSelectImage;
			break;
		case 3:
			brushsize3.image = tempSelectImage;
			break;
		case 4:
			brushsize4.image = tempSelectImage;
			break;
		case 5:
			brushsize5.image = tempSelectImage;
			break;
		default:
			break;
	}

	brushsize = brush;

	
	//If on iPhone init the painting from here
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		iPhoneMode = YES;
		UKexception = 5;
		int selectedPaintImage = [appDelegate getSaveCurrentPaintImage];
		[self refreshPaintImage:selectedPaintImage];
		paletteGhosting.hidden = YES;
		paletteGhosting.alpha = 0.0;
	} else {
		iPhoneMode = NO;
		UKexception = 6;
	}
	
	//first color - get color from saved index
	if (iPhoneMode) {        
		//CGColorRef color = [[[[iPhonePaintPalette subviews] objectAtIndex:[appDelegate getSaveCurrentPaintColor]] backgroundColor] CGColor];
        NSLog(@"Tag: %i",[appDelegate getSaveCurrentPaintColor]);
        UIView* v = [iPhonePaintPalette viewWithTag:[appDelegate getSaveCurrentPaintColor]];        
        
        [self highlightSelectedButton:(UIButton *)v];
        
        CGColorRef color = [[v backgroundColor] CGColor];

		int numComponents = CGColorGetNumberOfComponents(color);
		if (numComponents == 4)
		{
			const CGFloat *components = CGColorGetComponents(color);
			red = components[0];
			green = components[1];
			blue = components[2];
			alfa = components[3];
			alfa/=2;
		}	
	} else {
        UIButton* cButton;
        int colorIndex = [appDelegate getSaveCurrentPaintColor];
        CGColorRef color = [[[[colorMenuView subviews] objectAtIndex:0] backgroundColor] CGColor];
        if (colorIndex != NSNotFound) {
            color = [[[[colorMenuView subviews] objectAtIndex:colorIndex] backgroundColor] CGColor];
            cButton = [[colorMenuView subviews] objectAtIndex:colorIndex];
        }
        else {
            cButton = [[colorMenuView subviews] objectAtIndex:0];
        }
        [cButton setSelected:YES];
        int numComponents = CGColorGetNumberOfComponents(color);
		if (numComponents == 4)
		{
			const CGFloat *components = CGColorGetComponents(color);
			red = components[0];
			green = components[1];
			blue = components[2];
			alfa = components[3];
			alfa/=2;
		}
	}
	//
	paintInsideLines = YES;
	paintOnTop = NO;
	paintOnEmptyCanvas = NO;
	//
    
    // Show paint palette the first three times pait is opened (iPhone only)
    int paintOpenCount = [appDelegate getSavePaintOpenCount];
    [appDelegate setSavePaintOpenCount:paintOpenCount+1];
    if (iPhoneMode && paintOpenCount < 3) {
        [self showIPhonePaintPalette:nil];
    }
    
    //set current page
    [self refreshPaintImage:[PageHandler defaultHandler].currentPage];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifSubMenuHidden:) name:kSubMenuHidden object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifSubMenuActive:) name:kSubMenuActive object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifChangePage:) name:kCurrentPageDidChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifNavMainMenu:) name:kNavigateFromMainMenu object:nil];
}

#pragma mark -
#pragma mark Getters and Setters
- (BOOL) setSaveImageWarning {
	saveImageWarning = YES;
	return YES;
}
-(BOOL)shouldPaintInsideLines {
	if (paintInsideLines) {
		paintInsideLines = NO;
		return NO;
	} else {
		paintInsideLines = YES;
		return YES;
	}
}
-(BOOL)shouldPaintOnTop {
	if (paintOnTop) {
		paintOnTop = NO;
		return NO;
	} else {
		paintOnTop = YES;
		return YES;
	}
}
-(BOOL)shouldPaintOnEmptyCanvas {
	if (paintOnEmptyCanvas) {
		paintOnEmptyCanvas = NO;
		return NO;
	} else {
		paintOnEmptyCanvas = YES;
		return YES;
	}
}
-(BOOL)getShouldPaintInsideLines {
	return paintInsideLines;
}
-(BOOL)getShouldPaintOnTop {
	return paintOnTop;
}
-(BOOL)getShouldPaintOnEmptyCanvas {
	return paintOnEmptyCanvas;
}
- (void) setPaintStartValues {
	paintOnTop = NO;
	paintInsideLines = NO;
	paintOnEmptyCanvas = NO;
}
-(int) getCurrentPaintImage {
	return currentPaintImage;
}
-(float) getCurrentBrushsize {
	//NSLog(@"this is the returner brushsize: %f", brushsize);
	return brushsize;
}
-(float) getRedColor {
	//NSLog(@"this is the returner brushsize: %f", brushsize);
	return red;
}
-(float) getGreenColor {
	return green;
}
-(float) getBlueColor {
	return blue;
}
-(float) getAlfaColor {
	return alfa;
}
#pragma mark -
#pragma mark iPhone related functions
- (IBAction) returnToPaintMenuFromPaint:(id)sender {

	Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
	[appDelegate.myRootViewController navigateFromMainMenuWithItem:5];
}

-(IBAction) showIPhonePaintPalette:(id) sender {
	if (!iPhonePaintPaletteShown) {
		paletteGhosting.hidden = NO;
	}
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(paletteHidden:finished:context:)];
	[UIView setAnimationDuration:0.3];
	if (iPhonePaintPaletteShown) {
		//hide it
		iPhonePaintPalette.transform = CGAffineTransformIdentity;
		paletteGhosting.alpha = 0.0;
		iPhonePaintPaletteShown = NO;
	} else {
		//show it
		iPhonePaintPalette.transform = CGAffineTransformTranslate(iPhonePaintPalette.transform , 0.0, -192);
		paletteGhosting.alpha = 1.0;
		iPhonePaintPaletteShown = YES;
	} 
	[UIView commitAnimations];
    
    [[[[Angelina_AppDelegate get] currentRootViewController] mySubViewController] hideBothNavButtonsAnimated];
}
-(void) hideIPhonePaintPalette {
	iPhonePaintPaletteShown = NO;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(paletteHidden:finished:context:)];
	[UIView setAnimationDuration:0.3];
	iPhonePaintPalette.transform = CGAffineTransformIdentity;
	paletteGhosting.alpha = 0.0;
	[UIView commitAnimations];
    
    [[[[Angelina_AppDelegate get] currentRootViewController] mySubViewController] showBothNavButtonsAnimated];
}

-(void)paletteHidden:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	if (!iPhonePaintPaletteShown) {
		paletteGhosting.hidden = YES;
	}
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	int tag = touch.view.tag;
	if (tag == 100) {
		[self hideIPhonePaintPalette];
	}
}
#pragma mark -
#pragma mark PaintMenu
-(void) retractPaintMenu {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationDuration:0.4];
	changeImageHolder.alpha = 0.0;
	saveImageHolder.alpha = 0.0;
	[UIView commitAnimations];
}
-(void) restorePaintMenu {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.3];
	changeImageHolder.alpha = 1.0;
	saveImageHolder.alpha = 1.0;
	[UIView commitAnimations];
}

-(void) highlightSelectedButton:(UIButton *) button {
    if(button.tag == 0) {
        selectedColorMask.hidden = true;
        eraserButton.enabled = NO;
    } else {
        eraserButton.enabled = YES;
        selectedColorMask.hidden = false;
        CGRect frame = selectedColorMask.frame;
        frame.origin.x = button.frame.origin.x;
        frame.origin.y = button.frame.origin.y;
        selectedColorMask.frame = frame;
    }
}

#pragma mark -
#pragma mark Paint Images 
- (void) createImageArr {
	//create the image array
	[imageSelectArr removeAllObjects];
	NSMutableArray *myimageselects = [[NSMutableArray alloc] init];
	if (iPhoneMode) {
		for (unsigned i = 0; i < kNumberOfPaintImagesOnIphone; i++) {
			[myimageselects addObject:[NSNull null]];
		}
		for (unsigned i = 0; i < kNumberOfPaintImagesOnIphone; i++) {
			[myimageselects replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:i+1]];
		}
	} else {
		for (unsigned i = 0; i < kNumberOfPaintImages; i++) {
			[myimageselects addObject:[NSNull null]];
		}
		for (unsigned i = 0; i < kNumberOfPaintImages; i++) {
			[myimageselects replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:i+1]];
		}
	}
	self.imageSelectArr = myimageselects;
	[myimageselects release];
	myimageselects = nil;
	
}
-(IBAction) refreshThePaintImage {
	//[self refreshPaintImage];
}
-(void)refreshPaintImage:(int)image {
	currentPaintImage = image;
    
	[self setPaintStartValues];
    //
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *basePath = @"";
    /*if ((iPhoneMode && currentPaintImage == 4) || (!iPhoneMode && currentPaintImage == 7)) {
        basePath = [Angelina_AppDelegate getLocalizedAssetName:[bundle pathForResource:[NSString stringWithFormat:@"paint_%i" "_base", currentPaintImage] ofType:@"png"]];
    } else {*/
        basePath = [bundle pathForResource:[NSString stringWithFormat:@"paint_%i" "_base", currentPaintImage] ofType:@"png"];
    //}
    //
	if (paintViewController != nil) {
		[paintViewController.view removeFromSuperview];
		[lineart removeFromSuperview];
		[paintViewController release];
		paintViewController = nil;
    }
    //
    paintViewController = [[PaintViewController alloc] initWithNibName:@"PaintView" bundle:[NSBundle mainBundle]];
    [((PaintView*)paintViewController.view) initWithParent:self];
    [paintArea addSubview:paintViewController.view];
    
    UIImage *templineartImg = [UIImage imageWithContentsOfFile:basePath];
    UIImageView *templineartImgView = [[UIImageView alloc] initWithImage:templineartImg];
    
    self.lineart = templineartImgView;
    
    [templineartImgView release];
    
    [paintArea addSubview:lineart];
	
}
#pragma mark -
#pragma mark Colors & brushes
- (IBAction)colorPushed:(id)sender {
	if (iPhoneMode) {
		[self hideIPhonePaintPalette];
        NSLog(@"Tag for sender: %i",((UIButton*)sender).tag);
        
        [self highlightSelectedButton:((UIButton*)sender)];
	}
	CGColorRef color = [[(UIButton *)sender backgroundColor] CGColor];
	int numComponents = CGColorGetNumberOfComponents(color);
	if (numComponents == 4)
	{
		const CGFloat *components = CGColorGetComponents(color);
		red = components[0];
		green = components[1];
		blue = components[2];
		alfa = components[3];
		alfa/=2;
	}
	Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
    
	if (iPhoneMode) {
		[appDelegate setSaveCurrentPaintColor:[(UIButton*)sender tag]];
	} else {
        int icolor = [[colorMenuView subviews] indexOfObject:(UIButton*)sender];
        // Unscelect all colorbuttons
        for (int i = 0; i < kNumberOfColors; i++) {
            UIButton* cButton = [[colorMenuView subviews] objectAtIndex:i];
            if (i == icolor) {
                [cButton setSelected:YES];
            }
            else {
                [cButton setSelected:NO];
            }
        }
		[appDelegate setSaveCurrentPaintColor:icolor];
	}
}
-(IBAction)brushSizeButtonPushed:(id)sender {
	int check = brushsize;
	int newsize = [(UIButton *)sender tag];
	if (brushsize == newsize) {
		return;
	} else {
		brushsize = newsize;
	}
	if (iPhoneMode) {
		[self hideIPhonePaintPalette];
	}
	NSString *restorepath = [NSString stringWithFormat:@"brushsize_%i" ".png", check];
	UIImage *tempRestoreImage = [UIImage imageNamed:restorepath];
	switch (check) {
		case 1:
			brushsize1.image = tempRestoreImage;
			break;
		case 2:
			brushsize2.image = tempRestoreImage;
			break;
		case 3:
			brushsize3.image = tempRestoreImage;
			break;
		case 4:
			brushsize4.image = tempRestoreImage;
			break;
		case 5:
			brushsize5.image = tempRestoreImage;
			break;
		default:
			break;
	}
	check = brushsize;
	NSString *selectpath = [NSString stringWithFormat:@"brushsize_%i" "_select.png", check];
	UIImage *tempSelectImage = [UIImage imageNamed:selectpath];
	switch (check) {
		case 1:
			brushsize1.image = tempSelectImage;
			break;
		case 2:
			brushsize2.image = tempSelectImage;
			break;
		case 3:
			brushsize3.image = tempSelectImage;
			break;
		case 4:
			brushsize4.image = tempSelectImage;
			break;
		case 5:
			brushsize5.image = tempSelectImage;
			break;
		default:
			break;
	}
	Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
	[appDelegate setSaveCurrentPaintBrush:brushsize];
}
#pragma mark -
#pragma mark Sounds
-(IBAction)buttonSoundFX:(id)sender {
	
//	int newsize = [(UIButton *)sender tag]-18;
//	if (brushsize == newsize) return;
		
	Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
	//play eventsound
	[appDelegate playFXEventSound:@"Select"];
}
#pragma mark -
#pragma mark Saving and warnings
- (IBAction)saveimage:(id)sender {
	
	//FLURRY
	[[cdaAnalytics sharedInstance] trackEvent:[NSString stringWithFormat:@"Image%i", [self getCurrentPaintImage]] inCategory:@"PAINT - Tapped save image button" withLabel:@"paintimage" andValue:-1];

    Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];    
    CustomAlertViewController *alert = [[CustomAlertViewController alloc]init];
    alert.delegate = self;
    //alert.view.tag = CAVCSaveAlert;
    [alert show:appDelegate.myRootViewController.view alertType:CAVCSaveAlert];
    [alert release];	
    
//	saveText2.text = @"Saving...";
//	UIAlertView *alertView1 = [[UIAlertView alloc] initWithTitle:@"Saving Painting" message:@"Do you want to save your painting to your Photos Library?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"YES", nil];
//    alertView1.tag = kAlertViewOne;
//	[alertView1 show];
//	[alertView1 release];
}

-(void)wantsToSave {
	UIGraphicsBeginImageContext(paintArea.bounds.size);
	[paintArea.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	UIImageWriteToSavedPhotosAlbum(viewImage, self, nil, nil);
	
	//FLURRY
	[[cdaAnalytics sharedInstance] trackEvent:[NSString stringWithFormat:@"Image%i", [self getCurrentPaintImage]] inCategory:@"PAINT - Image was saved" withLabel:@"paintimage" andValue:-1];
	//
    
    Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];  
    CustomAlertViewController *alert = [[CustomAlertViewController alloc]init];
    alert.delegate = self;
    [alert show:appDelegate.myRootViewController.view alertType:CAVCSaveConfirmAlert];
    [alert release];
    
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Save completed!" message:@"The painting has been saved to your Photos Library." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//	[alert show];
//	[alert release];
	
	[self performSelector:@selector(resetText) withObject:nil afterDelay:0.8];
}

-(void) resetText {	
	saveText2.text = @"Save image";
}

- (IBAction)clearImage:(id) sender {
    [[cdaAnalytics sharedInstance] trackEvent:[NSString stringWithFormat:@"Image%i", [self getCurrentPaintImage]] inCategory:@"PAINT - Tapped clear button" withLabel:@"paintimage" andValue:-1];
    Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];

    CustomAlertViewController *alert = [[CustomAlertViewController alloc]init];
    alert.delegate = self;
    [alert show:appDelegate.myRootViewController.view alertType:CAVCClearAlert];
    [alert release];    
    
//    UIAlertView *alertView2 = [[UIAlertView alloc] initWithTitle:@"Clear Painting" message:@"Are you sure?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"YES", nil];
//    alertView2.tag = kAlertViewTwo;
//	[alertView2 show];
//	[alertView2 release];
}

- (void)wantsToClear {
    // For error information
    NSError *error;
    
    // Create file manager
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    // Attempt to delete the file at filePath2
    NSString *filepath = [(PaintView*)paintViewController.view fileName];
    
    if ([fileMgr removeItemAtPath:filepath error:&error] != YES)
        NSLog(@"Unable to delete file: %@", [error localizedDescription]);
    
    [paintViewController.view removeFromSuperview];
    [lineart removeFromSuperview];
    [paintViewController release];
    paintViewController = nil;
    
    [[cdaAnalytics sharedInstance] trackEvent:[NSString stringWithFormat:@"Image%i", [self getCurrentPaintImage]] inCategory:@"PAINT - cleared" withLabel:@"paintimage" andValue:-1];
    //set current page
    [self refreshPaintImage:[PageHandler defaultHandler].currentPage];
}

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if(alertView.tag == kAlertViewOne) {
//        if (buttonIndex == 0) {
//            //NSLog(@"This is button 0");
//            [self resetText];
//        } else if (buttonIndex == 1) {
//            //NSLog(@"This is button 1");
//            [self wantsToSave];			
//        }
//    } else if(alertView.tag == kAlertViewTwo) {
//        if (buttonIndex == 1) {
//            //NSLog(@"This is button 1");
//            [self wantsToClear];			
//        }
//    }
//}

- (void) CustomAlertViewController:(CustomAlertViewController *)alert wasDismissedWithValue:(NSInteger)dismissedValue {
    
    if(alert.alertType == CAVCSaveAlert && dismissedValue == CAVCButtonTagOk) {
        [self wantsToSave];			
    }
    else if(alert.alertType == CAVCClearAlert && dismissedValue == CAVCButtonTagOk) {
        [self wantsToClear];			
    }
}

#pragma mark -
#pragma mark Notifications

- (void)notifSubMenuHidden:(NSNotification *)notification {
	//id notificationSender = [notification object];
    
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.3];
    colorMenuView.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];
    
    [self.view  setUserInteractionEnabled:YES];
}

- (void)notifSubMenuActive:(NSNotification *)notification {
	//id notificationSender = [notification object];
    
    [self.view  setUserInteractionEnabled:NO];
    
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.3];
    colorMenuView.transform = CGAffineTransformTranslate(colorMenuView.transform , 0.0, 30);
	[UIView commitAnimations];
}

- (void)notifChangePage:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    [(PaintView*)paintViewController.view save];
    int nextpage = [[userInfo objectForKey:@"currentPage"] intValue];
    if(nextpage != currentPaintImage){
        CATransition* transition = [CATransition animation];
        transition.type = kCATransitionPush;
        if(nextpage > currentPaintImage)
            transition.subtype = kCATransitionFromRight;
        else
            transition.subtype = kCATransitionFromLeft;
        [paintArea.layer addAnimation:transition forKey:@"push-transition"];
    }
    [self refreshPaintImage:nextpage];
}

- (void)notifNavMainMenu:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    if ([[userInfo objectForKey:@"navItem"] intValue] != NAV_PAINT) {
        [(PaintView*)paintViewController.view save];
    }
}

#pragma mark -
#pragma mark Memory
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}
- (void) dealloc
{
	[brushSizeButton release];
	[paintArea release];
	[paintFrame release];
	[shakeToChangeText release];
	[changeText release];
	[changeText2 release];
	[saveText release];
	[saveText2 release];
	
	[brushsize1 release];
	[brushsize2 release];
	[brushsize3 release];
	[brushsize4 release];
	[brushsize5 release];
	
	[save release];
	[changeImage release];
	
	[changeImageHolder release];
	[saveImageHolder release];
	
	[imageSelectArr release];
	[paintViewController.view removeFromSuperview];
	[paintViewController release];
	paintViewController = nil;
	
    [paletteGhosting release];
    
	[lineart release];
	
	[iPhonePaintPalette release];
	
    [colorMenuView release];
    [eraserButton release];
	[super dealloc];
	
}


- (void)viewDidUnload {
    [colorMenuView release];
    colorMenuView = nil;
    [eraserButton release];
    eraserButton = nil;
    [super viewDidUnload];
}
@end
