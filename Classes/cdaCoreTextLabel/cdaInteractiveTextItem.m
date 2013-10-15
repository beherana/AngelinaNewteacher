//
//  cdaInteractiveTextItem.m
//
//  Created by Radif Sharafullin on 2/3/11.
//  Copyright 2011 Callaway Digital Arts. All rights reserved.
//

#import "cdaInteractiveTextItem.h"
#import "cdaGlobalFunctions.h"
#import <QuartzCore/QuartzCore.h>

@interface cdaInteractiveTextItem (topSecret)
-(void)setStateString:(NSString *)state animated:(BOOL)animated duration:(NSTimeInterval)duration;
-(void)loadDictionary;
-(void)switchTextColor:(UIColor*)color fontName:(NSString *)fontName fontType:(NSString *)fontType  fontType:(float)fontSize;
@end


@implementation cdaInteractiveTextItem

@synthesize dictionary,
wordIndex,
textItemState,
highlightTimeFrom,
highlightTimeTo,
delegate;

-(id)initWithDictionary:(NSDictionary *)dict onView:(UIView *)v{	
	self=[super init];
	if (self) {
		self.dictionary=dict;
		[self loadDictionary];
		[self setState:cdaInteractiveTextItemStateNormal animated:NO duration:0.0f];
		[v addSubview:self];
		self.userInteractionEnabled=YES;
	}
#ifdef kDrawsLabelEdges
	self.layer.borderColor=[[UIColor redColor] CGColor];
	self.layer.borderWidth=1;
#endif
	return self;
}


