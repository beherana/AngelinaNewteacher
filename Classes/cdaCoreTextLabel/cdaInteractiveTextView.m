//
//  cdaInteractiveTextView.m

//
//  Created by Radif Sharafullin on 2/3/11.
//  Copyright 2011 Callaway Digital Arts. All rights reserved.
//

#import "cdaInteractiveTextView.h"
#import "cdaGlobalFunctions.h"

@interface cdaInteractiveTextView (topSecret)
-(void)initVars;
@end

@implementation cdaInteractiveTextView

@synthesize delegate,
wordsDictionary,
words,
highlightWordsWhenReading,
backgroundImage,
volume,
isNarrating,
sharedAudioManager,
audioFilePath,
secondaryView,
secondaryWordsDictionary,
secondaryViewSize;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		[self initVars];
    }
    return self;
}

#pragma mark alloc
-(void)fadeIn{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    [self setAlpha:1.0];
    [UIView commitAnimations];
}

//use a secondary view to show the same text
+(id)textViewWithFrame:(CGRect)frame wordsPlistPath:(NSString *)plistFile andSecondaryPlistFile:(NSString *) _secondaryPlistFile withSecondaryView:(UIView *)_secondaryView {
	return [self textViewWithFrame:frame wordsDictionary:[NSDictionary dictionaryWithContentsOfFile:plistFile] andSecondaryDictionary:[NSDictionary dictionaryWithContentsOfFile:_secondaryPlistFile] withSecondaryView:_secondaryView];
}

+(id)textViewWithFrame:(CGRect)frame wordsPlistPath:(NSString *)plistFile{
	return [self textViewWithFrame:frame wordsDictionary:[NSDictionary dictionaryWithContentsOfFile:plistFile]];
}

+(id)textViewWithFrame:(CGRect)frame wordsDictionary:(NSDictionary *)wDictionary andSecondaryDictionary:(NSDictionary *) _secondaryDictionary withSecondaryView:(UIView *) _secondaryView{
    return [[[self alloc] initWithFrame:frame wordsDictionary:wDictionary andSecondaryDictionary:_secondaryDictionary withSecondaryView:_secondaryView] autorelease];
}

+(id)textViewWithFrame:(CGRect)frame wordsDictionary:(NSDictionary *)wDictionary{
	return [[[self alloc] initWithFrame:frame wordsDictionary:wDictionary] autorelease];
}

-(id)initWithFrame:(CGRect)frame wordsDictionary:(NSDictionary *)wDictionary {
    return [self initWithFrame:frame wordsDictionary:wDictionary andSecondaryDictionary:nil withSecondaryView:nil];
}

-(id)initWithFrame:(CGRect)frame wordsDictionary:(NSDictionary *)wDictionary andSecondaryDictionary:(NSDictionary *)_secondaryDictionary withSecondaryView:(UIView *) _secondaryView{
	
	self = [super initWithFrame:frame];
	
	if (self) {
		self.secondaryView = _secondaryView;
        self.secondaryWordsDictionary = _secondaryDictionary;
		[self initVars];
		[self renderWithWordsDictionary:wDictionary];
		
	}
	return self;
}

-(void)initVars{
	self.userInteractionEnabled=YES;
	[cdaInteractiveTextAudioManager audioManagerRetain];
	sharedAudioManager=[cdaInteractiveTextAudioManager sharedAudioManager];
    sharedAudioManager.delegate = self;
}

