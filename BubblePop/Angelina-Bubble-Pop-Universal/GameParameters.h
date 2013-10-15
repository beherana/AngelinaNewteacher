//
//  GameParameters.h
//  AngelinaGame
//
//  Created by Karl Söderström on 2011-06-27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GameParameters : NSObject {
    
}

+(NSDictionary *) params;
+(NSDictionary *) layout;
+(void)reset;
@end
