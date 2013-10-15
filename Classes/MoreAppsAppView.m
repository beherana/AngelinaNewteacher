//
//  MoreAppsAppView.m
//  Day-Of-The-Deisels-Universal
//
//  Created by Martin Kamara on 2011-10-11.
//  Copyright 2011 Commind. All rights reserved.
//

#import "MoreAppsAppView.h"
#import "cdaXSellAppLink.h"
#import "NetworkUtils.h"
#import "FlurryAnalytics.h"

#define IMAGE_PADDING_RIGHT_IPAD   20
#define HEADER_PADDING_BOTTOM_IPAD 12
#define DESCRIPTION_PADDING_BOTTOM_IPAD 6

#define IMAGE_PADDING_RIGHT_IPHONE   20
#define HEADER_PADDING_BOTTOM_IPHONE 6
#define IMAGE_PADDING_LEFT_IPHONE  20
#define DESCRIPTION_PADDING_BOTTOM_IPHONE 6


@implementation MoreAppsAppView

@synthesize headerLabel, descriptionLabel, downloadHereLabel, iconImageView, appURL, button, containerView, sectionName;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // set style and create labels
        self.headerLabel = [[[UILabel alloc]init] autorelease];
        self.headerLabel.textAlignment = UITextAlignmentLeft;
        self.headerLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 13 : 22)];
        self.headerLabel.textColor = [UIColor colorWithRed:0.0f/255.0f green:157.0f/255.0f blue:220.0f/255.0f alpha:1.0f];
        self.headerLabel.backgroundColor = [UIColor clearColor];
        self.headerLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.headerLabel.numberOfLines = 0;
        
        self.descriptionLabel = [[[UILabel alloc]init] autorelease];
        self.descriptionLabel.textAlignment = UITextAlignmentLeft;
        self.descriptionLabel.font =[UIFont fontWithName:@"Arial" size:((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 13 : 16)];
        self.descriptionLabel.textColor = [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
        self.descriptionLabel.backgroundColor = [UIColor clearColor];
        self.descriptionLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.descriptionLabel.numberOfLines = 0;
        
        self.downloadHereLabel = [[[UILabel alloc]init] autorelease];
        self.downloadHereLabel.textAlignment = UITextAlignmentLeft;
        self.downloadHereLabel.font =[UIFont fontWithName:((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? @"Arial" : @"Arial-BoldMT") size:((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 13 : 16)];
        self.downloadHereLabel.textColor = [UIColor colorWithRed:0.0f/255.0f green:157.0f/255.0f blue:220.0f/255.0f alpha:1.0f];
        self.downloadHereLabel.backgroundColor = [UIColor clearColor];
        self.downloadHereLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.downloadHereLabel.numberOfLines = 0;
        self.downloadHereLabel.text = @"Download here.";
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.button.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self.button addTarget:self action:@selector(appTapped) forControlEvents:UIControlEventTouchUpInside];
        
        self.iconImageView = [[[UIImageView alloc]init] autorelease];
        [self addSubview:self.headerLabel];
        [self addSubview:self.descriptionLabel];
        [self addSubview:self.downloadHereLabel];
        [self addSubview:self.iconImageView];
        [self addSubview:self.button];
    }
    return self;
}

-(void) appTapped {
    [[cdaAnalytics sharedInstance] trackEvent:[NSString stringWithFormat:@"%@: %@", self.sectionName, self.headerLabel.text] inCategory:@"xSell: Landing Page" withLabel:@"item" andValue:-1];
    
    CustomAlertViewController *alert = [[CustomAlertViewController alloc]init];
    alert.delegate = self;
    if ([NetworkUtils connectedToNetwork]) {
        NSString *fragment = [self.appURL fragment];
        if ([fragment isEqualToString:@"itunes"]) {
            alert.view.tag = CAVCLeaveToItunesAlert;
        } else if ([fragment isEqualToString:@"appstore"]) {
            alert.view.tag = CAVCLeaveToAppStoreAlert;
        } else {
            alert.view.tag = CAVCLeaveToWebsiteAlert;
        }
    } else {
        alert.view.tag = CAVCInternetAlert;
    }
    
    //this is dirty should change to new alert view framework
    [alert show:[[[self superview] superview] superview]];
    [alert release];
}

- (void)CustomAlertViewController:(CustomAlertViewController *)alert wasDismissedWithValue:(NSString *)value
{
    if ([value isEqualToString:@"Continue"]) {
        //reset state before continuing
        [self.containerView resetTabs];
        //goto the url
        [[UIApplication sharedApplication] openURL:self.appURL];
    }
}

-(id) setAppValues:(cdaXSellApp *) app {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // Register for icon downloaded notification to reload the cell's image
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadImage:) 
                                                 name:cdaXSellIconDownloadedNotification 
                                               object:app];
    
    //get image depending on device
    NSString const *iconSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] >= 2) {
            iconSize = IPHONE_RETINA_ICON_SIZE;
        }
        else {
            iconSize = IPHONE_ICON_SIZE;
            
        }
    }
    else {
        iconSize = IPAD_ICON_SIZE;
    }
    [self setImageViewFromApp:app forSize:iconSize];
    
    //labels
    self.headerLabel.text=app.name;
    self.descriptionLabel.text=app.shortDescription;
    
    //not sure how this should work but at the moment pick first link
    NSArray *links = app.appLinks;
    if (links && links.count > 0)
    {
        cdaXSellAppLink *link = [links objectAtIndex:0];
        NSString *urlString = link.URL;
        self.appURL = [NSURL URLWithString:urlString];
    }
    return self;
}

