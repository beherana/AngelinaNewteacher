//
//  cdaMoviePlayerControlledView.h
//  demoVideo
//
//  Created by Radif Sharafullin on 1/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cdaMoviePlayerView.h"

@interface cdaMoviePlayerControlledView : cdaMoviePlayerView {
	UISlider *scrubber;
	UIButton *playPauseButton;
	UIView *transportControlsHolder;
	BOOL transportControlsAreVisible;
	BOOL showsAndHidesTransportControlsOnTouch;
	@private
	float mRestoreAfterScrubbingRate;
	
}
/*!
 set to YES by default. hides and shows transport controls when the movie area touched
 */
@property(nonatomic, assign) BOOL showsAndHidesTransportControlsOnTouch;

/*!
 fades in transport controls with durations: .3
 */
-(void)fadeInTransportControls;
/*!
 fades out transport controls with durations: .3
 */
-(void)fadeOutTransportControls;
/*!
 returns YES if the movie is being scrubbed using trasport controls
 */
-(BOOL)isScrubbing;
/*!
 hides or shows transport controls. Same as fadeIn or fadeOut, but instantly. Good to use before showing player
 */
-(void)setTransportControlsHidden:(BOOL)hidden;
@end
