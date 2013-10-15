    //
//  SubMenuViewController.m
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/21/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import "SubMenuViewController.h"
#import "ThomasRootViewController.h"
#import "AVQueueManager.h"
#import "PageHandler.h"
#import "subThumbViewController.h"

#import "cdaAnalytics.h"

@implementation SubmenuViewIPhone

-(id)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if (self.userInteractionEnabled && !self.hidden && self.alpha > 0) {
        for(UIView *subview in [self subviews]) {
            CGPoint p = [subview convertPoint:point fromView:self];
            UIView *v = [subview hitTest:p withEvent:event];
            if (v != nil) {
                return v;
            }
        }
    }
    return nil;
}

@end


@interface SubMenuViewController ()
-(void)removeAddSubmenuFromSection:(BOOL)hide;
-(void)addContent:(int)section;
- (void)hideShowNavButtons;
-(void) updateFlurryForNavigationArrowButtons:(NSString*)direction section:(NSString*)section;
@property (nonatomic,retain) NSMutableArray *thumbControllers;
@end

@implementation SubMenuViewController

@synthesize pageNumber;
@synthesize train;
@synthesize navToReadButton, navToPaintButton, navToPuzzleButton;
@synthesize readIndicatorImage, paintIndicatorImage, puzzleIndicatorImage;
@synthesize thumbScrollView;
@synthesize selectedThumbImageView;
@synthesize subMenuIsVisible;
@synthesize fadeOverlayView;
@synthesize thumbControllers = _thumbControllers;
@synthesize pausedQueue;
@synthesize teaserWasShown;

/**/
-(void) initWithParent: (id) parent {
	//NSLog(@"Got an initcall from RootViewController");
	myparent = parent;
	iPhoneMode = [myparent getIPhoneMode];
    
    //Only show teaser for iPad
    if (iPhoneMode) {
        self.teaserWasShown = YES;
    }
    
	return;
}


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/**/
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentPageDidChange:) name:kCurrentPageDidChange object:nil];
    
	subMenuIsVisible = NO;
	subMenuIsRemoved = YES;
	//[self removeAddSubmenuFromSection:subMenuIsRemoved];
    
    [self enableTappedNavButton];
    [self hideShowNavButtons];
}

- (void)updateSelectedThumb:(int)page
{
    self.selectedThumbImageView.hidden = NO;
    
    UIView *thumbholder = [self.thumbScrollView viewWithTag:kThumbHolderTag];
    UIView *tapped = [[thumbholder subviews] objectAtIndex:page - 1];
    float frameOffset = iPhoneMode ? 30 : 16; //depending on device layout the frame differently
    CGPoint point = CGPointMake(tapped.center.x - frameOffset, self.selectedThumbImageView.center.y);
    //        CGPoint point = CGPointMake(tapped.center.x - 16, self.selectedThumbImageView.center.y);
    self.selectedThumbImageView.center = point;
    CGRect frame = self.selectedThumbImageView.frame;
    frame.origin.x -= frame.size.width;
    frame.size.width *= 3;
    [self.thumbScrollView scrollRectToVisible:frame animated:NO]; 
}

- (void)hideShowNavButtons
{
    int currentPage = [PageHandler defaultHandler].currentPage;
    int numberOfPages = [myparent getNumberOfReadPages];
    //only read has an enpage
    if (visibleInterface != NAV_READ) {
        numberOfPages--;
    }
    // first scene
    if (currentPage == 1) {  
        leftnavRead.hidden = YES;
        rightnavRead.hidden = NO;
    }
    //last scene
    else if (currentPage == numberOfPages) {
        leftnavRead.hidden = NO;
        rightnavRead.hidden = YES;
    }
    else {
        leftnavRead.hidden = NO;
        rightnavRead.hidden = NO;
    }
}

-(void)hideBothNavButtonsAnimated {
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options:UIViewAnimationCurveLinear
                     animations:^{
                         leftnavRead.alpha = 0.0f;
                         rightnavRead.alpha = 0.0f;
                     }
                     completion:^(BOOL completed) {
                         
                     }
     ];

}

