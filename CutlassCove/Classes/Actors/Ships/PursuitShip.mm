//
//  NavyShip.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 14/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "PursuitShip.h"
#import "ShipDetails.h"
#import "Cannonball.h"
#import "TargetTracer.h"
#import "Box2DUtils.h"
#import "Globals.h"


#import "NavyShip.h"

@interface PursuitShip ()

@end


@implementation PursuitShip

@synthesize duelState = mDuelState;
@synthesize enemy = mEnemy;

- (id)initWithActorDef:(ActorDef *)def key:(NSString *)key {
    if (self = [super initWithActorDef:def key:key]) {
        mPursuitEnded = NO;
		//mWakePeriod = 4.0f;
		mTracer = [[TargetTracer alloc] init];
	}
	return self;
}

- (void)setupShip {
	//if (mWakeCount == -1)
	//	mWakeCount = (int)(mShipDetails.speedRating * mAiModifier * 3) + 2;
	[super setupShip];
	self.duelState = PursuitStateFerrying;
}

- (void)setEnemy:(ShipActor *)enemy {
	if (mEnemy == enemy)
		return;
	[enemy retain];
	
	if (mEnemy != nil) {
		mTracer.target = nil;
        [mEnemy removePursuer:self];
		[mEnemy release]; mEnemy = nil;
	}
	
	if (enemy != nil) {
		mTracer.target = enemy;
		mEnemy = enemy; // Retained above for safety (if mEnemy is released and it then releases enemy somewhere, we could have a stray pointer)
        [mEnemy addPursuer:self];
	}
}

- (void)pursueeDestroyed:(ShipActor *)pursuee {
    assert(pursuee == self.enemy);
    self.enemy = nil;
    
    if (self.duelState != PursuitStateSailingToDock)
        self.duelState = PursuitStateSearching;
}

- (void)setDuelState:(PursuitState)state {
	PursuitState oldState = mDuelState;
	mDuelState = state;
	
	switch (state) {
		case PursuitStateIdle:
			break;
		case PursuitStateFerrying:
			break;
		case PursuitStateOutOfBounds:
			[self requestNewDestination];
			break;
		case PursuitStateChasing:
			break;
		case PursuitStateAiming:
			break;
		case PursuitStateStrafing:
			[self requestNewDestination];
			break;
		case PursuitStateSearching:
			if (oldState == PursuitStateSailingToDock)
				[self requestNewDestination];
			break;
		case PursuitStateEscorting:
			break;
		case PursuitStateSailingToDock:
			[self.destination setFinishAsDest];
			break;
		case PursuitStateSinking:
			break;
		default:
			assert(0);
			break;
	}
}

- (void)dock {
    self.enemy = nil;
    [super dock];
}

- (void)sink {
    self.enemy = nil;
    [super sink];
}

- (void)didReachDestination {
	if (mDuelState == PursuitStateSailingToDock || mDuelState == PursuitStateSearching || mDuelState == PursuitStateStrafing)
		[super didReachDestination];
	else if (mDuelState != PursuitStateChasing && mDuelState != PursuitStateAiming && mDuelState != PursuitStateSinking)
		self.duelState = PursuitStateSearching;
}

- (void)requestNewEnemy {
    [mScene requestTargetForPursuer:(NSObject *)self];
}

- (void)playerCamouflageActivated:(BOOL)value { }

- (void)endPursuit {
    if (mPursuitEnded)
        return;
    mPursuitEnded = YES;
    self.duelState = PursuitStateSailingToDock;
}

- (void)negotiateTarget:(ShipActor *)target {
	if (mInWhirlpoolVortex == YES || target == nil || mBody == 0)
		return;
	b2Vec2 bodyPos = mBody->GetPosition();
	b2Vec2 enemyPos = target.body->GetPosition();
	b2Vec2 dest = bodyPos - enemyPos;
	
	b2Vec2 linearVel = mBody->GetLinearVelocity();
	float angleToTarget = Box2DUtils::signedAngle(dest, linearVel);
	
	int angleInDegrees = (int)SP_R2D(angleToTarget);
	
	if (abs(angleInDegrees) > 87 && abs(angleInDegrees) < 93) {
		Cannonball *cannonball = [self fireCannon:((angleInDegrees > 0) ? PortSide : StarboardSide) trajectory:1.0f];
		[cannonball calculateTrajectoryFromTargetX:target.x targetY:target.y];
		cannonball.body->SetLinearVelocity(cannonball.body->GetLinearVelocity() + mTracer.targetVel);
		self.duelState = PursuitStateStrafing;
	}
}

- (BOOL)isNavigationDisabled {
	return (mInWhirlpoolVortex || mInDeathsHands || mBody == 0);
}

