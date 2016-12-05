//
//  RaceTrackActor.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 19/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RaceTrackActor.h"
#import "ShipActor.h"
#import "PlayerShip.h"
#import "Racer.h"
#import "RaceEvent.h"
#import "MultiPurposeEvent.h"
#import "Globals.h"

#define RACE_STATE_STOPPED 0x0
#define RACE_STATE_GRID 0x1
#define RACE_STATE_RUNNING 0x2

const int kDefaultLapsPerRace = 5;

@interface RaceTrackActor ()

- (void)setState:(int)state;
- (void)setupFinishLine:(NSDictionary *)finishLine;
- (void)setupPerimeterBuoys:(NSArray *)buoys;
- (void)setupCheckpoints:(NSArray *)checkpoints;
- (Racer *)containsRacer:(ShipActor *)ship;
- (void)markCheckpointAtIndex:(int)index;
- (void)markCheckpoint:(SPImage *)checkpoint;
- (void)unmarkCheckpointAtIndex:(int)index;
- (void)unmarkCheckpoint:(SPImage *)checkpoint;
- (int)findCheckpointIndex:(b2Fixture *)fixture;

@end


@implementation RaceTrackActor

- (id)initWithActorDef:(ActorDef *)def laps:(int)laps {
    if (self = [super initWithActorDef:def]) {
		mCategory = CAT_PF_SEA;
		mAdvanceable = YES;
		mFinishLine = nil;
        mLapsPerRace = laps;
		mBuoys = [[NSMutableArray alloc] initWithCapacity:88];
		mRacers = [[NSMutableSet alloc] init];
		
		// Save checkpoints to compare in collision processing
		mCheckpointCount = def->fixtureDefCount - 1;
        mCheckpoints = [[NSMutableArray alloc] initWithCapacity:mCheckpointCount];
		mCheckpointFixtures = new b2Fixture*[mCheckpointCount];
		memcpy(mCheckpointFixtures, def->fixtures, mCheckpointCount * sizeof(b2Fixture*));
		mFinishLineFixture = def->fixtures[def->fixtureDefCount - 1];
		mState = RACE_STATE_STOPPED;
    }
    return self;
}

- (id)initWithActorDef:(ActorDef *)def {
    return [self initWithActorDef:def laps:kDefaultLapsPerRace];
}

- (void)setupRaceTrackWithDictionary:(NSDictionary *)dictionary {
	NSArray *buoys = (NSArray *)[dictionary objectForKey:@"Buoys"];
	NSArray *checkpoints = (NSArray *)[dictionary objectForKey:@"Checkpoints"];
	NSDictionary *finishLine = (NSDictionary *)[dictionary objectForKey:@"FinishLine"];


	[self setupPerimeterBuoys:buoys];
	[self setupCheckpoints:checkpoints];
	[self setupFinishLine:finishLine];
[RESM pushItemOffsetWithAlignment:RACenter];
    self.rx = self.x; self.ry = self.y;
[RESM popOffset];
}

- (void)setupFinishLine:(NSDictionary *)finishLine {
	BOOL colorSwitch = YES; // For checkered flag
	SPSprite *sprite = [[SPSprite alloc] init];
	mFinishLine = [[SPSprite alloc] init];
	
	for (int i = 0; i < 16; i+=8) {
		for (int j = 0; j < 40; j+=8) {
			SPQuad *quad = [[SPQuad alloc] initWithWidth:8.0f height:8.0f];
			quad.x = j;
			quad.y = i;
			quad.color = (colorSwitch == YES) ? SP_WHITE : SP_BLACK;
			[sprite addChild:quad];
			[quad release];
			colorSwitch = !colorSwitch;
		}
	}
	sprite.x = -sprite.width / 2;
	sprite.y = -sprite.height / 2;
	mFinishLine.x = [(NSNumber *)[finishLine objectForKey:@"x"] floatValue];
	mFinishLine.y = [(NSNumber *)[finishLine objectForKey:@"y"] floatValue];
	mFinishLine.rotation = SP_D2R([(NSNumber *)[finishLine objectForKey:@"rotation"] floatValue]);
	[mFinishLine addChild:sprite];
	[self addChild:mFinishLine];
	[sprite release];
}