-(void)showBothNavButtonsAnimated {
    [UIView animateWithDuration:0.1
                          delay:0.2
                        options:UIViewAnimationCurveLinear
                     animations:^{
                         leftnavRead.alpha = 1.0f;
                         rightnavRead.alpha = 1.0f;
                     }
                     completion:^(BOOL completed) {
                         
                     }
     ];
}

-(void) showNavigation {
    if (leftnavRead.frame.origin.x < 0) {
        leftnavRead.frame = CGRectMake(leftnavRead.frame.origin.x+self.view.frame.size.width, leftnavRead.frame.origin.y, leftnavRead.frame.size.width, leftnavRead.frame.size.height);
    }
}

-(void) hideNavigation {
    if (leftnavRead.frame.origin.x > 0) {
        leftnavRead.frame = CGRectMake(leftnavRead.frame.origin.x-self.view.frame.size.width, leftnavRead.frame.origin.y, leftnavRead.frame.size.width, leftnavRead.frame.size.height);
    }
}

- (void)currentPageDidChange:(NSNotification *)notification
{
    [self updateSelectedThumb:[[[notification userInfo] objectForKey:@"currentPage"] intValue]];
    [self hideShowNavButtons];
}

-(void)hideSubMenu {
    [self hideShowSubMenu:YES];
}

-(void)hideShowSubMenu:(BOOL)hide {
    [self hideShowSubMenu:hide withDuration:0.3];
}

-(void)hideShowSubMenu:(BOOL)hide withDuration:(CFTimeInterval)duration {
	
	NSLog(@"Trying to hide the sub menu with: %d", hide);
/*    if ([myparent resumePage] && visibleInterface == NAV_READ && hide) {
        [self fadeOutOverlayView];
        leftnavRead.alpha = 0.0;
        rightnavRead.alpha = 0.0;
        tracksLeftRight.alpha = 1.0;    
        return;
    }*/

	//special case for showing the menu before hiding
    if (subMenuIsVisible && !self.teaserWasShown && hide) {
        //indicate for the user that there is a submenu by showing it a while before hiding it
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hideSubMenu) userInfo:nil repeats:NO];
        self.teaserWasShown = YES;
        [self fadeOutOverlayView];
        leftnavRead.alpha = 0.0;
        rightnavRead.alpha = 0.0;
        tracksLeftRight.alpha = 1.0;
        return;
    }
    
	float movevalue = -119.0;
	if (iPhoneMode) {
		movevalue = -210.0;
	} else {
        if (!hide && visibleInterface == 7) {
            train.hidden = YES;
        } else if (train.hidden) {
            train.hidden = NO;
        }
    }
	
	if (!hide) {
        if (visibleInterface == NAV_READ) {
            //update selectframe just in case
            if (![myparent getEndPageIsDisplayed]) {
                //keep track if submenu paused the queue
                subMenuIsVisible = YES;
                self.pausedQueue = ![[AVQueueManager sharedAVQueueManager] paused];
                [[AVQueueManager sharedAVQueueManager] pause];
                if ([myparent getSpeakerIsDelayed]) {
                    [myparent checkIfNarrationDateIsDelayed];
                }   
            }
        }
    }
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:duration];
	if (hide) {
		//NSLog(@"Hides it");
		subMenuIsVisible = NO;
		self.view.transform = CGAffineTransformIdentity;
		if (visibleInterface == NAV_READ) {
			[myparent resumeCocos:YES];
        }
        //Buttons are hidden for now - left in project in case navigation changes back to buttons again
        leftnavRead.alpha = 1.0;
        rightnavRead.alpha = 1.0;
        tracksLeftRight.alpha = 0.0;
        
        [self fadeOutOverlayView];


        [[NSNotificationCenter defaultCenter] postNotificationName:kSubMenuHidden object:nil];
	}
    else {
        //set active 
		//NSLog(@"Shows it");
		subMenuIsVisible = YES;
		self.view.transform = CGAffineTransformTranslate(self.view.transform , 0.0, movevalue);
		if (visibleInterface == NAV_READ) {
			[myparent pauseCocos:YES];
        }
        
        leftnavRead.alpha = 0.0;
        rightnavRead.alpha = 0.0;
        tracksLeftRight.alpha = 1.0;

        [self fadeInOverlayView];

        [[NSNotificationCenter defaultCenter] postNotificationName:kSubMenuActive object:nil];
	}
	[UIView commitAnimations];
}


