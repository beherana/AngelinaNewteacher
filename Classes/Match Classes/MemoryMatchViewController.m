//
//  MemoryMatchViewController.m
//  The Bird & The Snail - Knock Knock - Memory Match
//
//  Created by Henrik Nord on 3/24/09.
//  Copyright Haunted House 2009. All rights reserved.
//

#import "MemoryMatchViewController.h"
//#import "Angelina_AppDelegate.h"
#import "CardViewController.h"

#import "cdaAnalytics.h"

//static NSUInteger kNumCards = 20;
#define kEasyMatch 10
#define kHardMatch 18

@interface MemoryMatchViewController (PrivateMethods) 
//MEMORY MATCH
- (void) resetCards;
- (void) setupCardBasics;
- (void) loadCardBacksides:(int)line rownum:(int)row;
- (void) createMatchImageArr;
- (void) showStars:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2;
- (void) addEndView;
- (void) showPayOff;
- (void) removeAllCards;
- (void) deleteAllCards;
//MEMORY MATCH sounds
- (void)playMatchSound;
- (void)playSceneChangeSound;
- (void)playPayOffSound:(NSString*)sound;
- (void) stopPayOffSound;

- (void) stopSceneFXSound;

-(float) randRange:(float)low high:(float)high;
//
@end


CGFloat MatchDegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

@implementation MemoryMatchViewController

@synthesize cardControllers, cardSelectArr, matchData, cardRotationArr;

