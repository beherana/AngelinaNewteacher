//
//  cdaInteractiveTextView.h

//
//  Created by Radif Sharafullin on 2/3/11.
//  Copyright 2011 Callaway Digital Arts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cdaInteractiveTextItem.h"
#import "cdaInteractiveTextAudioManager.h"


@class cdaInteractiveTextView;

//delegate methods
@protocol  cdaInteractiveTextViewDelegate <NSObject>
@optional
-(void)cdaInteractiveTextView:(cdaInteractiveTextView *)interactiveTextView wordTapped:(cdaInteractiveTextItem *)wordIdem position:(CGPoint )position;
-(void)cdaInteractiveTextView:(cdaInteractiveTextView *)interactiveTextView backgroundTappedAtPosition:(CGPoint )position;

-(BOOL)cdaInteractiveTextView:(cdaInteractiveTextView *)interactiveTextView shouldHighlightWordItem:(cdaInteractiveTextItem *)wordIdem;
-(BOOL)cdaInteractiveTextView:(cdaInteractiveTextView *)interactiveTextView shouldSelectWordItem:(cdaInteractiveTextItem *)wordIdem;
-(BOOL)cdaInteractiveTextView:(cdaInteractiveTextView *)interactiveTextView shouldPlaySelectedWord:(cdaInteractiveTextItem *)wordIdem;
-(BOOL)cdaInteractiveTextView:(cdaInteractiveTextView *)interactiveTextView shouldDeselectWordItem:(cdaInteractiveTextItem *)wordIdem;

//playback
-(void)cdaInteractiveTextViewDidStartPlayback:(cdaInteractiveTextView *)interactiveTextView recordedAudio:(BOOL)isRecordedAudio;
-(void)cdaInteractiveTextViewDidStopPlayback:(cdaInteractiveTextView *)interactiveTextView recordedAudio:(BOOL)isRecordedAudio;
@end

@interface cdaInteractiveTextView : UIImageView <cdaInteractiveTextAudioManagerCurrentTimeObserver, cdaInteractiveTextAudioManagerDelegate, cdaInteractiveTextItemDelegate> {
	
	id <cdaInteractiveTextViewDelegate >delegate;
	cdaInteractiveTextAudioManager *sharedAudioManager;
	NSDictionary *wordsDictionary;
	NSMutableArray *words;
	BOOL highlightWordsWhenReading;
	UIImage *backgroundImage;
	float volume;
	BOOL isNarrating;
	NSString *audioFilePath;
    UIView *secondaryView;
    NSDictionary *secondaryWordsDictionary;
    CGSize secondaryViewSize;

	
	@private
	int lastHighlightedWordIndex;
	
}
//properties:

@property (nonatomic, assign) id <cdaInteractiveTextViewDelegate >delegate;
@property (nonatomic, retain) NSDictionary *wordsDictionary;
@property (nonatomic, retain) NSDictionary *secondaryWordsDictionary;
@property (nonatomic, retain) NSMutableArray *words;
@property (nonatomic, assign) BOOL highlightWordsWhenReading;
@property (nonatomic, assign) UIImage *backgroundImage;
@property (nonatomic, assign) float volume;
@property (nonatomic, readonly) BOOL isNarrating;
@property (nonatomic, readonly) cdaInteractiveTextAudioManager *sharedAudioManager;
@property (nonatomic, retain) NSString *audioFilePath;
@property (nonatomic, retain) UIView *secondaryView;
@property (nonatomic, assign) CGSize secondaryViewSize;

//alloc
+(id)textViewWithFrame:(CGRect)frame wordsPlistPath:(NSString *)plistFile;
+(id)textViewWithFrame:(CGRect)frame wordsPlistPath:(NSString *)plistFile andSecondaryPlistFile:(NSString *) _secondaryPlistFile withSecondaryView:(UIView *)_secondaryView;

+(id)textViewWithFrame:(CGRect)frame wordsDictionary:(NSDictionary *)wDictionary;
+(id)textViewWithFrame:(CGRect)frame wordsDictionary:(NSDictionary *)wDictionary andSecondaryDictionary:(NSDictionary *) _secondaryDictionary withSecondaryView:(UIView *) _secondaryView;

-(id)initWithFrame:(CGRect)frame wordsDictionary:(NSDictionary *)wDictionary;
-(id)initWithFrame:(CGRect)frame wordsDictionary:(NSDictionary *)wDictionary andSecondaryDictionary:(NSDictionary *)_secondaryDictionary withSecondaryView:(UIView *) _secondaryView;

//render
-(void)renderWithWordsDictionary:(NSDictionary *)wordsDictionary;
-(void)renderWithCurrentSettings;
-(void)removeAllWords;

-(void)fadeIn;
-(void)resetWords;
//play
-(void)play;
-(void)restart;
-(void)pause;
-(void)unpause;
-(void)stop;

//play recording
-(BOOL)playRecordingForKey:(NSString *)key;
-(NSArray *)recordingKeys;
-(BOOL)deleteRecordingForKey:(NSString *)key;
-(void)deleteRecordingsForAllKeys;

//record
-(void)recordVoiceForKey:(NSString *)key;
-(void)stopRecordingAndSave:(BOOL)save;

//states
-(BOOL)isPlayingNativeAudio;
-(BOOL)isPlayingRecordedAudio;
-(BOOL)isRecordingAudio;


//highlighting
-(void)highlightWordAtIndex:(int)wordIndex;
-(void)highlightWordsInRange:(NSRange)wordsRange;

-(void)deselectWordAtIndex:(int)wordIndex;
-(void)deselectWordsInRange:(NSRange)wordsRange;

-(void)deselectAllWords;

-(BOOL)isWordHiglightedAtIndex:(int)wordIndex;
-(BOOL)isWordSelectedAtIndex:(int)wordIndex;

//getters
-(cdaInteractiveTextItem *)wordItemAtIndex:(int)wordIndex;


-(CGPoint)getRepeatButtonPosition;


@end
