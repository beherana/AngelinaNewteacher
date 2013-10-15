//
//  JigsawPuzzlePieceController.m
//  The Bird & The Snail - Knock Knock - Deluxe
//
//  Created by Henrik Nord on 6/29/09.
//  Copyright 2009 Haunted House. All rights reserved.
//

#import "JigsawPuzzlePieceController.h"
#import "jigsawViewController.h"
#import "Angelina_AppDelegate.h"
#import "JigsawCreator.h"

CGFloat jigsawPieceDegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

#define kCompensateX 0//10
#define kCompensateY 0//-100
 /*
 #define kCompensateX 210
 #define kCompensateY 20
*/

@interface JigsawPuzzlePieceController (PrivateMethods)
-(void)initializeMyPuzzlePiece;
-(void) updateCurrentOrientation;
- (void)playMatchSound;
@end

@implementation JigsawPuzzlePieceController

@synthesize imageView = _imageView;

- (id)initWithJigsawPiece:(int)piece size:(NSString*)size {
    self = [super init];
	if (self) {
        myPiece = piece;
        mySize = size;
        if ([mySize isEqualToString:@"small"]) {
            mySize = @"12_";
        } else {
            mySize = @"";
        }
    }
	return self;
}
-(void) initWithParent: (id) parent
{
	if (self){
		myJigParent = parent;
		theCurrentPuzzle = [myJigParent getCurrentPuzzle];
		[self initializeMyPuzzlePiece];
	}
	return;
}