#pragma mark -
#pragma mark setting upp match 
-(id) initWithParentAndLevel:(id)parent level:(int)level {
	self = [super initWithNibName:@"MemoryMatchViewController" bundle:nil];
	if (self) {
		myParent = parent;
		mylevel = level;
        iPhoneMode = [parent getIPhoneMode];
      //  NSLog(@"Match loaded with level: %i", level);
	}
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSString *thePath = [[NSBundle mainBundle] pathForResource:@"matchgame" ofType:@"plist"];
	matchData = [[NSDictionary alloc] initWithContentsOfFile:thePath];
	
	if (mylevel == 0) {
		NSDictionary *mybasics = [[[NSDictionary alloc] initWithDictionary:[matchData objectForKey:@"easy"]] autorelease];
		numberOfImages = [[mybasics valueForKey:@"numberOfImages"] integerValue];
		matchOpacity = [[mybasics valueForKey:@"matchOpacity"] floatValue];
		cardimage = [mybasics valueForKey:@"imageName"];
		matchlevel = [[mybasics valueForKey:@"numberOfCards"] integerValue]; //kEasyMatch;
		numrows = [[mybasics valueForKey:@"numRows"] integerValue];//2;
		numcolumns = [[mybasics valueForKey:@"numColumns"] integerValue];//5;
		cardwidth = [[mybasics valueForKey:@"cardWidth"] floatValue];//78.0;
		cardheight = [[mybasics valueForKey:@"cardHeight"] floatValue];//78.0;
		xgridoffset = [[mybasics valueForKey:@"xGridOffset"] floatValue];//15;
		ygridoffset = [[mybasics valueForKey:@"yGridOffset"] floatValue];//100;
		xoffset = [[mybasics valueForKey:@"xOffset"] floatValue];//15;
		yoffset = [[mybasics valueForKey:@"yOffset"] floatValue];//15;
        isRotated = [[mybasics valueForKey:@"isRotated"] boolValue];
        useCollectedCards = [[mybasics valueForKey:@"useCollectedCards"] boolValue];
	} else {
		NSDictionary *mybasics = [[[NSDictionary alloc] initWithDictionary:[matchData objectForKey:@"hard"]] autorelease];
		numberOfImages = [[mybasics valueForKey:@"numberOfImages"] integerValue];
		matchOpacity = [[mybasics valueForKey:@"matchOpacity"] floatValue];
		cardimage = [mybasics valueForKey:@"imageName"];
		matchlevel = [[mybasics valueForKey:@"numberOfCards"] integerValue];//kHardMatch;
		numrows = [[mybasics valueForKey:@"numRows"] integerValue];//3;
		numcolumns = [[mybasics valueForKey:@"numColumns"] integerValue];//6;
		cardwidth = [[mybasics valueForKey:@"cardWidth"] floatValue];//61.0;
		cardheight = [[mybasics valueForKey:@"cardHeight"] floatValue];//61.0;
		xgridoffset = [[mybasics valueForKey:@"xGridOffset"] floatValue];//17;
		ygridoffset = [[mybasics valueForKey:@"yGridOffset"] floatValue];//73;
		xoffset = [[mybasics valueForKey:@"xOffset"] floatValue];//16;
		yoffset = [[mybasics valueForKey:@"yOffset"] floatValue];//16;
        isRotated = [[mybasics valueForKey:@"isRotated"] boolValue];
        useCollectedCards = [[mybasics valueForKey:@"useCollectedCards"] boolValue];
	}
	
    if (iPhoneMode && useCollectedCards) [myParent setMatchingCard:-1]; //displays collected card matches
    
	endPage = NO;
	
	[self resetCards];
	[self createMatchImageArr];
	
	if (iPhoneMode) {
        [self setupCardBasics];
    } else {
        [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(setupCardBasics) userInfo:nil repeats:NO];
    }
	
	//[self playSceneChangeSound];
	
}
#pragma mark -
#pragma mark resetting all 
- (void) resetCards {
	
	cardsAreActive = NO;
	imageone = -1;
	imagetwo = -1;
	currentcardOne = -1;
	currentcardTwo = -1;
	numCompletedCards = 0;
	numLoadedCards = 0;
}
#pragma mark -
#pragma mark setting upp cards 
- (void) createMatchImageArr {
	//create an arr to pick from
	NSMutableArray *selects = [[NSMutableArray alloc] init];
	for (unsigned i = 0; i < (numberOfImages); i++) {
		[selects addObject:[NSNull null]];
	}
	for (unsigned i = 0; i < (numberOfImages); i++) {
		[selects replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:i+1]];
	}
	//create the image array
	[cardSelectArr removeAllObjects];
	
	NSMutableArray *myimageselects = [[NSMutableArray alloc] init];
	for (unsigned i = 0; i < (matchlevel); i++) {
		[myimageselects addObject:[NSNull null]];
	}
	
	srandom(time(NULL));
	
	for (unsigned i = 0; i < (matchlevel/2); i++) {
		int chosen = random() %  [selects count];
		int myimage;
		myimage = [[selects objectAtIndex:chosen] integerValue];
		[selects removeObjectAtIndex:chosen];
		int g;
		g = i+matchlevel/2;
		[myimageselects replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:myimage]];
		[myimageselects replaceObjectAtIndex:g withObject:[NSNumber numberWithInt:myimage]];
	}
	self.cardSelectArr = myimageselects;
	
	[myimageselects release];
	
}

- (void) setupCardBasics {
    if (!iPhoneMode && isRotated) {
        BOOL switcher = NO;
        cardRotationArr = [[NSMutableArray alloc] init];
        for (unsigned i = 0; i < matchlevel; i++) {
            [cardRotationArr addObject:[NSNull null]];
            float angle = 0.0;
            if (switcher) {
                switcher = NO;
                angle = [self randRange:5.0 high:30.0];
            } else {
                switcher = YES;
                angle = [self randRange:-30.0 high:-5.0];
            }
            [cardRotationArr replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:angle]];
           // NSLog(@"This is the angle: %f", angle);
        } 
        
    }
	cardControllers = [[NSMutableArray alloc] init];
	for (unsigned i = 0; i < matchlevel; i++) {
        [cardControllers addObject:[NSNull null]];
    }

	for (unsigned i = 0; i < matchlevel/numcolumns; i++) {
		for (unsigned j = 0; j < matchlevel/numrows; j++) {
			[self loadCardBacksides:i rownum:j];
		}
	}
}

