//
//  cdaCTLabel.m
//  
//
//  Created by Radif Sharafullin on 2/3/11.
//  Copyright 2011 Callaway Digital Arts. All rights reserved.
//

#import "cdaCTLabel.h"
#import "cdaGlobalFunctions.h"

#if !TARGET_OS_IPHONE
@interface NSColor(CGColor)
- (CGColorRef)CGColor;
@end
@implementation NSColor(CGColor)
- (CGColorRef)CGColor {
    CGColorSpaceRef colorSpace = [[self colorSpace] CGColorSpace];
    NSInteger componentCount = [self numberOfComponents];
    CGFloat *components = (CGFloat *)calloc(componentCount, sizeof(CGFloat));
    [self getComponents:components];
    CGColorRef color = CGColorCreate(colorSpace, components);
    free((void*)components);
    return color;
}
@end
#endif

@interface cdaCTLabel (topSecret)
-(void)initVars;
@end


@implementation cdaCTLabel

@synthesize _textFrame,
 _frameSize,
 _attrString,
 _paddingBottom,
 fontCacher,
 lineHeight,
 reindentsTextOnResize,
 text;
#if !TARGET_OS_IPHONE
@synthesize backgroundColor;
#endif
#pragma mark alloc


+(id)labelWithFrame:(cdaRect)frame stringValue:(NSString*)stringValue fontFileName:(NSString *)fontName fontType:(NSString *)fontType fontSize:(float)fontSize color:(cdaColor *)c indent:(BOOL)indent{
	cdaCTLabel *label=[[[self alloc] initWithFrame:frame] autorelease];
	CTFontRef font=[label.fontCacher fontWithName:fontName ofType:fontType size:fontSize];
	[label setStringValue:stringValue font:font color:c indent:indent];
	return label;
}
+(id)labelWithFrame:(cdaRect)frame onView:(cdaView *)view stringValue:(NSString*)stringValue fontFileName:(NSString *)fontName fontType:(NSString *)fontType fontSize:(float)fontSize color:(cdaColor *)c indent:(BOOL)indent{
	cdaCTLabel *label=[self labelWithFrame:frame stringValue:stringValue fontFileName:fontName fontType:fontType fontSize:fontSize color:c indent:indent];
	[view addSubview:label];
	return label;
}
-(void)setStringValue:(NSString*)stringValue fontFileName:(NSString *)fontName fontType:(NSString *)fontType fontSize:(float)fontSize color:(cdaColor *)c indent:(BOOL)indent{
	
	//alloc font with cacher
	CTFontRef font=[self.fontCacher fontWithName:fontName ofType:fontType size:fontSize];
	[self setStringValue:stringValue font:font color:c indent:indent];
}


+(id)labelWithFrame:(cdaRect)frame onView:(cdaView *)view stringValue:(NSString*)stringValue font:(CTFontRef)f color:(cdaColor *)c indent:(BOOL)indent{
	cdaCTLabel *label=[self labelWithFrame:frame stringValue:stringValue font:f color:c indent:indent];
	[view addSubview:label];
	return label;
}
+(id)labelWithFrame:(cdaRect)frame stringValue:(NSString*)stringValue font:(CTFontRef)f color:(cdaColor *)c indent:(BOOL)indent{
	cdaCTLabel *label=[[[self alloc] initWithFrame:frame] autorelease];
	[label setStringValue:stringValue font:f color:c indent:indent];
	return label;
	
}

- (id)initWithFrame:(cdaRect)f {
    if ((self = [super initWithFrame:f])) {
        // Initialization code
		[self initVars];
    }
    return self;
}
-(void)initVars{
#if TARGET_OS_IPHONE
	self.userInteractionEnabled=NO;
#endif
	[self setBackgroundColor:[cdaColor clearColor]];
	_paddingBottom = 0;
	
	[cdaCTFontCacher cacherRetain];
	fontCacher=[cdaCTFontCacher sharedCacher];
	lineHeight=20;
}
- (void)dealloc {
#if !TARGET_OS_IPHONE
		CDA_RELEASE_SAFELY(backgroundColor);
#endif
	[cdaCTFontCacher cacherRelease];
	CDA_RELEASE_CF_SAFELY(_textFrame);
	self._attrString=nil;
	self.text=nil;
    [super dealloc];
}

#pragma mark getters
- (CGSize)suggestSizeAndFitRange:(CFRange *)range forAttributedString:(CFMutableAttributedStringRef)attrString usingSize:(CGSize)referenceSize
{
	if(_textFrame != nil) {
		CFRelease(_textFrame);
		_textFrame = nil;
	}
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrString);
	CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,_stringSize,NULL,referenceSize,range);
	CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attrString);
	
	CGFloat ascent, descent, leading;
	CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
	CGFloat lHeight = ascent + descent + leading;
	suggestedSize.height += lHeight / 2.f;
	
	CGMutablePathRef path = CGPathCreateMutable();
	CGRect rect = CGRectMake(0, 0, suggestedSize.width, suggestedSize.height);
	CGPathAddRect(path, NULL, rect);
	
	_textFrame = CTFramesetterCreateFrame(framesetter, _stringSize, path, NULL );
	
	CGPathRelease(path);
	CFRelease(line);
	CFRelease(framesetter);
	return suggestedSize;
}




