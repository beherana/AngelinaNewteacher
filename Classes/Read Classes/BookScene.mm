//
//  BookScene.m
//  Thomas
//
//  Created by Johannes Amilon on 11/4/10.
//  Copyright 2010 Vitamin Se Media AB. All rights reserved.
//

#import "BookScene.h"
#import "Angelina_AppDelegate.h"
#import "SceneComponent.h"
#import "PhysicsSprite.h"
#import "FogSprite.h"
#import "SimpleAudioEngine.h"
#import "FontLabelStringDrawing.h"
#import "PlaySoundAction.h"

#define PTM_RATIO 64.0

#define GRID_COLUMNS 128
#define GRID_ROWS 64


@implementation BookScene

@synthesize page,components;
@synthesize hotspotIndicators;
@synthesize isScreenshot;
@synthesize readTextZoomViewController;

/*-(id) init{
	if ((self=[super init]) ) {
		
	}
	return self;
}*/

- (void)precache:(int)scene
{
  	NSArray *data=[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"scene%d",scene] ofType:@"plist"]];
	
	for (uint i=1; i<[data count]; ++i) {
        [SceneComponent precacheComponent:[data objectAtIndex:i]];
	}  
}

-(CGPoint)getLayerOffset {
    return layerOffset;
}

-(void)setPage:(int)newPage{
	//NSLog(@"pageset");

		landscapeRight=[[Angelina_AppDelegate get] currentRootViewController].landscapeRight;

	
	isScreenshot=NO;
	page=newPage;
	NSMutableArray *data=[NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"scene%d",page] ofType:@"plist"]];
	
	components=[[NSMutableArray alloc] initWithCapacity:[data count]-1];
	componentsByName=[[NSMutableDictionary alloc] initWithCapacity:[data count]-1];
	SceneComponent *currentComponent;
	//load objects
	for (uint i=1; i<[data count]; ++i) {
		currentComponent=[SceneComponent componentWithDictionary:[data objectAtIndex:i] :i-1];
		[components addObject:currentComponent];
		[componentsByName setObject:currentComponent forKey:currentComponent.name];
		//NSLog(@"adding %@",currentComponent.name);
	}
	
	
    /* this isn't necessary on ipad it seems, and it slows done quite a bit
     *
	//This is to prevent the misterious black rectangle on the iphone
	CCLayerColor *superLayer=[[[CCLayerColor alloc] initWithColor:ccc4(255, 255, 255, 255)] autorelease];
	[self addChild:superLayer];
	*/
	
	//set background color
	if ([[[[data objectAtIndex:0] objectForKey:@"scenemetadata"] objectForKey:@"bgColor"] isEqual:@"BLACK"]) {
		layer=[[AccelerometerDelegateLayer alloc] initWithColor:ccc4(0, 0, 0, 255)];
	}else {
		layer=[[AccelerometerDelegateLayer alloc] initWithColor:ccc4(255, 255, 255, 255)];
	}
	

	layerOffset=ccp(0,0);
	
	if ([[[data objectAtIndex:0] objectForKey:@"scenemetadata"] objectForKey:@"offsetX"])
		layerOffset.x=[[[[data objectAtIndex:0] objectForKey:@"scenemetadata"] objectForKey:@"offsetX"] floatValue];
	
	if ([[[data objectAtIndex:0] objectForKey:@"scenemetadata"] objectForKey:@"offsetY"])
		layerOffset.y=[[[[data objectAtIndex:0] objectForKey:@"scenemetadata"] objectForKey:@"offsetY"] floatValue];
	
	
	
	layer.anchorPoint=ccp(0,0);
	layer.position=layerOffset;
	
	[self addChild:layer z:0 tag:0];
	animating=NO;
	
    //raising volume on sound fx again
    [PlaySoundAction adjustGainOnFX:1.0f];
    
	//background sound/music
	NSDictionary *sound=[[[data objectAtIndex:0] objectForKey:@"scenemetadata"] objectForKey:@"bgSound"];
	if (sound!=nil) {
		bgSound=[[sound objectForKey:@"filename"] retain];
		bgVolume=[[sound objectForKey:@"volume"] floatValue];
		bgRepeat=[[sound objectForKey:@"repeat"] boolValue];
		[[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:bgSound];
	}else {
		bgSound=nil;
	}
	
	//place background objects
	NSArray *objects=[[[[data objectAtIndex:0] objectForKey:@"scenemetadata"] objectForKey:@"static"] objectForKey:@"background"];
	for (uint i=0;i<[objects count]; ++i) {
		[self addRecursive:[objects objectAtIndex:i]:layer];
	}
	//place foreground objects
	objects=[[[[data objectAtIndex:0] objectForKey:@"scenemetadata"] objectForKey:@"animated"] objectForKey:@"objects"];
	for (uint i=0;i<[objects count]; ++i) {
		[self addRecursive:[objects objectAtIndex:i]:layer];
	}
	
	//language
	NSDictionary *languages=[[[[data objectAtIndex:0] objectForKey:@"scenemetadata"] objectForKey:@"static"] objectForKey:@"text"];
	NSString *language=[((Angelina_AppDelegate*)[[UIApplication sharedApplication] delegate]) getCurrentLanguage];
	NSDictionary *labelDict=[languages objectForKey:language];
	if (labelDict==nil) {
		labelDict=[languages objectForKey:@"en_US"];
	}
	
    NSString *interactiveTextPath=[labelDict objectForKey:@"interactiveTextPath"];

    
	//text box
	CGRect labelBounds=CGRectFromString([labelDict objectForKey:@"boundingBox"]);
	
	
	if ([labelDict objectForKey:@"linespacing"]) {
		[CocosFontHaxxor setRowSpace:[[labelDict objectForKey:@"linespacing"] intValue]];
	}else {
		[CocosFontHaxxor setRowSpace:10];
	}
	
	if (text) [text release];
	if ([labelDict objectForKey:@"overlayText"]) 
		text=[[labelDict objectForKey:@"overlayText"] retain];
	else 
		text=[[labelDict objectForKey:@"text"] retain];
    
    //read hotspot indicator locations from plist hotspots
    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"scenedelay" ofType:@"plist"];
	NSArray *delaycheck = [[NSArray alloc] initWithContentsOfFile:thePath];
	NSDictionary *scenedelay = [NSDictionary dictionaryWithDictionary:[delaycheck objectAtIndex:newPage-1]];
    NSArray *pageHotspots = [[NSArray alloc] initWithArray:[scenedelay objectForKey:@"indicators"]];
    self.hotspotIndicators = pageHotspots;
    [pageHotspots release];
    [delaycheck release];
	

	
	label=[[CCLabelTTF labelWithString:[labelDict objectForKey:@"text"]
								 dimensions:labelBounds.size alignment:UITextAlignmentLeft
								   fontName:[labelDict objectForKey:@"font"]
								   fontSize:[[labelDict objectForKey:@"size"] floatValue]] retain];
	label.position=CGPointMake(labelBounds.origin.x+labelBounds.size.width/2, labelBounds.origin.y+labelBounds.size.height/2);
    
    //moved here to remove hardcoded grey reloadbutton on black pages
    NSString *greySuffix=@"";
    
	if ([[labelDict objectForKey:@"color"] isEqual:@"WHITE"]) {
		[label setColor:ccWHITE];
		style=ReadOverlayViewStyleBlack;
        greySuffix=@"_grey";
	}else {
		[label setColor:ccBLACK];
		style=ReadOverlayViewStyleWhite;
	}
	//label.opacity=0;
	

	
	[layer addChild:label z:[[labelDict objectForKey:@"z"] intValue] tag:5000];
	
	//initialize physics
	hasPhysics=NO;
	world=NULL;
	mouseJoint=NULL;
	if ([[[data objectAtIndex:0] objectForKey:@"scenemetadata"] objectForKey:@"hasPhysics"]!=nil) {
		if ([[[[data objectAtIndex:0] objectForKey:@"scenemetadata"] objectForKey:@"hasPhysics"] boolValue]) {
			[self setupPhysics];
		}
	}
	
	//initialize fog
	hasFog=NO;
	fog=NULL;
	fogTexture=nil;
	NSDictionary *fogDict=[[[[data objectAtIndex:0] objectForKey:@"scenemetadata"] objectForKey:@"animated"] objectForKey:@"fog"];
	if (fogDict!=nil) {
		[self setupFog:fogDict];
	}
    
    //removing the extra animations
    for (UIView *v in [[[CCDirector sharedDirector]openGLView] subviews]) {
        if (v.tag==iTextViewTag) {
            [v removeFromSuperview];
            [v release];
            
        }
    }
    
    if (interactiveTextPath) {
        
        
        // allow for two views of the interactive text
        NSString *secondaryInteractiveTextPath=[labelDict objectForKey:@"secondaryInteractiveTextPath"];
        if (secondaryInteractiveTextPath) {
            self.readTextZoomViewController = [[[ReadTextZoomViewController alloc] init] autorelease];
            [[[[Angelina_AppDelegate get] currentRootViewController] view] addSubview:self.readTextZoomViewController.view];
            
            //create the textview
            iTextView=[[cdaInteractiveTextView textViewWithFrame:CGRectZero wordsPlistPath:[cdaGlobalFunctions cdaPath: interactiveTextPath] andSecondaryPlistFile:[cdaGlobalFunctions cdaPath:secondaryInteractiveTextPath] withSecondaryView:self.readTextZoomViewController.textView] retain];
        }
        else {
            iTextView=[[cdaInteractiveTextView textViewWithFrame:CGRectZero wordsPlistPath:[cdaGlobalFunctions cdaPath: interactiveTextPath]] retain];   
        }
        
        if (iTextView) {

            CGSize size = [[CCDirector sharedDirector] winSize];
            UIImage *textImage=[cdaGlobalFunctions imageFromView:iTextView];
            
            /* This is a special hack to handle a bug in the iPad 2 open GL drivers.
             * There are sometimes problems with zbuffer on 3d transitions if
             * textures are too big. 128x128 seems to work fine, so we'll split
             * the text image into chunks of that size.
             *
             * More info:
             * http://www.cocos2d-iphone.org/forum/topic/14495
             * https://devforums.apple.com/message/414331
             * http://www.imgtec.com/forum/forum_posts.asp?TID=1256&PID=4255
             */
            CCLayer *textLayer = [[[CCLayer alloc] init] autorelease];
            for (int x = 0; x < 1024; x += 128) {
                for (int y = 0; y < 1024; y += 128) {
                    if (x < textImage.size.width && y < textImage.size.height) {
                        CGImageRef imageRef = CGImageCreateWithImageInRect([textImage CGImage], CGRectMake(x, y, 128, 128));
                        UIImage *image = [UIImage imageWithCGImage:imageRef];
                        CGImageRelease(imageRef);
                    
                        CCTexture2D *texture=[[CCTexture2D alloc] initWithImage:image];
                        //[texture setAliasTexParameters];
                        CCSprite *textSprite=[CCSprite spriteWithTexture:texture];
                        [texture release];
                    
                        textSprite.anchorPoint=ccp(0,1);
                        textSprite.position=ccp(iTextView.frame.origin.x + x, size.height-(iTextView.frame.origin.y + y));
                        [textLayer addChild:textSprite];
                    }
                }
            }
            textLayer.tag=iTextViewTag;
            [self addChild:textLayer];
        }
        
        iTextView.alpha=0.0f;
        iTextView.tag=iTextViewTag;
        iTextView.delegate=self;
        [[[CCDirector sharedDirector] openGLView] addSubview:iTextView];
    }else
        iTextView=nil;
    
    
    //narration repeat button
	
	NSString *deviceSuffix= (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)?  @"~iphone" : @"~ipad";
	
	
	NSString *repeatButtonName=[NSString stringWithFormat:@"audio_reload%@%@.png",greySuffix,deviceSuffix];
	repeatButton=[[CCSprite spriteWithFile:repeatButtonName] retain];
	
    //do not show repeat narration button in text for iphone
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        repeatButton.visible = NO;
    }
    else {
        repeatButton.visible= [((Angelina_AppDelegate*)[[UIApplication sharedApplication] delegate]) getSaveNarrationSetting]==0;
    }
    
	CGPoint repeatButtonPosition = [iTextView getRepeatButtonPosition];
    repeatButton.position = CGPointMake(repeatButtonPosition.x, 768-repeatButtonPosition.y); // convert to cocos2d coord
	//repeatButton.opacity=0;
    if (repeatButton != nil) {
        [layer addChild:repeatButton z:1000 tag:6000];
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if ([[[data objectAtIndex:0] objectForKey:@"scenemetadata"] objectForKey:@"popover"])
            [[[Angelina_AppDelegate get] currentRootViewController] setPopover:[[[data objectAtIndex:0] objectForKey:@"scenemetadata"] objectForKey:@"popover"]];
        else
            [[[Angelina_AppDelegate get] currentRootViewController] setPopover:nil];  
    }
}