-(void) fadeInOverlayView {
//    self.fadeOverlayView.alpha = 0.2;
    [self.fadeOverlayView setUserInteractionEnabled:YES];
    
    //special case for the end page
    if ([myparent getEndPageIsDisplayed]) {
        self.fadeOverlayView.alpha = 0.0;
    }
    else {
        self.fadeOverlayView.alpha = 0.5;
    }
}

-(void) fadeOutOverlayView {
    self.fadeOverlayView.alpha = 0.0;
    // Deactivate touch
    [self.fadeOverlayView setUserInteractionEnabled:NO];    
}

-(void)addInterfaceToSubMenu:(int)interface {
	NSLog(@"this is the selected interface: %i", interface);
	visibleInterface = interface;

		//hide pagenumbers - changed - hide the wagon all togheter instead
		//if (pageNumber.hidden == NO) {
		//	pageNumber.hidden = YES;
		//}
    if (wagon.hidden == NO) {
        wagon.hidden = YES;
    }
    [self hideShowNavButtons];
    if (interface == 1) {
        [self removeInterfaceFromSubMenu];
        [self addContent:interface];
        subMenuIsRemoved = YES;
        [self removeAddSubmenuFromSection:subMenuIsRemoved];
    } else if (interface == NAV_MAIN) {
        [self removeInterfaceFromSubMenu];
        [self addContent:interface];
        subMenuIsRemoved = YES;
        [self removeAddSubmenuFromSection:subMenuIsRemoved];
    } else if (interface == NAV_READ) {
        [self removeInterfaceFromSubMenu];
        [self addContent:interface];
        [self highlightRead];
        if (subMenuIsRemoved) {
            subMenuIsRemoved = NO;
            [self removeAddSubmenuFromSection:subMenuIsRemoved];
        }
        if (subMenuIsVisible) {
            [self hideShowSubMenu:subMenuIsVisible];
        }
    } else if (interface == NAV_WATCH) {
        [self removeInterfaceFromSubMenu];
        [self addContent:interface];
        subMenuIsRemoved = YES;
        [self removeAddSubmenuFromSection:subMenuIsRemoved];
    } else if (interface == NAV_PAINT) {
        [self removeInterfaceFromSubMenu];
        [self addContent:interface];
        [self highlightPaint];
        if (subMenuIsRemoved) {
            subMenuIsRemoved = NO;
            [self removeAddSubmenuFromSection:subMenuIsRemoved];
        }
        if (subMenuIsVisible) {
            [self hideShowSubMenu:subMenuIsVisible];
        }            
    } else if (interface == NAV_PUZZLE) {
        [self removeInterfaceFromSubMenu];
        [self addContent:interface];
        [self highlightPuzzle];
        if (subMenuIsRemoved) {
            subMenuIsRemoved = NO;
            [self removeAddSubmenuFromSection:subMenuIsRemoved];
        }
        if (subMenuIsVisible) {
            [self hideShowSubMenu:subMenuIsVisible];
        }
    } else if (interface == 7) {
        [self removeInterfaceFromSubMenu];
        [self addContent:interface];
        if (subMenuIsRemoved) {
            subMenuIsRemoved = NO;
            [self removeAddSubmenuFromSection:subMenuIsRemoved];
        }
        if (!subMenuIsVisible) {
            [self hideShowSubMenu:subMenuIsVisible];
        }
	}
}


#pragma mark -
-(void)removeInterfaceFromSubMenu {
	//removes interface in subContentHolder
	if (mySubMenuRead != nil) {
		[mySubMenuRead.view removeFromSuperview];
		[mySubMenuRead release];
		mySubMenuRead = nil;
		[self restoreSubmenuFade];
	}
	if (mySubMenuPaint != nil) {
		[mySubMenuPaint.view removeFromSuperview];
		[mySubMenuPaint release];
		mySubMenuPaint = nil;
        [subContentHolder setHidden:NO];
	}
	if (mySubMenuPuzzles != nil) {
		[mySubMenuPuzzles.view removeFromSuperview];
		[mySubMenuPuzzles release];
		mySubMenuPuzzles = nil;
	}
	if (mySubMenuMatch != nil) {
		[mySubMenuMatch.view removeFromSuperview];
		[mySubMenuMatch release];
		mySubMenuMatch = nil;
	}
}


