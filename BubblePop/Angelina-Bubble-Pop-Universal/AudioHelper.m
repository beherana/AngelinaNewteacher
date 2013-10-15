//
//  AudioHelper.m
//  Angelina-Bubble-Pop-Universal
//
//  Created by Karl Söderström on 2011-08-23.
//  Copyright 2011 Commind AB. All rights reserved.
//

#import "AudioHelper.h"
#import "SimpleAudioEngine.h"

#define BubblePopAudioEnabled @"BubblePopAudioEnabled"

@implementation AudioHelper

+(void)preloadAudio
{
    SimpleAudioEngine *engine = [SimpleAudioEngine sharedEngine];
    [engine preloadEffect:AngelinaGameAudio_ThoughtBubbleChange];
    [engine preloadEffect:AngelinaGameAudio_ChangeFlower];
    [engine preloadEffect:AngelinaGameAudio_ChangeFlowerLow];
    [engine preloadEffect:AngelinaGameAudio_DefaultPop];
    [engine preloadEffect:AngelinaGameAudio_PopBubble1];
    [engine preloadEffect:AngelinaGameAudio_PopBubble2];
    [engine preloadEffect:AngelinaGameAudio_PopBubble3];
    [engine preloadEffect:AngelinaGameAudio_PopBubble4];
    [engine preloadEffect:AngelinaGameAudio_StretchAndPop];
    [engine preloadEffect:AngelinaGameAudio_AscendStar];
    [engine preloadEffect:AngelinaGameAudio_LossOfLifeWooopSound];
    [engine preloadEffect:AngelinaGameAudio_ButterflyPop];
    [engine preloadEffect:AngelinaGameAudio_BumblebeePop];
    [engine preloadEffect:AngelinaGameAudio_FlowerBushPop];
    [engine preloadEffect:AngelinaGameAudio_100p];
    [engine preloadEffect:AngelinaGameAudio_500p];
    [engine preloadEffect:AngelinaGameAudio_KlickKlack1];
    [engine preloadEffect:AngelinaGameAudio_KlickKlack2];
    [engine preloadEffect:AngelinaGameAudio_KlickKlack3];
    [engine preloadEffect:AngelinaGameAudio_Highscore];
    [engine preloadEffect:AngelinaGameAudio_TickTack_1_5s];
    [engine preloadEffect:AngelinaGameAudio_TickTack_2s];
    [engine preloadEffect:AngelinaGameAudio_TickTack_One_Tap];
    [engine preloadEffect:AngelinaGameAudio_TimeOut];
    
}

+(void)preloadAudioFile:(NSString*)file
{
    [[SimpleAudioEngine sharedEngine] preloadEffect:file];

}

+(void)setup
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:BubblePopAudioEnabled]];
    BOOL audioEnabled = [AudioHelper audioIsEnabled];
    if (audioEnabled) {
        [AudioHelper enableAudio];
    } else {
        [AudioHelper disableAudio];
    }
}

+(BOOL)audioIsEnabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:BubblePopAudioEnabled];
}

+(void)enableAudio
{
    [[SimpleAudioEngine sharedEngine] setEffectsVolume:1.0];
    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.5];
    if (![AudioHelper audioIsEnabled]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:BubblePopAudioEnabled];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+(void)disableAudio
{
    [[SimpleAudioEngine sharedEngine] setEffectsVolume:0.0];
    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.0];
    if ([AudioHelper audioIsEnabled]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:BubblePopAudioEnabled];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+(ALuint)playAudio:(NSString*)file
{
    if ([self audioIsEnabled]) {
        return [[SimpleAudioEngine sharedEngine] playEffect:file];
    } else {
        return 0;
    }
}

+(void)stopAudio:(ALuint)audio
{
    if ([self audioIsEnabled] && audio > 0) {
        [[SimpleAudioEngine sharedEngine] stopEffect:audio];
    }
}

+(void)pauseAudio:(ALuint)audio
{
    if ([self audioIsEnabled] && audio > 0) {
        [[SimpleAudioEngine sharedEngine] pauseEffect:audio];
    }
}

+(void)resumeAudio:(ALuint)audio
{
    if ([self audioIsEnabled] && audio > 0) {
        [[SimpleAudioEngine sharedEngine] resumeEffect:audio];
    }
}


+(void)playBackgroundAudio:(NSString*)file
{
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:file loop:YES];
}

+(void)pauseBackgroundAudio
{
    [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
}

+(void)resumeBackgroundAudio
{
    [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
}

+(void)stopBackgroundAudio
{
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
}
@end
