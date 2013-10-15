//
//  ThomasSwitch.h
//  ThomasSettings
//
//  Created by Radif Sharafullin on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cdaSwitch.h"

/*!
 Usage:
 ThomasSwitch *s=[[ThomasSwitch alloc] initWithFrame:CGRectMake(200, 200, 0, 0)];
 [s setTarget:self selector:@selector(switchTapped:)];
 [self.view addSubview:s];
 [s setOn:NO animated:YES];
 [s release];
 
 
 -(void)switchTapped:(ThomasSwitch *)s{
	NSLog(@"%i",s.isOn);
 }
 
*/
@interface ThomasSwitch : cdaSwitch {

}

@end
