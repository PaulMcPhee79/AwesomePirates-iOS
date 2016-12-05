//
//  PoolActor.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 12/07/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "PoolActor.h"
#import "PoolActorCache.h"
#import "VertexAnimator.h"
#import "NpcShip.h"
#import "MerchantShip.h"
#import "OverboardActor.h"
#import "PowderKegActor.h"
#import "BrandySlickActor.h"
#import "Globals.h"

const float kSpawnDuration = 2.0f;
const float kSpawnedAlpha = 0.7f;
const float kSpawnedScale = 1.5f;

@interface PoolActor ()

- (void)setupActorCostume;
- (void)setState:(PoolActorState)state;
- (void)resetVertexAnimators;
- (void)spawnOverTime:(float)duration;
- (void)spawnCompleted;
- (void)despawnCompleted;
- (void)onSpawnCompleted:(SPEvent *)event ;
- (void)onDespawnCompleted:(SPEvent *)event;
- (BOOL)ignoresContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact;

@end


@implementation PoolActor

@synthesize durationRemaining = mDurationRemaining;
@dynamic despawning,fullDuration,bitmapID,deathBitmap,poolTextureName,resourcesKey;

+ (float)spawnDuration {
	return kSpawnDuration;
}

+ (float)despawnDuration {
    return VOODOO_DESPAWN_DURATION;
}

+ (float)spawnedAlpha {
	return kSpawnedAlpha;
}

+ (float)spawnedScale {
	return kSpawnedScale;
}

+ (int)numPoolRipples {
	return ((RESM.isLowPerformance) ? 1 : kMaxPoolActorRipples);
}

- (id)initWithActorDef:(ActorDef *)def duration:(float)duration {
	if (self = [super initWithActorDef:def]) {
		mCategory = CAT_PF_WAVES;
		mAdvanceable = YES;
		mState = PoolActorStateIdle;
		mDuration = duration;
		mDurationRemaining = duration;
		mRipples = nil;
		mResources = nil;
        for (int i = 0; i < kMaxPoolActorRipples; ++i)
            mVAnim[i] = nil;
		[self checkoutPooledResources];
		[self setupActorCostume];
    }
    return self;
}

- (double)fullDuration {
	return 0;
}

- (uint)bitmapID {
	return 0;
}

- (uint)deathBitmap {
	return 0;
}

- (NSString *)poolTextureName {
	return nil;
}

- (NSString *)resourcesKey {
	return nil;
}

