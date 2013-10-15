//
//  cdaAnalytics.h
//
//  Created by zhen tan on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANTracker.h"

@protocol cdaAnalyticsDelegate <NSObject>

@required
-(void)trackPage:(NSString*)pageName;;
-(void)trackEvent:(NSString *)eventName inCategory:(NSString*)categoryName withLabel:(NSString*)labelName andValue:(int)value;

@optional
-(void)startTracker;
-(void)stopTracker;
-(void)logError:(NSString*)error withMessage:(NSString*)msg andException:(NSException*)exception;
-(void)setCustomVariableAtIndex:(NSUInteger)index name:(NSString *)name value:(NSString *)value scope:(GANCVScope)scope;
-(void)addTransaction:(NSString *)orderID totalPrice:(double)totalPrice storeName:(NSString *)storeName;
-(void)addItem:(NSString *)orderId itemSKU:(NSString*)item itemName:(NSString *)itemName itemPrice:(double)price;
-(void)trackTransactions;
-(void)clearTransactions;
-(void)applicationWillEnterForeground;
-(void)setSessionReportsOnCloseEnabled:(BOOL)reportOnClose;
@end

#if defined DEBUG || defined ENTERPRISE
static NSString* const cdaAnalyticKeyType = @"test";
#else
static NSString* const cdaAnalyticKeyType = @"live";
#endif

@interface cdaAnalytics : NSObject <cdaAnalyticsDelegate> {
    NSMutableArray* trackers;
    NSMutableDictionary*timers;
}

+(cdaAnalytics*) sharedInstance;

//initialize api keys
-(void)registerProvider:(id)tracker;
-(void)registerProvider:(id<cdaAnalyticsDelegate>)tracker setSessionReportsOnCloseEnabled:(BOOL)reportOnClose;

//tracking
-(void)trackPage:(NSString*)pageName;
-(void)trackEvent:(NSString *)eventName;
-(void)trackEvent:(NSString *)eventName inCategory:(NSString*)categoryName withLabel:(NSString*)labelName andValue:(int)value;

-(void)trackEvent:(NSString *)eventName timed:(BOOL)isEventTimed;
-(void)trackEvent:(NSString *)eventName inCategory:(NSString*)categoryName withLabel:(NSString*)labelName timed:(BOOL)isEventTimed;
-(void)endTimedEvent:(NSString *)eventName;

-(void)setCustomVariableAtIndex:(NSUInteger)index name:(NSString *)name value:(NSString *)value scope:(GANCVScope)scope;

-(void)addTransaction:(NSString *)orderID totalPrice:(double)totalPrice storeName:(NSString *)storeName;
-(void)addItem:(NSString *)orderId itemSKU:(NSString*)item itemName:(NSString *)itemName itemPrice:(double)price;
-(void)trackTransactions;
-(void)clearTransactions;

-(void)logError:(NSString*)error withMessage:(NSString*)msg andException:(NSException*)exception;
-(void)stopTracker;

-(void)applicationWillEnterForeground:(NSNotification*)notification;
-(void)applicationDidEnterBackgroundNotification:(NSNotification*)notification;
@end
