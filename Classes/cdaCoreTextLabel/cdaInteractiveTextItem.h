//
//  cdaInteractiveTextItem.h

//
//  Created by Radif Sharafullin on 2/3/11.
//  Copyright 2011 Callaway Digital Arts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cdaCTLabel.h"
//#define kDrawsLabelEdges //uncomment this to draw the edges of each label
typedef enum {
    cdaInteractiveTextItemStateNormal  = 0,
    cdaInteractiveTextItemStateHighlighted,
	cdaInteractiveTextItemStateSelected,
} cdaInteractiveTextItemState;
@class cdaInteractiveTextItem;
@protocol  cdaInteractiveTextItemDelegate <NSObject>
-(NSArray *)words;
@end


@interface cdaInteractiveTextItem : cdaCTLabel {
	NSDictionary *dictionary;
	NSTimeInterval highlightTimeFrom;
	NSTimeInterval highlightTimeTo;
	int wordIndex;
	cdaInteractiveTextItemState textItemState;
	id <cdaInteractiveTextItemDelegate> delegate;
	
}
@property (nonatomic, assign) cdaInteractiveTextItemState textItemState;
@property (nonatomic, retain) NSDictionary *dictionary;
@property (nonatomic, assign) int wordIndex;
@property (nonatomic, assign) id <cdaInteractiveTextItemDelegate> delegate;
@property (nonatomic, readonly) NSString *wordAudioFilePath;
@property (nonatomic, readonly) NSString *popoverImageFilePath;
@property (nonatomic, readonly) float animationDurationToSelected;
@property (nonatomic, readonly) float animationDurationFromSelected;
@property (nonatomic, readonly) float animationDurationToHighlight;
@property (nonatomic, readonly) float animationDurationFromHighlight;
@property (nonatomic, assign) NSTimeInterval highlightTimeFrom;
@property (nonatomic, assign) NSTimeInterval highlightTimeTo;
@property (nonatomic, readonly) NSArray * wordGroupIndexes;

-(id)initWithDictionary:(NSDictionary *)dict onView:(UIView *)v;
-(void)setState:(cdaInteractiveTextItemState)state animated:(BOOL)animated duration:(NSTimeInterval)duration;
-(id)propertyForKey:(NSString *)key;
@end
