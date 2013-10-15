//
//  cdaPortability
//  
//
//  Created by Radif Sharafullin on 2/3/11.
//  Copyright 2011 Callaway Digital Arts. All rights reserved.
//

#if TARGET_OS_IPHONE
#define cdaView UIView
#define cdaViewController UIViewController
#define cdaColor UIColor
#define cdaPoint CGPoint
#define cdaPointMake(x, y) CGPointMake(x, y)
#define cdaRect CGRect
#define cdaRectMake(x,y,h,w) CGRectMake(x,y,h,w)
#define cdaRectInset(rect,dx,dy) CGRectInset(rect,dx,dy)


#else


#define cdaView NSView
#define cdaViewController NSViewController
#define cdaColor NSColor
#define cdaPoint NSPoint

#define cdaPointMake(x, y) NSMakePoint(x, y)
#define cdaRect NSRect
#define cdaRectMake(x,y,h,w) NSMakeRect(x,y,h,w)
#define cdaRectInset(rect,dx,dy) NSInsetRect(rect,dx,dy)
#endif