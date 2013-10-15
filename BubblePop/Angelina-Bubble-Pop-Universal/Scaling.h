//
//  Scaling.h
//  Angelina-Bubble-Pop-Universal
//
//  Created by Karl Söderström on 2011-08-25.
//  Copyright 2011 Commind AB. All rights reserved.
//

#define scaleOfScreen ([Scaling sharedInstance].scale)
#define scaleValueToScreen(val) ((val) * scaleOfScreen)
#define scaleOfUIKitScreen ([Scaling sharedInstance].UIKitScale)
#define scaleValueToUIKitScreen(val) ((val) * scaleOfUIKitScreen)
#define scaleCGPointToScreen(val) (CGPointMake(scaleValueToScreen((val).x),scaleValueToScreen((val).y)))


@interface Scaling : NSObject {
    float _scale;
    float _UIKitScale;
}

@property (nonatomic, assign) float scale;
@property (nonatomic, assign) float UIKitScale;

+ (Scaling *)sharedInstance;
+ (void)reset;

@end
