//
//  Angelina_AppDelegate.m
//  Hero Universal
//
//  Created by Henrik Nord on 11/9/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import "Angelina_AppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>
#import "cdaAnalytics.h"
#import "cdaAnalyticsFlurryTracker.h"
#import "cdaAnalyticsGoogleTracker.h"
#import "AVQueueManager.h"
#import "UAPush.h"
#import "UAirship.h"
#import "CDAudioManager.h"

//Save data
#define kSelectedAppSection @"kSelectedAppSection"
#define kLastVisitedMenuItem @"kLastVisitedMenuItem"
#define kCurrentReadPage @"kCurrentReadPage"
#define kReadNarrationSetting @"kReadNarrationSetting"
#define kReadEnlargeTextSetting @"kReadEnlargeTextSetting"
#define kReadMusicSetting @"kReadMusicSetting"
#define kCurrentPaintImage @"kCurrentPaintImage"
#define kCurrentBrushSize @"kCurrentBrushSize"
#define kCurrentPaintColor @"kCurrentPaintColor"
#define kPaintOpenCount @"kPaintOpenCount"
#define kCurrentPuzzle @"kCurrentPuzzle"
#define kPuzzleDifficulty @"kPuzzleDifficulty"
#define kCurrentDotImage @"kCurrentDotImage"
#define kDotDifficulty @"kDotDifficulty"
#define kMatchDifficulty @"kMatchDifficulty"
#define kRunningNarrationTime @"kRunningNarrationTime"
#define kOldSavedDate @"kOldSavedDate"
#define kNarrationDelayTime @"kNarrationDelayTime"
#define kIntroPresentationPlayed @"kIntroPresentationPlayed"
#define kSwipeInReadIsTurnedOff @"kSwipeInReadIsTurnedOff"
#define kSelectedWatchMovie @"kSelectedWatchMovie"

@interface Angelina_AppDelegate (PrivateMethods)
//INITS
-(void) setupRootViewController;
//langcheck
- (bool)isLanguage:(NSString*)checkLanguage;
- (bool)isRegion:(NSString*)checkRegion;
@end


@implementation Angelina_AppDelegate

@synthesize window;
@synthesize audioPlayer, fxPlayer, speakerPlayer, interfaceSounds, introPresentation, endSound;
@synthesize currentPaintImage; //TEMP to fix
@synthesize myRootViewController;
@synthesize pageHandler = _pageHandler;
@synthesize voicePresentationPlayed;


#pragma mark -
#pragma mark Application lifecycle
+ (void) initialize {	
	if ([self class] == [Angelina_AppDelegate class]) {
		//prefs
        NSString *appsection = [NSString stringWithFormat:@"%d", NAV_MAIN];

		//if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) appsection = @"3";
		NSString *lastvisited = @"2";
		NSString *readpage = @"0";
		NSString *narration = @"YES";
		NSNumber *enlarge=[NSNumber numberWithBool:YES];
		NSString *music = @"YES";
		NSString *paintimage = @"1";
		NSString *paintbrush = @"3";
		NSString *paintcolor = @"6";
        NSString *paintopencount = @"0";
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) paintcolor = @"10";
		NSString *puzzle = @"1";
		NSString *puzzledifficulty = @"0";
		NSString *dotimage = @"1";
		NSString *dotdifficulty = @"0";
		NSString *narrationtime = [NSString stringWithFormat:@"0"];
		NSString *narrationdelay = @"0";
		NSDate *now = [NSDate date];
		NSString *intropresentation = @"NO";
		NSString *swipeturnedoff = @"NO";
        NSString *matchdifficulty = @"0";
        NSString *selectWatchMovie = @"0";
		
		
		NSDictionary *defaults =  [NSDictionary dictionaryWithObjectsAndKeys:
                                   appsection, kSelectedAppSection,
                                   readpage, kCurrentReadPage,
                                   enlarge,kReadEnlargeTextSetting,
                                   narration, kReadNarrationSetting,
								   music, kReadMusicSetting,
                                   paintimage, kCurrentPaintImage,
                                   paintbrush, kCurrentBrushSize,
                                   paintcolor, kCurrentPaintColor,
                                   paintopencount, kPaintOpenCount,
                                   puzzle, kCurrentPuzzle,
								   puzzledifficulty, kPuzzleDifficulty,
                                   dotimage, kCurrentDotImage,
                                   dotdifficulty, kDotDifficulty,
                                   narrationtime, kRunningNarrationTime,
                                   now, kOldSavedDate,
								   narrationdelay, kNarrationDelayTime,
                                   intropresentation, kIntroPresentationPlayed,
                                   swipeturnedoff, kSwipeInReadIsTurnedOff,
                                   lastvisited, kLastVisitedMenuItem,
                                   matchdifficulty, kMatchDifficulty,
                                   selectWatchMovie, kSelectedWatchMovie,
                                   nil];
        
		[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
		
	}
}

