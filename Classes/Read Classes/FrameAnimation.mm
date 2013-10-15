//
//  SceneAnimation.m
//  Thomas
//
//  Created by Johannes Amilon on 11/8/10.
//  Copyright 2010 Vitamin Se Media AB. All rights reserved.
//

#import "FrameAnimation.h"
#import "Angelina_AppDelegate.h"
#import "BookScene.h"
#import "PlaySoundAction.h"

@implementation FrameAnimation

@synthesize spriteSheet,parentIndex,hasSound;

-(id) initWithDictionary:(NSDictionary *)data:(int)tag{
	if ((self=[super init])) {
		//load spritesheet
		parentIndex=-1;
		name=[[data objectForKey:@"texturedata"] retain];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[name stringByAppendingString:@".plist"]];
		spriteSheet=[[CCSpriteBatchNode batchNodeWithFile:[name stringByAppendingString:@".png"]] retain];
		[spriteSheet.textureAtlas.texture setAntiAliasTexParameters];
		spriteSheet.tag=tag;
		animations=[[NSMutableDictionary alloc] init];
		sprites=[[NSMutableDictionary alloc] init];
		firstFrames=[[NSMutableDictionary alloc] init];
		
		NSDictionary *source=[data objectForKey:@"source"];
		NSArray *keys=[source allKeys];
		
		if ([data objectForKey:@"visibleInactive"]){
			visibleInactive=[[data objectForKey:@"visibleInactive"] boolValue];
		}else {
			visibleInactive=false;
		}
        spriteSheet.visible=visibleInactive;
		repeatsForever=[[data objectForKey:@"repeatForever"] boolValue];
		
		if ([data objectForKey:@"returnToFirstFrame"]) {
			returnToFirstFrame=[[data objectForKey:@"returnToFirstFrame"] boolValue];
		}else{
			returnToFirstFrame=NO;
		}
		
		hasSound=NO;
		
		for (uint i=0; i<[keys count]; ++i) {
			if ([[source objectForKey:[keys objectAtIndex:i]] count]==2) {
				NSArray *frames;
				NSDictionary *values;
				NSMutableArray *animFrames;
				values=[[source objectForKey:[keys objectAtIndex:i]] objectAtIndex:0];
				frames=[[source objectForKey:[keys objectAtIndex:i]] objectAtIndex:1];
				
				//load animation
				int totalFrames=[[values objectForKey:@"totalFrames"] intValue];
				animFrames=[NSMutableArray arrayWithCapacity:totalFrames];
				for (int j=0; j<totalFrames; ++j) {
					[animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[[frames objectAtIndex:j%[frames count]] stringByAppendingString:@".png"]]];
				}
				
				CCAnimation *animation=[CCAnimation animationWithFrames:animFrames delay:1.0f/[[values objectForKey:@"frameRate"] floatValue]];
                
                if (repeatsForever) {
					if ([values objectForKey:@"sound"]) {
						hasSound=YES;
						PlaySoundAction *playSound=[PlaySoundAction actionWithFilePath:[values objectForKey:@"sound"]];
						if ([values objectForKey:@"volume"]) {
							playSound.volume=[[values objectForKey:@"volume"] floatValue];
						}
						[animations setObject:[CCRepeatForever actionWithAction:
											   [CCSpawn actionOne:playSound 
												two:[CCAnimate actionWithAnimation:animation restoreOriginalFrame:NO]]]
									   forKey:[keys objectAtIndex:i]];
						
					}else if ([values objectForKey:@"sound_lang"]) {
                        //if in UK-area add _UK to soundfiles that have the _lang tag
                        NSString *fixedsound = [Angelina_AppDelegate getLocalizedAssetName:[values objectForKey:@"sound_lang"]];
                        
                        hasSound=YES;
						PlaySoundAction *playSound=[PlaySoundAction actionWithFilePath:fixedsound];
						if ([values objectForKey:@"volume"]) {
							playSound.volume=[[values objectForKey:@"volume"] floatValue];
						}
						[animations setObject:[CCRepeatForever actionWithAction:
											   [CCSpawn actionOne:playSound 
                                                              two:[CCAnimate actionWithAnimation:animation restoreOriginalFrame:NO]]]
									   forKey:[keys objectAtIndex:i]];
                    }else {
						[animations setObject:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animation restoreOriginalFrame:NO]] forKey:[keys objectAtIndex:i]];
						
					}					
				}else {
					if ([values objectForKey:@"sound"]) {
						hasSound=YES;
						PlaySoundAction *playSound=[PlaySoundAction actionWithFilePath:[values objectForKey:@"sound"]];
						if ([values objectForKey:@"volume"]) {
							playSound.volume=[[values objectForKey:@"volume"] floatValue];
						}
						[animations setObject:[CCSequence actions:
											   [CCSpawn actionOne:playSound two:[CCAnimate actionWithAnimation:animation restoreOriginalFrame:NO]],
											   [CCCallFuncN actionWithTarget:self selector:@selector(animationDone)],nil] forKey:[keys objectAtIndex:i]];
					}else if ([values objectForKey:@"sound_lang"]) {
                        //if in UK-area add _UK to soundfiles that have the _lang tag
                        NSString *fixedsound = [Angelina_AppDelegate getLocalizedAssetName:[values objectForKey:@"sound_lang"]];
                        
                        hasSound=YES;
						PlaySoundAction *playSound=[PlaySoundAction actionWithFilePath:fixedsound];
						if ([values objectForKey:@"volume"]) {
							playSound.volume=[[values objectForKey:@"volume"] floatValue];
						}
						[animations setObject:[CCSequence actions:
											   [CCSpawn actionOne:playSound two:[CCAnimate actionWithAnimation:animation restoreOriginalFrame:NO]],
											   [CCCallFuncN actionWithTarget:self selector:@selector(animationDone)],nil] forKey:[keys objectAtIndex:i]];
                    }else {
						[animations setObject:[CCSequence actions:
											   [CCAnimate actionWithAnimation:animation restoreOriginalFrame:NO],
											   [CCCallFuncN actionWithTarget:self selector:@selector(animationDone)],nil] forKey:[keys objectAtIndex:i]];
					}
				}
				//create sprite
				CCSprite *sprite=[CCSprite spriteWithSpriteFrame:[animFrames objectAtIndex:0]];
				sprite.position=CGPointMake([[values objectForKey:@"x"] floatValue],[[values objectForKey:@"y"] floatValue]);
				sprite.tag=i;
				if (!visibleInactive) {
					sprite.opacity=0;
				}				
				[spriteSheet addChild:sprite z:[[values objectForKey:@"z"] intValue]];
				
				[sprites setObject:sprite forKey:[keys objectAtIndex:i]];
				if (visibleInactive && returnToFirstFrame) {
					[firstFrames setObject:[animFrames objectAtIndex:0] forKey:[keys objectAtIndex:i]];
				}
			}else {
				//multiple frame animations in a row, put them in a sequence action
				CCSequence *sequence=nil;
				CCSpriteFrame *first;
				uint anims=[[source objectForKey:[keys objectAtIndex:i]] count];
				for (uint k=0; k<anims; k+=2) {
					NSArray *frames;
					NSDictionary *values;
					NSMutableArray *animFrames;
					values=[[source objectForKey:[keys objectAtIndex:i]] objectAtIndex:k];
					frames=[[source objectForKey:[keys objectAtIndex:i]] objectAtIndex:k+1];
					int totalFrames=[[values objectForKey:@"totalFrames"] intValue];
					animFrames=[NSMutableArray arrayWithCapacity:totalFrames];
					for (int j=0; j<totalFrames; ++j) {
						[animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[[frames objectAtIndex:j%[frames count]] stringByAppendingString:@".png"]]];
					}
					CCAnimation *animation=[CCAnimation animationWithFrames:animFrames delay:1.0f/[[values objectForKey:@"frameRate"] floatValue]];
					
					if (sequence==nil) {
						if ([values objectForKey:@"sound"]) {
							hasSound=YES;
							PlaySoundAction *playSound=[PlaySoundAction actionWithFilePath:[values objectForKey:@"sound"]];
							if ([values objectForKey:@"volume"]) {
								playSound.volume=[[values objectForKey:@"volume"] floatValue];
							}
							sequence=[CCSequence actions:[CCSpawn actionOne:playSound two:[CCAnimate actionWithAnimation:animation restoreOriginalFrame:NO]],nil];
						}else if ([values objectForKey:@"sound_lang"]) {
                            //if in UK-area add _UK to soundfiles that have the _lang tag
                            NSString *fixedsound = [Angelina_AppDelegate getLocalizedAssetName:[values objectForKey:@"sound_lang"]];
                            
							hasSound=YES;
							PlaySoundAction *playSound=[PlaySoundAction actionWithFilePath:fixedsound];
							if ([values objectForKey:@"volume"]) {
								playSound.volume=[[values objectForKey:@"volume"] floatValue];
							}
							sequence=[CCSequence actions:[CCSpawn actionOne:playSound two:[CCAnimate actionWithAnimation:animation restoreOriginalFrame:NO]],nil];
						} else {
							sequence=[CCSequence actions:[CCAnimate actionWithAnimation:animation restoreOriginalFrame:NO],nil];
						}
						first=[animFrames objectAtIndex:0];
					}else {
						if ([values objectForKey:@"sound"]) {
							hasSound=YES;
							PlaySoundAction *playSound=[PlaySoundAction actionWithFilePath:[values objectForKey:@"sound"]];
							if ([values objectForKey:@"volume"]) {
								playSound.volume=[[values objectForKey:@"volume"] floatValue];
							}
							sequence=[CCSequence actionOne:sequence two:[CCSpawn actionOne:playSound two:[CCAnimate actionWithAnimation:animation restoreOriginalFrame:NO]]];
						}else if ([values objectForKey:@"sound_lang"]) {
                            //if in UK-area add _UK to soundfiles that have the _lang tag
                            NSString *fixedsound = [Angelina_AppDelegate getLocalizedAssetName:[values objectForKey:@"sound_lang"]];
                            
							hasSound=YES;
							PlaySoundAction *playSound=[PlaySoundAction actionWithFilePath:fixedsound];
							if ([values objectForKey:@"volume"]) {
								playSound.volume=[[values objectForKey:@"volume"] floatValue];
							}
							sequence=[CCSequence actionOne:sequence two:[CCSpawn actionOne:playSound two:[CCAnimate actionWithAnimation:animation restoreOriginalFrame:NO]]];
						} else {
							sequence=[CCSequence actionOne:sequence two:[CCAnimate actionWithAnimation:animation restoreOriginalFrame:NO]];
						}
					}
				}
				if (repeatsForever) {
					[animations setObject:[CCRepeatForever actionWithAction:sequence] forKey:[keys objectAtIndex:i]];
				}else {
					[animations setObject:[CCSequence actionOne:sequence two:[CCCallFuncN actionWithTarget:self selector:@selector(animationDone)]] forKey:[keys objectAtIndex:i]];
				}
				//create sprite
				CCSprite *sprite=[CCSprite spriteWithSpriteFrame:first];
				sprite.position=CGPointMake([[[[source objectForKey:[keys objectAtIndex:i]] objectAtIndex:0] objectForKey:@"x"] floatValue],[[[[source objectForKey:[keys objectAtIndex:i]] objectAtIndex:0] objectForKey:@"y"] floatValue]);
				sprite.tag=i;
				if (!visibleInactive) {
					sprite.opacity=0;
				}
				[spriteSheet addChild:sprite z:[[[[source objectForKey:[keys objectAtIndex:i]] objectAtIndex:0] objectForKey:@"z"] intValue]];
				
				[sprites setObject:sprite forKey:[keys objectAtIndex:i]];
				if (visibleInactive && returnToFirstFrame) {
					[firstFrames setObject:first forKey:[keys objectAtIndex:i]];
				}
			}
			
		}
	}
	return self;
}

