//
//  RootViewController.h
//  AngelinaGame
//
//  Created by Karl Söderström on 2011-06-27.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameOverViewController.h"
#import "HUDViewController.h"
#import "PauseViewController.h"
#import "TutorialViewController.h"
#import "TitleViewController.h"
#import "StarAnimationViewController.h"
#import "BubblePopIntroViewController.h"
#import "MenuViewController.h"
#import "cocos2d.h"

@class TitleViewController;

@protocol BubblePopDelegate
@required
- (void)bubblePopHomeButtonPressed;
@end

@interface BubblePopRootViewController : UIViewController {
@private
    GameOverViewController *_gameOverViewController;
    HUDViewController *_hudViewController;
    PauseViewController *_pauseViewController;
    TutorialViewController *_tutorialViewController;
    TitleViewController *_titleViewController;
    StarAnimationViewController *_starAnimationViewController;
    BubblePopIntroViewController *_introViewController;
    MenuViewController *_menuViewController;
    id<BubblePopDelegate> _delegate;
    
    // textures
    CCTexture2D *_whiteglyphs;
    CCTexture2D *_texture_sheet;
}

@property (nonatomic, retain) GameOverViewController *gameOverViewController;
@property (nonatomic, retain) HUDViewController *hudViewController;
@property (nonatomic, retain) PauseViewController *pauseViewController;
@property (nonatomic, retain) TutorialViewController *tutorialViewController;
@property (nonatomic, retain) TitleViewController *titleViewController;
@property (nonatomic, retain) StarAnimationViewController *starAnimationViewController;
@property (nonatomic, retain) BubblePopIntroViewController *introViewController;
@property (nonatomic, retain) MenuViewController *menuViewController;
@property (nonatomic, assign) id<BubblePopDelegate> delegate;

@property (nonatomic, retain) CCTexture2D *whiteglyphs;
@property (nonatomic, retain)
    CCTexture2D *texture_sheet;

- (void)setupHUDView;
- (void)showTitleAnimated:(BOOL)animated;
- (void)showIntroMovie;
- (void)startGame;
- (void)stopGame;
@end