- (void)loadCardBacksides:(int)line rownum:(int)row {
	//set this one up each time we're entering
	int card = (row * numrows + line);
	//NSLog(@"this is card: %i", card);
	
	
    if (card < 0) return;
    if (card >= matchlevel) return;
	srandom(time(NULL));
	int chosen = random() %  [cardSelectArr count];
	int myimage;
	myimage = [[cardSelectArr objectAtIndex:chosen] integerValue];
	[cardSelectArr removeObjectAtIndex:chosen];
	
	//NSLog(@"This is the image name I'm sending: %@", cardimage);
	CardViewController *controller = [[CardViewController alloc] initWithCardNumber:myimage cardid:card parent:self imagename:(NSString*)cardimage];
	[cardControllers replaceObjectAtIndex:card withObject:controller];
    
    // add the controller's view to the stage
	if (controller != nil) {
		//NSLog(@"something wrong with the controller?");
        CGRect frame;
		//position card
		float xpos;
		float ypos;
		
		xpos = xgridoffset + ((xoffset+cardwidth) * row);
		ypos = ygridoffset + ((yoffset+cardheight) * line);
		
        frame.origin.x = xpos;
        frame.origin.y = ypos;
		//
		frame.size.width = cardwidth;
		frame.size.height = cardheight;
		//
        controller.view.frame = frame;
        
        if (!iPhoneMode && isRotated) {
            float angle = [[cardRotationArr objectAtIndex:0] integerValue];
            [cardRotationArr removeObjectAtIndex:0];
            //NSLog(@"This is the angle: %f", angle);
            //controller.view.frame.origin.y = controller.frame.origin.y + angle/10;
            controller.view.center = CGPointMake(controller.view.center.x+angle/5, controller.view.center.y - angle);
            controller.view.transform = CGAffineTransformRotate(controller.view.transform, MatchDegreesToRadians(angle));
        }
		//
        [self.view addSubview:controller.view];
       
    }
     
	[controller release];
	controller = nil;
}
-(float) randRange:(float)low high:(float)high {
    float base=(random()%100)/100.0; 
    return base*(high-low)+low;
}
#pragma mark -
#pragma mark turning cards 
- (void) cardFlipped:(int)card cardid:(int)cardid {
	//
	if (cardsAreActive == NO) return;
	
	if (imageone == -1 && imagetwo == -1) {
		//no card is open (both are -1) bizniz as usuall - do whatever needs to be done here...
		//get new carddata
		currentcardOne = cardid;
		imageone = card;
		CardViewController *controller = [cardControllers objectAtIndex:currentcardOne];
		[controller switchCards];
		
		return;
		//
	} else {
		//check if 1 or 2 cards are open
		if (imageone != -1 && imagetwo != -1) {
			//unless i hit an open card
			if (currentcardOne == cardid || currentcardTwo == cardid) {
				//oops clicked an open card
				return;
			}
			//both cards are open - please close them immediately
			CardViewController *controller_1 = [cardControllers objectAtIndex:currentcardOne];
			CardViewController *controller_2 = [cardControllers objectAtIndex:currentcardTwo];
			//message them to tell them to close down biz
			[controller_1 switchCards];
			[controller_2 switchCards];
			//reset carddata
			currentcardOne = -1;
			currentcardTwo = -1;
			imageone = -1;
			imagetwo = -1;
			//get new carddata
			currentcardOne = cardid;
			imageone = card;
			//flip the new card
			CardViewController *controller = [cardControllers objectAtIndex:currentcardOne];
			[controller switchCards];		
			//then return since I don't need any other checks after this
			return;
		}
		//check if 1 card is open if the new card is the same
		if (imageone != -1 || imagetwo != -1) {
			//check to see if they are the same
			if (currentcardOne == cardid || currentcardTwo == cardid) {
				//oops clicked an open card
				return;
			}
			//check wich one to populate
			if (imageone == -1) {
				//imageOne is the one to populate
				currentcardOne = cardid;
				imageone = card;
				CardViewController *controller = [cardControllers objectAtIndex:currentcardOne];
				[controller switchCards];
			} else if (imagetwo == -1) {
				//imageTwo is the one to populate
				currentcardTwo = cardid;
				imagetwo = card;
				CardViewController *controller = [cardControllers objectAtIndex:currentcardTwo];
				[controller switchCards];
			}
			//check for a match
			if (imageone == imagetwo) {
				//eureka we got a match - clean up data and make cards stickies
				numCompletedCards++;
				if (numCompletedCards == matchlevel/2) {
                    
                    [[cdaAnalytics sharedInstance] trackEvent:[NSString stringWithFormat:@"MATCH completed with level of difficulty: %i", mylevel]];
                    
					//
					matchBackToMenuButton.hidden = YES;
					matchtitle.hidden = YES;
                    if (!iPhoneMode) {
                        [myParent hideShowMatchSubmenu:YES];
                    }
					//start timer for end animation
					[NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(addEndView) userInfo:nil repeats:NO];
				}
                if (!iPhoneMode && useCollectedCards) {
                    [myParent setMatchingCard:card];
                }
				[self playMatchSound];
				CardViewController *controller_1 = [cardControllers objectAtIndex:currentcardOne];
				[controller_1 lockCard];
				
				CardViewController *controller_2 = [cardControllers objectAtIndex:currentcardTwo];
				[controller_2 lockCard];
				
				[self showStars:controller_1.view.center.x y1:controller_1.view.center.y x2:controller_2.view.center.x y2:controller_2.view.center.y];
				//and clean up carddata
				currentcardOne = -1;
				currentcardTwo = -1;
				imageone = -1;
				imagetwo = -1;
				
			} else {
				//oh no - sorry - this is not the one we are looking for
				return;
			}
			//we are done here - no need to continue
			return;
		}
	}
}
#pragma mark -
#pragma mark match feedback 
- (void) showStars:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2 {
	//start by loading
	//get plist data
	NSDictionary *mybasics = [[[NSDictionary alloc] initWithDictionary:[matchData objectForKey:@"matchFeedback"]] autorelease];
	if ([mybasics objectForKey:@"imageName"] != NULL) {
		NSString *feedbackimagename = [mybasics valueForKey:@"imageName"];
		int numberofimages = [[mybasics valueForKey:@"numberOfImages"] intValue];
		float myduration = [[mybasics valueForKey:@"duration"] floatValue];
		int myrepeats = [[mybasics valueForKey:@"repeats"] intValue];
		// Alloc all places in list first
		NSMutableArray *mystaranimation = [[NSMutableArray alloc] init];
		for (unsigned i = 0; i < numberofimages; i++) {
			[mystaranimation addObject:[NSNull null]];
		}
		int z = 0;
		while (z < numberofimages) {
			//get image
			NSString *imagePath = [NSString stringWithFormat:@"%@" @"%i" @".png", feedbackimagename, z];
			UIImage *renderedView = [UIImage imageNamed:imagePath];
			[mystaranimation replaceObjectAtIndex:z withObject:renderedView];
			[renderedView release];
			renderedView = nil;
			imagePath = nil;
			z++;
		}
		
		UIImageView *stars1 = [[[UIImageView alloc] initWithImage:[mystaranimation objectAtIndex:0]] autorelease];
		UIImageView *stars2 = [[[UIImageView alloc] initWithImage:[mystaranimation objectAtIndex:0]] autorelease];
		
		[self.view addSubview:stars1];
		[self.view addSubview:stars2];
		
		stars1.animationImages = mystaranimation;
		stars1.animationDuration =myduration;
		stars1.animationRepeatCount = myrepeats;
		
		stars2.animationImages = mystaranimation;
		stars2.animationDuration = myduration;
		stars2.animationRepeatCount = myrepeats;
		
		[mystaranimation release];
		
		stars1.center = CGPointMake(x1, y1);
		stars2.center = CGPointMake(x2, y2);
		
		[stars1 startAnimating];
		[stars2 startAnimating];
		
		[self.view bringSubviewToFront:stars1];
		[self.view bringSubviewToFront:stars2];
		
		stars1.hidden = NO;
		stars2.hidden = NO;
	}
}
#pragma mark -
#pragma mark payoff
- (void) showPayOff {
	//get plist data
	NSDictionary *maindict = [[[NSDictionary alloc] initWithDictionary:[matchData objectForKey:@"endAnimation"]] autorelease];
	NSDictionary *mybasics = [[[NSDictionary alloc] initWithDictionary:[maindict objectForKey:@"parentTranslateAnimation"]] autorelease];
	float mystartx = 0.0;
	float mystarty = 0.0;
	float myendx = 0.0;
	float myendy = 0.0;
	float mystartscalex = 1.0;
	float mystartscaley = 1.0;
	float myendscalex = 1.0;
	float myendscaley = 1.0;
	float mystartrotation = 0.0;
	float myendrotation = 0.0;
	float mywidth = 0.0;
	float myheight = 0.0;
	//
	NSString *myimagename = @"";
	float myimagewidth = 0.0;
	float myimageheight = 0.0;
	float myimagex = 0.0;
	float myimagey = 0.0;
	int myimagedepth = 0;
	float parentduration = [[mybasics valueForKey:@"duration"] floatValue];
	BOOL usetranslate = NO;
	BOOL usescale = NO;
	BOOL userotation = NO;
	
	NSString *sound = @"";
	
	if ([mybasics objectForKey:@"endX"] != NULL) {
		myendx = [[mybasics valueForKey:@"endX"] floatValue];
		usetranslate = YES;
	}
	if ([mybasics objectForKey:@"endY"] != NULL) {
		myendy = [[mybasics valueForKey:@"endY"] floatValue];
		usetranslate = YES;
	}
	if ([mybasics objectForKey:@"startScaleX"] != NULL) {
		mystartx = [[mybasics valueForKey:@"startX"] floatValue];
		
	}
	if ([mybasics objectForKey:@"startScaleY"] != NULL) {
		mystarty = [[mybasics valueForKey:@"startY"] floatValue];
		
	}
	if ([mybasics objectForKey:@"startScaleX"] != NULL) {
		mystartscalex = [[mybasics valueForKey:@"startScaleX"] floatValue];
	}
	if ([mybasics objectForKey:@"startScaleY"] != NULL) {
		mystartscaley = [[mybasics valueForKey:@"startScaleY"] floatValue];
	}
	if ([mybasics objectForKey:@"endScaleX"] != NULL) {
		myendscalex = [[mybasics valueForKey:@"endScaleX"] floatValue];
		usescale = YES;
	}
	if ([mybasics objectForKey:@"endScaleY"] != NULL) {
		myendscaley = [[mybasics valueForKey:@"endScaleY"] floatValue];
		usescale = YES;
	}
	if ([mybasics objectForKey:@"startRotation"] != NULL) {
		mystartrotation = [[mybasics valueForKey:@"startRotation"] floatValue];
		
	}
	if ([mybasics objectForKey:@"endRotation"] != NULL) {
		myendrotation = [[mybasics valueForKey:@"endRotation"] floatValue];
		userotation = YES;
	}
	if ([mybasics objectForKey:@"backgroundImage"] != NULL || [mybasics valueForKey:@"backgroundImage"] != @"") {
		myimagename = [mybasics valueForKey:@"backgroundImage"];
		//NSLog(@"myimagename: %@", myimagename);
		myimagewidth = [[mybasics valueForKey:@"backgroundImageWidth"] floatValue];
		myimageheight = [[mybasics valueForKey:@"backgroundImageHeight"] floatValue];
		myimagex = [[mybasics valueForKey:@"backgroundImageX"] floatValue];
		myimagey = [[mybasics valueForKey:@"backgroundImageY"] floatValue];
		myimagedepth = [[mybasics valueForKey:@"backgroundImageDepth"] intValue];
	}
	if ([maindict objectForKey:@"soundFile"] != NULL || [maindict valueForKey:@"soundFile"] != @"") {
		sound = [maindict valueForKey:@"soundFile"];
	}
	//
	
	NSBundle *bundle = [NSBundle mainBundle];
	
	CGRect payoffframe = CGRectMake(mystartx, mystarty, mywidth, myheight);
	UIView *animcontainer = [[[UIView alloc] initWithFrame:payoffframe] autorelease];
	if (myimagename != @"") {
		NSString *bkgimgpath = [bundle pathForResource:[NSString stringWithFormat:@"%@", myimagename] ofType:@"png"];
		UIImage *bkgimage = [UIImage imageWithContentsOfFile:bkgimgpath];
		CGRect bkgimageframe = CGRectMake(myimagex, myimagey, myimagewidth, myimageheight);
		UIImageView *bkgholder = [[UIImageView alloc] initWithFrame:bkgimageframe];
		bkgholder.image = bkgimage;
		bkgholder.tag = myimagedepth;
		[animcontainer addSubview:bkgholder];
		[bkgholder release];
	}
	
	//
	//get number of child animations
	NSArray *animations = [maindict objectForKey:@"animationBlocks"];
	for (unsigned i = 0; i < [animations count]; i++) {
		NSDictionary *myanimbasics = [[NSDictionary alloc] initWithDictionary:[animations objectAtIndex:i]];
		NSString *feedbackimagename = [myanimbasics valueForKey:@"imageName"];
		int numberofimages = [[myanimbasics valueForKey:@"numberOfImages"] intValue];
		float myx = [[myanimbasics valueForKey:@"x"] floatValue];
		float myy = [[myanimbasics valueForKey:@"y"] floatValue];
		int mydepth = [[myanimbasics valueForKey:@"depth"] intValue];
		float myduration = [[myanimbasics valueForKey:@"duration"] floatValue];
		int myrepeats = [[myanimbasics valueForKey:@"repeats"] intValue];
		NSMutableArray *payoffAnimation = [[NSMutableArray alloc] init];
		/**/
		for (unsigned i = 0; i < numberofimages; i++) {
			//NSLog(@"Building the array");
			[payoffAnimation addObject:[NSNull null]];
		}
		 
		int z = 0;
		while (z < numberofimages) {
			//get image
			NSString *imagePath = [NSString stringWithFormat:@"%@" @"%i" @".png", feedbackimagename, z+1];
			UIImage *renderedView = [UIImage imageNamed:imagePath];
			[payoffAnimation replaceObjectAtIndex:z withObject:renderedView];
			[renderedView release];
			z++;
		}
		
		UIImageView *mysubanim = [[UIImageView alloc] initWithImage:[payoffAnimation objectAtIndex:0]];
		
		mysubanim.animationImages = payoffAnimation;
		mysubanim.animationDuration = myduration;
		mysubanim.animationRepeatCount = myrepeats;
		
		mysubanim.center = CGPointMake(myx+(mysubanim.frame.size.width/2), myy+(mysubanim.frame.size.height/2));
		
		mysubanim.tag = mydepth; //use tag to resort depth later - just make the whole thing work first...
		
		[animcontainer addSubview:mysubanim];
		
		///resolves a bug if I want to check if anim is animating but I'm not checking this here
		//mysubanim.hidden = YES;
		////////////////
		//mysubanim.hidden = NO;
		
		[mysubanim startAnimating];
		
		[mysubanim release];
		[payoffAnimation release];
		[myanimbasics release];
	}
	
	//reorder images and animations so they get proper depth
	for (unsigned i = 0; i < [[animcontainer subviews] count]; i++) {
		UIView *tapped = [animcontainer viewWithTag:i+1];
		[animcontainer bringSubviewToFront:tapped];
	}
	
	//set initial scale and rotation if needed
	if (usescale || (mystartscalex != 1.0 || mystartscaley != 1.0)) animcontainer.transform = CGAffineTransformScale(animcontainer.transform, mystartscalex, mystartscaley);
	if (userotation || mystartrotation != 0.0) animcontainer.transform = CGAffineTransformRotate(animcontainer.transform, MatchDegreesToRadians(mystartrotation));
	
	//add
	[self.view addSubview:animcontainer];
	
	//do animation on parent if relevant
	if (parentduration != 0) {
		//animate parent containter
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(payoffAnimationFinished:finished:context:)];
		[UIView setAnimationDuration:parentduration];
		if (usetranslate) animcontainer.center = CGPointMake(myendx, myendy);
		if (usescale) animcontainer.transform = CGAffineTransformScale(animcontainer.transform, myendscalex, myendscaley);
		if (userotation) animcontainer.transform = CGAffineTransformRotate(animcontainer.transform, MatchDegreesToRadians(myendrotation));
		[UIView commitAnimations];
	}
	
	//play sound for animation
	if (sound != @"") {
		[self playPayOffSound:(NSString*)sound];
	}
	
}

