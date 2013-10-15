//
//  PageTurnWithBackground.m
//  Angelina-New-Teacher-Universal
//
//  Created by Karl Söderström on 2011-09-13.
//  Copyright 2011 Commind AB. All rights reserved.
//


#import "PageTurnWithBackground.h"
#import "cocos2d.h"

@implementation Grid3dWithBackground

-(void)blit {
	NSInteger n = gridSize_.x * gridSize_.y;
	
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Unneeded states: GL_COLOR_ARRAY
	//enable culling, the default cull face is back
	glEnable(GL_CULL_FACE);
	//now only the front facing polygons are drawn
	glDisableClientState(GL_COLOR_ARRAY);	
	
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, texCoordinates);
	glDrawElements(GL_TRIANGLES, (GLsizei) n*6, GL_UNSIGNED_SHORT, indices);
	
	//change the winding of what OpenGl considers front facing
	//only the back facing polygons will be drawn
	//this works better then changing the cull face
	glFrontFace(GL_CW);
	//glEnable(GL_TEXTURE_2D);
	//glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    //glEnableClientState(GL_COLOR_ARRAY);
    CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:@"back_page.png"];
    glBindTexture(GL_TEXTURE_2D, texture.name);
    
    glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, texCoordinates);
	glDrawElements(GL_TRIANGLES, (GLsizei) n*6, GL_UNSIGNED_SHORT, indices);
	
	//restore GL default states
	glFrontFace(GL_CCW);
	glDisable(GL_CULL_FACE);
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
}
-(void)setProgress:(float)progress {
	animationProgress = progress;
}

@end

@implementation Grid3dWithBackgroundAction

-(CCGridBase *)grid {
	return [Grid3dWithBackground gridWithSize:gridSize_];
}

-(void)setProgress:(float)progress {
	Grid3dWithBackground *g = (Grid3dWithBackground *)[target_ grid];
	[g setProgress:progress];
}
@end


@implementation PageTurn3dWithBackground

+(id) actionWithSize:(ccGridSize)size duration:(ccTime)d fromCorner:(NSInteger)fromCorner 
{
	return [[[self alloc] initWithSize:size duration:d fromCorner:fromCorner] autorelease];
}
-(id) initWithSize:(ccGridSize)gSize duration:(ccTime)d fromCorner:(NSInteger)fromCorner 
{
	if ( (self = [super initWithDuration:d]) )
	{
		turnCorner = fromCorner;
		gridSize_ = gSize;
		
		winSize = [[CCDirector sharedDirector] winSize];
	}
	
	return self;
}

/*
 * Update each tick
 * Time is the percentage of the way through the duration
 */
-(void)update:(ccTime)time
{
	//Copied pretty much intact from the PageTurn3D, added the progress and different corners.
	float tt = MAX( 0, time - 0.25f );
	float deltaAy = ( tt * tt * 500);
	float ay = -100 - deltaAy;
	
	float deltaTheta = - (float) M_PI_2 * sqrtf( time) ;
	float theta = /*0.01f*/ + (float) M_PI_2 +deltaTheta;
	
	float sinTheta = sinf(theta);
	float cosTheta = cosf(theta);
	
	//Setting progress adjusts the gray color of the background page
	[self setProgress:time];		
	
	for( int i = 0; i <=gridSize_.x; i++ )
	{
		for( int j = 0; j <= gridSize_.y; j++ )
		{
			// Get original vertex
			ccVertex3F	p = [self originalVertex:ccg(i,j)];
			
			//Yeah, some duplicate stuff in each of these that could be cleaned up....but not today.			
		
            float R = sqrtf(p.x*p.x + (p.y - ay) * (p.y - ay));
            float r = R * sinTheta;
            float alpha = asinf( p.x / R );
            float beta = alpha / sinTheta;
            float cosBeta = cosf( beta );
            
            // If beta > PI then we've wrapped around the cone
            // Reduce the radius to stop these points interfering with others
            if( beta <= M_PI)
                p.x = ( r * sinf(beta));
            else
            {
                // Force X = 0 to stop wrapped
                // points
                p.x = 0;
            }
            
            p.y = ( R + ay - ( r*(1 - cosBeta)*sinTheta));
            
            // We scale z here to avoid the animation being
            // too much bigger than the screen due to perspectve transform
            p.z = (r * ( 1 - cosBeta ) * cosTheta) / 7; // "100" didn't work for
			
			// Stop z coord from dropping beneath underlying page in a transition
			// issue #751				
			if (p.z<0.5f)
				p.z = 0.5f;
			
			// Set new coords
			[self setVertex:ccg(i,j) vertex:p];
		}
	}
}

@end


@implementation TransitionPageTurnWithBackground

/** creates a base transition with duration and incoming scene */
+(id) transitionWithDuration:(ccTime)t scene:(CCScene*)s backwards:(BOOL)back {
	return [[[self alloc] initWithDuration:t scene:s backwards:back] autorelease];
}

/** initializes a transition with duration and incoming scene */
-(id) initWithDuration:(ccTime) t scene:(CCScene*)s backwards:(BOOL) back
{
	// XXX: needed before [super init]
	back_ = back;
	
	if( ( self = [super initWithDuration:t scene:s] ) )
	{
	}
	return self;
}

-(void) sceneOrder {
	inSceneOnTop_ = back_;
}

//
-(void) onEnter {
	[super onEnter];
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	int x, y;
	if (s.width>=1024 || s.height>=1024) {
		//iPad, do a smaller grid, looks a little smoother to my eyes.
		if (s.width > s.height)	{
			x = 32;
			y = 24;
		} else {
			x = 24;
			y = 32;
		}
	} else {
		if (s.width > s.height)	{
			x = 16;
			y = 12;
		} else {
			x = 12;
			y = 16;
		}
	}
	
	id action  = [self actionWithSize:ccg(x,y)];
	
	if (!back_)	{
		[outScene_ runAction: [CCSequence actions:
							   action,
							   [CCCallFunc actionWithTarget:self selector:@selector(finish)],
							   [CCStopGrid action],
							   nil]
		 ];
	} else {
		// to prevent initial flicker
		inScene_.visible = NO;
		[inScene_ runAction: [CCSequence actions:
							  [CCShow action],
							  action,
							  [CCCallFunc actionWithTarget:self selector:@selector(finish)],
							  [CCStopGrid action],
							  nil]
		 ];
	}
	
}

-(CCActionInterval*) actionWithSize:(ccGridSize)v {
	if (back_)	{
		return [CCReverseTime actionWithAction:[PageTurn3dWithBackground actionWithSize:v duration:duration_]];
	} else {
		return [PageTurn3dWithBackground actionWithSize:v duration:duration_];
	}
}

@end


