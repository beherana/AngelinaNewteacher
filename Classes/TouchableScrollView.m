//
//  TouchableScrollView.m
//  Angelina-New-Teacher-Universal
//
//  Created by Radif Sharafullin on 6/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TouchableScrollView.h"


@implementation TouchableScrollView
@synthesize target, selector;
-(id)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if (self) {
        self.target=nil;
        self.selector=nil;
    }
    return self;

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.target) {
        if ([self.target respondsToSelector:self.selector])
            [self.target performSelector:self.selector];
    }
}
- (void)dealloc
{
    [super dealloc];
}

@end
