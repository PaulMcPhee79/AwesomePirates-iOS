//
//  NpcShip.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 9/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "NpcShip.h"
#import "NpcShipCache.h"
#import "PursuitShip.h"
#import "EscortShip.h"
#import "PrimeShip.h"
#import "ShipDetails.h"
#import "Wake.h"
#import "Cannonball.h"
#import "AcidPoolActor.h"
#import "MagmaPoolActor.h"
#import "PlayerDetails.h"
#import "CannonDetails.h"
#import "PlayerShip.h"
#import "TownCannon.h"
#import "AbyssalBlastProp.h"
#import "ShipFactory.h"
#import "Box2DUtils.h"
#import "GameController.h"
#import "Globals.h"

const double kDefaultReloadDelay = 4.0;

const int kStateAvoidNull = 0x0;
const int kStateAvoidDecelerating = 0x1;
const int kStateAvoidSlowed = 0x2;
const int kStateAvoidAccelerating = 0x3;

@interface NpcShip ()

- (void)dockOverTime:(float)duration;
- (void)burn;
- (void)proceedToSink;
- (void)avoidCollisions;
- (void)reload;
- (BOOL)isOutOfBounds;
- (void)burnOut;
- (void)onBurningHalfComplete:(SPEvent *)event;
- (void)sinkingComplete;
- (void)dockingComplete;
- (void)onDockingComplete:(SPEvent *)event;

@end


@implementation NpcShip

@synthesize isCollidable = mIsCollidable;
@synthesize inWhirlpoolVortex = mInWhirlpoolVortex;
@synthesize inDeathsHands = mInDeathsHands;
@synthesize inFuture = mInFuture;
@synthesize aiModifier = mAiModifier;
@synthesize destination = mDestination;
@synthesize feeler = mFeeler;
@synthesize hitBox = mHitBox;
@synthesize avoidState = mAvoidState;
@synthesize avoiding = mAvoiding;
@synthesize docking = mDocking;

- (id)initWithActorDef:(ActorDef *)def key:(NSString *)key {
    if (self = [super initWithActorDef:def key:key]) {
		mIsCollidable = YES;
		mHasLeftPort = NO;
		mDocking = NO;
		mReloading = NO;
		mInWhirlpoolVortex = NO;
		mInDeathsHands = NO;
		mBootyGoneWanting = YES;
		mInFuture = NO;
		mGoods = NO;
		mAiModifier = 1;
		mWhirlpoolOverboardDelay = 2.0;
		mReloadInterval = kDefaultReloadDelay;
        mReloadTimer = 0.0;
        mSinkingTimer = 0.0;
		mDestination = nil;
		mAvoidState = kStateAvoidNull;
		mAvoidAccel = 0.0f;
		mSlowedFraction = 0.25f;
		//mWakePeriod = 5.0f;
		mAngVelUpright = 0.4f;
		mAvoiding = nil;
        mResources = nil;
		[self checkoutPooledResources];
    }
    return self;
}

- (void)setupShip {
	//if (mWakeCount == -1)
	//	mWakeCount = (int)MIN([Wake maxWakeBufferSize],mShipDetails.speedRating * mAiModifier);
	[super setupShip];
	[self recalculateForces];
	mWake.ripplePeriod = MIN([Wake maxRipplePeriod], [Wake defaultRipplePeriod] * MAX([Wake minRipplePeriod], [ShipActor defaultSailForceMax] / MAX(1, mSailForceMax)));
	mReloadInterval = (double)mShipDetails.reloadInterval;
	
	NSString *textureName = nil;
	
	if (mInFuture == YES && mShipDetails.textureFutureName != nil) {
		textureName = mShipDetails.textureFutureName;
        [mCostumeImages autorelease];
        mCostumeImages = nil;
	} else {
		textureName = mShipDetails.textureName;
    }
	
	mCostume = [[SPSprite alloc] init];
    
    if (mWardrobe == nil)
        mWardrobe = [[SPSprite alloc] init];
    mWardrobe.alpha = 1;
    mWardrobe.scaleX = mWardrobe.scaleY = 1;
	[mWardrobe addChild:mCostume];
    [self addChild:mWardrobe];
	
	if (mCostumeImages == nil)
		mCostumeImages = [[self setupCostumeForTexturesStartingWith:textureName cacheGroup:TM_CACHE_PF_SHIPS] retain];
	[self enqueueCostumeImages:mCostumeImages];
}

