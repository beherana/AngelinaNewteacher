//
//  ConstantContactCollectionService.h
//  KeepInTouchWidgets
//
//  Created by FRANCISCO CANDALIJA on 5/25/11.
//  Copyright 2011 Callaway Digital Arts, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cdaContactCollectionService.h"
#import "cdaConstantContactProperties.h"

@interface cdaConstantContactCollectionService : NSObject <cdaContactCollectionService> {
    cdaConstantContactProperties* properties;
}

+(cdaConstantContactCollectionService *)sharedInstance;
+(void)freeSharedInstance;

@property (nonatomic, retain) cdaConstantContactProperties* properties;

@end
