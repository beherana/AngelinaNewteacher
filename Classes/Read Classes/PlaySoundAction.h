//
//  PlaySoundAction.h
//  Misty-Island-Rescue-iPad
//
//  Created by Johannes Amilon on 11/26/10.
//  Copyright 2010 Vitamin Se Media AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"

@interface PlaySoundAction : CCActionInstant {
	NSString *filePath;
	float volume;
	ALuint source;
}

@property (nonatomic) float volume;

+(id) actionWithFilePath:(NSString *)file;

+(void)pauseSounds;
+(void)resumeSounds;
+(void)clearSounds;
+(void)stopSounds;
+(void)adjustGainOnFX:(ALfloat)value;
+(void)setSoundsPrevented:(BOOL)state;

-(id) initWithFilePath:(NSString *)file;

@end
