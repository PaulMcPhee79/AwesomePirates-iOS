//
//  OverboardActor.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 17/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "OverboardActor.h"
#import "SharkCache.h"
#import "Shark.h"
#import "ShipActor.h"
#import "PlayerDetails.h"
#import "GameController.h"
#import "Globals.h"

const int kStateAlive = 1;
const int kStateEaten = 2;
const int kStateDead = 3;

@interface OverboardActor ()

- (void)setState:(int)state;
- (void)setupActorCostume;
- (void)bodyShrunk;
- (void)bloodFaded;
- (void)onBodyShrunk:(SPEvent *)event;
- (void)onBloodFaded:(SPEvent *)event;

@end


@implementation OverboardActor

@synthesize isCollidable = mIsCollidable;
@synthesize hasRepellent = mHasRepellent;
@synthesize isPlayer = mIsPlayer;
@synthesize prisoner = mPrisoner;
@synthesize destination = mDestination;
@synthesize predator = mPredator;
@synthesize deathBitmap = mDeathBitmap;
@dynamic edible,dying,gender,infamyBonus;

+ (float)fps {
	return 6.0f;
}

- (id)initWithActorDef:(ActorDef *)def key:(NSString *)key {
	if (self = [super initWithActorDef:def]) {
		mCategory = CAT_PF_POINT_MOVIES;
		mAdvanceable = YES;
		mIsCollidable = YES;
        mHasRepellent = NO;
        mIsPlayer = NO;
		mKey = [key copy];
		mState = kStateAlive;
        mDeathBitmap = 0;
		mPrisoner = nil;
		mPersonClip = nil;
		mBlood = nil;
		mDestination = nil;
		mPredator = nil;
		mResources = nil;
		[self checkoutPooledResources];
		[self setupActorCostume];
    }
    return self;
}

/*
if (resources) {
    SPMovieClip *personClip = (SPMovieClip *)[resources objectForKey:@"Person"];
    
    if (personClip) {
        personClip.scaleX = personClip.scaleY = 1;
        personClip.alpha = 1;
        personClip.currentFrame = 0;
        [personClip play];
    }
    
    SPSprite *bloodSprite = (SPSprite *)[resources objectForKey:@"Blood"];
    
    if (bloodSprite) {
        bloodSprite.scaleX = 0.5f;
        bloodSprite.scaleY = 0.5f;
        bloodSprite.alpha = 1;
    }
}
*/

- (void)setupActorCostume {
	if (mPersonClip == nil) {
		mPersonClip = [[SPMovieClip alloc] initWithFrames:[mScene texturesStartingWith:@"overboard_" cacheGroup:TM_CACHE_SHARK] fps:[OverboardActor fps]];
		mPersonClip.x = -mPersonClip.width / 2;
		mPersonClip.y = -mPersonClip.height / 2;
		mPersonClip.loop = YES;
	}
    
    mPersonClip.scaleX = mPersonClip.scaleY = 1;
    mPersonClip.alpha = 1;
    mPersonClip.currentFrame = 0;
    [mPersonClip play];
	
	if (mBlood == nil) {
		SPImage *bloodImage = [SPImage imageWithTexture:[mScene textureByName:@"blood" cacheGroup:TM_CACHE_SHARK]];
		bloodImage.x = -bloodImage.width / 2;
		bloodImage.y = -bloodImage.height / 2;
		
		mBlood = [[SPSprite alloc] init];
		[mBlood addChild:bloodImage];
	}
    
    mBlood.scaleX = mBlood.scaleY = 0.5f;
    mBlood.alpha = 1;
	
	self.x = self.px;
	self.y = self.py;
	self.rotation = -self.b2rotation;
	
	[self addChild:mPersonClip];
	[mScene.juggler addObject:mPersonClip];
}

- (void)setState:(int)state {
    if (state < mState)
        return;
	mState = state;
}

- (BOOL)edible {
	return (mPredator == nil && mState == kStateAlive && mHasRepellent == NO);
}

- (BOOL)dying {
	return mState != kStateAlive;
}

- (int)gender {
	return mPrisoner.gender;
}

- (int)infamyBonus {
	return mPrisoner.infamyBonus;
}

- (void)setPredator:(Shark *)predator {
    if (mPredator == predator)
        return;
    
    // Prevent stack overflow when Shark tries to unset us.
    Shark *currentPredator = mPredator;
    mPredator = nil;
    
    if (currentPredator) {
        if (currentPredator.prey == self)
            currentPredator.prey = nil;
        [currentPredator autorelease]; currentPredator = nil;
    }
    
	mPredator = [predator retain];
}