-(void) setReplayVisible{
	if (isScreenshot) {
		return;
	}
	//[PlaySoundAction setSoundsPrevented:NO];
    //[PlaySoundAction adjustGainOnFX:1.0f];
	if (!animating) {
		return;
	}
    
    ThomasRootViewController *rootViewController = [[Angelina_AppDelegate get] currentRootViewController];
    //do not show replay if we have a popover image
    if (rootViewController.popoverImageViewController != nil) {
        return;
    }

    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone){
        repeatButton.visible=YES;
    }

    //check if submenu is open then don't show the icon
    if ([rootViewController subMenuIsVisible]) {
        return;
    }
    [[rootViewController readOverlayViewController] narrationAttention];
    [self.readTextZoomViewController narrationAttention];

    CCRotateBy *rotate = [[[CCRotateBy alloc] initWithDuration:1.0 angle:720] autorelease];
    [repeatButton runAction:rotate];
    
}

-(void) setReplayHidden{
	if (isScreenshot) {
		return;
	}
	
	//[PlaySoundAction setSoundsPrevented:YES];
	//[PlaySoundAction stopSounds]; <--- Changing gain on all FX sound instead of turning off
    //[PlaySoundAction adjustGainOnFX:0.4f];
	if (!animating) {
		return;
	}
	repeatButton.visible=NO;
}

