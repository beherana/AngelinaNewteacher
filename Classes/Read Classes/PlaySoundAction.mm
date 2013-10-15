//
//  PlaySoundAction.mm
//  Misty-Island-Rescue-iPad
//
//  Created by Johannes Amilon on 11/26/10.
//  Copyright 2010 Vitamin Se Media AB. All rights reserved.
//

#import "PlaySoundAction.h"
#import "Angelina_AppDelegate.h"

@implementation PlaySoundAction

@synthesize volume;

static NSMutableDictionary *soundList=nil;
static BOOL preventSound=NO;

+(id) actionWithFilePath:(NSString *)file{
	return [[[self alloc] initWithFilePath:file] autorelease];
}

-(id) initWithFilePath:(NSString *)file{
	if ((self=[super init])) {
		volume=1.0f;
		filePath=[file retain];
		[[SimpleAudioEngine sharedEngine] preloadEffect:filePath];
	}
	return self;
}

+(void)pauseSounds{
	if (soundList==nil) {
		return;
	}
	NSArray *keys=[soundList allKeys];
	for (uint i=0; i<[keys count]; ++i) {
		ALuint source=[[keys objectAtIndex:i] intValue];
		ALuint result=[[SimpleAudioEngine sharedEngine] pauseEffect:source];
		//NSLog(@"pausing %d, result %d",source,result);
		if (source!=result) {
			[soundList removeObjectForKey:[keys objectAtIndex:i]];
		}
	}
}

+(void)resumeSounds{
	if (soundList==nil) {
		return;
	}
	NSArray *keys=[soundList allKeys];
	for (uint i=0; i<[keys count]; ++i) {
		ALuint source=[[keys objectAtIndex:i] intValue];
		/*ALuint result=*/[[SimpleAudioEngine sharedEngine] resumeEffect:source];
		//NSLog(@"resuming %d, result %d",source,result);
	}
}

+(void)clearSounds{
	if (soundList==nil) {
		return;
	}
	[soundList removeAllObjects];
}

+(void)stopSounds{
    NSLog(@"Stop sound called");
	if (soundList==nil) {
		return;
	}
	NSArray *keys=[soundList allKeys];
	for (uint i=0; i<[keys count]; ++i) {
		ALuint source=[[keys objectAtIndex:i] intValue];
		[[SimpleAudioEngine sharedEngine] stopEffect:source];
	}
	[soundList removeAllObjects];
}
+(void)adjustGainOnFX:(ALfloat)value{
    
    [[SimpleAudioEngine sharedEngine] changeGainOnAllFXSounds:value];
    
}
+(void)setSoundsPrevented:(BOOL)state{
	preventSound=state;
}

-(void) startWithTarget:(id)aTarget
{
	//Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
	//if (appDelegate.speakerPlayer.playing) [appDelegate stopReadSpeakerPlayback];
	[super startWithTarget:aTarget];
	
	if (preventSound) {
		return;
	}
	
	source=[[SimpleAudioEngine sharedEngine] playEffect:filePath  pitch:1.0f pan:0.0f gain:volume];
	NSNumber *s=[NSNumber numberWithInt:source];
	if (soundList==nil) {
		soundList=[[NSMutableDictionary alloc] init];
	}
	[soundList setObject:s forKey:s];
}

-(void)dealloc{
	[[SimpleAudioEngine sharedEngine] stopEffect:source];
	[[SimpleAudioEngine sharedEngine] unloadEffect:filePath];
	[filePath release];
	[super dealloc];
}

@end
