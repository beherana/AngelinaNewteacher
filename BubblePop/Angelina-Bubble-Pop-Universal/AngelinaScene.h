//
//  AngelinaScene.h
//  AngelinaGame
//
//  Created by Karl Söderström on 2011-06-27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BubbleLayer.h"
#import "ThoughtBubble.h"
#import "LivesIndicator.h"
#import "ScoreHandler.h"
#import "TimeHandler.h"

// Notifications
#define AngelinaGame_LivesChanged @"AngelinaGame_LivesChanged"
#define AngelinaGame_ScoreChanged @"AngelinaGame_ScoreChanged"
#define AngelinaGame_ThoughtBubbleChanged @"AngelinaGame_ThoughtBubbleChanged"
#define AngelinaGame_BubblePopped @"AngelinaGame_BubblePopped"
#define AngelinaGame_LastLifeLost @"AngelinaGame_LastLifeLost"
#define AngelinaGame_GameOver @"AngelinaGame_GameOver"
#define AngelinaGame_GamePaused @"AngelinaGame_GamePaused"
#define AngelinaGame_GameResumed @"AngelinaGame_GameResumed"
#define AngelinaGame_GameReset @"AngelinaGame_GameReset"
#define AngelinaGame_TutorialStarted @"AngelinaGame_TutorialStarted"
#define AngelinaGame_TutorialEnded @"AngelinaGame_TutorialEnded"
#define AngelinaGame_GameWillStart @"AngelinaGame_GameWillStart"
#define AngelinaGame_GameDidStart @"AngelinaGame_GameDidStart"
#define AngelinaGame_GameDidEnd @"AngelinaGame_GameDidEnd"
#define AngelinaGame_IntroMovieDidFinish @"AngelinaGame_IntroMovieDidFinish"

#define ANGELINA_SCENE_TAG 9988

@interface AngelinaScene : CCLayer {
    BubbleLayer *_bubbleLayer;
    ThoughtBubble *_thoughtBubble;
    LivesIndicator *_livesIndicator;
    CCLabelBMFont *_scoreLabel;
    CCLabelBMFont *_highScoreLabel;
    CCSprite *_best;
    ScoreHandler *_scoreHandler;
    CCSprite *_angelina;
    TimeHandler *_timeHandler;
}

@property (nonatomic, assign) BubbleLayer *bubbleLayer;
@property (nonatomic, assign) ThoughtBubble *thoughtBubble;
@property (nonatomic, assign) LivesIndicator *livesIndicator;
@property (nonatomic, assign) CCLabelBMFont *scoreLabel;
@property (nonatomic, assign) CCLabelBMFont *highScoreLabel;
@property (nonatomic, retain) ScoreHandler *scoreHandler;
@property (nonatomic, assign) CCSprite *angelina;
@property (nonatomic, assign) TimeHandler *timeHandler;
@property (nonatomic, assign) CCSprite *best;
+(CCScene *) scene;
+(AngelinaScene *) getCurrent;
-(void) reset;
-(void) pause;
-(void) resume;

- (void)setColor:(ccColor3B)color;

@end