#pragma mark -
#pragma mark style sub menu navigation
-(void)highlightRead {
    [self selectReadButton];
    
    self.readIndicatorImage.hidden   = NO;
    self.paintIndicatorImage.hidden  = YES;
    self.puzzleIndicatorImage.hidden = YES;
}

-(void)highlightPaint {
    [self selectPaintButton];

    self.readIndicatorImage.hidden   = YES;
    self.paintIndicatorImage.hidden  = NO;
    self.puzzleIndicatorImage.hidden = YES;
}

-(void)highlightPuzzle {
    [self selectPuzzleButton];
    
    self.readIndicatorImage.hidden   = YES;
    self.paintIndicatorImage.hidden  = YES;
    self.puzzleIndicatorImage.hidden = NO;
}

-(void)selectReadButton {
    self.navToReadButton.selected    = YES;
    self.navToPuzzleButton.selected  = NO;
    self.navToPaintButton.selected   = NO;
}

-(void)selectPaintButton {
    self.navToReadButton.selected    = NO;
    self.navToPuzzleButton.selected  = NO;
    self.navToPaintButton.selected   = YES;
}

-(void)selectPuzzleButton {
    self.navToReadButton.selected    = NO;
    self.navToPuzzleButton.selected  = YES;
    self.navToPaintButton.selected   = NO;
}

- (void)addThumbs:(NSArray *)thumbnails
{
    // Remove all old thumbs
    for (UIView *v in self.thumbScrollView.subviews) {
        if (v != self.selectedThumbImageView) {
            [v removeFromSuperview];
        }
    }
    self.thumbControllers = nil;
    self.thumbControllers = [NSMutableArray array];
    
	float startx = iPhoneMode ? 15 : 25;
	float starty = 15;
	float thumbwidth = 96;
	float increment = 20;//150;
    if (iPhoneMode) {
        thumbwidth = 90;
        increment = 11;
        starty = self.selectedThumbImageView.frame.origin.y+2;
    }
	float totalwidth = ((thumbwidth+increment)*([thumbnails count]));
    
    CGRect holderframe = CGRectMake(0, starty, totalwidth, self.view.frame.size.height);
	UIView *thumbholder = [[[UIView alloc] initWithFrame:holderframe] autorelease];
    thumbholder.tag = kThumbHolderTag;
	
    UIView *v = [self.thumbScrollView viewWithTag:kThumbHolderTag];
    [v removeFromSuperview];
    
    CGSize size = self.thumbScrollView.frame.size;
    size.width = totalwidth + startx;
    self.thumbScrollView.contentSize = size;
    [self.thumbScrollView addSubview:thumbholder];
    float x = startx;
	for (int i = 0; i < [thumbnails count]; i++) {
        
		subThumbViewController *controller = [[[subThumbViewController alloc] initWithThumb:[thumbnails objectAtIndex:i] parent:self thumbid:i labelnum:0] autorelease];
        CGRect frame = controller.view.frame;
        frame.origin = CGPointMake(x, 0);
        controller.view.frame = frame;
		x += increment + thumbwidth;
        [thumbholder addSubview:controller.view];
        [self.thumbControllers addObject:controller];
	}
    [self updateSelectedThumb:[PageHandler defaultHandler].currentPage];
	[self.thumbScrollView bringSubviewToFront:self.selectedThumbImageView];

}

-(void)menuTappedWithThumb:(int)thumb {
    int page = thumb + 1;
    [self updateSelectedThumb:page];
    [self updateFlurryForNavigationThumbs:visibleInterface fromThumb:[PageHandler defaultHandler].currentPage toThumb:thumb+1];
    if (!self.subMenuIsVisible && !self.teaserWasShown) {
        //special hack to show the submenu briefly before hiding it again
        self.view.transform = CGAffineTransformTranslate(self.view.transform , 0.0, -119.0);
        subMenuIsVisible = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:kSubMenuActive object:nil];


    }
    else {
        [self hideShowSubMenu:YES];
    }
	[PageHandler defaultHandler].currentPage = page;
}

