//
//  ReadOverlayUIView.h
//  Angelina-New-Teacher-Universal
//
//  Created by Martin Kamara on 2011-09-04.
//  Copyright 2011 Commind. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReadOverlayUIView : UIView {

    UIButton *repeatNarrationButton;
    UIButton *danceButton;
}

@property (nonatomic,retain) IBOutlet UIButton *repeatNarrationButton;
@property (nonatomic,retain) IBOutlet UIButton *danceButton;


@end

