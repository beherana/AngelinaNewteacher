//
//  ImageAnimations.h
//  Angelina-New-Teacher-Universal
//
//  Created by Martin Kamara on 2011-09-07.
//  Copyright 2011 Commind. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageAnimations : NSObject


+ (void)spinLayer:(CALayer *)inLayer duration:(CFTimeInterval)inDuration direction:(int)direction;

@end
