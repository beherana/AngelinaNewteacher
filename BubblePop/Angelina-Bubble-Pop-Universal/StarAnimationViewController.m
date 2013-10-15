//
//  FinishedPuzzleViewController.m
//  Angelina-New-Teacher-Universal
//
//  Created by Karl Söderström on 2011-06-01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StarAnimationViewController.h"



@implementation StarAnimationViewController 

@synthesize images = _images;

- (void)dealloc
{
    self.images = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)] autorelease];
        
    self.view = view;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"star_animation" ofType:@"plist"]];
    
    self.images = [NSMutableDictionary dictionary];
    
    NSArray *animations = [plist objectForKey:@"animations"];
        
    for (NSDictionary *animation in animations) {        
        UIImageView *imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:[animation objectForKey:@"image"]]] autorelease];
        
        [self.images setObject:imageView forKey:[animation objectForKey:@"image"]];
    }
}

- (void)startAnimation
{
    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"star_animation" ofType:@"plist"]];
    NSArray *animations = [plist objectForKey:@"animations"];
    
    float longestEndTime = 0.0;
    
    for (NSDictionary *animation in animations) {
        UIImageView *imageView = [self.images objectForKey:[animation objectForKey:@"image"]];
        if (imageView == nil) {
            continue;
        }
        
        float scale = [[animation objectForKey:@"scale"] floatValue];
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
        
        float rotation = [[animation objectForKey:@"rotation"] floatValue];
        CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(rotation * M_PI / 180);
        
        imageView.transform = CGAffineTransformConcat(scaleTransform, rotationTransform);
        
        float opacity = [[animation objectForKey:@"opacity"] floatValue];
        imageView.alpha = opacity;
        
        imageView.center = CGPointFromString([animation objectForKey:@"position"]);
        
        //[CATransaction begin];
        
        // add keyframes
        for (NSDictionary *keyframe in [animation objectForKey:@"keyframes"]) {
            float startTime = [[keyframe objectForKey:@"startTime"] floatValue];
            float endTime = [[keyframe objectForKey:@"endTime"] floatValue];
            float duration = endTime - startTime;
            
            longestEndTime = MAX(endTime, longestEndTime);
            
            if ([keyframe objectForKey:@"scale"] != nil && [keyframe objectForKey:@"rotation"] == nil) {
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, startTime * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [UIView animateWithDuration:duration animations:^{
                        NSNumber *scale = [keyframe objectForKey:@"scale"];
                        imageView.transform = CGAffineTransformMakeScale([scale floatValue], [scale floatValue]);
                    }];
                });
            }
            
            [UIView animateWithDuration:duration
                                  delay:startTime
                                options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 NSNumber *rotation = [keyframe objectForKey:@"rotation"];
                                 NSNumber *scale = [keyframe objectForKey:@"scale"];
                                 NSNumber *opacity = [keyframe objectForKey:@"opacity"];
                                 NSString *position = [keyframe objectForKey:@"position"];
                                 
                                 CGAffineTransform rotationTransform;
                                 CGAffineTransform scaleTransform;
                                 if (rotation != nil) {
                                     rotationTransform = CGAffineTransformMakeRotation([rotation floatValue] * M_PI / 180);
                                 }
                                 if (scale != nil) {
                                     scaleTransform = CGAffineTransformMakeScale([scale floatValue], [scale floatValue]);
                                 }
                                 if (rotation != nil && scale != nil) {
                                     imageView.transform = CGAffineTransformConcat(rotationTransform, scaleTransform);
                                 } else if (rotation != nil) {
                                     imageView.transform = rotationTransform;
                                 } else if (scale != nil) {
                                     //imageView.transform = scaleTransform;
                                 }
                                 
                                 if (opacity != nil) {
                                     imageView.alpha = [opacity floatValue];
                                 }
                                 if (position != nil) {
                                     imageView.center = CGPointFromString(position);
                                 }
                             }
                             completion:nil];
        }
        [self.view addSubview:imageView];
        //[CATransaction commit];
    }
    
    //[self.parent performSelector:@selector(finishedPuzzledAnimationFinished) withObject:nil afterDelay:longestEndTime];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
