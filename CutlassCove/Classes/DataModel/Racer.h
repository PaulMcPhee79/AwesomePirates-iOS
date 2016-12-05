//
//  Racer.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 19/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ShipActor;

@interface Racer : SPEventDispatcher {
	BOOL mRacing;
    BOOL mDidJustCrossFinishLine;
	int mUpdateThrottle;
	int mTotalCheckpoints;
	int mNextCheckpoint;
	int mPrevCheckpoint;
	int mTotalLaps;
	int mLap;
	double mLapTime;
	double mRaceTime;
	ShipActor *mOwner;
}

@property (nonatomic,readonly) BOOL racing;
@property (nonatomic,readonly) BOOL finishedRace;
@property (nonatomic,readonly) BOOL didJustCrossFinishLine;
@property (nonatomic,readonly) double lapTime;
@property (nonatomic,readonly) double raceTime;
@property (nonatomic,readonly) int lap;
@property (nonatomic,readonly) int totalLaps;
@property (nonatomic,readonly) int nextCheckpoint;
@property (nonatomic,readonly) int prevCheckpoint;
@property (nonatomic,readonly) int totalCheckpoints;
@property (nonatomic,readonly) ShipActor *owner;

- (id)initWithOwner:(ShipActor *)owner laps:(int)laps checkpoints:(int)checkpoints;
- (void)prepareForNewRace;
- (void)startRace;
- (int)checkpointReached:(int)index; // Returns new checkpoint value, if it was a valid update
- (BOOL)finishLineCrossed;
- (void)broadcastRaceUpdate;
- (void)advanceTime:(double)time;

@end
