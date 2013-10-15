//
//  ScoreIncrementAction.m
//  Angelina-Bubble-Pop-Universal
//
//  Created by Karl Söderström on 2011-08-17.
//  Copyright 2011 Commind AB. All rights reserved.
//

#import "ScoreIncrementAction.h"
#import "AudioHelper.h"

@implementation ScoreIncrementAction

+(id) actionWithDuration:(ccTime)t fromScore:(NSUInteger) fromScore toScore:(NSUInteger)toScore withAudio:(BOOL)audio
{	
	return [[[self alloc] initWithDuration:(ccTime)t fromScore:(NSUInteger) fromScore toScore:(NSUInteger)toScore withAudio:audio] autorelease];
}

-(id) initWithDuration:(ccTime)t fromScore:(NSUInteger) fromScore toScore:(NSUInteger)toScore withAudio:(BOOL)audio
{
	if((self=[super initWithDuration: t])) {
		_fromScore = fromScore;
        _toScore = toScore;
        _audio = audio;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone]initWithDuration:[self duration] fromScore:_fromScore toScore:_toScore withAudio:_audio];
	return copy;
}

-(void) startWithTarget:(CCNode *)aTarget
{
    NSAssert([aTarget respondsToSelector:@selector(setString:)], @"Incompatible target node");
	[super startWithTarget:aTarget];
	_delta = _toScore - _fromScore;
}

-(void) update: (ccTime) t
{	
    NSUInteger score = _fromScore + round(_delta * t);
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
    [formatter setGroupingSeparator:@","];
    [formatter setGroupingSize:3];
    [formatter setUsesGroupingSeparator:YES];
    NSString *str = [formatter stringFromNumber:[NSNumber numberWithInt:score]];
    NSString *current = ((CCLabelBMFont *)target_).string;
    if (_audio && ![current isEqual:str]) {
        [AudioHelper playAudio:AngelinaGameAudio_TickTack_One_Tap];
    }
    [target_ setString:str];
}

@end
