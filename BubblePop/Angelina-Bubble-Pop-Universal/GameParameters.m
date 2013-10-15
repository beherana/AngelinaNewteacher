//
//  GameParameters.m
//  AngelinaGame
//
//  Created by Karl Söderström on 2011-06-27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameParameters.h"
#import "GameState.h"
static NSDictionary *params;
static NSDictionary *layout;

@implementation GameParameters

+(NSDictionary *) params
{
    if (params == nil) {
        
        NSString *file = @"game_parameters";
        if ([GameState sharedInstance].gameMode == AngelinaGameMode_Clock) {
            file = @"game_parameters_clock";
        }
        
        NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:@"plist"];
        params = [[NSDictionary dictionaryWithContentsOfFile:path] retain];
    }
    return params;
}

+(NSDictionary *) layout
{
    if (layout == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"layout" ofType:@"plist"];
        layout = [[NSDictionary dictionaryWithContentsOfFile:path] retain];
    }
    return layout;
}

+(void)reset
{
    [params release];
    params = nil;
}

@end