- (void)negotiateTarget:(ShipActor *)target { }

- (void)saveFixture:(b2Fixture *)fixture atIndex:(int)index {
	switch (index) {
		case 5: mFeeler = fixture; break;
        case 6: mHitBox = fixture; break;
		default: break;
	}
	[super saveFixture:fixture atIndex:index];
}

- (void)recalculateForces {
	if (mBody == 0)
		return;
    float sailForceTweak = 1.45f, turnForceTweak = 1.1f;
    float speedRatingMax = kSpeedRatingMax; // ([RESM isHighPerformance]) ? kSpeedRatingMax : 1.2f * kSpeedRatingMax;
    float controlRatingMax = kControlRatingMax; // ([RESM isHighPerformance]) ? kControlRatingMax : 1.1f * kControlRatingMax;
	mSailForceMax = mSpeedModifier * sailForceTweak * 2.0f * mBody->GetMass() * MIN(speedRatingMax, mShipDetails.speedRating * mAiModifier);
	mSailForce = mSailForceMax;
	mTurnForceMax = mControlModifier * turnForceTweak * mBody->GetMass() * MIN(controlRatingMax, mShipDetails.controlRating * mAiModifier) * PI_HALF / 2.0f / 3.0f;
    mTurnForceMax *= 1.35f; // 1.35f because ships are 50% larger since v2.0
}

- (int)infamyBonus {
	return mShipDetails.infamyBonus;
}

- (void)setAiModifier:(float)modifier {
	mAiModifier = modifier;
	[self recalculateForces];
}

- (void)setAvoidState:(int)state {
	switch (state) {
		case kStateAvoidNull:
			self.avoiding = nil;
			mSailForce = mSailForceMax;
			mAvoidAccel = 0.0f;
			break;
		case kStateAvoidDecelerating:
			mAvoidAccel = -mSailForceMax / 100.0f;
			break;
		case kStateAvoidSlowed:
			mSailForce = 0.25f * mSailForceMax;
			mAvoidAccel = 0.0f;
			break;
		case kStateAvoidAccelerating:
			mSailForce = 0.25f * mSailForceMax;
			mAvoidAccel = mSailForceMax / 200.0f;
			break;
	}
	
	mAvoidState = state;
}

- (void)setInWhirlpoolVortex:(BOOL)inWhirlpoolVortex {
    if (inWhirlpoolVortex == YES)
        self.avoidState = kStateAvoidNull;
    mInWhirlpoolVortex = inWhirlpoolVortex;
}

- (void)setInDeathsHands:(BOOL)value {
	if (value == YES && mInDeathsHands == NO && mBody) {
		mBody->SetLinearVelocity(b2Vec2(0,0));
		mBody->SetAngularVelocity(0);
	}
    
    self.avoidState = kStateAvoidNull;
	mInDeathsHands = value;
}

- (void)avoidCollisions {
	mSailForce += mAvoidAccel;
	
	if (mAvoidState == kStateAvoidNull)
		return;
    else if (self.avoiding == nil && mAvoidState != kStateAvoidAccelerating)
        self.avoidState = kStateAvoidAccelerating;
	else if (mAvoidState == kStateAvoidDecelerating && (mSailForce <= mSlowedFraction * mSailForceMax))
		self.avoidState = kStateAvoidSlowed;		
	else if (mAvoidState == kStateAvoidAccelerating && mSailForce >= mSailForceMax)
		self.avoidState = kStateAvoidNull;
}

- (bool)preSolve:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
    if (mDocking || mRemoveMe || self.isPreparingForNewGame)
		return false;
    
    return mIsCollidable;
    
//    bool collidable = true;
//    
//    if ([other isKindOfClass:[NpcShip class]]) {
//        NpcShip *ship = (NpcShip *)other;
//        
//        collidable = mIsCollidable;
//        
//        if (self.avoiding == nil && ship.avoiding == self && fixtureSelf == mFeeler && fixtureOther != ship.feeler) {
//            // Switch avoidance roles
//            self.avoiding = ship;
//            self.avoidState = kStateAvoidDecelerating;
//            ship.avoiding = nil;
//        }
//    }
//    
//    return (collidable && fixtureSelf != mFeeler);
}


