//
//  BrandySlickActor.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 14/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BrandySlickActor.h"
#import "ActorFactory.h"
#import "WaterFire.h"
#import "NpcShip.h"
#import "MerchantShip.h"
#import "OverboardActor.h"
#import "PowderKegActor.h"
#import "VertexAnimator.h"
#import "AchievementManager.h"
#import "GameSettings.h"
#import "GameController.h"
#import "Globals.h"

typedef enum {
	BrandySlickStateSpawning = 0,
	BrandySlickStateSpawned,
	BrandySlickStateDespawning,
	BrandySlickStateDespawned
} BrandySlickState;

const float kSpawnDuration = 3.0f;
const int kBrandyFlameCount = 21;

@interface BrandySlickActor ()

- (void)setupActorCostume;
- (void)setState:(int)state;
- (void)spawnOverTime:(float)duration;
- (void)onDespawnCompleted:(SPEvent *)event;

@end


@implementation BrandySlickActor

@dynamic despawning;

+ (BrandySlickActor *)brandySlickActorAtX:(float)x y:(float)y rotation:(float)rotation scale:(float)scale duration:(float)duration {
	ActorFactory *juilliard = [ActorFactory juilliard];
	ActorDef *actorDef = [juilliard createBrandySlickDefAtX:x y:y angle:rotation scale:scale];
	BrandySlickActor *slick = [[[BrandySlickActor alloc] initWithActorDef:actorDef scale:scale duration:duration] autorelease];
	delete actorDef;
	actorDef = 0;
	return slick;
}

- (id)initWithActorDef:(ActorDef *)def scale:(float)scale duration:(float)duration {
	if (self = [super initWithActorDef:def]) {
		mCategory = CAT_PF_SEA;
        mAdvanceable = YES;
		mState = BrandySlickStateSpawning;
		mBrandyScale = scale;
		mDuration = (double)duration;
		mPrisonersFried = 0;
		mSlick = nil;
		mFire = nil;
        
        mZombieSlick = NO;
        mZombieCounter = 0;
        
		[self setupActorCostume];
    }
    return self;
}

- (void)setupActorCostume {
	SPImage *image = [SPImage imageWithTexture:[mScene textureByName:@"brandy-slick"]];
	image.x = -image.width / 2;
	image.y = -image.height / 2;
	mSlick = [[SPSprite alloc] init];
	[mSlick addChild:image];
	[self addChild:mSlick];
    
    mVAnim = [[VertexAnimator alloc] initWithQuad:image];
    mVAnim.animFactor = 1.75f;
	
	int coords[] = { 2,5,9,0,10,8,17,3,24,9,32,8,38,2,45,0,54,1,60,8,63,0,68,10,73,4,79,10,80,0,87,4,94,8,95,0,102,7,106,1,110,10 };
	mFire = [[WaterFire alloc] initWithCategory:CAT_PF_WAVES flameCoords:coords numFlames:kBrandyFlameCount];
	[mScene addProp:mFire];
	
	self.x = mFire.x = self.px;
	self.y = mFire.y = self.py;
	mSlick.rotation = -self.b2rotation - PI_HALF;
    mFire.rotation = -self.b2rotation - PI_HALF;
	mSlick.scaleX = mSlick.scaleY = mFire.scaleX = mFire.scaleY = 0.0f;
	
	double idolDuration = [Idol durationForIdol:[mScene idolForKey:GADGET_SPELL_BRANDY_SLICK]];
	
	if (mDuration <= VOODOO_DESPAWN_DURATION) {
		// Start in despawn mode
		[self setState:BrandySlickStateDespawning];
		mSlick.scaleX = mSlick.scaleY = mFire.scaleX = mFire.scaleY = mBrandyScale;
		mSlick.alpha = mFire.alpha = mDuration / VOODOO_DESPAWN_DURATION;
		[self despawnOverTime:mDuration];
	} else if (SP_IS_FLOAT_EQUAL(idolDuration, mDuration) || mDuration > idolDuration) {
		// Start as new brandy slick
		[self spawnOverTime:kSpawnDuration];
	} else if (mDuration > (idolDuration - kSpawnDuration)) {
		// Start spawning
		[self setState:BrandySlickStateSpawning];
		
		float spawnFraction = (idolDuration - mDuration) / kSpawnDuration;
		float spawnDuration = (1 - spawnFraction) * kSpawnDuration;
		mSlick.scaleX = mSlick.scaleY = mFire.scaleX = mFire.scaleY = spawnFraction * mBrandyScale;
		[self spawnOverTime:spawnDuration];
	} else {
		// Start already spawned
		[self setState:BrandySlickStateSpawned];
		mSlick.scaleX = mSlick.scaleY = mFire.scaleX = mFire.scaleY = mBrandyScale;
	}
}

- (void)setState:(int)state {
    if (state < mState)
        return;
    
	switch (state) {
		case BrandySlickStateSpawning:
            [mVAnim reset];
			break;
		case BrandySlickStateSpawned:
			break;
		case BrandySlickStateDespawning:
			break;
		case BrandySlickStateDespawned:
            [mScene hideHintByName:GAME_SETTINGS_KEY_BRANDY_SLICK_TIPS];
			break;
		default:
			break;
	}
	mState = state;
}