-(void)payoffAnimationFinished:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	[myParent redrawMenu];
}
#pragma mark -
#pragma mark removing and registering
- (IBAction)removeMemoryMatch:(id)sender {
	
	[matchtitle release];
	[cardControllers removeAllObjects];
	[cardControllers release];
	[cardSelectArr release];
	[matchBackToMenuButton release];
	[matchData release];
	
	[myParent redrawMenu];
}

- (void) registerCard {
	numLoadedCards++;
	if (numLoadedCards == matchlevel) {
		cardsAreActive = YES;	
	}
	return;
}
- (void) deleteAllCards {
	//NSLog(@"deleteAllCards");
	/*
	for (unsigned i = 0; i < [cardControllers count]; i++) {
		NSLog(@"This is cardControllers count: %i", [cardControllers count]);
        CardViewController *controller = [cardControllers objectAtIndex:i];
		[controller removeCard];
		if ([controller.view superview]) [controller.view removeFromSuperview];
    }
	*/
	[cardControllers removeAllObjects];
}
- (void) removeAllCards {
	for (unsigned i = 0; i < [cardControllers count]; i++) {
        CardViewController *controller = [cardControllers objectAtIndex:i];
		[controller hideCard];
    }
}
#pragma mark -
#pragma mark end view
- (void) addEndView {
	if (matchOpacity == 0.0) {
		//cards are allready hidden
		[self deleteAllCards];
		[self showPayOff];
	} else {
		//hide the cards
		[self removeAllCards];
		[NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(showPayOff) userInfo:nil repeats:NO];
	}
	[self playSceneChangeSound];
}