//- (bool)preSolve:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
//	if (mDocking || mRemoveMe)
//		return false;
//    
//	bool collidable = true;
//	
//	if ([other isKindOfClass:[NpcShip class]]) {
//		collidable = mIsCollidable;
//		NpcShip *ship = (NpcShip *)other;
//        
//        //if (fixtureSelf == mFeeler || fixtureOther == ship.feeler)
//        //    NSLog(@"ONE FEELER");
//        if (fixtureSelf == mFeeler && fixtureOther == ship.feeler)
//            NSLog(@"TWO FEELERS");
//
//		if ((self.avoiding == nil || ship.avoiding == nil) && mInWhirlpoolVortex == NO && mInDeathsHands == NO && collidable && ship.isCollidable) {
//            // Prevent circular referencing
//            if (self.avoiding != ship && ship.avoiding != self) {
//                if ([self isKindOfClass:[PursuitShip class]]) {
//                    if ([ship isKindOfClass:[PursuitShip class]]) {
//                        if (fixtureOther == ship.feeler && fixtureSelf != mFeeler) {
//                            ship.avoiding = self;
//                            ship.avoidState = kStateAvoidDecelerating;
//                        } else {
//                            self.avoiding = ship;
//                            self.avoidState = kStateAvoidDecelerating;
//                        }
//                    }
//                } else {
//                    if ([ship isKindOfClass:[PursuitShip class]]) {
//                        if (fixtureSelf == mFeeler) {
//                            self.avoiding = ship;
//                            self.avoidState = kStateAvoidDecelerating;
//                        }
//                    } else if (fixtureOther != ship.feeler && fixtureSelf == mFeeler) {
//                        self.avoiding = ship;
//                        self.avoidState = kStateAvoidDecelerating;
//                    } else if (fixtureOther == ship.feeler && fixtureSelf != mFeeler) {
//                        ship.avoiding = self;
//                        ship.avoidState = kStateAvoidDecelerating;
//                    } else if (ship.avoidState != kStateAvoidNull) {
//                        ship.avoiding = self;
//                        ship.avoidState = kStateAvoidDecelerating;
//                    } else if (self.avoidState != kStateAvoidNull) {
//                        self.avoiding = ship;
//                        self.avoidState = kStateAvoidDecelerating;
//                    } else {
//                        b2Manifold *manifold = contact->GetManifold();
//                        b2WorldManifold worldManifold;
//                        contact->GetWorldManifold(&worldManifold);
//                        
//                        if (mBody && manifold && manifold->pointCount > 0) {
//                            b2Vec2 collisionPoint = worldManifold.points[0];
//                            b2Vec2 selfVector = collisionPoint - mBody->GetPosition();
//                            b2Vec2 otherVector = collisionPoint - ship.body->GetPosition();
//                            
//                            if (selfVector.LengthSquared() > otherVector.LengthSquared()) {
//                                self.avoiding = ship;
//                                self.avoidState = kStateAvoidDecelerating;
//                            } else {
//                                ship.avoiding = self;
//                                ship.avoidState = kStateAvoidDecelerating;
//                            }
//                        }
//                    }
//                }
//            }
//		}
//		assert(!(self.avoiding == ship && ship.avoiding == self));
//	}
//    
//    // Don't wont to collide with the feeler - just want to use it as 
//	return (collidable && fixtureSelf != mFeeler);
//}


