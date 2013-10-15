//
//  cdaAffiliateLink.m
//  Hero-Of-The-Rails-Universal
//
//  Created by Radif Sharafullin on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cdaAffiliateLink.h"


@implementation cdaAffiliateLink

@synthesize url;
+(void)launchAffiliateLink:(NSString *)link{
    cdaAffiliateLink *x=[self new];
    [x launchAffiliateLink:link];
    [x release];
}
-(id)init{
    self=[super init];
    [self retain];
    return self;
}
-(void)launchAffiliateLink:(NSString *)link{
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]] delegate:self startImmediately:YES];
    [conn release];
}


// Save the most recent URL in case multiple redirects occur
// "iTunesURL" is an NSURL property in your class declaration
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    self.url = [response URL];
    return request;
}

// No more redirects; use the last URL saved
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[UIApplication sharedApplication] openURL:self.url];
    [self release];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [self release];
}
-(void)dealloc{
    self.url=nil;
    [super dealloc];
}
@end
