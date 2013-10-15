//
//  PauseViewController.h
//  Angelina-Bubble-Pop-Universal
//
//  Created by Karl Söderström on 2011-08-03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//



@interface PauseViewController : UIViewController {
    
    IBOutlet UIButton *btnQuit;
    IBOutlet UIButton *btnRestart;
    IBOutlet UIButton *btnContinue;
    IBOutlet UIButton *btnAudio;
}

- (IBAction)btnContinueAction:(id)sender;
- (IBAction)btnRestartAction:(id)sender;
- (IBAction)btnAudioAction:(id)sender;
- (IBAction)btnQuitAction:(id)sender;

@end
