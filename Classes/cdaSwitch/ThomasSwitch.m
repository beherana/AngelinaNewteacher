//
//  ThomasSwitch.m
//  ThomasSettings
//
//  Created by Radif Sharafullin on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ThomasSwitch.h"
#import <QuartzCore/QuartzCore.h>


@implementation ThomasSwitch


- (id)initWithFrame:(CGRect)frame {
    
	UIImage *thomasSwitchImage=[UIImage imageNamed:@"thomas_switch.png"];
	
	self =  [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, 101, thomasSwitchImage.size.height) backgroundImage:thomasSwitchImage];
	
    if (self) {
        // Initialization code.
		
		self.layer.cornerRadius=4;
	
		self.layer.borderWidth=1;
		self.layer.borderColor=[[UIColor colorWithWhite:0 alpha:.2]CGColor];
		
    }
    return self;
}



- (void)dealloc {
    [super dealloc];
}


@end