//Flurry Error handling
void uncaughtExceptionHandler(NSException *exception) {
    NSString *msg=[NSString stringWithFormat:@"Crash Stack: %@", [NSThread callStackSymbols]];
    [[cdaAnalytics sharedInstance] logError:@"Uncaught" withMessage:msg andException:exception];
} 


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    

    //Init Airship launch options
#if (!TARGET_IPHONE_SIMULATOR)
    NSMutableDictionary *takeOffOptions = [[[NSMutableDictionary alloc] init] autorelease];
    [takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
#endif
    
    NSMutableDictionary *airshipConfigOptions = [[[NSMutableDictionary alloc] init] autorelease];
    [airshipConfigOptions setValue:@"mDCR277ZRTGihbxMoeCWJA" forKey:@"DEVELOPMENT_APP_KEY"];
    [airshipConfigOptions setValue:@"AoSgq1DCT0aWZcTg8xNP7Q" forKey:@"DEVELOPMENT_APP_SECRET"];
    
    [airshipConfigOptions setValue:@"cVOM_DeQRSuGoPQCBL9jjw" forKey:@"PRODUCTION_APP_KEY"];
    [airshipConfigOptions setValue:@"Kpwp4vDHR46dqxS2l_Gu9Q" forKey:@"PRODUCTION_APP_SECRET"];
    
    
#ifdef DEBUG
    [airshipConfigOptions setValue:@"NO" forKey:@"APP_STORE_OR_AD_HOC_BUILD"];
#else
    [airshipConfigOptions setValue:@"YES" forKey:@"APP_STORE_OR_AD_HOC_BUILD"];
#endif
    
#if (!TARGET_IPHONE_SIMULATOR)    
    [takeOffOptions setValue:airshipConfigOptions forKey:UAirshipTakeOffOptionsAirshipConfigKey];
    
    
    // Create Airship singleton that's used to talk to Urban Airship servers.
    // Please populate AirshipConfig.plist with your info from http://go.urbanairship.com
    [UAirship takeOff:takeOffOptions];
    
    [[UAPush shared] resetBadge];//zero badge on startup
    
    [[UAPush shared] registerForRemoteNotificationTypes: (UIRemoteNotificationType)
     (UIRemoteNotificationTypeBadge |
      UIRemoteNotificationTypeSound |
      UIRemoteNotificationTypeAlert)];
    
#endif
    
     cdaAnalyticsFlurryTracker* flurryTracker = nil;
    
	//ANALYTICS
	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		iPhoneMode = YES;
        
#if defined DEBUG || defined ENTERPRISE
        //Flurry key for iPhone test
        flurryTracker = [[[cdaAnalyticsFlurryTracker alloc] initWithAPIKey:@"KQHE5F3FF7ADF47D8JFX"] autorelease];
#else
		//Flurry key for iPhone
        flurryTracker = [[[cdaAnalyticsFlurryTracker alloc] initWithAPIKey:@"CXV7GB15DW3HPR48N8TD"] autorelease];
#endif
        
	} else {
		iPhoneMode = NO;
        
#if defined DEBUG || defined ENTERPRISE
        //Flurry key for iPad test
        flurryTracker = [[[cdaAnalyticsFlurryTracker alloc] initWithAPIKey:@"3B5M65J34NDQMPAKEM94"] autorelease];
#else
		//Flurry key for iPad
        flurryTracker = [[[cdaAnalyticsFlurryTracker alloc] initWithAPIKey:@"BQC7KJUYBG5MT53HU1GA"] autorelease];
#endif
	}
   
    
#if defined DEBUG || defined ENTERPRISE
    //Google Test key
    cdaAnalyticsGoogleTracker* gaTracker = [[[cdaAnalyticsGoogleTracker alloc] initWithAPIKey:@"UA-30636856-1"] autorelease];
#else
    //Google Live key
    cdaAnalyticsGoogleTracker* gaTracker = [[[cdaAnalyticsGoogleTracker alloc] initWithAPIKey:@"UA-30634844-1"] autorelease];
#endif
    
    [[cdaAnalytics sharedInstance] registerProvider:flurryTracker];
    [[cdaAnalytics sharedInstance] registerProvider:gaTracker];
    
    
    
    
    //configure audio session
    [[CDAudioManager sharedManager] setMode:kAMM_FxPlusMusic];
	
    [self loadPrefs];
	
    _pageHandler = [[PageHandler alloc] init];
    // default to first page if nothing stored in prefs
    _pageHandler.currentPage = saveCurrentReadPage > 0 ? saveCurrentReadPage : 1;
    
    // PageHandler notifications
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(currentPageDidChange:)
     name:kCurrentPageDidChange
     object:nil];
    
	//[self setupAudioSession];
    
    //make sure we always start in movie select menu when the app is restarted
    [self setSavedSelectedWatchMovie:0];
	
	[self setupRootViewController];
	
    [self.window makeKeyAndVisible];
	
    return YES;
}

