//
//  ReadOverlayUIView.m
//  Angelina-New-Teacher-Universal
//
//  Created by Martin Kamara on 2011-09-04.
//  Copyright 2011 Commind. All rights reserved.
//

#import "ReadOverlayUIView.h"

@implementation ReadOverlayUIView

@synthesize danceButton,repeatNarrationButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    if(CGRectContainsPoint(repeatNarrationButton.frame, point) || CGRectContainsPoint(danceButton.frame, point))
        return YES; // touched button!
    
    return NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}

*/
- (void)dealloc {
    self.repeatNarrationButton = nil;
    self.danceButton = nil;
    [super dealloc];
}
@end
