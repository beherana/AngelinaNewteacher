//
//  AppDelegate.h
//  AngelinaGame
//
//  Created by Karl Söderström on 2011-06-27.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BubblePopRootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	BubblePopRootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