- (IBAction)menuButtonTouchCancelled:(id)sender {
    switch ([myparent getCurrentNavigationItem]) {
        case NAV_READ:
            navToReadButton.selected = YES;
            break;
        case NAV_PAINT:
            navToPaintButton.selected = YES;
            break;
        case NAV_PUZZLE:
            navToPuzzleButton.selected = YES;
            break;
        default:
            break;
    }
}

- (IBAction)menuButtonTouchDown:(id)sender {
    self.navToReadButton.selected = NO;
    self.navToPaintButton.selected = NO;
    self.navToPuzzleButton.selected = NO;
}


-(void)addContent:(int)section {
	if (section == 1) {
		leftnavRead.alpha = 0.0;
		rightnavRead.alpha = 0.0;
		tracksLeftRight.alpha = 1.0;
        fullTrack.alpha = 1.0;
        train.hidden = NO;
	} else if (section == 2) {
		leftnavRead.alpha = 0.0;
		rightnavRead.alpha = 0.0;
		tracksLeftRight.alpha = 1.0;
        fullTrack.alpha = 1.0;
        train.hidden = NO;
	} else if (section == 3) {
		if (mySubMenuRead == nil) {
			mySubMenuRead = [[SubMenuRead alloc] initWithNibName:@"SubMenuRead" bundle:nil];
			[subContentHolder addSubview:mySubMenuRead.view];
            [mySubMenuRead initWithParent:self];
            
            [self addThumbs:[mySubMenuRead getThumbnails]];
            [self menuTappedWithThumb:[PageHandler defaultHandler].currentPage - 1];
			//Buttons are hidden for now - left in project in case navigation changes back to buttons again
			leftnavRead.alpha = 1.0;
			rightnavRead.alpha = 1.0;
			//leftnavRead.alpha = 0.0;
			//rightnavRead.alpha = 0.0;
			//leftnavRead.hidden = YES;
			//rightnavRead.hidden = YES;
			tracksLeftRight.alpha = 0.0;
            fullTrack.alpha = 1.0;
			//show wagon instead of just pagenumber
			wagon.hidden = NO;
            train.hidden = NO;
			//pageNumber.hidden = NO;
			[self setSubmenuFade];
		}
	} else if (section == 4) {
		leftnavRead.alpha = 0.0;
		rightnavRead.alpha = 0.0;
		tracksLeftRight.alpha = 1.0;
        train.hidden = NO;
	} else if (section == 5) {
		if (mySubMenuPaint == nil) {
			mySubMenuPaint = [[SubMenuPaint alloc] initWithNibName:@"SubMenuPaint" bundle:nil];
			[subContentHolder addSubview:mySubMenuPaint.view];
            [subContentHolder setHidden:YES];
			[mySubMenuPaint initWithParent:self];
            
            [self addThumbs:[mySubMenuPaint getThumbnails]];
            [self menuTappedWithThumb:[PageHandler defaultHandler].currentPage - 1];
			leftnavRead.alpha = 1.0;
			rightnavRead.alpha = 1.0;
			tracksLeftRight.alpha = 0.0;
            fullTrack.alpha = 1.0;
            train.hidden = NO;
			[self restoreSubmenuFade];
		}
	} else if (section == 6) {
		if (mySubMenuPuzzles == nil) {
			mySubMenuPuzzles = [[SubMenuPuzzles alloc] initWithNibName:@"SubMenuPuzzles" bundle:nil];
			[subContentHolder addSubview:mySubMenuPuzzles.view];
			[mySubMenuPuzzles initWithParent:self];
            [self addThumbs:[mySubMenuPuzzles getThumbnails]];
            [self menuTappedWithThumb:[PageHandler defaultHandler].currentPage - 1];
			leftnavRead.alpha = 1.0;
			rightnavRead.alpha = 1.0;
			tracksLeftRight.alpha = 1.0;
            fullTrack.alpha = 1.0;
            train.hidden = NO;
			[self restoreSubmenuFade];
		}
	} else if (section == 7) {
		if (mySubMenuMatch == nil) {
			mySubMenuMatch = [[SubMenuMatch alloc] initWithNibName:@"SubMenuMatch" bundle:nil];
			[subContentHolder addSubview:mySubMenuMatch.view];
			[mySubMenuMatch initWithParent:self];
			leftnavRead.alpha = 0.0;
			rightnavRead.alpha = 0.0;
			tracksLeftRight.alpha = 0.0;
            fullTrack.alpha = 0.0;
            train.hidden = YES;
			[self restoreSubmenuFade];
		}
	}
}
-(void)removeAddSubmenuFromSection:(BOOL)hide {
	//hides the submenu in sections that doesn't use it
    
    //If the submenu fades in when the paint color chooser is already showing it looks weired.
    NSTimeInterval duration = (!self.teaserWasShown && visibleInterface == NAV_PAINT) ? 0 : 0.3;
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:duration];
	if (hide) {
		//NSLog(@"Hides it");
		self.view.alpha = 0.0;
        [self fadeOutOverlayView];
	} else {
		//NSLog(@"Shows it");
		self.view.alpha = 1.0;
		if (visibleInterface == 3) {
			leftnavRead.alpha = 1.0;
			rightnavRead.alpha = 1.0;
			tracksLeftRight.alpha = 0.0;
		}

	}
	[UIView commitAnimations];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
	int tag = touch.view.tag;
	if (tag == 1) {
        if (subMenuIsVisible == YES) {
            if (self.pausedQueue) {
                [[AVQueueManager sharedAVQueueManager] play];
            }
        }
		[self hideShowSubMenu:subMenuIsVisible];
	}
	else if (subMenuIsVisible && touchLocation.y < 65) {
        if (self.pausedQueue) {
            [[AVQueueManager sharedAVQueueManager] play];
        }
        [self hideShowSubMenu:subMenuIsVisible];	
	}    
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

