//
//  Dot.h
//  Misty-Island-Rescue-iPad
//
//  Created by Johannes Amilon on 11/25/10.
//  Copyright 2010 Vitamin Se Media AB. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Dot : NSObject {
	float dotX;
	float dotY;
	float cp1X;
	float cp1Y;
	float cp2X;
	float cp2Y;
	int type;
	int dotNum;
	int dotState;
}

@property (nonatomic,readonly) float dotX;
@property (nonatomic,readonly) float dotY;
@property (nonatomic,readonly) float cp1X;
@property (nonatomic,readonly) float cp1Y;
@property (nonatomic,readonly) float cp2X;
@property (nonatomic,readonly) float cp2Y;
@property (nonatomic,readonly) int type;
@property (nonatomic,readonly) int dotNum;
@property (nonatomic) int dotState;

+(id)dotWithDictionary:(NSDictionary *) dict;

-(id)initWithDictionary:(NSDictionary *) dict;

@end
