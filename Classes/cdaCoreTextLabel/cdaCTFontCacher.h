//
//  cdaCTFontCacher.h
//  textExample
//
//  Created by Radif Sharafullin on 2/3/11.
//  Copyright 2011 Callaway Digital Arts. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <CoreText/CoreText.h>
#endif


/*!
 *	This is an opaque object, used by cdaCTLabel internally. however, it can be used separately as follows:
 *	[cdaCTFontCacher cacherRetain];
 *	//This will return the font and cache it in ram until cacher is released, you can also call drain fonts in case of memory warning
 *	CTFontRef font=[[cdaCTFontCacher sharedCacher] fontWithName:fontName ofType:fontType size:fontSize];
  *	if you want to use the device font, provide it's name in fontFileName and use @"system" for fontType
 *	use the font
 * 
 *	[cdaCTFontCacher cacherRelease];//relinquish the ownership
 */

@interface cdaCTFontCacher : NSObject {

	NSMutableDictionary *fonts;
}
@property (nonatomic, retain) NSMutableDictionary *fonts;
+(id)sharedCacher;
+(void)cacherRetain;
+(void)cacherRelease;

- (CTFontRef)fontWithName:(NSString *)fontName ofType:(NSString *)type size:(float)size;
- (CTFontRef)fontWithName:(NSString *)fontName ofType:(NSString *)type attributes:(NSDictionary *)attributes;
-(void)unloadFontName:(NSString *)fontName ofType:(NSString *)type size:(float)size;
-(void)unloadAllFonts;
-(void)drainFontCache;
@end
