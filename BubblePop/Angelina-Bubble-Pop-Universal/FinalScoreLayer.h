//
//  FinalScoreLayer.h
//  Angelina-Bubble-Pop-Universal
//
//  Created by Karl Söderström on 2011-08-17.
//  Copyright 2011 Commind AB. All rights reserved.
//

#import "cocos2d.h"

@interface FinalScoreLayer : CCLayer {
    @private
    CCLabelBMFont *_label;
}

@property (nonatomic, assign) CCLabelBMFont *label;
@end
