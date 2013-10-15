//
//  cdaSwitch.m
//  ThomasSettings
//
//  Created by Radif Sharafullin on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cdaSwitch.h"


@implementation cdaSwitchImageView

-(id)initWithImage:(UIImage *)image{
	self =[super initWithImage:image];
	if (self) {
		
		
		self.userInteractionEnabled=YES;
		
	}
	
	return self;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

	[super touchesBegan:touches withEvent:event];
	
	NSSet *allTouches = [event allTouches];
	if ([allTouches count]>1) return;//bail out if more than one finger is on the screen
	
	UITouch *touch=[allTouches anyObject];
	CGPoint location=[touch locationInView:self];
	x=location.x;
	
	location=[touch locationInView:self.superview];
	spanX=location.x;
	
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	[super touchesMoved:touches withEvent:event];
if (x>=0) {
	NSSet *allTouches = [event allTouches];
	//if ([allTouches count]>1) return;//bail out if more than one finger is on the screen
	
	UITouch *touch=[allTouches anyObject];
	CGPoint location=[touch locationInView:self];
	float newX=location.x;
	
	CGFloat difference=x-newX;

	location=[touch locationInView:self.superview];
	span=location.x-spanX;
	float frameX=self.frame.origin.x-difference;
	const float leftEdge=self.superview.frame.size.width-self.frame.size.width;
	if (frameX<leftEdge) frameX=leftEdge;
	if (frameX>0) frameX=0;
	//if (frameX<self.frame.size.width) frameX=self.frame.size.width;
	self.frame=CGRectMake(frameX, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
	
	
}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	[super touchesEnded:touches withEvent:event];
	[self reindentMe];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
	[super touchesCancelled:touches withEvent:event];
	[self reindentMe];
}
-(void)reindentMe{
	x=-1;
	if (fabs(span)>3) {
		//figure out where we belong;
		const float leftEdge=fabs(self.superview.frame.size.width-self.frame.size.width);
		float frameX=fabs(self.frame.origin.x);
		float middle=leftEdge/2;
		if (frameX>middle) {
			[self.superview performSelector:@selector(swipeLeft)];
		}else {
			[self.superview performSelector:@selector(swipeRight)];
		}

		
	}else 
		[self.superview performSelector:@selector(tap)];
	
	spanX=0;
	span=0;
}
@end


@interface cdaSwitch (topSecret)
-(void)reindentAnimated:(BOOL)animated;
@end


@implementation cdaSwitch
@synthesize target, selector;
- (id)initWithFrame:(CGRect)frame backgroundImage:(UIImage *)bg{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		self.clipsToBounds=YES;
		on=YES;
		background=[[cdaSwitchImageView alloc]initWithImage:bg];
		[self addSubview:background];
		
		
    }
    return self;
}

- (void)setOn:(BOOL)state{
	on =state;
	[self reindentAnimated:NO];	
}
-(void)swipeLeft{
	on=NO;
	[self reindentAnimated:YES];
}
-(void)swipeRight{
	on=YES;
	[self reindentAnimated:YES];
}

-(void)tap{
	on=!on;
	[self reindentAnimated:YES];
}
- (void)setOn:(BOOL)state animated:(BOOL)animated{
	on =state;
	[self reindentAnimated:animated];	
}
-(BOOL)isOn{
	return on;
}
-(void)reindentAnimated:(BOOL)animated{
	float duration=animated? .3f : 0.0f;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:duration];
	
	background.frame= on?
	CGRectMake(0, 0, background.frame.size.width, background.frame.size.height)
	:
	CGRectMake(-background.frame.size.width+self.frame.size.width, 0, background.frame.size.width, background.frame.size.height)
	;
	
	[UIView commitAnimations];
	
	[target performSelector:selector withObject:self];
}

- (void)setTarget:(id)t selector:(SEL)s{
	self.target=t;
	self.selector=s;
}
- (void)dealloc {
	[background release];
    [super dealloc];
}


@end