- (void)setupActorCostume {
    if (mCostume == nil)
        mCostume = [[SPSprite alloc] init];
    mCostume.scaleX = mCostume.scaleY = 0.01f;
	mCostume.alpha = 0.01f;
    [self addChild:mCostume];
    
	if (mRipples == nil) {
		mRipples = [[NSMutableArray alloc] initWithCapacity:[PoolActor numPoolRipples]];
		
		SPTexture *poolTexture = [mScene textureByName:self.poolTextureName cacheGroup:TM_CACHE_VOODOO];
		
		for (int i = 0; i < [PoolActor numPoolRipples]; ++i) {
			SPImage *image = [SPImage imageWithTexture:poolTexture];
			image.x = -image.width / 2;
			image.y = -image.height / 2;
			
			SPSprite *sprite = [SPSprite sprite];
			sprite.scaleX = sprite.scaleY = 0;
			[sprite addChild:image];
			[mRipples addObject:sprite];
			[mCostume addChild:sprite];
            
            // Only one frame for low performance devices
            if (RESM.isLowPerformance)
                break;
		}
	} else {
		for (SPSprite *sprite in mRipples) {
			[mCostume addChild:sprite];
            
            // Only one frame for low performance devices
            if (RESM.isLowPerformance)
                break;
        }
	}
    
    for (int i = 0; i < MIN(mRipples.count, [PoolActor numPoolRipples]); ++i)
    {
        SPSprite *sprite = (SPSprite*)[mRipples objectAtIndex:i];
        if (sprite == nil || sprite.numChildren == 0)
            continue;
        SPDisplayObject *child = [sprite childAtIndex:0];
        if (child && [child isKindOfClass:[SPImage class]])
        {
            SPImage *animatedQuad = (SPImage *)child;
        
            if (mVAnim[i])
                [mVAnim[i] setAnimatedQuad:animatedQuad];
            else {
                mVAnim[i] = [[VertexAnimator alloc] initWithQuad:animatedQuad];
                mVAnim[i].animFactor = 1.75f;
                mVAnim[i].animRate = 3.0f;
            }
        }
    }
	
	self.x = self.px;
	self.y = self.py;
	self.rotation = -self.b2rotation;
	
	if (mDuration <= VOODOO_DESPAWN_DURATION) {
		// Start in despawn mode
		self.scaleX = self.scaleY = kSpawnedScale;
		self.alpha = kSpawnedAlpha * (mDuration / VOODOO_DESPAWN_DURATION);
		[self setState:PoolActorStateSpawned];
		[self despawnOverTime:mDuration];
	} else if (SP_IS_FLOAT_EQUAL(self.fullDuration, mDuration) || mDuration > self.fullDuration) {
		// Start as new pool
		[self setState:PoolActorStateIdle];
		[self spawnOverTime:kSpawnDuration];
	} else if (mDuration > (self.fullDuration - kSpawnDuration)) {
		// Start spawning
		float spawnFraction = (self.fullDuration - mDuration) / kSpawnDuration;
		float spawnDuration = (1 - spawnFraction) * kSpawnDuration;
		
		self.alpha = kSpawnedAlpha * spawnFraction;
		self.scaleX = self.scaleY = kSpawnedScale * spawnFraction;
		[self setState:PoolActorStateIdle];
		[self spawnOverTime:spawnDuration];
	} else {
		// Start already spawned
		self.alpha = kSpawnedAlpha;
		self.scaleX = self.scaleY = kSpawnedScale;
		[self setState:PoolActorStateSpawned];
	}
	
	[self startPoolAnimation];
}

- (void)setState:(PoolActorState)state {
    if (state < mState)
        return;
    
	switch (state) {
		case PoolActorStateIdle:
			break;
		case PoolActorStateSpawning:
			break;
		case PoolActorStateSpawned:
			break;
		case PoolActorStateDespawning:
			break;
		case PoolActorStateDespawned:
        {
            [self resetVertexAnimators];
            for (int i = 0; i < [PoolActor numPoolRipples]; ++i)
            {
                if(mVAnim[i])
                    [mVAnim[i] setAnimatedQuad:nil];
            }
            
            [mScene removeActor:self];
        }
			break;
		default:
			break;
	}
	mState = state;
}

- (void)resetVertexAnimators {
    for (int i = 0; i < [PoolActor numPoolRipples]; ++i)
    {
        if(mVAnim[i])
            [mVAnim[i] reset];
    }
}

- (void)startPoolAnimation {
	[self stopPoolAnimation];
	
	float delay = 0;
	
    if (RESM.isLowPerformance) {
        if (mRipples.count > 0) {
            SPSprite *sprite = (SPSprite *)[mRipples objectAtIndex:0];
            sprite.scaleX = sprite.scaleY = 0;
            sprite.alpha = 1;
            
            if (![mResources startTweenForKey:RESOURCE_KEY_POOL_RIPPLE_TWEEN_SCALE]) {
                SPTween *tween = [SPTween tweenWithTarget:sprite time:0.8f * mRipples.count];
                [tween animateProperty:@"scaleX" targetValue:0.75f];
                [tween animateProperty:@"scaleY" targetValue:0.75f];
                [mScene.juggler addObject:tween];
            }
        }
    } else {
        uint index = 0;
        
        for (SPSprite *sprite in mRipples) {
            sprite.scaleX = sprite.scaleY = 0;
            sprite.alpha = 1;
            
            if (![mResources startTweenForKey:RESOURCE_KEY_POOL_RIPPLE_TWEEN_SCALE+index]) {
                SPTween *tween = [SPTween tweenWithTarget:sprite time:0.8f * mRipples.count];
                [tween animateProperty:@"scaleX" targetValue:1.2f];
                [tween animateProperty:@"scaleY" targetValue:1.2f];
                tween.delay = delay;
                tween.loop = SPLoopTypeRepeat;
                [mScene.juggler addObject:tween];
            }
            
            if (![mResources startTweenForKey:RESOURCE_KEY_POOL_RIPPLE_TWEEN_ALPHA+index]) {
                SPTween *tween = [SPTween tweenWithTarget:sprite time:0.8f * mRipples.count transition:SP_TRANSITION_EASE_IN_LINEAR];
                [tween animateProperty:@"alpha" targetValue:0];
                tween.delay = delay;
                tween.loop = SPLoopTypeRepeat;
                [mScene.juggler addObject:tween];
                delay += tween.time / mRipples.count;
            }
            
            ++index;
        }
    }
    
    [self resetVertexAnimators];
}

