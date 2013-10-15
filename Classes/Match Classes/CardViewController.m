//
//  CardViewController.m
//  The Bird and The Snail - Knock Knock - Memory Match
//
//  Created by Henrik Nord on 3/24/09.
//  Copyright 2009 Haunted House. All rights reserved.
//

#import "CardViewController.h"
#import "MemoryMatchViewController.h"

@interface CardViewController (PrivateMethods) 
- (void)initCards;
@end

@implementation CardViewController

@synthesize frontside, backside;

// Load the view nib and initialize the pageNumber ivar.
- (id)initWithCardNumber:(int)card cardid:(int)thisId parent:(id)parent imagename:(NSString*)imagename {
	self = [super initWithNibName:@"MemoryCardView" bundle:nil];
	if (self) {
        cardNumber = card;
		cardID = thisId;
		myParent = parent;
		cardimagename = imagename;
		//NSLog(@"This is the image name inside cards: %@", imagename);
    }
    return self;
}

- (void) initCards {
	//
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelay:0.25+(cardID*0.08)];
	[UIView setAnimationDuration:0.2];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(registerCard:finished:context:)];
	backside.transform = CGAffineTransformIdentity;
	backside.alpha = 1.0;
	[UIView commitAnimations];

}
- (void) registerCard:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	[myParent registerCard];
}
- (void) switchCards {
	//
	if ([frontside superview]) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDuration:0.3];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:NO];
		[frontside removeFromSuperview];
		[self.view addSubview:backside];
		[UIView commitAnimations];
	} else {
		[myParent playCardSound:cardNumber];
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDuration:0.3];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:NO];
		[backside removeFromSuperview];
		[self.view addSubview:frontside];
		[UIView commitAnimations];
	}	
}

- (void) lockCard {
	cardLockedDown = YES;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelay:0.9];
	[UIView setAnimationDuration:0.3];
	frontside.alpha = [myParent getMatchOpacity];
	[UIView commitAnimations];
}
- (void) hideCard {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelay:0.05+(cardID*0.05)];
	[UIView setAnimationDuration:0.1];
	frontside.alpha = 0.0;
	[UIView commitAnimations];
}
- (void) removeCard {
	if ([frontside superview]) [frontside removeFromSuperview];
	if ([backside superview]) [backside removeFromSuperview];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	//NSBundle *bundle = [NSBundle mainBundle];
	
	CGRect imagesize = CGRectMake(0, 0, [myParent getcardwidth], [myParent getcardheight]);
	//backside (apple)
	UIImageView *mybackimg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cardbackside.png"]];
	mybackimg.frame = imagesize;
	
	mybackimg.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.000].CGColor;
	mybackimg.layer.shadowOpacity = 0.4;
	mybackimg.layer.shouldRasterize = YES;
	mybackimg.layer.shadowOffset = CGSizeMake(0.0,3.0);
	mybackimg.layer.shadowRadius = 2.0;
	
	self.backside = mybackimg;
	
	//frontside (card)
	//NSString *imagePath = [bundle pathForResource:[NSString stringWithFormat:@"%@" @"%i", cardimagename, cardNumber] ofType:@"png"];
	//UIImageView *myfrontimg = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imagePath]];
    NSString *imagePath = [NSString stringWithFormat:@"%@" @"%i" @".png", cardimagename, cardNumber];
    UIImageView *myfrontimg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imagePath]];
    
	myfrontimg.frame = imagesize;
	
	myfrontimg.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.000].CGColor;
	myfrontimg.layer.shadowOpacity = 0.4;
	myfrontimg.layer.shouldRasterize = YES;
	myfrontimg.layer.shadowOffset = CGSizeMake(0.0,3.0);
	myfrontimg.layer.shadowRadius = 2.0;
	
	self.frontside = myfrontimg;
	
	
	[self.view addSubview:backside];
	//backside.transform = CGAffineTransformScale(backside.transform, 0.1, 0.1);
	//backside.alpha = 0.0;
	
	[myfrontimg release];
	myfrontimg = nil;
	[mybackimg release];
	mybackimg = nil;
	
	
	//NSLog(@"prior to init cards");
	
	//[self initCards];
    //[NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(initCards) userInfo:nil repeats:NO];
    //REMOVED CARD START ANIMATION
    //ENABLE CARDS IMMEDIATELY
    [myParent registerCard];

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	//NSLog(@"Touched card");
	if (!cardLockedDown) {
		[myParent cardFlipped:cardNumber cardid:cardID];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	//NSLog(@"Cards are released");
	[frontside release];
	[backside release];
    [super dealloc];
}


@end
