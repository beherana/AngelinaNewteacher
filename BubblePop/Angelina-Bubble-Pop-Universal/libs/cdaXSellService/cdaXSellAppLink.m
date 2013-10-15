//
//  cdaXSellAppLink.m
//  cdaXSellServiceSample
//
//  Created by FRANCISCO CANDALIJA on 8/22/11.
//  Copyright (c) 2011 N/A. All rights reserved.
//

#import "cdaXSellAppLink.h"
#import "cdaPropertyUtils.h"

@implementation cdaXSellAppLink
@synthesize type;
@synthesize URL;
@synthesize description;


- (id)initFromDictionary: (NSDictionary*) dict {
    self = [super init];
    if( self ) {
        [[cdaPropertyUtils sharedInstance] iterateThroughPropertiesOfClass: [self class]executingBlock:^(NSString* propName) {
            [self setValue:[dict objectForKey:propName] forKey:propName];            
        }];
    }
    return self;
}

@end
