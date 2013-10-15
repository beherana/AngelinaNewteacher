//
//  AppDelegate.m
//  AngelinaGame
//
//  Created by Karl Söderström on 2011-06-27.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "GameConfig.h"
#import "AngelinaScene.h"
#import "BubblePopRootViewController.h"
#import "TitleScene.h"
#import "AudioHelper.h"
#import "BubblePopIntroViewController.h"
#import "GameState.h"
#import "UAirship.h"
#import "UAPush.h"
#import "FlurryAnalytics.h"


@implementation AppDelegate

@synthesize window;

- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController

//	CC_ENABLE_DEFAULT_GL_STATES();
//	CCDirector *director = [CCDirector sharedDirector];
//	CGSize size = [director winSize];
//	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
//	sprite.position = ccp(size.width/2, size.height/2);
//	sprite.rotation = -90;
//	[sprite visit];
//	[[director openGLView] swapBuffers];
//	CC_ENABLE_DEFAULT_GL_STATES();
	
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}

//Flurry Error handling
void uncaughtExceptionHandler(NSException *exception) {
	[FlurryAnalytics logError:@"Uncaught" message:@"Crash!" exception:exception];
} 

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	    
    //Init Airship launch options
#if (!TARGET_IPHONE_SIMULATOR)
    NSMutableDictionary *takeOffOptions = [[[NSMutableDictionary alloc] init] autorelease];
    [takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
#endif
    
    NSMutableDictionary *airshipConfigOptions = [[[NSMutableDictionary alloc] init] autorelease];
    [airshipConfigOptions setValue:@"ABrY7Z3nQw-VUSWDazXdvQ" forKey:@"DEVELOPMENT_APP_KEY"];
    [airshipConfigOptions setValue:@"0wrtgXz-Rju_B_-ExUO-dw" forKey:@"DEVELOPMENT_APP_SECRET"];
    
    [airshipConfigOptions setValue:@"6oS4VxnvSMuXkMSKRsP5Mg" forKey:@"PRODUCTION_APP_KEY"];
    [airshipConfigOptions setValue:@"e7XEzaiZQ8ifluQpgO2cMQ" forKey:@"PRODUCTION_APP_SECRET"];
    
    
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
    
    //Flurry
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        //DEV
        [FlurryAnalytics startSession:@"XPSP4VDHZBPJW1685ZG2"];
        [FlurryAnalytics setDebugLogEnabled:YES];
		//LIVE
		//[FlurryAnalytics startSession:@"UK9856B7DGEH65F9ZEZN"];
        //[FlurryAnalytics setDebugLogEnabled:NO];
        
	} else {
        [FlurryAnalytics startSession:@"U6KRHYYB3M5E9EQH3MM1"];
        [FlurryAnalytics setDebugLogEnabled:YES];
		//LIVE
		//[FlurryAnalytics startSession:@"KFMTNN19CSFDFAYKMP6H"];
        //[FlurryAnalytics setDebugLogEnabled:NO];

	}

    
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	
	CCDirector *director = [CCDirector sharedDirector];

	// Init the View Controller
	viewController = [[BubblePopRootViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
						];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
    [director setProjection:kCCDirectorProjection2D];
    
//	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
//	if( ! [director enableRetinaDisplay:YES] )
//		CCLOG(@"Retina Display Not supported");
	
	//
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//
	// IMPORTANT:
	// By default, this template only supports Landscape orientations.
	// Edit the RootViewController.m file to edit the supported orientations.
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif
	
	[director setAnimationInterval:1.0/60];

#ifdef DEBUG
	[director setDisplayFPS:YES];
#else
    [director setDisplayFPS:NO];
#endif	
	
	// make the OpenGLView a child of the view controller
	[viewController setView:glView];
	
	// make the View Controller a child of the main window
	[window addSubview: viewController.view];
	
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	
	// Removes the startup flicker
	[self removeStartupFlicker];
	
    [AudioHelper setup];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"ab_whiteglyphs_texture.plist" textureFile:@"ab_whiteglyphs_texture.png"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"ab_texture_sheet.plist" textureFile:@"ab_texture_sheet.png"];
    
    [viewController showIntroMovie];
        
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	if (viewController.pauseViewController == nil) {
        [[CCDirector sharedDirector] resume];
    }
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
	[viewController release];
	
	[window release];
	
	[director end];
    
    [UAirship land];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
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


- (void)dealloc {
	[[CCDirector sharedDirector] release];
	[window release];
	[super dealloc];
}

@end
