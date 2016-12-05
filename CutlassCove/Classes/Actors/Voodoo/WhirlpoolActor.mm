//
//  WhirlpoolActor.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 16/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WhirlpoolActor.h"
#import "ActorFactory.h"
#import "NpcShip.h"
#import "NavyShip.h"
#import "MerchantShip.h"
#import "PlayerShip.h"
#import "PowderKegActor.h"
#import "OverboardActor.h"
#import "NetActor.h"
#import "BrandySlickActor.h"
#import "TempestActor.h"
#import "PoolActor.h"
#import "AchievementManager.h"
#import "Box2DUtils.h"
#import "Globals.h"

const float kSpawnDuration = 3.0f; // Can't be zero or will enable possible DBZ

typedef enum {
	WhirlpoolStateIdle = 0,
	WhirlpoolStateAlive,
	WhirlpoolStateDying,
	WhirlpoolStateDead
} WhirlpoolState;

@interface WhirlpoolActor ()

- (void)setState:(int)state;
- (void)setupActorCostume;
- (void)spawnOverTime:(float)duration;
- (void)onDespawnCompleted:(SPEvent *)event;
- (void)applyVortexForceToBody:(b2Body *)body suckFactor:(float)suckFactor swirlFactor:(float)swirlFactor;
- (BOOL)ignoresContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact;

@end


@implementation WhirlpoolActor

@synthesize swirlFactor = mSwirlFactor;
@synthesize suckFactor = mSuckFactor;

+ (float)spawnDuration {
	return kSpawnDuration;
}

+ (WhirlpoolActor *)whirlpoolActorAtX:(float)x y:(float)y rotation:(float)rotation duration:(float)duration {
	ActorFactory *juilliard = [ActorFactory juilliard];
	ActorDef *actorDef = [juilliard createWhirlpoolDefAtX:x y:y angle:0.0f];
	WhirlpoolActor *whirlpool = [[[WhirlpoolActor alloc] initWithActorDef:actorDef duration:duration] autorelease];
	delete actorDef;
	actorDef = 0;
	return whirlpool;
}

- (id)initWithActorDef:(ActorDef *)def duration:(float)duration {
	if (self = [super initWithActorDef:def]) {
		mCategory = CAT_PF_WAVES;
		mAdvanceable = YES;
        mSwirlFactor = 1.0f;
        mSuckFactor = 2.25f;
		mDuration = (double)duration;
		mState = WhirlpoolStateIdle;
		mRoyalFlushes = 0;
		mWater = nil;
		mCostume = nil;
		mVictims = [[NSMutableSet alloc] init];
		
		// Save fixtures
		b2Fixture **fixtures = def->fixtures;
		mPool = fixtures[0];
		mEye = fixtures[1];
		mRadius = MAX(1.0f, mPool->GetShape()->m_radius);
		
		[self setupActorCostume];
		[self setState:WhirlpoolStateAlive];
    }
    return self;
}

- (void)setupActorCostume {
	if (mCostume != nil)
		return;
	mCostume = [[SPSprite alloc] init];
	mWater = [[SPImage alloc] initWithTexture:[mScene textureByName:@"whirlpool"]];
	mWater.x = -mWater.width / 2;
	mWater.y = -mWater.height / 2;
	[mCostume addChild:mWater];

    if (RESM.isLowPerformance) {
        mCostume.scaleX = 0.75f;
        mCostume.scaleY = 0.75f;
    }
    
	[self addChild:mCostume];
	self.x = self.px;
	self.y = self.py;
	self.alpha = 0.0f;
	
	double idolDuration = [Idol durationForIdol:[mScene idolForKey:VOODOO_SPELL_WHIRLPOOL]];
	
	if (mDuration <= VOODOO_DESPAWN_DURATION) {
		// Start in despawn mode
		self.alpha = mDuration / VOODOO_DESPAWN_DURATION;
		[self despawnOverTime:mDuration];
	} else if (SP_IS_FLOAT_EQUAL(idolDuration, mDuration) || mDuration > idolDuration) {
		// Start as new whirlpool
		[self spawnOverTime:kSpawnDuration];
	} else if (mDuration > (idolDuration - kSpawnDuration)) {
		// Start spawning
		float spawnFraction = (idolDuration - mDuration) / kSpawnDuration;
		float spawnDuration = (1 - spawnFraction) * kSpawnDuration;
		
		self.alpha = spawnFraction;
		[self spawnOverTime:spawnDuration];
	} else {
		// Start already spawned
		self.alpha = 1.0f;
	}
	[mScene.audioPlayer playSoundWithKey:@"Whirlpool" volume:1 easeInDuration:kSpawnDuration];
}

