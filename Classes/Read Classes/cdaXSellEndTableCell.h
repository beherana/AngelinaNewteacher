//
//  cdaXSellEndTableCell.h
//  Angelina-Bubble-Pop-Universal
//
//  Created by Martin Kamara on 2011-08-20.
//  Copyright 2011 Commind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cdaXSellApp.h"

#define T_IMAGE_PADDING_RIGHT_IPAD   18
#define T_HEADER_PADDING_BOTTOM_IPAD 12
#define T_CELL_PADDING_BOTTOM_IPAD   31

#define T_IMAGE_PADDING_RIGHT_IPHONE   12
#define T_HEADER_PADDING_BOTTOM_IPHONE 6
#define T_CELL_PADDING_BOTTOM_IPHONE   20
#define T_DOWNLOAD_HERE_PADDING_BOTTOM 5

@interface cdaXSellEndTableCell : UITableViewCell {
    
    UILabel *headerLabel;
    UILabel *descriptionLabel;
    UILabel *downloadHereLabel;
    UIImageView *iconImageView;
    UITableView *parentTable;
    
    NSURL * appURL;
}

@property(nonatomic,retain)UILabel *headerLabel;
@property(nonatomic,retain)UILabel *descriptionLabel;
@property(nonatomic,retain)UILabel *downloadHereLabel;
@property(nonatomic,retain)UIImageView *iconImageView;
@property(nonatomic,retain)NSURL *appURL;
@property(nonatomic,retain)UITableView *parentTable;

-(void)reloadImage:(NSNotification*)notification;

-(CGFloat) sizeLabelToFit:(UILabel *) sizeLabel;
-(CGFloat) sizeContentToFit;
-(id) setAppValues:(cdaXSellApp *) app forTable:(UITableView *) table;
-(void) setImageViewFromApp:(cdaXSellApp *) app forSize:(NSString const*) size;


@end
