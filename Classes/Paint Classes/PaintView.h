//
//  PaintView.h
//  The Bird & The Snail
//
//  Created by Henrik Nord on 1/4/09.
//  Copyright 2009 Haunted House. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaintViewController.h"

@class PaintViewController;
@class PaintHolderLandscapeViewController;

@interface PaintView : UIView {
@private
	PaintHolderLandscapeViewController *_parent;
    NSMutableArray *_brushSizes;
    CGContextRef _paintBuffer;
    CGLayerRef _paintLayer;
    CGContextRef _paintLayerContext;
    NSMutableArray *_points;
    float _brushSize;
}

-(void) initWithParent: (id) parent;
- (void)save;
- (NSString *)fileName;
@end
