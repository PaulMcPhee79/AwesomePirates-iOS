//
//  BrandySlickActor.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 14/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Actor.h"
#import "Ignitable.h"

#define CUST_EVENT_TYPE_BRANDY_SLICK_DESPAWNED @"brandySlickDespawnedEvent"

@class WaterFire;
@class VertexAnimator;

@interface BrandySlickActor : Actor <Ignitable> {
	int mState;
	float mBrandyScale;
	double mDuration;
	uint mPrisonersFried;
    
    BOOL mZombieSlick;
    double mZombieCounter;
    
	VertexAnimator *mVAnim;
	SPSprite *mSlick;
	WaterFire *mFire;
}

@property (nonatomic,readonly) BOOL despawning;

+ (BrandySlickActor *)brandySlickActorAtX:(float)x y:(float)y rotation:(float)rotation scale:(float)scale duration:(float)duration;
- (id)initWithActorDef:(ActorDef *)def scale:(float)scale duration:(float)duration;
- (void)despawnOverTime:(float)duration;

@end
