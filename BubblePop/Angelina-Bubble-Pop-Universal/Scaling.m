//
//  Scaling.m
//  Angelina-Bubble-Pop-Universal
//
//  Created by Karl Söderström on 2011-08-25.
//  Copyright 2011 Commind AB. All rights reserved.
//

#import "Scaling.h"
#import "cocos2d.h"

#define DEFAULT_SCALE 0.46875

static Scaling *sharedScaling;

@implementation Scaling
@synthesize scale = _scale;
@synthesize UIKitScale = _UIKitScale;

+ (Scaling *)sharedInstance
{
    if (sharedScaling == nil) {
        sharedScaling = [[Scaling alloc] init];
    }
    return sharedScaling;
}

- (id)init
{
    self = [super init];
    if (self) {
        if ([[[UIDevice currentDevice] model] rangeOfString:@"iPad"].location != NSNotFound)
        {
            // ipad
            [[CCDirector sharedDirector] setContentScaleFactor:1.0];
            self.scale = 1.0; 
            self.UIKitScale = 1.0;
        } else {
            if([[UIScreen mainScreen] respondsToSelector:@selector(scale)]
               && [[UIScreen mainScreen] scale] == 2)
            {
                // retina
                [[CCDirector sharedDirector] setContentScaleFactor:2.0];
                self.scale = DEFAULT_SCALE * 2;
                self.UIKitScale = DEFAULT_SCALE;                
            } else {
                // iphone
                [[CCDirector sharedDirector] setContentScaleFactor:1.0];
                self.scale = DEFAULT_SCALE; 
                self.UIKitScale = DEFAULT_SCALE;                
            }
        }
    }
    
    return self;
}

+ (void)reset 
{
    [sharedScaling release];
    sharedScaling = nil;
    [[CCDirector sharedDirector] setContentScaleFactor:1.0];
}



@end
