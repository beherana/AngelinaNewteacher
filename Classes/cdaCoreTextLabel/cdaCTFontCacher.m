//
//  cdaCTFontCacher.m
//  textExample
//
//  Created by Radif Sharafullin on 2/3/11.
//  Copyright 2011 Callaway Digital Arts. All rights reserved.
//

#import "cdaCTFontCacher.h"
#import "cdaGlobalFunctions.h"

static cdaCTFontCacher *sharedCacher;

@interface cdaCTFontCacher (topSecret)
-(NSString *)keyforFontName:(NSString *)fontName ofType:(NSString *)type size:(float)size;
@end


@interface cdaCTFontHolder : NSObject
{
	CTFontRef font;
}
+(id)fontHolderWithFont:(CTFontRef)ft;
@property (nonatomic, readwrite) CTFontRef font;

@end
@implementation cdaCTFontHolder
@synthesize font;
+(id)fontHolderWithFont:(CTFontRef)ft{
	cdaCTFontHolder *holder=[[[self class] new] autorelease];
	holder.font=ft;
	return holder;
}
-(void)setFont:(CTFontRef)ft{
	if (!ft) return;
		CDA_RELEASE_CF_SAFELY(font);
		font=ft;
		CFRetain(font);
	
	
}
-(void)dealloc{
	CDA_LOG_METHOD_NAME;
	CDA_RELEASE_CF_SAFELY(font);
	[super dealloc];
}

@end



@implementation cdaCTFontCacher
@synthesize fonts;

#pragma mark singleton piping
+(id)sharedCacher{
	if (sharedCacher) return sharedCacher;
	
	sharedCacher=[[self new] autorelease];
	return sharedCacher;
}
+(void)cacherRetain{
	[[[self class]sharedCacher] retain];
}
+(void)cacherRelease{
	if (sharedCacher) {
		if ([sharedCacher retainCount]>0) {
			if ([sharedCacher retainCount]==1) {
				[sharedCacher release];
				sharedCacher=nil;
			}else {
				[sharedCacher release];
			}
		}
	}
}

#pragma mark Alloc
-(id)init{
	self=[super init];
	if (self) {
		CDA_LOG_METHOD_NAME;
		[self drainFontCache];//creates an instance of the dictionary
		
	}
	return self;
}
-(void)dealloc{
	CDA_LOG_METHOD_NAME;
	self.fonts=nil;
	[super dealloc];
}

#pragma mark Methods
-(void)unloadFontName:(NSString *)fontName ofType:(NSString *)type size:(float)size{
	[[self fonts] removeObjectForKey:[self keyforFontName:fontName ofType:type size:size]];
}
-(void)unloadAllFonts{
	[self drainFontCache];
}
-(void)drainFontCache{
	self.fonts=[NSMutableDictionary dictionary];
}
- (CTFontRef)fontWithName:(NSString *)fontName ofType:(NSString *)type size:(float)size{
	
	NSString *fontKey=[self keyforFontName:fontName ofType:type size:size];
	if ([self.fonts objectForKey:fontKey]) {
		//cdaLog(@"already cached, returning from cache: %@",fontKey);
		cdaCTFontHolder *ftHolder=[self.fonts objectForKey:fontKey];
		return [ftHolder font];
	}
	
	
	CTFontRef retFont;
	if ([[type lowercaseString] isEqualToString:@"system"]) {
		
		retFont=CTFontCreateWithName((CFStringRef)fontName, size, NULL);
	}else {
		NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionary];
		[fontAttributes setValue:[NSNumber numberWithFloat:size] forKey:(id)kCTFontSizeAttribute];		
		retFont=[self fontWithName:fontName ofType:type attributes:fontAttributes];
	}


	[self.fonts setObject:[cdaCTFontHolder fontHolderWithFont:retFont] forKey:fontKey];
	cdaLog(@"caching font: %@",fontKey);
	CFRelease(retFont);
	
	
	return retFont;
}

- (CTFontRef)fontWithName:(NSString *)fontName ofType:(NSString *)type attributes:(NSDictionary *)attributes {
	NSString *fontPath = [[NSBundle mainBundle] pathForResource:fontName ofType:type];
	
	if (!fontPath) return nil;
	
	NSData *data = [[NSData alloc] initWithContentsOfFile:fontPath];
	CGDataProviderRef fontProvider = CGDataProviderCreateWithCFData((CFDataRef)data);
	
	
	CGFontRef cgFont = CGFontCreateWithDataProvider(fontProvider);
	
	CTFontDescriptorRef fontDescriptor = CTFontDescriptorCreateWithAttributes((CFDictionaryRef)attributes);
	CTFontRef font = CTFontCreateWithGraphicsFont(cgFont, 0, NULL, fontDescriptor);
	
	CFRelease(fontDescriptor);
	CGFontRelease(cgFont);
	CGDataProviderRelease(fontProvider);		
	[data release];	
	return font;
}
#pragma mark Key Generator
-(NSString *)keyforFontName:(NSString *)fontName ofType:(NSString *)type size:(float)size{
	return [NSString stringWithFormat:@"%@.%@-%f",fontName,type,size];
}
@end