-(CGFloat) textXOffset {
    return self.iconImageView.frame.size.width+((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? IMAGE_PADDING_RIGHT_IPHONE :IMAGE_PADDING_RIGHT_IPAD);
}

-(CGFloat) textYOffset {
    return 0;
    //return self.iconImageView.frame.size.height+((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? IMAGE_PADDING_RIGHT_IPHONE :IMAGE_PADDING_RIGHT_IPAD);
}


-(CGFloat) sizeContentToFit {
    CGFloat totalSize = 0.0;
    
    totalSize += [self sizeLabelToFit:self.headerLabel];
    totalSize += ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? HEADER_PADDING_BOTTOM_IPHONE : HEADER_PADDING_BOTTOM_IPAD);
    totalSize += [self sizeLabelToFit:self.descriptionLabel];
        totalSize += ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? DESCRIPTION_PADDING_BOTTOM_IPHONE : DESCRIPTION_PADDING_BOTTOM_IPAD);
    totalSize += [self sizeLabelToFit:self.downloadHereLabel];
    
    //check maximum size f
    if (self.iconImageView.frame.size.height > totalSize) {
        totalSize = self.iconImageView.frame.size.height + ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 2 : 13); //hack to layout when using images
    }
    
    return totalSize;
}

//resize the labels to fit the text
-(CGFloat) sizeLabelToFit:(UILabel *) sizeLabel  {
    //Calculate the expected size based on the font and linebreak mode of your label
    CGFloat maxWidth = self.frame.size.width-[self textXOffset];
    CGSize maximumLabelSize = CGSizeMake(maxWidth,9999);
    
    CGSize expectedLabelSize = [sizeLabel.text sizeWithFont:sizeLabel.font 
                                          constrainedToSize:maximumLabelSize 
                                              lineBreakMode:sizeLabel.lineBreakMode]; 
    
    //adjust the label the the new height.
    sizeLabel.frame = CGRectMake(sizeLabel.frame.origin.x, sizeLabel.frame.origin.y, expectedLabelSize.width, expectedLabelSize.height);
    
    return sizeLabel.frame.size.height;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.bounds;
    CGFloat boundsX = contentRect.origin.x;
    
    //calculate the widths of the labels
    CGFloat height = [self sizeContentToFit];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
    
    //layout the labels
    self.iconImageView.frame = CGRectMake(boundsX+0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height);
    self.headerLabel.frame = CGRectMake(boundsX+[self textXOffset], [self textYOffset], headerLabel.frame.size.width, headerLabel.frame.size.height);   
    self.descriptionLabel.frame = CGRectMake(boundsX+headerLabel.frame.origin.x, (headerLabel.frame.origin.y+headerLabel.frame.size.height+((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? HEADER_PADDING_BOTTOM_IPHONE - 1 : HEADER_PADDING_BOTTOM_IPAD -4)), descriptionLabel.frame.size.width, descriptionLabel.frame.size.height); //-4 to compensate uilabel padding
    self.downloadHereLabel.frame =CGRectMake(boundsX+descriptionLabel.frame.origin.x, (descriptionLabel.frame.origin.y + descriptionLabel.frame.size.height+((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? DESCRIPTION_PADDING_BOTTOM_IPHONE : DESCRIPTION_PADDING_BOTTOM_IPAD)), downloadHereLabel.frame.size.width, downloadHereLabel.frame.size.height);
}

-(void)reloadImage:(NSNotification*)notification {
    cdaXSellApp* app = [notification object];
    
    [self setImageViewFromApp:app forSize:[[notification userInfo] objectForKey:@"size"]];
    [self setNeedsLayout];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) setImageViewFromApp:(cdaXSellApp *) app forSize:(NSString const*) size {
    
    NSString* path = [app iconImageFileNameForSize:size];
    UIImage* image = [UIImage imageWithContentsOfFile: path];
    [self.iconImageView setImage:image];
    
    //set the size
    CGRect imageFrame = self.iconImageView.frame;
    imageFrame.size = [app iconDimensions:size];
    self.iconImageView.frame = imageFrame;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.headerLabel removeFromSuperview];
    self.headerLabel = nil;
    
    [self.descriptionLabel removeFromSuperview];
    self.descriptionLabel = nil;
    
    [self.downloadHereLabel removeFromSuperview];
    self.downloadHereLabel = nil;
    
    [self.iconImageView removeFromSuperview];
    self.iconImageView = nil;
    
    [self.button removeFromSuperview];
    self.button = nil;
    
    self.appURL = nil;
    self.sectionName = nil;
    
    self.containerView = nil;
    
    [super dealloc];
}


@end
