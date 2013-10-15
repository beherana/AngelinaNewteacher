//
//  cdaPropertyUtils.h
//  cdaXSellServiceSample
//
//  Created by FRANCISCO CANDALIJA on 7/6/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface cdaPropertyUtils : NSObject

+(cdaPropertyUtils*) sharedInstance;
/*
 * Method that will extract the property names of the class and will invoke a block of code
 * with the name of the property as a parameter.
 */
-(void) iterateThroughPropertiesOfClass: (Class) clazz executingBlock: (void(^)(NSString*))blockToExecute;
                                                                                
@end
