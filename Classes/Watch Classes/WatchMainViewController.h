//
//  WatchMainViewController.h
//  Angelina-New-Teacher-Universal
//
//  Created by Oskar Håkansson on 5/30/11.
//  Copyright 2011 Commind AB. All rights reserved.
//

#import <UIKit/UIKit.h>

//movie menu
@class WatchViewController;

@interface ForwardingUIView : UIView
@end

@interface WatchMainViewController : UIViewController <UIScrollViewDelegate> {
    WatchViewController *myWatchViewController;
    UIScrollView *scrollView;
    UIView *scrollContentView;
    UIView *viewAnimate;
    
    IBOutlet UIView *resumeCover;
}

-(IBAction) mainMovieNav:(UIButton*)sender;
@property (nonatomic, retain) IBOutlet UIView *viewAnimate;
@property (nonatomic, retain) IBOutlet UIScrollView* scrollView;
@property (nonatomic, retain) IBOutlet UIView* scrollContentView;
@property (retain, nonatomic) IBOutlet UIButton *firstIcon;
@property (retain, nonatomic) IBOutlet UIButton *lastIcon;
-(void) releaseWatchViewController;
-(void) restoreOngoingMovie:(int)select;
@end
