//
//  cdaXSellService.h
//  cdaXSellServiceSample
//
//  Created by FRANCISCO CANDALIJA on 7/1/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cdaXSellApp.h"

extern NSString *const cdaXSellServiceErrorDomain;


@interface cdaXSellService : NSObject 

+(cdaXSellService*)sharedInstance;

/*
 * onSuccess block will receive an array of cdaXSellApp objects with information about
 * each of the x-sell apps configured for the app with the key passed
 * as an argument.
 */
-(void) xsellAppsForAppWithKey: (NSString*) appKey onSuccess:(void (^)(NSArray* xsellApps)) successBlock onError: (void (^)(NSError* error)) errorBlock;
-(void) xsellAppsForAppWithKey: (NSString*) appKey  filterByPlatform:(cdaXSellAppTargetPlatform)platform onSuccess:(void (^)(NSArray* xsellApps)) successBlock onError: (void (^)(NSError* error)) errorBlock;

@end
