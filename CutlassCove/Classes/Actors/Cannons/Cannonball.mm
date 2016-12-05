//
//  Cannonball.m
//  Pirates
//
//  Created by Paul McPhee on 18/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "Cannonball.h"
#import "CannonFactory.h"
#import "CannonballGroup.h"
#import "CannonballCache.h"
#import "Box2DUtils.h"
#import "PointMovie.h"
#import "Splash.h"
#import "Explosion.h"
#import "ShipActor.h"
#import "PlayerShip.h"
#import "NpcShip.h"
#import "MerchantShip.h"
#import "NavyShip.h"
#import "PirateShip.h"
#import "TownCannon.h"
#import "BrandySlickActor.h"
#import "PowderKegActor.h"
#import "OverboardActor.h"
#import "Ash.h"
#import "GameController.h"
#import "Globals.h"

const int kCannonballImpactDamage = 2;

const float kMaxAltitude = ((PI / 8.0f) / kGravity) / 4.0f;
const float kShadowAlpha = 0.35f;
const float kBaseShadowFactor = 56.0f; // 128.0f // 192.0f; //128.0f;
const float kScaleFactor = 0.07f * PI; // 0.09f * PI; // Original Value: 0.125f * PI;
const float kScaleMin = 0.3f;
const float kScaleMax = 1.75f;
const float kScaleRange = kScaleMax - kScaleMin;

const int kCannonballCoreTag = 0x1;
const int kCannonballCoreMask = 0xff;
const int kCannonballConeTag = 0x100;
const int kCannonballConeMask = 0xff00;

@interface Cannonball ()

- (void)alterTrajectory:(float)factor padding:(float)padding;
- (CannonballImpactLog *)notifyOfImpact:(ImpactType)impactType ricochetTarget:(Actor *)ricochetTarget;
- (ShipActor *)nearestRicochetTarget:(NSMutableSet *)targets ignoreActor:(Actor *)ignoreActor;
- (void)ricochet:(ShipActor *)ship;
- (void)displayHitEffect:(int)effectType;
- (void)decorateCannonball;

@end


@implementation Cannonball

@synthesize cannonballGroupId = mGroupId;
@synthesize cannonballGroup = mGroup;
@synthesize shotType = mShotType;
@synthesize shooter = mShooter;
@synthesize hasProcced = mHasProcced;
@synthesize core = mCore;
@synthesize cone = mCone;
@synthesize bore = mBore;
@synthesize trajectory = mTrajectory;
@synthesize distanceRemaining = mDistanceRemaining;
@synthesize gravity = mGravity;
@synthesize infamyBonus = mInfamyBonus;
@synthesize ricochetCount = mRicochetCount;
@synthesize damageFromImpact = mDamageFromImpact;
@dynamic shooterName,distSq;

+ (float)fps {
	return 12.0f;
}

+ (NSString *)shooterName:(SPSprite *)shooter {
	NSString *name = nil;
	
	if ([shooter isKindOfClass:[PlayerShip class]])
		name = @"PlayerShip";
	else if ([shooter isKindOfClass:[PirateShip class]])
		name = @"PirateShip";
	else if ([shooter isKindOfClass:[NavyShip class]])
		name = @"NavyShip";
	else if ([shooter isKindOfClass:[MerchantShip class]])
		name = @"MerchantShip";
	else if ([shooter isKindOfClass:[TownCannon class]])
		name = @"TownCannon";
	else {
		name = @"INVALID_CANNON_SHOOTER";
		//NSLog(@"%@",name);
	}
	return name;
}

