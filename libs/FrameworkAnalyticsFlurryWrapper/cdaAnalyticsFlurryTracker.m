//
//  cdaAnalyticsFlurryTracker.m
//
//  Created by zhen tan on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cdaAnalyticsFlurryTracker.h"
#import "FlurryAnalytics.h"

@implementation cdaAnalyticsFlurryTracker
@synthesize apiKey;

+(cdaAnalyticsFlurryTracker*) trackerWithAPIKey:(NSString*) key {
    return [[[cdaAnalyticsFlurryTracker alloc] initWithAPIKey:key] autorelease];
}

-(id) initWithAPIKey: (NSString*) key {
    self = [super init];
    if( self ) {
        self.apiKey = key;
    }
    return self;
}

-(void)startTracker
{
    [FlurryAnalytics startSession:self.apiKey];
}

-(void)trackPage:(NSString*)pageName
{
    [FlurryAnalytics logEvent:@"cdaAnalytics" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:pageName, @"Navigations events", nil]];
}

-(void)trackEvent:(NSString *)eventName inCategory:(NSString*)categoryName withLabel:(NSString*)labelName andValue:(int)value
{
    [FlurryAnalytics logEvent:categoryName withParameters:[NSDictionary dictionaryWithObjectsAndKeys:eventName, eventName, nil]];
}

-(void)logError:(NSString*)error withMessage:(NSString*)msg andException:(NSException*)exception
{
    [FlurryAnalytics logError:error message:msg exception:exception];
}

-(void)setSessionReportsOnCloseEnabled:(BOOL)reportOnClose
{
    [FlurryAnalytics setSessionReportsOnCloseEnabled:reportOnClose];
}
@end
