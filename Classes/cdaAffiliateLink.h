//
//  cdaAffiliateLink.h
//  Hero-Of-The-Rails-Universal
//
//  Created by Radif Sharafullin on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface cdaAffiliateLink : NSObject {
    NSURL *url;
}
@property (nonatomic, retain) NSURL *url;
+(void)launchAffiliateLink:(NSString *)link;
-(void)launchAffiliateLink:(NSString *)link;
@end
