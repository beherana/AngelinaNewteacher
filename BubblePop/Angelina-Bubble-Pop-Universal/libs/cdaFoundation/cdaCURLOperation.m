//
//  cdaXSellDownloadOperation.m
//  cdaXSellServiceSample
//
//  Created by FRANCISCO CANDALIJA on 7/1/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import "cdaCURLOperation.h"

@implementation cdaCURLOperation
@synthesize successBlock, failureBlock;


- (id)initWithRequest:(NSURLRequest *)inRequest
{
    self.successBlock = nil;
    self.failureBlock = nil;

    return [super initWithRequest:inRequest];
}

-(void) dealloc {
    self.successBlock = nil;
    self.failureBlock = nil;
    [super dealloc];
}

- (void)didFinish
{
    [super didFinish];
    self.successBlock();
}

- (void)didFailWithError:(NSError *)inError
{
    [super didFailWithError:inError];
    self.failureBlock(inError);
}

@end