#pragma mark setters
-(void)setTextColor:(cdaColor *)color{
	[self setTextColor:color range:NSMakeRange(0,[self._attrString length])];
}
-(void)setTextColor:(cdaColor *)color range:(NSRange)range{
	CGColorRef col=[color CGColor];
[self._attrString addAttribute:(NSString*)(kCTForegroundColorAttributeName) value:(id)col range:range];
#if !TARGET_OS_IPHONE
	CGColorRelease(col);
#endif
}



-(void)setStringValue:(NSString*)stringValue font:(CTFontRef)f color:(cdaColor *)c indent:(BOOL)indent{
	self.text=stringValue;
	NSDictionary *baseAttributes = [NSDictionary dictionaryWithObject:(id)f forKey:(NSString *)kCTFontAttributeName];

	if (lineHeight==0)lineHeight = 20.0f;
	
    CTParagraphStyleSetting settings[] = {
        { kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(lineHeight), &lineHeight },
        { kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(lineHeight), &lineHeight },
    };
	
	
	_stringSize = CFRangeMake(0,[stringValue length]);
	_width = 0;
	
	self._attrString = [[[NSMutableAttributedString alloc] initWithString:stringValue attributes:baseAttributes] autorelease];
	CGColorRef col=[c CGColor];
	[self._attrString addAttribute:(NSString*)(kCTForegroundColorAttributeName) value:(id)col range:NSMakeRange(0,[stringValue length])];
#if !TARGET_OS_IPHONE
	CGColorRelease(col);
#endif
	
	//[self._attrString addAttribute:(NSString*)(kCTFontWidthTrait) value:(id)[NSNumber numberWithFloat:30.0f] range:NSMakeRange(0,[stringValue length])];

	if(indent){
		CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, sizeof(settings) / sizeof(settings[0]));
		[self._attrString addAttribute:(NSString*)(kCTParagraphStyleAttributeName) value:(id)paragraphStyle range:NSMakeRange(0, [stringValue length])];
		CFRelease(paragraphStyle);
	}
}




- (void)setFrame:(cdaRect)f {
	f.size.height+=_paddingBottom;
	[super setFrame:f];
	if (reindentsTextOnResize) [self renderTextFrame];
}


-(void)setFrameOrigin:(cdaPoint)origin {
	cdaRect r = [self frame];
	r.origin.x = origin.x;
	r.origin.y = origin.y;
	[self setFrame:r];
}

#pragma mark Drawing
-(void)renderTextFrameWithWidth:(int)w sizeToFit:(BOOL)sizeToFit {
	if(_width == w) return;
	_width = w;
	CFRange fitRange;
	CDA_RELEASE_CF_SAFELY(_textFrame)
	CGRect r = CGRectMake(0,0,w,1440);
	cdaRect textDisplayRect = CGRectInset(r, 1.f, 1.f);
	_frameSize = [self suggestSizeAndFitRange:&fitRange forAttributedString:(CFMutableAttributedStringRef)self._attrString usingSize:textDisplayRect.size];
	if(sizeToFit) [self setFrame:cdaRectMake(self.frame.origin.x,self.frame.origin.y,_frameSize.width,_frameSize.height+5)];
}
-(void)renderTextFrame{
	[self renderTextFrameWithWidth:self.frame.size.width sizeToFit:NO];
}
- (void)drawRect:(cdaRect)rect {
	[super drawRect:rect];
#if TARGET_OS_IPHONE
	CGContextRef context = UIGraphicsGetCurrentContext();
#else
	CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
	if (backgroundColor) {
		[backgroundColor set];
		[NSBezierPath fillRect:rect];
		
	}
#endif
	CGContextSaveGState(context);
#if TARGET_OS_IPHONE
	CGContextTranslateCTM(context, 0, _frameSize.height+3);
	CGContextScaleCTM(context, 1.0f, -1.0f);
#else
	CGContextScaleCTM(context, 1.0f, 1.0f);
#endif
	CTFrameDraw(self._textFrame,context);
	CGContextRestoreGState(context);
	

	//CGContextSetCharacterSpacing(context, 10);
	//[@"hello" drawInRect:rect withFont:[UIFont boldSystemFontOfSize:10]];
}
#if !TARGET_OS_IPHONE
-(void)setBackgroundColor:(NSColor *)color{
	CDA_RELEASE_SAFELY(backgroundColor);
	backgroundColor=[color retain];
	[self setNeedsDisplay:YES];
	
}
-(BOOL)isFlipped{
	return NO;
}
#endif
@end