#pragma mark Relay iPhoneMode
-(BOOL) getIPhoneMode {
	return iPhoneMode;
}

#pragma mark -
#pragma mark PUZZLES
-(void)preStartJigsawPuzzle:(int)puzzle {
	[myparent preStartJigsawPuzzle:puzzle];
}
-(int) getPuzzleDifficulty {
	return [myparent getPuzzleDifficulty];
}
-(void) setPuzzleLevelOfDifficulty:(int)diff {
	[myparent setPuzzleLevelOfDifficulty:diff];
}

#pragma mark -
#pragma mark DOTS - NOT used in Hero of the Rails
-(void)preStartDots:(int)dot {
	[myparent preStartDots:dot];
}
-(int) getDotDifficulty {
	return [myparent getDotDifficulty];
}
-(void) setDotLevelOfDifficulty:(int)diff {
	[myparent setDotLevelOfDifficulty:diff];
}
-(int) getCurrentDotsPage {
	return [myparent getCurrentDotsPage];
}
-(void) updatePuzzleTrain:(int)image {
	[myparent updateDotTrain:image];
}

#pragma mark -
#pragma mark MATCH
-(void)preStartMatch:(int)match {
	[myparent preStartMatch:match];
}
-(int) getMatchDifficulty {
	return [myparent getMatchDifficulty];
}
-(void) setMatchLevelOfDifficulty:(int)diff {
	[myparent setMatchLevelOfDifficulty:diff];
}
-(void) setMatchingCard:(int)match {
    [mySubMenuMatch setMatchingCard:match];
}
-(void) resetMatchingCards {
    [mySubMenuMatch resetMatchingCards];
}
-(void)hideShowMatchSubmenu:(BOOL)hide {
    NSLog(@"Should be hiding match submenu");
    mySubMenuMatch.view.hidden = hide;
}
#pragma mark -
#pragma mark PAINT 
-(void)refreshPaintImage:(int)image {
	[myparent refreshPaintImage:image];
}
-(int) getCurrentPaintPage {
	return [myparent getCurrentPaintPage];
}
-(void)refreshPaintTrain:(int)image {
	[myparent updatePaintTrain:image];
}
#pragma mark -
#pragma mark READ

