//
//  NetActor.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 14/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Actor.h"
#import "Ignitable.h"

#define CUST_EVENT_TYPE_NET_DESPAWNED @"netDespawnedEvent"

@class WaterFire;
@class VertexAnimator;

@interface NetActor : Actor <Ignitable> {
	BOOL mDespawning;
	BOOL mIgnited;
    
    BOOL mZombieNet;
    double mZombieCounter;
    
	float mNetScale;
	float mSpawnScale;
    double mDuration;
	
	BOOL mHasShrunk;
	BOOL mShrinking;
	float mCollidableRadiusFactor;
	float mCollidableRadius;
	b2Fixture *mCenterFixture;
	b2Fixture *mAreaFixture;
	
    VertexAnimator *mVAnim;
	SPSprite *mCostume;
}

@property (nonatomic,readonly) BOOL despawning;
@property (nonatomic,readonly) float netScale;
@property (nonatomic,assign) float spawnScale;
@property (nonatomic,assign) float collidableRadiusFactor;
@property (nonatomic,readonly) b2Fixture *centerFixture;
@property (nonatomic,readonly) b2Fixture *areaFixture;

+ (NetActor *)netActorAtX:(float)x y:(float)y rotation:(float)rotation scale:(float)scale duration:(float)duration;
- (id)initWithActorDef:(ActorDef *)def scale:(float)scale duration:(float)duration;
- (void)despawnOverTime:(float)duration;
- (void)beginShrinking;
- (void)stopShrinking;

@end
