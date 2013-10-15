//
//  SmokeNode.h
//  Smoke
//
//  Created by Robert Bergkvist on 2010-11-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface SmokeNode : CCParticleSystemQuad {
	CGPoint p0;
	CGPoint p1;
	CGPoint p2;
	CGPoint p3;
	BOOL spewSmoke;
	BOOL flippingPage;
}

-(void)updateQuadWithParticle:(tCCParticle*)p newPosition:(CGPoint)newPos;
@property (nonatomic,readwrite,assign) CGPoint p0;
@property (nonatomic,readwrite,assign) CGPoint p1;
@property (nonatomic,readwrite,assign) CGPoint p2;
@property (nonatomic,readwrite,assign) CGPoint p3;
@property (nonatomic) BOOL spewSmoke;
@property (nonatomic) BOOL flippingPage;
@end