-(NSArray*) getHotspotIndicators {
    return self.hotspotIndicators;
}

-(void) setupPhysics{
	hasPhysics=YES;
	NSDictionary *physics=[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"scene%d_physics",page] ofType:@"plist"]];
	useAccelerometer=[[[physics objectForKey:@"data"] objectForKey:@"useAccelerometer"] boolValue];
	respawnObjects=[[[physics objectForKey:@"data"] objectForKey:@"respawnObjects"] boolValue];
	world=new b2World(b2Vec2([[[physics objectForKey:@"data"] objectForKey:@"gravityX"] floatValue],[[[physics objectForKey:@"data"] objectForKey:@"gravityY"] floatValue]),false);	
	
	//setup boundaries
	physicsBox=CGRectFromString([[physics objectForKey:@"data"] objectForKey:@"boundingBox"]);
	CGRect boundingBox=CGRectMake(physicsBox.origin.x/PTM_RATIO, physicsBox.origin.y/PTM_RATIO, physicsBox.size.width/PTM_RATIO, physicsBox.size.height/PTM_RATIO);
	b2BodyDef groundBodyDef;
	groundBody=world->CreateBody(&groundBodyDef);
	b2PolygonShape groundBox;
	b2FixtureDef boxShapeDef;
	boxShapeDef.shape=&groundBox;
	if ([[[physics objectForKey:@"data"] objectForKey:@"hasLeftWall"] boolValue]) {
		groundBox.SetAsEdge(b2Vec2(boundingBox.origin.x,boundingBox.origin.y),b2Vec2(boundingBox.origin.x,boundingBox.origin.y+boundingBox.size.height));
		groundBody->CreateFixture(&boxShapeDef);
	}
	if ([[[physics objectForKey:@"data"] objectForKey:@"hasRightWall"] boolValue]) {
		groundBox.SetAsEdge(b2Vec2(boundingBox.origin.x+boundingBox.size.width,boundingBox.origin.y),b2Vec2(boundingBox.origin.x+boundingBox.size.width,boundingBox.origin.y+boundingBox.size.height));
		groundBody->CreateFixture(&boxShapeDef);
	}
	if ([[[physics objectForKey:@"data"] objectForKey:@"hasTop"] boolValue]) {
		groundBox.SetAsEdge(b2Vec2(boundingBox.origin.x,boundingBox.origin.y+boundingBox.size.height),b2Vec2(boundingBox.origin.x+boundingBox.size.width,boundingBox.origin.y+boundingBox.size.height));
		groundBody->CreateFixture(&boxShapeDef);
	}
	if ([[[physics objectForKey:@"data"] objectForKey:@"hasBottom"] boolValue]) {
		groundBox.SetAsEdge(b2Vec2(boundingBox.origin.x,boundingBox.origin.y),b2Vec2(boundingBox.origin.x+boundingBox.size.width,boundingBox.origin.y));
		groundBody->CreateFixture(&boxShapeDef);
		
	}
	
	//create objects
	NSArray *objects=[physics objectForKey:@"objects"];
	NSArray *definitions=[[physics objectForKey:@"data"] objectForKey:@"definitions"];
	for (uint i=0; i<[objects count]; ++i) {
		NSDictionary *object=[objects objectAtIndex:i];
		NSDictionary *definition=[definitions objectAtIndex:[[object objectForKey:@"definition"] intValue]];
		PhysicsSprite *sprite=[PhysicsSprite spriteWithFile:[definition objectForKey:@"image"]];
		if ([definition objectForKey:@"spriteOffset"]!=nil) {
			sprite.spriteOffset=CGSizeFromString([definition objectForKey:@"spriteOffset"]);
		}
		if ([definition objectForKey:@"preventRotation"]!=nil) {
			sprite.preventRotation=[[definition objectForKey:@"preventRotation"] boolValue];
		}
		sprite.position=ccp([[object objectForKey:@"x"] floatValue]+sprite.spriteOffset.width,[[object objectForKey:@"y"] floatValue]+sprite.spriteOffset.height);
		sprite.rotation=[[object objectForKey:@"rotation"] floatValue];
		sprite.canGrab=[[definition objectForKey:@"canGrab"] boolValue];
		sprite.startPosition=sprite.position;
		sprite.startVelocity=ccp([[object objectForKey:@"impulseX"] floatValue],[[object objectForKey:@"impulseY"] floatValue]);
		sprite.startRotation=sprite.rotation;
		sprite.startSpin=[[object objectForKey:@"spin"] floatValue];
		[layer addChild:sprite z:1001 tag:9000+i];
		
		
		
		b2BodyDef bodyDef;
		bodyDef.type=b2_dynamicBody;
		bodyDef.position.Set(sprite.position.x/PTM_RATIO,sprite.position.y/PTM_RATIO);
		bodyDef.angle=-1*CC_DEGREES_TO_RADIANS(sprite.rotation);
		bodyDef.userData=sprite;
		b2Body *body=world->CreateBody(&bodyDef);
		
		b2FixtureDef shapeDef;
		
		if ([definition objectForKey:@"radius"]!=nil) {
			b2CircleShape circle;
			circle.m_radius=[[definition objectForKey:@"radius"] floatValue]/PTM_RATIO;
			shapeDef.shape=&circle;
		}else {
			b2PolygonShape box;
			box.SetAsBox([[definition objectForKey:@"width"] floatValue]/PTM_RATIO/2, [[definition objectForKey:@"height"] floatValue]/PTM_RATIO/2);
			shapeDef.shape=&box;
		}		
		
		shapeDef.density=[[definition objectForKey:@"density"] floatValue];
		shapeDef.friction=[[definition objectForKey:@"friction"] floatValue];
		shapeDef.restitution=[[definition objectForKey:@"restitution"] floatValue];
		body->CreateFixture(&shapeDef);
		
		body->SetLinearVelocity(b2Vec2(sprite.startVelocity.x,sprite.startVelocity.y));
		body->SetAngularVelocity(sprite.startSpin);
	}
}

