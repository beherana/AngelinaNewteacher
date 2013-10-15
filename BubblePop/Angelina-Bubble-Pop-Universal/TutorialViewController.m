//
//  TutorialViewController.m
//  Angelina-Bubble-Pop-Universal
//
//  Created by Karl Söderström on 2011-08-16.
//  Copyright 2011 Commind AB. All rights reserved.
//

#import "TutorialViewController.h"
#import "cocos2d.h"
#import "AngelinaScene.h"
#import "GameState.h"
#import "TitleScene.h"
#import "GameParameters.h"
#import "Animations.h"
#import "cdaAnalytics.h"
#import "FlurryGameEvent.h"
#import "AudioHelper.h"

@interface TutorialViewController ()
- (void)playAnimation:(int)page;
- (void)showArrows:(int)page;
@end

@implementation TutorialViewController
@synthesize tutorialSteps = _tutorialSteps;
@synthesize page = _page;
@synthesize bubbles = _bubbles;
@synthesize angelinaScene = _angelinaScene;
@synthesize chooseTutorialView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization       
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
 
#ifdef ANGELINA_BUBBLE_POP_INAPP
    btnAudio.hidden = YES;
#endif // ANGELINA_BUBBLE_POP_INAPP
    
    
    [GameState sharedInstance].tutorialMode = YES;
    CCScene *scene = [AngelinaScene scene];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.2 scene:scene]];
    self.angelinaScene = (AngelinaScene *)[scene getChildByTag:ANGELINA_SCENE_TAG];
    self.angelinaScene.thoughtBubble.visible = NO;
    
    btnAudio.selected = ![AudioHelper audioIsEnabled];
}

- (void)darkenAllSprites
{
    ccColor3B color = ccc3(160,160,160);
    //AngelinaScene *scene = (AngelinaScene *)[[CCDirector sharedDirector].runningScene getChildByTag:ANGELINA_SCENE_TAG];
    [self.angelinaScene setColor:color];
    [self.angelinaScene.thoughtBubble setColor:color];
    [self.angelinaScene.highScoreLabel setColor:color];
    [self.angelinaScene.scoreLabel setColor:color];
    [self.angelinaScene.best setColor:color];
    [self.angelinaScene.livesIndicator setColor:color];
    [self.angelinaScene.timeHandler setColor:color];
    for (Bubble *bubble in self.bubbles) {
        [bubble setColor:color];
    }
}

- (void)highlightSprite:(NSString *)name
{
    CCNode *sprite = nil;
    //AngelinaScene *scene = (AngelinaScene *)[[CCDirector sharedDirector].runningScene getChildByTag:ANGELINA_SCENE_TAG];
    
    if ([name isEqualToString:@"angelina"]) {
        sprite = self.angelinaScene.angelina;
    } else if ([name isEqualToString:@"thoughtBubble"]) {
        sprite = self.angelinaScene.thoughtBubble;
    } else if ([name isEqualToString:@"lives"]) {
        sprite = self.angelinaScene.livesIndicator;
    } else if ([name isEqualToString:@"time"]) {
        sprite = self.angelinaScene.timeHandler;
    } else if ([name hasPrefix:@"bubble"]) {
        NSUInteger index = [[name substringFromIndex:6] intValue];
        sprite = [self.bubbles objectAtIndex:index];
    }
    
    [(id<CCRGBAProtocol>)sprite setColor:ccc3(255, 255, 255)];
}