- (void)dealloc {
	self.dictionary=nil;
    [super dealloc];
}
-(void)setTextItemState:(cdaInteractiveTextItemState)newState{
	if (textItemState==newState) return;
	
	
	
	NSTimeInterval duration = 0;
	
	if (newState==cdaInteractiveTextItemStateHighlighted) {
		duration=[self animationDurationToHighlight];
	}else if ((textItemState==cdaInteractiveTextItemStateHighlighted) && (newState==cdaInteractiveTextItemStateNormal)) {
		duration=[self animationDurationFromHighlight];
	}else if (newState==cdaInteractiveTextItemStateSelected) {
		duration=[self animationDurationToSelected];
	}else if ((textItemState==cdaInteractiveTextItemStateSelected) && (newState==cdaInteractiveTextItemStateNormal)) {
		duration=[self animationDurationFromSelected];
	}


	textItemState=newState;

	NSArray *indexes=self.wordGroupIndexes;
	for (NSString *index in indexes) {
		cdaInteractiveTextItem * wordItem=[[delegate words] objectAtIndex:[index intValue]];
		[wordItem setTextItemState:newState];
	} 
	
	[self setState:textItemState animated:YES duration:duration];
}
-(void)setState:(cdaInteractiveTextItemState)state animated:(BOOL)animated duration:(NSTimeInterval)duration{
	NSString *stateString=@"normal";
switch (state) {
	case cdaInteractiveTextItemStateNormal:{
		stateString=@"normal";
	}break;
	case cdaInteractiveTextItemStateHighlighted:{
		stateString=@"highlighted";
	}break;
	case cdaInteractiveTextItemStateSelected:{
		stateString=@"selected";
	}break;
	default:
		break;
}
	[self setStateString:stateString animated:animated duration:duration];
}
-(void)setStateString:(NSString *)state animated:(BOOL)animated duration:(NSTimeInterval)duration{
	if (!animated) duration=0;
	[UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
						 CATransform3D transform=CATransform3DIdentity;
						 //rotation
						 CGFloat rotation=0;
						 if ([[[[self.dictionary objectForKey:@"states"]objectForKey:state] objectForKey:@"rotation"] floatValue]) rotation=[[[[self.dictionary objectForKey:@"states"]objectForKey:state] objectForKey:@"rotation"] floatValue];
						 
						 //scaleX
						 //scaleY
						 CGFloat scaleX=1;
						 CGFloat scaleY=1;
						 if ([[[[self.dictionary objectForKey:@"states"]objectForKey:state] objectForKey:@"scaleX"] floatValue]) scaleX=[[[[self.dictionary objectForKey:@"states"]objectForKey:state] objectForKey:@"scaleX"] floatValue];
						 if ([[[[self.dictionary objectForKey:@"states"]objectForKey:state] objectForKey:@"scaleY"] floatValue]) scaleY=[[[[self.dictionary objectForKey:@"states"]objectForKey:state] objectForKey:@"scaleY"] floatValue];
						 transform=CATransform3DRotate(transform, rotation, 0, 0, 1);
						 transform=CATransform3DScale(transform, scaleX, scaleY, 1);
						 
						 //translateX
						 //translateY
						 CGFloat translateX=1;
						 CGFloat translateY=1;
						 if ([[[[self.dictionary objectForKey:@"states"]objectForKey:state] objectForKey:@"translateX"] floatValue]) translateX=[[[[self.dictionary objectForKey:@"states"]objectForKey:state] objectForKey:@"translateX"] floatValue];
						 if ([[[[self.dictionary objectForKey:@"states"]objectForKey:state] objectForKey:@"translateY"] floatValue]) translateY=[[[[self.dictionary objectForKey:@"states"]objectForKey:state] objectForKey:@"translateY"] floatValue];
						 transform=CATransform3DTranslate(transform, translateX, translateY, 0);
						 self.layer.transform=transform;
						 
						 
						 
						 //shadows
						 if ([[[self.dictionary objectForKey:@"states"]objectForKey:state] objectForKey:@"shadowOpacity"]) self.layer.shadowOpacity=[[[[self.dictionary objectForKey:@"states"]objectForKey:state] objectForKey:@"shadowOpacity"] floatValue];
						 if ([[[self.dictionary objectForKey:@"states"]objectForKey:state] objectForKey:@"shadowOffset"]) self.layer.shadowOffset=CGSizeFromString([[[self.dictionary objectForKey:@"states"]objectForKey:state] objectForKey:@"shadowOffset"]);
						 
						 if ([[[self.dictionary objectForKey:@"states"]objectForKey:state] objectForKey:@"shadowColor"]) {
							 UIColor *col=UIColorFromRGBAString([[[self.dictionary objectForKey:@"states"]objectForKey:state] objectForKey:@"shadowColor"]);
							 self.layer.shadowColor=[col CGColor];
						 }
						 if ([[[self.dictionary objectForKey:@"states"]objectForKey:state] objectForKey:@"shadowRadius"] ) self.layer.shadowRadius=[[[[self.dictionary objectForKey:@"states"]objectForKey:state] objectForKey:@"shadowRadius"] floatValue];
						 
                         
                         
                         //color
                         UIColor *textColor=nil;
                         NSString *color = [[[self.dictionary objectForKey:@"states"] objectForKey:state]objectForKey:@"textColor"];
                         if (color) textColor=UIColorFromRGBAString(color);
                         
                         if (!textColor) {
                         //get it from the normal state
                             color = [[[self.dictionary objectForKey:@"states"] objectForKey:@"normal"]objectForKey:@"textColor"];
                             if (color) textColor=UIColorFromRGBAString(color);
                             if (!textColor) textColor=[UIColor blackColor];
                         }
                         

                         //fontName
                         NSString *fontName = [[[self.dictionary objectForKey:@"states"] objectForKey:state]objectForKey:@"fontName"];
                         if (!fontName) fontName = [[[self.dictionary objectForKey:@"states"] objectForKey:@"normal"]objectForKey:@"fontName"];
                         //fontType
                         NSString *fontType = [[[self.dictionary objectForKey:@"states"] objectForKey:state]objectForKey:@"fontType"];
                         if(!fontType) fontType = [[[self.dictionary objectForKey:@"normal"] objectForKey:@"normal"]objectForKey:@"fontType"];
                         //fontSize
                         float fontSize = [[[[self.dictionary objectForKey:@"states"] objectForKey:state]objectForKey:@"fontSize"] floatValue];
                         if(!fontSize) fontSize=[[[[self.dictionary objectForKey:@"states"] objectForKey:@"normal"]objectForKey:@"fontSize"] floatValue];
                         
                         [self switchTextColor:textColor fontName:fontName fontType:fontType fontType:fontSize];
						 
					 
					 }
                     completion:nil];
}
-(void)switchTextColor:(UIColor*)color fontName:(NSString *)fontName fontType:(NSString *)fontType  fontType:(float)fontSize {
    
    
	[self setStringValue:self.text
			fontFileName:fontName
				fontType:fontType
				fontSize:fontSize
				   color:color
				  indent:NO];
	[self renderTextFrame];
	self.reindentsTextOnResize=YES;
    
    [self renderTextFrame];
    [self setNeedsDisplay];
    
}
-(void)loadDictionary{

	CGRect frame=CGRectZero;
	//frame
	if ([self.dictionary objectForKey:@"frame"]) frame=CGRectFromString([self.dictionary objectForKey:@"frame"]);
    
    frame.origin.x=ceil(frame.origin.x);
    frame.origin.y=ceil(frame.origin.y);
    frame.size.width=ceil(frame.size.width);
    frame.size.height=ceil(frame.size.height);
    
    
	//color
	UIColor *textColor=nil;
	NSString *color = [[[self.dictionary objectForKey:@"states"] objectForKey:@"normal"]objectForKey:@"textColor"];
	if (color) textColor=UIColorFromRGBAString(color);
	
	if (!textColor) textColor=[UIColor blackColor];
	
	//text
	self.text=[self.dictionary objectForKey:@"text"];
	//fontName
	NSString *fontName = [[[self.dictionary objectForKey:@"states"] objectForKey:@"normal"] objectForKey:@"fontName"];
	//fontType
	NSString *fontType = [[[self.dictionary objectForKey:@"states"] objectForKey:@"normal"]objectForKey:@"fontType"];
	//fontSize
	float fontSize = [[[[self.dictionary objectForKey:@"states"] objectForKey:@"normal"] objectForKey:@"fontSize"] floatValue];
	
	
	
	self.frame=frame;
	self.backgroundColor=[UIColor clearColor];
	
	[self setStringValue:self.text
			fontFileName:fontName
				fontType:fontType
				fontSize:fontSize
				   color:textColor
				  indent:NO];
	[self renderTextFrame];
	self.reindentsTextOnResize=YES;
	
	
	//anchorPoint
	CGPoint anchorPoint= CGPointMake(.5, .5);
	if ([self.dictionary objectForKey:@"anchorPoint"]) anchorPoint=CGPointFromString([self.dictionary objectForKey:@"anchorPoint"]);	
	[self.layer setAnchorPoint:anchorPoint];
	
	
	highlightTimeFrom=[[self.dictionary objectForKey:@"highlightTimeFrom"] floatValue];
	highlightTimeTo=[[self.dictionary objectForKey:@"highlightTimeTo"] floatValue];
	
}
#pragma mark Properties
-(id)propertyForKey:(NSString *)key{
    return [self.dictionary objectForKey:key];
}
-(NSArray *)wordGroupIndexes{
    if (![[self.dictionary objectForKey:@"wordGroupIndexes"] length]) return nil;
	return [[self.dictionary objectForKey:@"wordGroupIndexes"] componentsSeparatedByString:@","];
}
-(NSString *)wordAudioFilePath{
	return [cdaGlobalFunctions cdaPath:[self.dictionary objectForKey:@"wordAudioFilePath"]];
}
-(NSString *)popoverImageFilePath{
	return [cdaGlobalFunctions cdaPath:[self.dictionary objectForKey:@"popoverImageFilePath"]];
}
-(float) animationDurationToSelected{
	return [[self.dictionary objectForKey:@"animationDurationToSelected"] floatValue];
}
-(float) animationDurationFromSelected{
	return [[self.dictionary objectForKey:@"animationDurationFromSelected"] floatValue];
}
-(float) animationDurationToHighlight{
	return [[self.dictionary objectForKey:@"animationDurationToHighlight"] floatValue];
}
-(float) animationDurationFromHighlight{
	return [[self.dictionary objectForKey:@"animationDurationFromHighlight"] floatValue];
}
@end