- (id)initWithActorDef:(ActorDef *)def shotType:(NSString *)shotType shooter:(SPSprite *)shooter bore:(float)bore trajectory:(float)trajectory {
    if (self = [super initWithActorDef:def]) {
		mCategory = CAT_PF_EXPLOSIONS;
		mAdvanceable = YES;
		mGroupId = 0;
        mGroup = nil;
		mShotType = [shotType copy];
		mShooter = [shooter retain];
		mOrigin = mBody->GetPosition();
		mHasProcced = NO;
		
		b2Fixture **fixtures = def->fixtures;
		mCore =  *fixtures;
		
		if (def->fixtureDefCount == 2) {
			++fixtures;
			mCone = *fixtures;
		} else {
			mCone = 0;
		}
		//++fixtures;
		//mTest = *fixtures;
        
        GameController *gc = GCTRL;

        mGravity = kGravity * gc.fpsFactor;
		mBore = bore;
		self.trajectory = trajectory;
		mShadowFactor = 0.0f;
		mBallClip = nil;
		mShadowClip = nil;
        mBallContainer = nil;
        mShadowContainer = nil;
        mBallCostume = nil;
        mShadowCostume = nil;
		
		mRicocheted = NO;
		mRicochetCount = 0;
        mDamageFromImpact = kCannonballImpactDamage * gc.thisTurn.difficultyMultiplier;
		mInfamyBonus = [[CannonballInfamyBonus alloc] init];
		
		if (mKey == nil)
			mKey = [[NSString stringWithFormat:@"Cannonball"] copy];
        mSensors = [[NSMutableArray alloc] initWithCapacity:5];
		mDestroyedShips = [[NSMutableSet alloc] init];
		mResources = nil;
		[self checkoutPooledResources];
    }
    return self;
}

- (id)initWithActorDef:(ActorDef *)def shotType:(NSString *)shotType shooter:(SPSprite *)shooter bore:(float)bore {
	return [self initWithActorDef:def shotType:shotType shooter:shooter bore:bore trajectory:-PI_HALF / 2];
}

- (id)init {
	ActorDef actorDef;
	return [self initWithActorDef:&actorDef shotType:@"single-shot_" shooter:[[[SPSprite alloc] init] autorelease] bore:1];
}

- (void)setupCannonball {
	GameController *gc = [GameController GC];
	
	// Cannonball clips
	NSArray *textures = nil;
	
	if (mBallClip == nil) {
		textures = [mScene texturesStartingWith:mShotType cacheGroup:TM_CACHE_CANNONBALLS];
		mBallClip = [[SPMovieClip alloc] initWithFrames:textures fps:[Cannonball fps]];
		mBallClip.x = -mBallClip.width/2;
		mBallClip.loop = YES;
	}
	
    mBallClip.y = 0;
    mBallClip.currentFrame = 0;
    [mBallClip play];
	[mScene.juggler addObject:mBallClip];

	if (mShadowClip == nil) {
		if (textures == nil)
			textures = [mScene texturesStartingWith:mShotType cacheGroup:TM_CACHE_CANNONBALLS];
		mShadowClip = [[SPMovieClip alloc] initWithFrames:textures fps:[Cannonball fps]];
		mShadowClip.x = -mShadowClip.width/2;
		mShadowClip.loop = YES;
	}
    
    mShadowClip.y = 0;
    mShadowClip.currentFrame = 0;
    [mShadowClip play];
	[mScene.juggler addObject:mShadowClip];
    
    mShadowContainer = [[SPSprite alloc] init];
    mShadowContainer.y = -mShadowClip.height / 8;
    [mShadowContainer addChild:mShadowClip];
    
    mShadowCostume = [[SPSprite alloc] init];
    [mShadowCostume addChild:mShadowContainer];
    [self addChild:mShadowCostume];
    
    mBallContainer = [[SPSprite alloc] init];
    mBallContainer.y = -mBallClip.height / 8;
    [mBallContainer addChild:mBallClip];
    
    mBallCostume = [[SPSprite alloc] init];
    [mBallCostume addChild:mBallContainer];
    [self addChild:mBallCostume];
    
    /*
    SPQuad *testQuad = [SPQuad quadWithWidth:24 height:48];
    testQuad.x = -testQuad.width / 2;
    testQuad.y = mBallContainer.y;
    [self addChild:testQuad];
    */
	
	// Calculate shadow length based on time of day
	mShadowFactor = kBaseShadowFactor * gc.timeKeeper.shadowOffsetY;
	
    self.x = self.px;
	self.y = self.py;
    mBallCostume.rotation = -self.b2rotation;
    mShadowCostume.rotation = -self.b2rotation;
	[self decorateCannonball];
}

- (void)setGravity:(float)gravity {
    mGravity = gravity * GCTRL.fpsFactor;
}

- (CannonballInfamyBonus *)infamyBonus {
	return [[mInfamyBonus copy] autorelease];
}

