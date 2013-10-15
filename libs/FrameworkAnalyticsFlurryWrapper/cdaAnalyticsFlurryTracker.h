//
//  cdaAnalyticsFlurryTracker.h
//
//  Created by zhen tan on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cdaAnalytics.h"

@interface cdaAnalyticsFlurryTracker : NSObject <cdaAnalyticsDelegate>
@property (nonatomic, retain) NSString* apiKey;
-(id) initWithAPIKey: (NSString*) key;
+(cdaAnalyticsFlurryTracker*) trackerWithAPIKey:(NSString*) key;
-(void)trackPage:(NSString*)pageName;
-(void)trackEvent:(NSString *)eventName inCategory:(NSString*)categoryName withLabel:(NSString*)labelName andValue:(int)value;
-(void)startTracker;
-(void)setSessionReportsOnCloseEnabled:(BOOL)reportOnClose;
@end
