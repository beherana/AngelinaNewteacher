//
//  GameOverViewController.h
//  Angelina-Bubble-Pop-Universal
//
//  Created by Karl Söderström on 2011-06-30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StarAnimationViewController.h"

@interface GameOverViewController : UIViewController {
    StarAnimationViewController *_starAnimationViewController;
    IBOutlet UIImageView *imgGameOver;
    IBOutlet UIButton *btnRestart;
    IBOutlet UIButton *btnQuit;
}

@property (nonatomic, retain) StarAnimationViewController *starAnimationViewController;
- (IBAction)btnRestartAction:(id)sender;
- (IBAction)btnQuitAction:(id)sender;

@end
