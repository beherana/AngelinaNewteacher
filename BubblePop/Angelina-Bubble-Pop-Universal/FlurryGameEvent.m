//
//  FlurryGameEvent.m
//  Angelina-Bubble-Pop-Universal
//
//  Created by Martin Kamara on 2011-08-31.
//  Copyright 2011 Commind. All rights reserved.
//

#import "FlurryGameEvent.h"
#import "cdaAnalytics.h"
#import "GameState.h"

@implementation FlurryGameEvent

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

//Wrap the flurry call with a game mode parameter
+(void) logEvent:(NSString *) event {
    switch ([GameState sharedInstance].gameMode) {
        case AngelinaGameMode_Classic:
            [[cdaAnalytics sharedInstance] trackEvent:@"Classic" inCategory:flurryEventPrefix(event) withLabel:@"game mode" andValue:-1];
            break;
        case AngelinaGameMode_Clock:
            [[cdaAnalytics sharedInstance] trackEvent:@"Beat the Clock" inCategory:flurryEventPrefix(event) withLabel:@"game mode" andValue:-1];
            break;
        default:
            [[cdaAnalytics sharedInstance] trackEvent:@"unknown" inCategory:flurryEventPrefix(event) withLabel:@"game mode" andValue:-1];
            break;
    }    
}

//appends a game mode value to the flurry log events
+(void) logEvent:(NSString *) event withParameters:(NSDictionary *)parameters {
    NSMutableDictionary *mutableParameters = [parameters mutableCopy];

    switch ([GameState sharedInstance].gameMode) {
        case AngelinaGameMode_Classic:
//            [mutableParameters setObject:@"Classic" forKey:@"game mode"];
//            [FlurryAnalytics logEvent:flurryEventPrefix(event) withParameters:mutableParameters];
            
            [[cdaAnalytics sharedInstance] trackEvent:@"Classic" inCategory:flurryEventPrefix(event) withLabel:@"game mode" andValue:-1];
            
            break;
        case AngelinaGameMode_Clock:
//            [mutableParameters setObject:@"Beat the Clock" forKey:@"game mode"];
//            [FlurryAnalytics logEvent:flurryEventPrefix(event) withParameters:mutableParameters];
             
            [[cdaAnalytics sharedInstance] trackEvent:@"Beat the Clock" inCategory:flurryEventPrefix(event) withLabel:@"game mode" andValue:-1];
             
            break;
        default:
//            [mutableParameters setObject:@"unknown" forKey:@"game mode"];
//            [FlurryAnalytics logEvent:flurryEventPrefix(event) withParameters:mutableParameters];
             
             [[cdaAnalytics sharedInstance] trackEvent:@"unknown" inCategory:flurryEventPrefix(event) withLabel:@"game mode" andValue:-1];
             
            break;
    }    
}

//Append game mode to Event name
+(void) logEventPrefixWithMode:(NSString *) event withParameters:parameters timed:(BOOL) timed {
    switch ([GameState sharedInstance].gameMode) {
        case AngelinaGameMode_Classic:
            
            [[cdaAnalytics sharedInstance] trackEvent:[NSString stringWithFormat:flurryEventPrefix(@"Classic: %@"),event]];
            
            break;
        case AngelinaGameMode_Clock:
            
            [[cdaAnalytics sharedInstance] trackEvent:[NSString stringWithFormat:flurryEventPrefix(@"Beat the Clock: %@"),event]];
            break;
        default:
            
            [[cdaAnalytics sharedInstance] trackEvent:[NSString stringWithFormat:flurryEventPrefix(@"Unknown: %@"),event] ];
            
            break;
    }    
}

+(void) logEventPrefixWithMode:(NSString *) event withParameters:parameters {
    [FlurryGameEvent logEventPrefixWithMode:event withParameters:parameters timed:NO];
}

//Append game mode to Event name
+(void) endTimedEventPrefixWithMode:(NSString *) event {
    switch ([GameState sharedInstance].gameMode) {
        case AngelinaGameMode_Classic:
            
            [[cdaAnalytics sharedInstance] trackEvent:[NSString stringWithFormat:flurryEventPrefix(@"Classic: %@"),event]];
            
            break;
        case AngelinaGameMode_Clock:
            
            [[cdaAnalytics sharedInstance] trackEvent:[NSString stringWithFormat:flurryEventPrefix(@"Beat the Clock: %@"),event]];
            
            break;
        default:            
            [[cdaAnalytics sharedInstance] trackEvent:[NSString stringWithFormat:flurryEventPrefix(@"Unknown: %@"),event]];
            
            break;
    }
}

@end