- (void)currentPageDidChange:(NSNotification *)notification
{
    saveCurrentReadPage = [[[notification userInfo] objectForKey:@"currentPage"] intValue];
    [self savePrefs];
}

-(void)loadPrefs {
	//Restore prefs
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	saveSelectedAppSection = [standardUserDefaults integerForKey:kSelectedAppSection];
	saveLastVisitedMenuItem = [standardUserDefaults integerForKey:kLastVisitedMenuItem];
	saveCurrentReadPage = [standardUserDefaults integerForKey:kCurrentReadPage];
	saveReadNarrationSetting = [standardUserDefaults boolForKey:kReadNarrationSetting];
	saveReadEnlargeTextSetting = [standardUserDefaults boolForKey:kReadEnlargeTextSetting];
	saveReadMusicSetting = [standardUserDefaults boolForKey:kReadMusicSetting];
	saveCurrentPaintImage = [standardUserDefaults integerForKey:kCurrentPaintImage];
	saveCurrentPaintBrush = [standardUserDefaults integerForKey:kCurrentBrushSize];
	saveCurrentPaintColor = [standardUserDefaults integerForKey:kCurrentPaintColor];
    savePaintOpenCount = [standardUserDefaults integerForKey:kPaintOpenCount];
	saveCurrentPuzzle = [standardUserDefaults integerForKey:kCurrentPuzzle];
	savePuzzleDifficulty = [standardUserDefaults integerForKey:kPuzzleDifficulty];
	saveCurrentDotImage = [standardUserDefaults integerForKey:kCurrentDotImage];
	saveDotDifficulty = [standardUserDefaults integerForKey:kDotDifficulty];
    saveMatchDifficulty = [standardUserDefaults integerForKey:kMatchDifficulty];
	introPresentationPlayed = [standardUserDefaults boolForKey:kIntroPresentationPlayed];
	swipeInReadIsTurnedOff = [standardUserDefaults boolForKey:kSwipeInReadIsTurnedOff];
    saveSelectedWatchMovie = [standardUserDefaults integerForKey:kSelectedWatchMovie];
    
    //if we are not coming from the background or runnging the app for the first time
    if (keepPrefs != YES) {
        //reset app preferences
        saveSelectedAppSection = NAV_MAIN;
        saveLastVisitedMenuItem = NAV_MAIN;
        
        saveCurrentReadPage = 1;
    }
}
-(void)savePrefs {
	//save prefs
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	[standardUserDefaults setInteger:saveSelectedAppSection forKey:kSelectedAppSection];
	[standardUserDefaults setInteger:saveLastVisitedMenuItem forKey:kLastVisitedMenuItem];
	[standardUserDefaults setInteger:saveCurrentReadPage forKey:kCurrentReadPage];
	[standardUserDefaults setBool:saveReadNarrationSetting forKey:kReadNarrationSetting];
	[standardUserDefaults setBool:saveReadEnlargeTextSetting forKey:kReadEnlargeTextSetting];
	[standardUserDefaults setBool:saveReadMusicSetting forKey:kReadMusicSetting];
	[standardUserDefaults setInteger:saveCurrentPaintImage forKey:kCurrentPaintImage];
	[standardUserDefaults setInteger:saveCurrentPaintBrush forKey:kCurrentBrushSize];
	[standardUserDefaults setInteger:saveCurrentPaintColor forKey:kCurrentPaintColor];
	[standardUserDefaults setInteger:savePaintOpenCount forKey:kPaintOpenCount];    
	[standardUserDefaults setInteger:saveCurrentPuzzle forKey:kCurrentPuzzle];
	[standardUserDefaults setInteger:savePuzzleDifficulty forKey:kPuzzleDifficulty];
	[standardUserDefaults setInteger:saveCurrentDotImage forKey:kCurrentDotImage];
	[standardUserDefaults setInteger:saveDotDifficulty forKey:kDotDifficulty];
    [standardUserDefaults setInteger:saveMatchDifficulty forKey:kMatchDifficulty];
	[standardUserDefaults setBool:introPresentationPlayed forKey:kIntroPresentationPlayed];
	[standardUserDefaults setBool:swipeInReadIsTurnedOff forKey:kSwipeInReadIsTurnedOff];
    [standardUserDefaults setInteger:saveSelectedWatchMovie forKey:kSelectedWatchMovie];
}

