//
//  ConstantContactCURLOperation.m
//  KeepInTouchWidgets
//
//  Created by FRANCISCO CANDALIJA on 5/24/11.
//  Copyright 2011 Callaway Digital Arts, Inc. All rights reserved.
//

#import "cdaConstantContactCURLOperation.h"


@implementation cdaConstantContactCURLOperation
@synthesize onSuccessHandler, onFailureHandler;

- (void)dealloc
{
	self.onSuccessHandler = nil;
    self.onFailureHandler = nil;
	[super dealloc];
}

- (void)didFinish
{
    [super didFinish];
    NSHTTPURLResponse *theHTTPResponse = (NSHTTPURLResponse *)self.response;
    if( self.onSuccessHandler ) {
        self.onSuccessHandler([theHTTPResponse statusCode], [theHTTPResponse allHeaderFields], self.data);
    }
}

- (void)didFailWithError:(NSError *)inError
{
    [super didFailWithError:inError];
    if( self.onFailureHandler ) {
        self.onFailureHandler(inError);
    }
}


@end