- (void)advanceTime:(double)time {
    if (mZombieSlick == NO) {
        mZombieCounter += time;
        
        if (mZombieCounter > 3.0) {
            mZombieCounter = 0;
            
            if (self.turnID != GCTRL.thisTurn.turnID)
                mZombieSlick = YES;
        }
    }
    
    if (self.markedForRemoval)
		return;
    
    if (mDuration > VOODOO_DESPAWN_DURATION) {
        mDuration -= time;
        
        if (mDuration <= VOODOO_DESPAWN_DURATION)
            [self despawnOverTime:VOODOO_DESPAWN_DURATION];
    }
    
    if (!self.ignited)
        [mVAnim advanceTime:time];
}

- (BOOL)despawning {
	return (mState == BrandySlickStateDespawning || mState == BrandySlickStateDespawned);
}

- (BOOL)ignited {
	return mFire.ignited;
}

- (void)spawnOverTime:(float)duration {
	if (mState != BrandySlickStateSpawning)
		return;
	SPTween *tween = [SPTween tweenWithTarget:mSlick time:duration transition:SP_TRANSITION_EASE_OUT];
	[tween animateProperty:@"scaleX" targetValue:mBrandyScale];
	[tween animateProperty:@"scaleY" targetValue:mBrandyScale];
	[mScene.juggler addObject:tween];
	
	tween = [SPTween tweenWithTarget:mFire time:duration transition:SP_TRANSITION_EASE_OUT];
	[tween animateProperty:@"scaleX" targetValue:mBrandyScale];
	[tween animateProperty:@"scaleY" targetValue:mBrandyScale];
	[mScene.juggler addObject:tween];
}

- (void)ignite {
	[mFire ignite];
    [mVAnim reset];
    
    GameController *gc = GCTRL;
    
    if ([gc.gameSettings settingForKey:GAME_SETTINGS_KEY_BRANDY_SLICK_TIPS] == NO)
        [gc.gameSettings setSettingForKey:GAME_SETTINGS_KEY_BRANDY_SLICK_TIPS value:YES];
    [mScene hideHintByName:GAME_SETTINGS_KEY_BRANDY_SLICK_TIPS];
}

- (void)despawnOverTime:(float)duration {
	if (self.despawning == YES)
		return;
	[self setState:BrandySlickStateDespawning];
	[mScene.juggler removeTweensWithTarget:mFire];
	[mScene.juggler removeTweensWithTarget:mSlick];
	
	if (duration < 0)
		duration = VOODOO_DESPAWN_DURATION;
	
	[mFire extinguishOverTime:duration];
	
	SPTween *tween = [SPTween tweenWithTarget:mSlick time:duration];
	[tween animateProperty:@"alpha" targetValue:0.0f];
	[tween addEventListener:@selector(onDespawnCompleted:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
	[mScene.juggler addObject:tween];
}

- (void)onDespawnCompleted:(SPEvent *)event {
	assert(mState == BrandySlickStateDespawning);
	[self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_BRANDY_SLICK_DESPAWNED]];
	[self safeRemove];
	
	[mScene removeProp:mFire];
    
    if (self.turnID == GCTRL.thisTurn.turnID)
        [mScene.objectivesManager progressObjectiveWithEventType:OBJ_TYPE_VOODOO_GADGET_EXPIRED tag:GADGET_SPELL_BRANDY_SLICK];
	[self setState:BrandySlickStateDespawned];
}

- (void)respondToPhysicalInputs {
	if (self.ignited == NO || mZombieSlick)
		return;
	for (Actor *actor in mContacts) {
		if (actor.markedForRemoval == YES)
			continue;

		if ([actor isKindOfClass:[NpcShip class]]) {
			NpcShip *ship = (NpcShip *)actor;
			
			if (ship.docking == NO) {
				ship.deathBitmap = DEATH_BITMAP_BRANDY_SLICK;
				[ship sink];
			}
		} else if ([actor isKindOfClass:[OverboardActor class]]) {
			OverboardActor *person = (OverboardActor *)actor;
			
			if (person.dying == NO) {
				[person environmentalDeath];
                
                if (person.prisoner.planked)
                    ++mPrisonersFried;
			
				if (mPrisonersFried == 3)
					[mScene.achievementManager grantDeepFriedAchievement];
			}
		} else if ([actor isKindOfClass:[PowderKegActor class]]) {
			PowderKegActor *keg = (PowderKegActor *)actor;
			[keg detonate];
		}
	}
}

- (void)prepareForNewGame {
    if (mPreparingForNewGame)
        return;
    mPreparingForNewGame = YES;
    [self despawnOverTime:mNewGamePreparationDuration];
}

- (void)dealloc {
	[mScene.juggler removeTweensWithTarget:mSlick];
	[mScene.juggler removeTweensWithTarget:mFire];
	[mScene removeProp:mFire];
	[mFire release]; mFire = nil;
    [mVAnim release]; mVAnim = nil;
	[mSlick release]; mSlick = nil;
	[super dealloc];
}

@end
