//
//  TouchableScrollView.h
//  Angelina-New-Teacher-Universal
//
//  Created by Radif Sharafullin on 6/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TouchableScrollView : UIScrollView {
    
}
@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL selector;
@end
