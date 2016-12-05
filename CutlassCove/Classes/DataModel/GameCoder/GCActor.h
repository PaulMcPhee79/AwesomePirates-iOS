//
//  GCActor.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 31/01/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCCannonball.h"

@interface GCDestination : NSObject <NSCoding> {
	BOOL finishIsDest;
	int spawnPlaneStart;
	int spawnPlaneFinish;
	int seaLaneA;
	int seaLaneB;
	SPPoint *adjustedSeaLaneC;
}

@property (nonatomic,assign) BOOL finishIsDest;
@property (nonatomic,assign) int spawnPlaneStart;
@property (nonatomic,assign) int spawnPlaneFinish;
@property (nonatomic,assign) int seaLaneA;
@property (nonatomic,assign) int seaLaneB;
@property (nonatomic,retain) SPPoint *adjustedSeaLaneC;

@end

@class Prisoner;

@interface GCActor : NSObject <NSCoding> {
	NSString *key;
	int actorId;
	
	// Special Ship Escorts
	uint fleetEscort;
    uint fleetID;
	
	// Pursuit Ship Duel State
	int duelState;
	
	float x;
	float y;
	float rotation;
	GCDestination *dest;
	Prisoner *prisoner;
	NSMutableArray *cannonballs;
	NSMutableArray *enemyIds;
}

@property (nonatomic,copy) NSString *key;
@property (nonatomic,assign) int actorId;
@property (nonatomic,assign) uint fleetEscort;
@property (nonatomic,assign) uint fleetID;
@property (nonatomic,assign) int duelState;
@property (nonatomic,assign) float x;
@property (nonatomic,assign) float y;
@property (nonatomic,assign) float rotation;
@property (nonatomic,retain) GCDestination *dest;
@property (nonatomic,retain) Prisoner *prisoner;
@property (nonatomic,readonly) NSArray *cannonballs;
@property (nonatomic,readonly) NSArray *enemyIds;
@property (nonatomic,readonly) int firstEnemyId;

- (id)initWithKey:(NSString *)actorKey;
- (void)addCannonball:(GCCannonball *)cannonball;
- (void)addEnemyId:(int)enemyId;

@end
