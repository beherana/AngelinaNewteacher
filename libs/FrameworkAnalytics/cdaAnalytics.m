//
//  cdaAnalytics.m
//
//  Created by zhen tan on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cdaAnalytics.h"

@implementation cdaAnalytics

+(cdaAnalytics*)sharedInstance {
    static cdaAnalytics* instance = nil;
    if( instance == nil ) {
        instance = [cdaAnalytics new];
    }
    return instance;
}

-(id)init
{
    self = [super init];
    if (self)
    {
        trackers = nil;
        timers = nil;
        
        [[NSNotificationCenter defaultCenter]   addObserver:self
                                                   selector:@selector(applicationDidEnterBackgroundNotification:)
                                                       name:UIApplicationDidEnterBackgroundNotification
                                                     object:[UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter]   addObserver:self
                                                   selector:@selector(applicationWillEnterForeground:)
                                                       name:UIApplicationWillEnterForegroundNotification
                                                     object:[UIApplication sharedApplication]];
        
    }
    return self;
}

-(void)registerProvider:(id<cdaAnalyticsDelegate>)tracker 
{
    if (!trackers)
        trackers = [[NSMutableArray alloc] init];
    [trackers addObject:tracker];
    if( [tracker respondsToSelector:@selector(startTracker)] )
       [tracker startTracker];
    if ([tracker respondsToSelector:@selector(trackPage:)])
        [tracker trackPage:@"/app_entry_point"];
}

-(void)registerProvider:(id<cdaAnalyticsDelegate>)tracker setSessionReportsOnCloseEnabled:(BOOL)reportOnClose
{
    [self registerProvider:tracker];
    if ([tracker respondsToSelector:@selector(setSessionReportsOnCloseEnabled:)])
        [tracker setSessionReportsOnCloseEnabled:reportOnClose];
}

-(void)trackPage:(NSString*)pageName
{
    for(id<cdaAnalyticsDelegate> tracker in trackers)
        [tracker trackPage:pageName];
        
}

-(void)trackEvent:(NSString *)eventName
{
    for(id<cdaAnalyticsDelegate> track in trackers)
    {
        [track trackEvent:eventName inCategory:@"undefined category" withLabel:@"events" andValue:-1];
    }
}

-(void)trackEvent:(NSString *)eventName inCategory:(NSString*)categoryName withLabel:(NSString*)labelName andValue:(int)value
{
    for(id<cdaAnalyticsDelegate> track in trackers)
        [track trackEvent:eventName inCategory:categoryName withLabel:labelName andValue:value];
}

-(void)trackEvent:(NSString *)eventName timed:(BOOL)isEventTimed
{
    if (!isEventTimed)
    {
        [self trackEvent:eventName];
        return;
    }
    if (!timers)
        timers = [[NSMutableDictionary alloc] init];
    
    NSDictionary* event = [[[NSDictionary alloc] initWithObjectsAndKeys:eventName, @"eventName", @"undefined category", @"categoryName", @"timed events", @"labelName", [NSDate date], @"startTime", nil ] autorelease];
    [timers setValue:event forKey:eventName];
}

-(void)trackEvent:(NSString *)eventName inCategory:(NSString*)categoryName withLabel:(NSString*)labelName timed:(BOOL)isEventTimed
{
    if (!isEventTimed)
    {
        [self trackEvent:eventName inCategory:categoryName withLabel:labelName andValue:-1];
        return;
    }

    NSDictionary* event = [[[NSDictionary alloc] initWithObjectsAndKeys:eventName, @"eventName", categoryName, @"categoryName", labelName, @"labelName", [NSDate date], @"startTime", nil ] autorelease];
    if (!timers)
        timers = [[NSMutableDictionary alloc] init];
    [timers setValue:event forKey:eventName];
}

-(void)endTimedEvent:(NSString *)eventName
{
    if (timers)
    {
        NSDictionary* event = [timers objectForKey:eventName];
        if (event)
        {
            NSDate *startTime = [event objectForKey:@"startTime"];
            NSTimeInterval duration = fabs([startTime timeIntervalSinceNow]);
            [self trackEvent:[event objectForKey:@"eventName"] inCategory:[event objectForKey:@"categoryName"] withLabel:[event objectForKey:@"labelName"] andValue:(int)duration];
            [timers removeObjectForKey:eventName];
        }
    }
}

-(void)setCustomVariableAtIndex:(NSUInteger)index name:(NSString *)name value:(NSString *)value scope:(GANCVScope)scope
{
    for(id<cdaAnalyticsDelegate> t in trackers)
    {
        if( [t respondsToSelector:@selector(setCustomVariableAtIndex:name:value:scope:)] )
            [t setCustomVariableAtIndex:index name:name value:value scope:scope];
    }
}

-(void)addTransaction:(NSString *)orderID totalPrice:(double)totalPrice storeName:(NSString *)storeName
{
    for(id<cdaAnalyticsDelegate> t in trackers)
    {
        if( [t respondsToSelector:@selector(setCustomVariableAtIndex:name:value:scope:)] )
            [t addTransaction:orderID totalPrice:totalPrice storeName:storeName];
    }
}

-(void)addItem:(NSString *)orderId itemSKU:(NSString*)item itemName:(NSString*)itemName itemPrice:(double)price
{
    for(id<cdaAnalyticsDelegate> t in trackers)
    {
        if( [t respondsToSelector:@selector(setCustomVariableAtIndex:name:value:scope:)] )
            [t addItem:orderId itemSKU:item itemName:itemName itemPrice:price];
    }
}

-(void)trackTransactions
{
    for(id<cdaAnalyticsDelegate> t in trackers)
    {
        if( [t respondsToSelector:@selector(trackTransactions)] )
            [t trackTransactions];
    }
}

-(void)clearTransactions
{
    for(id<cdaAnalyticsDelegate> t in trackers)
    {
        if( [t respondsToSelector:@selector(clearTransactions)] )
            [t clearTransactions];
    }
}

-(void)logError:(NSString*)error withMessage:(NSString*)msg andException:(NSException*)exception
{
    for(id<cdaAnalyticsDelegate> t in trackers)
        if( [t respondsToSelector:@selector(logError:withMessage:andException:)] )
            [t logError: error withMessage:msg andException:exception];
}

-(void)stopTracker
{
    for(id<cdaAnalyticsDelegate> t in trackers)
        if( [t respondsToSelector:@selector(stopTracker)] )
            [t stopTracker];
}

-(void)applicationWillEnterForeground:(NSNotification *)notification
{
    for(id<cdaAnalyticsDelegate> t in trackers)
        if( [t respondsToSelector:@selector(applicationWillEnterForeground)] )
            [t applicationWillEnterForeground];
}

-(void)applicationDidEnterBackgroundNotification:(NSNotification *)notification
{
    [self stopTracker];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [trackers release];
    [timers release];
    [super dealloc];
}

@end