-(id)initWithImage:(UIImage *)image{
	self=[super initWithImage:image];
		if (self) {

			[self initVars];
		}
	return self;
}
-(void)dealloc{
	[[cdaInteractiveTextAudioManager sharedAudioManager] stop];
	[cdaInteractiveTextAudioManager audioManagerRelease];
	self.wordsDictionary=nil;
	self.words=nil;
    self.secondaryView = nil;
    self.secondaryWordsDictionary = nil;
	self.audioFilePath=nil;
    self.delegate = nil;
	CDA_LOG_METHOD_NAME;
	[super  dealloc];
}
#pragma mark render
-(void)renderWithWordsDictionary:(NSDictionary *)wDictionary {
	[self setWordsDictionary:wDictionary];
	[self renderWithCurrentSettings];
}
-(void)renderWithCurrentSettings{
	[self removeAllWords];
	//audio file path
	self.audioFilePath=[cdaGlobalFunctions cdaPath:[wordsDictionary objectForKey:@"audioFilePath"]];

	//size
	
	if ([wordsDictionary objectForKey:@"frame"]) {
		CGRect fr=CGRectFromString([wordsDictionary objectForKey:@"frame"]);
        fr.origin.x=ceil(fr.origin.x);
        fr.origin.y=ceil(fr.origin.y);
        fr.size.width=ceil(fr.size.width);
        fr.size.height=ceil(fr.size.height);
        self.frame=fr;
					 
	}
    //get the size of the secondary view
    if (self.secondaryWordsDictionary != nil && [self.secondaryWordsDictionary objectForKey:@"frame"]) {
        CGRect sFrame=CGRectFromString([self.secondaryWordsDictionary objectForKey:@"frame"]);
        self.secondaryViewSize = sFrame.size;
    }
	
	//backgoundImage
	
	if ([wordsDictionary objectForKey:@"backgoundImageScaleFit"]) {
		BOOL fit=[[wordsDictionary objectForKey:@"backgoundImageScaleFit"] boolValue];
		self.contentMode = fit ? UIViewContentModeScaleAspectFit : UIViewContentModeScaleAspectFill;
	}
	if ([wordsDictionary objectForKey:@"backgoundImage"]) {
		NSString *imagePath=[cdaGlobalFunctions cdaPath:[wordsDictionary objectForKey:@"backgoundImage"]];
		
		self.image=[UIImage imageWithContentsOfFile:imagePath];
		
	}
	
	
	UIColor *bgColor=[UIColor clearColor];
	if ([wordsDictionary objectForKey:@"backgroundColor"]) bgColor=UIColorFromRGBAString([wordsDictionary objectForKey:@"backgroundColor"]);
	self.backgroundColor=bgColor;
	
	//words
	NSArray *wordsList=[self.wordsDictionary objectForKey:@"words"];
	self.words=[NSMutableArray array];
	int counter=0;
	for (NSDictionary *word in wordsList) {
		cdaInteractiveTextItem *wordItem=[[[cdaInteractiveTextItem alloc]initWithDictionary:word onView:self] autorelease];
		wordItem.wordIndex=counter;
		wordItem.delegate=self;
		[self.words addObject:wordItem];
        
        //if secondary dictionary
        if (self.secondaryWordsDictionary != nil) {
            //get the corresponding word from the secondary list
            NSArray *secondaryWordsList=[self.secondaryWordsDictionary objectForKey:@"words"];
            NSAssert(([secondaryWordsList count] == [wordsList count]), @"Number of words in secondary word list does not match");
            NSDictionary *secondaryWord = [secondaryWordsList objectAtIndex:wordItem.wordIndex];

            //get current word from dictionary
            cdaInteractiveTextItem *secondaryWordItem=[[[cdaInteractiveTextItem alloc]initWithDictionary:secondaryWord onView:self.secondaryView] autorelease];
            secondaryWordItem.delegate = nil;
            secondaryWordItem.wordIndex = counter;
            
            //inherit some properties from the original word
            secondaryWordItem.highlightTimeFrom = wordItem.highlightTimeFrom;
            secondaryWordItem.highlightTimeTo   = wordItem.highlightTimeTo;
            
            [self.words addObject:secondaryWordItem];
        }
        
        counter++;
	}

}
-(void)removeAllWords{
	
for (cdaInteractiveTextItem *wordItem in self.words) {
	[wordItem removeFromSuperview];
}
	self.words=nil;
	
}
#pragma mark play
-(void)resetWords {
    [self deselectAllWords];
	lastHighlightedWordIndex=0;
}
-(void)play{
    [self resetWords];
	[self.sharedAudioManager playAudioWithPath:self.audioFilePath observer:self];
}
-(void)playWordAtIndex:(int)index{
	[self.sharedAudioManager playAudioFile:[[self.words objectAtIndex:index]wordAudioFilePath]];
}
-(void)pause{
	[[self sharedAudioManager] pause];
}
-(void)unpause{    
	[[self sharedAudioManager] unpause];
}
-(void)stop{
	[self.sharedAudioManager stop];
}
-(void)restart{
	[[self sharedAudioManager] restart:self.audioFilePath observer:self];
}

