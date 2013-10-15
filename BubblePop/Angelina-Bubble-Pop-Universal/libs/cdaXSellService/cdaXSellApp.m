//
//  cdaXSellApp.m
//  cdaXSellServiceSample
//
//  Created by FRANCISCO CANDALIJA on 7/2/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import "cdaXSellApp.h"
#import "cdaPropertyUtils.h"
#import "cdaCURLOperation.h"

NSString *const cdaXSellServiceErrorDomain = @"com.callaway.frameworks.cdaXSellServiceErrorDomain";

NSString const*	IPHONE_ICON_SIZE = @"iphone";
NSString const*	IPHONE_RETINA_ICON_SIZE = @"iphone-retina";
NSString const*	IPAD_ICON_SIZE = @"ipad";
NSString const*	IPAD_HD_ICON_SIZE = @"ipad-hd";
NSString* cdaXSellIconDownloadedNotification = @"cdaXSellIconDownloadedNotification";
@implementation cdaXSellApp

@synthesize appKey;
@synthesize name;
@synthesize shortDescription;
@synthesize appLinks;
@synthesize iconBySize;
@synthesize targetPlatform;

- (id)initFromDictionary: (NSDictionary*) dict {
    self = [super init];
    if( self ) {
        [[cdaPropertyUtils sharedInstance] iterateThroughPropertiesOfClass: [self class]executingBlock:^(NSString* propName) {
            [self setValue:[dict objectForKey:propName] forKey:propName];            
        }];
        cachedIconFileBySize = [[NSMutableDictionary dictionary] retain];
    }
    return self;
}

-(void) dealloc {
    [[cdaPropertyUtils sharedInstance] iterateThroughPropertiesOfClass: [self class]executingBlock:^(NSString* propName) {
        if( ![propName isEqualToString:@"targetPlatform"] ) {
            [self setValue:nil forKey:propName];
        }
    }];
    [cachedIconFileBySize release];
    [super dealloc];
}

-(NSString*) description {
    NSMutableArray* result = [NSMutableArray array];
    [[cdaPropertyUtils sharedInstance] iterateThroughPropertiesOfClass: [self class]executingBlock:^(NSString* propName) {
        [result addObject:[NSString stringWithFormat:@"%@: %@", propName, [self valueForKey:propName]]];
    }];
    return [result componentsJoinedByString:@", "];
}


-(NSString*) iconFileNameForAppWithKey: (NSString*) appKey andSize:(NSString const*) size {
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [path stringByAppendingPathComponent:[NSString stringWithFormat:@".%@-%@.png", self.appKey, size]];
}

-(NSString*) offlineIconPathInBundleForAppKey: (NSString*) appKey andSize: (NSString const*)size {
    return [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@-%@", self.appKey, size] ofType:@"png"];
}

-(void) downloadIconURLForSize: (NSString const*) size onSuccess: (void(^)(NSString* localFileName)) successBlock onError: (void(^)(NSError* error)) errorBlock {
    NSString *url = [[self.iconBySize objectForKey:size] objectForKey:@"URL"];

    if( url == nil ) {
        errorBlock([NSError errorWithDomain:cdaXSellServiceErrorDomain code:ILLEGAL_ICON_SIZE userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"size '%@' is not valid", size], @"cause", nil]]);
        return;
    }
    NSURL *iconURL = [NSURL URLWithString:url];
    NSURLRequest* iconRequest = [NSURLRequest requestWithURL:iconURL];
    cdaCURLOperation* op = [[cdaCURLOperation alloc] initWithRequest:iconRequest];
    NSString* iconFileName = [self iconFileNameForAppWithKey:self.appKey andSize:size];
    op.successBlock = ^{
        if( ![op.data writeToFile:iconFileName atomically:true] ) {
            op.failureBlock([NSError errorWithDomain:cdaXSellServiceErrorDomain code:COULD_NOT_WRITE_ERROR userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"could not write %@ file", iconFileName], @"cause", nil]]);
            return;
        } 
        successBlock(iconFileName);                       
    };
    op.failureBlock = ^(NSError* error) {
        NSLog(@"Error downloading icon file: %@", error);                
    };
    [op start];
    [op release];
}


-(NSString*) iconImageFileNameForSize: (NSString const*) size {
    NSString* cachedIconFileName = [cachedIconFileBySize objectForKey:size];
    if( cachedIconFileName == nil ) {        
        // Start retrieving icon from network
        [self downloadIconURLForSize: size onSuccess:^(NSString* localFileName) {
            [cachedIconFileBySize setObject:localFileName forKey:size]; 
            [[NSNotificationCenter defaultCenter] postNotificationName:cdaXSellIconDownloadedNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:size,@"size",nil]];           
        } onError:^(NSError *error) {
            NSLog(@"Error downloading icon for app key: %@ and size: %@, error: %@", self.appKey, size, error);
        }];
        
        cachedIconFileName = [self offlineIconPathInBundleForAppKey:self.appKey andSize:size];
        if( cachedIconFileName == nil ) {
            NSLog(@"No offline icon provisioned for app key: %@ and size: %@", self.appKey, size);
            return nil;
        }
        
    }
    return cachedIconFileName;
}

//return the width and height of the icon
-(CGSize) iconDimensions: (NSString const*) size {
    NSDictionary *icon = [self.iconBySize objectForKey:size];
    CGFloat width  = [[icon objectForKey:@"width"] floatValue];
    CGFloat height = [[icon objectForKey:@"height"] floatValue];
    
    return CGSizeMake(width,height);
}

-(BOOL) compatibleWithPlatform:(cdaXSellAppTargetPlatform) platform {
    if( self.targetPlatform == cdaXSellDeviceTypeUniversal ) {
        return YES;        
    }
    if( platform == cdaXSellDeviceTypeAll  ) {
        return YES;
    }
    return  self.targetPlatform == platform;
}

@end