#pragma mark -
#pragma mark getters and setters
-(float)getcardwidth {
	return cardwidth;
}
-(float)getcardheight {
	return cardheight;
}
-(float)getMatchOpacity {
	return matchOpacity;
}
#pragma mark -
#pragma mark SOUND
- (void)playCardSound:(int)sound {
	[myParent playCardSound:sound];
}
- (void)playMatchSound {
	[myParent playFXEventSound:@"match"];
}
- (void)playSceneChangeSound {
}
- (void) stopSceneFXSound {
}

- (void)playPayOffSound:(NSString*)sound {
	[myParent playFXEventSound:sound];
}
/*
- (void)playCardSound:(int)sound {
	
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if (appDelegate.fxPlayer.playing) [appDelegate stopFXPlayback];
	
	NSString *mypath = [NSString stringWithFormat:@"cardsound%i", sound-1];
	NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:mypath ofType:@"m4a"]];
	AVAudioPlayer *thePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
	[fileURL release];
	if (thePlayer) {
		appDelegate.fxPlayer = thePlayer;
		[thePlayer release];
		appDelegate.fxPlayer.volume = 0.4;
		[appDelegate startFXPlayback];
	}
}
- (void)playMatchSound {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if (appDelegate.fxPlayer.playing) [appDelegate stopFXPlayback];
	
	NSString *mypath = [NSString stringWithFormat:@"match"];
	NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:mypath ofType:@"m4a"]];
	AVAudioPlayer *thePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
	[fileURL release];
	if (thePlayer) {
		appDelegate.fxPlayer = thePlayer;
		[thePlayer release];
		appDelegate.fxPlayer.volume = 0.4;
		[appDelegate startFXPlayback];
	}
}
- (void)playSceneChangeSound {
	
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if (appDelegate.fxPlayer.playing) [appDelegate stopFXPlayback];
	
	NSString *mypath = [NSString stringWithFormat:@"endsound"];
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
- (void) stopSceneFXSound {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	if (appDelegate.fxPlayer.playing) [appDelegate stopFXPlayback];
}

- (void)playPayOffSound {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if (appDelegate.fxPlayer.playing) [appDelegate stopFXPlayback];
	
	NSString *mypath = [NSString stringWithFormat:@"payoff"];
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
*/
#pragma mark -
#pragma mark memory 
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	//MEMORY MATCH
	//NSLog(@"match got dealloced");
	[matchtitle release];
	[cardControllers removeAllObjects];
	[cardControllers release];
	[cardSelectArr release];
    [cardRotationArr release];
	[matchBackToMenuButton release];
	[matchData release];
    [super dealloc];
	
}

@end