-(void)setSubmenuFade {
	//NSString *thePath = [[NSBundle mainBundle] pathForResource:@"scenenav" ofType:@"plist"];
	//NSArray *sceneData = [[NSArray alloc] initWithContentsOfFile:thePath];
	//int scene = [[sceneData objectAtIndex:[myparent getCurrentReadPage]] intValue];
    int scene = [PageHandler defaultHandler].currentPage;
    
	NSString *metapath = [[NSBundle mainBundle] pathForResource:@"scenemetadata" ofType:@"plist"];
    NSArray *getscenedata = [[NSArray alloc] initWithContentsOfFile:metapath];
	NSDictionary *metadata = [[NSDictionary alloc] initWithDictionary:[getscenedata objectAtIndex:scene]];
    NSString *scenecolor = [metadata valueForKey:@"color"];
    
    if ([scenecolor isEqualToString:@"BLACK"]) {
	//if (scene > 17 && scene < 23) {
		if (blackSubmenuFade.alpha == 0.0) {
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
			[UIView setAnimationDuration:1.0];
			blackSubmenuFade.alpha = 1.0;
			whiteSubmenuFade.alpha = 0.0;
			trainlight.alpha = 0.0;
			traindark.alpha = 1.0;
			pageNumber.textColor = [UIColor grayColor];
			[UIView commitAnimations];
			[mySubMenuRead updateColorsOnLabels:NO];
		}
	} else {
		if (whiteSubmenuFade.alpha == 0.0) {
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
			[UIView setAnimationDuration:1.0];
			blackSubmenuFade.alpha = 0.0;
			whiteSubmenuFade.alpha = 1.0;
			trainlight.alpha = 1.0;
			traindark.alpha = 0.0;
			pageNumber.textColor = [UIColor grayColor];
			[UIView commitAnimations];
			[mySubMenuRead updateColorsOnLabels:YES];
		}
	}
	//[sceneData release];
    [getscenedata release];
    [metadata release];
}
-(void)restoreSubmenuFade {
    if (visibleInterface == 7) {
        whiteSubmenuFade.alpha = 0.0;
        blackSubmenuFade.alpha = 0.0;
        //self.view.backgroundColor = [UIColor clearColor];
    } else {
        //self.view.backgroundColor = [UIColor whiteColor];
        if (whiteSubmenuFade.alpha == 0.0) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView setAnimationDuration:0.3];
            blackSubmenuFade.alpha = 0.0;
            whiteSubmenuFade.alpha = 1.0;
            trainlight.alpha = 1.0;
            traindark.alpha = 0.0;
            pageNumber.textColor = [UIColor blackColor];
            [UIView commitAnimations];
        }
    }
}
-(BOOL)getNarrationValue {
	return [myparent getNarrationValue];
}
-(void)setNarrationValue:(BOOL)value {
    if (![[AVQueueManager sharedAVQueueManager] itemInQueue:@"hotspot_movie"]) {
        self.pausedQueue = value;
    }
	[myparent setNarrationValue:value];
}
-(BOOL)getMusicValue {
	return [myparent getMusicValue];
}
-(void)setMusicValue:(BOOL)value {
	[myparent setMusicValue:value];
}
-(BOOL)getSwipeValue {
	return [myparent getSwipeValue];
}
-(void)setSwipeValue:(BOOL)value {
	[myparent setSwipeValue:value];
}
-(void)playNarrationOnScene {
	[myparent playNarrationOnScene];
}
-(void)stopNarrationOnScene {
    [myparent stopNarrationOnScene];
}

-(void)disableTappedNavButton {
    rightnavRead.enabled = NO;
    leftnavRead.enabled = NO;
    [self.view viewWithTag:1].userInteractionEnabled = NO;
    myparent.homeButton.userInteractionEnabled = NO;
    
    [[myparent readOverlayViewController] disableNavigation];
    
}
-(void)enableTappedNavButton {
    rightnavRead.enabled = YES;
    leftnavRead.enabled = YES;
    [self.view viewWithTag:1].userInteractionEnabled = YES;
    myparent.homeButton.userInteractionEnabled = YES;
    
    [[myparent readOverlayViewController] enableNavigation];
}

-(BOOL)isNavButtonsEnabled
{
    return (rightnavRead.enabled && leftnavRead.enabled);
}

