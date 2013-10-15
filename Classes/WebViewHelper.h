//
//  WebViewHelper.h
//  Misty-Island-Rescue-Universal
//
//  Created by Martin Kamara on 2011-07-29.
//  Copyright 2011 Commind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomAlertViewController.h"

@interface WebViewHelper : NSObject <UIWebViewDelegate, CustomAlertViewControllerDelegate> {

    NSURL *url;
    NSURL *willOpenUrl;
    UIView *parentView;
    UIView *dialogueView;
    UIWebView *webView;
    UIScrollView *webScroller;
    UIActivityIndicatorView *activityIndicator;
    UIImageView *noInternetImage;
}

@property (nonatomic,retain) NSURL *url;
@property (nonatomic,retain) NSURL *willOpenUrl;
@property (nonatomic,retain) UIView *parentView;
@property (nonatomic,retain) UIView *dialogueView;
@property (nonatomic,retain) UIWebView *webView;
@property (nonatomic,retain) UIScrollView *webScroller;
@property (nonatomic,retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic,retain) UIImageView *noInternetImage;

-(id) initWithWebView:(UIWebView *) _webView inView:(UIView *) _parentView forURL:(NSString *) _urlString dialogueHolderView:(UIView *) _dialogueView;
-(id) initWithWebView:(UIWebView *) _webView inView:(UIView *) _parentView forURL:(NSString *) _urlString dialogueHolderView:(UIView *) _dialogueView customNoConnectionImage:(UIImageView *) _noInternetImage customActivityIndicator:(UIActivityIndicatorView *) _activityIndicator;
-(void) refresh;
-(void) refresh:(BOOL) forceRefresh;
-(void) handleNoInternet;
-(void) showLeavingAppAlert;

@end