-(void)setupFog:(NSDictionary *)fogDict{
	hasFog=YES;
	fog = new FluidField();
	fog->init();
	
	//set parameters;
	fog->setGridSize(GRID_COLUMNS,GRID_ROWS);
	int fogWidth=[[fogDict objectForKey:@"width"] intValue];
	int fogHeight=[[fogDict objectForKey:@"height"] intValue];
	fog->setDisplaySize(fogWidth,fogHeight);
	fog->setSpawnArea([[fogDict objectForKey:@"spawnTop"] intValue],[[fogDict objectForKey:@"spawnBottom"] intValue]);
	fog->setDensity([[fogDict objectForKey:@"density"] floatValue]);
	fog->setTurbulence([[fogDict objectForKey:@"turbulence"] floatValue]);
	fog->setNoiseScale([[fogDict objectForKey:@"noiseScaleX"] floatValue], [[fogDict objectForKey:@"noiseScaleY"] floatValue]);
	fog->setWindSpeed([[fogDict objectForKey:@"windSpeed"] floatValue]);
	if ([fogDict objectForKey:@"force"]!=nil) {
		fog->setForce([[fogDict objectForKey:@"force"] floatValue]);
	}
	if ([fogDict objectForKey:@"viscosity"]!=nil) {
		fog->setViscosity([[fogDict objectForKey:@"viscosity"] floatValue]);
	}
	int border=[[fogDict objectForKey:@"topBorder"] intValue];
	if (border!=-1) {
		fog->setTopBorder(border);
	}
	border=[[fogDict objectForKey:@"bottomBorder"] intValue];
	if (border!=-1) {
		fog->setBottomBorder(border);
	}
	/*border=[[fogDict objectForKey:@"leftBorder"] intValue];
	if (border!=-1) {
		fog->setLeftBorder(border);
	}
	border=[[fogDict objectForKey:@"rightBorder"] intValue];
	if (border!=-1) {
		fog->setRightBorder(border);
	}*/
	fog->clear();
	
	fogReveal=NO;
	if ([fogDict objectForKey:@"reveal"]!=nil) {
		fogReveal=YES;
		fog->setThickness(1.0f);
		fogRevealStart=[[[fogDict objectForKey:@"reveal"] objectForKey:@"start"] floatValue];
		fogRevealDuration=[[[fogDict objectForKey:@"reveal"] objectForKey:@"duration"] floatValue];
		fogRevealTimer=0;
	}

	// Set up fog
	fogTexture = [[CCTexture2D alloc] initWithData:fog->getData(0) pixelFormat:kCCTexture2DPixelFormat_RGBA8888 pixelsWide:GRID_COLUMNS pixelsHigh:GRID_ROWS contentSize:CGSizeMake(GRID_COLUMNS,GRID_ROWS)];
	
	FogSprite *fogSprite = [FogSprite spriteWithTexture:fogTexture];
	fogX=[[fogDict objectForKey:@"x"] floatValue];
	fogSprite.position = ccp( fogX, [[fogDict objectForKey:@"y"] floatValue] );
	fogSprite.scaleX = (float)fogWidth/(float)GRID_COLUMNS;
	fogSprite.scaleY = (float)fogHeight/(float)GRID_ROWS;
	
	[layer addChild:fogSprite z:[[fogDict objectForKey:@"z"] intValue] tag:1000];
}

-(void)update:(ccTime)dt{
	if (isScreenshot) {
		return;
	}
	
	if (hasPhysics) {
		world->Step(dt, 10, 10);
		for (b2Body *b = world->GetBodyList(); b; b=b->GetNext()) {		
			if (b->GetUserData() !=NULL) {
				PhysicsSprite *objectData=(PhysicsSprite *)b->GetUserData();			
				if (b->GetPosition().x*PTM_RATIO<-500 || b->GetPosition().x*PTM_RATIO>1524 || b->GetPosition().y*PTM_RATIO<-500 || b->GetPosition().y*PTM_RATIO>1268) {
					if (respawnObjects) {
						b->SetTransform(b2Vec2(objectData.startPosition.x/PTM_RATIO,objectData.startPosition.y/PTM_RATIO),-1*CC_DEGREES_TO_RADIANS(objectData.startRotation));
						b->SetLinearVelocity(b2Vec2(objectData.startVelocity.x,objectData.startVelocity.y));
						b->SetAngularVelocity(objectData.startSpin);
					}else {
						b->SetAwake(false);
						[self removeChild:(PhysicsSprite*)b->GetUserData() cleanup:YES];
						b->SetUserData(NULL);
						continue;
					}
				}
				
				objectData.position=ccp(b->GetPosition().x*PTM_RATIO+objectData.spriteOffset.width,b->GetPosition().y*PTM_RATIO+objectData.spriteOffset.height);
				if (!objectData.preventRotation) {
					objectData.rotation=-1*CC_RADIANS_TO_DEGREES(b->GetAngle());
				}
			}
		}
	}
	if (hasFog) {
		
		if (fogReveal) {
			fogRevealTimer+=dt;
			if (fogRevealStart>=0) {
				if (fogRevealTimer>=fogRevealStart) {
					fogRevealStart=-1;
					fogRevealTimer=0;
				}
			}else if (fogRevealDuration>0) {
				if (fogRevealTimer>=fogRevealDuration) {
					fog->setThickness(0);
					fogReveal=NO;
				}else {
					fog->setThickness(1.0f-(fogRevealTimer/fogRevealDuration));
				}				
			}
		}		
		fog->update();
		GLuint texId = fogTexture.name;
		glBindTexture(GL_TEXTURE_2D,texId);
		glTexSubImage2D(GL_TEXTURE_2D, 0,0,0,GRID_COLUMNS,GRID_ROWS,GL_RGBA,GL_UNSIGNED_BYTE,fog->getData(dt));
	}
}

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{
	if (isScreenshot) {
		return;
	}
	
	//apply the accelerometer values to physics engine
	b2Vec2 gravity;
	if (landscapeRight) {
		gravity=b2Vec2(-acceleration.y*15,acceleration.x*15);
	}else {
		gravity=b2Vec2(acceleration.y*15,-acceleration.x*15);
	}	
	world->SetGravity(gravity);
}