#pragma mark -
#pragma mark Project inits
-(void) setupRootViewController {
	//add root view controller
	myRootViewController = [[ThomasRootViewController alloc] initWithNibName:@"ThomasRootViewController" bundle:nil];
	[window addSubview:myRootViewController.view];
}
#pragma mark -
#pragma mark Getters and Setters
- (id)getCurrentLanguage {
	//NSLog(@"ASKING ABOUT LANGUAGE");
	NSLocale *currentUsersLocale = [NSLocale currentLocale];
	NSString *currentlanguage = [NSString stringWithFormat:@"%@", [currentUsersLocale localeIdentifier]];
	NSLog(@"This is the current language: %@", currentlanguage);
	if ([currentlanguage isEqualToString:@"haw_US"]) {
		NSLog(@"This is hawaiian");
		return currentlanguage;
	} else if ([currentlanguage isEqualToString:@"en_US"]) {
		//NSLog(@"I am in US");
		return currentlanguage;
	} else {
		//here we check for exceptions right?
		if ([self isLanguage:@"en"] && ([self isRegion:@"VI"] || [self isRegion:@"CA"] || [self isRegion:@"PH"])) {
			NSLog(@"The exception language's");
			currentlanguage = @"en_US";
			return currentlanguage;
		} else {
			NSLog(@"I am in the rest of the world"); // <-- If not in the exception list this app is going for UK English
			currentlanguage = @"en_GB";
			return currentlanguage;
		}
	}

}
#pragma mark -
#pragma mark LANGUAGE - Regional Override
- (bool)isLanguage:(NSString*)checkLanguage
{
    // Lookup app languages
    NSBundle* appBundle = [NSBundle mainBundle];
    NSArray*  appLanguages = [appBundle preferredLocalizations];
    if( [appLanguages count] > 0 )
    {
        NSString* appLang = [appLanguages objectAtIndex:0];
        // Convert both strings to lower case ready for compare
        NSString* lowercaseAppLang   = [appLang lowercaseString];
        NSString* lowercaseCheckLang = [checkLanguage lowercaseString];
		
        if( [lowercaseAppLang hasPrefix:lowercaseCheckLang ] )
        {
            return TRUE;
        }
    }
	
    // No match
	return FALSE;
}

- (bool)isRegion:(NSString*)checkRegion
{
    // Lookup current locale
    NSLocale* appLocale   = [NSLocale currentLocale];
    NSString* appLocaleId = [appLocale localeIdentifier];
	
    // Convert both strings to lower case ready for compare
    NSString* lowercaseAppLocale   = [appLocaleId lowercaseString];
    NSString* lowercaseCheckRegion = [checkRegion lowercaseString];
	
    // Matching region?
    if( [lowercaseAppLocale hasSuffix:lowercaseCheckRegion ] )
    {
        return TRUE;
    }
	
    // No match
	return FALSE;
}
#pragma mark -
#pragma mark GETTERS and SETTERS
-(int) getSaveSelectedAppSection {
	return saveSelectedAppSection;
}
-(void) setSaveSelectedAppSection:(int)value {
	NSLog(@"Saving with value: %i", value);
	saveSelectedAppSection = value;
	[self savePrefs];
}

-(int) getSaveLastVisitedMenuItem {
	return saveLastVisitedMenuItem;
}
-(void) setSaveLastVisitedMenuItem:(int)value {
	saveLastVisitedMenuItem = value;
	[self savePrefs];
}

-(BOOL)getSaveReadEnlargeTextSetting{
	return saveReadEnlargeTextSetting;
}


-(void)setSaveReadEnlargeTextSetting:(BOOL)value{
	saveReadEnlargeTextSetting=value;
	[self savePrefs];
}
-(BOOL) getSaveNarrationSetting {
	return saveReadNarrationSetting;
}
-(void) setSaveNarrationSetting:(BOOL)value {
	saveReadNarrationSetting = value;
	[self savePrefs];
}
-(BOOL) getSaveMusicSetting {
	return saveReadMusicSetting;
}
-(void) setSaveMusicSetting:(BOOL)value {
	saveReadMusicSetting = value;
	[self savePrefs];
	//play music
	if (value) {
		[self startReadPlayback];
	} else {
		[self pauseReadPlayback];
	}
}
-(int) getSaveCurrentPaintImage {
	return saveCurrentPaintImage;
}
-(void) setSaveCurrentPaintImage:(int)value {
	saveCurrentPaintImage = value;
	[self savePrefs];
}
-(int) getSaveCurrentPaintBrush {
	return saveCurrentPaintBrush;
}
-(void) setSaveCurrentPaintBrush:(int)value {
	saveCurrentPaintBrush = value;
	[self savePrefs];
}
-(int) getSaveCurrentPaintColor {
	return saveCurrentPaintColor;
}
-(void) setSaveCurrentPaintColor:(int)value {
	saveCurrentPaintColor = value;
	[self savePrefs];
}
-(int) getSavePaintOpenCount {
    return savePaintOpenCount;
}
-(void) setSavePaintOpenCount:(int)value {
    savePaintOpenCount = value;
    [self savePrefs];
}
-(int) getSaveCurrentPuzzle {
    // In Angelina, all pages are synced
	return saveCurrentPuzzle;
    //return [self getSaveCurrentReadPage];
}
-(void) setSaveCurrentPuzzle:(int)value {
    // In Angelina, all pages are synced
	//saveCurrentPuzzle = value;
	//[self savePrefs];
    //[self setSaveCurrentReadPage:value];
}
-(int) getSaveCurrentPuzzleDifficulty {
	return savePuzzleDifficulty;
}
-(void) setSaveCurrentPuzzleDifficulty:(int)value {
	savePuzzleDifficulty = value;
	[self savePrefs];
}
-(int) getSaveCurrentDotImage {
	return saveCurrentDotImage;
}
-(void) setSaveCurrentDotImage:(int)value {
	saveCurrentDotImage = value;
	[self savePrefs];
}
-(int) getSaveDotDifficulty {
	return saveDotDifficulty;
}
-(void) setSaveDotDifficulty:(int)value {
	saveDotDifficulty = value;
	[self savePrefs];
}
-(int) getSaveMatchDifficulty {
	return saveMatchDifficulty;
}
-(void) setSaveMatchDifficulty:(int)value {
	saveMatchDifficulty = value;
	[self savePrefs];
}
-(BOOL) getIntroPresentationPlayed {
	return introPresentationPlayed;
}
-(void) setIntroPresentationPlayed:(BOOL)value {
	introPresentationPlayed = value;
	[self savePrefs];
}
-(NSTimeInterval)setNarrationTime:(NSTimeInterval) time {
	
	NSTimeInterval runningNarrationTime = time;
	
	//Save to prefs
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	[standardUserDefaults setInteger:runningNarrationTime forKey:kRunningNarrationTime];
	NSDate *now = [NSDate date];
	[standardUserDefaults setValue:now forKey:kOldSavedDate];
	
	return runningNarrationTime;
}
-(id)getNarrationTime {
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	NSDate *old = [standardUserDefaults valueForKey:kOldSavedDate];
	return old;
}

