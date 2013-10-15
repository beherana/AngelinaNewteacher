//
//  AudioHelper.h
//  Angelina-Bubble-Pop-Universal
//
//  Created by Karl Söderström on 2011-08-23.
//  Copyright 2011 Commind AB. All rights reserved.
//

#import "SimpleAudioEngine.h"

#define AngelinaGameAudio_GameMusic @"game_music.m4a"
#define AngelinaGameAudio_MenuMusic @"menu_music.m4a"
#define AngelinaGameAudio_StretchAndPop @"01_Stretch_and_Pop_V3.m4a"
#define AngelinaGameAudio_AscendStar @"03_Ascend_Star_V2.m4a"
#define AngelinaGameAudio_PopBubble1 @"04_Pop_Bubble1_V2.m4a"
#define AngelinaGameAudio_PopBubble2 @"05_Pop_Bubble2_V2.m4a"
#define AngelinaGameAudio_PopBubble3 @"06_Pop_Bubble3_V2.m4a"
#define AngelinaGameAudio_PopBubble4 @"07_Pop_Bubble4_V2.m4a"
#define AngelinaGameAudio_ButterflyPop @"08_Butterflie_Pop_V2.m4a"
#define AngelinaGameAudio_BumblebeePop @"09_Bumble_Bee_Pop_V2.m4a"
#define AngelinaGameAudio_FlowerBushPop @"10_Flower_Bush_Pop.m4a"
#define AngelinaGameAudio_100p @"11_100p_V2.m4a"
#define AngelinaGameAudio_500p @"12_500p.m4a"
#define AngelinaGameAudio_KlickKlack1 @"13_Klick_Klack1.m4a"
#define AngelinaGameAudio_KlickKlack2 @"14_Klick_Klack2.m4a"
#define AngelinaGameAudio_KlickKlack3 @"15_Klick_Klack3.m4a"
#define AngelinaGameAudio_ChangeFlower @"16_Change_Flower_V2.m4a"
#define AngelinaGameAudio_ChangeFlowerLow @"16_Change_Flower_V2_LOW.m4a"
#define AngelinaGameAudio_LossOfLifeWooopSound @"17_Loss_of_Life_Wooop_Sound_V2.m4a"
#define AngelinaGameAudio_Highscore @"18_Highscore_V2.m4a"
#define AngelinaGameAudio_DefaultPop @"19_Default_Pop.m4a"
#define AngelinaGameAudio_ThoughtBubbleChange @"20_Thought_Bubble_Change.m4a"
#define AngelinaGameAudio_TickTack_1_5s @"TickTack_1_5s_V2.m4a"
#define AngelinaGameAudio_TickTack_2s @"TickTack_2s_V2.m4a"
#define AngelinaGameAudio_TickTack_One_Tap @"TickTack_One_Tap_V2.m4a"
#define AngelinaGameAudio_TimeOut @"TimeOut_V1.m4a"



@interface AudioHelper : NSObject

+(void)setup;
+(BOOL)audioIsEnabled;
+(void)enableAudio;
+(void)disableAudio;

+(void)preloadAudio;
+(void)preloadAudioFile:(NSString*)file;
+(ALuint)playAudio:(NSString*)file;
+(void)stopAudio:(ALuint)audio;
+(void)pauseAudio:(ALuint)audio;
+(void)resumeAudio:(ALuint)audio;
+(void)playBackgroundAudio:(NSString*)file;
+(void)pauseBackgroundAudio;
+(void)resumeBackgroundAudio;
+(void)stopBackgroundAudio;
@end
