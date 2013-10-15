//
//  cdaXSellAppLink.h
//  cdaXSellServiceSample
//
//  Created by FRANCISCO CANDALIJA on 8/22/11.
//  Copyright (c) 2011 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    APPSTORE_LINK = 1,
	ITUNES_LINK = 2
} cdaXSellAppLinkType;

@interface cdaXSellAppLink: NSObject {
    
    cdaXSellAppLinkType type;
    NSString* URL;
    NSString* description;
    
}

@property (nonatomic, assign) cdaXSellAppLinkType type;
@property (nonatomic, retain) NSString* URL;
@property (nonatomic, retain) NSString* description;

- (id)initFromDictionary: (NSDictionary*) dict;
@end
