    //
//  SubMenuPuzzles.m
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/22/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import "SubMenuPuzzles.h"
//#import "ThomasRootViewController.h"
#import "subThumbViewController.h"

//#import "Angelina_AppDelegate.h"

@interface SubMenuPuzzles()
- (void)updateDifficultyButtons;
@end

@implementation SubMenuPuzzles


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
    levelOfDifficulty = [myparent getPuzzleDifficulty];
    [self updateDifficultyButtons];
    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"scenenav" ofType:@"plist"];
	sceneData = [[NSArray alloc] initWithContentsOfFile:thePath];
    
}

/*
*/
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    [super viewDidLoad];
	//Moved to initWithParent so that we have a parent to get difficulty from
    /*
	levelOfDifficulty = [myparent getPuzzleDifficulty];
    [self updateDifficultyButtons];
    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"scenenav" ofType:@"plist"];
	sceneData = [[NSArray alloc] initWithContentsOfFile:thePath];
     */
}

- (void)updateDifficultyButtons
{
    easybutton.selected = (levelOfDifficulty == 0);
    hardbutton.selected = !easybutton.selected;
}

- (void)setDifficulty:(int)newDifficulty
{
    if (levelOfDifficulty == newDifficulty) {
        return;
    }
    levelOfDifficulty = newDifficulty;
    [myparent hideShowSubMenu:YES];
    [myparent setPuzzleLevelOfDifficulty:levelOfDifficulty];
    [self updateDifficultyButtons];
}

- (IBAction)easyButtonAction:(id)sender
{
    [self setDifficulty:0];
}

- (IBAction)hardButtonAction:(id)sender
{
    [self setDifficulty:1];
}

- (NSArray*)getThumbnails
{
    NSMutableArray *result = [NSMutableArray array];
    //Subtract one image for the end page
    for (int i = 0; i < ([sceneData count]-1); i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"readthumb_%i", i + 1]];
        [result addObject:image];
    }
    return [NSArray arrayWithArray:result];
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
    [sceneData release];
    [easybutton release];
    [hardbutton release];
    [super dealloc];
}


@end
