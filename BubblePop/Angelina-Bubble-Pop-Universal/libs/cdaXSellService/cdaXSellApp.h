//
//  cdaXSellApp.h
//  cdaXSellServiceSample
//
//  Created by FRANCISCO CANDALIJA on 7/2/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const cdaXSellServiceErrorDomain;

typedef enum {
    cdaXSellDeviceTypeiPad=1,
    cdaXSellDeviceTypeiPhone=2,	
    cdaXSellDeviceTypeUniversal=3,
    cdaXSellDeviceTypeAll=4
} cdaXSellAppTargetPlatform;

enum cdaXSellServiceErrorCode {
    DATA_PARSING_ERROR = 1,
    NO_CACHED_DATA_AVAILABLE = 2,
    COULD_NOT_WRITE_ERROR = 3,
    OFFLINE_ICON_NOT_PROVIDED = 4,
    ILLEGAL_ICON_SIZE = 5,
    NO_OFFLINE_XSELL_DATA_PROVIDED = 6
};

// Keys to index iconBySize dictionary in cdaXSellApp object
extern NSString const*	IPHONE_ICON_SIZE;
extern NSString const*	IPHONE_RETINA_ICON_SIZE;
extern NSString const*	IPAD_ICON_SIZE;
extern NSString const*	IPAD_HD_ICON_SIZE;

extern NSString* cdaXSellIconDownloadedNotification;

@interface cdaXSellApp : NSObject {
    NSString* appKey;
    NSString* name;
    NSString* shortDescription;
    NSArray* appLinks;
    NSDictionary* iconBySize;
    cdaXSellAppTargetPlatform targetPlatform;

    NSMutableDictionary* cachedIconFileBySize;
}
- (id)initFromDictionary: (NSDictionary*) dict;
- (NSString*) iconImageFileNameForSize: (NSString const*) size;
-(CGSize) iconDimensions: (NSString const*) size;
-(BOOL) compatibleWithPlatform:(cdaXSellAppTargetPlatform) platform;

@property (nonatomic, retain) NSString* appKey;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* shortDescription;
@property (nonatomic, retain) NSArray* appLinks;
@property (nonatomic, retain) NSDictionary* iconBySize;
@property (nonatomic, assign) cdaXSellAppTargetPlatform targetPlatform;

@end