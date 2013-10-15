//
//  cdaGlobalFunctions.m
//  mscocktailsipad
//
//  Created by Radif Sharafullin on 4/18/11.
//  Copyright 2011 Callaway Digital Arts. All rights reserved.
//


/*!
 *  Caveats:
 *
 *  This file is included into each framework. The changes you make will apply across all the frameworks and possibly revisions of these frameworks. Consider TWICE before changing anything here!
 *  
 *  This file is marked as a private file of each library to avoid name clashes.
 *
 */

#import "cdaGlobalFunctions.h"
#include <mach/mach_time.h>


UIColor* UIColorFromRGBAString(NSString * rgbaString){
    NSArray *elements=[rgbaString componentsSeparatedByString:@","];
    float components[4];
    for (int i=0;i<4;++i) {
        components[i]=0.0f;
    }
    int counter=0;
    for (NSString *element in elements) {
        components[counter]= [element floatValue];
        counter++;
    }
    return [UIColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:components[3]];
}

NSString * cdaPath(NSString *inPath){
    return [cdaGlobalFunctions cdaPath:inPath];
}
@implementation cdaGlobalFunctions



#pragma mark filesystem
// Gets the full bundle path of an item
+ (NSString *)getFullPath:(NSString *)inPath
{
	return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:inPath];
}
+(NSString *)documentsPath{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+(NSString *)cachesPath{
	return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}
+(NSString *)libraryPath{
	return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+(NSString *)cdaPath:(NSString *)inPath{
	//bundle
	inPath=[inPath stringByReplacingOccurrencesOfString:@"$(BUNDLE)" withString:[[NSBundle mainBundle] resourcePath]];
	//documents
	inPath=[inPath stringByReplacingOccurrencesOfString:@"$(DOCUMENTS)" withString:[cdaGlobalFunctions documentsPath] ];
	//cache
	inPath=[inPath stringByReplacingOccurrencesOfString:@"$(CACHES)" withString:[cdaGlobalFunctions cachesPath]];
    //Library
	inPath=[inPath stringByReplacingOccurrencesOfString:@"$(LIBRARY)" withString:[cdaGlobalFunctions libraryPath]];
    //Downloads
    inPath=[inPath stringByReplacingOccurrencesOfString:@"$(DOWNLOADS)" withString:[[cdaGlobalFunctions libraryPath] stringByAppendingPathComponent:@"cdaDownloads"]];
	return inPath;
}



// Gets the document path of an item. If inCreateDirectories is YES, it will create intermediate
// directories that don't exist.
+ (NSString *)getDocumentPath:(NSString *)inPath createDirectories:(BOOL)inCreateDirectories{
	NSString *tmpString = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:inPath];
	NSString *directoryPath = [tmpString stringByDeletingLastPathComponent];
	if (inCreateDirectories && ![[NSFileManager defaultManager] fileExistsAtPath:directoryPath])
		[[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
	
	return tmpString;
}


// Gets the document path of an item. If inCreateDirectories is YES, it will create intermediate
// directories that don't exist.
+ (NSString *)getDocumentPath:(NSString *)inPath createItIfDoesntExist:(BOOL)inCreateDirectories{
	NSString *tmpString = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:inPath];
	if (inCreateDirectories && ![[NSFileManager defaultManager] fileExistsAtPath:tmpString])
		[[NSFileManager defaultManager] createDirectoryAtPath:tmpString withIntermediateDirectories:YES attributes:nil error:nil];
	
	return tmpString;
}

+(NSString *)uniqueTimestampID{
	srandom(time(NULL));//ForID
	NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
	[dateFormatter setDateFormat:@"a-dd-yyyy-MM-hh-ss-mm"];
	NSString *dateString=[NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:[NSDate date]]];
	[dateFormatter release];
	return 	[NSString stringWithFormat:@"%@-%llu-%i%i%i%i",dateString,mach_absolute_time(),random()%10000,random()%10000,random()%10000,random()%10000];
	
}

@end
