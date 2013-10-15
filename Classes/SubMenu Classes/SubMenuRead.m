    //
//  SubMenuRead.m
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/22/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import "SubMenuRead.h"
#import "subThumbViewController.h"
#import "cdaAnalytics.h"
#import "SubMenuViewController.h"
#import "PageHandler.h"

@interface SubMenuRead (PrivateMethods)
-(void)createAndAddThumbs:(int)numthumbs;
@end

@implementation SubMenuRead

@synthesize thumbholder, sceneData, thumbControllers;
@synthesize narrationButton, swipeButton;

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
-(void)initWithParent:(id)parent {
	myparent = parent;
	iPhoneMode = [myparent getIPhoneMode];
	
	//setup all paint images...
	//[self createAndAddThumbs:[sceneData count]];
	
	currentNarrationSetting = [myparent getNarrationValue];
	currentMusicSetting = [myparent getMusicValue];
    currentSwipeSetting = [myparent getSwipeValue];

    //a selected narration button means that the narration is turned off
	[self.narrationButton setSelected:!currentNarrationSetting];
    [self.swipeButton setSelected:currentSwipeSetting];
    
	selectedScene = [PageHandler defaultHandler].currentPage;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	//get number of scenes
	NSString *thePath = [[NSBundle mainBundle] pathForResource:@"scenenav" ofType:@"plist"];
	sceneData = [[NSArray alloc] initWithContentsOfFile:thePath];
	
	//setup all paint images...
	//[self createAndAddThumbs:[sceneData count]];

}

- (NSArray*)getThumbnails
{
    NSMutableArray *result = [NSMutableArray array];
    //Subtract one page for the end page
    for (int i = 0; i < ([sceneData count]); i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"readthumb_%i", i + 1]];
        [result addObject:image];
    }
    return [NSArray arrayWithArray:result];
}


-(void) updateColorsOnLabels:(BOOL)black {
	for (unsigned i=0; i < [thumbControllers count]; i++) {
		subThumbViewController *controller = [thumbControllers objectAtIndex:i];
		[controller recolorTextLabel:black];
	}
}

#pragma mark -
#pragma mark scrollView 
- (void)scrollViewWillBeginDragging:(UIScrollView *)sender {
	
}
- (void)scrollViewDidScroll:(UIScrollView *)sender {
	
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	
}
#pragma mark -
#pragma mark Switches
-(IBAction)narrationButtonPressed:(id)sender {
    UIButton *buttonPressed = (UIButton *)sender;
    //invert the button state.
    buttonPressed.selected = !buttonPressed.selected;
    
    //a selected button means that the narration is turned off
    currentNarrationSetting = !buttonPressed.selected;
	[myparent setNarrationValue:currentNarrationSetting];
    
//    if (currentNarrationSetting) {
//        [myparent playNarrationOnScene];
//    } else {
//        [myparent stopNarrationOnScene];
//    }
    
    
    [[cdaAnalytics sharedInstance] trackEvent:[NSString stringWithFormat:@"Turning %@ Narration", (currentNarrationSetting ? @"off" : @"on")]];
}

-(IBAction)swipeButtonPressed:(id)sender {
    UIButton *buttonPressed = (UIButton *)sender;
    //invert the button state.
    buttonPressed.selected = !buttonPressed.selected;
    
    currentSwipeSetting = buttonPressed.selected;
	[myparent setSwipeValue:currentSwipeSetting];
    
    [[cdaAnalytics sharedInstance] trackEvent:[NSString stringWithFormat:@"Turning %@ Swipe", (currentSwipeSetting ? @"on" : @"off")]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[selectframe release];
	thumbScroller.delegate=nil;
	[thumbScroller release];
	thumbScroller=nil;
	[thumbholder release];
	[sceneData release];
	[narrationSwitch release];
	[swipeSwitch release];
	[thumbControllers release];
    [selectframe release];
    [narrationButton release];
    [swipeButton release];
    [super dealloc];
}


@end
