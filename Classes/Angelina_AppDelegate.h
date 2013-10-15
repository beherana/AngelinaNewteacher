//
//  Angelina_AppDelegate.h
//  Hero Universal
//
//  Created by Henrik Nord on 11/9/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ThomasRootViewController.h"
#import "PageHandler.h"

#define kiPhoneLayerScale 0.46875

@class ThomasRootViewController;

@interface Angelina_AppDelegate : NSObject <UIApplicationDelegate, AVAudioPlayerDelegate> {
    UIWindow *window;
	
	ThomasRootViewController *myRootViewController;
	
	BOOL puzzleDifficulty;
	
	//AUDIO
	AVAudioPlayer *audioPlayer;
	AVAudioPlayer *fxPlayer;
	AVAudioPlayer *speakerPlayer;
	AVAudioPlayer *interfaceSounds;
	AVAudioPlayer *introPresentation;
	AVAudioPlayer *endSound;
	
	//SoundEffect			*erasingSound;
	//SoundEffect			*selectSound;
	//SoundEffect			*menusound;
	
	//TEMP to fix
	NSNumber *currentPaintImage;
	
	int sectionWeLeft;
	
	//Save Variables
	int saveSelectedAppSection;
	int saveLastVisitedMenuItem;
	int saveCurrentReadPage;
	BOOL saveReadNarrationSetting;
	BOOL saveReadEnlargeTextSetting;
	BOOL saveReadMusicSetting;
	int saveCurrentPaintImage;
	int saveCurrentPaintBrush;
	int saveCurrentPaintColor;
    int savePaintOpenCount;
	int saveCurrentPuzzle;
	int savePuzzleDifficulty;
	int saveCurrentDotImage;
	int saveDotDifficulty;
    int saveMatchDifficulty;
    int saveSelectedWatchMovie;
	
	BOOL introPresentationPlayed;
    BOOL voicePresentationPlayed;
	
	BOOL swipeInReadIsTurnedOff;
    
    BOOL blockSaveForSelectedWatchMovie;
	
	BOOL iPhoneMode;
    
    BOOL keepPrefs;
    
    PageHandler *_pageHandler;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

//Audio
@property (nonatomic, retain)	AVAudioPlayer					*audioPlayer;
@property (nonatomic, retain)	AVAudioPlayer					*fxPlayer;
@property (nonatomic, retain)	AVAudioPlayer					*speakerPlayer;
@property (nonatomic, retain)	AVAudioPlayer					*interfaceSounds;
@property (nonatomic, retain)	AVAudioPlayer					*introPresentation;
@property (nonatomic, retain)	AVAudioPlayer					*endSound;

@property (nonatomic,readonly) ThomasRootViewController *myRootViewController;
@property (nonatomic,readonly) PageHandler *pageHandler;

@property (nonatomic,assign) BOOL voicePresentationPlayed;

//TEMP to fix
@property (nonatomic, retain) NSNumber *currentPaintImage;
#pragma mark intro
-(void)showFakeLandingPage;
#pragma mark AUDIO
//- (void)setupAudioSession;
- (void)startFXPlayback;
- (void)stopFXPlayback;
- (void)pauseReadPlayback;
- (void)startReadPlayback;
-(void) stopReadSpeakerPlayback;
- (void) startReadSpeakerPlayback;
- (void) pauseReadSpeakerPlayback;
- (void) pauseByFXReadSpeakerPlayback;
-(void) cleanUpReadSpeaker;		
-(void)startIntroPresentation;
-(void)stopIntroPresentation;
-(void)playVoicePresentation;
-(void)playIntroThomasWhistle;
-(void)playIntroHiroWhistle;
-(void)loadReadMusic;
- (void) stopInterfaceAudio;
-(void)playEndSound;
-(void)startEndSound;
-(void)stopEndSound;
- (void)playCardSound:(int)sound;
//
- (void)playFXEventSound:(NSString *)sound;
//
#pragma mark PREFS
-(void) loadPrefs;
-(void) savePrefs;

#pragma mark getters setters
- (id)getCurrentLanguage;
-(int) getSaveSelectedAppSection;
-(void) setSaveSelectedAppSection:(int)value;

-(int) getSaveLastVisitedMenuItem;
-(void) setSaveLastVisitedMenuItem:(int)value;

-(BOOL) getSaveNarrationSetting;
-(void) setSaveNarrationSetting:(BOOL)value;
-(BOOL)getSaveReadEnlargeTextSetting;
-(void)setSaveReadEnlargeTextSetting:(BOOL)value;
-(BOOL) getSaveMusicSetting;
-(void) setSaveMusicSetting:(BOOL)value;
-(int) getSaveCurrentPaintImage;
-(void) setSaveCurrentPaintImage:(int)value;
-(int) getSaveCurrentPaintBrush;
-(void) setSaveCurrentPaintBrush:(int)value;
-(int) getSaveCurrentPaintColor;
-(void) setSaveCurrentPaintColor:(int)value;
-(int) getSavePaintOpenCount;
-(void) setSavePaintOpenCount:(int)value;
-(int) getSaveCurrentPuzzleDifficulty;
-(void) setSaveCurrentPuzzleDifficulty:(int)value;
-(int) getSaveCurrentDotImage;
-(void) setSaveCurrentDotImage:(int)value;
-(int) getSaveDotDifficulty;
-(void) setSaveDotDifficulty:(int)value;
-(int) getSaveMatchDifficulty;
-(void) setSaveMatchDifficulty:(int)value;
-(BOOL) getIntroPresentationPlayed;
-(void) setIntroPresentationPlayed:(BOOL)value;
-(BOOL)getReadViewIsPaused;
-(BOOL)getSwipeInReadIsTurnedOff;
-(void)setSwipeInReadIsTurnedOff:(BOOL)value;
-(int) getSavedSelectedWatchMovie;
-(void) setSavedSelectedWatchMovie:(int)value;
//
-(NSTimeInterval)setNarrationTime:(NSTimeInterval) time;
-(id)getNarrationTime;
-(void)setSavedDelaytime:(float)delay;
-(float)getSavedDelaytime;
//-(BOOL)getPuzzleDifficulty;
- (void) forceReadSpeakerPlayback;
#pragma mark relays
-(void)videoFinishedPlaying;
-(void)introFinishedPlaying;
-(void)unPauseReadView;

//
+(NSString*) getLocalizedAssetName:(NSString*)assetname;

-(ThomasRootViewController *)currentRootViewController;

+(Angelina_AppDelegate *)get;


@end