- (NSString *)shooterName {
	return [Cannonball shooterName:mShooter];
}

- (void)setCannonballGroup:(CannonballGroup *)cannonballGroup {
    assert(!(mGroup && cannonballGroup));
    mGroup = cannonballGroup;
    mGroupId = (mGroup) ? mGroup.groupId : 0;
}

- (float)distSq {
	b2Vec2 distVec = (mBody) ? mBody->GetPosition() - mOrigin : b2Vec2(0,0);
	float x = M2P(distVec.x);
	float y = M2P(distVec.y);
	return x * x + y * y;
}

- (void)setTrajectory:(float)value {
	mTrajectory = value;
	mDistanceRemaining = fabsf(mTrajectory / mGravity);
	mMidDistance = mDistanceRemaining / 2;
	mScaleFactor = fabsf(mTrajectory / (kScaleFactor * GCTRL.fpsFactor));
}

- (void)calculateTrajectoryFromTarget:(b2Body *)target {
    if (!target || !mBody)
        return;
    
    b2Vec2 targetPos = target->GetPosition();
    b2Vec2 cannonballVelocity = mBody->GetLinearVelocity();
    float cannonballMagnitude = cannonballVelocity.Length();
    
    // Calc initial trajectory
    b2Vec2 distVec = b2Vec2(self.px - M2PX(targetPos.x), self.py - M2PY(targetPos.y));
    float distance = distVec.Length();
    float distVel = cannonballMagnitude * (PPM / mScene.fps);
    
    if (SP_IS_FLOAT_EQUAL(distVel, 0))
        distVel = 1;
    
    mDistanceRemaining = mGravity * (distance / distVel);
    mTrajectory = -mDistanceRemaining * mGravity;
    mMidDistance = mDistanceRemaining / 2;
    mScaleFactor = fabsf((mDistanceRemaining * mGravity) / kScaleFactor);
    
    // Recalibrate trajectory based on the position our target will be at in future.
    b2Vec2 combinedVelocity = cannonballVelocity + target->GetLinearVelocity();
    float combinedMagnitude = combinedVelocity.Length();
    
    if (cannonballMagnitude != 0 && combinedMagnitude != 0) {
        [self alterTrajectory:combinedMagnitude / cannonballMagnitude padding:0.1f];
        combinedVelocity *= (cannonballMagnitude / combinedMagnitude);
        mBody->SetLinearVelocity(combinedVelocity);
    }
        
}

- (void)calculateTrajectoryFromTargetX:(float)targetX targetY:(float)targetY {	
	float x = self.px - targetX;
	float y = self.py - targetY;
	
	b2Vec2 velVec = (mBody) ? mBody->GetLinearVelocity() : b2Vec2(0,0);
	velVec.x *= PPM / mScene.fps;
	velVec.y *= PPM / mScene.fps;
	
	float dist = [Globals vecLengthX:x y:y];
	float vel = [Globals vecLengthX:velVec.x y:velVec.y];
    
    if (SP_IS_FLOAT_EQUAL(vel, 0))
        vel = 1;

	mDistanceRemaining = mGravity * (dist / vel);
	mTrajectory = -mDistanceRemaining * mGravity;
	mMidDistance = mDistanceRemaining / 2;
	mScaleFactor = fabsf((mDistanceRemaining * mGravity) / (kScaleFactor * GCTRL.fpsFactor));
	
	// Clamp shots to their shooter's maximum cannon range
	//if (mTrajectory < SP_D2R(-22.5f))
	//	self.trajectory = SP_D2R(-22.5f);
	//NSLog(@"<======== Trajectory: %f ===========>", SP_R2D(mTrajectory));
}

- (void)copyTrajectoryFrom:(Cannonball *)other {
    mDistanceRemaining = other.distanceRemaining;
    mTrajectory = -mDistanceRemaining * mGravity;
    mMidDistance = mDistanceRemaining / 2;
	mScaleFactor = fabsf((mDistanceRemaining * mGravity) / (kScaleFactor * GCTRL.fpsFactor));
}

