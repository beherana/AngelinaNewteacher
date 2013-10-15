//
//  TitleScene.h
//  Angelina-Bubble-Pop-Universal
//
//  Created by Karl Söderström on 2011-08-02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

#define ANGELINA_TITLE_TAG 9987

@interface TitleScene : CCLayer <CCTargetedTouchDelegate>
{
    @private
    CCLayer *_background;
}

+(CCScene *) scene;
-(void)popAllBubbles;
@end