- (void)loadTutorial:(NSString *)tutorialPath
{
    [[CCDirector sharedDirector] resume];
    
    [UIView animateWithDuration:0.2 animations:^(void) {
        chooseTutorialView.alpha = 0;
        tutorialView.alpha = 1;
    }];
    
    
    NSDictionary *tutorial = [NSDictionary dictionaryWithContentsOfFile:tutorialPath];
    
    //AngelinaScene *angelinaScene = [AngelinaScene getCurrent];
    
    [self.angelinaScene.thoughtBubble unschedule:@selector(randomizeNextFlowerType)];
    
    self.angelinaScene.thoughtBubble.nextType = [[tutorial objectForKey:@"thoughtBubble"] intValue];
    [self.angelinaScene.thoughtBubble updateFlowerType];

    self.angelinaScene.thoughtBubble.visible = YES;
    [self.angelinaScene.thoughtBubble runAction:[CCFadeIn actionWithDuration:0.2]];
    
    self.angelinaScene.livesIndicator.lives = [[tutorial objectForKey:@"lives"] intValue];
    
    self.bubbles = [NSMutableArray array];
    
    for (NSDictionary *b in [tutorial objectForKey:@"bubbles"]) {
        int type = [[b objectForKey:@"type"] intValue];
        Bubble *bubble = nil;
        if (type == BubbleType_Flower) {
            bubble = [self.angelinaScene.bubbleLayer addBubbleWithType:BubbleType_Flower flowerType:[[b objectForKey:@"flowerType"] intValue]];
        } else {
            bubble = [self.angelinaScene.bubbleLayer addBubbleWithType:type];            
        }        
        bubble.sprite.scale = scaleValueToScreen([[b objectForKey:@"scale"] floatValue]);
        bubble.bonusSprite.scale = bubble.sprite.scale;
        bubble.positionInPixels = ccp(scaleValueToScreen([[b objectForKey:@"x"] floatValue]),
                                      scaleValueToScreen([[b objectForKey:@"y"] floatValue]));
        [self.bubbles addObject:bubble];
    }
    
    
    self.page = 0;
    btnPrev.hidden = YES;
    
    self.tutorialSteps = [tutorial objectForKey:@"steps"];
    
    const float leftMargin = scaleValueToUIKitScreen(27);
    UIImage *rule = [UIImage imageNamed:@"rule_tutorial.png"];
    float x = rule.size.width;
    
    for (NSDictionary *step in self.tutorialSteps) {
        x += leftMargin;
        UIImage *image = [UIImage imageNamed:[step objectForKey:@"textImage"]];
        UIImageView *imageView = [[[UIImageView alloc] initWithImage:image] autorelease];
        imageView.frame = CGRectMake(x, 0, scrollView.frame.size.width - leftMargin - rule.size.width*2, scrollView.frame.size.height);
        imageView.contentMode = UIViewContentModeLeft;
        
        x += imageView.frame.size.width;
        
        [scrollView addSubview:imageView];
        
        if (step != [self.tutorialSteps lastObject]) {
            UIImageView *ruler = [[[UIImageView alloc] initWithImage:rule] autorelease];
            ruler.frame = CGRectMake(x, 0, rule.size.width, scrollView.frame.size.height);
            ruler.contentMode = UIViewContentModeLeft;
            x += ruler.frame.size.width;
            [scrollView addSubview:ruler];
        }
    }
    
    scrollView.contentSize = CGSizeMake(x, scrollView.frame.size.height);

    UITapGestureRecognizer *recognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startAction:)] autorelease];
    [startBubbleView addGestureRecognizer:recognizer];
    
    [self showArrows:self.page];
    [self performSelector:@selector(playAnimation:) withObject:(id)self.page afterDelay:0.8];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [GameState sharedInstance].tutorialMode = NO;
}

- (void)viewDidUnload
{
    [GameState sharedInstance].tutorialMode = NO;
    [btnNext release];
    btnNext = nil;
    [btnPrev release];
    btnPrev = nil;
    [scrollView release];
    scrollView = nil;
    [arrowsView release];
    arrowsView = nil;
    [startBubbleView release];
    startBubbleView = nil;
    [imgBackplate release];
    imgBackplate = nil;
    [chooseTutorialView release];
    chooseTutorialView = nil;
    [tutorialView release];
    tutorialView = nil;
    [btnRestart release];
    btnRestart = nil;
    [btnSkip release];
    btnSkip = nil;
    [btnClassic release];
    btnClassic = nil;
    [btnClock release];
    btnClock = nil;
    [super viewDidUnload];
    self.tutorialSteps = nil;
    self.bubbles = nil;
    self.angelinaScene = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)dealloc
{
    [GameState sharedInstance].tutorialMode = NO;
    self.tutorialSteps = nil;
    self.bubbles = nil;
    self.angelinaScene = nil;
    [btnNext release];
    [btnPrev release];
    [scrollView release];
    [arrowsView release];
    [startBubbleView release];
    [imgBackplate release];
    [chooseTutorialView release];
    [tutorialView release];
    [btnRestart release];
    [btnSkip release];
    [btnClassic release];
    [btnClock release];
    [super dealloc];
}

- (void)closeTutorial:(NSString *)nextScene
{
    [[cdaAnalytics sharedInstance] trackEvent:@"Close" inCategory:flurryEventPrefix(@"How-To Complete") withLabel:@"tap" andValue:-1];

    [[Animations sharedInstance] stopCurrentAnimation];
    
    [GameState sharedInstance].tutorialMode = NO;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:nextScene forKey:@"nextScene"];
    [[NSNotificationCenter defaultCenter] postNotificationName:AngelinaGame_TutorialEnded object:self userInfo:userInfo];
}

- (void)enableButtons
{
    btnPrev.hidden = (self.page == 0);
}

- (void)scrollToPage:(int)page {
    UIImage *rule = [UIImage imageNamed:@"rule_tutorial.png"];
    float x = page * (scrollView.frame.size.width - rule.size.width);
    CGPoint p = CGPointMake(x, 0);
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
        scrollView.contentOffset = p;
    } completion:nil];
    // For some reason these ways of scolling don't work. It seems to be something
    // with how UIKit is synced with cocos display link.
    //
    //[scrollView setContentOffset:CGPointMake(x, 0) animated:NO];
    //[scrollView scrollRectToVisible:CGRectMake(x, 0, scrollView.frame.size.width, scrollView.frame.size.height) animated:YES];
}

