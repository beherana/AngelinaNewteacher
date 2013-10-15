//
//  FlurryGameEvent.h
//  Angelina-Bubble-Pop-Universal
//
//  Created by Martin Kamara on 2011-08-31.
//  Copyright 2011 Commind. All rights reserved.
//



@interface FlurryGameEvent : NSObject

+ (void) logEvent:(NSString *) event;
+ (void) logEvent:(NSString *) event withParameters:(NSDictionary *) parameters;
+ (void) logEventPrefixWithMode:(NSString *) event withParameters:parameters timed:(BOOL) timed;
+ (void) logEventPrefixWithMode:(NSString *) event withParameters:(NSDictionary *) parameters;
+ (void) endTimedEventPrefixWithMode:(NSString *) event;


@end
