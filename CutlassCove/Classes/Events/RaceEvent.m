//
//  RaceEvent.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 19/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RaceEvent.h"
#import "Racer.h"

const double kRequiredLapTime = 14.0; // 12.0;
const double kRequiredMph = 88.0;

const double kRequiredSpeedDemonMph = 120.0;
const double kRequiredSpeedDemonLapTime = kRequiredLapTime * (kRequiredMph / kRequiredSpeedDemonMph);

@implementation RaceEvent

@synthesize raceFinished = mRaceFinished;
@synthesize crossedFinishLine = mCrossedFinishLine;
@synthesize lapTime = mLapTime;
@synthesize raceTime = mRaceTime;
@synthesize mph = mMph;
@synthesize lap = mLap;
@synthesize totalLaps = mTotalLaps;

+ (RaceEvent *)raceEventWithRacer:(Racer *)racer bubbles:(BOOL)bubbles {
	return [[[RaceEvent alloc] initWithRacer:racer bubbles:bubbles] autorelease];
}

+ (double)requiredRaceTimeForLapCount:(int)lapCount {
	return lapCount * kRequiredLapTime;
}

+ (double)requiredSpeedDemonTimeForLapCount:(int)lapCount {
    return lapCount * kRequiredSpeedDemonLapTime;
}

- (double)calculateMph:(Racer *)racer {
	double requiredRaceTime = [RaceEvent requiredRaceTimeForLapCount:mTotalLaps] * ((racer.lap - 1) / (double)MAX(1,racer.totalLaps));
	double requiredLapTime = kRequiredLapTime * (racer.nextCheckpoint / (double)MAX(1,racer.totalCheckpoints));
	double mph = (SP_IS_FLOAT_EQUAL(racer.raceTime, 0)) ? 0 : kRequiredMph / MAX(0.5f, (racer.raceTime / MAX(1.0,requiredRaceTime + requiredLapTime)));
	
	// Smooth it out for lap 1 until the data pool averages out
	if (racer.lap == 1) {
        float fractionComplete = MIN(1.0f, racer.raceTime / kRequiredLapTime);
        mph = 96.0 * (1.0f - fractionComplete) + mph * fractionComplete;
    }

	return mph;
}

- (id)initWithRacer:(Racer *)racer bubbles:(BOOL)bubbles {
	if (self = [super initWithType:CUST_EVENT_TYPE_RACE_UPDATE bubbles:bubbles]) {
		mRaceFinished = racer.finishedRace;
        mCrossedFinishLine = racer.didJustCrossFinishLine;
		mLapTime = racer.lapTime;
		mRaceTime = racer.raceTime;
		mLap = racer.lap;
		mTotalLaps = racer.totalLaps;
		mMph = [self calculateMph:racer];
	}
	return self;
}

@end
