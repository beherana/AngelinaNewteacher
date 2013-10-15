//
//  ConstantContactProperties.h
//  KeepInTouchWidgets
//
//  Created by FRANCISCO CANDALIJA on 5/25/11.
//  Copyright 2011 Callaway Digital Arts, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface cdaConstantContactProperties : NSObject {
    NSString* url;
    NSString* customerId;
    NSString* createContactContentyType;
    NSString* apiKey;
    NSString* apiSecret;
    
}


@property (nonatomic,retain) NSString* url;
@property (nonatomic,retain) NSString* customerId;
@property (nonatomic,retain) NSString* createContactContentyType;
@property (nonatomic,retain) NSString* apiKey;
@property (nonatomic,retain) NSString* apiSecret;

@end
