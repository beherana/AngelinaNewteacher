//
//  cdaAnalyticsGoogleTracker.m
//
//  Created by zhen tan on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cdaAnalyticsGoogleTracker.h"

// Dispatch period in seconds
static const NSInteger kGANDispatchPeriodSec = 10;

@implementation cdaAnalyticsGoogleTracker
@synthesize apiKey;

+(cdaAnalyticsGoogleTracker*) trackerWithAPIKey:(NSString*) key {
    return [[[cdaAnalyticsGoogleTracker alloc] initWithAPIKey:key] autorelease];
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
    [[GANTracker sharedTracker] startTrackerWithAccountID:self.apiKey
                                           dispatchPeriod:kGANDispatchPeriodSec
                                                 delegate:nil];
    NSError *error1 = nil;
    if(![[GANTracker sharedTracker] setCustomVariableAtIndex:1
                                                        name:@"model"
                                                       value:[[UIDevice currentDevice] localizedModel]
                                                       scope:kGANVisitorScope
                                                   withError:&error1]){
        NSLog(@"GA Custom variable - model error: %@", error1);
    }
    NSError *error2 = nil;
    if(![[GANTracker sharedTracker] setCustomVariableAtIndex:2
                                                        name:[[UIDevice currentDevice] systemName]
                                                       value:[[UIDevice currentDevice] systemVersion]
                                                       scope:kGANVisitorScope
                                                   withError:&error2]){
        NSLog(@"GA Custom variable - systemName error: %@", error2);
    }
}

-(void)stopTracker
{
    [[GANTracker sharedTracker] stopTracker];
}

-(void)applicationWillEnterForeground:(NSNotification *)notification
{
    [self startTracker];
}

-(void)trackPage:(NSString*)pageName
{
    NSError *error = nil;
    if (![[GANTracker sharedTracker] trackPageview:pageName withError:&error])
    {
        NSLog(@"error in trackPageview: %@", error);
    }
}

-(void)trackEvent:(NSString *)eventName inCategory:(NSString*)categoryName withLabel:(NSString*)labelName andValue:(int)value
{
    NSError *error = nil;
    if (![[GANTracker sharedTracker] trackEvent:categoryName
                                         action:eventName
                                          label:labelName
                                          value:value
                                      withError:&error])
    {
        NSLog(@"error in trackEvent: %@", error);
    }
}

-(void)setCustomVariableAtIndex:(NSUInteger)index name:(NSString *)name value:(NSString *)value scope:(GANCVScope)scope
{
    if (index < 1 || index > 5)
        return;
    else 
    {
        NSError *error = nil;
        if(![[GANTracker sharedTracker] setCustomVariableAtIndex:index
                                                            name:name
                                                           value:value
                                                           scope:scope
                                                       withError:&error])
        {
            NSLog(@"error in setCustomVariableAtIndex: %@", error);
        }
    }
}

-(void)addTransaction:(NSString *)orderID totalPrice:(double)totalPrice storeName:(NSString *)storeName
{
    NSError *error = nil;
    [[GANTracker sharedTracker] addTransaction:orderID
                                    totalPrice:totalPrice
                                     storeName:storeName
                                      totalTax:0
                                  shippingCost:0
                                     withError:&error];
    if (error) {
        // Handle error
        NSLog(@"error in addTransaction: %@", error);
    }
}

-(void)addItem:(NSString *)orderId itemSKU:(NSString*)item itemName:(NSString *)itemName itemPrice:(double)price
{
    NSError *error = nil;
    [[GANTracker sharedTracker] addItem:orderId
                                itemSKU:item
                              itemPrice:price
                              itemCount:1
                              itemName:itemName
                           itemCategory:@"in app purchase"
                              withError:&error];
    if (error) {
        // Handle error
        NSLog(@"error in addTransaction: %@", error);
    }
}

-(void)trackTransactions
{
    NSError *error = nil;
    [[GANTracker sharedTracker] trackTransactions:&error];
}

-(void)clearTransactions
{
    NSError *error = nil;
    [[GANTracker sharedTracker] clearTransactions:&error];
    
}

-(void)logError:(NSString*)error withMessage:(NSString*)msg andException:(NSException*)exception
{
    //might want to log an event here?
}


@end