#pragma mark recording
-(BOOL)playRecordingForKey:(NSString *)key{
	[self deselectAllWords];
	return [[self sharedAudioManager] playRecordingForKey:key];
}
-(NSArray *)recordingKeys{
	return [self.sharedAudioManager recordingKeys];
}
-(BOOL)deleteRecordingForKey:(NSString *)key{
	return [[self sharedAudioManager] deleteRecordingForKey:key];
}
-(void)deleteRecordingsForAllKeys{
	[self.sharedAudioManager deleteRecordingsForAllKeys];
}

-(void)recordVoiceForKey:(NSString *)key{
	[self deselectAllWords];
	[self.sharedAudioManager recordVoiceForKey:key];
}

-(void)stopRecordingAndSave:(BOOL)save{
	[self deselectAllWords];
	[self.sharedAudioManager stopRecordingAndSave:save];
}


-(void)setBackgroundImage:(UIImage *)img{
	[self setImage:img];
}


#pragma mark getters
-(cdaInteractiveTextItem *)wordItemAtIndex:(int)wordIndex{
	
	return [self.words objectAtIndex:wordIndex];
}
//states
-(BOOL)isPlayingNativeAudio{
	return [self.sharedAudioManager isPlayingNativeAudio];
}
-(BOOL)isPlayingRecordedAudio{
	return [self.sharedAudioManager isPlayingRecordedAudio];
}
-(BOOL)isRecordingAudio{
	return [self.sharedAudioManager isRecording];
}

-(CGPoint)getRepeatButtonPosition
{
    cdaInteractiveTextItem *lastWord = [self.words lastObject];
    float x = self.frame.origin.x + lastWord.frame.origin.x + lastWord.frame.size.width + 10;
    float y = self.frame.origin.y + lastWord.frame.origin.y + 15;
    return CGPointMake(x, y);
}


#pragma mark UIResponder
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	//[super touchesBegan:touches withEvent:event];
	NSSet *allTouches = [event allTouches];
	if ([allTouches count]>1) {
		if(![self.sharedAudioManager isPlayingNativeAudio]) [self deselectAllWords];
		return;//bail out if more than one finger is on the screen
	}
	UITouch *touch=[allTouches anyObject];
	UIView *touchedView=[touch view];
	if (touchedView==self){
		if ([delegate respondsToSelector:@selector(cdaInteractiveTextView:backgroundTappedAtPosition:)]) [delegate cdaInteractiveTextView:self backgroundTappedAtPosition:[touch locationInView:self]]; 
        [super touchesBegan:touches withEvent:event];
	}else {
		if ([self isRecordingAudio]) return;
		if ([touchedView isKindOfClass:[cdaInteractiveTextItem class]]) {
		//change state to selected
		BOOL should=YES;
		if ([delegate respondsToSelector:@selector(cdaInteractiveTextView:shouldSelectWordItem:)]) should=[delegate cdaInteractiveTextView:self shouldSelectWordItem:(cdaInteractiveTextItem *)touch.view]; 
		if (should) {
			[self deselectAllWords];
			[(cdaInteractiveTextItem *)touch.view setTextItemState:cdaInteractiveTextItemStateSelected];
		}
		
		should=YES;
		if ([delegate respondsToSelector:@selector(cdaInteractiveTextView:shouldPlaySelectedWord:)]) should=[delegate cdaInteractiveTextView:self shouldPlaySelectedWord:(cdaInteractiveTextItem *)touch.view]; 
		if (should) [self playWordAtIndex:[(cdaInteractiveTextItem *)touch.view wordIndex]];
		
		
		if ([delegate respondsToSelector:@selector(cdaInteractiveTextView:wordTapped:position:)]) [delegate cdaInteractiveTextView:self wordTapped:(cdaInteractiveTextItem *)touch.view position:[touch locationInView:touch.view]]; 
	}
	}
	
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	[super touchesEnded:touches withEvent:event];
	NSSet *allTouches = [event allTouches];
	UITouch *touch=[allTouches anyObject];
	UIView *touchedView=[touch view];
	if ([touchedView isKindOfClass:[cdaInteractiveTextItem class]]){
		
		//change state to selected
		BOOL should=YES;
		if ([delegate respondsToSelector:@selector(cdaInteractiveTextView:shouldDeselectWordItem:)]) should=[delegate cdaInteractiveTextView:self shouldDeselectWordItem:(cdaInteractiveTextItem *)touch.view]; 
		if (should) [(cdaInteractiveTextItem *)touch.view setTextItemState:cdaInteractiveTextItemStateNormal];
	}else [self deselectAllWords];
	
	
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
	[super touchesCancelled:touches withEvent:event];
	[self touchesEnded:touches withEvent:event];
}


