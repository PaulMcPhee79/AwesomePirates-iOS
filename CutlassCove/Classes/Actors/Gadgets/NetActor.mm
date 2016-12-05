//
//  NetActor.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 14/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NetActor.h"
#import "ActorFactory.h"
#import "NpcShip.h"
#import "MerchantShip.h"
#import "WaterFire.h"
#import "VertexAnimator.h"
#import "AchievementManager.h"
#import "GameController.h"
#import "Globals.h"

const float kSpawnDuration = 3.0f;
const float kNetDragFactor = 0.25f;
const int kNetFlameCount = 25;

@interface NetActor ()

- (void)setupActorCostume;
- (void)spawnOverTime:(float)duration;
- (void)onDespawnCompleted:(SPEvent *)event;

@end


@implementation NetActor

@synthesize despawning = mDespawning;
@synthesize netScale = mNetScale;
@synthesize collidableRadiusFactor = mCollidableRadiusFactor;
@synthesize centerFixture = mCenterFixture;
@synthesize areaFixture = mAreaFixture;
@synthesize spawnScale = mSpawnScale;

+ (NetActor *)netActorAtX:(float)x y:(float)y rotation:(float)rotation scale:(float)scale duration:(float)duration {
	ActorFactory *juilliard = [ActorFactory juilliard];
	ActorDef *actorDef = [juilliard createNetDefAtX:x y:y angle:rotation scale:scale];
	NetActor *net = [[[NetActor alloc] initWithActorDef:actorDef scale:scale duration:duration] autorelease];
	delete actorDef;
	actorDef = 0;
	return net;
}

- (id)initWithActorDef:(ActorDef *)def scale:(float)scale duration:(float)duration {
	if (self = [super initWithActorDef:def]) {
		mCategory = CAT_PF_SURFACE;
		mAdvanceable = YES;
		mIgnited = NO;
		mNetScale = scale;
		mDuration = (double)duration;
		mHasShrunk = NO;
		mShrinking = NO;
		mDespawning = NO;
		mCostume = nil;
        
        mZombieNet = NO;
		mZombieCounter = 0;
        
		// Save fixtures
		b2Fixture **fixtures = def->fixtures;
		mCenterFixture = fixtures[0];
		mAreaFixture = fixtures[1];
		mCollidableRadius = mAreaFixture->GetShape()->m_radius;
		mCollidableRadiusFactor = 1;
		mSpawnScale = 0;
		
		[self setupActorCostume];
    }
    return self;
}

- (void)setupActorCostume {
	mCostume = [[SPSprite alloc] init];
	SPImage *image = [SPImage imageWithTexture:[mScene textureByName:@"net"]];
	image.x = -image.width / 2;
	image.y = -image.height / 2;
	[mCostume addChild:image];
	[self addChild:mCostume];
    
    mVAnim = [[VertexAnimator alloc] initWithQuad:image];
    mVAnim.animFactor = 3.0f;
	
	self.x = self.px;
	self.y = self.py;
	mCostume.rotation = -self.b2rotation;
	mSpawnScale = mCostume.scaleX = mCostume.scaleY = 0.0f;
	self.alpha = 0.65f;
	
	double idolDuration = [Idol durationForIdol:[mScene idolForKey:GADGET_SPELL_NET]];
	
	if (mDuration <= VOODOO_DESPAWN_DURATION) {
		// Start in despawn mode
		mSpawnScale = mCostume.scaleX = mCostume.scaleY = mNetScale;
		self.alpha = mDuration / VOODOO_DESPAWN_DURATION;
		[self despawnOverTime:mDuration];
	} else if (SP_IS_FLOAT_EQUAL(idolDuration, mDuration) || mDuration > idolDuration) {
		// Start as new net
		[self spawnOverTime:kSpawnDuration];
	} else if (mDuration > (idolDuration - kSpawnDuration)) {
		// Start spawning
		float spawnFraction = (idolDuration - mDuration) / kSpawnDuration;
		float spawnDuration = (1 - spawnFraction) * kSpawnDuration;
		
		mSpawnScale = mCostume.scaleX = mCostume.scaleY = spawnFraction * mNetScale;
		[self spawnOverTime:spawnDuration];
	} else {
		// Start already spawned
		mSpawnScale = mCostume.scaleX = mCostume.scaleY = mNetScale;
	}
}

- (BOOL)ignited {
	return mIgnited;
}

- (void)ignite {
    mIgnited = YES; // Ignore ignite calls. We no longer ignite.
    
    /*
	if (mIgnited == NO) {
		mIgnited = YES;
		[self despawnOverTime:VOODOO_DESPAWN_DURATION];
	}
     */
}

- (void)advanceTime:(double)time {
    if (mZombieNet == NO) {
        mZombieCounter += time;
        
        if (mZombieCounter > 3.0) {
            mZombieCounter = 0;
            
            if (self.turnID != GCTRL.thisTurn.turnID)
                mZombieNet = YES;
        }
    }
    
	if (self.markedForRemoval)
		return;
    
    if (mDuration > VOODOO_DESPAWN_DURATION) {
        mDuration -= time;
        
        if (mDuration <= VOODOO_DESPAWN_DURATION)
            [self despawnOverTime:VOODOO_DESPAWN_DURATION];
    }
    
	self.x = self.px;
	self.y = self.py;
	mCostume.rotation = -self.b2rotation;
	
	if (mShrinking)
		self.collidableRadiusFactor *= 0.99f;
	mCostume.scaleX = mCostume.scaleY = mSpawnScale * mCollidableRadiusFactor;
    
    [mVAnim advanceTime:time];
}