- (void)alterTrajectory:(float)factor padding:(float)padding {
    mDistanceRemaining = (mDistanceRemaining * factor) + padding;
    mTrajectory = -mDistanceRemaining * mGravity;
    mMidDistance = mDistanceRemaining / 2;
	mScaleFactor = fabsf((mDistanceRemaining * mGravity) / (kScaleFactor * GCTRL.fpsFactor));
}

- (void)beginContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
	[super beginContact:other fixtureSelf:fixtureSelf fixtureOther:fixtureOther contact:contact];
	
	int tag = [self tagForContactWithActor:other];
	
	if (fixtureSelf == mCore)
		[self setTag:tag + kCannonballCoreTag forContactWithActor:other];
	else if (fixtureSelf == mCone)
		[self setTag:tag + kCannonballConeTag forContactWithActor:other];
}

- (void)endContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
	int tag = [self tagForContactWithActor:other];
	
    if (tag != 0) {
        if (fixtureSelf == mCore)
            [self setTag:tag - kCannonballCoreTag forContactWithActor:other];
        else if (fixtureSelf == mCone)
            [self setTag:tag - kCannonballConeTag forContactWithActor:other];
    }
    
	[super endContact:other fixtureSelf:fixtureSelf fixtureOther:fixtureOther contact:contact];
}

