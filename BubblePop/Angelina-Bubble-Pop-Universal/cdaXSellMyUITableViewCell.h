//
//  cdaXSellMyUITableViewCell.h
//  Angelina-Bubble-Pop-Universal
//
//  Created by Martin Kamara on 2011-08-20.
//  Copyright 2011 Commind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cdaXSellApp.h"

#define IMAGE_PADDING_RIGHT_IPAD   18
#define HEADER_PADDING_BOTTOM_IPAD 12
#define CELL_PADDING_BOTTOM_IPAD   31

#define IMAGE_PADDING_RIGHT_IPHONE   15
#define HEADER_PADDING_BOTTOM_IPHONE 10
#define CELL_PADDING_BOTTOM_IPHONE   18

@interface cdaXSellMyUITableViewCell : UITableViewCell {
    
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