- (void)spawnOverTime:(float)duration {
	if (mDespawning == YES)
		return;
	[mScene.juggler removeTweensWithTarget:self];
	
	SPTween *tween = [SPTween tweenWithTarget:self time:duration transition:SP_TRANSITION_EASE_OUT];
	[tween animateProperty:@"spawnScale" targetValue:mNetScale];
	[mScene.juggler addObject:tween];
    
    [mVAnim reset];
}

- (void)despawnOverTime:(float)duration {
	if (mDespawning == YES)
		return;
	mDespawning = YES;
	[mScene.juggler removeTweensWithTarget:self];
	[mScene.juggler removeTweensWithTarget:mCostume];
	
	if (duration < 0)
		duration = VOODOO_DESPAWN_DURATION;
	
	SPTween *tween = [SPTween tweenWithTarget:mCostume time:duration];
	[tween animateProperty:@"alpha" targetValue:0.0f];
	[tween addEventListener:@selector(onDespawnCompleted:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
	[mScene.juggler addObject:tween];
}

- (void)onDespawnCompleted:(SPEvent *)event {
	[mScene.juggler removeTweensWithTarget:self];
    
    if (self.turnID == GCTRL.thisTurn.turnID)
        [mScene.objectivesManager progressObjectiveWithEventType:OBJ_TYPE_VOODOO_GADGET_EXPIRED tag:GADGET_SPELL_NET];
	[self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_NET_DESPAWNED]];
	
	[self safeRemove];
}

- (void)setCollidableRadiusFactor:(float)value {
	mCollidableRadiusFactor = value;
	mHasShrunk = YES;
}

- (void)beginShrinking {
	if (mShrinking == NO) {
		//[mScene.juggler removeTweensWithTarget:mCostume]; // This cancels despawn = bad!
		mShrinking = YES;
		mHasShrunk = YES;
	}
}

- (void)stopShrinking {
	mShrinking = NO;
}

- (void)respondToPhysicalInputs {
	if (mBody == 0 || mZombieNet || self.markedForRemoval)
		return;
    uint shipCount = 0;
	float radius = mCollidableRadiusFactor * (mCollidableRadius * mCollidableRadius);
	b2Vec2 selfPos = mBody->GetPosition();
	
	for (Actor *actor in mContacts) {
		if (actor.markedForRemoval == YES)
			continue;
		if ([actor isKindOfClass:[NpcShip class]]) {
            if (mHasShrunk) {
                NpcShip *ship = (NpcShip *)actor;
			
                b2Vec2 otherPos = ship.body->GetPosition();
                b2Vec2 dist = otherPos - selfPos;
			
                if (dist.LengthSquared() > radius) {
                    ship.drag = 1.0f;
                } else {
                    ship.drag = kNetDragFactor;
                    ++shipCount;
                }
            } else {
                ++shipCount;
            }
		}
	}
    
    if (self.isPreparingForNewGame == NO) { // && mZombieNet == NO && self.markedForRemoval == NO // These ones are already checked for on function entry.
        if (shipCount >= 8)
            [mScene.achievementManager grantEntrapmentAchievement];
        [mScene.objectivesManager progressObjectiveWithEventType:OBJ_TYPE_TRAWLING_NET count:shipCount];
    }
}

- (bool)preSolve:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
	bool collidable = true;
	
    if (mZombieNet == NO && self.markedForRemoval == NO) {
        if (mHasShrunk && mBody) {
            // Make sure we abide by our potentially smaller radius
            b2Vec2 otherPos = other.body->GetPosition();
            b2Vec2 selfPos = mBody->GetPosition();
            b2Vec2 dist = otherPos - selfPos;
            
            if (dist.LengthSquared() > mCollidableRadiusFactor * (mCollidableRadius * mCollidableRadius))
                collidable = false;
        }
    } else {
        collidable = false;
    }
	
	return collidable;
}

- (void)beginContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
	if ([other isKindOfClass:[NpcShip class]]) {
		NpcShip *ship = (NpcShip *)other;

        if (mZombieNet == NO && self.markedForRemoval == NO)
            ship.drag = kNetDragFactor;
		[super beginContact:other fixtureSelf:fixtureSelf fixtureOther:fixtureOther contact:contact];
	}
}

- (void)endContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
    [super endContact:other fixtureSelf:fixtureSelf fixtureOther:fixtureOther contact:contact];
    
    if (mRemovedContact && mZombieNet == NO && self.markedForRemoval == NO) {
        if ([other isKindOfClass:[NpcShip class]]) {
            NpcShip *ship = (NpcShip *)other;
			ship.drag = 1.0f;
        }
    }
}

- (void)prepareForNewGame {
    if (mPreparingForNewGame)
        return;
    mPreparingForNewGame = YES;
    [self despawnOverTime:mNewGamePreparationDuration];
}

- (void)safeRemove {
    for (Actor *actor in mContacts) {
		if (actor.markedForRemoval == YES)
			continue;
		if ([actor isKindOfClass:[NpcShip class]]) {
            NpcShip *ship = (NpcShip *)actor;
			ship.drag = 1.0f;
        }
    }
    
    [super safeRemove];
}

- (void)zeroOutFixtures {
	[super zeroOutFixtures];
	
	mCenterFixture = 0;
	mAreaFixture = 0;
}

- (void)dealloc {
	[mScene.juggler removeTweensWithTarget:mCostume];
    [mVAnim release]; mVAnim = nil;
	[mCostume release]; mCostume = nil;
	[super dealloc];
}

@end
