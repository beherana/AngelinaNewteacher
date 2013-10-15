//
//  HUDViewController.h
//  Angelina-Bubble-Pop-Universal
//
//  Created by Karl Söderström on 2011-08-03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//



@interface HUDViewController : UIViewController {
    UIButton *btnPause;
}

@property (nonatomic, retain) IBOutlet UIButton *btnPause;
- (IBAction)btnPauseAction:(id)sender;

@end
