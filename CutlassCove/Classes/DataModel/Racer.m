//
//  Racer.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 19/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Racer.h"
#import "RaceEvent.h"
#import "GameController.h"

const int kUpdateThrottleLimit = 3; // Prevent excessive event generation

@interface Racer ()

- (void)nextCheckpointSetTo:(int)value;

@end


@implementation Racer

@synthesize racing = mRacing;
@synthesize didJustCrossFinishLine = mDidJustCrossFinishLine;
@synthesize lapTime = mLapTime;
@synthesize raceTime = mRaceTime;
@synthesize lap = mLap;
@synthesize totalLaps = mTotalLaps;
@synthesize totalCheckpoints = mTotalCheckpoints;
@synthesize nextCheckpoint = mNextCheckpoint;
@synthesize prevCheckpoint = mPrevCheckpoint;
@synthesize owner = mOwner;
@dynamic finishedRace;


- (id)initWithOwner:(ShipActor *)owner laps:(int)laps checkpoints:(int)checkpoints {
	if (self = [super init]) {
		mRacing = NO;
        mDidJustCrossFinishLine = NO;
		mUpdateThrottle = 0;
		mLap = 0;
		mTotalLaps = laps;
		mNextCheckpoint = 0;
		mTotalCheckpoints = checkpoints;
		mPrevCheckpoint = mTotalCheckpoints - 1;
		mLapTime = 0;
		mRaceTime = 0;
		mOwner = [owner retain];
		[self addEventListener:@selector(onRaceUpdate:) atObject:mOwner forType:CUST_EVENT_TYPE_RACE_UPDATE];
	}
	return self;
}

- (BOOL)finishedRace {
    return (mLap == mTotalLaps && mRacing == NO);
}

- (void)nextCheckpointSetTo:(int)value {
	if (value <= mTotalCheckpoints) {
		mPrevCheckpoint = mNextCheckpoint;
		mNextCheckpoint = value;
	}
}

- (void)prepareForNewRace {
	mLap = 0;
	mNextCheckpoint = 0;
	mPrevCheckpoint = mTotalCheckpoints - 1;
	mLapTime = 0;
	mRaceTime = 0;
}

- (void)startRace {
	mRacing = YES;
	mLap = 1;
}

- (int)checkpointReached:(int)index {
	if (mRacing == YES && index == mNextCheckpoint)
		[self nextCheckpointSetTo:mNextCheckpoint + 1];
	return mNextCheckpoint;
}

- (BOOL)finishLineCrossed {
	if (mRacing == YES && mNextCheckpoint == mTotalCheckpoints) {
        mDidJustCrossFinishLine = YES;
        
		if (mLap < mTotalLaps) {
            [self broadcastRaceUpdate];
			++mLap;
			mLapTime = 0;
			[self nextCheckpointSetTo:0];
		} else {
			mRacing = NO;
            [self broadcastRaceUpdate];
		}
        
        mDidJustCrossFinishLine = NO;
	}

	return mRacing;
}

- (void)broadcastRaceUpdate {
    [self dispatchEvent:[RaceEvent raceEventWithRacer:self bubbles:NO]];
}

- (void)advanceTime:(double)time {
	if (mRacing == YES) {
		mLapTime += time;
		mRaceTime += time;
	}
	
	if (++mUpdateThrottle == kUpdateThrottleLimit) {
		mUpdateThrottle = 0;
		[self broadcastRaceUpdate];
	}
}

- (void)dealloc {
	[mOwner release]; mOwner = nil;
	[super dealloc];
}

@end
