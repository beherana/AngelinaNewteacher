//
//  PageHandler.h
//  Angelina-New-Teacher-Universal
//
//  Created by Karl Söderström on 2011-05-30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kCurrentPageDidChange @"CurrentPageDidChange"

@interface PageHandler : NSObject {
@private
    int _currentPage;
}

// Changes to this property are dispatched using NSNotificationCenter
// with a notification named kCurrentPageDidChange.
// userInfo contains NSNumbers for:
//   oldPage        - the old page
//   currentPage    - the new page 
@property (nonatomic, assign) int currentPage;

-(void)forcePage:(int) page;
+ (PageHandler *) defaultHandler;

@end
