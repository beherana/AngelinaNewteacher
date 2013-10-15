//
//  FogSprite.m
//  Thomas
//
//  Created by Robert Bergkvist on 2010-11-18.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FogSprite.h"


@implementation FogSprite
-(void) draw {
	glColorMask(TRUE,TRUE,TRUE,FALSE);
	glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
	glTexEnvi (GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_BLEND);
	[super draw];
	glBlendFunc(CC_BLEND_SRC,CC_BLEND_DST);
	glTexEnvi (GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
	glColorMask(TRUE,TRUE,TRUE,TRUE);	
}
@end
