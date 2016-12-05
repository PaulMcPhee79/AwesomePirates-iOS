//
//  GCMisc.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 29/01/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameController.h"
#import "Cooldown.h"
#import "GCAsh.h"
#import "GCVoodoo.h"
#import "GCActor.h"
#import "GCTownAi.h"
#import "AshProc.h"
#import "ThisTurn.h"

@interface GCMisc : NSObject <NSCoding> {
	NSString *alias;
	GameState gameState;
	GameState queuedState;
	ThisTurn *thisTurn;
	int64_t infamy;
	int mutiny;
	uint day;
	uint timeOfDay;
	float timePassed;
	
	// Playfield
	int actorIdSeed; // Ensures we maintain unique actor IDs after a load.
	uint beachState;
	uint kegsRemaining;
	NSMutableArray *activeAshes;
	NSMutableArray *activeVoodoos;
	NSMutableArray *actors;
	GCTownAi *townAi;
	AshProc *ashProc;
	
	// Cove
	NSArray *coveVenueKeys;
	
	// Tavern
	uint numShotsMissed;
	uint bottlesState;
	BOOL infamyAwarded;
}

@property (nonatomic,copy) NSString *alias;
@property (nonatomic,assign) GameState gameState;
@property (nonatomic,assign) GameState queuedState;
@property (nonatomic,copy) ThisTurn *thisTurn;
@property (nonatomic,assign) int64_t infamy;
@property (nonatomic,assign) int mutiny;
@property (nonatomic,assign) uint day;
@property (nonatomic,assign) uint timeOfDay;
@property (nonatomic,assign) float timePassed;
// Playfield
@property (nonatomic,assign) int actorIdSeed;
@property (nonatomic,assign) uint beachState;
@property (nonatomic,assign) uint kegsRemaining;
@property (nonatomic,readonly) NSArray *activeAshes;
@property (nonatomic,readonly) NSArray *activeVoodoos;
@property (nonatomic,readonly) NSArray *actors;
@property (nonatomic,retain) GCTownAi *townAi;
@property (nonatomic,retain) AshProc *ashProc;
// Cove
@property (nonatomic,copy) NSArray *coveVenueKeys;
// Tavern
@property (nonatomic,assign) uint numShotsMissed;
@property (nonatomic,assign) uint bottlesState;
@property (nonatomic,assign) BOOL infamyAwarded;

+ (GCMisc *)gcMisc;

- (void)addActiveAsh:(GCAsh *)ash;
- (void)addActiveVoodoo:(GCVoodoo *)voodoo;
- (void)addActor:(GCActor *)actor;

@end
