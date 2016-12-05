//
//  ThisTurn.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 3/09/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kMutinyThreshold 6

typedef enum {
    AdvStateNormal = 0,
    AdvStateStopShips,
    AdvStateOverboard,
    AdvStateEaten,
    AdvStateDead
} AdventureState;

@class Countdown;

@interface ThisTurn : SPEventDispatcher <NSCoding,NSCopying> {
    BOOL wasGameProgressMade;
    
    uint turnID;
	uint settings;

    int mutiny;
    Countdown *mutinyCountdown;
    
    float potionMultiplier;
    uint infamyMultiplier;
    int64_t infamy;
    
    double speed;
    double lapTimes[3];
    
    // Stats
    BOOL statsCommitted;
    uint cannonballsShot;
	uint cannonballsHit;
    uint shipsSunk;
    float daysAtSea;
    
    // Modes/States
    NSString *gameMode;
    AdventureState adventureState;
}

@property (nonatomic,assign) BOOL wasGameProgressMade;
@property (nonatomic,assign) uint turnID;
@property (nonatomic,assign) uint settings;
@property (nonatomic,assign) BOOL isGameOver;
@property (nonatomic,assign) BOOL assistedAiming;
@property (nonatomic,assign) BOOL tutorialMode;
@property (nonatomic,readonly) int mutinyThreshold;
@property (nonatomic,readonly) BOOL playerShouldDie;
@property (nonatomic,assign) int mutiny;
@property (nonatomic,copy) Countdown *mutinyCountdown;
@property (nonatomic,assign) float potionMultiplier;
@property (nonatomic,assign) uint infamyMultiplier;
@property (nonatomic,assign) int64_t infamy;
@property (nonatomic,assign) double speed;
@property (nonatomic,readonly) uint difficultyMultiplier;
@property (nonatomic,copy) NSString *gameMode;
@property (nonatomic,assign) AdventureState adventureState;

// Stats
@property (nonatomic,assign) uint cannonballsShot;
@property (nonatomic,assign) uint cannonballsHit;
@property (nonatomic,assign) uint shipsSunk;
@property (nonatomic,readonly) float cannonAccuracy;
@property (nonatomic,assign) float daysAtSea;

- (void)commitStats;
- (void)prepareForNewTurn;

- (void)addMutiny:(int)value;
- (void)reduceMutinyCountdown:(float)amount;
- (void)resetMutinyCountdown;

- (int64_t)addInfamy:(int64_t)value;
- (int64_t)addInfamyUnfiltered:(int64_t)value;

// Base index of one (not zero).
- (double)timeForLap:(int)lap;
- (void)setTime:(double)lapTime forLap:(int)lap;
- (double)totalRaceTime;

@end
