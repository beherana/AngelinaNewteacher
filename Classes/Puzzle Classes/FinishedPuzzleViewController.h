//
//  FinishedPuzzleViewController.h
//  Angelina-New-Teacher-Universal
//
//  Created by Karl Söderström on 2011-06-01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "jigsawViewController.h"

@interface FinishedPuzzleViewController : UIViewController {
@private
  	jigsawViewController *_parent;
    NSMutableDictionary *_images;
    NSMutableArray *_audio;
}
@property (nonatomic,assign) jigsawViewController *parent;
@property (nonatomic,retain) NSMutableDictionary *images;
@property (nonatomic,retain) NSMutableArray *audio;

- (void)startAnimation;

@end