-(void)orientationChanged:(BOOL)isLandscapeRight{
	if (isScreenshot) {
		return;
	}
	
	if (hasPhysics && useAccelerometer && landscapeRight!=isLandscapeRight) {
		b2Vec2 oldgravity=world->GetGravity();
		world->SetGravity(b2Vec2(-oldgravity.x,-oldgravity.y));
	}
	landscapeRight=isLandscapeRight;
}

-(void)addRecursive:(NSDictionary *)data:(CCNode *)currentNode{
	//recursively adds an object and its children to the scene
	SceneComponent *currentComponent=[componentsByName objectForKey:[data objectForKey:@"name"]];
	[currentNode addChild:[currentComponent getCocosNode] z:currentComponent.z];
	//NSLog(@"adding recursive %@", currentComponent.name);
	NSArray *children=[data objectForKey:@"children"];
	for (uint i=0; i<[children count]; ++i) {
		[self addRecursive:[children objectAtIndex:i] :[currentComponent getCocosNode]];
	}
}

-(void)removeRecursive:(CCNode *)node{
	for (CCNode *child in [node children]) {
		[self removeRecursive:child];
	}
	[node removeAllChildrenWithCleanup:YES];
}

-(void)cocosDidStop {
    [self.readTextZoomViewController hideAnimated:NO];
}

-(void)stopAnimation{
	if (isScreenshot) {
		return;
	}
	
	if (!animating) {
		return;
	}
	animating=NO;
	//NSLog(@"Page %d: stopAnimation",page);
	//turn off physics
	if (hasPhysics || hasFog) {
		[self unschedule:@selector(update:)];
		if (hasPhysics) {
			layer.isAccelerometerEnabled=NO;
		}		
		/*if (hasFog) {
			[layer getChildByTag:1000].visible=NO;
		}*/
	}
	
	//stop sound
	if (bgSound!=nil) {
		[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	}
	
	//stop animations
	for (uint i=0; i<[components count]; ++i) {
		[[components objectAtIndex:i] stopAnimations];
	}
}


-(void)startAnimation{
	if (isScreenshot) {
		return;
	}
	
	if (animating) {
		return;
	}
	animating=YES;
	
	//NO FADE ON TEXTS IN READ
	/*
	[label runAction:[CCPropertyAction actionWithDuration:0.0f key:@"opacity" from:0 to:255]];
	[repeatButton runAction:[CCPropertyAction actionWithDuration:0.0f key:@"opacity" from:0 to:255]];
	*/
	
	//NSLog(@"Page %d: startAnimation",page);
	//turn on physics
	if (hasPhysics || hasFog) {
		[self schedule:@selector(update:) interval:1.0/60.0];
		if (hasPhysics) {
			layer.isAccelerometerEnabled=useAccelerometer;
		}
		/*if (hasFog) {
			[layer getChildByTag:1000].visible=YES;
		}*/
	}
	//start sound
	if (bgSound!=nil) {
		Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
		if (appDelegate.fxPlayer.playing) [appDelegate stopFXPlayback];
		[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:bgVolume];
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:bgSound loop:bgRepeat];
	}
	//start "start-type" animations
	for (uint i=0; i<[components count]; ++i) {
		[[components objectAtIndex:i] runStartAnimations];
	}
}
-(BOOL) isAnimating {
	return animating;
}
-(void)triggerAnimationByName:(NSString *)name{
	if (isScreenshot) {
		return;
	}
    //stop movies
	for (uint i=0; i<[components count]; ++i) {
		[[components objectAtIndex:i] stopMovies];
	}
	[[componentsByName objectForKey:name] triggerAnimations];
    if(iTextView) [self popTextOverVideo];

}

-(void) onEnterTransitionDidFinish{
	//call appdelegate to clean up after transition
	[super onEnterTransitionDidFinish];
	//NSLog(@"onEnterTransitionDidFinish");
		[[[Angelina_AppDelegate get] currentRootViewController] sceneTransitionDone];

    iTextView.alpha=1.0f;
    
    CCNode *textLayer = [self getChildByTag:iTextViewTag];
    textLayer.visible = NO;
    
    //[self removeChild:[self getChildByTag:iTextViewTag] cleanup:YES];
    //[iTextView play];// FIXME: remove me
    
}

-(void)dealloc{
	if (text) [text release];
	if (isScreenshot) {
		[self removeAllChildrenWithCleanup:YES];
	}else {
		[self removeRecursive:layer];
		[self removeAllChildrenWithCleanup:YES];
		if (world) {
			delete world;
			world=NULL;
		}
		if (fog) {
			delete fog;
			fog=NULL;
		}
		[repeatButton release];
		[bgSound release];
		[fogTexture release];
		[layer release];
		[label release];
		for (uint i=0; i<[components count]; ++i) {
			[[components objectAtIndex:i] killAnimations];
		}
		[components release];
		[componentsByName release];
	}
    self.hotspotIndicators = nil;
    for (cdaInteractiveTextView *v in [[[CCDirector sharedDirector]openGLView] subviews]) {
        if (v.tag==iTextViewTag && v.delegate == self) {
            [v removeFromSuperview];
            [v release];
            
        }
    }
    
    if (self.readTextZoomViewController != nil) {
        [self.readTextZoomViewController.view removeFromSuperview];
        self.readTextZoomViewController = nil;
    }
	[super dealloc];
}


//checks for dynamic, grabbable physics objects
struct QueryCallback : b2QueryCallback {
	QueryCallback(const b2Vec2& point){
		this->point=point;
		fixture=NULL;
	}
	
