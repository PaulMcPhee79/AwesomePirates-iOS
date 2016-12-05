//
//  RaceEvent.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 19/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CUST_EVENT_TYPE_RACE_UPDATE @"raceUpdateEvent"

@class Racer;

@interface RaceEvent : SPEvent {
	BOOL mRaceFinished;
    BOOL mCrossedFinishLine;
	double mLapTime;
	double mRaceTime;
	double mMph;
	int mLap;
	int mTotalLaps;
}

@property (nonatomic,readonly) BOOL raceFinished;
@property (nonatomic,readonly) BOOL crossedFinishLine;
@property (nonatomic,readonly) double lapTime;
@property (nonatomic,readonly) double raceTime;
@property (nonatomic,readonly) double mph;
@property (nonatomic,readonly) int lap;
@property (nonatomic,readonly) int totalLaps;

+ (RaceEvent *)raceEventWithRacer:(Racer *)racer bubbles:(BOOL)bubbles;
+ (double)requiredRaceTimeForLapCount:(int)lapCount;
+ (double)requiredSpeedDemonTimeForLapCount:(int)lapCount;
- (id)initWithRacer:(Racer *)racer bubbles:(BOOL)bubbles;

@end
