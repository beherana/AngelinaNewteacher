//
//  CCommaArrayTransformer.m
//  TouchCode
//
//  Created by brandon on 5/5/09.
//  Copyright 2009 toxicsoftware.com. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "CCommaArrayTransformer.h"

@implementation CCommaArrayTransformer

+ (BOOL)allowsReverseTransformation
{
	return(NO);
}

- (id)transformedValue:(id)value
{
	NSAssert([value isKindOfClass:[NSArray class]], @"CCommaArrayTransformer: value must be an NSArray!");
		
	NSMutableString *result = [[[NSMutableString alloc] init] autorelease];
	NSArray *array = value;
	for (NSObject *item in array)
	{
		if ([array objectAtIndex:0] == item)
			[result appendString:[item description]];
		else
			[result appendFormat:@",%@", [item description]];
	}
	return(result);
}

@end
