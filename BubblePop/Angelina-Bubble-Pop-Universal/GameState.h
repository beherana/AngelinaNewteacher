//
//  GameState.h
//  Angelina-Bubble-Pop-Universal
//
//  Created by Karl Söderström on 2011-08-16.
//  Copyright 2011 Commind AB. All rights reserved.
//

typedef enum {
    AngelinaGameMode_Unknown = 0,
    AngelinaGameMode_Classic,
    AngelinaGameMode_Clock
} AngelinaGameMode;

@interface GameState : NSObject {
    @private
    BOOL _tutorialMode;
    NSDate *_timeOfLastCorrectBubbleSpawn;
    int _lastFlowerType;
    int _numOfLastFlowerType;
    AngelinaGameMode _gameMode;
    int _livesLostWithoutScore;
    NSMutableDictionary *_bubbleStats;
}

@property (nonatomic, assign) BOOL tutorialMode;
@property (nonatomic, retain) NSDate *timeOfLastCorrectBubbleSpawn;
@property (nonatomic, assign) int lastFlowerType;
@property (nonatomic, assign) int numOfLastFlowerType;
@property (nonatomic, assign) AngelinaGameMode gameMode;
@property (nonatomic, assign) int livesLostWithoutScore;
@property (nonatomic, retain) NSMutableDictionary *bubbleStats;

+ (GameState *)sharedInstance;
- (void) incrementBubbleStats:(NSString *) bubbleType;

@end
