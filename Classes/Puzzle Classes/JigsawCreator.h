//
//  JigsawCreator.h
//  Angelina-New-Teacher-Universal
//
//  Created by Karl Söderström on 2011-05-18.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JigsawCreator : NSObject {
@private
    NSDictionary *_plist;
    int numPieces;
}

- (id)initWithPList:(NSString *)plistFile numPieces:(int)pieces;
- (UIImage *)createJigsawPiece:(int)piece fromImage:(UIImage *)image;

@end
