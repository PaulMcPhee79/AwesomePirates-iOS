/*
 *  RayCastClosest.h
 *  PiratesOfCutlassCove
 *
 *  Created by Paul McPhee on 4/11/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef RAY_CAST_CLOSEST_H
#define RAY_CAST_CLOSEST_H

#import <Box2D/Box2D.h>
#import "Actor.h"
#import "NpcShip.h"
#import "MerchantShip.h"
#import "BrandySlickActor.h"

class RayCastClosest : public b2RayCastCallback {
	
public:
	RayCastClosest(b2Body *owner) {
		mOwner = owner;
		mFixture = 0;
        mGlancingFixture = 0;
	}
	
	void ResetFixture() {
		mFixture = 0;
        mGlancingFixture = 0;
	}
	
	float32 ReportFixture(b2Fixture *fixture, const b2Vec2 &point, const b2Vec2 &normal, float32 fraction) {
		float32 rayControl = -1;
		b2Body *body = fixture->GetBody();
		
		if (body && body != mOwner) {
			BOOL shouldProcessRay = NO;
			Actor *actor = (Actor *)(body->GetUserData());
			
			if ([actor isKindOfClass:[NpcShip class]]) {
				NpcShip *ship = (NpcShip *)actor;
				
				if (ship.inWhirlpoolVortex == NO && fixture != ship.feeler && ship.markedForRemoval == NO && ship.docking == NO) {
                    // Don't process hitbox collisions if we're too close to the other ship
                    if (fixture != ship.hitBox || fraction > 0.075f) {
                        shouldProcessRay = YES;
                        
//                        if ([ship isKindOfClass:[MerchantShip class]]) {
//                            MerchantShip *merchantShip = (MerchantShip *)ship;
//                            shouldProcessRay = (fixture != merchantShip.defender);
//                        }
                    } else if (mGlancingFixture == nil)
                        mGlancingFixture = fixture;
				}
			} else if ([actor isKindOfClass:[BrandySlickActor class]]) {
				BrandySlickActor *brandySlick = (BrandySlickActor *)actor;
				shouldProcessRay = (brandySlick.ignited == NO);
			}
			
			if (shouldProcessRay) {
				mFixture = fixture;
				mPoint = point;
				mNormal = normal;
				mFraction = fraction;
				rayControl = fraction;
			}
		}
		return rayControl;
	}
	
	b2Body *mOwner;
	b2Fixture *mFixture;
    b2Fixture *mGlancingFixture; // Better to hit close ones if nothing else gets hit.
	b2Vec2 mPoint;
	b2Vec2 mNormal;
	float32 mFraction;
};

#endif