-(void)setSavedDelaytime:(float)delay {
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	[standardUserDefaults setFloat:delay forKey:kNarrationDelayTime];
}
-(float)getSavedDelaytime {
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	float thetime = [standardUserDefaults floatForKey:kNarrationDelayTime];
	return thetime;
}

-(BOOL)getReadViewIsPaused {
	return [[self currentRootViewController] getReadViewIsPaused];
}
-(BOOL)getSwipeInReadIsTurnedOff {
	return swipeInReadIsTurnedOff;
}
-(void)setSwipeInReadIsTurnedOff:(BOOL)value {
	swipeInReadIsTurnedOff = value;
	[self savePrefs];
}
-(int) getSavedSelectedWatchMovie {
    return saveSelectedWatchMovie;
}
-(void) setSavedSelectedWatchMovie:(int)value {
    if (blockSaveForSelectedWatchMovie) return;
    saveSelectedWatchMovie = value;
    [self savePrefs];
}
/*
-(BOOL)getPuzzleDifficulty {
	return puzzleDifficulty;
}
 */

#pragma mark -
#pragma mark AudioSession methods

- (void)pauseReadPlayback
{
	//useBkgMusic = NO;
	[self.audioPlayer pause];
	//NSLog(@"Background music in Read was paused");
}

- (void)startReadPlayback
{
	//useBkgMusic = YES;
	//NSLog(@"Background music in Read was started");
	if ([self.audioPlayer play])
	{
		self.audioPlayer.delegate = self;
	}
	else
		NSLog(@"Could not play %@\n", self.audioPlayer.url);
}
- (void)startFXPlayback
{
	//NSLog(@"Read FX-sound was started");
	if ([self.fxPlayer play])
	{
		self.fxPlayer.delegate = self;
	}
	else
		NSLog(@"Could not play %@\n", self.fxPlayer.url);
}
- (void)stopFXPlayback
{
	//NSLog(@"Got a stop playing for the fx - and then a crash?");
	if (self.fxPlayer != nil && self.fxPlayer.playing) {
		[self.fxPlayer stop];
		//NSLog(@"FX-sound Read was paused");
	}
}
- (void) startReadSpeakerPlayback {
	if ([[self currentRootViewController] getCurrentNavigationItem] != 3) return;
	//NSLog(@"Read speaker was started");
	if (saveReadNarrationSetting) {
		if ([self.speakerPlayer play])
		{
			self.speakerPlayer.delegate = self;
		}
		else {
			NSLog(@"Could not play %@\n", self.speakerPlayer.url);
		}
	}
}