- (void)respondToPhysicalInputs {
	if (self.markedForRemoval || self.isPreparingForNewGame || mDistanceRemaining > (mGravity + 0.005))
		return;

	BOOL hitSolidObject = NO, playerHitNpcShip = NO;
	Actor *hitShip = nil;
    CannonballImpactLog *impactLog = nil;
    
	for (Actor *actor in mContacts) {
		if (actor.markedForRemoval == YES)
			continue;
		int tag = [self tagForContactWithActor:actor];
		
		// We're only interested in processing contacts with the core cannonball fixture; not the ricochet cone.
		if ((tag & kCannonballCoreMask) == 0)
			continue;
		
		if (actor != mShooter && ![actor isSensor]) {
			if ([actor isKindOfClass:[ShipActor class]]) {
				if ([mDestroyedShips containsObject:actor])
					continue;
				
				if ([actor isKindOfClass:[PlayerShip class]]) {
					PlayerShip *ship = (PlayerShip *)actor;
					
					if (ship.isFlyingDutchman == YES)
						continue;
				} else if ([actor isKindOfClass:[NpcShip class]]) {
					if ([mShooter isKindOfClass:[PlayerShip class]]) {
						impactLog = [self notifyOfImpact:ImpactNpcShip ricochetTarget:actor];
						
						// If not in a group OR if the first of a group to ricochet off this ship
						if (impactLog == nil || impactLog.mayRicochet) {
							NpcShip *npcShip = (NpcShip *)actor;
							
							if (npcShip.docking == NO) {
								PlayerShip *playerShip = (PlayerShip *)mShooter;
								[playerShip cannonballHitTarget:YES ricochet:mRicocheted proc:mHasProcced];
								[mScene.achievementManager playerHitShip:npcShip distSq:self.distSq ricocheted:mRicocheted];
                                
                                // Apply ricochet bonus
                                npcShip.ricochetHop = mRicochetCount;
                                npcShip.ricochetBonus = (int)(mRicochetCount * [Potion ricochetBonusForPotion:[mScene potionForKey:POTION_RICOCHET]]);
                                
                                // Apply procMultiplier to both because procs are supposed to multiply your entire score
                                //npcShip.ricochetBonus = mRicochetCount * mInfamyBonus.procMultiplier * mInfamyBonus.ricochetBonus;
								//npcShip.sunkByPlayerCannonInfamyBonus = mInfamyBonus.procMultiplier * npcShip.infamyBonus;
                                npcShip.sunkByPlayerCannonInfamyBonus = npcShip.infamyBonus;
							
								if (mInfamyBonus.procType & ASH_SAVAGE)
									[npcShip throwCrewOverboard:1];
								else if (mInfamyBonus.procType & ASH_NOXIOUS)
									[npcShip spawnAcidPool];
                                
                                if (mInfamyBonus.procType)
                                    npcShip.ashBitmap = mInfamyBonus.procType;
                                npcShip.miscBitmap |= mInfamyBonus.miscBitmap;
								playerHitNpcShip = YES;
							}
						}
					}
				}
				
				[(ShipActor *)actor damageShipWithCannonball:self];
				hitShip = actor;
				[mDestroyedShips addObject:actor];
                hitSolidObject = YES;
                break;
			} else {
                hitSolidObject = YES;
            }
		} else if ([actor isKindOfClass:[BrandySlickActor class]] || [actor isKindOfClass:[PowderKegActor class]]
                   || [actor isKindOfClass:[OverboardActor class]]) {
			[mSensors addObject:actor];
		}
	}
	
	// Splash at 0.0f; hit below 0.015f.
	if (mDistanceRemaining <= 0.0 || hitSolidObject) {
		if (hitShip == nil && mRicocheted == NO && [mShooter isKindOfClass:[PlayerShip class]]) {
            BOOL ignoreMiss = NO;
            ImpactType impactType = (hitSolidObject) ? ImpactLand : ImpactWater;
			impactLog = [self notifyOfImpact:impactType ricochetTarget:nil];
            
            if (impactType == ImpactWater) {
                // Don't penalize player for igniting a Brandy Slick
                for (Actor *sensor in mSensors) {
                    if ([sensor isKindOfClass:[BrandySlickActor class]]) {
                        BrandySlickActor *brandySlick = (BrandySlickActor *)sensor;
                        
                        if (brandySlick.ignited == NO) {
                            ignoreMiss = YES;
                            
                            if (self.cannonballGroup)
                                [self.cannonballGroup ignoreGroupMiss];
                            break;
                        }
                    }
                }
            }
            
            if ((impactLog == nil || impactLog.groupMissed) && ignoreMiss == NO) {
                PlayerShip *ship = (PlayerShip *)mShooter;
                [ship cannonballHitTarget:NO ricochet:mRicocheted proc:mHasProcced];
                [mScene.achievementManager playerMissed:mInfamyBonus.procType];
            }
		}
		
		if (hitSolidObject) {
			[self displayHitEffect:MovieTypeExplosion];
			
			if (impactLog == nil || impactLog.shouldPlaySounds)
				[self playExplosionSound];
		} else {
            for (Actor *actor in mSensors) {
                if ([actor isKindOfClass:[BrandySlickActor class]]) {
                    BrandySlickActor *slick = (BrandySlickActor *)actor;
                    [slick ignite];
                } else if ([actor isKindOfClass:[PowderKegActor class]]) {
                    PowderKegActor *keg = (PowderKegActor *)actor;
                    [keg detonate];
                } else if ([actor isKindOfClass:[OverboardActor class]]) {
                    OverboardActor *person = (OverboardActor *)actor;
                    [person environmentalDeath];
                }
            }
            
			[self displayHitEffect:MovieTypeSplash];
			
			if (impactLog == nil || impactLog.shouldPlaySounds)
				[self playSplashSound];
		}
		
		mRicocheted = NO;
		
		if (hitShip && [mShooter isKindOfClass:[PlayerShip class]]) {
			if (playerHitNpcShip && (impactLog == nil || impactLog.mayRicochet) && mRicochetCount < 5) {
				// Test for ricochet
				ShipActor *ricochetTarget = [self nearestRicochetTarget:mContacts ignoreActor:hitShip];
				
				if (ricochetTarget != nil)
					[self ricochet:ricochetTarget];
			}
		}
		
		if (mRicocheted == NO) {
            [self notifyOfImpact:ImpactRemoveMe ricochetTarget:nil];
			[self safeRemove];
		}
	}
	
	[mSensors removeAllObjects];
}

- (CannonballImpactLog *)notifyOfImpact:(ImpactType)impactType ricochetTarget:(Actor *)ricochetTarget {
	CannonballImpactLog *impactLog = nil;
	
	if (self.cannonballGroup) {
        impactLog = [CannonballImpactLog logWithCannonball:self impactType:impactType ricochetTarget:ricochetTarget];
        [self.cannonballGroup cannonballImpacted:impactLog];
    }

	return impactLog;
}