- (void)stopPoolAnimation {
	for (SPSprite *sprite in mRipples)
		[mScene.juggler removeTweensWithTarget:sprite];
}

- (void)advanceTime:(double)time {
	if (self.markedForRemoval == YES)
		return;
    
    if (mDurationRemaining > VOODOO_DESPAWN_DURATION) {
        mDurationRemaining -= time;
        
        if (mDurationRemaining <= VOODOO_DESPAWN_DURATION)
            [self despawnOverTime:VOODOO_DESPAWN_DURATION];
    } else {
        mDurationRemaining -= time;
        
        if (mDurationRemaining < 0)
            mDurationRemaining = 0;
    }
    
	self.x = self.px;
	self.y = self.py;
	self.rotation = -self.b2rotation;
    
    for (int i = 0; i < [PoolActor numPoolRipples]; ++i)
    {
        if(mVAnim[i])
            [mVAnim[i] advanceTime:time];
    }
}

- (BOOL)despawning {
	return (mState == PoolActorStateDespawning || mState == PoolActorStateDespawned);
}

- (void)spawnOverTime:(float)duration {
	assert(mState == PoolActorStateIdle);
	
    if (SP_IS_FLOAT_EQUAL(duration, kSpawnDuration) == NO || ![mResources startTweenForKey:RESOURCE_KEY_POOL_SPAWN_TWEEN]) {
        SPTween *tween = [SPTween tweenWithTarget:mCostume time:duration];
        [tween animateProperty:@"alpha" targetValue:kSpawnedAlpha];
        [tween animateProperty:@"scaleX" targetValue:kSpawnedScale];
        [tween animateProperty:@"scaleY" targetValue:kSpawnedScale];
        [tween addEventListener:@selector(onSpawnCompleted:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
        [mScene.juggler addObject:tween];
    }
    
	[self setState:PoolActorStateSpawning];
}

- (void)despawnOverTime:(float)duration {
	if (mState != PoolActorStateSpawning && mState != PoolActorStateSpawned)
        return;
	
    if (SP_IS_FLOAT_EQUAL(duration, VOODOO_DESPAWN_DURATION) == NO || ![mResources startTweenForKey:RESOURCE_KEY_POOL_DESPAWN_TWEEN]) {
        // Irregular despawn time indicates we may still be spawning when asked to despawn. Remove possible concurrent tweens.
        [mScene.juggler removeTweensWithTarget:mCostume];
        
        SPTween *tween = [SPTween tweenWithTarget:mCostume time:duration];
        [tween animateProperty:@"alpha" targetValue:0.01f];
        [tween addEventListener:@selector(onDespawnCompleted:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
        [mScene.juggler addObject:tween];
    }
    
    [self setState:PoolActorStateDespawning];
}

- (void)spawnCompleted {
    [self setState:PoolActorStateSpawned];
}

- (void)despawnCompleted {
    [self setState:PoolActorStateDespawned];
}

- (void)onSpawnCompleted:(SPEvent *)event {
	[self spawnCompleted];
}

- (void)onDespawnCompleted:(SPEvent *)event {
	[self despawnCompleted];
}

- (void)sinkNpcShip:(NpcShip *)ship {
    ship.deathBitmap = self.deathBitmap;
    [ship sink];
}

- (void)killOverboardActor:(OverboardActor *)actor {
    actor.deathBitmap = self.deathBitmap;
    [actor environmentalDeath];
}

- (void)respondToPhysicalInputs {
	if (mState == PoolActorStateDespawned || self.isPreparingForNewGame)
		return;
	for (Actor *actor in mContacts) {
		if (actor.markedForRemoval == YES)
			continue;
		
		if ([actor isKindOfClass:[NpcShip class]]) {
			NpcShip *ship = (NpcShip *)actor;
			
			if (ship.docking == NO)
                [self sinkNpcShip:ship];
		} else if ([actor isKindOfClass:[OverboardActor class]]) {
			OverboardActor *person = (OverboardActor *)actor;
			
			if (person.dying == NO)
				[self killOverboardActor:person];
		} else if ([actor isKindOfClass:[PowderKegActor class]]) {
            PowderKegActor *keg = (PowderKegActor *)actor;
            [keg detonate];
        } else if ([actor isKindOfClass:[BrandySlickActor class]]) {
            BrandySlickActor *slick = (BrandySlickActor *)actor;
            [slick ignite];
        }
	}
}

- (BOOL)ignoresContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
    BOOL ignores = NO;
    
    if ([other isKindOfClass:[NpcShip class]]) {
		NpcShip *ship = (NpcShip *)other;
		
		if (fixtureOther != ship.stern)
			ignores = YES;
	} else if ([other isKindOfClass:[OverboardActor class]] == NO && [other isKindOfClass:[PowderKegActor class]] == NO && [other isKindOfClass:[BrandySlickActor class]] == NO) {
		ignores = YES;
	}
    
    return ignores;
}

- (void)beginContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
	if ([self ignoresContact:other fixtureSelf:fixtureSelf fixtureOther:fixtureOther contact:contact])
        return;
    [super beginContact:other fixtureSelf:fixtureSelf fixtureOther:fixtureOther contact:contact];
}

- (void)endContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
    if ([self ignoresContact:other fixtureSelf:fixtureSelf fixtureOther:fixtureOther contact:contact])
        return;
    [super endContact:other fixtureSelf:fixtureSelf fixtureOther:fixtureOther contact:contact];
}

- (void)prepareForNewGame {
    if (mPreparingForNewGame)
        return;
    mPreparingForNewGame = YES;
    [self despawnOverTime:mNewGamePreparationDuration];
}

- (void)resourceEventFiredWithKey:(uint)key type:(NSString *)type target:(NSObject *)target {
    switch (key) {
        case RESOURCE_KEY_POOL_SPAWN_TWEEN:
            [self spawnCompleted];
            break;
        case RESOURCE_KEY_POOL_DESPAWN_TWEEN:
            [self despawnCompleted];
            break;
        default:
            break;
    }
}

- (void)checkoutPooledResources {
	if (mResources == nil)
		mResources = [[[mScene cacheManagerByName:CACHE_POOL_ACTOR] checkoutPoolResourcesForKey:self.resourcesKey] retain];
	if (mResources == nil)
		NSLog(@"_+_+_+_+_+_+_+_+_ MISSED POOL ACTOR CACHE _+_++_+_+_+_+_+_+");
    else {
        mResources.client = self;
        
        if (mRipples == nil)
            mRipples = [(NSMutableArray *)[mResources miscResourceForKey:RESOURCE_KEY_POOL_RIPPLES] retain];
        if (mCostume == nil)
            mCostume = [(SPSprite *)[mResources displayObjectForKey:RESOURCE_KEY_POOL_COSTUME] retain];
    }
}

- (void)checkinPooledResources {
    if (mResources) {
        [[mScene cacheManagerByName:CACHE_POOL_ACTOR] checkinPoolResources:mResources];
        [mResources release]; mResources = nil;
    }
}

- (void)dealloc {
    [mScene.juggler removeTweensWithTarget:mCostume];
	[self stopPoolAnimation];
	[self checkinPooledResources];
    for (int i = 0; i < [PoolActor numPoolRipples]; ++i)
    {
        [mVAnim[i] release];
        mVAnim[i] = nil;
    }
	[mRipples release]; mRipples = nil;
    [mCostume release]; mCostume = nil;
	[super dealloc];
}

@end
