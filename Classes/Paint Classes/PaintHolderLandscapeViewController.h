//
//  PaintHolderLandscapeViewController.h
//  Book
//
//  Created by Henrik Nord on 9/14/08.
//  Copyright 2008 Haunted House. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomAlertViewController.h"

@class PaintViewController;
//@class PaintView;

@interface PaintHolderLandscapeViewController : UIViewController <UIApplicationDelegate, CustomAlertViewControllerDelegate>{
	
	PaintViewController *paintViewController;
	
	IBOutlet UIButton *brushSizeButton;
	IBOutlet UIView *paintArea;
	IBOutlet UIView *paintFrame;
	IBOutlet UILabel *shakeToChangeText;
	IBOutlet UILabel *changeText;
	IBOutlet UILabel *changeText2;
	IBOutlet UILabel *saveText;
	IBOutlet UILabel *saveText2;
    IBOutlet UIButton *eraserButton;
	
	IBOutlet UIImageView *brushsize1;
	IBOutlet UIImageView *brushsize2;
	IBOutlet UIImageView *brushsize3;
	IBOutlet UIImageView *brushsize4;
	IBOutlet UIImageView *brushsize5;
	
	IBOutlet UIButton *save;
	IBOutlet UIButton *changeImage;
	
	IBOutlet UIView *changeImageHolder;
	IBOutlet UIView *saveImageHolder;
	
	IBOutlet UIView *paletteGhosting;
	
    IBOutlet UIView *colorMenuView;
    IBOutlet UIImageView *selectedColorMask;
	float red;
	float green;
	float blue;
	float alfa;
	float brushsize;
	
	NSMutableArray *imageSelectArr;
	
	int currentPaintImage;
	
	BOOL saveImageWarning;
	
	BOOL paintHintsShown;
	BOOL paintInsideLines;
	BOOL paintOnTop;
	BOOL paintOnEmptyCanvas;
	
	//Put paint images in here instead
	UIImageView*	lineart;
	int UKexception;
	
	IBOutlet UIView *iPhonePaintPalette;
	BOOL iPhonePaintPaletteShown;
	
	BOOL iPhoneMode;
	
}
@property (nonatomic, retain) NSMutableArray *imageSelectArr;

@property (nonatomic, retain) UIImageView *lineart;

- (void) setPaintStartValues;
-(int) getCurrentPaintImage;
-(float) getCurrentBrushsize;
-(float) getRedColor;
-(float) getGreenColor;
-(float) getBlueColor;
-(float) getAlfaColor;

-(BOOL) setSaveImageWarning;
-(BOOL)shouldPaintInsideLines;
-(BOOL)getShouldPaintInsideLines;
-(BOOL)shouldPaintOnTop;
-(BOOL)getShouldPaintOnTop;
-(BOOL)shouldPaintOnEmptyCanvas;
-(BOOL)getShouldPaintOnEmptyCanvas;

-(void) refreshPaintImage:(int)image;
-(IBAction) refreshThePaintImage;

- (IBAction)colorPushed:(id)sender;
-(IBAction)brushSizeButtonPushed:(id)sender;
-(IBAction)buttonSoundFX:(id)sender;

- (IBAction)saveimage:(id)sender;

-(void) retractPaintMenu;
-(void) restorePaintMenu;
-(void) highlightSelectedButton:(UIButton *) button;

- (IBAction) returnToPaintMenuFromPaint:(id)sender;
-(IBAction) showIPhonePaintPalette:(id) sender;

- (IBAction)clearImage:(id) sender;

@end