- (void)playAnimation:(int)page {
    NSString *animation = [[self.tutorialSteps objectAtIndex:page] objectForKey:@"animation"];
    if (animation != nil && [animation length] > 0) {
        [[Animations sharedInstance] startAnimation:animation onNode:self.angelinaScene.angelina];
    }

}

- (void)showArrows:(int)page {
    
    
    [self darkenAllSprites];
    NSArray *highlight = [[self.tutorialSteps objectAtIndex:page] objectForKey:@"highlight"];
    for (NSString *name in highlight) {
        [self highlightSprite:name];
    }
    
    // Remove old arrows
    for (UIView *v in arrowsView.subviews) {
        [UIView animateWithDuration:0.2 delay:0.3 options:UIViewAnimationCurveLinear animations:^(void) {
            v.alpha = 0;
        } completion:^(BOOL finished) {
            [v removeFromSuperview];
        }];
    }
    
    // Add new arrows
    NSArray *arrows = [[self.tutorialSteps objectAtIndex:page] objectForKey:@"arrows"];
    for (NSDictionary *arrow in arrows) {
        float x = scaleValueToUIKitScreen([[arrow objectForKey:@"x"] floatValue]);
        float y = scaleValueToUIKitScreen([[arrow objectForKey:@"y"] floatValue]);
        UIImage *image = [UIImage imageNamed:[arrow objectForKey:@"image"]];
        
        UIImageView *v = [[[UIImageView alloc] initWithImage:image] autorelease];
        v.frame = CGRectMake(x, y, image.size.width, image.size.height);
        v.alpha = 0;
        [arrowsView addSubview:v];
        [UIView animateWithDuration:0.2 delay:0.3 options:UIViewAnimationCurveLinear animations:^(void) {
            v.alpha = 1;
        } completion:nil];
    }
}

- (IBAction)btnAction:(id)sender {
    if (sender == btnNext) {
        self.page = self.page + 1;
    } else {
        self.page = self.page - 1;
    }
    
    if (self.page == [self.tutorialSteps count]) {
        for (UIView *v in self.view.subviews) {
            if (v != startBubbleView && v != btnRestart) {
                [UIView animateWithDuration:0.2 animations:^(void) {
                    v.alpha = 0;
                }];
            }
        }
        [[AngelinaScene getCurrent].bubbleLayer popAllBubbles];
        [[AngelinaScene getCurrent].thoughtBubble runAction:[CCFadeOut actionWithDuration:0.2]];
        
        startBubbleView.alpha = 0;
        startBubbleView.hidden = NO;
        [UIView animateWithDuration:0.2 animations:^(void) {
            startBubbleView.alpha = 1;
        }];
        
        btnRestart.hidden = NO;
        btnSkip.hidden = YES;
    } else {
        [self scrollToPage:self.page];
        [self enableButtons];
        [self showArrows:self.page];
        [self playAnimation:self.page];
    }
}

- (void)startAction:(UIGestureRecognizer *)recognizer
{
    [[cdaAnalytics sharedInstance] trackEvent:@"Start" inCategory:flurryEventPrefix(@"How-To Complete") withLabel:@"tap" andValue:-1];
    
    [self closeTutorial:@"game"];    
}

- (IBAction)btnSkipAction:(id)sender {
    [self closeTutorial:@"title"];
}

- (IBAction)btnClassicAction:(id)sender {
    [[cdaAnalytics sharedInstance] trackEvent:@"Classic" inCategory:flurryEventPrefix(@"How-To") withLabel:@"tap" andValue:-1];
    
    if (!self.tutorialSteps) {
        [GameState sharedInstance].gameMode = AngelinaGameMode_Classic;
        [GameParameters reset];
        AngelinaScene *scene = self.angelinaScene;
        scene.livesIndicator = [LivesIndicator node];
        [scene addChild:scene.livesIndicator z:20];
        
        [self loadTutorial:[[NSBundle mainBundle] pathForResource:@"tutorial" ofType:@"plist"]];
    }
}

- (IBAction)btnClockAction:(id)sender {
    [[cdaAnalytics sharedInstance] trackEvent:@"Beat the Clock" inCategory:flurryEventPrefix(@"How-To") withLabel:@"tap" andValue:-1];

    if (!self.tutorialSteps) {
        [GameState sharedInstance].gameMode = AngelinaGameMode_Clock;
        [GameParameters reset];
        AngelinaScene *scene = self.angelinaScene;
        scene.timeHandler = [TimeHandler node];
        [scene addChild:scene.timeHandler z:20];
    
        [self loadTutorial:[[NSBundle mainBundle] pathForResource:@"tutorial_clock" ofType:@"plist"]];
    }
}

- (IBAction)btnRestartAction:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:AngelinaGame_TutorialStarted object:self userInfo:[NSDictionary dictionaryWithObject:@"Classic" forKey:@"GameType"]];
}

- (IBAction)btnAudioAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    if (button.selected) {
        [AudioHelper disableAudio];
    } else {
        [AudioHelper enableAudio];
    }
}
@end
