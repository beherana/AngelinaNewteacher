//
//  cdaAnalyticsGoogleTracker.h
//
//  Created by zhen tan on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cdaAnalytics.h"

@interface cdaAnalyticsGoogleTracker : NSObject <cdaAnalyticsDelegate>
    
@property (nonatomic, retain) NSString* apiKey;

-(id) initWithAPIKey: (NSString*) key;
+(cdaAnalyticsGoogleTracker*) trackerWithAPIKey:(NSString*) key;
-(void)trackPage:(NSString*)pageName;
-(void)trackEvent:(NSString *)eventName inCategory:(NSString*)categoryName withLabel:(NSString*)labelName andValue:(int)value;
-(void)startTracker;
-(void)stopTracker;
-(void)applicationWillEnterForeground:(NSNotification *)notification;
-(void)setCustomVariableAtIndex:(NSUInteger)index name:(NSString *)name value:(NSString *)value scope:(GANCVScope)scope;
-(void)addTransaction:(NSString *)orderID totalPrice:(double)totalPrice storeName:(NSString *)storeName;
-(void)addItem:(NSString *)orderId itemSKU:(NSString*)item itemName:(NSString *)itemName itemPrice:(double)price;
-(void)trackTransactions;
-(void)clearTransactions;
@end
