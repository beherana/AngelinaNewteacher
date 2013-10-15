    //
//  SubMenuPaint.m
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/22/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import "SubMenuPaint.h"
#import "subThumbViewController.h"

@interface SubMenuPaint (PrivateMethods)
-(void)createAndAddThumbs:(int)numthumbs;
@end

@implementation SubMenuPaint

@synthesize thumbholder;

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
	//start up paint
	/*skip random
	//select a random image
	srandom(time(NULL));
	int chosen = random() %  9;
	selectedPaintImage = chosen+1;
	NSLog(@"selectedPaintImage: %i", selectedPaintImage);
	[self menuTappedWithThumb:selectedPaintImage];
	 */
	//[myparent refreshPaintImage:selectedPaintImage];
	//[myparent preStartJigsawPuzzle:selectedPaintImage];
	//UIView *selected = [self.view viewWithTag:selectedPaintImage];
	//selectframe.center = selected.center;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    //get number of scenes
	NSString *thePath = [[NSBundle mainBundle] pathForResource:@"scenenav" ofType:@"plist"];
	sceneData = [[NSArray alloc] initWithContentsOfFile:thePath];

}

- (NSArray*)getThumbnails
{
    NSMutableArray *result = [NSMutableArray array];
    //Subtract one page for the end page
    for (int i = 0; i < ([sceneData count]-1); i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"paintthumb_%i", i + 1]];
        [result addObject:image];
    }
    return [NSArray arrayWithArray:result];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)sender {
	
}
- (void)scrollViewDidScroll:(UIScrollView *)sender {
	
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	
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
	[thumbScroller release];
	[thumbholder release];
    [sceneData release];
    [super dealloc];
}


@end