	bool ReportFixture(b2Fixture* fixture){
		b2Body *body=fixture->GetBody();
		if (body->GetType() == b2_dynamicBody && ((PhysicsSprite*)body->GetUserData()).canGrab) {
			if (fixture->TestPoint(point)){
				this->fixture=fixture;
				return false;
			}
		}
		return true;
	}
	
	b2Vec2 point;
	b2Fixture *fixture;
};

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	if (isScreenshot) {
		return NO;
	}
	
	
	CGPoint point=[touch locationInView:[[[Angelina_AppDelegate get] currentRootViewController] view]];

	
	CGPoint fogPoint=point;

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
		fogPoint.x/=kiPhoneLayerScale;
		fogPoint.y/=kiPhoneLayerScale;
	}

	if (hasFog) {
		fog->mouseDown((fogPoint.x-layerOffset.x)-(fogX-(fog->getWidth()/2)), fogPoint.y+layerOffset.y+fog->getHeight()-786);
	}
	
	touchedElement=-1;
	
	
	point=[[CCDirector sharedDirector] convertToGL:fogPoint];
	
	CGPoint physicsPoint=point;
	
	physicsPoint.x-=layerOffset.x;
	physicsPoint.y-=layerOffset.y;
	//grab physics object
	if (hasPhysics && touchedElement==-1 && mouseJoint==NULL) {
		touchPoint=b2Vec2(physicsPoint.x/PTM_RATIO,physicsPoint.y/PTM_RATIO);
		b2AABB aabb;
		b2Vec2 d=b2Vec2(0.001f,0.001f);
		aabb.lowerBound=touchPoint-d;
		aabb.upperBound=touchPoint+d;
		
		QueryCallback callback(touchPoint);
		world->QueryAABB(&callback, aabb);
		if (callback.fixture) {
			b2Body *grabbedBody=callback.fixture->GetBody();
			b2MouseJointDef md;
			md.bodyA=groundBody;
			md.bodyB=grabbedBody;
			md.target=touchPoint;
			md.maxForce=1000.0f*grabbedBody->GetMass();
			md.collideConnected=true;
			mouseJoint = (b2MouseJoint*)world->CreateJoint(&md);
		}
	}
	
	

	//repeat button
	CGRect box=CGRectMake(0, 0, repeatButton.contentSize.width, repeatButton.contentSize.height);
	if (mouseJoint==NULL && touchedElement==-1 && repeatButton.visible && CGRectContainsPoint(CGRectApplyAffineTransform(box, [repeatButton nodeToWorldTransform]), point)) {
		touchedElement=-2;
	}
	
	//label
	box=CGRectMake(0, 0, label.contentSize.width, label.contentSize.height);
	if (mouseJoint==NULL && touchedElement==-1 &&  CGRectContainsPoint(CGRectApplyAffineTransform(box, [label nodeToWorldTransform]), point)) {
		touchedElement=-3;
	}
	
	
	
	//click scene component

		BOOL getCocosPaused=[[[Angelina_AppDelegate get] currentRootViewController] getCocosPaused];
	
	
	if (mouseJoint==NULL && touchedElement==-1 && !getCocosPaused) {

		for (uint i=0; i<[components count]; ++i) {
			if ([[components objectAtIndex:i] isTouched:point]) {
				touchedElement=i;
				break;
			}
		}
	}
	
	return YES;
}

-(BOOL)isDraggingObject{
	return mouseJoint!=NULL;
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event{
	if (isScreenshot) {
		return;
	}
	
	CGPoint point=[touch locationInView:[[[Angelina_AppDelegate get] currentRootViewController] view]];

	
	CGPoint fogPoint=point;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
		fogPoint.x/=kiPhoneLayerScale;
		fogPoint.y/=kiPhoneLayerScale;
	}
	
	if (hasFog) {
		fog->mouseMove(fogPoint.x-layerOffset.x-(fogX-(fog->getWidth()/2)), fogPoint.y+layerOffset.y+fog->getHeight()-786);
	}
	
	//move physics object around
	if (hasPhysics && mouseJoint!=NULL) {
		point=[[CCDirector sharedDirector] convertToGL:fogPoint];
		

		point.x-=layerOffset.x;
		point.y-=layerOffset.y;
		if (!CGRectContainsPoint(physicsBox, point)) {
			world->DestroyJoint(mouseJoint);
			mouseJoint=NULL;
			return;
		}		
		touchPoint=b2Vec2(point.x/PTM_RATIO,point.y/PTM_RATIO);
		mouseJoint->SetTarget(touchPoint);
	}
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {	
    BOOL showHotspotIndicators = YES; //only show hotspot indicators for some touch events
    
	if (isScreenshot) {
		return;
	}

	if ([((Angelina_AppDelegate*)[[UIApplication sharedApplication] delegate]) getReadViewIsPaused]) {
		//NSLog(@"Touching");
		[((Angelina_AppDelegate*)[[UIApplication sharedApplication] delegate]) unPauseReadView];
        showHotspotIndicators = NO;
	}
	
	
	
	CGPoint point=[touch locationInView:[[[Angelina_AppDelegate get] currentRootViewController] view]];
	
	
	
	CGPoint fogPoint=point;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
		fogPoint.x/=kiPhoneLayerScale;
		fogPoint.y/=kiPhoneLayerScale;
	}

	
	if (hasFog) {
		fog->mouseUp(fogPoint.x-layerOffset.x-(fogX-(fog->getWidth()/2)), fogPoint.y+layerOffset.y+fog->getHeight()-786);
	}
	
	point=[[CCDirector sharedDirector] convertToGL:fogPoint];

	
	//repeat button - make touch ended area a double the size of the button
	CGRect box=CGRectMake(0, 0, repeatButton.contentSize.width*2, repeatButton.contentSize.height*2);
	if (mouseJoint==NULL && repeatButton.visible && touchedElement==-2 && CGRectContainsPoint(CGRectApplyAffineTransform(box, [repeatButton nodeToWorldTransform]), point)) {
		[[[Angelina_AppDelegate get] currentRootViewController] forceNarrationOnScene];
        showHotspotIndicators = NO;
	}
	
	//label
	box=CGRectMake(0, 0, label.contentSize.width, label.contentSize.height);
	if (mouseJoint==NULL && touchedElement==-3  && CGRectContainsPoint(CGRectApplyAffineTransform(box, [label nodeToWorldTransform]), point)) {
		
		[self showText];
        showHotspotIndicators = NO;
	}
	
	
	if (touchedElement>-1  && mouseJoint==NULL) {
		//click scene component
		[[components objectAtIndex:touchedElement] handleTouch:point];
        showHotspotIndicators = NO;
	}
    
    if (showHotspotIndicators) {
        [[[Angelina_AppDelegate get] currentRootViewController] showHotspotIndicators];
    }
	//release physics object
	if (hasPhysics && mouseJoint!=NULL) {
		world->DestroyJoint(mouseJoint);
		mouseJoint=NULL;
	}
}