- (void)getEatenByShark {
	if (mState != kStateAlive)
		return;
    
	[self setState:kStateEaten];
	[self playEatenAliveSound];
    
    if (![mResources startTweenForKey:RESOURCE_KEY_SHARK_PERSON_TWEEN]) {
        SPTween *tween = [SPTween tweenWithTarget:mPersonClip time:0.5f transition:SP_TRANSITION_LINEAR];
        [tween animateProperty:@"alpha" targetValue:0.0f];
        [tween animateProperty:@"scaleX" targetValue:0.7f];
        [tween animateProperty:@"scaleY" targetValue:0.7f];
        [tween addEventListener:@selector(onBodyShrunk:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
        [mScene.juggler addObject:tween];
    }
	
	mBlood.x = self.x;
	mBlood.y = self.y;
	mBlood.scaleX = 0.5f;
	mBlood.scaleY = 0.5f;
	mBlood.alpha = 1.0f;
	[mScene.spriteLayerManager addChild:mBlood withCategory:CAT_PF_SEA];
	
    if (![mResources startTweenForKey:RESOURCE_KEY_SHARK_BLOOD_TWEEN]) {
        SPTween *tween = [SPTween tweenWithTarget:mBlood time:5.0f transition:SP_TRANSITION_LINEAR];
        [tween animateProperty:@"alpha" targetValue:0.0f];
        [tween animateProperty:@"scaleX" targetValue:2.0f];
        [tween animateProperty:@"scaleY" targetValue:2.0f];
        [tween addEventListener:@selector(onBloodFaded:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
        [mScene.juggler addObject:tween];
    }
	
	if (mPrisoner && mPrisoner.planked)
		[self dropLoot];
}

- (void)environmentalDeath {
	if (self.dying || self.isPlayer)
		return;
	[self getEatenByShark];
	
	if (mPredator != nil) {
        if (mPredator.prey == self)
            mPredator.prey = nil;
		[mPredator release]; mPredator = nil;
	}
    
    [mScene.objectivesManager progressObjectiveWithEventType:OBJ_TYPE_OVERBOARD_DEATH tag:self.deathBitmap];
}

- (void)bodyShrunk {
    [mScene.achievementManager prisonerKilled:self];
}

- (void)bloodFaded {
    [mScene.juggler removeObject:mPersonClip];
	[mPersonClip release];
	mPersonClip = nil;
	[mScene.spriteLayerManager removeChild:mBlood withCategory:CAT_PF_SEA];
	[mScene removeActor:self];
	[self setState:kStateDead];
}

- (void)onBodyShrunk:(SPEvent *)event {
	[self bodyShrunk];
}

- (void)onBloodFaded:(SPEvent *)event {
	[self bloodFaded];
}

- (void)playEatenAliveSound {
    float volume = 0.2f;
    NSString *soundName = nil;
    
    if (self.gender == kGenderMale) {
        soundName = @"ScreamMan";
        volume = 0.2f;
    } else {
        soundName = @"ScreamWoman";
        volume = 0.225f;
    }
    
    //UIDevicePlatform platformType = [RESM platformType];
    //if (platformType == UIDevice3GiPod || platformType == UIDevice3GSiPhone || platformType == UIDevice5iPhone || platformType == UIDevice2GiPad)
    //    volume *= 0.8f;

	[mScene.audioPlayer playSoundWithKey:soundName volume:volume];
}

- (void)advanceTime:(double)time {
	self.x = self.px;
	self.y = self.py;
}

- (void)dock {
	// Just to satisfy PathFollower protocol.
}

- (void)dropLoot {

}

- (void)resourceEventFiredWithKey:(uint)key type:(NSString *)type target:(NSObject *)target {
    switch (key) {
        case RESOURCE_KEY_SHARK_PERSON_TWEEN:
            [self bodyShrunk];
            break;
        case RESOURCE_KEY_SHARK_BLOOD_TWEEN:
            [self bloodFaded];
            break;
        default:
            break;
    }
}

- (void)checkoutPooledResources {
	if (mResources == nil)
		mResources = [[[mScene cacheManagerByName:CACHE_SHARK] checkoutPoolResourcesForKey:@"Overboard"] retain];
	if (mResources == nil)
		NSLog(@"_+_+_+_+_+_+_+_+_ MISSED SHARK CACHE _+_++_+_+_+_+_+_+");
    else {
        mResources.client = self;
        
        if (mPersonClip == nil)
            mPersonClip = [(SPMovieClip *)[mResources displayObjectForKey:RESOURCE_KEY_SHARK_PERSON] retain];
        if (mBlood == nil)
            mBlood = [(SPSprite *)[mResources displayObjectForKey:RESOURCE_KEY_SHARK_BLOOD] retain];
    }
}

- (void)checkinPooledResources {
    if (mResources) {
        [[mScene cacheManagerByName:CACHE_SHARK] checkinPoolResources:mResources];
        [mResources release]; mResources = nil;
    }
}

- (void)cleanup {
	[super cleanup];
    
    if (mPredator)
        self.predator = nil; // Will already be nil if called from our dealloc
}

- (void)dealloc {
    [self cleanup];
    
	if (mState != kStateDead) {
		if (mPersonClip != nil) {
			[mScene.juggler removeTweensWithTarget:mPersonClip];
			[mScene.juggler removeObject:mPersonClip];
		}
	}
	
	if (mState == kStateEaten) {
		[mScene.juggler removeTweensWithTarget:mBlood];
		[mScene.spriteLayerManager removeChild:mBlood withCategory:CAT_PF_SEA];
		mState = kStateDead;
	}
	
	[self checkinPooledResources];
	[mPersonClip release]; mPersonClip = nil;
	[mBlood release]; mBlood = nil;
	[mDestination release]; mDestination = nil;
	[mPrisoner release]; mPrisoner = nil;
	[super dealloc];
}

@end
