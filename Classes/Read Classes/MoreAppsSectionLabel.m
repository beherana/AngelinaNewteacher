//
//  MoreAppsSectionLabel.m
//  Day-Of-The-Deisels-Universal
//
//  Created by Martin Kamara on 2011-10-12.
//  Copyright 2011 Commind. All rights reserved.
//

#import "MoreAppsSectionLabel.h"

@implementation MoreAppsSectionLabel
@synthesize ruler;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.ruler = [[[UIView alloc] init] autorelease];
        
        float rulerHeight = 1;
        self.ruler=[[[UIView alloc]initWithFrame:CGRectMake(0, frame.size.height - rulerHeight, frame.size.width, rulerHeight)] autorelease];
        [self.ruler setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self addSubview:self.ruler];
        
       // self.backgroundColor = [UIColor redColor];
    }
    
    return self;
}

-(void) setTextColor:(UIColor *)textColor {
    [super setTextColor:textColor];
    self.ruler.backgroundColor = textColor;
}

- (void)dealloc
{
    self.ruler = nil;
    
    [super dealloc];
}


@end
