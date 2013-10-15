//
//  cdaXSellAppSection.h
//  cdaXSellServiceSample
//
//  Created by FRANCISCO CANDALIJA on 8/22/11.
//  Copyright (c) 2011 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface cdaXSellAppSection : NSObject {
    NSString* name;
    NSMutableArray* apps;
}

@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSMutableArray* apps;

@end