- (void)setWaterColor:(uint)color {
	mWater.color = color;
}

- (void)setState:(int)state {
	switch (state) {
		case WhirlpoolStateIdle:
			break;
		case WhirlpoolStateAlive:
			break;
		case WhirlpoolStateDying:
			break;
		case WhirlpoolStateDead:
			for (Actor *actor in mContacts) {
				if ([actor isKindOfClass:[NpcShip class]]) {
					NpcShip *ship = (NpcShip *)actor;
					ship.inWhirlpoolVortex = NO;
				}
			}
			[mScene removeActor:self];
			[mScene.juggler removeTweensWithTarget:self];
			break;
	}
	mState = state;
}

- (void)spawnOverTime:(float)duration {
	assert(mState == WhirlpoolStateIdle);
	SPTween *tween = [SPTween tweenWithTarget:self time:duration];
	[tween animateProperty:@"alpha" targetValue:1];
	[mScene.juggler addObject:tween];
}

- (void)despawnOverTime:(float)duration {
	if (mState != WhirlpoolStateAlive)
        return;
    
	SPTween *tween = [SPTween tweenWithTarget:self time:duration];
	[tween animateProperty:@"alpha" targetValue:0.01f];
	[tween addEventListener:@selector(onDespawnCompleted:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
	[mScene.juggler addObject:tween];
	[mScene.audioPlayer stopSoundWithKey:@"Whirlpool" easeOutDuration:duration];
	[self setState:WhirlpoolStateDying];
}

- (void)onDespawnCompleted:(SPEvent *)event {
	[self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_WHIRLPOOL_DESPAWNED]];
    
    if (self.turnID == GCTRL.thisTurn.turnID)
        [mScene.objectivesManager progressObjectiveWithEventType:OBJ_TYPE_VOODOO_GADGET_EXPIRED tag:VOODOO_SPELL_WHIRLPOOL];
	[self setState:WhirlpoolStateDead];
}

- (void)advanceTime:(double)time {
    if (self.markedForRemoval)
		return;
    
	mCostume.rotation += time * 3.0f;
    
    if (mDuration > VOODOO_DESPAWN_DURATION) {
        mDuration -= time;
        
        if (mDuration <= VOODOO_DESPAWN_DURATION)
            [self despawnOverTime:VOODOO_DESPAWN_DURATION];
    }
}

- (void)applyVortexForceToBody:(b2Body *)body suckFactor:(float)suckFactor swirlFactor:(float)swirlFactor {
	if (body == 0 || mBody == 0)
		return;
	b2Vec2 vec = mBody->GetPosition() - body->GetPosition();
	float32 len = vec.Length();
	
	if (len < FLT_EPSILON)
		return;
	vec.Normalize();
	
	b2Vec2 angularVelocity = vec;
	Box2DUtils::rotateVector(angularVelocity, PI_HALF);
	body->SetLinearVelocity(((5.0f + 20.0f * (len / mRadius)) * swirlFactor) * angularVelocity);
	vec *= (body->GetMass() / 10.0f) * 1200.0f * suckFactor;
	body->ApplyForce(vec, body->GetPosition());
}

- (void)respondToPhysicalInputs {
	if (mState == WhirlpoolStateDead)
		return;
	
	for (Actor *actor in mVictims) {
		if (actor.markedForRemoval == YES)
			continue;
		if ([actor isKindOfClass:[NpcShip class]]) {
			NpcShip *ship = (NpcShip *)actor;
			
			if (ship.docking == NO) {
				ship.deathBitmap = DEATH_BITMAP_WHIRLPOOL;
				[ship sink];
				[ship shrinkOverTime:1];
                
                if ([ship isKindOfClass:[NavyShip class]]) {
                    ++mRoyalFlushes;
                    
                    if (mRoyalFlushes == 3)
                        [mScene.achievementManager grantRoyalFlushAchievement];
                }
			}
		} else if ([actor isKindOfClass:[PowderKegActor class]]) {
			PowderKegActor *keg = (PowderKegActor *)actor;
			[keg detonate];
		} else if ([actor isKindOfClass:[NetActor class]]) {
			NetActor *net = (NetActor *)actor;
			
			if (net.despawning == NO)
				[net despawnOverTime:VOODOO_DESPAWN_DURATION];
		} else if ([actor isKindOfClass:[OverboardActor class]]) {
			OverboardActor *person = (OverboardActor *)actor;
            person.deathBitmap = DEATH_BITMAP_WHIRLPOOL;
            [person environmentalDeath];
		} else {
            [mScene removeActor:actor];
		}
	}
    
	[mVictims removeAllObjects];
		
	for (Actor *actor in mContacts) {
		float suckFactor = mSuckFactor, swirlFactor = mSwirlFactor;
		
		if (actor.markedForRemoval == YES)
			continue;
		if ([actor isKindOfClass:[NpcShip class]]) {
			NpcShip *ship = (NpcShip *)actor;
			
			if (ship.inWhirlpoolVortex == NO)
				ship.inWhirlpoolVortex = YES;
		} else if ([actor isKindOfClass:[OverboardActor class]]) {
            OverboardActor *person = (OverboardActor *)actor;
            
            if (person.isPlayer)
                continue;
			swirlFactor *= 1.25f;
		} else if ([actor isKindOfClass:[BrandySlickActor class]]) {
			BrandySlickActor *brandySlick = (BrandySlickActor *)actor;
			
			if (brandySlick.despawning == NO)
				[brandySlick despawnOverTime:VOODOO_DESPAWN_DURATION / 2];
			continue;
		} else if ([actor isKindOfClass:[NetActor class]]) {
			NetActor *net = (NetActor *)actor;
			[net beginShrinking];
			net.body->ApplyTorque(-2000 * net.netScale);
		} else if ([actor isKindOfClass:[PoolActor class]]) {
			PoolActor *poolActor = (PoolActor *)actor;
			
			if (poolActor.despawning == NO)
				[poolActor despawnOverTime:VOODOO_DESPAWN_DURATION / 2];
		}
        
		[self applyVortexForceToBody:actor.body suckFactor:suckFactor swirlFactor:swirlFactor];
	}
}

- (BOOL)ignoresContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
    return ([other isKindOfClass:[TempestActor class]]);
}