-(void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event{
	if (isScreenshot) {
		return;
	}
	
	if (hasFog) {
		CGPoint fogPoint=[touch locationInView:[[[Angelina_AppDelegate get] currentRootViewController] view]];
		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
			fogPoint.x/=kiPhoneLayerScale;
			fogPoint.y/=kiPhoneLayerScale;
		}

		
		
		fog->mouseUp(fogPoint.x-layerOffset.x-(fogX-(fog->getWidth()/2)), fogPoint.y+layerOffset.y+fog->getHeight()-786);
	}
	
	//release physics object
	if (hasPhysics && mouseJoint!=NULL) {
		world->DestroyJoint(mouseJoint);
		mouseJoint=NULL;
	}
}


-(void)turnIntoScreenshot{
	if (isScreenshot) {
        return;
    }
    
    //kill everything
    
    CCNode *textLayer = [[self getChildByTag:iTextViewTag] retain];
    
	[self stopAnimation];
	isScreenshot=YES;
	[self removeRecursive:layer];
	[self removeAllChildrenWithCleanup:YES];
	if (world) {
		delete world;
		world=NULL;
	}
	if (fog) {
		delete fog;
		fog=NULL;
	}
    
    // In Angelina we don't need a screenshot, and this slows down page 
    // transitions A LOT. Instead, just grab the bg and repeat button sprite
    // and display directly.
    CCSprite *bg = ((SceneComponent*)[components objectAtIndex:0]).sprite;
    bg.position = ccp(layerOffset.x, layerOffset.y);
    [self addChild:bg];
    if (repeatButton != nil) {
        [self addChild:repeatButton];
    }
    
	[repeatButton release];
	[bgSound release];
	[fogTexture release];
	[layer release];
	[label release];
	for (uint i=0; i<[components count]; ++i) {
		[[components objectAtIndex:i] killAnimations];
	}
    
	[components release];
	[componentsByName release];
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
	//[[CCTextureCache sharedTextureCache] removeUnusedTextures];
    
	//take screenshot
    {
        
        /*
        CGSize size=  [[CCDirector sharedDirector] winSize];
		GLuint bufferLength=size.width*size.height*4;
		GLubyte *buffer=(GLubyte *)malloc(bufferLength);
		glReadPixels(0, 0, size.width, size.height, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
        
        
        CCTexture2D * texture=[[CCTexture2D alloc] initWithData:buffer pixelFormat:kCCTexture2DPixelFormat_RGBA8888 pixelsWide:size.width pixelsHigh:size.height contentSize:size];
		free(buffer);
        
		//set screenshot as screen
		CCSprite *sprite=[CCSprite spriteWithTexture:texture];
		[texture release];
		sprite.flipY=YES;
        sprite.anchorPoint=CGPointMake(0, 0);
		[self addChild:sprite];
        */
        
        if (iTextView) {
            [iTextView stop];
            
            // Reuse screenshot if it already exists
            if (textLayer != nil) {
                [self addChild:textLayer];
                textLayer.visible = YES;
            } else {
                CGSize size=  [[CCDirector sharedDirector] winSize];
                UIImage *textImage=[cdaGlobalFunctions imageFromView:iTextView];
                CCTexture2D *texture=[[CCTexture2D alloc] initWithImage:textImage];
                //[texture setAliasTexParameters];
                CCSprite *textSprite=[CCSprite spriteWithTexture:texture];
                [texture release];
            
                textSprite.anchorPoint=ccp(0,1);
                textSprite.position=ccp(iTextView.frame.origin.x, size.height-iTextView.frame.origin.y);
                [self addChild:textSprite];
            }
        }
        
	}
    [iTextView removeFromSuperview];
    [iTextView release];
    iTextView = nil;
    [textLayer release];
}

#pragma mark Stars particleSystem
-(void)showStarsL{
    CCParticleSystemQuad *stars=[CCParticleSystemQuad particleWithFile:@"PageTurnStarsL.plist"];
    stars.autoRemoveOnFinish=YES;
    
    stars.startColor=(ccColor4F) {0.98, 0.71, 0.75,1.0f};
    stars.startColorVar=(ccColor4F) {0,0,0,0.2};
    stars.endColor=(ccColor4F)  {0.98, 0.71, 0.75,1.0f};
    stars.endColorVar=(ccColor4F) {0,0,0,1};
    
//    stars.angleVar=360;
//    stars.angle=0;
    stars.startSpin=0;
    stars.startSpinVar=45;
     
    CGSize winSize=[[CCDirector sharedDirector] winSize];
    //stars.position=ccp(0,winSize.height/2);
    stars.position=ccp(winSize.width,winSize.height/2);

    [self addChild:stars];
    
    CCMoveTo *move = [CCMoveTo actionWithDuration:.8 position:ccp(0,winSize.height/2)];
    [stars runAction:move];
    
    
    
    stars=[CCParticleSystemQuad particleWithFile:@"PageTurnStarsL.plist"];
    stars.autoRemoveOnFinish=YES;
    
    stars.startColor=(ccColor4F) {0.83,0.19,0.43,1.0f};
    stars.startColorVar=(ccColor4F) {0,0,0,0};
    stars.endColor=(ccColor4F) {0.83,0.19,0.43,1.0f};
    stars.endColorVar=(ccColor4F) {0,0,0,1};
    stars.startSpin=0;
    stars.startSpinVar=45;
    
    //stars.position=ccp(0,winSize.height/2);
    stars.position=ccp(winSize.width,winSize.height/2);
    [self addChild:stars];
    move = [CCMoveTo actionWithDuration:.8 position:ccp(0,winSize.height/2)];
    [stars runAction:move];
    
    stars=[CCParticleSystemQuad particleWithFile:@"PageTurnStarsL.plist"];
    stars.autoRemoveOnFinish=YES;
    
    stars.startColor=(ccColor4F) {0.87,0.19,0.34,1.0f};
    stars.startColorVar=(ccColor4F) {0,0,0,0};
    stars.endColor=(ccColor4F) {0.91,.56,.67,1.0f};
    stars.endColorVar=(ccColor4F) {0,0,0,1};
    stars.startSpin=0;
    stars.startSpinVar=95;
//    stars.startSize=
    
    //stars.position=ccp(0,winSize.height/2);
    stars.position=ccp(winSize.width,winSize.height/2);
    move = [CCMoveTo actionWithDuration:.8 position:ccp(0,winSize.height/2)];
    [self addChild:stars];

    [stars runAction:move];
}