- (void) forceReadSpeakerPlayback {
	if ([[self currentRootViewController] getCurrentNavigationItem] != 3) return;
	//NSLog(@"Read speaker was started");
		if ([self.speakerPlayer play])
		{
			self.speakerPlayer.delegate = self;
		}
		else {
			NSLog(@"Could not play %@\n", self.speakerPlayer.url);
		}
}
- (void) pauseReadSpeakerPlayback {
	//NSLog(@"Read speaker was Paused");
	//if (saveReadNarrationSetting) {
	[[self currentRootViewController] pauseNarrationOnScene];
	//[myRootViewController narrationFinished];
	//}
}
- (void) pauseByFXReadSpeakerPlayback {
	//NSLog(@"Read speaker was Paused");
	//if (saveReadNarrationSetting) {
	[[self currentRootViewController] pauseNarrationOnScene];
	[[self currentRootViewController] narrationFinished];
	//}
}
-(void) stopReadSpeakerPlayback {
	//NSLog(@"Read speaker was Stopped");
	if (self.speakerPlayer != nil && self.speakerPlayer.playing) {
		[[self currentRootViewController] pauseNarrationOnScene];
		[[self currentRootViewController] narrationFinished];
	}
	//NSLog(@"Speaker in Read was paused");
}
-(void) cleanUpReadSpeaker {
	//[speakerPlayer release];
	[self.speakerPlayer stop];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    self.voicePresentationPlayed = YES;
	//NSLog(@"So audio got a didfinish playing here");
	if (player == self.audioPlayer) {
		if (flag == NO)
			//NSLog(@"Playback finished unsuccessfully");
			[player setCurrentTime:0.];
		[self startReadPlayback];
	} else if (player == self.speakerPlayer) {
		[[self currentRootViewController] narrationFinished];
	}
}
- (void) startInterfaceAudio {
	//NSLog(@"Interface audio was started");
	if ([self.interfaceSounds play])
	{
		self.interfaceSounds.delegate = self;
	}
	else
		NSLog(@"Could not play %@\n", self.interfaceSounds.url);
}
- (void) stopInterfaceAudio {
	if (self.interfaceSounds != nil && self.interfaceSounds.playing) {
		[self.interfaceSounds stop];
	}
	NSLog(@"interfaceSounds was paused");
}
- (void) startIntroPresentation {
	//NSLog(@"introPresentation audio was started");
	if ([self.introPresentation play])
	{
		self.introPresentation.delegate = self;
	}
	else
		NSLog(@"Could not play %@\n", self.introPresentation.url);
}
- (void) stopIntroPresentation {
	if (self.introPresentation != nil && self.introPresentation.playing) {
		[self.introPresentation stop];
        self.voicePresentationPlayed = YES;
	}
	NSLog(@"introPresentation was stopped");
}
- (void) startEndSound {
	//NSLog(@"endsound audio was started");
	if ([self.endSound play])
	{
		self.endSound.delegate = self;
	}
	else
		NSLog(@"Could not play %@\n", self.endSound.url);
}
- (void) stopEndSound {
	if (self.endSound != nil && self.endSound.playing) {
		[self.endSound stop];
	}
	NSLog(@"endsound was stopped");
}
#pragma mark soundfx
- (void)playFXEventSound:(NSString *)sound {
	if (self.interfaceSounds.playing) [self stopInterfaceAudio];
	
	NSURL *fileURL;
	if ([sound isEqualToString:@"Select"]) {
		//Play sound
		//[selectSound play];
		NSString *mypath = [NSString stringWithFormat:@"select"];
		fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:mypath ofType:@"m4a"]];
	} else if ([sound isEqualToString:@"Menu"]) {
		//play sound
		//[menusound play];
		NSString *mypath = [NSString stringWithFormat:@"menu"];
		fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:mypath ofType:@"m4a"]];
	} else if ([sound isEqualToString:@"mainmenu"]) {
		//play sound
		//[menusound play];
		NSString *mypath = [NSString stringWithFormat:@"menu_bar"];
		fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:mypath ofType:@"m4a"]];
	} else if ([sound isEqualToString:@"endsound"]) {
		//play sound
		//[menusound play];
		NSString *mypath = [NSString stringWithFormat:@"end_sound"];
		fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:mypath ofType:@"m4a"]];
	} else if ([sound isEqualToString:@"match"]) {
		//play sound
		NSString *mypath = [NSString stringWithFormat:@"matchthomas"];
		fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:mypath ofType:@"m4a"]];
	} else if ([sound isEqualToString:@"matchpayoff"]) {
		//play sound
		NSString *langadd = @"";
		if ([[self getCurrentLanguage] isEqualToString:@"en_GB"]) {
			langadd = @"_UK";
		}
		NSString *mypath = [NSString stringWithFormat:@"matchpayoffsound%@", langadd];
		fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:mypath ofType:@"m4a"]];
	} else {
		//Play sound
		//[erasingSound play];
		NSString *mypath = [NSString stringWithFormat:@"erase"];
		fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:mypath ofType:@"m4a"]];
	}

	AVAudioPlayer *thePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
	[fileURL release];
	if (thePlayer) {
		self.interfaceSounds = thePlayer;
		[thePlayer release];
		self.interfaceSounds.volume = 1.0;
		[self startInterfaceAudio];
	}
}
- (void)playCardSound:(int)sound {
	if (self.interfaceSounds.playing) [self stopInterfaceAudio];
	NSString *langadd = @"";
	//if (sound-1 == 4 || sound-1 == 1 || sound-1 == 0) { //All Sounds are UK in HERO
		if ([[self getCurrentLanguage] isEqualToString:@"en_GB"]) {
			langadd = @"_UK";
		}
	//}
	NSString *mypath = [NSString stringWithFormat:@"cardsound%i" "%@", sound-1, langadd];
	NSLog(@"this is the uk-path for cardsound: %@", mypath);
	NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:mypath ofType:@"m4a"]];
	AVAudioPlayer *thePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
	[fileURL release];
	if (thePlayer) {
		self.interfaceSounds = thePlayer;
		[thePlayer release];
		self.interfaceSounds.volume = 1.0;
		[self startInterfaceAudio];
	}
}
#pragma mark introPresentation
-(void)playVoicePresentation {
    if (self.voicePresentationPlayed == YES) {
        return;
    }
    
	NSString *mypath = [NSString stringWithFormat:@"intro_presentation"];
	NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:mypath ofType:@"m4a"]];
	AVAudioPlayer *thePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
	[fileURL release];
	if (thePlayer) {
		self.introPresentation = thePlayer;
		[thePlayer release];
		self.introPresentation.volume = 1.0;
		[self startIntroPresentation];
	}
}

