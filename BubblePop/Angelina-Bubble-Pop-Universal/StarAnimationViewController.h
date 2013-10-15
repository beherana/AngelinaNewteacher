//
//  FinishedPuzzleViewController.h
//  Angelina-New-Teacher-Universal
//
//  Created by Karl Söderström on 2011-06-01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StarAnimationViewController : UIViewController {
@private
    NSMutableDictionary *_images;
}
@property (nonatomic,retain) NSMutableDictionary *images;

- (void)startAnimation;

@end