- (void)setupPerimeterBuoys:(NSArray *)buoys {
	if (mFinishLine != nil)
		return;
	SPTexture *buoyTexture = (SPTexture *)[mScene textureByName:@"buoy"];
	
	for (NSDictionary *dict in buoys) {
		SPImage *image = [[SPImage alloc] initWithTexture:buoyTexture];
		image.x = [(NSNumber *)[dict objectForKey:@"x"] floatValue];
		image.y = [(NSNumber *)[dict objectForKey:@"y"] floatValue];
		[mBuoys addObject:image];
		[self addChild:image];
		[image release];
	}
}

- (void)setupCheckpoints:(NSArray *)checkpoints {
	if (mCheckpoints.count > 0)
		return;
	SPTexture *arrowTexture = (SPTexture *)[mScene textureByName:@"race-arrow"];
	
	for (NSDictionary *dict in checkpoints) {
		SPSprite *sprite = [[SPSprite alloc] init];
		SPImage *image = [[SPImage alloc] initWithTexture:arrowTexture];
		image.x = -image.width / 2;
		image.y = -image.height / 2;
		[mCheckpoints addObject:image];
		[sprite addChild:image];
		
		sprite.x = [(NSNumber *)[dict objectForKey:@"x"] floatValue];
		sprite.y = [(NSNumber *)[dict objectForKey:@"y"] floatValue];
		sprite.rotation = SP_D2R([(NSNumber *)[dict objectForKey:@"rotation"] floatValue]);
		[self addChild:sprite];
		
		[image release];
		[sprite release];
	}
}

- (void)setState:(int)state {
	switch (state) {
		case RACE_STATE_STOPPED:
        {
            NSArray *racers = [mRacers allObjects];
            
			for (Racer *racer in racers) {
				if ([racer.owner isKindOfClass:[PlayerShip class]] && racer.finishedRace) {
                    bool speedDemonAchievecd = racer.raceTime <= [RaceEvent requiredSpeedDemonTimeForLapCount:racer.totalLaps];
                    bool greatScottAchieved = racer.raceTime <= [RaceEvent requiredRaceTimeForLapCount:racer.totalLaps];
                    
                    MultiPurposeEvent *mpEvent = [MultiPurposeEvent multiPurposeEventWithType:CUST_EVENT_TYPE_RACE_FINISHED bubbles:NO];
                    [mpEvent.data setObject:[NSNumber numberWithBool:speedDemonAchievecd || greatScottAchieved] forKey:CUST_EVENT_TYPE_RACE_FINISHED];
                    [self dispatchEvent:mpEvent];
                    
                    if (speedDemonAchievecd)
                        [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_SPEED_DEMON]];
                    else if (greatScottAchieved)
                        [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_88MPH]];
                }
			}
        }
			break;
		case RACE_STATE_GRID:
			for (Racer *racer in mRacers)
				[racer prepareForNewRace];
			break;
		case RACE_STATE_RUNNING:
			for (Racer *racer in mRacers)
				[racer startRace];
			break;
		default:
			assert(0);
			break;
	}
	mState = state;
}

- (void)prepareForNewRace {
	for (SPImage *checkpoint in mCheckpoints)
		[self unmarkCheckpoint:checkpoint];
	[self setState:RACE_STATE_GRID];
}

- (void)stopRace {
	for (SPImage *checkpoint in mCheckpoints)
		[self unmarkCheckpoint:checkpoint];
	[self setState:RACE_STATE_STOPPED];
}

- (void)prepareForNewLap {
	SPImage *checkpoint = (SPImage *)[mCheckpoints objectAtIndex:0];
	[self markCheckpoint:checkpoint];
}

