//
//  PuzzleViewController_iPhone.m
//
//  Created by Henrik Nord on 2/14/11.
//  Copyright 2011 Haunted House. All rights reserved.
//

#import "PuzzleViewController_iPhone.h"
#import "PuzzleDelegate.h"

@implementation PuzzleViewController_iPhone

-(void) initWithParent: (id) parent
{
	self=[super init];
	if (self){
		myParent=parent;
	}
	return;
}

@end
