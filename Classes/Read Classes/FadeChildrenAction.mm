//
//  FadeChildrenAction.mm
//  Misty-Island-Rescue-iPad
//
//  Created by Johannes Amilon on 12/2/10.
//  Copyright 2010 Vitamin Se Media AB. All rights reserved.
//

#import "FadeChildrenAction.h"


@implementation FadeChildrenAction

-(void) update: (ccTime) t
{
	[self recursiveFade:target_ :t];
}

-(void)recursiveFade:(CCNode *)node :(ccTime)t{
	if ([node isKindOfClass:[CCSprite class]]) {
		[(id<CCRGBAProtocol>)node setOpacity: fromOpacity + ( toOpacity - fromOpacity ) * t];
	}
	CCArray *children=[node children];
	for (uint i=0; i<[children count]; ++i) {
		[self recursiveFade:[children objectAtIndex:i] :t];
	}
}

@end
