//
//  WebViewHelper.m
//  Misty-Island-Rescue-Universal
//
//  Created by Martin Kamara on 2011-07-29.
//  Copyright 2011 Commind. All rights reserved.
//

#import "WebViewHelper.h"
#import "NetworkUtils.h"

@implementation WebViewHelper

@synthesize url, willOpenUrl, parentView, webView, activityIndicator, noInternetImage, dialogueView, webScroller;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

// fewer options conf init method
- (id)initWithWebView:(UIWebView *) _webView inView:(UIView *) _parentView forURL:(NSString *) _urlString dialogueHolderView:(UIView *) _dialogueView{
    return [self initWithWebView:_webView inView:_parentView forURL:_urlString dialogueHolderView:_dialogueView customNoConnectionImage:nil customActivityIndicator:nil];
}

// totally customizable init method
- (id)initWithWebView:(UIWebView *) _webView inView:(UIView *) _parentView forURL:(NSString *) _urlString dialogueHolderView:(UIView *) _dialogueView customNoConnectionImage:(UIImageView *) _noInternetImage customActivityIndicator:(UIActivityIndicatorView *) _activityIndicator{
    
    self.parentView        = _parentView;
    self.dialogueView      = _dialogueView;
    self.noInternetImage   = _noInternetImage;
    self.activityIndicator = _activityIndicator;
    
    self.webView = _webView;
    self.webView.delegate = self;
    self.webView.hidden = NO;
    //dont show webview until content has loaded otherwise a scrollview will appear
    self.webView.alpha = 0.0f;
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.scalesPageToFit = YES;
    [self.webView sizeToFit];


    if (self.webScroller == nil) {
        //setup and conf the scroll view
        UIScrollView *tmpSv = [[UIScrollView alloc] initWithFrame:self.webView.frame];
        self.webScroller = tmpSv;
        [tmpSv release];
        self.webScroller.backgroundColor = [UIColor clearColor];
        [self.webScroller setShowsHorizontalScrollIndicator:NO];
        [self.webScroller setShowsVerticalScrollIndicator:NO];
        
        //replace the web view with the scroll view and add the web view to the scrollview
        int viewIndex = [[self.parentView subviews] indexOfObject:self.webView];
        [self.parentView insertSubview:self.webScroller atIndex:viewIndex];
        [self.webView removeFromSuperview];
        [self.webScroller addSubview:self.webView];

        self.webScroller.contentSize = self.webView.frame.size;
        self.webView.frame = CGRectMake(0, 0, self.webView.frame.size.width, self.webView.frame.size.width);
    }
    
    self.url = [NSURL URLWithString:_urlString];
    
    [self refresh:YES];
 
    return [self init];
}

-(void)refresh {
    [self refresh:NO];
}

// if force refresh otherwise
-(void)refresh:(BOOL)forceRefresh {
    
    //check for internet
    if (![NetworkUtils connectedToNetwork]) {
        [self handleNoInternet];
    }
    //force refresh otherwise only refresh if we have a no internet image on top
    else if (forceRefresh || (self.noInternetImage && self.noInternetImage.hidden == NO)) {
        
        //hide any no internet images we got around
        if (self.noInternetImage) {
            self.noInternetImage.hidden = YES;
        }
        
        //create an activity indicator
        if (self.activityIndicator == nil) {
            UIActivityIndicatorView *tmpAct;
            //add it to the middle of the view
            tmpAct = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((self.webScroller.frame.size.width/2)+self.webScroller.frame.origin.x, self.webScroller.frame.origin.y+50, 20, 20)];
            self.activityIndicator = tmpAct;
            //self.activityIndicator.backgroundColor = [UIColor redColor];
            self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
            [tmpAct release];
            [self.parentView addSubview:self.activityIndicator];
        }
        
        if ([self.webView isLoading])
            [self.webView stopLoading];
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];

        
    }
    
    return;
}

-(void)handleNoInternet {
    
    //create UIImageView unless exists
    if (self.noInternetImage == nil) {
        //create an image view ontop of the webview with same placement
        UIImageView *tmpImageView = [[UIImageView alloc] init];
        //differ image depending on platform
        CGRect imageFrame = self.webScroller.frame;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [tmpImageView setImage:[UIImage imageNamed:@"no_connection"]];
            imageFrame.size.width = 222;
            imageFrame.size.height = 34;
        }
        else {
            [tmpImageView setImage:[UIImage imageNamed:@"no_connection~ipad"]];
            imageFrame.size.width = 310;
            imageFrame.size.height = 54;
        }
        tmpImageView.frame = imageFrame;
        //assign the image
        self.noInternetImage = tmpImageView;
        [tmpImageView release];
        
        self.noInternetImage.center = self.webScroller.center;
        
        //add the image to the parent view
        [self.parentView addSubview: self.noInternetImage];
    }
    
    self.noInternetImage.hidden = NO;
    //hide any partialy loaded web view
    self.webView.alpha = 0.0f;
}

- (void)webViewDidStartLoad:(UIWebView *)loadWebView {
	[self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)loadWebView {
	[self.activityIndicator stopAnimating];

    //resize the web view and fade in
    [self.webView sizeToFit];
    self.webScroller.contentSize = self.webView.frame.size;
    
    [UIView animateWithDuration:0.3
                          delay:0.0 
                        options:UIViewAnimationOptionCurveEaseInOut 
                     animations:^{
                         self.webView.alpha = 1;
                     }
                     completion:nil];

}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType) navigationType {
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        self.willOpenUrl = [request URL];
        [self showLeavingAppAlert];
        return NO;
    }

    return YES;
}

//leaving app or no network dialogue
- (void)showLeavingAppAlert
{
//    CustomAlertViewController *alert = [[CustomAlertViewController alloc]init];
//    alert.delegate = self;
//    if ([NetworkUtils connectedToNetwork]) {
//        NSString *fragment = [self.willOpenUrl fragment];
//        if ([fragment isEqualToString:@"itunes"]) {
//            alert.view.tag = CAVCLeaveToItunesAlert;
//        } else if ([fragment isEqualToString:@"appstore"]) {
//            alert.view.tag = CAVCLeaveToAppStoreAlert;
//        } else {
//            alert.view.tag = CAVCLeaveToWebsiteAlert;
//        }
//    } else {
//        alert.view.tag = CAVCInternetAlert;
//    }
//    [alert show:self.dialogueView];
//    [alert release];	
}

- (void)CustomAlertViewController:(CustomAlertViewController *)alert wasDismissedWithValue:(NSInteger)dismissedValue
{
    if (dismissedValue == CAVCButtonTagOk) {
        [[UIApplication sharedApplication] openURL:self.willOpenUrl];
    }
    
    self.willOpenUrl = nil;
}



- (void)dealloc {
    if (self.noInternetImage != nil) {
        [self.noInternetImage removeFromSuperview];
        self.noInternetImage = nil;
    }
    
    if ([self.webView isLoading]) {
		[self.webView stopLoading];
    }
    self.webView.delegate = nil;
    self.webView = nil;
    self.webScroller = nil;
    self.parentView = nil;
    self.dialogueView = nil;
    self.url = nil;
    self.willOpenUrl = nil;
    
    self.activityIndicator = nil;
    

    [super dealloc];
}

@end