-(void)playIntroThomasWhistle {
	NSString *mypath = [NSString stringWithFormat:@"intro_thomas_whistle"];
	NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:mypath ofType:@"m4a"]];
	AVAudioPlayer *thePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
	[fileURL release];
	if (thePlayer) {
		self.introPresentation = thePlayer;
		[thePlayer release];
		self.introPresentation.volume = 1.0;
		[self startIntroPresentation];
	}
}

-(void)playIntroHiroWhistle {
	NSString *mypath = [NSString stringWithFormat:@"intro_hiro_whistle"];
	NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:mypath ofType:@"m4a"]];
	AVAudioPlayer *thePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
	[fileURL release];
	if (thePlayer) {
		self.introPresentation = thePlayer;
		[thePlayer release];
		self.introPresentation.volume = 1.0;
		[self startIntroPresentation];
	}
}

#pragma mark music in read 
-(void)loadReadMusic {
	NSString *mypath = [NSString stringWithFormat:@"read_music"];
	NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:mypath ofType:@"m4a"]];
	AVAudioPlayer *thePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
	[fileURL release];
	if (thePlayer) {
		self.audioPlayer = thePlayer;
		[thePlayer release];
		self.audioPlayer.volume = 1.0;
		[self startReadPlayback];
	}
}
#pragma mark endsound
-(void)playEndSound {
	NSString *mypath = [NSString stringWithFormat:@"end_sound"];
	NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:mypath ofType:@"m4a"]];
	AVAudioPlayer *thePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
	[fileURL release];
	if (thePlayer) {
		self.endSound = thePlayer;
		[thePlayer release];
		self.endSound.volume = 1.0;
		[self startEndSound];
	}
}
-(void)unloadReadMusic {
	//if (player == self.audioPlayer) {
	if (self.audioPlayer != nil && self.audioPlayer.playing) {
		[self.audioPlayer stop];
		[self.audioPlayer release];
	}
}
#pragma mark -
#pragma mark RootViewController Relays
-(void)videoFinishedPlaying {
	[[self currentRootViewController] videoFinishedPlaying];
}
-(void)introFinishedPlaying {
	[[self currentRootViewController] introFinishedPlaying];
}
-(void)showFakeLandingPage {
	[[self currentRootViewController] showFakeLandingPage];
}
-(void)unPauseReadView {
	[[self currentRootViewController] unPauseReadView];
}
#pragma mark -
#pragma mark application related
- (void)applicationWillResignActive:(UIApplication *)application {
	//NSLog(@"applicationWillResignActive");
	/*
	[[self currentRootViewController] unloadCurrentNavigationItem];
	
	[[self currentRootViewController] removePendingSceneDelay];	
	
	if ([[self currentRootViewController] getCurrentNavigationItem] == 3) {
		[self stopReadSpeakerPlayback];
		[[self currentRootViewController] pauseCocos];
	}
	 
	[[self currentRootViewController] setSpeakerIsPaused:NO];
	[[self currentRootViewController] setSpeakerIsDelayed:NO];*/
	//sectionWeLeft = [[self currentRootViewController] getCurrentNavigationItem];
	if ([[self currentRootViewController] getCurrentNavigationItem] == NAV_READ) {
		[self stopReadSpeakerPlayback];
		[[self currentRootViewController] pauseCocos];
        [[self currentRootViewController] removePopoverImage];
	}
    
    keepPrefs = YES;

	[self savePrefs];
	//[[self currentRootViewController] navigateFromMainMenuWithItem:0];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	//NSLog(@"applicationDidBecomeActive - within the current section: %i", [[self currentRootViewController] getCurrentNavigationItem]);
	/*
	if ([[self currentRootViewController] getCurrentNavigationItem]==3) {
		[[self currentRootViewController] resumeCocos];
	}
	[[self currentRootViewController] setSpeakerIsPaused:NO];
	[[self currentRootViewController] setSpeakerIsDelayed:NO];
	*/
	/*
	if (saveReadMusicSetting && [[self currentRootViewController] getCurrentNavigationItem]==3) {
		[self startReadPlayback];
	}
	 */
	if ([[self currentRootViewController] getCurrentNavigationItem]==3) {
		[[self currentRootViewController] resumeCocos];
	}
	[self loadPrefs];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	//NSLog(@"applicationWillTerminate");
	
	if ([[self currentRootViewController] getCurrentNavigationItem]==3) {
		[[self currentRootViewController] killCocos];
	}
    
	/*
	[[self currentRootViewController] setSpeakerIsPaused:NO];
	[[self currentRootViewController] setSpeakerIsDelayed:NO];
	*/
	[self savePrefs];
    
    [UAirship land];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	//NSLog(@"applicationDidEnterBackground");
	
	if ([[self currentRootViewController] getCurrentNavigationItem]==NAV_READ) {
		[self stopReadSpeakerPlayback];
		[[self currentRootViewController] stopCocos];
        [[self currentRootViewController] removePopoverImage];
	} else if ([[self currentRootViewController] getCurrentNavigationItem]==NAV_WATCH) {
        blockSaveForSelectedWatchMovie = YES;
    }
	/*
	[[self currentRootViewController] setSpeakerIsPaused:NO];
	[[self currentRootViewController] setSpeakerIsDelayed:NO];
	[[self currentRootViewController] narrationFinished];
	*/
    
    keepPrefs = YES;

	[self savePrefs];
	[[self currentRootViewController] navigateFromMainMenuWithItem:0];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	//NSLog(@"applicationWillEnterForeground - within the current section: %i", [[self currentRootViewController] getCurrentNavigationItem]);
	/*
	[[self currentRootViewController] navigateFromMainMenuWithItem:saveSelectedAppSection];
	
	
	if ([[self currentRootViewController] getCurrentNavigationItem]==3) {
		[[self currentRootViewController] startCocos];
	}
	
	[[self currentRootViewController] setSpeakerIsPaused:NO];
	[[self currentRootViewController] setSpeakerIsDelayed:NO];
	 */
	//NSString *lang = [self getCurrentLanguage];
	//NSLog(@"getting language on enter: %@", lang);
	[self loadPrefs];
    blockSaveForSelectedWatchMovie = NO;
	[[self currentRootViewController] navigateFromMainMenuWithItem:saveSelectedAppSection];
    
    // Activate page resume in read
    myRootViewController.resumePage = YES;
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	//NSLog(@"applicationSignificantTimeChange");
	/*
	if ([[self currentRootViewController] getCurrentNavigationItem]==3) {
		[[self currentRootViewController] resetCocos];
	}
	 */
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Updates the device token and registers the token with UA
#if (!TARGET_IPHONE_SIMULATOR)
    [[UAirship shared] registerDeviceToken:deviceToken];
#endif
    
    //We can collect the device tokens here:
    
    //TODO: Extra options:
    /*
     - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
     UALOG(@"APN device token: %@", deviceToken);
     
     // Create a few tags
     NSMutableArray *tags = [NSMutableArray arrayWithObjects:@"Tag1", @"Tag2", @"Tag3", nil];
     NSDictionary *info = [[NSMutableDictionary alloc] initWithObjectsAndKeys:tags, @"tags", nil];
     
     // Updates the device token and registers the token with UA
     [[UAirship shared] registerDeviceToken:deviceToken withExtraInfo:info];
     }
     */
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
    [[self currentRootViewController] sceneCleanup];
}


