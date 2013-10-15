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
#import <mach/mach.h>
#include <mach/mach_time.h>
#import <mach/mach_host.h>
#import <QuartzCore/CALayer.h>
#import <QuartzCore/QuartzCore.h>



UIColor* UIColorFromRGBAString(NSString * rgbaString){
    NSArray *elements=[rgbaString componentsSeparatedByString:@","];
    assert([elements count] == 4);
    float r = [[elements objectAtIndex:0] floatValue];
    float g = [[elements objectAtIndex:1] floatValue];
    float b = [[elements objectAtIndex:2] floatValue];
    float a = [[elements objectAtIndex:3] floatValue];
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

NSString * cdaPath(NSString *inPath){
    return [cdaGlobalFunctions cdaPath:inPath];
}
@implementation cdaGlobalFunctions
//TODO: this class is yet to be expanded

#pragma mark memory
+(natural_t)getFreeMemory {
	mach_port_t host_port;
	mach_msg_type_number_t host_size;
	vm_size_t pagesize;
	host_port = mach_host_self();
	host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
	host_page_size(host_port, &pagesize);
	vm_statistics_data_t vm_stat;
	if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
		cdaLog(@"Failed to fetch vm statistics");
		return 0;
	}
	/* Stats in bytes */
	natural_t mem_free = vm_stat.free_count * pagesize;
	return mem_free;
}
+(void)freeMemory:(natural_t)freemem{
	size_t size = freemem - 2048;
	void *allocation = malloc(freemem - 2048);
	bzero(allocation, size);
	free(allocation);
}
+(natural_t)freeUnusedMemory{
    natural_t freemem = [self getFreeMemory];
	[self freeMemory:freemem];
	freemem=freemem-[self getFreeMemory];
	return freemem;
}
+ (double)availableMemory {
	vm_statistics_data_t vmStats;
	mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
	kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
	
	if(kernReturn != KERN_SUCCESS) {
		return NSNotFound;
	}
	
	return ((vm_page_size * vmStats.free_count) / 1024.0) / 1024.0;
}
#pragma mark DiskSpace
+(NSString *)gigabytesFromBytes:(double)bytes {
	double kilobytes = bytes/1024.0;
	double megabytes = kilobytes/1024.0;
	double gigabytes = megabytes/1024.0;
	return [NSString stringWithFormat:@"%.2f",gigabytes];
}
+(NSString *)megabytesFromBytes:(double)bytes {
	double kilobytes = bytes/1024.0;
	double megabytes = kilobytes/1024.0;
	return [NSString stringWithFormat:@"%.2f",megabytes];
}

+(double)totalSpace {  
    double bytes = 0.0f;  
    NSError *error = nil;  
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:cdaPath(@"$DOCUMENTS") error: &error];  
    
    if (dictionary) {  
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];  
        bytes = [fileSystemSizeInBytes doubleValue];  
    } else {  
        cdaLog(@"Error Obtaining File System Info: Domain = %@, Code = %@", [error domain], [error code]);  
        return NSNotFound;
    }  
	
    return bytes;
}

+(double)takenSpace {  
	double bytes = ([self totalSpace])-([self freeSpace]);
    return bytes;
}

+(double)freeSpace {  
	double bytes = 0.0f;  
    NSError *error = nil;  
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:cdaPath(@"$DOCUMENTS") error: &error];  
	
    if (dictionary) {  
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemFreeSize];  
        bytes = [fileSystemSizeInBytes doubleValue];  
    } else {  
        cdaLog(@"Error Obtaining File System Info: Domain = %@, Code = %@", [error domain], [error code]);  
        return NSNotFound;
    }  
    
    return bytes;
}

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
	inPath=[inPath stringByReplacingOccurrencesOfString:@"$BUNDLE" withString:[[NSBundle mainBundle] resourcePath]];
	//documents
	inPath=[inPath stringByReplacingOccurrencesOfString:@"$DOCUMENTS" withString:[cdaGlobalFunctions documentsPath] ];
	//cache
	inPath=[inPath stringByReplacingOccurrencesOfString:@"$CACHES" withString:[cdaGlobalFunctions cachesPath]];
    //Library
	inPath=[inPath stringByReplacingOccurrencesOfString:@"$LIBRARY" withString:[cdaGlobalFunctions libraryPath]];
    //Downloads
    inPath=[inPath stringByReplacingOccurrencesOfString:@"$DOWNLOADS" withString:[[cdaGlobalFunctions libraryPath] stringByAppendingPathComponent:@"cdaDownloads"]];
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
#pragma mark Photograph the view
+(UIImage *)imageFromView:(UIView *)v{
	UIGraphicsBeginImageContext(v.bounds.size);
	[v.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return img;
}


#pragma mark Image manipulation
+ (UIImage *)scaleAndCropImage:(UIImage *)fullImage toSize:(CGSize)size {
	CGSize imageSize = fullImage.size;
	CGFloat scale = 1.0f;
	CGImageRef subimage = NULL;
	if(imageSize.width > imageSize.height) {
		// image height is smallest
		scale = size.height / imageSize.height;
		CGFloat offsetX = ((scale * imageSize.width - size.width) / 2.0f) / scale;
		CGRect subRect = CGRectMake(offsetX, 0.0f, 
									imageSize.width - (2.0f * offsetX), 
									imageSize.height);
		subimage = CGImageCreateWithImageInRect([fullImage CGImage], subRect);
	} else {
		// image width is smallest
		scale = size.width / imageSize.width;
		CGFloat offsetY = ((scale * imageSize.height - size.height) / 2.0f) / scale;
		CGRect subRect = CGRectMake(0.0f, offsetY, imageSize.width, 
									imageSize.height - (2.0f * offsetY));
		subimage = CGImageCreateWithImageInRect([fullImage CGImage], subRect);
	}
	// scale the image
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(NULL, size.width, 
												 size.height, 8, 0, colorSpace, 
												 kCGImageAlphaPremultipliedFirst); 
	CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
	CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
	CGContextDrawImage(context, rect, subimage);
	CGContextFlush(context);
	// get the scaled image
	CGImageRef scaledImage = CGBitmapContextCreateImage(context);
	CGContextRelease (context);
	CGImageRelease(subimage);
	subimage = NULL;
	subimage = scaledImage;
    UIImage* returnImg=[UIImage imageWithCGImage:subimage];
    CGImageRelease(subimage);
	return returnImg;
}

+ (CALayer *)createGradientFadeLayerMask:(CGRect)frame withTopFade:(CGFloat)topHeight withBottomFade:(CGFloat)bottomHeight
{
    CAGradientLayer *maskLayer = [CAGradientLayer layer];
    
    maskLayer.frame = frame;
    
    CGColorRef outerColor = [UIColor colorWithWhite:1.0 alpha:0.0].CGColor;
    CGColorRef innerColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
    
    maskLayer.colors = [NSArray arrayWithObjects:(id)outerColor, 
                        (id)innerColor, (id)innerColor, (id)outerColor, nil];
    CGFloat top = topHeight / frame.size.height;
    CGFloat bottom = (frame.size.height - bottomHeight) / frame.size.height;
    maskLayer.locations = [NSArray arrayWithObjects:
                           [NSNumber numberWithFloat:0.0], 
                           [NSNumber numberWithFloat:top], 
                           [NSNumber numberWithFloat:bottom], 
                           [NSNumber numberWithFloat:1.0],
                           nil];
    return maskLayer;
}

@end
