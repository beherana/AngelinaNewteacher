//
//  ThomasSettingsTVC_iPhone.m
//  ThomasSettings
//
//  Created by Radif Sharafullin on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ThomasSettingsTVC_iPhone.h"


@implementation ThomasSettingsTVC_iPhone
@synthesize s;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		self.textLabel.font=[UIFont fontWithName:@"Arial" size:22.5];
		self.textLabel.textColor=[UIColor colorWithRed:128.0f/255.0f green:128.0f/255.0f blue:132.0f/255.0f alpha:1.0f];
		self.selectionStyle=UITableViewCellSelectionStyleBlue;
		self.accessoryView=nil;
		accessoryLabel=[[[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width-30, 0, 30, self.frame.size.height)] autorelease];
		accessoryLabel.textAlignment=UITextAlignmentCenter;
		accessoryLabel.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin;
		accessoryLabel.textColor=self.textLabel.textColor;
		accessoryLabel.font=[UIFont fontWithName:@"Arial" size:23.5];
		accessoryLabel.backgroundColor=[UIColor clearColor];
		accessoryLabel.text=@">";
		[self.contentView addSubview:accessoryLabel];
		
		s=[[ThomasSwitch alloc] initWithFrame:CGRectMake(330, 14, 0, 0)];
		[self.contentView addSubview:s];
		s.hidden=YES;
		
    }
    return self;
}

-(void)prepareForReuse{
	self.selectionStyle=UITableViewCellSelectionStyleBlue;
	accessoryLabel.hidden=NO;
	s.hidden=YES;
	
}
-(void)setSwitchTarget:(id)target selector:(SEL)selector{

	self.selectionStyle=UITableViewCellSelectionStyleNone;
	self.accessoryView=nil;
	accessoryLabel.hidden=YES;
	s.hidden=NO;
	[s setTarget:target selector:selector];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
	if (selected) 
		accessoryLabel.textColor=[UIColor whiteColor];
	else 
		accessoryLabel.textColor=self.textLabel.textColor;

    // Configure the view for the selected state.
}

- (void)setHighlighted:(BOOL)selected animated:(BOOL)animated {
    
    [super setHighlighted:selected animated:animated];
	if (selected) 
		accessoryLabel.textColor=[UIColor whiteColor];
	else 
		accessoryLabel.textColor=self.textLabel.textColor;
	
    // Configure the view for the selected state.
}
- (void)dealloc {
	[s release];
	[accessoryLabel release];
    [super dealloc];
	
}


@end
