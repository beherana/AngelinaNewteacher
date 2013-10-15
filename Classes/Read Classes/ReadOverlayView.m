//
//  ReadOverlayView.m
//  Misty-Island-Rescue-Universal
//
//  Created by Radif Sharafullin on 2/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ReadOverlayView.h"
#import "cdaCTLabel.h"

@implementation ReadOverlayView

-(void)setTarget:(id)tg selector:(SEL)sel{
	target=tg;
	selector=sel;
}

- (id)initWithFrame:(CGRect)frame text:(NSString *)text style:(ReadOverlayViewStyle) style{
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		self.userInteractionEnabled=YES;
		NSString *suffix= style==ReadOverlayViewStyleWhite? @"white" : @"black";
		self.image=[UIImage imageNamed:[NSString stringWithFormat:@"overlay-background-%@.png",suffix]];
		
		float width=422;
		float height=0;
		
		
		UIColor * color=style==ReadOverlayViewStyleWhite? [UIColor blackColor] : [UIColor whiteColor];
		
		textLabel = [[cdaCTLabel alloc]initWithFrame:cdaRectMake(0,0,width,height)];
		textLabel.lineHeight=34;
		textLabel.backgroundColor=[cdaColor clearColor];
		[textLabel setStringValue:text
		   fontFileName:@"Georgia"
		   fontType:@"system"
		   fontSize:21
		   color:color
		   indent:YES];
		 
		 
		 [textLabel renderTextFrameWithWidth:width sizeToFit:YES];
		 
		
		height=textLabel.frame.size.height;
		
		UIScrollView *sv=[[UIScrollView alloc]initWithFrame:CGRectMake(31, 49, 422, 320-49-10-10)];
		[sv setContentInset:UIEdgeInsetsMake(0, 0, 35, 0)];
		sv.showsVerticalScrollIndicator=NO;
		sv.showsHorizontalScrollIndicator=NO;
		
		[sv addSubview:textLabel];
		[sv setContentSize:CGSizeMake(width, height+10)];
		[self addSubview:sv];
		
		[sv release];
		[textLabel release];
		
		UIImageView *fadeView=[[UIImageView alloc]initWithFrame:CGRectMake(31, 320-19-45, 422, 45)];
		[fadeView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"overlay-gradient-%@.png",suffix]]];
		[self addSubview:fadeView];
		[fadeView release];
		
		closeButton=[UIButton buttonWithType:UIButtonTypeCustom];
		float buttonInset=10;
		[closeButton setFrame:CGRectMake(437-buttonInset, 22-buttonInset, 19+buttonInset*2, 19+buttonInset*2)];
		[closeButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"overlay-close-%@.png",suffix]] forState:UIControlStateNormal];
		[closeButton addTarget:self action:@selector(dismissAnimated) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:closeButton];
		
    }
    return self;
}

-(void)presentInViewAnimated:(UIView *)v{
	self.alpha=0.0f;
	[v addSubview:self];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationDuration:.3];
	self.alpha=1.0f;
	[UIView commitAnimations];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelay:.1];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationDuration:.3];
	textLabel.alpha=1.0f;
	[UIView commitAnimations];
	
}
-(void)dismissAnimated{
	closeButton.userInteractionEnabled=NO;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationDuration:.15];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(dismissMe)];
	self.alpha=0.0f;
	[UIView commitAnimations];
}
-(void)dismissMe{
	[target performSelector:selector];
	[self removeFromSuperview];
}
- (void)dealloc {
    [super dealloc];
}


@end
