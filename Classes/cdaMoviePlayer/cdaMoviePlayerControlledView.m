//
//  cdaMoviePlayerControlledView.m
//  demoVideo
//
//  Created by Radif Sharafullin on 1/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cdaMoviePlayerControlledView.h"
#import <AVFoundation/AVFoundation.h>
#import "cdaGlobalFunctions.h"

#define kPauseImage [UIImage imageNamed:@"cdaMediaPlayerPause"]
#define kPlayImage [UIImage imageNamed:@"cdaMediaPlayerPlay"]

@interface cdaMoviePlayerControlledView (geometry)
-(CGRect)frameForControlsHolder;
-(CGRect)frameForScrubber;
-(CGRect)frameForPlayButton;
@end


@implementation cdaMoviePlayerControlledView
@synthesize showsAndHidesTransportControlsOnTouch;
-(void)timeUpdated:(CMTime)time{
	AVAsset* asset = [[self.player currentItem] asset];
	
	if (!asset) return;
	
	double duration = CMTimeGetSeconds([asset duration]);
	
	if (isfinite(duration))
	{
		float minValue = [scrubber minimumValue];
		float maxValue = [scrubber maximumValue];
		double time = CMTimeGetSeconds([self.player currentTime]);
		
		[scrubber setValue:(maxValue - minValue) * time / duration + minValue];
	}
}

- (BOOL)isPlaying{
	return mRestoreAfterScrubbingRate != 0.f || [self.player rate] != 0.f;
}
- (void)syncButtons{
	if ([self isPlaying])
	{
		
		[playPauseButton setImage:kPauseImage forState:UIControlStateNormal];
	}
	else
	{
		[playPauseButton setImage:kPlayImage forState:UIControlStateNormal];
	}
}
- (id)init {
    
    self = [super init];
    if (self) {
        // Initialization code.
		
		self.showsAndHidesTransportControlsOnTouch=YES;
		
		transportControlsHolder=[UIView new];
		transportControlsHolder.frame=[self frameForControlsHolder];
		transportControlsHolder.backgroundColor=[UIColor colorWithWhite:0 alpha:.7];
		[self addSubview:transportControlsHolder];
		transportControlsAreVisible=YES;
		
		scrubber=[UISlider new];
		scrubber.frame=[self frameForScrubber];
		scrubber.continuous=YES;
		scrubber.minimumValue=0;
		scrubber.maximumValue=10000;
		[scrubber addTarget:self action:@selector(beginScrubbing:) forControlEvents:UIControlEventTouchDown];
		[scrubber addTarget:self action:@selector(scrub:) forControlEvents:UIControlEventValueChanged];
		[scrubber addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchUpInside];
		[scrubber addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchUpOutside];
		[transportControlsHolder addSubview:scrubber];
		
		
		playPauseButton=[UIButton new];
		playPauseButton.showsTouchWhenHighlighted=YES;
		playPauseButton.frame=[self frameForPlayButton];
		[playPauseButton addTarget:self action:@selector(playPausePressed:) forControlEvents:UIControlEventTouchDown];
		[transportControlsHolder addSubview:playPauseButton];
		
		[self syncButtons];
    }
    return self;
}
-(void)setFrame:(CGRect)frame{
	[super setFrame:frame];
	transportControlsHolder.frame=[self frameForControlsHolder];
	scrubber.frame=[self frameForScrubber];
	playPauseButton.frame=[self frameForPlayButton];
}

- (void)dealloc {
	CDA_RELEASE_SAFELY(scrubber);
	CDA_RELEASE_SAFELY(playPauseButton);
	CDA_RELEASE_SAFELY(transportControlsHolder);
    [super dealloc];
}

#pragma mark Effects
-(void)setTransportControlsHidden:(BOOL)hidden{
	transportControlsHolder.alpha=!hidden;
	transportControlsAreVisible=!hidden;
}
-(void)fadeInTransportControls{
	transportControlsAreVisible=YES;
	if (transportControlsHolder.alpha==1.0f) [transportControlsHolder setAlpha:0.0];
	[UIView animateWithDuration:.3
						  delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 transportControlsHolder.alpha=1.0; 
						 
					 } completion:^(BOOL finished){
						 ;
					 }
	 ];
}
-(void)fadeOutTransportControls{
	transportControlsAreVisible=NO;
	[UIView animateWithDuration:.3
						  delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 transportControlsHolder.alpha=0.0; 
						 
					 } completion:^(BOOL finished){
						 ;
					 }
	 ];
}

#pragma mark Callbacks

-(void)playPausePressed:(UIButton *)sender{
	
	
	
	if ([self isPlaying]){
		[self pause];
	}
	else{
		[self play];
	}
	
}
- (void)beginScrubbing:(id)sender
{
	mRestoreAfterScrubbingRate = [self.player rate];
	[self.player setRate:0.f];
	
	[self removeTimeObserver];
}

- (void)scrub:(id)sender
{
	if ([sender isKindOfClass:[UISlider class]])
	{
		UISlider* slider = sender;
		
		AVAsset* asset = [[self.player currentItem] asset];
		
		if (!asset) return;
		
		double duration = CMTimeGetSeconds([asset duration]);
		
		if (isfinite(duration))
		{
			float minValue = [slider minimumValue];
			float maxValue = [slider maximumValue];
			float value = [slider value];
			CGFloat width = CGRectGetWidth([slider bounds]);
			
			double time = duration * (value - minValue) / (maxValue - minValue);
			double tolerance = 0.5f * duration / width;
			
			[self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) toleranceBefore:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) toleranceAfter:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC)];
		}
	}
}

- (void)endScrubbing:(id)sender
{
	if (!mTimeObserver)
	{
		AVAsset* asset = [[self.player currentItem] asset];
		
		if (!asset)
			return;
		
		double duration = CMTimeGetSeconds([asset duration]);
		
		if (isfinite(duration))
		{
			CGFloat width = CGRectGetWidth([scrubber bounds]);
			double tolerance = 0.5f * duration / width;
			
			[self setTimeObserverWithTolerance:tolerance];
		}
	}
	
	if (mRestoreAfterScrubbingRate)
	{
		[self.player setRate:mRestoreAfterScrubbingRate];
		mRestoreAfterScrubbingRate = 0.f;
	}
}

- (BOOL)isScrubbing{
	return mRestoreAfterScrubbingRate != 0.f;
}
#pragma mark Geometry
-(CGRect)frameForControlsHolder{
	return CGRectMake(0, self.frame.size.height-40, self.frame.size.width-0, 40);
}
-(CGRect)frameForScrubber{
	return CGRectMake(50, 0, transportControlsHolder.frame.size.width-60, 40);
}
-(CGRect)frameForPlayButton{

	return CGRectMake(0, 0, 40, 40);
}

#pragma mark UIResponder
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	[super touchesEnded:touches withEvent:event];
	if (!self.showsAndHidesTransportControlsOnTouch) return;//bail out if the user doesn't want player to show controls on touch
	
	NSSet *allTouches = [event allTouches];
	if ([allTouches count]>1) return;//bail out if more than one finger is on the screen
	
	if ([[allTouches anyObject] view]==self){ //bail out if touching anything else but the movie area
		if (transportControlsAreVisible) 
			[self fadeOutTransportControls];
		else 
			[self fadeInTransportControls];
	}
}
@end