- (void)beginContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
    if ([self ignoresContact:other fixtureSelf:fixtureSelf fixtureOther:fixtureOther contact:contact])
        return;
    if (other.isPreparingForNewGame)
        return;
    
    if (other.isSensor == NO || [other isKindOfClass:[OverboardActor class]] || [other isKindOfClass:[PowderKegActor class]]) {
		if (fixtureSelf == mEye)
			[mVictims addObject:other];
	} else if ([other isKindOfClass:[NetActor class]]) {
		NetActor *net = (NetActor *)other;
		
		if (fixtureSelf == mEye && fixtureOther == net.centerFixture)
			[mVictims addObject:other];
	}
    
    [super beginContact:other fixtureSelf:fixtureSelf fixtureOther:fixtureOther contact:contact];
}

- (void)endContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
    if ([self ignoresContact:other fixtureSelf:fixtureSelf fixtureOther:fixtureOther contact:contact])
        return;
    
    [super endContact:other fixtureSelf:fixtureSelf fixtureOther:fixtureOther contact:contact];
    
    if (mRemovedContact) {
        if ([other isKindOfClass:[NpcShip class]]) {
            NpcShip *ship = (NpcShip *)other;
            ship.inWhirlpoolVortex = NO;
        } else if ([other isKindOfClass:[NetActor class]]) {
            NetActor *net = (NetActor *)other;
            [net stopShrinking];
        }
    }	
}

- (void)prepareForNewGame {
    if (mPreparingForNewGame)
        return;
    mPreparingForNewGame = YES;
    [self despawnOverTime:mNewGamePreparationDuration];
}

- (void)zeroOutFixtures {
	[super zeroOutFixtures];
	
	mPool = 0;
	mEye = 0;
}

- (void)dealloc {
	if (mState != WhirlpoolStateDying && mState != WhirlpoolStateDead)
		[mScene.audioPlayer stopEaseOutSoundWithKey:@"Whirlpool"];
	[mWater release]; mWater = nil;
	[mCostume release]; mCostume = nil;
	[mVictims release]; mVictims = nil;
	[super dealloc];
}

@end
