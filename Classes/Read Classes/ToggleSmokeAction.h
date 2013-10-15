//
//  ToggleSmokeAction.h
//  Misty-Island-Rescue-iPad
//
//  Created by Johannes Amilon on 11/26/10.
//  Copyright 2010 Vitamin Se Media AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface ToggleSmokeAction : CCActionInstant {
	BOOL smokeState;	
}

+(id) actionWithState:(BOOL)state;

-(id) initWithState:(BOOL)state;

@end
