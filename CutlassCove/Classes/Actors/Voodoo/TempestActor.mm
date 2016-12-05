//
//  TempestActor.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 14/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TempestActor.h"
#import "TempestCache.h"
#import "ActorFactory.h"
#import "ShipActor.h"
#import "NpcShip.h"
#import "MerchantShip.h"
#import "OverboardActor.h"
#import "PowderKegActor.h"
#import "AchievementManager.h"
#import "RingBuffer.h"
#import "Globals.h"

typedef enum {
	TempestStateAlive = 0,
	TempestStateDead
} TempestState;

const int kTempestDebrisBufferSize = 8;

@interface TempestActor ()

- (void)setState:(int)state;
- (void)setupActorCostume;
- (void)onDespawnCompleted:(SPEvent *)event;
- (void)showShipDebris;
- (void)debrisComplete:(SPSprite *)debris;
- (void)onDebrisComplete:(SPEvent *)event;
- (BOOL)ignoresContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact;

@end


@implementation TempestActor

@synthesize target = mTarget;

+ (int)debrisBufferSize {
    return kTempestDebrisBufferSize;
}

+ (TempestActor *)tempestActorAtX:(float)x y:(float)y rotation:(float)rotation duration:(float)duration {
	ActorFactory *juilliard = [ActorFactory juilliard];
	ActorDef *actorDef = [juilliard createTempestDefAtX:x y:y angle:0.0f];
	TempestActor *tempest = [[[TempestActor alloc] initWithActorDef:actorDef duration:duration] autorelease];
	delete actorDef;
	actorDef = 0;
	return tempest;
}

- (id)initWithActorDef:(ActorDef *)def duration:(float)duration {
	if (self = [super initWithActorDef:def]) {
		mCategory = CAT_PF_CLOUD_SHADOWS;
		mAdvanceable = YES;
		mDuration = (double)duration;
		mTarget = nil;
		mCostume = nil;
		mSwirl = nil;
		mDebris = nil;
		mSplash = nil;
		mDebrisCache = nil;
		mDebrisBuffer = nil;
        mResources = nil;
        [self checkoutPooledResources];
		[self setupActorCostume];
		[self setState:TempestStateAlive];
    }
    return self;
}

- (void)setupActorCostume {
	assert(mCostume == nil);
	mCostume = [[SPSprite alloc] init];
	mCostume.x = -55;
	mCostume.y = -55;
    
    SPSprite *costumeScaler = [SPSprite sprite];
    costumeScaler.scaleX = costumeScaler.scaleY = 1.35f;
	[costumeScaler addChild:mCostume];
    [self addChild:costumeScaler];
	
	// Splash
	mSplash = [[SPMovieClip alloc] initWithFrames:[mScene texturesStartingWith:@"tempest-splash_"] fps:8];
	mSplash.x = 61;
	mSplash.y = 65;
	[mScene.juggler addObject:mSplash];
	[mCostume addChild:mSplash];

	// Stem
	mStem = [[SPImage alloc] initWithTexture:[mScene textureByName:@"tempest-stem"]];
	mStem.x = 26;
	mStem.y = 42;
	[mCostume addChild:mStem];
	
	// Swirl
	mSwirl = [[SPSprite alloc] init];
	SPImage *swirlImage = [SPImage imageWithTexture:[mScene textureByName:@"tempest-swirl"]];
	swirlImage.x = -swirlImage.width / 2;
	swirlImage.y = -swirlImage.height / 2;
	mSwirl.x = swirlImage.width / 2;
	mSwirl.y = swirlImage.height / 2;
	[mSwirl addChild:swirlImage];
	[mCostume addChild:mSwirl];
	
	// Debris
    mDebrisBuffer = [[RingBuffer alloc] initWithCapacity:kTempestDebrisBufferSize];
    mDebris = [[SPSprite alloc] init];
	[mCostume addChild:mDebris];
    
    if (mDebrisCache == nil) {
        SPTexture *debrisTexture = [mScene textureByName:@"tempest-debris"];
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:kTempestDebrisBufferSize];
        
        for (int i = 0; i < kTempestDebrisBufferSize; ++i) {
            SPSprite *sprite = [SPSprite sprite];
            SPImage *image = [SPImage imageWithTexture:debrisTexture];
            image.x = -image.width / 2;
            image.y = -image.height / 2;
            sprite.x = image.width / 2;
            sprite.y = image.height / 2;
            [sprite addChild:image];
            [array addObject:sprite];
        }
        
        mDebrisCache = [[NSArray alloc] initWithArray:array];
    }
    
	for (SPSprite *sprite in mDebrisCache)
        [mDebrisBuffer addItem:sprite];
	
	// Clouds
	mClouds = [[SPSprite alloc] init];
	SPImage *cloudsImage = [SPImage imageWithTexture:[mScene textureByName:@"tempest-clouds"]];
	cloudsImage.x = -cloudsImage.width / 2;
	cloudsImage.y = -cloudsImage.height / 2;
	mClouds.x = cloudsImage.width / 2;
	mClouds.y = cloudsImage.height / 2;
	mClouds.alpha = 0.6f;
	[mClouds addChild:cloudsImage];
	[mCostume addChild:mClouds];
	
	self.x = self.px;
	self.y = self.py;
	
	if (mDuration <= VOODOO_DESPAWN_DURATION) {
		// Start in despawn mode
		self.alpha = (float)mDuration / VOODOO_DESPAWN_DURATION;
		[self despawnOverTime:mDuration];
	}
    
	[mScene.audioPlayer playSoundWithKey:@"GhostlyTempest" volume:1 easeInDuration:3];
}

