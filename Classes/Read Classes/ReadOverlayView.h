//
//  ReadOverlayView.h
//  Misty-Island-Rescue-Universal
//
//  Created by Radif Sharafullin on 2/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class cdaCTLabel;
typedef enum {
	ReadOverlayViewStyleWhite = 0,
	ReadOverlayViewStyleBlack = 1,
} ReadOverlayViewStyle;

@interface ReadOverlayView : UIImageView  {
	id target;
	SEL selector;
	UIButton * closeButton;
	cdaCTLabel *textLabel;
	
}
- (id)initWithFrame:(CGRect)frame text:(NSString *)text style:(ReadOverlayViewStyle) style;
-(void)setTarget:(id)tg selector:(SEL)sel;
-(void)presentInViewAnimated:(UIView *)v;
@end
