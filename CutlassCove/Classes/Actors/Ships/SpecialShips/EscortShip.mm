//
//  EscortShip.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 22/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "EscortShip.h"
#import "PrimeShip.h"
#import "PlayerShip.h"
#import "PirateShip.h"
#import "ShipDetails.h"
#import "Cannonball.h"
#import "TargetTracer.h"
#import "Box2DUtils.h"
#import "Globals.h"


@interface EscortShip ()

@end

@implementation EscortShip

@synthesize willEnterTown = mWillEnterTown;
@synthesize fleetID = mFleetID;
@synthesize escortee = mEscortee;

- (id)initWithActorDef:(ActorDef *)def key:(NSString *)key {
    if (self = [super initWithActorDef:def key:key]) {
		mWillEnterTown = NO;
        mFleetID = 0;
	}
	return self;
}

- (void)setupShip {
	[super setupShip];
	
	mSlowedFraction = 0.5f;
	mDuelState = PursuitStateEscorting; // Don't use property in case mEscortee is not yet set
}

- (void)setEscortee:(PrimeShip *)ship {
	if (mEscortee == ship)
		return;
	[ship retain];
	
	if (mEscortee != nil) {
		[mEscortee removeEventListener:@selector(onEscorteeDestroyed:) atObject:self forType:CUST_EVENT_TYPE_ESCORTEE_DESTROYED];
		[mEscortee release];
		mEscortee = nil;
	}
	mEscortee = ship;
	[mEscortee addEventListener:@selector(onEscorteeDestroyed:) atObject:self forType:CUST_EVENT_TYPE_ESCORTEE_DESTROYED];
	
	if (ship != nil)
		[self setDuelState:PursuitStateEscorting];
}

- (void)onEscorteeDestroyed:(SPEvent *)event {
	[mEscortee autorelease];
	mEscortee = nil;
	
	if (mEnemy == nil)
		[self setDuelState:PursuitStateSailingToDock];
}

- (void)setDuelState:(PursuitState)state {
	self.isCollidable = YES;
	
	switch (state) {
		case PursuitStateSearching:
			state = PursuitStateEscorting;
			// Allow fall through
		case PursuitStateEscorting:
			if (mEscortee != nil)
				break;
			state = PursuitStateSailingToDock;
			// Allow fall through
		case PursuitStateSailingToDock:
			if (mEscortee != nil && mEscortee.docking == NO) {
				state = PursuitStateEscorting;
			} else {
				if (mDestination.seaLaneC == nil) {
					self.isCollidable = !mWillEnterTown;
					[self.destination setFinishAsDest];
				} else {
					mDestination.seaLaneC = mDestination.seaLaneC; // Make way to town entrance
				}
				mDuelState = state;
				return; // Exit early
			}
			break;
		default:
			break; 
	}
	[super setDuelState:state];
}

- (void)playerCamouflageActivated:(BOOL)value {
    if (mPursuitEnded)
        return;
    
	if (value == YES) {
		if (self.duelState != PursuitStateFerrying)
			self.duelState = PursuitStateSailingToDock;
	} else {
		if (mEnemy != nil)
			self.duelState = PursuitStateChasing;
		else if (self.duelState != PursuitStateFerrying)
			self.duelState = PursuitStateEscorting;
	}
}

- (bool)preSolve:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
	if (mRemoveMe == YES)
		return false;
	bool collidable = true;
	
	if ([other isKindOfClass:[EscortShip class]]) {
		EscortShip *ship = (EscortShip *)other;
		
		// Prevent circular referencing
		if (collidable && ship.isCollidable && self.avoiding != ship && ship.avoiding != self) {
			if (fixtureOther == ship.feeler && fixtureSelf != mFeeler) {
				ship.avoiding = self;
				ship.avoidState = kStateAvoidDecelerating;
			} else {
				self.avoiding = ship;
				self.avoidState = kStateAvoidDecelerating;
			}
		}
		assert(!(self.avoiding == ship && ship.avoiding == self));
	} else if ([other isKindOfClass:[NpcShip class]]) {
        collidable = (mIsCollidable || other == self.escortee); // Can always collide with escortee
    }
    
	return (collidable && fixtureSelf != mFeeler);
}

- (void)sailWithForce:(float32)force {
    // Slow down when entering the town so that we can enter more orderly
    if (self.destination.finishIsDest && mDestination.finish == kPlaneIdTown)
        [super sailWithForce:0.75f * force];
    else
        [super sailWithForce:force];
}

- (float)navigate {
	if (mInWhirlpoolVortex || mInDeathsHands)
		return 0.0f;
	float sailForce = 0.0f;
	
	if (self.duelState == PursuitStateEscorting) {
		if (mEscortee == nil) {
			self.duelState = PursuitStateSailingToDock;
		} else if (mDestination && mBody) {
			sailForce = mEscortee.sailForce;
			b2Vec2 bodyPos = mBody->GetPosition();
			b2Vec2 dest = [mEscortee flankPosition:self];
			mDestination.dest = dest;
			dest = bodyPos - dest;
			
            float destLenSquared = dest.LengthSquared();
            
            // 12.0f is optimal distance
            if (destLenSquared > 24.0f) sailForce *= 1.35f;
			else if (destLenSquared > 12.05f) sailForce *= 1.15f;
            else if (destLenSquared < 11.95f) sailForce = MIN(0.85 * sailForce,mEscortee.currentSailForce);
            else sailForce = MIN(sailForce,mEscortee.currentSailForce);
            
			sailForce *= mDrag;
			
			[self sailWithForce:sailForce];

			// Turn towards destination
			b2Vec2 linearVel = mBody->GetLinearVelocity();
			float angleToTarget = Box2DUtils::signedAngle(dest, linearVel);
			
			if (angleToTarget != 0.0f) {
                //float escorteeAngleFactor = MIN(1.0f, 0.5f + 0.5f * (fabsf(self.escortee.b2rotation - self.b2rotation) / (PI_HALF / 2)));
				float turnForce = ((angleToTarget > 0.0f) ? -1.0f : 1.0f) * (mTurnForceMax * (MIN(sailForce,mSailForce) / mSailForceMax));
				[self turnWithForce:turnForce];
			}
		}
	} else {
		sailForce = [super navigate];
	}
	return sailForce;
}

- (BOOL)hasBootyGoneWanting:(SPSprite *)shooter {
	return [shooter isKindOfClass:[PirateShip class]];
}

- (void)creditPlayerSinker {
	[mScene.achievementManager escortShipSunk:self];
}

- (void)safeRemove { 
	if (mRemoveMe == YES)
		return;
	[super safeRemove];
	
	SPEvent *event = [[SPEvent alloc] initWithType:CUST_EVENT_TYPE_ESCORT_DESTROYED bubbles:NO];
	[self dispatchEvent:event];
	[event release];
}

- (void)cleanup {
	[super cleanup];
	
	if (mEscortee != nil) {
		[mEscortee removeEventListener:@selector(onEscorteeDestroyed:) atObject:self forType:CUST_EVENT_TYPE_ESCORTEE_DESTROYED];
		[mEscortee release];
		mEscortee = nil;
	}
}

- (void)dealloc {
	if (mEscortee != nil)
		[self cleanup];
	
	[super dealloc];
}

@end