- (void)setState:(int)state {
    if (state < mState)
        return;
    
	switch (state) {
		case TempestStateAlive:
			break;
		case TempestStateDead:
			self.target = nil;
			break;
	}
	mState = state;
}

- (void)setTarget:(ShipActor *)ship {
	if (mTarget == ship)
		return;
	if (mTarget != nil) {
		[mTarget removePursuer:self];
		[mTarget release]; mTarget = nil;
	}
	
	if (ship != nil) {
		mTarget = [ship retain];
		[mTarget addPursuer:self];
	}
}

- (void)flip:(BOOL)enable {
    if (enable) {
        self.scaleX = -1;
        mCostume.x = -50;
        mCostume.y = -52;
    } else {
        self.scaleX = 1;
        mCostume.x = -55;
        mCostume.y = -55;
    }
}

- (void)pursueeDestroyed:(ShipActor *)pursuee {
    assert(pursuee == self.target);
    self.target = nil;
}

- (void)showShipDebris {
    uint index = mDebrisBuffer.indexOfNextItem;
	SPSprite *sprite = mDebrisBuffer.nextItem;
	
	if (sprite == nil)
		return;
	[mScene.juggler removeTweensWithTarget:sprite];
	sprite.alpha = 0;
	[mDebris addChild:sprite];
	
    if (![mResources startTweenForKey:RESOURCE_KEY_TEMPEST_DEBRIS_TWEEN_IN+index]) {
        SPTween *fadeIn = [SPTween tweenWithTarget:sprite time:1.0f];
        [fadeIn animateProperty:@"alpha" targetValue:1];
        [mScene.juggler addObject:fadeIn];
        
        SPTween *fadeOut = [SPTween tweenWithTarget:sprite time:1.0f];
        [fadeOut animateProperty:@"alpha" targetValue:0];
        fadeOut.delay = fadeIn.time;
        [fadeOut addEventListener:@selector(onDebrisComplete:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
        [mScene.juggler addObject:fadeOut];
    } else {
        [mResources startTweenForKey:RESOURCE_KEY_TEMPEST_DEBRIS_TWEEN_OUT+index];
    }
}

- (void)debrisComplete:(SPSprite *)debris {
    if (debris)
        [mDebris removeChild:debris];
}

- (void)onDebrisComplete:(SPEvent *)event {
	SPTween *tween = (SPTween *)event.currentTarget;
	SPSprite *sprite = (SPSprite *)tween.target;
	[self debrisComplete:sprite];
}

- (void)despawnOverTime:(float)duration {
    if (mState != TempestStateAlive)
        return;
    
	SPTween *tween = [SPTween tweenWithTarget:mStem time:duration];
	[tween animateProperty:@"alpha" targetValue:0.0f];
	[mScene.juggler addObject:tween];
	
	tween = [SPTween tweenWithTarget:self time:duration];
	[tween animateProperty:@"alpha" targetValue:0.0f];
	[tween addEventListener:@selector(onDespawnCompleted:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
	[mScene.juggler addObject:tween];
	[mScene.audioPlayer stopSoundWithKey:@"GhostlyTempest" easeOutDuration:duration];
	[self setState:TempestStateDead];
}

- (void)onDespawnCompleted:(SPEvent *)event {
    self.target = nil;
    
    if (self.turnID == GCTRL.thisTurn.turnID)
        [mScene.objectivesManager progressObjectiveWithEventType:OBJ_TYPE_VOODOO_GADGET_EXPIRED tag:VOODOO_SPELL_TEMPEST];
	[mScene.juggler removeObject:mSplash];
	[mScene removeActor:self];
}

- (void)advanceTime:(double)time {
	if (mBody == 0)
		return;
    
    if (mDuration > VOODOO_DESPAWN_DURATION) {
        mDuration -= time;
        
        if (mDuration <= VOODOO_DESPAWN_DURATION)
            [self despawnOverTime:VOODOO_DESPAWN_DURATION];
    }
    
	self.x = self.px;
	self.y = self.py;
	mSwirl.rotation -= time * 12.0f;
	mClouds.rotation -= time * 3.0f;
	
	for (SPSprite *sprite in mDebrisCache)
		sprite.rotation -= time * 12.0f;
	
	if (mState == TempestStateDead)
		return;
	if (mTarget == nil) {
        [mScene requestTargetForPursuer:(NSObject *)self];
		
		// Slow to a crawl while waiting for new target
		b2Vec2 velocity(-2.0f, -2.0f);
		mBody->SetLinearVelocity(velocity);
		return;
	}
	
	b2Vec2 dest = mTarget.body->GetPosition() - mBody->GetPosition();
	dest.Normalize();
	
	b2Vec2 velocity = 8.0f * dest;
	mBody->SetLinearVelocity(velocity);
}

- (void)respondToPhysicalInputs {
	if (mState == TempestStateDead)
		return;
	for (Actor *actor in mContacts) {
		if (actor.markedForRemoval == YES)
			continue;
		if ([actor isKindOfClass:[NpcShip class]]) {
			NpcShip *ship = (NpcShip *)actor;
			
			if (ship.docking == NO) {
				ship.deathBitmap = DEATH_BITMAP_GHOSTLY_TEMPEST;
				[ship sink];
				[self showShipDebris];
			}
			
			if (ship == mTarget)
				self.target = nil;
		} else if ([actor isKindOfClass:[OverboardActor class]]) {
			OverboardActor *person = (OverboardActor *)actor;
			
			if (person.dying == NO) {
                person.deathBitmap = DEATH_BITMAP_GHOSTLY_TEMPEST;
				[person environmentalDeath];
                [mScene.achievementManager grantNoPlaceLikeHomeAchievement];
			}
		} else if ([actor isKindOfClass:[PowderKegActor class]]) {
			PowderKegActor *keg = (PowderKegActor *)actor;
			[keg detonate];
		}
	}
}

- (BOOL)ignoresContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
    return NO;
    
    BOOL ignores = NO;
    
    if ([other isKindOfClass:[NpcShip class]]) {
		NpcShip *ship = (NpcShip *)other;
		
		if (fixtureOther == ship.feeler) {
			ignores = YES;
		} else if ([other isKindOfClass:[MerchantShip class]]) {
			MerchantShip *merchantShip = (MerchantShip *)other;
			
			if (fixtureOther == merchantShip.defender)
				ignores = YES;
		}
	}
    
    return ignores;
}

- (void)beginContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
	if ([self ignoresContact:other fixtureSelf:fixtureSelf fixtureOther:fixtureOther contact:contact])
        return;
    if (other.isPreparingForNewGame)
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
        case RESOURCE_KEY_TEMPEST_DEBRIS_TWEEN_IN:
            break;
        case RESOURCE_KEY_TEMPEST_DEBRIS_TWEEN_OUT:
        default:
            if (key >= RESOURCE_KEY_TEMPEST_DEBRIS_TWEEN_OUT) {
                SPTween *tween = (SPTween *)target;
                SPSprite *debris = (SPSprite *)tween.target;
                [self debrisComplete:debris];
            }
            break;
    }
}

- (void)checkoutPooledResources {
	if (mResources == nil)
		mResources = [[[mScene cacheManagerByName:CACHE_TEMPEST] checkoutPoolResources] retain];
	if (mResources == nil)
		NSLog(@"_+_+_+_+_+_+_+_+_ MISSED TEMPEST CACHE _+_++_+_+_+_+_+_+");
    else {
        mResources.client = self;
        
        if (mDebrisCache == nil)
            mDebrisCache = [(NSArray *)[mResources miscResourceForKey:RESOURCE_KEY_TEMPEST_DEBRIS] retain];
    }
}

- (void)checkinPooledResources {
    if (mResources) {
        [[mScene cacheManagerByName:CACHE_TEMPEST] checkinPoolResources:mResources];
        [mResources release]; mResources = nil;
    }
}

- (void)cleanup {
	[super cleanup];
	
	if (mTarget != nil) {
		[mTarget removePursuer:self];
		[mTarget release]; mTarget = nil;
	}
}

- (void)dealloc {
	if (mState != TempestStateDead)
		[mScene.audioPlayer stopEaseOutSoundWithKey:@"GhostlyTempest"];
	if (mDebrisCache) {
		for (SPSprite *sprite in mDebrisCache)
			[mScene.juggler removeTweensWithTarget:sprite];
	}
	
	if (mSplash)
		[mScene.juggler removeObject:mSplash];
	if (mStem)
		[mScene.juggler removeTweensWithTarget:mStem];
	
    [self checkinPooledResources];
    
	[mDebris release]; mDebris = nil;
	[mDebrisCache release]; mDebrisCache = nil;
	[mDebrisBuffer release]; mDebrisBuffer = nil;
	[mClouds release]; mClouds = nil;
	[mSwirl release]; mSwirl = nil;
	[mStem release]; mStem = nil;
	[mSplash release]; mSplash = nil;
	[mCostume release]; mCostume = nil;
	[mTarget release]; mTarget = nil;
	[super dealloc];
}

@end
