//
//  UnitTesting.m
//  TouchCode
//
//  Created by Jonathan Wight on 20090528.
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

#import <Foundation/Foundation.h>

#import "CLazyCache.h"

@interface CLazyCache ()
@property (readonly, retain, nonatomic) NSMutableDictionary *cachedObjectsByKey;
@property (readonly, retain, nonatomic) NSMutableArray *cachedKeys;
@end

int main (int argc, const char * argv[])
{
NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

CLazyCache *theCache = [[[CLazyCache alloc] initWithCapacity:1] autorelease];
NSLog(@"%d/%d/%d", theCache.capacity, theCache.cachedObjectsByKey.count, theCache.cachedKeys.count);
[theCache cacheObject:@"1" forKey:@"1"];
NSLog(@"%d/%d/%d", theCache.capacity, theCache.cachedObjectsByKey.count, theCache.cachedKeys.count);
[theCache cacheObject:@"2" forKey:@"2"];
NSLog(@"%d/%d/%d", theCache.capacity, theCache.cachedObjectsByKey.count, theCache.cachedKeys.count);


[pool drain];
return 0;
}
