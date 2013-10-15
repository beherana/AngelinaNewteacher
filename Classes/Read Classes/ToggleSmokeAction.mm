//
//  ToggleSmokeAction.mm
//  Misty-Island-Rescue-iPad
//
//  Created by Johannes Amilon on 11/26/10.
//  Copyright 2010 Vitamin Se Media AB. All rights reserved.
//

#import "ToggleSmokeAction.h"
#import "SmokeNode.h"

@implementation ToggleSmokeAction

+(id) actionWithState:(BOOL)state{
	return [[[self alloc] initWithState:state] autorelease];
}

-(id) initWithState:(BOOL)state{
	if ((self=[super init])) {
		smokeState=state;
	}
	return self;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	((SmokeNode *)aTarget).spewSmoke=smokeState;
}

@end