- (void)dealloc {
    [window release];
	//audio
	[audioPlayer release];
	[fxPlayer release];
	[speakerPlayer release];
	[interfaceSounds release];
	[endSound release];
	//TEMP to fix
	[currentPaintImage release];
	[myRootViewController release];
	//
    [super dealloc];
}

#pragma mark universal getters
+(NSString *) getLocalizedAssetName:(NSString*)assetname {
    //if in UK-area add _UK to soundfiles that have the _lang tag
    NSString *langadd = @"";
    Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
    if ([[appDelegate getCurrentLanguage] isEqualToString:@"en_GB"]) {
        langadd = @"_UK";
    }
    NSString *strippedname = [assetname stringByDeletingPathExtension];
    NSString *localizedname = [strippedname stringByAppendingString:langadd];
    NSString *assetextension = [assetname pathExtension];
    NSString *fixedname = [localizedname stringByAppendingPathExtension:assetextension];
    
    if([langadd isEqualToString:@"_UK"])
    {
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fixedname];
        if(!fileExists){
            fixedname = [fixedname stringByReplacingCharactersInRange:[fixedname rangeOfString:@"_UK" options:NSBackwardsSearch] withString:@""];
            NSLog(@"File not found, fallback to non UK path");
        }
    }
    NSLog(@"This is the fixed path being returned: %@", fixedname);
    return fixedname;
}

-(ThomasRootViewController *)currentRootViewController{
	return myRootViewController;
}

+(Angelina_AppDelegate *)get{
	return (Angelina_AppDelegate *)[[UIApplication sharedApplication]delegate];
}
@end