- (void)markCheckpointAtIndex:(int)index {
	if (index >= 0 && index < mCheckpoints.count)
		[self markCheckpoint:(SPImage *)[mCheckpoints objectAtIndex:index]];
}

- (void)markCheckpoint:(SPImage *)checkpoint {
	checkpoint.color = 0x00ff00;
}
		 
- (void)unmarkCheckpointAtIndex:(int)index {
	if (index >= 0 && index < mCheckpoints.count)
		[self unmarkCheckpoint:(SPImage *)[mCheckpoints objectAtIndex:index]];
}		 

- (void)unmarkCheckpoint:(SPImage *)checkpoint {
	checkpoint.color = 0xff0000;
}

- (void)addRacer:(ShipActor *)ship {
	if (ship && [self containsRacer:ship] == nil) {
		Racer *racer = [[Racer alloc] initWithOwner:ship laps:mLapsPerRace checkpoints:mCheckpoints.count];
		[mRacers addObject:racer];
        [racer broadcastRaceUpdate];
		[racer release];
	}
}

- (Racer *)containsRacer:(ShipActor *)ship {
	Racer *foundRacer = nil;
	
	for (Racer *racer in mRacers) {
		if (racer.owner == ship) {
			foundRacer = racer;
			break;
		}
	}
	return foundRacer;
}

- (void)removeRacer:(ShipActor *)ship {
	Racer *removeRacer = nil;
	
	for (Racer *racer in mRacers) {
		if (racer.owner == ship) {
			removeRacer = racer;
			break;
		}
	}
	
	if (removeRacer != nil)
		[mRacers removeObject:removeRacer];
}

- (int)findCheckpointIndex:(b2Fixture *)fixture {
	int index = -1;
	
	for (int i = 0; i < mCheckpointCount; ++i) {
		if (fixture == mCheckpointFixtures[i]) {
			index = i;
			break;
		}
	}
	//NSLog(@"Checkpoint Index: %d", index);
	return index;
}

- (void)beginContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
	Racer *racer = [self containsRacer:(ShipActor *)other];
	
	if (racer && mState == RACE_STATE_RUNNING && fixtureSelf != mFinishLineFixture) {
		int index = [self findCheckpointIndex:fixtureSelf];
		int checkpoint = [racer checkpointReached:index];
		
		if (index != checkpoint) {
			[self markCheckpointAtIndex:checkpoint];
			[self unmarkCheckpointAtIndex:racer.prevCheckpoint];
		}
	}
}

- (void)endContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
	Racer *racer = [self containsRacer:(ShipActor *)other];
	
	if (racer && mState != RACE_STATE_STOPPED && fixtureSelf == mFinishLineFixture) {
		if (mState == RACE_STATE_GRID) {
			[self setState:RACE_STATE_RUNNING];
		} else {
			BOOL racing = [racer finishLineCrossed];
			
			if (racing == NO)
				[self setState:RACE_STATE_STOPPED];
			else
				[self markCheckpointAtIndex:racer.nextCheckpoint];
		}
	}
}

- (void)advanceTime:(double)time {
	if (mState == RACE_STATE_RUNNING) {
		for (Racer *racer in mRacers)
			[racer advanceTime:time];
	}
}

- (void)prepareForNewGame {
    // Do nothing
}

- (void)zeroOutFixtures {
	[super zeroOutFixtures];
	
	mFinishLineFixture = 0;
	delete [] mCheckpointFixtures; mCheckpointFixtures = 0; // Individual fixtures destroyed by b2World
}

- (void)dealloc {
	mFinishLineFixture = 0;
	delete [] mCheckpointFixtures; mCheckpointFixtures = 0; // Individual fixtures destroyed by b2World
	[mFinishLine release]; mFinishLine = nil;
	[mBuoys release]; mBuoys = nil;
	[mCheckpoints release]; mCheckpoints = nil;
	[mRacers release]; mRacers = nil;
	[super dealloc];
}

@end