#pragma mark Observer
-(void)cdaInteractiveTextAudioManager:(cdaInteractiveTextAudioManager *)audioManager isPlayingCurrentTime:(NSTimeInterval)currentTime{
	int count=words.count;
	for (int i=lastHighlightedWordIndex-6; i<count; ++i) {
		if (i>lastHighlightedWordIndex+6) break;
		if (i>=0) {
			
		cdaInteractiveTextItem *wordItem=[words objectAtIndex:i];
		if (wordItem.highlightTimeFrom<currentTime && wordItem.highlightTimeTo>currentTime){
			[wordItem setTextItemState:cdaInteractiveTextItemStateHighlighted];
			lastHighlightedWordIndex=i;
		}
		else
			[wordItem setTextItemState:cdaInteractiveTextItemStateNormal];
		}
	}
}
#pragma mark highlighting
-(void)highlightWordAtIndex:(int)wordIndex{
	cdaInteractiveTextItem *wordItem=[words objectAtIndex:wordIndex];
	[wordItem setTextItemState:cdaInteractiveTextItemStateHighlighted];
}
-(void)highlightWordsInRange:(NSRange)wordsRange{
	int endRange=wordsRange.location+wordsRange.length;
	for (int i=wordsRange.location; i<endRange; ++i) {
		cdaInteractiveTextItem *wordItem=[words objectAtIndex:i];
		[wordItem setTextItemState:cdaInteractiveTextItemStateHighlighted];
	}
}

-(void)deselectWordAtIndex:(int)wordIndex{
	cdaInteractiveTextItem *wordItem=[words objectAtIndex:wordIndex];
	[wordItem setTextItemState:cdaInteractiveTextItemStateNormal];
	
}
-(void)deselectWordsInRange:(NSRange)wordsRange{
	int endRange=wordsRange.location+wordsRange.length;
	for (int i=wordsRange.location; i<endRange; ++i) {
		cdaInteractiveTextItem *wordItem=[words objectAtIndex:i];
		[wordItem setTextItemState:cdaInteractiveTextItemStateNormal];
	}
}

-(void)deselectAllWords{
	for (cdaInteractiveTextItem *wordItem in self.words) {
        BOOL should=YES;
		if ([delegate respondsToSelector:@selector(cdaInteractiveTextView:shouldDeselectWordItem:)]) should=[delegate cdaInteractiveTextView:self shouldDeselectWordItem:wordItem]; 
		if (should) [wordItem setTextItemState:cdaInteractiveTextItemStateNormal];
        
    }
}

-(BOOL)isWordHiglightedAtIndex:(int)wordIndex{
	cdaInteractiveTextItem *wordItem=[words objectAtIndex:wordIndex];
	return [wordItem textItemState]==cdaInteractiveTextItemStateHighlighted;
}
-(BOOL)isWordSelectedAtIndex:(int)wordIndex{
	cdaInteractiveTextItem *wordItem=[words objectAtIndex:wordIndex];
	return [wordItem textItemState]==cdaInteractiveTextItemStateSelected;
}
         
#pragma mark - Audio callbacks
- (void)cdaInteractiveTextAudioManagerDidStartPlaying:(cdaInteractiveTextAudioManager *)interactiveTextAudioManager
{
    if ([self.delegate respondsToSelector:@selector(cdaInteractiveTextViewDidStartPlayback:recordedAudio:)]) {
        [self.delegate cdaInteractiveTextViewDidStartPlayback:self recordedAudio:[self.sharedAudioManager isPlayingRecordedAudio]];
    }
}
- (void)cdaInteractiveTextAudioManagerDidFinishPlaying:(cdaInteractiveTextAudioManager *)interactiveTextAudioManager successfully:(BOOL)flag
{
    if ([self.delegate respondsToSelector:@selector(cdaInteractiveTextViewDidStopPlayback: recordedAudio:)]) {
        [self.delegate cdaInteractiveTextViewDidStopPlayback:self recordedAudio:[self.sharedAudioManager isPlayingRecordedAudio]];
    }
    [self deselectAllWords];
}

-(void)cdaInteractiveTextAudioManagerWillRestartPlaying:(cdaInteractiveTextAudioManager *)interactiveTextAudioManager {
    [self resetWords];
}
        
@end