- (void)beginContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
    if ([other isKindOfClass:[NpcShip class]]) {
        NpcShip *ship = (NpcShip *)other;
        
        do {
            if ((self.avoiding == nil || ship.avoiding == nil) && mInWhirlpoolVortex == NO && mInDeathsHands == NO && mIsCollidable && ship.isCollidable) {
                if (self.avoiding != ship && ship.avoiding != self) {
                    if ([self isKindOfClass:[PursuitShip class]]) {
                        if ([self isKindOfClass:[EscortShip class]]) {
                            EscortShip *escortShip = (EscortShip *)self;
                            
                            if (escortShip.escortee)
                                break;
                        }
                        
                        if ([ship isKindOfClass:[PursuitShip class]]) {
                            if ([ship isKindOfClass:[EscortShip class]]) {
                                EscortShip *escortShip = (EscortShip *)ship;
                                
                                if (escortShip.escortee) {
                                    if (fixtureSelf == mFeeler && escortShip.escortee.avoiding != self) {
                                        self.avoiding = ship;
                                        self.avoidState = kStateAvoidDecelerating;
                                    }
                                    break;
                                }
                            }
                            
                            if (fixtureOther == ship.feeler && fixtureSelf != mFeeler) {
                                ship.avoiding = self;
                                ship.avoidState = kStateAvoidDecelerating;
                            } else {
                                self.avoiding = ship;
                                self.avoidState = kStateAvoidDecelerating;
                            }
                        }
                    } else {
                        if ([self isKindOfClass:[PrimeShip class]]) {
                            PrimeShip *primeShip = (PrimeShip *)self;
                            
                            if (ship == primeShip.leftEscort || ship == primeShip.rightEscort || ship.avoiding == primeShip.leftEscort || ship.avoiding == primeShip.rightEscort)
                                break;
                        }
                        
                        if ([ship isKindOfClass:[PursuitShip class]]) {
                            if (fixtureSelf == mFeeler) {
                                if ([ship isKindOfClass:[EscortShip class]]) {
                                    EscortShip *escortShip = (EscortShip *)ship;
                                    
                                    if (escortShip.escortee == nil || escortShip.escortee.avoiding != self) {
                                        self.avoiding = ship;
                                        self.avoidState = kStateAvoidDecelerating;
                                    }
                                } else {
                                    self.avoiding = ship;
                                    self.avoidState = kStateAvoidDecelerating;
                                }
                            }
                        } else if (fixtureOther != ship.feeler && fixtureSelf == mFeeler) {
                            self.avoiding = ship;
                            self.avoidState = kStateAvoidDecelerating;
                        } else if (fixtureOther == ship.feeler && fixtureSelf != mFeeler) {
                            ship.avoiding = self;
                            ship.avoidState = kStateAvoidDecelerating;
                        } else if (ship.avoidState != kStateAvoidNull) {
                            ship.avoiding = self;
                            ship.avoidState = kStateAvoidDecelerating;
                        } else if (self.avoidState != kStateAvoidNull) {
                            self.avoiding = ship;
                            self.avoidState = kStateAvoidDecelerating;
                        } else {
                            self.avoiding = ship;
                            self.avoidState = kStateAvoidDecelerating;
                        }
                    }
                }
                else if (fixtureSelf == mFeeler && fixtureOther != ship.feeler && self.avoiding == nil && ship.avoiding == self
                         && (([self isKindOfClass:[PursuitShip class]] == NO && [self isKindOfClass:[PrimeShip class]] == NO)
                             || ([self isKindOfClass:[PursuitShip class]] && [self isKindOfClass:[PursuitShip class]]))) {
                             
                             if (ship.docking == NO && ship.markedForRemoval == NO && ship.isPreparingForNewGame == NO) {
                                 // Switch avoidance roles
                                 self.avoiding = ship;
                                 self.avoidState = kStateAvoidDecelerating;
                                 ship.avoiding = nil;
                             }
                }
            }
        } while (NO);
    }

    [super beginContact:other fixtureSelf:fixtureSelf fixtureOther:fixtureOther contact:contact];
}

- (void)endContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
    [super endContact:other fixtureSelf:fixtureSelf fixtureOther:fixtureOther contact:contact];
    
	if (mRemovedContact) {
        if ([other isKindOfClass:[NpcShip class]]) {
            NpcShip *ship = (NpcShip *)other;
            if (ship == self.avoiding)
                self.avoiding = nil;
            if (self == ship.avoiding)
                ship.avoiding = nil;
        }
    }
}

- (void)dock {
	[self dockOverTime:0.5f];
}

