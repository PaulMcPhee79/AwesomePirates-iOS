//
//  WhirlpoolActor.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 16/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Actor.h"

#define CUST_EVENT_TYPE_WHIRLPOOL_DESPAWNED @"whirlpoolDespawnedEvent"

@interface WhirlpoolActor : Actor {
	int mState;
    uint mRoyalFlushes;
    float mSwirlFactor;
    float mSuckFactor;
	double mDuration;
	
    float32 mRadius;
	SPImage *mWater;
	SPSprite *mCostume;
	
	b2Fixture *mPool;
	b2Fixture *mEye;
	NSMutableSet *mVictims;
}

@property (nonatomic,assign) float swirlFactor;
@property (nonatomic,assign) float suckFactor;


+ (float)spawnDuration;
+ (WhirlpoolActor *)whirlpoolActorAtX:(float)x y:(float)y rotation:(float)rotation duration:(float)duration;
- (id)initWithActorDef:(ActorDef *)def duration:(float)duration;
- (void)despawnOverTime:(float)duration;
- (void)setWaterColor:(uint)color;

@end
