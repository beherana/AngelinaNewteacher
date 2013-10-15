//
//  DotImageView.mm
//  Misty-Island-Rescue-iPad
//
//  Created by Johannes Amilon on 11/25/10.
//  Copyright 2010 Vitamin Se Media AB. All rights reserved.
//

#import "DotImageView.h"
#import "DotView.h"

@implementation DotImageView

@synthesize index;

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	[((DotView *)[self superview]) dotTouchBegan:self];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	[((DotView *)[self superview]) dotTouchEnded:self];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
	[[self superview] touchesCancelled:touches withEvent:event];
}

@end
