//
//  cdaCTLabel.h
//  
//
//  Created by Radif Sharafullin on 2/3/11.
//  Copyright 2011 Callaway Digital Arts. All rights reserved.
//

//TODO: 
//letterspacing needs to be figured out
//[self._attrString addAttribute:(NSString*)(kCTFontWidthTrait) value:(id)[NSNumber numberWithFloat:0.0f] range:NSMakeRange(0,[stringValue length])];
//[fontAttributes setValue:[NSNumber numberWithFloat:5.f] forKey:(id)kCTFontWidthTrait];		

#import "cdaPortability.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#else
#import <AppKit/AppKit.h>
#endif


#import "cdaCTFontCacher.h"
/*!
* Caution: OSX version is still unstable 
* 
* Example:
* 
* 
* cdaCTLabel *ctLabel = [[cdaCTLabel alloc]initWithFrame:cdaRectMake(0,0,300,40)];
* ctLabel.backgroundColor=[cdaColor cyanColor];
* [ctLabel setStringValue:@"Hello World: second line third line"
* fontFileName:@"ArcherWeb-Light"
* fontType:@"otf"
* fontSize:22
* color:[cdaColor blackColor]
* indent:YES];
* 
* [ctLabel setTextColor:[cdaColor yellowColor] range:NSMakeRange(0, 1)];
* 
* //[ctLabel renderTextFrame];
* //ctLabel.reindentsTextOnResize=YES;
* //[ctLabel setFrame:cdaRectMake(0, 0, 30, 3000)];
* 
* [ctLabel renderTextFrameWithWidth:160 sizeToFit:YES];
* 
* [self.view addSubview:ctLabel];
* 
* 
* 
*/


@interface cdaCTLabel : cdaView {


	CTFrameRef _textFrame;
	NSMutableAttributedString* _attrString;
	CGSize _frameSize;
	CFRange _stringSize;
	int _width;
	int _paddingBottom;
	cdaCTFontCacher *fontCacher;
	float lineHeight;
	BOOL reindentsTextOnResize;
	NSString *text;
#if !TARGET_OS_IPHONE
	NSColor *backgroundColor;
#endif
}
/*!
 one of the "render" methods has to be called in order to render;
 after setting all the attributes, call 
 -(void)renderTextFrameWithWidth:(int)width sizeToFit:(BOOL)sizeToFit;
 OR
 -(void)renderTextFrame;
 OR
 set the "reindentsTextOnResize" property to YES and set the new frame;
 
 you may need to call setNeedsDisplay in rare occasions
 */
@property (nonatomic, assign) BOOL reindentsTextOnResize;
#if !TARGET_OS_IPHONE
@property (nonatomic, assign) NSColor *backgroundColor;
#endif
/*!
 default value is 20. set it before you set the stringValue
 */
@property (nonatomic, assign) float lineHeight;

/*!
 internal object that caches the fonts allowing you to reuse it between the multiple labels. 
 It is initiated when the first label is initiated and released when the last label is released
 */
@property (nonatomic, readonly) cdaCTFontCacher *fontCacher;
/*!
 default value is 0 space added at the bottom
 */
@property (nonatomic) int _paddingBottom;

/*!
 Core Text attribute string. use it for subclassing when adding features
 */
@property (nonatomic,retain) 	NSMutableAttributedString* _attrString;
@property (nonatomic, readonly) CTFrameRef _textFrame;
@property(nonatomic) CGSize _frameSize;
@property (nonatomic, retain) NSString *text;

//these methods use font cacher
/*!
 *	if you want to use the device font, provide it's name in fontFileName and use @"system" for fontType
 */
+(id)labelWithFrame:(cdaRect)frame stringValue:(NSString*)stringValue fontFileName:(NSString *)fontName fontType:(NSString *)fontType fontSize:(float)fontSize color:(cdaColor *)c indent:(BOOL)indent;
/*!
 *	if you want to use the device font, provide it's name in fontFileName and use @"system" for fontType
 */
+(id)labelWithFrame:(cdaRect)frame onView:(cdaView *)view stringValue:(NSString*)stringValue fontFileName:(NSString *)fontName fontType:(NSString *)fontType fontSize:(float)fontSize color:(cdaColor *)c indent:(BOOL)indent;
/*!
 *	if you want to use the device font, provide it's name in fontFileName and use @"system" for fontType
 */
-(void)setStringValue:(NSString*)stringValue fontFileName:(NSString *)fontName fontType:(NSString *)fontType fontSize:(float)fontSize color:(cdaColor *)c indent:(BOOL)indent;	


+(id)labelWithFrame:(cdaRect)frame stringValue:(NSString*)stringValue font:(CTFontRef)f color:(cdaColor *)c indent:(BOOL)indent;
+(id)labelWithFrame:(cdaRect)frame onView:(cdaView *)view stringValue:(NSString*)stringValue font:(CTFontRef)f color:(cdaColor *)c indent:(BOOL)indent;
-(void)setFrameOrigin:(cdaPoint)origin;
-(void)setStringValue:(NSString*)stringValue font:(CTFontRef)f color:(cdaColor *)c indent:(BOOL)indent;


//color
/*!
 sets the color of the whole text
 */
-(void)setTextColor:(cdaColor *)color;

/*!
 sets the color of the text in provided range (for the first letter use NSMakeRange(0, 1) )
 */
-(void)setTextColor:(cdaColor *)color range:(NSRange)range;


//render
/*!
 one of the "render" methods has to be called in order to render;
 after setting all the attributes, call 
 -(void)renderTextFrameWithWidth:(int)width sizeToFit:(BOOL)sizeToFit;
 OR
 -(void)renderTextFrame;
 OR
 set the "reindentsTextOnResize" property to YES and set the new frame;
 
 you may need to call setNeedsDisplay in rare occasions
 */
-(void)renderTextFrameWithWidth:(int)width sizeToFit:(BOOL)sizeToFit;

/*!
 one of the "render" methods has to be called in order to render;
 after setting all the attributes, call 
 -(void)renderTextFrameWithWidth:(int)width sizeToFit:(BOOL)sizeToFit;
 OR
 -(void)renderTextFrame;
 OR
 set the "reindentsTextOnResize" property to YES and set the new frame;
 
 you may need to call setNeedsDisplay in rare occasions
 */
-(void)renderTextFrame;

@end