- (ShipActor *)nearestRicochetTarget:(NSMutableSet *)targets ignoreActor:(Actor *)ignoreActor {
	float xDist, yDist, closest = 99999999.9, distSq;
	ShipActor *target = nil;
	
	for (Actor *actor in targets) {
		if (actor == ignoreActor || actor.markedForRemoval)
			continue;
		int tag = [self tagForContactWithActor:actor];
		
		if (tag & kCannonballConeMask) {
			if ([actor isKindOfClass:[NpcShip class]]) {
				NpcShip *ship = (NpcShip *)actor;
				
				if (ship.docking == NO) {
					xDist = self.x - ship.x;
					yDist = self.y - ship.y;
					distSq = [Globals vecLengthSquaredX:xDist y:yDist];
				
					if (closest > distSq) {
						closest = distSq;
						target = (ShipActor *)actor;
					}
				}
			}
		}
	}
	
	return target;
}

- (void)ricochet:(ShipActor *)ship {
	if (ship == nil || mBody == 0)
		return;
	mRicocheted = YES;
	++mRicochetCount;
	
	// Calculate and apply linear velocity
	b2Vec2 selfPos = mBody->GetPosition();
	b2Vec2 target = ship.body->GetPosition();
	float x = target.x - selfPos.x;
	float y = target.y - selfPos.y;
	
	b2Vec2 impulse(x, y);
	impulse.Normalize();
	impulse *= [CannonFactory cannonballImpulse];
	mBody->SetLinearVelocity(b2Vec2(0,0));
	mBody->ApplyLinearImpulse(impulse, selfPos);
	
	// Caluclate trajectory
	[self calculateTrajectoryFromTargetX:M2PX(target.x) targetY:M2PY(target.y)];
	
	// Add target's linear velocity to ensure we hit it
	b2Vec2 selfVel = mBody->GetLinearVelocity();
	b2Vec2 targetVelocity = ship.body->GetLinearVelocity();
	mBody->SetLinearVelocity(selfVel + targetVelocity);
	
	// Set transform
	b2Vec2 vertical = b2Vec2(0, 1);
	selfVel = mBody->GetLinearVelocity();
	mBody->SetTransform(selfPos, -Box2DUtils::signedAngle(selfVel, vertical));
	
	// Adjust appearance
    mBallCostume.rotation = -self.b2rotation;
    mShadowCostume.rotation = -self.b2rotation;
    
    // Closer to 1.0f doesn't look good, so clamp at 0.75f.
    float shadowOffsetY = GCTRL.timeKeeper.shadowOffsetY;
    if (fabsf(shadowOffsetY) > 0.75f)
        shadowOffsetY = (shadowOffsetY > 0 ? 0.75f : -0.75f) * shadowOffsetY;
	mShadowFactor = kBaseShadowFactor * shadowOffsetY; 
	[self decorateCannonball];
}

- (void)displayHitEffect:(int)effectType {
    [PointMovie pointMovieWithType:effectType x:self.x y:self.y];
}

- (void)playExplosionSound {
    float volume = MIN(1.25f, 0.7f + 0.15f * mRicochetCount);
    float pitch = MAX(0.5f, 1.1f - (MIN(1, mRicochetCount) * 0.2f + MAX(0, (int)mRicochetCount - 1) * 0.1f));
	[mScene.audioPlayer playRandomSoundWithKeyPrefix:@"Explosion" range:3 volume:volume pitch:pitch];
}

- (void)playSplashSound {
	[mScene.audioPlayer playSoundWithKey:@"Splash" volume:((RESM.isLowSoundOutput) ? 0.5f : 0.33f)];
}

- (void)advanceTime:(double)time {
	self.x = self.px;
	self.y = self.py;

	mDistanceRemaining -= mGravity * (time * GCTRL.fps);
	[self decorateCannonball];
}

