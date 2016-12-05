//
//  RaceTrackActor.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 19/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Actor.h"

#define CUST_EVENT_TYPE_RACE_FINISHED @"RaceFinishedEvent"
#define CUST_EVENT_TYPE_88MPH @"88MphEvent"
#define CUST_EVENT_TYPE_SPEED_DEMON @"SpeedDemonEvent"

@class ShipActor;

@interface RaceTrackActor : Actor {
	int mState;
    int mLapsPerRace;
	SPSprite *mFinishLine;
	NSMutableArray *mBuoys;
	NSMutableArray *mCheckpoints;
	NSMutableSet *mRacers;
	
	int mCheckpointCount;
	b2Fixture **mCheckpointFixtures;
	b2Fixture *mFinishLineFixture;
}

- (id)initWithActorDef:(ActorDef *)def laps:(int)laps;
- (void)setupRaceTrackWithDictionary:(NSDictionary *)dictionary;
- (void)prepareForNewRace;
- (void)stopRace;
- (void)prepareForNewLap;
- (void)addRacer:(ShipActor *)ship;
- (void)removeRacer:(ShipActor *)ship;

@end
