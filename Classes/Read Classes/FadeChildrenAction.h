//
//  FadeChildrenAction.h
//  Misty-Island-Rescue-iPad
//
//  Created by Johannes Amilon on 12/2/10.
//  Copyright 2010 Vitamin Se Media AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface FadeChildrenAction :CCFadeTo {

}

-(void)recursiveFade:(CCNode *)node:(ccTime)t;

@end
