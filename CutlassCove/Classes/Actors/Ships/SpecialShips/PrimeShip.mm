//
//  PrimeShip.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 23/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "PrimeShip.h"
#import "EscortShip.h"
#import "PlayerShip.h"
#import "PirateShip.h"
#import "Cannonball.h"
#import "Box2DUtils.h"
#import "GameController.h"

@interface PrimeShip ()

@property (nonatomic,readonly) int flankIndex;

- (void)setupTrail;
-(void)setupEscort:(EscortShip *)ship asFlank:(EscortShip **)flank;
- (b2Vec2)calcFlankPosForAngle:(float)angle;
- (void)onEscortDestroyed:(SPEvent *)event;

@end

@implementation PrimeShip

@synthesize fleetID = mFleetID;
@synthesize leftEscort = mLeftEscort;
@synthesize rightEscort = mRightEscort;
@synthesize currentSailForce = mCurrentSailForce;
@dynamic flankIndex;

- (id)initWithActorDef:(ActorDef *)def key:(NSString *)key {
    if (self = [super initWithActorDef:def key:key]) {
        mLaunching = YES;
        mFleetID = 0;
        mCurrentSailForce = 0;
        mTrailIndex = -1;
        mTrailInit = 0;
        mTrailIndexCount = GCTRL.fps / 2;
	}
	return self;
}

- (void)setupShip {
	[super setupShip];
	//mTurnModifier = 2.0f; // Allows this ship to overpower another npc ship in a turn-war.
}

- (int)flankIndex {
    return (mTrailIndex + 1) % mTrailIndexCount;
}

- (void)setFleetID:(uint)fleetID {
    mFleetID = fleetID;
    mLeftEscort.fleetID = fleetID;
    mRightEscort.fleetID = fleetID;
}

- (void)setLeftEscort:(EscortShip *)ship {
	[self setupEscort:ship asFlank:&mLeftEscort];
}

- (void)setRightEscort:(EscortShip *)ship {
	[self setupEscort:ship asFlank:&mRightEscort];
}

- (void)setupTrail {
    mTrailIndex = mTrailIndexCount-1;
}

-(void)setupEscort:(EscortShip *)ship asFlank:(EscortShip **)flank {
	if (*flank == ship)
		return;
	[ship retain];
	
	if (*flank != nil) {
		[*flank removeEventListener:@selector(onEscortDestroyed:) atObject:self forType:CUST_EVENT_TYPE_ESCORT_DESTROYED];
		[*flank release];
	}
	*flank = ship;
	[*flank addEventListener:@selector(onEscortDestroyed:) atObject:self forType:CUST_EVENT_TYPE_ESCORT_DESTROYED];
}

- (bool)preSolve:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
	return fixtureSelf != mFeeler;
}

- (void)onEscortDestroyed:(SPEvent *)event {
	EscortShip *ship = (EscortShip *)event.currentTarget;
	
	if (ship == mLeftEscort) {
		[mLeftEscort release];
		mLeftEscort = nil;
	} else if (ship == mRightEscort) {
		[mRightEscort release];
		mRightEscort = nil;
	}
}

- (b2Vec2)flankPosition:(EscortShip *)ship {
    b2Vec2 flankPos;
    
    if (mTrailInit < mTrailIndexCount) {
        flankPos = [self calcFlankPosForAngle:((ship == mLeftEscort) ? -PI_HALF : PI_HALF)];
    } else {
        flankPos = (ship == mLeftEscort) ? mTrailLeft[self.flankIndex] : mTrailRight[self.flankIndex];
    }
    
    return flankPos;
}

- (b2Vec2)calcFlankPosForAngle:(float)angle {
    if (mBody == 0)
        return b2Vec2();
    
    b2Vec2 primePos = mBody->GetPosition();
    b2Vec2 sternCenter = mStern->GetAABB(0).GetCenter();
    b2Vec2 bowCenter = mBow->GetAABB(0).GetCenter();
    
    b2Vec2 flankPos = sternCenter - bowCenter;
    flankPos *= 0.75f;
    Box2DUtils::rotateVector(flankPos, angle);
    flankPos = primePos + flankPos;
    return flankPos;
}

- (float)navigate {
    if (mTrailIndex == -1)
        [self setupTrail];
    
    // Drag when first launched so that escort ships can more easily match our speed
    if (mLaunching && mBody) {
		b2Vec2 bodyPos = mBody->GetPosition();
		b2Vec2 spawnPoint = mDestination.loc;
		b2Vec2 dist = bodyPos - spawnPoint;
        
		if (dist.LengthSquared() < (P2M(16) * P2M(16))) {
			mSailForce = MIN(mSailForce, 0.5f * mSailForceMax);
        } else {
            if (self.avoidState == kStateAvoidNull)
                mSailForce = mSailForceMax;
            mLaunching = NO;
        }
	}
    
    mCurrentSailForce = [super navigate];
    
    if (mBody) {
        if (self.leftEscort)
            mTrailLeft[mTrailIndex] = [self calcFlankPosForAngle:-PI_HALF];
        
        if (self.rightEscort)
            mTrailRight[mTrailIndex] = [self calcFlankPosForAngle:PI_HALF]; 

        if (mTrailInit < mTrailIndexCount)
            ++mTrailInit;
        
        ++mTrailIndex;
        
        if (mTrailIndex >= mTrailIndexCount)
            mTrailIndex = 0;
    }
    
    return mCurrentSailForce;
}

- (void)damageShipWithCannonball:(Cannonball *)cannonball {
	if (self.isCollidable == YES && [cannonball.shooter isKindOfClass:[ShipActor class]]) {
		if ([cannonball.shooter isKindOfClass:[PlayerShip class]]) {
			PlayerShip *playerShip = (PlayerShip *)cannonball.shooter;
			
			if (playerShip.isCamouflaged) {
				[super damageShipWithCannonball:cannonball];
				return;
			}
		}
		
		if (mLeftEscort != nil) {
			mLeftEscort.enemy = (ShipActor *)cannonball.shooter;
			mLeftEscort.duelState = PursuitStateChasing;
		}
		if (mRightEscort != nil) {
			mRightEscort.enemy = (ShipActor *)cannonball.shooter;
			mRightEscort.duelState = PursuitStateChasing;
		}
	}
	[super damageShipWithCannonball:cannonball];
}

- (BOOL)hasBootyGoneWanting:(SPSprite *)shooter {
	return [shooter isKindOfClass:[PirateShip class]];
}

- (void)safeRemove { 
	if (mRemoveMe == YES)
		return;
	[super safeRemove];
	
	SPEvent *event = [[SPEvent alloc] initWithType:CUST_EVENT_TYPE_ESCORTEE_DESTROYED bubbles:NO];
	[self dispatchEvent:event];
	[event release];
}

- (void)cleanup {
	[super cleanup];
	
	if (mLeftEscort != nil) {
		[mLeftEscort removeEventListener:@selector(onEscortDestroyed:) atObject:self forType:CUST_EVENT_TYPE_ESCORT_DESTROYED];
		[mLeftEscort release];
		mLeftEscort = nil;
	}
	
	if (mRightEscort != nil) {
		[mRightEscort removeEventListener:@selector(onEscortDestroyed:) atObject:self forType:CUST_EVENT_TYPE_ESCORT_DESTROYED];
		[mRightEscort release];
		mRightEscort = nil;
	}
}

- (void)dealloc {
	if (mLeftEscort != nil || mRightEscort != nil)
		[self cleanup];

	[super dealloc];
}

@end
