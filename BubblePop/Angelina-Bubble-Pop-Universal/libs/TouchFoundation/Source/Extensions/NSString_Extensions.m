//
//  NSString_Extensions.m
//  TouchCode
//
//  Created by Jonathan Wight on 07/01/08.
//  Copyright 2008 toxicsoftware.com. All rights reserved.
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

#import "NSString_Extensions.h"

#import "NSScanner_HTMLExtensions.h"

@implementation NSString (NSString_Extensions)

- (NSString *)stringByTidyingHTMLEntities
{
NSMutableString *theOutput = [NSMutableString string];

NSScanner *theScanner = [NSScanner scannerWithString:self];
[theScanner setCharactersToBeSkipped:NULL];

while ([theScanner isAtEnd] == NO)
	{
	NSString *theString = NULL;
	if ([theScanner scanUpToString:@"&" intoString:&theString] == YES)
		{
		[theOutput appendString:theString];
		}
	if ([theScanner scanHTMLEntityIntoString:&theString] == YES)
		{
		[theOutput appendString:theString];
		}
	else
		{
		if ([theScanner scanString:@"&" intoString:&theString] == YES)
			{
			[theOutput appendString:theString];
			}
		}
	}

return([[theOutput copy] autorelease]);
}

- (NSArray *)componentsSeperatedByWhitespaceRunsOrComma
{
    NSMutableCharacterSet *theCommaCharacterSet = [[[NSCharacterSet characterSetWithCharactersInString:@","] mutableCopy] autorelease];
    [theCommaCharacterSet formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return [self componentsSeparatedByRunsFromCharacterSet:theCommaCharacterSet];
}

- (NSArray *)componentsSeparatedByRunsFromCharacterSet:(NSCharacterSet *)characterSet
{
    NSMutableArray *theArray = [NSMutableArray array];
    NSCharacterSet *contentSet = [characterSet invertedSet];
    
    NSScanner *theScanner = [NSScanner scannerWithString:self];
    while (![theScanner isAtEnd])
	{
        [theScanner scanCharactersFromSet:characterSet intoString:NULL];
        
        NSString *theValue = NULL;
        if ([theScanner scanCharactersFromSet:contentSet intoString:&theValue] == YES)
		{
            [theArray addObject:theValue];
		}
	}
    return(theArray);
}

#pragma mark -

- (long)asLongFromHex
{
long theValue = strtol([self UTF8String], NULL, 16);
return(theValue);
}

- (NSString *)stringByAddingPercentEscapesWithCharactersToLeaveUnescaped:(NSString *)inCharactersToLeaveUnescaped legalURLCharactersToBeEscaped:(NSString *)inLegalURLCharactersToBeEscaped
{
NSString *theEscapedString = [(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, (CFStringRef)inCharactersToLeaveUnescaped, (CFStringRef)inLegalURLCharactersToBeEscaped, kCFStringEncodingUTF8) autorelease];

return(theEscapedString);
}

- (NSString *)stringByObsessivelyAddingPercentEscapes
{
return([self stringByAddingPercentEscapesWithCharactersToLeaveUnescaped:@"abcdefghijklmnopqrstuvwyxzABCDEFGHIJKLMNOPQRSTUVWXYZ123456780" legalURLCharactersToBeEscaped:@"/=&?"]);
}

- (NSString *)stringByFlatteningHTML
{
    NSMutableArray *components = [NSMutableArray array];
    NSScanner *scanner = [NSScanner scannerWithString:self];
    
    while (![scanner isAtEnd])
    {
        NSString *thisComponent = @"";
        
        [scanner scanUpToString:@"<" intoString:&thisComponent];
        [scanner scanUpToString:@">" intoString:nil];
        [scanner scanString:@">" intoString:nil];
        
        if (thisComponent.length > 0)
            [components addObject:thisComponent];
    }
    
    NSString *flattenedString = [components componentsJoinedByString:@" "];
    return flattenedString;
}

@end