- (void)dockOverTime:(float)duration {
    if (mDocking)
		return;
    [self removeAllPursuers];
	mDocking = YES;
	mIsCollidable = NO;
	//mLantern.visible = NO;
	
	if (mBootyGoneWanting == YES && mScene.raceEnabled == NO)
		[GCTRL.thisTurn addMutiny:1];
	
    if (![mResources startTweenForKey:RESOURCE_KEY_NPC_DOCK_TWEEN]) {
        SPTween *tween = [SPTween tweenWithTarget:mWardrobe time:duration transition:SP_TRANSITION_LINEAR];
        [tween animateProperty:@"alpha" targetValue:0.0f];
        [tween addEventListener:@selector(onDockingComplete:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
        [mScene.juggler addObject:tween];
    }
}

- (void)sink {
	if (mDocking)
		return;
    [self removeAllPursuers];
    
	[super sink];
	mDocking = YES;
	
	if (mDeathBitmap & (DEATH_BITMAP_BRANDY_SLICK | DEATH_BITMAP_ACID_POOL | DEATH_BITMAP_MAGMA_POOL | DEATH_BITMAP_SEA_OF_LAVA)) {
		[mSinkingClip pause];
		[self burn];
        
        if (mDeathBitmap & DEATH_BITMAP_SEA_OF_LAVA)
            [self spawnMagmaPool];
	} else {
        if (mDeathBitmap & DEATH_BITMAP_GHOSTLY_TEMPEST)
            mDeathCostume.visible = NO;
		[self proceedToSink];
	}
	
	if (mBootyGoneWanting == YES && mScene.raceEnabled == NO && (mDeathBitmap & DEATH_BITMAP_NPC_CANNON))
		[GCTRL.thisTurn addMutiny:1];
	
	[mWardrobe removeChild:mCostume];
    mSinkingTimer = mSinkingClip.duration;
}

- (void)burn {
	[super burn];
	mWardrobe.alpha = 0;
	
    if (![mResources startTweenForKey:RESOURCE_KEY_NPC_BURN_IN_TWEEN]) {
        SPTween *tween = [SPTween tweenWithTarget:mWardrobe time:mBurningClip.duration / 2 transition:SP_TRANSITION_EASE_OUT];
        [tween animateProperty:@"alpha" targetValue:1];
        [mScene.juggler addObject:tween];
        [tween addEventListener:@selector(onBurningHalfComplete:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
    }
}

- (void)proceedToSink {
	if (mBody)
		mBody->SetLinearVelocity(b2Vec2(0.0f,0.0f));
	mIsCollidable = NO;
	[mSinkingClip play];
	[self playSunkSound];

	if (mDeathBitmap && (mDeathBitmap & (DEATH_BITMAP_NPC_CANNON | DEATH_BITMAP_TOWN_CANNON)) == 0 && mScene.raceEnabled == NO)
		[self creditPlayerSinker];
	if (mDeathBitmap && (mDeathBitmap & DEATH_BITMAP_NPC_MASK) == 0)
		[self dropLoot];
}

- (void)shrinkOverTime:(float)duration {
	//if (duration < 0)
	//	duration = mSinkingClip.duration;
    
    // Ignore duration so that caching tweens works
	
    if (![mResources startTweenForKey:RESOURCE_KEY_NPC_SHRINK_TWEEN]) {
        SPTween *tween = [SPTween tweenWithTarget:mWardrobe time:1 transition:SP_TRANSITION_LINEAR];
        [tween animateProperty:@"scaleX" targetValue:0.01f];
        [tween animateProperty:@"scaleY" targetValue:0.01f];
        [mScene.juggler addObject:tween];
    }
}

- (Cannonball *)fireCannon:(int)side trajectory:(float)trajectory {
	mReloading = YES;
    mReloadTimer = mReloadInterval;
	return [super fireCannon:side trajectory:trajectory];
}

- (void)playFireCannonSound {
	[mScene.audioPlayer playSoundWithKey:@"NpcCannon" volume:0.75f];
}

- (void)reload {
	mReloading = NO;
}

- (void)damageShipWithCannonball:(Cannonball *)cannonball {
	[super damageShipWithCannonball:cannonball];
	
	if (mRemoveMe == NO && mDocking == NO) {
		if ([cannonball.shooter isKindOfClass:[PlayerShip class]]) {
			mDeathBitmap = DEATH_BITMAP_PLAYER_CANNON;
			mBootyGoneWanting = NO;
			[self sink];
		} else {
			if ([cannonball.shooter isKindOfClass:[NpcShip class]])
				mDeathBitmap = DEATH_BITMAP_NPC_CANNON;
			else if ([cannonball.shooter isKindOfClass:[TownCannon class]])
				mDeathBitmap = DEATH_BITMAP_TOWN_CANNON;
			mBootyGoneWanting = [self hasBootyGoneWanting:cannonball.shooter];
			[self sink];
		}
	}
}

- (BOOL)hasBootyGoneWanting:(SPSprite *)shooter {
	return NO;
}

- (void)throwCrewOverboard:(int)count {
	for (int i = 0; i < count; ++i) {
        [mScene prisonerOverboard:nil ship:self];
		mOverboard = (mOverboard == mStern) ? mBow : mStern; // Spread multiple prisoners out in the water
	}
	mOverboard = mStern;
}

- (void)spawnAcidPool {
	if (mBody) {
		b2Vec2 bodyPos = mBody->GetPosition();
		AcidPoolActor *acidPool = [AcidPoolActor acidPoolActorAtX:bodyPos.x y:bodyPos.y duration:ASH_DURATION_ACID_POOL];
		[mScene addActor:acidPool];
	}
}

- (void)spawnMagmaPool {
    if (mBody) {
		b2Vec2 bodyPos = mBody->GetPosition();
		MagmaPoolActor *magmaPool = [MagmaPoolActor magmaPoolActorAtX:bodyPos.x
                                                                    y:bodyPos.y
                                                             duration:ASH_DURATION_MAGMA_POOL * [Potion potencyDurationFactorForPotion:[mScene potionForKey:POTION_POTENCY]]];
		[mScene addActor:magmaPool];
	}
}

- (void)creditPlayerSinker {

}

- (void)didLeavePort {
	if (mHasLeftPort == YES)
		return;
    [mScene actorDepartedPort:self];
	mHasLeftPort = YES;
}

- (void)didReachDestination {
	[self requestNewDestination];
}

- (void)requestNewDestination {
    [mScene actorArrivedAtDestination:self];
}

- (float)navigate {
	if (mInWhirlpoolVortex || mInDeathsHands || mBody == 0)
		return 0.0f;
	float sailForce = mDrag * mSailForce;
	[self sailWithForce:sailForce];
	
	if (mDestination) {
		b2Vec2 bodyPos = mBody->GetPosition();
		b2Vec2 dest = mDestination.dest;
		dest -= bodyPos;
		
		if (mHasLeftPort == NO) {
			b2Vec2 distTravelled = bodyPos - mDestination.loc;
			
			if ((fabsf(distTravelled.x) + fabsf(distTravelled.y)) > 20.0f) // In meters
				[self didLeavePort];
		}
		
		if (fabsf(dest.x) < 2.0f && fabsf(dest.y) < 2.0f) {			
			// Signal ship's arrival at destination
			[self didReachDestination];
		} else {
			// Turn towards destination
			b2Vec2 linearVel = mBody->GetLinearVelocity();
			float angleToTarget = Box2DUtils::signedAngle(dest, linearVel);
			
			if (angleToTarget != 0.0f) {
				float turnForce = mDrag * ((angleToTarget > 0.0f) ? 2.0f : -2.0f) * (mTurnForceMax * (sailForce / mSailForceMax));
				[self turnWithForce:turnForce];
			}
		}
	}
	return sailForce;
}

- (void)updatePositionOrientation {
	if (mBody == 0)
		return;
	// Ship position/orientation
	b2Vec2 rudder = mStern->GetAABB(0).GetCenter();
	self.x = M2PX(rudder.x);
	self.y = M2PY(rudder.y);
	self.rotation = -self.b2rotation;
}

- (void)advanceTime:(double)time {
	if (mRemoveMe || mDocking || mBody == 0) {
		if (mRemoveMe == NO && mInWhirlpoolVortex == YES)
			[self updatePositionOrientation];
        if (mSinkingTimer > 0.0) {
            mSinkingTimer -= time;
            
            if (mSinkingTimer <= 0.0)
                [self sinkingComplete];
        }
		return;
	}
    
    if (mReloadTimer > 0.0) {
        mReloadTimer -= time;
        
        if (mReloadTimer <= 0.0)
            [self reload];
    }
	
	[super advanceTime:time];
	[self avoidCollisions];
	[self updatePositionOrientation];
	
	float sailForce = [self navigate];
	[self tickWakeOdometer:sailForce * (time * GCTRL.fps)];
	[self updateCostumeWithAngularVelocity:mBody->GetAngularVelocity()];
    
	if ([self isOutOfBounds]) {
		mBootyGoneWanting = NO;
		[self dock];
	}
	
    /*
	if (mInWhirlpoolVortex) {
		if (mWhirlpoolOverboardDelay >= 0 && [mScene isEquippedIdolMaxedForKey:VOODOO_SPELL_WHIRLPOOL]) {
			mWhirlpoolOverboardDelay -= time;
			
			if (mWhirlpoolOverboardDelay < 0)
				[self throwCrewOverboard:1];
		}
	}
     */
}

- (BOOL)isOutOfBounds {
    return (self.x < -210.0f || self.x > 690.0f || self.y < -170.0f || self.y > 490.0f);
}

- (void)burnOut {
    if (![mResources startTweenForKey:RESOURCE_KEY_NPC_BURN_OUT_TWEEN]) {
        SPTween *tween = [SPTween tweenWithTarget:mWardrobe time:mBurningClip.duration / 2 transition:SP_TRANSITION_LINEAR];
        [tween animateProperty:@"alpha" targetValue:0];
        [mScene.juggler addObject:tween];
    }
	
	[self proceedToSink];
}

- (void)onBurningHalfComplete:(SPEvent *)event {
    [self burnOut];
}

- (void)sinkingComplete {
    if (self.ashBitmap == ASH_ABYSSAL && mPreparingForNewGame == NO) {
        AbyssalBlastProp *blastProp = [[AbyssalBlastProp alloc] init];
        blastProp.x = self.centerX;
        blastProp.y = self.centerY;
        [mScene addProp:blastProp];
        [blastProp blast];
        [blastProp release];
        blastProp = nil;
    }
    
	[mScene.juggler removeTweensWithTarget:self];
	[mScene removeActor:self]; // Calls safe remove for us
}

- (void)dockingComplete {
    [mScene.juggler removeTweensWithTarget:self];
	[mScene removeActor:self]; // Calls safe remove for us
}

- (void)onDockingComplete:(SPEvent *)event {
	[self dockingComplete];
}

- (void)prepareForNewGame {
    if (mPreparingForNewGame)
        return;
    mPreparingForNewGame = YES;
    [self dockOverTime:mNewGamePreparationDuration];
}

- (void)resourceEventFiredWithKey:(uint)key type:(NSString *)type target:(NSObject *)target {
    switch (key) {
        case RESOURCE_KEY_NPC_DOCK_TWEEN:
            [self dockingComplete];
            break;
        case RESOURCE_KEY_NPC_BURN_IN_TWEEN:
            [self burnOut];
            break;
        case RESOURCE_KEY_NPC_BURN_OUT_TWEEN:
            break;
        case RESOURCE_KEY_NPC_SHRINK_TWEEN:
            break;
        default:
            break;
    }
}

- (void)checkoutPooledResources {
	if (mResources == nil)
		mResources = [[[mScene cacheManagerByName:CACHE_NPC_SHIP] checkoutPoolResourcesForKey:mKey] retain];
	if (mResources == nil)
		NSLog(@"_+_+_+_+_+_+_+_+_ MISSED NPC_SHIP CACHE _+_++_+_+_+_+_+_+");
    else {
        mResources.client = self;
        
        if (mWardrobe == nil)
            mWardrobe = [(SPSprite *)[mResources displayObjectForKey:RESOURCE_KEY_NPC_WARDROBE] retain];
        if (mCostumeImages == nil)
            mCostumeImages = [(NSArray *)[mResources miscResourceForKey:RESOURCE_KEY_NPC_COSTUME] retain];
        if (mSinkingClip == nil)
            mSinkingClip = [(SPMovieClip *)[mResources displayObjectForKey:RESOURCE_KEY_NPC_SINKING] retain];
        if (mBurningClip == nil)
            mBurningClip = [(SPMovieClip *)[mResources displayObjectForKey:RESOURCE_KEY_NPC_BURNING] retain];
    }
}

- (void)checkinPooledResources {
    if (mResources) {
        [mWardrobe removeAllChildren];
        [[mScene cacheManagerByName:CACHE_NPC_SHIP] checkinPoolResources:mResources];
        [mResources release]; mResources = nil;
    }
}

- (void)zeroOutFixtures {
	[super zeroOutFixtures];
	
	mFeeler = 0;
    mHitBox = 0;
}

- (void)dealloc {
	[mAvoiding release]; mAvoiding = nil;
	[mDestination release]; mDestination = nil;
	
	[self checkinPooledResources];
	[super dealloc];
}

@end
