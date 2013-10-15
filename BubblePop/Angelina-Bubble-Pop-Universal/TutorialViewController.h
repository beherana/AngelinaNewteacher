//
//  TutorialViewController.h
//  Angelina-Bubble-Pop-Universal
//
//  Created by Karl Söderström on 2011-08-16.
//  Copyright 2011 Commind AB. All rights reserved.
//
@class AngelinaScene;

@interface TutorialViewController : UIViewController {
@private
    NSArray *_tutorialSteps;
    IBOutlet UIButton *btnNext;
    IBOutlet UIButton *btnPrev;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIView *arrowsView;
    IBOutlet UIView *startBubbleView;
    int _page;
    IBOutlet UIImageView *imgBackplate;
    IBOutlet UIView *chooseTutorialView;
    IBOutlet UIView *tutorialView;
    IBOutlet UIButton *btnRestart;
    IBOutlet UIButton *btnSkip;
    
    IBOutlet UIButton *btnClock;
    IBOutlet UIButton *btnClassic;
    NSMutableArray *_bubbles;
    AngelinaScene *_angelinaScene;
    
    IBOutlet UIButton *btnAudio;
}

@property (nonatomic, retain) NSArray *tutorialSteps;
@property (nonatomic, assign) int page;
@property (nonatomic, retain) NSMutableArray *bubbles;
@property (nonatomic, retain) AngelinaScene *angelinaScene;
@property (nonatomic, retain) UIView *chooseTutorialView;

- (IBAction)btnAction:(id)sender;
- (IBAction)btnSkipAction:(id)sender;
- (IBAction)btnClassicAction:(id)sender;
- (IBAction)btnClockAction:(id)sender;
- (IBAction)btnRestartAction:(id)sender;
- (IBAction)btnAudioAction:(id)sender;

@end
