//
//  CannonballGroup.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 11/07/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "CannonballGroup.h"
#import "Cannonball.h"

static int _nextGroupId = 1;
const double kSoundInterval = 0.1;

@interface CannonballGroup ()

- (BOOL)hasGroupMissed;
- (void)expireGroup;

@end


@implementation CannonballGroup

@synthesize groupId,hitQuota;

+ (CannonballGroup *)cannonballGroupWithHitQuota:(int)quota {
	return [[[CannonballGroup alloc] initWithHitQuota:quota] autorelease];
}

- (id)initWithHitQuota:(int)quota {
	if (self = [super initWithCategory:0]) {
        mAdvanceable = YES;
		hitQuota = quota;
		groupId = ++_nextGroupId;
		hitCounter = 0;
		mSplashSoundTimer = 0;
		mExplosionSoundTimer = 0;
        mIgnoreGroupMiss = NO;
		mCannonballs = [[NSMutableArray alloc] initWithCapacity:3];
		mRicochetTargets = [[NSMutableArray alloc] initWithCapacity:3];
	}
	return self;
}

- (id)init {
	return [self initWithHitQuota:1];
}

- (BOOL)hasGroupMissed {
	return (mIgnoreGroupMiss == NO && hitCounter < hitQuota);
}

- (void)ignoreGroupMiss {
    mIgnoreGroupMiss = YES;
}

- (void)addCannonball:(Cannonball *)cannonball {
	if (cannonball.cannonballGroupId == 0 && [mCannonballs containsObject:cannonball] == NO) { // Don't want to add it to more than one group
		cannonball.cannonballGroup = self;
		[mCannonballs addObject:cannonball];
		++hitCounter;
	}
}

- (void)removeCannonball:(Cannonball *)cannonball {
	if (cannonball != nil) {
		cannonball.cannonballGroup = nil;
		[[cannonball retain] autorelease];
		[mCannonballs removeObject:cannonball];
	}
	
	if (mCannonballs.count == 0)
		[self expireGroup];
}

- (void)removeAllCannonballs {
    for (Cannonball *cannonball in mCannonballs) {
        cannonball.cannonballGroup = nil;
        [[cannonball retain] autorelease];
    }
    
    [mCannonballs removeAllObjects];
    [self expireGroup];
}

- (void)cannonballImpacted:(CannonballImpactLog *)log {
	Cannonball *cannonball = log.cannonball;

	// Destruction case
	if (log.isCannonballMarkedForRemoval) {
		[self removeCannonball:cannonball];
		return;
	}
	
	if (log.ricochetTarget != nil) {
		log.mayRicochet = ([mRicochetTargets containsObject:log.ricochetTarget] == NO);
	
		if (log.mayRicochet)
			[mRicochetTargets addObject:log.ricochetTarget];
		
		if (cannonball.ricochetCount == 0) {
			// This is the initial hit and we should only play the sound once else it sounds bad in unison.
			log.shouldPlaySounds = (mExplosionSoundTimer <= 0);
			mExplosionSoundTimer = kSoundInterval;
		} else {
			log.shouldPlaySounds = YES;
		}
	} else {
		if (cannonball.ricochetCount == 0) {
			log.shouldPlaySounds = (mSplashSoundTimer <= 0);
			mSplashSoundTimer = kSoundInterval;
			--hitCounter;
		} else {
			log.shouldPlaySounds = YES;
		}
	}
	log.groupMissed = [self hasGroupMissed];
}

- (void)expireGroup {
	[mScene removeProp:self];
}

- (void)advanceTime:(double)time {
    mSplashSoundTimer -= time;
    mExplosionSoundTimer -= time;
}

- (void)dealloc {
	for (Cannonball *cannonball in mCannonballs)
		cannonball.cannonballGroup = nil;
	[mCannonballs dealloc]; mCannonballs = nil;
	[mRicochetTargets release]; mRicochetTargets = nil;
	[super dealloc];
	
    //NSLog(@"<<<<<<<<<<<<<<<<< CANNONBALL GROUP DEALLOC'ED >>>>>>>>>>>>>>>>>>>");
}

@end
