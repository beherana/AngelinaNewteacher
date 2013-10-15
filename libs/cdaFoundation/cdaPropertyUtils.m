//
//  cdaPropertyUtils.m
//  cdaXSellServiceSample
//
//  Created by FRANCISCO CANDALIJA on 7/6/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import "cdaPropertyUtils.h"

@implementation cdaPropertyUtils


+(cdaPropertyUtils*)sharedInstance {
    static cdaPropertyUtils* instance = nil;
    if( instance == nil ) {
        instance = [cdaPropertyUtils new];
    }
    return instance;
}

-(void) iterateThroughPropertiesOfClass: (Class) clazz executingBlock: (void(^)(NSString* property)) blockToRun {
    unsigned int numProperties;
    objc_property_t* properties = class_copyPropertyList(clazz, &numProperties);
    
    for( int i = 0 ; i < numProperties ; i++ ) {
        objc_property_t property = properties[i];
        const char* cPropName = property_getName(property);
        NSString *propName = [NSString stringWithCString:cPropName encoding:NSASCIIStringEncoding];
        blockToRun(propName);        
    }
    free(properties);
    
}



@end
