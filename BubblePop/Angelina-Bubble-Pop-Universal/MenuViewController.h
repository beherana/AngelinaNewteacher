//
//  MenuViewController.h
//  Angelina-Bubble-Pop-Universal
//
//  Created by Karl Söderström on 2011-09-02.
//  Copyright (c) 2011 Commind AB. All rights reserved.
//

typedef enum {
    AngelinaGameMenuIcon_Star = 0,
    AngelinaGameMenuIcon_Play,
    AngelinaGameMenuIcon_Pause,
} AngelinaGameMenuIcon;


@interface MenuViewController : UIViewController {
    BOOL _isShowing;
    BOOL _willPause;
    BOOL _willResume;
    AngelinaGameMenuIcon _icon;
    IBOutlet UIImageView *imgSubmenu;
    IBOutlet UIImageView *imgIcon;
    IBOutlet UIButton *btnContinue;
    IBOutlet UIButton *btnRestart;
    IBOutlet UIButton *btnQuit;
    IBOutlet UIButton *btnTutorial;
    IBOutlet UIButton *btnSound;
    IBOutlet UIButton *btnSoundDisabled;
}

@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, assign) AngelinaGameMenuIcon icon;

- (void)bringToFront;

- (IBAction)btnToggleAction:(id)sender;
- (void)setIsShowing:(BOOL)isShowing animated:(BOOL)animated;
- (IBAction)btnContinueAction:(id)sender;
- (IBAction)btnRestartAction:(id)sender;
- (IBAction)btnQuitAction:(id)sender;
- (IBAction)btnTutorialAction:(id)sender;
- (IBAction)btnSoundAction:(id)sender;



@end
