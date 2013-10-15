    //
//  cdaXSellService.m
//  cdaXSellServiceSample
//
//  Created by FRANCISCO CANDALIJA on 7/1/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import "cdaXSellService.h"
#import "cdaCURLOperation.h"
#import "NSDictionary_JSONExtensions.h"
#import "cdaXSellApp.h"
#import "cdaXSellAppLink.h"
#import "cdaXSellAppSection.h"

#define CDA_CDN_BASE_URL @"http://cdn-media.callaway.com"
//#define CDA_CDN_BASE_URL @"http://127.0.0.1"


@implementation cdaXSellService

+(cdaXSellService*)sharedInstance {
    static cdaXSellService* instance = nil;
    if( instance == nil ) {
        instance = [[cdaXSellService alloc] init];
    }
    return instance;
}

- (void)dealloc {
    [super dealloc];
}

-(NSString*) cacheFileNameForKey: (NSString*) appKey {
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [path stringByAppendingPathComponent:[NSString stringWithFormat:@".%@.json", appKey]];
}


-(NSArray*) appsFromCacheFileForKey: (NSString*)appKey compatibleWithPlatform:(cdaXSellAppTargetPlatform)targetPlatform onError: (NSError**) error {
    
    NSLog(@"Reading from file: %@", [self cacheFileNameForKey:appKey]);
    NSData* data = [NSData dataWithContentsOfFile:[self cacheFileNameForKey:appKey]];
    if( data == nil ) {
        *error = [NSError errorWithDomain:cdaXSellServiceErrorDomain code:NO_CACHED_DATA_AVAILABLE userInfo:nil];
        return nil;
    }
    NSMutableDictionary* sectionByName = [NSMutableDictionary dictionary];
    NSError *outError;
    NSDictionary* dict = [NSDictionary dictionaryWithJSONData:data error:&outError];
    if( dict == NULL ) {
        *error = [NSError errorWithDomain:cdaXSellServiceErrorDomain code:DATA_PARSING_ERROR userInfo:[NSDictionary dictionaryWithObjectsAndKeys:outError, @"cause", nil]];
        return nil;
    }
    
    NSArray* dictApps = [dict objectForKey:@"crossSells"];
    for( NSDictionary* dictApp in dictApps ) {                
                                        
        // Get the App object from dict
        cdaXSellApp* app = [[cdaXSellApp alloc] initFromDictionary:dictApp];        
        if( [app compatibleWithPlatform:targetPlatform] ) {
            
            // Transform app links into objects
            NSMutableArray* appLinks = [NSMutableArray array];
            for (NSDictionary* appLinkDict in [dictApp objectForKey:@"appLinks"] ) {
                
                cdaXSellAppLink* appLink = [[cdaXSellAppLink alloc] initFromDictionary: appLinkDict];                
                [appLinks addObject:appLink];                
                [appLink release];
                
            }                                
            app.appLinks = appLinks;    
            
            // Get the section
            NSString* sectionName = [dictApp objectForKey:@"section"];
            cdaXSellAppSection *section = [sectionByName objectForKey:sectionName];
            if(section == nil ) {
                section = [[[cdaXSellAppSection alloc] init] autorelease];
                section.name = sectionName;
                [sectionByName setObject:section forKey:sectionName];
            }
            
            // Add the app to the section
            if( section.apps == nil ) {
                section.apps = [NSMutableArray array];
            }                
            
            [section.apps addObject:app];

            [app release];
        }
    }
    
    return [sectionByName allValues];
}

-(NSString *) offlineJsonPathInBundleForAppKey:(NSString*) appKey {
   return [[NSBundle mainBundle] pathForResource:appKey ofType:@"json"];
}


-(BOOL) createCacheIfNotExistsForKey: (NSString*) appKey {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if( ![fileManager fileExistsAtPath:[self cacheFileNameForKey:appKey]] ) {
        // Copy file from bundle
        NSString* offlineJsonPath = [self offlineJsonPathInBundleForAppKey:appKey];
        if( [fileManager fileExistsAtPath:offlineJsonPath] ) {
            NSError *error;
            if( ![fileManager copyItemAtPath:offlineJsonPath toPath:[self cacheFileNameForKey:appKey] error:&error] ) {
                NSLog(@"Error copying offline json file from bundle to cache: %@", error);
                return FALSE;
            }
        } else {
            return FALSE;
        }
    }
    return TRUE;
}

-(cdaXSellAppTargetPlatform) model2Platform:(NSString*) model {
    cdaXSellAppTargetPlatform platform;
    if( [model rangeOfString:@"iPhone"].length > 0  || [model rangeOfString:@"iPod"].length > 0 ) {
        platform = cdaXSellDeviceTypeiPhone;
    } else if ( [model rangeOfString:@"iPad"].length > 0 ) {
        platform= cdaXSellDeviceTypeiPad;
    } else {
        platform= cdaXSellDeviceTypeAll;
    }
    return platform;
}

-(void) xsellAppsForAppWithKey: (NSString*) appKey onSuccess:(void (^)(NSArray* xsellApps)) successBlock onError:(void (^)(NSError* error)) errorBlock {    
    UIDevice* device = [UIDevice currentDevice];
    cdaXSellAppTargetPlatform platform = [self model2Platform:device.model];
    [self xsellAppsForAppWithKey:appKey filterByPlatform:platform onSuccess:successBlock onError:errorBlock];
}

-(void) xsellAppsForAppWithKey: (NSString*) appKey  filterByPlatform:(cdaXSellAppTargetPlatform)platform onSuccess:(void (^)(NSArray* xsellApps)) successBlock onError: (void (^)(NSError* error)) errorBlock {    
    // Try to refresh from CDN
    NSURL* url = [NSURL URLWithString: [[CDA_CDN_BASE_URL stringByAppendingPathComponent:appKey] stringByAppendingPathExtension:@"json"]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    cdaCURLOperation* op = [[cdaCURLOperation alloc] initWithRequest:request];
    op.successBlock = ^{
        // Persist file in library directory
        [op.data writeToFile:[self cacheFileNameForKey:appKey] atomically:true];                        
        NSError* error;
        NSArray * apps = [self appsFromCacheFileForKey:appKey compatibleWithPlatform:platform onError:&error];        
        if( apps == nil ) {
            errorBlock(error);            
        } else {
            successBlock(apps);
        }
    };
    op.failureBlock = ^(NSError* error) {
        NSLog(@"Download error: %@", error);        
        // Check if there's a cached file
        if( [self createCacheIfNotExistsForKey:appKey] ) {
            // Try to return fro cache
            NSError* error;
            NSArray * apps = [self appsFromCacheFileForKey:appKey compatibleWithPlatform:platform onError:&error];        
            if( apps == nil ) {
                errorBlock(error);
            } else {
                successBlock(apps);
            }
        } else {
            errorBlock([NSError errorWithDomain:cdaXSellServiceErrorDomain code:NO_OFFLINE_XSELL_DATA_PROVIDED userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"inital data", [NSString stringWithFormat:@"No initial data provided in %@ resource in the main bundle", [self offlineJsonPathInBundleForAppKey:appKey]], nil]]);
        }
    };
    [op start];    
    [op release];
}


@end
