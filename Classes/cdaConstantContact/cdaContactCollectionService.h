//
//  ContactCollectionService.h
//  KeepInTouchWidgets
//
//  Created by FRANCISCO CANDALIJA on 5/25/11.
//  Copyright 2011 Callaway Digital Arts, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cdaContact.h"

typedef enum {
    cdaOptInSource_REQUESTED_BY_CDA,
    cdaOptInSource_REQUESTED_BY_CONTACT
} cdaOptInSource;

typedef void (^cdaContactCollectionServiceOperationSuccessHandler)(int statusCode, NSDictionary* headers, NSData* contents);
typedef void (^cdaContactCollectionServiceOperationFailureHandler)(NSError* error);


@protocol cdaContactCollectionService <NSObject>

-(void) collectContact:(cdaContact*) contact addToLists :(NSArray*)listIds withOptInSource:(cdaOptInSource)optInSource onSuccess:(cdaContactCollectionServiceOperationSuccessHandler)onSuccessHandler onFailure: (cdaContactCollectionServiceOperationFailureHandler)onFailureHandler;

@end
