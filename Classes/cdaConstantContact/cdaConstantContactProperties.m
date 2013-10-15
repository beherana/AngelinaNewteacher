//
//  ConstantContactProperties.m
//  KeepInTouchWidgets
//
//  Created by FRANCISCO CANDALIJA on 5/25/11.
//  Copyright 2011 Callaway Digital Arts, Inc. All rights reserved.
//

#import "cdaConstantContactProperties.h"


@implementation cdaConstantContactProperties
@synthesize apiKey,apiSecret,url,createContactContentyType,customerId;

-(void)dealloc{

    self.apiKey=nil;
    self.apiSecret=nil;
    self.url=nil;
    self.createContactContentyType=nil;
    self.customerId=nil;
    
    [super dealloc];
}
@end