-(void) startAnimations{
	//starts all animations
	NSArray *keys=[sprites allKeys];
	for (uint i=0; i<[keys count]; ++i) {
		((CCSprite *)[sprites objectForKey:[keys objectAtIndex:i]]).opacity=255;
		[[sprites objectForKey:[keys objectAtIndex:i]] runAction:[animations objectForKey:[keys objectAtIndex:i]]];
	}
    spriteSheet.visible=YES;
}
-(void) stopAnimations{
	//stops all animations
	NSArray *keys=[sprites allKeys];
	for (uint i=0; i<[keys count]; ++i) {
		[[sprites objectForKey:[keys objectAtIndex:i]] stopAllActions];
	}
}

-(void) animationDone{
	//called when animation is done (called once for each individual sprite)
	NSArray *keys=[sprites allKeys];
	for (uint i=0; i<[keys count]; ++i) {
		if (!visibleInactive) {
			((CCSprite *)[sprites objectForKey:[keys objectAtIndex:i]]).opacity=0;
		}else if (returnToFirstFrame) {
			[((CCSprite *)[sprites objectForKey:[keys objectAtIndex:i]]) setDisplayFrame:[firstFrames objectForKey:[keys objectAtIndex:i]]];
		}
		
	}
    spriteSheet.visible=visibleInactive;
	if (parentIndex!=-1) {
		[[[[Angelina_AppDelegate get] currentRootViewController].currentScene.components objectAtIndex:parentIndex] animationDone];
	}
}
	
-(int) numberOfCallbacks{
	//the number of times animationDone will be called
	if (repeatsForever) {
		return 0;
	}
	return [sprites count];
}

-(void) killAnimations{
	[animations release];
	animations=nil;
}

-(void) dealloc{
	[firstFrames release];
	[name release];
	[spriteSheet release];
	[sprites release];
	[animations release];
	[super dealloc];
}

@end
