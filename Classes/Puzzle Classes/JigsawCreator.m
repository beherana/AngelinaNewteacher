//
//  JigsawCreator.m
//  Angelina-New-Teacher-Universal
//
//  Created by Karl Söderström on 2011-05-18.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "JigsawCreator.h"

#define kImageMargin 4

@interface JigsawCreator ()
@property (nonatomic,retain) NSDictionary *plist;
@end

@implementation JigsawCreator

@synthesize plist = _plist;

- (id)initWithPList:(NSString *)plistFile numPieces:(int)pieces
{
    //NSAssert((pieces == 6 || pieces == 9), @"Invalid number of pieces specified: %i", pieces);
    NSAssert((pieces == 6 || pieces == 12), @"Invalid number of pieces specified: %i", pieces);
    self = [self init];
    if (self != nil) {
        self.plist =
            [NSDictionary dictionaryWithContentsOfFile:plistFile];
        numPieces = pieces;
    }
    return self;
}

- (void)dealloc
{
    self.plist = nil;
    [super dealloc];
}

- (CGPoint)pointForPiece:(int)piece
{
    NSArray *a = [self.plist objectForKey:[NSString stringWithFormat:@"puzzle%i", numPieces]];
    NSString *val = [a objectAtIndex:piece - 1];
    NSArray *parts = [val componentsSeparatedByString:@","];
    return CGPointMake([[parts objectAtIndex:0] doubleValue],
                       [[parts objectAtIndex:1] doubleValue]);
}

- (UIImage*)maskImageForPiece:(int)piece
{
    NSString *name=nil;
    if (numPieces == 12) {
        name=[NSString stringWithFormat:@"puzzle12_mask%d.png", piece];
    }
    else if (numPieces == 9) {
        name=[NSString stringWithFormat:@"puzzle9_mask%d.png", piece];        
    } 
    else {
        name=[NSString stringWithFormat:@"puzzle_mask%d.png", piece];
    }
    
    UIImage *img=[UIImage imageNamed:name];
    
    if (img!=nil) {
        return img;
    }
    
    name=[name stringByAppendingString:@".png"];
    
    img=[UIImage imageNamed:name];
    return img;
}

- (UIImage *)subImage:(UIImage*)image rect:(CGRect)rect
{
    if (image.scale==2) {
        rect=CGRectMake(rect.origin.x*2,rect.origin.y*2,rect.size.width*2,rect.size.height*2);
    }
    CGImageRef drawImage = CGImageCreateWithImageInRect(image.CGImage, rect);
    UIImage *newImage = [UIImage imageWithCGImage:drawImage scale:image.scale orientation:UIImageOrientationUp];
    CGImageRelease(drawImage);
    return newImage;
}

- (UIImage *)maskImage:(UIImage*)image mask:(UIImage*)mask
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGImageRef maskImage = [mask CGImage];
    size_t width = CGImageGetWidth(maskImage);
    size_t height = CGImageGetHeight(maskImage);
        
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 width + kImageMargin*2,
                                                 height + kImageMargin*2,
                                                 8,
                                                 0,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast);
    
    CGColorSpaceRelease(colorSpace);    
    
    CGContextClipToMask(context, CGRectMake(kImageMargin, kImageMargin, width, height), maskImage);    
    CGContextDrawImage(context, CGRectMake(kImageMargin, kImageMargin, width, height), [image CGImage]);    
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    UIImage *result = [UIImage imageWithCGImage:cgImage scale:image.scale orientation:UIImageOrientationUp];
    CGImageRelease(cgImage);
    return result;
}

- (UIImage *)addEffects:(UIImage*)image
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGImageRef img = [image CGImage];
    size_t width = CGImageGetWidth(img);
    size_t height = CGImageGetHeight(img);
    
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 width,
                                                 height,
                                                 8,
                                                 0,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast);
    
    CGColorSpaceRelease(colorSpace);    
    
    CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 3, [UIColor colorWithRed:88.0/255.0 green:58.0/255.0 blue:0 alpha:1].CGColor);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), img);    
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return result;

}

- (UIImage *)createJigsawPiece:(int)piece fromImage:(UIImage *)image
{        
    UIImage *maskImage = [self maskImageForPiece:piece];
    CGPoint point = [self pointForPiece:piece];
    UIImage *subImage =
        [self subImage:image rect:CGRectMake(point.x, point.y, maskImage.size.width, maskImage.size.height)];

    UIImage *maskedImage = [self maskImage:subImage mask:maskImage];

    //return [self addEffects:maskedImage];
    return maskedImage;
}


@end