- (void)decorateCannonball {
#if 1
    // More linear scaling. Less distance in the max altitude flat plateau range but smaller at low altitudes.
    float scaleFunction = fabsf(mDistanceRemaining - mMidDistance) / mMidDistance;
    float scaleFunctionSq = scaleFunction * scaleFunction;
    float scale = MIN(kScaleMax, kScaleMin + (mScaleFactor * (0.2f * (1.0f - scaleFunction) + 0.8f * (1.0f - scaleFunctionSq))));
#else
    // Removes linear component of scaling to give larger scales at lower altitudes but flattens out at max scale earlier on.
    float scaleFunction = fabsf(mDistanceRemaining - mMidDistance) / mMidDistance;
    scaleFunction *= scaleFunction;
    float scale = MIN(kScaleMax, kScaleMin + (mScaleFactor * (1.0f - scaleFunction)));
#endif
    
    mBallContainer.scaleX = scale;
    mBallContainer.scaleY = scale;
    mShadowContainer.scaleX = scale;
    mShadowContainer.scaleY = scale;
    
    float scaler = (scale - kScaleMin) / kScaleRange;
	mShadowClip.alpha = MAX(0.1f, kShadowAlpha - kShadowAlpha * scaler); // MAX(0.1f, kShadowAlpha - halfScale);
    mShadowCostume.y = mShadowFactor * scaler * scaler; // halfScale * (-16 + mShadowFactor * halfScale);
}

- (void)safeRemove { 
	if (mRemoveMe == YES)
		return;
	[super safeRemove];
    
    if (self.cannonballGroup)
        [self.cannonballGroup removeCannonball:self]; // Group retains/autoreleases us
	
    if (self.isPreparingForNewGame == NO && [mShooter isKindOfClass:[PlayerShip class]]) {
        if (mRicochetCount >= 3) {
            if ([mScene.achievementManager hasCopsAndRobbersAchievement] == NO) {
                int navyCount = 0, pirateCount = 0;
                
                for (Actor *actor in mDestroyedShips) {
                    if ([actor isKindOfClass:[NavyShip class]])
                        ++navyCount;
                    else if ([actor isKindOfClass:[PirateShip class]])
                        ++pirateCount;
                }
                
                if (navyCount >= 2 && pirateCount >= 2)
                    [mScene.achievementManager grantCopsAndRobbersAchievement];
            }
        }
        
        [mScene.achievementManager grantRicochetAchievement:mRicochetCount];
        [GCTRL.objectivesManager progressObjectiveWithRicochetVictims:mDestroyedShips];
    }
}

- (void)resourceEventFiredWithKey:(uint)key type:(NSString *)type target:(NSObject *)target { }

- (void)checkoutPooledResources {
	if (mResources == nil)
		mResources = [[[mScene cacheManagerByName:CACHE_CANNONBALL] checkoutPoolResourcesForKey:mShotType] retain];
	if (mResources == nil)
		NSLog(@"_+_+_+_+_+_+_+_+_ MISSED CANNONBALL CACHE _+_++_+_+_+_+_+_+");
    else {
        mResources.client = self;
        
        if (mBallClip == nil)
            mBallClip = [(SPMovieClip *)[mResources displayObjectForKey:RESOURCE_KEY_CANNONBALL_CLIP] retain];
        if (mShadowClip == nil)
            mShadowClip = [(SPMovieClip *)[mResources displayObjectForKey:RESOURCE_KEY_SHADOW_CLIP] retain];
    }
}

- (void)checkinPooledResources {
    if (mResources) {
        [[mScene cacheManagerByName:CACHE_CANNONBALL] checkinPoolResources:mResources];
        [mResources release]; mResources = nil;
    }
}

- (void)zeroOutFixtures {
	[super zeroOutFixtures];
	
	mCore = 0;
	mCone = 0;
}

- (void)dealloc {
	mCore = 0;
	mCone = 0;
    self.cannonballGroup = nil;
	
	if (mBallClip != nil)
		[mScene.juggler removeObject:mBallClip];
	
	if (mShadowClip != nil)
		[mScene.juggler removeObject:mShadowClip];
	[self checkinPooledResources];
	[mInfamyBonus release]; mInfamyBonus = nil;
	[mBallClip release]; mBallClip = nil;
	[mShadowClip release]; mShadowClip = nil;
    [mBallContainer release]; mBallContainer = nil;
    [mShadowContainer release]; mShadowContainer = nil;
    [mBallCostume release]; mBallCostume = nil;
    [mShadowCostume release]; mShadowCostume = nil;
	[mShotType release]; mShotType = nil;
	[mShooter release]; mShooter = nil;
    [mSensors release]; mSensors = nil;
	[mDestroyedShips release]; mDestroyedShips = nil;
    [super dealloc];
	
	//NSLog(@"Cannonball dealloc'ed");
}

@end

