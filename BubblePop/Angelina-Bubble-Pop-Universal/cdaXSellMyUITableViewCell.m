//
//  cdaXSellMyUITableViewCell.m
//  Angelina-Bubble-Pop-Universal
//
//  Created by Martin Kamara on 2011-08-20.
//  Copyright 2011 Commind. All rights reserved.
//

#import "cdaXSellMyUITableViewCell.h"
#import "cdaXSellAppLink.h"

@implementation cdaXSellMyUITableViewCell

@synthesize headerLabel, descriptionLabel, downloadHereLabel, iconImageView, appURL, parentTable;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // set style and create labels
        self.headerLabel = [[[UILabel alloc]init] autorelease];
        self.headerLabel.textAlignment = UITextAlignmentLeft;
        self.headerLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 12 : 18)];
        self.headerLabel.textColor = [UIColor colorWithRed:89.0f/255.0f green:59.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
        self.headerLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.headerLabel.numberOfLines = 0;
        
        self.descriptionLabel = [[[UILabel alloc]init] autorelease];
        self.descriptionLabel.textAlignment = UITextAlignmentLeft;
        self.descriptionLabel.font =[UIFont fontWithName:@"Arial" size:((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 12 : 16)];
        self.descriptionLabel.textColor = [UIColor colorWithRed:89.0f/255.0f green:59.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
        self.descriptionLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.descriptionLabel.numberOfLines = 0;
        
        self.downloadHereLabel = [[[UILabel alloc]init] autorelease];
        self.downloadHereLabel.textAlignment = UITextAlignmentLeft;
        self.downloadHereLabel.font =[UIFont fontWithName:@"Arial-BoldMT" size:((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 12 : 16)];
        self.downloadHereLabel.textColor = [UIColor colorWithRed:89.0f/255.0f green:59.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
        self.downloadHereLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.downloadHereLabel.numberOfLines = 0;
        self.downloadHereLabel.text = @"Download here.";
        
        self.iconImageView = [[[UIImageView alloc]init] autorelease];
        [self.contentView addSubview:self.headerLabel];
        [self.contentView addSubview:self.descriptionLabel];
        [self.contentView addSubview:self.downloadHereLabel];
        [self.contentView addSubview:self.iconImageView];
     
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

-(void) debugFrame:(CGRect) frame {
    NSLog(@"%fx%f width:%f height:%f",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);

}

-(id) setAppValues:(cdaXSellApp *) app forTable:(UITableView *) table {
    self.parentTable = table;
    
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
    cdaXSellAppLink *link = [links objectAtIndex:0];
    NSString *urlString = link.URL;
    self.appURL = [NSURL URLWithString:urlString];
    
    return self;
}


-(CGFloat) textXOffset {
    return self.iconImageView.frame.size.width+((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? IMAGE_PADDING_RIGHT_IPHONE :IMAGE_PADDING_RIGHT_IPAD);
}

-(CGFloat) sizeContentToFit {
    CGFloat totalSize = 0.0;
    
    totalSize += [self sizeLabelToFit:self.headerLabel];
    totalSize += ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? HEADER_PADDING_BOTTOM_IPHONE : HEADER_PADDING_BOTTOM_IPAD);
    totalSize += [self sizeLabelToFit:self.descriptionLabel];
    totalSize += [self sizeLabelToFit:self.downloadHereLabel];
    
    //check maximum size f
    if (self.iconImageView.frame.size.height > totalSize) {
        totalSize = self.iconImageView.frame.size.height + ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 2 : 13); //hack to layout when using images
    }
    
    totalSize += ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? CELL_PADDING_BOTTOM_IPHONE : CELL_PADDING_BOTTOM_IPAD);
    
    return totalSize;
}

//resize the labels to fit the text
-(CGFloat) sizeLabelToFit:(UILabel *) sizeLabel  {
    //Calculate the expected size based on the font and linebreak mode of your label
    CGFloat maxWidth = self.parentTable.frame.size.width-[self textXOffset];
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
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;

    //calculate the widths of the labels
    [self sizeContentToFit];
    
    //layout the labels
    self.iconImageView.frame = CGRectMake(boundsX+0, 0, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height);
    self.headerLabel.frame = CGRectMake(boundsX+[self textXOffset], 0-((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 1 : 4), headerLabel.frame.size.width, headerLabel.frame.size.height); //-4 to compensate uilabel padding    
    self.descriptionLabel.frame = CGRectMake(boundsX+headerLabel.frame.origin.x, (headerLabel.frame.origin.y+headerLabel.frame.size.height+((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? HEADER_PADDING_BOTTOM_IPHONE - 1 : HEADER_PADDING_BOTTOM_IPAD -4)), descriptionLabel.frame.size.width, descriptionLabel.frame.size.height); //-4 to compensate uilabel padding
    self.downloadHereLabel.frame =CGRectMake(boundsX+descriptionLabel.frame.origin.x, (descriptionLabel.frame.origin.y + descriptionLabel.frame.size.height), downloadHereLabel.frame.size.width, downloadHereLabel.frame.size.height);
}

-(void)reloadImage:(NSNotification*)notification {
    cdaXSellApp* app = [notification object];

    [self setImageViewFromApp:app forSize:[[notification userInfo] objectForKey:@"size"]];
    [self setNeedsLayout];
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
    [self.headerLabel removeFromSuperview];
    self.headerLabel = nil;
    
    [self.descriptionLabel removeFromSuperview];
    self.descriptionLabel = nil;
    
    [self.downloadHereLabel removeFromSuperview];
    self.downloadHereLabel = nil;
    
    [self.iconImageView removeFromSuperview];
    self.iconImageView = nil;

    self.appURL = nil;
    
    self.parentTable = nil;
    
    [super dealloc];
}


@end
