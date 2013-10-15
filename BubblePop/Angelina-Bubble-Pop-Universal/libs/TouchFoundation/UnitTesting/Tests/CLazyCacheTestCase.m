//
//  CLazyCacheTestCase.m
//  TouchCode
//
//  Created by Jonathan Wight on 6/25/09.
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

#import "CLazyCacheTestCase.h"

#import "CLazyCache.h"

@implementation CLazyCacheTestCase

- (void)testCache1
{
CLazyCache *theCache = [[[CLazyCache alloc] initWithCapacity:2] autorelease];
STAssertEquals(theCache.capacity, 2U, @"Capacity doesn't match");
STAssertEquals(theCache.count, 0U, @"Count not 0");
[theCache cacheObject:@"A" forKey:@"1"];
STAssertEquals(theCache.count, 1U, @"Count not 1");
[theCache cacheObject:@"B" forKey:@"2"];
STAssertEquals(theCache.count, 2U, @"Count not 2");
[theCache cacheObject:@"C" forKey:@"3"];
STAssertEquals(theCache.count, 2U, @"Count not 2");

STAssertEqualObjects([theCache cachedObjectForKey:@"3"], @"C", @"Mismatch");
STAssertEqualObjects([theCache cachedObjectForKey:@"2"], @"B", @"Mismatch");
STAssertEqualObjects([theCache cachedObjectForKey:@"1"], NULL, @"Mismatch");
}

@end