-(IBAction)navLeftInRead:(id)sender {
    NSString *mysection = @"";
    if ([myparent getCurrentNavigationItem] == NAV_READ) {
        mysection = @"Read";
    } else if ([myparent getCurrentNavigationItem] == NAV_PAINT) {
        mysection = @"Paint";
    } else if ([myparent getCurrentNavigationItem] == NAV_PUZZLE) {
        mysection = @"Puzzle";
    }
    //FLURRY
    [self updateFlurryForNavigationArrowButtons:@"Previous" section:mysection];
    //
	[myparent turnpage:NO];
}
-(IBAction)navRightInRead:(id)sender {
    NSString *mysection = @"";
    if ([myparent getCurrentNavigationItem] == NAV_READ) {
        mysection = @"Read";
    } else if ([myparent getCurrentNavigationItem] == NAV_PAINT) {
        mysection = @"Paint";
    } else if ([myparent getCurrentNavigationItem] == NAV_PUZZLE) {
        mysection = @"Puzzle";
    }
    //FLURRY
    [self updateFlurryForNavigationArrowButtons:@"Previous" section:mysection];
    //
    [myparent turnpage:YES];
}

//navigate to read, paint and puzzle from the sub menu
-(IBAction)navFunctionality:(id)sender {
    ((UIButton *)sender).selected = YES;
    if ([myparent getEndPageIsDisplayed]) {
        if (sender == self.navToReadButton) {
            [self hideShowSubMenu:YES];
            [PageHandler defaultHandler].currentPage = 1;
        }
        else {
            [[PageHandler defaultHandler] forcePage:1];
        }
    }
    if (sender == self.navToReadButton) {
        //FLURRY
        [[cdaAnalytics sharedInstance] trackEvent:@"Read" inCategory:flurryEventPrefix(@"Submenu") withLabel:@"tap" andValue:-1];
        [myparent navigateFromMainMenuWithItem:NAV_READ];
    }
    else if (sender == self.navToPaintButton) {
        //FLURRY
        [[cdaAnalytics sharedInstance] trackEvent:@"Paint" inCategory:flurryEventPrefix(@"Submenu") withLabel:@"tap" andValue:-1];
        [myparent navigateFromMainMenuWithItem:NAV_PAINT];
    }
    else if (sender == self.navToPuzzleButton) {
        //FLURRY
        [[cdaAnalytics sharedInstance] trackEvent:@"Puzzle" inCategory:flurryEventPrefix(@"Submenu") withLabel:@"tap" andValue:-1];
        [myparent navigateFromMainMenuWithItem:NAV_PUZZLE];
    }
}

-(void) updateFlurryForNavigationArrowButtons:(NSString*)direction section:(NSString*)section {
    
    [[cdaAnalytics sharedInstance] trackEvent:[NSString stringWithFormat:@"Navigating between pages using arrow-buttons. Navigation Direction: %@, Section In App: %@", direction, section]];
}

-(void)updateFlurryForNavigationThumbs:(int)section fromThumb:(int)fromThumb toThumb:(int)toThumb {
    if (fromThumb == toThumb) {
        return;
    }
    
    NSString *mysection = @"";
    if (section == NAV_READ) {
        mysection = @"Read";
    } else if (section == NAV_PAINT) {
        mysection = @"Paint";
    } else if (section == NAV_PUZZLE) {
        mysection = @"Puzzle";
    }
    
    [[cdaAnalytics sharedInstance] trackEvent:[NSString stringWithFormat:@"Navigating between pages using thumbs. SectionInApp: %@, FromPage: %d, ToPage: %d", mysection, fromThumb, toThumb]];
}

//pause and resume with fade down on scene
-(void) pauseCocos:(BOOL)fade {
	[myparent pauseCocos:fade];
}
-(void) resumeCocos:(BOOL)fade {
	[myparent resumeCocos:fade];
}
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[subContentHolder release];
	[train release];
	[leftnavRead release];
	[rightnavRead release];
	[tracksLeftRight release];
	[pageNumber release];
	[train release];
	[blackSubmenuFade release];
	[whiteSubmenuFade release];
	[trainlight release];
	[traindark release];
	[wagon release];
    [fullTrack release];
    [selectedThumbImageView release];
    [navToReadButton release];
    [navToPaintButton release];
    [navToPuzzleButton release];
    [readIndicatorImage release];
    [paintIndicatorImage release];
    [puzzleIndicatorImage release];
    self.thumbControllers = nil;
    [super dealloc];
}

@end
