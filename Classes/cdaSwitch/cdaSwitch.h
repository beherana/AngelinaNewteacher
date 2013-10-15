//
//  cdaSwitch.h
//  ThomasSettings
//
//  Created by Radif Sharafullin on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface cdaSwitchImageView : UIImageView{

	CGFloat x;
	CGFloat spanX;
	CGFloat span;
}
-(void)reindentMe;

@end


@interface cdaSwitch : UIView {
	BOOL on;
	id target;
	SEL selector;
	
@private
	cdaSwitchImageView *background;
	
}


@property(nonatomic,getter=isOn) BOOL on;
@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL selector;

- (id)initWithFrame:(CGRect)frame backgroundImage:(UIImage *)image;
- (void)setOn:(BOOL)on animated:(BOOL)animated; // does not send action
- (void)setTarget:(id)target selector:(SEL)selector;
@end