- (void) initializeMyPuzzlePiece {
    // change 9 to 12
    JigsawCreator *creator = [[[JigsawCreator alloc]
                               initWithPList:[[NSBundle mainBundle] pathForResource:@"jigsaw_pieces" ofType:@"plist"] numPieces:[mySize isEqualToString:@""] ? 6 : kNumberOfHardJigsawPieces] autorelease];
    UIImage *image = [creator createJigsawPiece:myPiece fromImage:myJigParent.image];
    
    self.imageView = [[[UIImageView alloc] initWithImage:image] autorelease];
    self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    self.view.frame = self.imageView.frame;
    
    //UIImage *effect = [UIImage imageNamed:[NSString stringWithFormat: @"puzzle%@_effect%i.png",[mySize isEqualToString:@""] ? @"" : @"9", myPiece]];
    UIImage *effect = [UIImage imageNamed:[NSString stringWithFormat: @"puzzle%@_effect%i.png",[mySize isEqualToString:@""] ? @"" : [NSString stringWithFormat:@"%i",kNumberOfHardJigsawPieces], myPiece]];
    UIImageView *effectView = [[[UIImageView alloc] initWithImage:effect] autorelease];
    effectView.center = CGPointMake(self.imageView.frame.size.width/2, self.imageView.frame.size.height/2);
    [self.imageView addSubview:effectView];
    
    // Setup shadow
    self.imageView.layer.shadowColor = [UIColor colorWithRed:88.0/255.0 green:58.0/255.0 blue:0 alpha:1].CGColor;
    self.imageView.layer.shadowOffset = CGSizeMake(0, 0);
    self.imageView.layer.shadowRadius = 5;
    self.imageView.layer.shadowOpacity = 0.0;
    
	NSMutableArray *startxArr;
	float startx;
	NSMutableArray *startyArr;
	float starty;
	
	if ([mySize isEqualToString:@""]) {
		startxArr = [myJigParent.finalDestination objectAtIndex:0];
		startx = [[startxArr objectAtIndex:myPiece-1] floatValue];
		startyArr = [myJigParent.finalDestination objectAtIndex:1];
		starty = [[startyArr objectAtIndex:myPiece-1] floatValue];
	} else {
		startxArr = [myJigParent.finalHardDestination objectAtIndex:0];
		startx = [[startxArr objectAtIndex:myPiece-1] floatValue];
		startyArr = [myJigParent.finalHardDestination objectAtIndex:1];
		starty = [[startyArr objectAtIndex:myPiece-1] floatValue];
	}
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone) {
		if ([mySize isEqualToString:@""]) {
			//reposition the easy puzzle since these positions was translated from the iphone version
			startx += kCompensateX;
			starty += kCompensateY;
		}
	}
	self.view.center = CGPointMake(startx, starty);
	
	self.view.alpha = 0.0;
	
	//[self.view addSubview:tempShadow];
	[self.view addSubview:self.imageView];
		
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.3];
	self.view.alpha = 1.0;
	[UIView commitAnimations];
	
}
- (void) repositionLockedJigsawPiece {
	//NSLog(@"reposition Locked Jigsaw Piece called");
	
	NSMutableArray *startxArr;
	float startx;
	NSMutableArray *startyArr;
	float starty;
	
	if ([mySize isEqualToString:@""]) {
		startxArr = [myJigParent.finalDestination objectAtIndex:0];
		startx = [[startxArr objectAtIndex:myPiece-1] floatValue];
		startyArr = [myJigParent.finalDestination objectAtIndex:1];
		starty = [[startyArr objectAtIndex:myPiece-1] floatValue];
	} else {
		startxArr = [myJigParent.finalHardDestination objectAtIndex:0];
		startx = [[startxArr objectAtIndex:myPiece-1] floatValue];
		startyArr = [myJigParent.finalHardDestination objectAtIndex:1];
		starty = [[startyArr objectAtIndex:myPiece-1] floatValue];
	}
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone) {
		if ([mySize isEqualToString:@""]) {
			//reposition the easy puzzle since these positions was translated from the iphone version
			startx += kCompensateX;
			starty += kCompensateY;
		}
	}
	self.view.center = CGPointMake(startx, starty);
}
- (void) scrambleJigsawPuzzle {
	float startx;
	float starty;
	float myrotate;
	
	NSMutableArray *startxArr;
	NSMutableArray *startyArr;
	NSMutableArray *rotateArr;
	
	if ([mySize isEqualToString:@""]) {
		startxArr = [myJigParent.startDestinationLandscape objectAtIndex:0];
		startx = [[startxArr objectAtIndex:myPiece-1] floatValue];
		startyArr = [myJigParent.startDestinationLandscape objectAtIndex:1];
		starty = [[startyArr objectAtIndex:myPiece-1] floatValue];
		rotateArr = [myJigParent.startDestinationLandscape objectAtIndex:2];
		myrotate = [[rotateArr objectAtIndex:myPiece-1] floatValue];
	} else {
		startxArr = [myJigParent.startHardDestinationLandscape objectAtIndex:0];
		startx = [[startxArr objectAtIndex:myPiece-1] floatValue];
		startyArr = [myJigParent.startHardDestinationLandscape objectAtIndex:1];
		starty = [[startyArr objectAtIndex:myPiece-1] floatValue];
		rotateArr = [myJigParent.startHardDestinationLandscape objectAtIndex:2];
		myrotate = [[rotateArr objectAtIndex:myPiece-1] floatValue];
	}

	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone) {
		if ([mySize isEqualToString:@""]) {
			//reposition the easy puzzle since these positions was translated from the iphone version
			startx += kCompensateX;
			starty += kCompensateY;
		}
	}
	
	CGFloat rotation = 0.0+myrotate;
	CATransform3D rotationTransform = CATransform3DIdentity;
	rotationTransform = CATransform3DRotate(rotationTransform, jigsawPieceDegreesToRadians(rotation), 0.0, 0.0, 1.0);
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.1];
    self.imageView.layer.shadowOpacity = 0.9;
	self.view.layer.transform = rotationTransform;
	self.view.transform = CGAffineTransformScale(self.view.transform, 0.5, 0.5);
	self.view.center = CGPointMake(startx, starty);
	[UIView commitAnimations];
	
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	//NSLog(@"touching a puzzle piece");
	
	Angelina_AppDelegate *appDelegate = (Angelina_AppDelegate *)[[UIApplication sharedApplication] delegate];
	//play eventsound
	[appDelegate playFXEventSound:@"Select"];
	
	if (![myJigParent getUnscrambled]) return;
	//
	NSNumber *mystate = [NSNumber numberWithInt:[[myJigParent.completedPieces objectAtIndex:myPiece-1] integerValue]];
	if (mystate == [NSNumber numberWithInt:1]) return;
	
	[myJigParent switchDepth:myPiece direction:1];
	[myJigParent switchToBig:myPiece];
	
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:myJigParent.view];
	
	xcompensation = location.x-self.view.center.x;
	ycompensation = location.y-self.view.center.y;
	
	//reset jigsawpiece
	self.view.transform = CGAffineTransformIdentity;

}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if (![myJigParent getUnscrambled]) return;
	NSNumber *mystate = [NSNumber numberWithInt:[[myJigParent.completedPieces objectAtIndex:myPiece-1] integerValue]];
	if (mystate == [NSNumber numberWithInt:1]) return;
	
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:myJigParent.view];
	
	self.view.center = CGPointMake(location.x-xcompensation,location.y-ycompensation);
	
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"Tapping on the movie but so I shouldn't be seeing this!");
	Angelina_AppDelegate *appDelegate = (Angelina_AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if (![myJigParent getUnscrambled]) {
		//need to scramble puzzle
		[myJigParent setUnscrambled];
		[myJigParent scrambelPuzzlePieces];
		//play eventsound
		[appDelegate playFXEventSound:@""];
		return;
	}
	
	NSNumber *mystate = [NSNumber numberWithInt:[[myJigParent.completedPieces objectAtIndex:myPiece-1] integerValue]];
	if (mystate == [NSNumber numberWithInt:1]) return;
	
	BOOL inPlace = NO;
	float myCenterX = self.view.center.x;
	float myCenterY = self.view.center.y;
	float limit = 50;
	float xMinVal = myCenterX - limit;
	float xMaxVal = myCenterX + limit;
	float yMinVal = myCenterY - limit;
	float yMaxVal = myCenterY + limit;
	
	NSMutableArray *startxArr;
	NSMutableArray *startyArr;
	float startx;
	float starty;
	if ([mySize isEqualToString:@""]) {
		startxArr = [myJigParent.finalDestination objectAtIndex:0];
		startx = [[startxArr objectAtIndex:myPiece-1] floatValue];
		startyArr = [myJigParent.finalDestination objectAtIndex:1];
		starty = [[startyArr objectAtIndex:myPiece-1] floatValue];
	} else {
		startxArr = [myJigParent.finalHardDestination objectAtIndex:0];
		startx = [[startxArr objectAtIndex:myPiece-1] floatValue];
		startyArr = [myJigParent.finalHardDestination objectAtIndex:1];
		starty = [[startyArr objectAtIndex:myPiece-1] floatValue];
	}

	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone) {
		if ([mySize isEqualToString:@""]) {
			//reposition the easy puzzle since these positions was translated from the iphone version
			startx += kCompensateX;
			starty += kCompensateY;
		}
	}
	if ((startx > xMinVal && startx < xMaxVal) && (starty > yMinVal && starty < yMaxVal)) {
		inPlace = YES;
		NSNumber *mystate = [NSNumber numberWithInt:1];
		[myJigParent.completedPieces replaceObjectAtIndex:myPiece-1 withObject:mystate];
	} else {
		inPlace = NO;
	}
	
	if (inPlace) {
		
		//play in place sound
		[self playMatchSound];
		
		//put at exact pos
		
        [myJigParent switchDepth:myPiece direction:0];
		[myJigParent returnToSmall:myPiece];
		[UIView animateWithDuration:0.1
                              delay:0
                            options:UIViewAnimationCurveEaseOut
                         animations:^{
                             self.view.center = CGPointMake(startx, starty);
                             //remove shadow
                             self.imageView.layer.shadowOpacity = 0.0;
                         }
                         completion:^(BOOL){
                             [myJigParent finished:self];
                             [myJigParent checkJigsawCompletion];
                         }];        
		
	} else {

		[myJigParent returnToSmall:myPiece];
		
		float startx;
		float starty;
		float myrotate;
		
		NSMutableArray *startxArr;
		NSMutableArray *startyArr;
		NSMutableArray *rotateArr;
		
		if ([mySize isEqualToString:@""]) {
			startxArr = [myJigParent.startDestinationLandscape objectAtIndex:0];
			startx = [[startxArr objectAtIndex:myPiece-1] floatValue];
			startyArr = [myJigParent.startDestinationLandscape objectAtIndex:1];
			starty = [[startyArr objectAtIndex:myPiece-1] floatValue];
			rotateArr = [myJigParent.startDestinationLandscape objectAtIndex:2];
			myrotate = [[rotateArr objectAtIndex:myPiece-1] floatValue];
		} else {
			startxArr = [myJigParent.startHardDestinationLandscape objectAtIndex:0];
			startx = [[startxArr objectAtIndex:myPiece-1] floatValue];
			startyArr = [myJigParent.startHardDestinationLandscape objectAtIndex:1];
			starty = [[startyArr objectAtIndex:myPiece-1] floatValue];
			rotateArr = [myJigParent.startHardDestinationLandscape objectAtIndex:2];
			myrotate = [[rotateArr objectAtIndex:myPiece-1] floatValue];
		}

		if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone) {
			if ([mySize isEqualToString:@""]) {
				//reposition the easy puzzle since these positions was translated from the iphone version
				startx += kCompensateX;
				starty += kCompensateY;
			}
		}
		
		CGFloat rotation = 0.0+myrotate;
		CATransform3D rotationTransform = CATransform3DIdentity;
		rotationTransform = CATransform3DRotate(rotationTransform, jigsawPieceDegreesToRadians(rotation), 0.0, 0.0, 1.0);
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDuration:0.2];
		self.view.layer.transform = rotationTransform;
		self.view.transform = CGAffineTransformScale(self.view.transform, 0.5, 0.5);
		self.view.center = CGPointMake(startx, starty);
		[UIView commitAnimations];
		
		//play eventsound
		[appDelegate playFXEventSound:@""];
		
	}
	self.view.alpha = 1.0;
}

- (void)playMatchSound {
	Angelina_AppDelegate *appDelegate = (Angelina_AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if (appDelegate.fxPlayer.playing) [appDelegate stopFXPlayback];
	//REPLACED - temp silence
	//NSString *mypath = [NSString stringWithFormat:@"menubutton"];
	NSString *mypath = [NSString stringWithFormat:@"silence"];
	NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:mypath ofType:@"m4a"]];
	AVAudioPlayer *thePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
	[fileURL release];
	if (thePlayer) {
		appDelegate.fxPlayer = thePlayer;
		[thePlayer release];
		appDelegate.fxPlayer.volume = 0.6;
		[appDelegate startFXPlayback];
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
	//NSLog(@"Puzzle piece was dealloced");
	self.imageView = nil;
    [super dealloc];
}


@end
