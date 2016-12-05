//
//  PoolActor.h
//  Cutlass Cove
//
//  Created by Paul McPhee on 5/11/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Actor.h"
#import "ResourceClient.h"

typedef enum {
	PoolActorStateIdle = 0,
	PoolActorStateSpawning,
	PoolActorStateSpawned,
	PoolActorStateDespawning,
	PoolActorStateDespawned
} PoolActorState;

@class NpcShip;
@class OverboardActor;
@class VertexAnimator;

const int kMaxPoolActorRipples = 3;

@interface PoolActor : Actor <ResourceClient> {
	PoolActorState mState;
	
    double mDuration;
	double mDurationRemaining;
    
    SPSprite *mCostume;
    
    VertexAnimator *mVAnim[kMaxPoolActorRipples];
	NSMutableArray *mRipples;
	ResourceServer *mResources;
}

@property (nonatomic,readonly) double durationRemaining;
@property (nonatomic,readonly) BOOL despawning;

// Override in subclass
@property (nonatomic,readonly) double fullDuration;
@property (nonatomic,readonly) uint bitmapID;
@property (nonatomic,readonly) uint deathBitmap;
@property (nonatomic,readonly) NSString *poolTextureName;
@property (nonatomic,readonly) NSString *resourcesKey;


+ (float)spawnDuration;
+ (float)despawnDuration;
+ (float)spawnedAlpha;
+ (float)spawnedScale;
+ (int)numPoolRipples;

- (id)initWithActorDef:(ActorDef *)def duration:(float)duration;
- (void)startPoolAnimation;
- (void)stopPoolAnimation;
- (void)sinkNpcShip:(NpcShip *)ship;
- (void)killOverboardActor:(OverboardActor *)actor;
- (void)despawnOverTime:(float)duration;

@end