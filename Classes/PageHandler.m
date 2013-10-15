//
//  PageHandler.m
//  Angelina-New-Teacher-Universal
//
//  Created by Karl Söderström on 2011-05-30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PageHandler.h"
#import "Angelina_AppDelegate.h"

@implementation PageHandler
@synthesize currentPage = _currentPage;

- (void)setCurrentPage:(int)currentPage
{
    int oldPage = _currentPage;
    _currentPage = currentPage;
    
    if (oldPage != currentPage) {
    
        NSDictionary *userInfo =
        [NSDictionary dictionaryWithObjectsAndKeys:
         [NSNumber numberWithInt:oldPage], @"oldPage",
         [NSNumber numberWithInt:currentPage], @"currentPage",
         nil];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:kCurrentPageDidChange
         object:self
         userInfo:userInfo];
    }
}

-(void)forcePage:(int) page {
    _currentPage = page;
}

+ (PageHandler *) defaultHandler
{
    return [Angelina_AppDelegate get].pageHandler;
}
@end