-(void)showStarsR{
    CCParticleSystemQuad *stars=[CCParticleSystemQuad particleWithFile:@"PageTurnStarsR.plist"];
    stars.autoRemoveOnFinish=YES;

    stars.startColor=(ccColor4F) {0.98, 0.71, 0.75,1.0f};
    stars.startColorVar=(ccColor4F) {0,0,0,0.2};
    stars.endColor=(ccColor4F)  {0.98, 0.71, 0.75,1.0f};
    stars.endColorVar=(ccColor4F) {0,0,0,1};
    
    
//    stars.angleVar=360;
//    stars.angle=0;
    stars.startSpin=0;
    stars.startSpinVar=0;
    
    CGSize winSize=[[CCDirector sharedDirector] winSize];
    stars.position=ccp(0,winSize.height/2);
    [self addChild:stars];
    CCMoveTo *move = [CCMoveTo actionWithDuration:.8 position:ccp(winSize.width,winSize.height/2)];
    [stars runAction:move];
    
    stars=[CCParticleSystemQuad particleWithFile:@"PageTurnStarsR.plist"];
    stars.autoRemoveOnFinish=YES;
    
    stars.startColor=(ccColor4F) {0.83,0.19,0.43,1.0f};
    stars.startColorVar=(ccColor4F) {0,0,0,0};
    stars.endColor=(ccColor4F) {0.83,0.19,0.43,1.0f};
    stars.endColorVar=(ccColor4F) {0,0,0,1};
    stars.startSpin=0;
    stars.startSpinVar=45;
    
    stars.position=ccp(0,winSize.height/2);
    [self addChild:stars];
    move = [CCMoveTo actionWithDuration:0.8 position:ccp(winSize.width,winSize.height/2)];
    [stars runAction:move];
    
    
    stars=[CCParticleSystemQuad particleWithFile:@"PageTurnStarsR.plist"];
    stars.autoRemoveOnFinish=YES;
    
    stars.startColor=(ccColor4F) {0.87,0.19,0.34,1.0f};
    stars.startColorVar=(ccColor4F) {0,0,0,0};
    stars.endColor=(ccColor4F) {0.91,.56,.67,1.0f};
    stars.endColorVar=(ccColor4F) {0,0,0,1};
    stars.startSpin=0;
    stars.startSpinVar=95;
    //    stars.startSize=
    
    stars.position=ccp(0,winSize.height/2);
    [self addChild:stars];
     move = [CCMoveTo actionWithDuration:.8 position:ccp(winSize.width,winSize.height/2)];
    [stars runAction:move];
    
}

#pragma mark InteractiveText
-(void)popTextOverVideo{
    [[[CCDirector sharedDirector] openGLView] bringSubviewToFront:iTextView];
}
-(void)recordVoiceForKey{
	if ([iTextView isRecordingAudio]) {
		[iTextView stopRecordingAndSave:YES];
	}else {
		[iTextView recordVoiceForKey:@"sample1"];
	}
}

-(void)playRec{
    
	[iTextView playRecordingForKey:@"sample1"];
}
-(BOOL)cdaInteractiveTextView:(cdaInteractiveTextView *)interactiveTextView shouldHighlightWordItem:(cdaInteractiveTextItem *)wordIdem{
	CDA_LOG_METHOD_NAME;
	return YES;
}
-(void)play{
	[self performSelector:@selector(removeSubviews) withObject:nil afterDelay:3];
}


//playback
-(void)cdaInteractiveTextViewDidStartPlayback:(cdaInteractiveTextView *)interactiveTextView recordedAudio:(BOOL)isRecordedAudio{
    
}
-(void)cdaInteractiveTextViewDidStopPlayback:(cdaInteractiveTextView *)interactiveTextView recordedAudio:(BOOL)isRecordedAudio{
    [[[Angelina_AppDelegate get] currentRootViewController] narrationFinished];
}
-(BOOL)cdaInteractiveTextView:(cdaInteractiveTextView *)interactiveTextView shouldSelectWordItem:(cdaInteractiveTextItem *)wordItem{
    return (wordItem.popoverImageFilePath!=nil);
}
-(void)cdaInteractiveTextView:(cdaInteractiveTextView *)interactiveTextView
                   wordTapped:(cdaInteractiveTextItem *)wordItem
                     position:(CGPoint )position
{
    if (self.readTextZoomViewController != nil){
        [self.readTextZoomViewController show];
    }
    else {
        if (wordItem.popoverImageFilePath != nil) {
            ThomasRootViewController *rootViewController =
            [[Angelina_AppDelegate get] currentRootViewController];
            
            [rootViewController showPopoverImage:wordItem.popoverImageFilePath withSourcePosition:[wordItem convertPoint:position toView:rootViewController.view]];
        }
    }
}

#pragma mark CocoaBridge to display text overlay

-(void)showText{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
		if ([[Angelina_AppDelegate get] getSaveReadEnlargeTextSetting]) {
			[[[Angelina_AppDelegate get] currentRootViewController] showReadOverlayViewWithText:text style:style];
		}
	}
}

# pragma mark - cdaInteractiveTextView audio control
- (void)pauseAudio
{
    if (!isScreenshot) {
        [iTextView pause];
    }
}
- (void)unpauseAudio
{
    if (!isScreenshot) {
        [iTextView unpause];
    }
}
- (void)playAudio
{
    if (!isScreenshot) {
        [iTextView play];
        if ([AVQueueManager sharedAVQueueManager].paused) {
            [self setReplayVisible];
        }
    }
}

-(void)restartAudio {
    if (!isScreenshot) {
        [iTextView restart];
    }    
}
- (void)stopAudio
{
    if (!isScreenshot) {
        [iTextView stop];
    }
}
- (BOOL)isPlayingAudio
{
    return isScreenshot ? NO : [iTextView isPlayingNativeAudio];
}
@end
