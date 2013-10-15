//
//  PaintView.m
//  The Bird & The Snail
//
//  Created by Henrik Nord on 1/4/09.
//  Copyright 2009 Haunted House. All rights reserved.
//

#import "PaintView.h"
#import "PaintViewController.h"
#import "PaintHolderLandscapeViewController.h"

#define DEFAULT_POINTS_CAPACITY 4

@interface PaintView () 
@property (nonatomic, assign) PaintHolderLandscapeViewController *parent;
@property (nonatomic, retain) NSMutableArray *brushSizes;
@property (nonatomic, assign) CGContextRef paintBuffer;
@property (nonatomic, assign) CGLayerRef paintLayer;
@property (nonatomic, assign) CGContextRef paintLayerContext;
@property (nonatomic, retain) NSMutableArray *points;
@property (nonatomic, assign) float brushSize;
- (void)initPaintScene;
@end

@implementation PaintView
@synthesize parent = _parent;
@synthesize brushSizes = _brushSizes;
@synthesize paintBuffer = _paintBuffer;
@synthesize paintLayer = _paintLayer;
@synthesize paintLayerContext = _paintLayerContext;
@synthesize points = _points;
@synthesize brushSize = _brushSize;

-(void) initWithParent: (id) parent {
	self.parent = (PaintHolderLandscapeViewController *) parent;
	[self initPaintScene];
	
	return;
}

-(void)awakeFromNib {
	
	[super awakeFromNib];
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	self.paintBuffer = CGBitmapContextCreate(NULL, self.frame.size.width, self.frame.size.height, 8, 4 * self.frame.size.width, colorSpace, kCGImageAlphaPremultipliedFirst);
    self.paintLayer = CGLayerCreateWithContext(self.paintBuffer, self.frame.size, NULL);
    self.paintLayerContext = CGLayerGetContext(self.paintLayer);
	CGColorSpaceRelease(colorSpace);
}

- (void)initPaintScene {
    //setup brushsizes - different brush sizes for iphone
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.brushSizes = [NSArray arrayWithObjects: 
                            [NSNumber numberWithFloat:4.0],
                            [NSNumber numberWithFloat:18.75],
                            [NSNumber numberWithFloat:33.75],  
                            nil];
    }
    else {
        self.brushSizes = [NSArray arrayWithObjects: 
                            [NSNumber numberWithFloat:4.0],
                            [NSNumber numberWithFloat:18.75],
                            [NSNumber numberWithFloat:45.0],  
                            nil];
    }

    self.points = [NSMutableArray arrayWithCapacity:DEFAULT_POINTS_CAPACITY];
    
    // load old image
    NSString *fileName = [self fileName];
    NSLog(@"opening %@", fileName);
    UIImage *image = [UIImage imageWithContentsOfFile:fileName];
    if (image != nil) {
        CGContextRef context = CGLayerGetContext(self.paintLayer);
        CGSize size = CGLayerGetSize(self.paintLayer);
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), [image CGImage]);
    }
}


- (void)drawRect:(CGRect)rect {
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextClipToRect(currentContext, rect);
	CGContextDrawLayerInRect(currentContext, self.frame, self.paintLayer);
}

- (void)setupParameters {
    self.brushSize = [[self.brushSizes objectAtIndex:[self.parent getCurrentBrushsize] - 1] floatValue];
    CGContextSetLineWidth(self.paintLayerContext, self.brushSize);
	CGContextSetLineCap(self.paintLayerContext, kCGLineCapRound);
    CGContextSetRGBStrokeColor(self.paintLayerContext,
                               [self.parent getRedColor],
                               [self.parent getGreenColor],
                               [self.parent getBlueColor],
                               1.0);
    CGContextSetInterpolationQuality(self.paintLayerContext, kCGInterpolationHigh);
    CGContextSetShouldAntialias(self.paintLayerContext, YES);
    CGContextSetAllowsAntialiasing(self.paintLayerContext, YES);
}

- (void)drawLineFrom:(CGPoint)point1 to:(CGPoint)point2 {
    CGContextBeginPath(self.paintLayerContext);
	
    CGContextMoveToPoint(self.paintLayerContext, point1.x, point1.y);
    CGContextAddLineToPoint(self.paintLayerContext, point2.x, point2.y);
	CGContextStrokePath(self.paintLayerContext);
    
    float x = MIN(point1.x, point2.x) - self.brushSize/2;
    float y = MIN(point1.y, point2.y) - self.brushSize/2;
    float w = MAX(point1.x, point2.x) + self.brushSize/2 - x;
    float h = MAX(point1.y, point2.y) + self.brushSize/2 - y;    
    [self setNeedsDisplayInRect:CGRectMake(x, y, w, h)];
}

- (void)drawBezierCurve:(NSArray *)points {
    CGPoint p0 = [[points objectAtIndex:0] CGPointValue];
    CGPoint p1 = [[points objectAtIndex:1] CGPointValue];
    CGPoint p2 = [[points objectAtIndex:2] CGPointValue];
    CGPoint p3 = [[points objectAtIndex:3] CGPointValue];
    
    CGPoint b0 = p1;
    CGPoint b1 = CGPointMake(p1.x + (p2.x - p0.x) / 6,
                             p1.y + (p2.y - p0.y) / 6);
    CGPoint b2 = CGPointMake(p2.x + (p1.x - p3.x) / 6,
                             p2.y + (p1.y - p3.y) / 6);
    CGPoint b3 = p2;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, b0.x, b0.y);
    CGPathAddCurveToPoint(path, NULL, b1.x, b1.y, b2.x, b2.y, b3.x, b3.y);
    
    CGContextAddPath(self.paintLayerContext, path);
    CGContextStrokePath(self.paintLayerContext);
    
    CGRect boundingBox = CGPathGetBoundingBox(path);
    boundingBox = CGRectInset(boundingBox, -self.brushSize/2, -self.brushSize/2);
    [self setNeedsDisplayInRect:boundingBox];
    CGPathRelease(path);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
    [self.points removeAllObjects];
    [self setupParameters];
    
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
    [self.points addObject:[NSValue valueWithCGPoint:point]];
	
	[self.parent setSaveImageWarning];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
    //[self drawLineFrom:[[self.points lastObject] CGPointValue] to:point];
	[self.points addObject:[NSValue valueWithCGPoint:point]];
    if ([self.points count] == 4) {
        [self drawBezierCurve:self.points];
        [self.points removeObjectAtIndex:0];
    }
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
    [self.points addObject:[NSValue valueWithCGPoint:point]];
    
    if ([self.points count] < 4) {
        CGPoint p = [[self.points lastObject] CGPointValue];
        [self drawLineFrom:p to:p];
    } else {
        [self drawBezierCurve:self.points];
    }
}

- (NSString*)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"saved_paint_%i.png", [self.parent getCurrentPaintImage]]];
}

- (void)save
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGSize size = CGLayerGetSize(self.paintLayer);
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 size.width,
                                                 size.height,
                                                 8,
                                                 0,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast);
    
    CGColorSpaceRelease(colorSpace);    
    
    CGContextDrawLayerInRect(context, CGRectMake(0, 0, size.width, size.height), self.paintLayer);
    
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
	NSString *filename = [self fileName];
    NSLog(@"saving %@", filename);
    [UIImagePNGRepresentation(result) writeToFile:filename atomically:YES];
}


- (void)dealloc {
	self.parent = nil;
    self.brushSizes = nil;
    CGContextRelease(self.paintBuffer);
    self.paintBuffer = nil;
    CGLayerRelease(self.paintLayer);
    self.paintLayer = nil;
    self.points = nil;
	
    [super dealloc];
}

@end
