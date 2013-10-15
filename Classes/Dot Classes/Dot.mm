//
//  Dot.mm
//  Misty-Island-Rescue-iPad
//
//  Created by Johannes Amilon on 11/25/10.
//  Copyright 2010 Vitamin Se Media AB. All rights reserved.
//

#import "Dot.h"


@implementation Dot

@synthesize dotX,dotY,cp1X,cp1Y,cp2X,cp2Y,type,dotNum,dotState;

+(id)dotWithDictionary:(NSDictionary *) dict{
	return [[[self alloc] initWithDictionary:dict] autorelease];
}

-(id) initWithDictionary:(NSDictionary *)dict{
	if ((self=[super init])) {
		dotX=[[dict objectForKey:@"x"] floatValue];
		dotY=[[dict objectForKey:@"y"] floatValue];
		
		if ([dict objectForKey:@"dot"]) {
			dotNum=[[dict objectForKey:@"dot"] intValue];
			dotState=0;
		}else {
			dotNum=-1;
			dotState=-1;
		}
		
		NSString *typeString=[dict objectForKey:@"type"];
		if ([typeString isEqual:@"start"]) {
			type=0;
		}else if ([typeString isEqual:@"line"]) {
			type=1;
		}else{
			type=2;
			cp1X=[[dict objectForKey:@"cp1x"] floatValue];
			cp1Y=[[dict objectForKey:@"cp1y"] floatValue];
			cp2X=[[dict objectForKey:@"cp2x"] floatValue];
			cp2Y=[[dict objectForKey:@"cp2y"] floatValue];
		}
		
	}
	return self;
}

@end