- (float)navigate {
	if ([self isNavigationDisabled])
		return 0;

	float sailForce = mDrag * mSailForce;
	
	// TODO: when an escort ship is attacking the player and another Silver Train is hit by this escort's cannonball, body can be zero...
	if (mEnemy != nil && mEnemy.body == 0) {
		self.enemy = nil;
		self.duelState = PursuitStateSearching;
		return [super navigate];
	}
	
	if (mReloading == NO && mDuelState != PursuitStateFerrying && mDuelState != PursuitStateDeparting && mDuelState != PursuitStateSailingToDock)
		[self negotiateTarget:mEnemy]; // We want to shoot if we're strafing and our target passes into our shooting window
	
	switch (mDuelState) {
		case PursuitStateIdle:
			sailForce /= 3.0f;
			[self sailWithForce:sailForce];
			break;
		case PursuitStateFerrying:
			sailForce = [super navigate];
			break;
		case PursuitStateOutOfBounds:
			sailForce = [super navigate];
			break;
		case PursuitStateChasing:
		{
			if (mEnemy == nil) {
				self.duelState = PursuitStateSearching;
			} else {
				b2Vec2 enemyPos = mEnemy.body->GetPosition();
				mDestination.dest = enemyPos;
				b2Vec2 dist = enemyPos - mBody->GetPosition();
			
				if (fabsf(dist.x) + fabsf(dist.y) < 25.0f && mReloading == NO) // In meters
					self.duelState = PursuitStateAiming;
			}
			sailForce = [super navigate];
			break;
		}
		case PursuitStateAiming:
		{
			if (mEnemy == nil) {
				self.duelState = PursuitStateSearching;
			} else {
				[self sailWithForce:sailForce];
				
				b2Vec2 bodyPos = mBody->GetPosition();
				b2Vec2 enemyPos = mEnemy.body->GetPosition();
				b2Vec2 dest = enemyPos - bodyPos;
				
				b2Vec2 linearVel = mBody->GetLinearVelocity();
				float angleToTarget = Box2DUtils::signedAngle(dest, linearVel);
				
				int angleInDegrees = (int)SP_R2D(angleToTarget);
				
				if ((angleInDegrees > -89 && angleInDegrees < 89) || angleInDegrees > 91 || angleInDegrees < -91) {
					float turnForce = 0.0f;
					
					if (angleInDegrees >= 0)
						turnForce = ((angleInDegrees < 90) ? -1.0f : 1.0f) * (mTurnForceMax * (sailForce / mSailForceMax));
					else
						turnForce = ((angleInDegrees < -90) ? -1.0f : 1.0f) * (mTurnForceMax * (sailForce / mSailForceMax));
					[self turnWithForce: turnForce];
				} else if (fabsf(dest.x) + fabsf(dest.y) > 35.0f) { // In meters
					self.duelState = PursuitStateChasing;
				}
			}
			break;
		}
		case PursuitStateStrafing:
		{
			if (mEnemy == nil) {
				self.duelState = PursuitStateSearching;
				[self sailWithForce:sailForce];
			} else if (mReloading == NO) {
				b2Vec2 bodyPos = mBody->GetPosition();
				b2Vec2 dest = mEnemy.body->GetPosition() - bodyPos;
					
				if ((fabsf(dest.x) + fabsf(dest.y)) > 30.0f) // In meters
					self.duelState = PursuitStateChasing;
				else
					self.duelState = PursuitStateAiming;
				[self sailWithForce:sailForce];
			} else {
				sailForce = [super navigate];
			}
			break;
		}
		case PursuitStateSearching:
			sailForce = [super navigate];
			break;
		case PursuitStateEscorting:
			sailForce = [super navigate];
			break;
		case PursuitStateSailingToDock:
			sailForce = [super navigate];
			break;
		case PursuitStateSinking:
		default:
			sailForce = 0.0f;
			break;
	}
	return sailForce;
}

- (void)advanceTime:(double)time {
	[super advanceTime:time];
	
	switch (mDuelState) {
		case PursuitStateSearching:
            if (mReloading == NO) {
                if (mEnemy == nil)
                    [self requestNewEnemy];
                else
                    self.duelState = PursuitStateChasing;
            }
			break;
		default:
			break;
	}
	
	if (mRemoveMe || mDocking)
		return;
	[mTracer advanceTime:time];
}

- (bool)preSolve:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
    if (mDocking || mRemoveMe)
		return false;
    
    bool collidable = true;
    
    if ([other isKindOfClass:[PursuitShip class]]) {
        PursuitShip *ship = (PursuitShip *)other;
        
        collidable = mIsCollidable;
        
        if (self.avoiding == nil && ship.avoiding == self && fixtureSelf == mFeeler && fixtureOther != ship.feeler) {
            // Switch avoidance roles
            self.avoiding = ship;
            self.avoidState = kStateAvoidDecelerating;
            ship.avoiding = nil;
        }
    }
    
    return (collidable && fixtureSelf != mFeeler);
}

// Must be cleaned up by owner
- (void)cleanup {
	[super cleanup];
	
	if (mEnemy != nil) {
		mTracer.target = nil;
        [mEnemy removePursuer:self];
		[mEnemy release]; mEnemy = nil;
	}
}

- (void)dealloc {
    mTracer.target = nil;
	[mTracer release]; mTracer = nil;
    [mEnemy release]; mEnemy = nil; // Can't be in here if enemy still has us as a pursuer
	[super dealloc];
}

@end
