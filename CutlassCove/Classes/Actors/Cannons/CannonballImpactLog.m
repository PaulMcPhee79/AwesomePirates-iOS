//
//  CannonballImpactLog.m
//  CutlassCove
//
//  Created by Paul McPhee on 2/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CannonballImpactLog.h"

@implementation CannonballImpactLog

@synthesize impactType = mImpactType;
@synthesize cannonball = mCannonball;
@synthesize ricochetTarget = mRicochetTarget;
@synthesize groupMissed = mGroupMissed;
@synthesize mayRicochet = mMayRicochet;
@synthesize shouldPlaySounds = mShouldPlaySounds;
@dynamic missed,isCannonballMarkedForRemoval;

+ (CannonballImpactLog *)logWithCannonball:(Cannonball *)cannonball impactType:(ImpactType)impactType ricochetTarget:(Actor *)ricochetTarget {
    return [[[CannonballImpactLog alloc] initWithCannonball:cannonball impactType:impactType ricochetTarget:ricochetTarget] autorelease];
}

- (id)initWithCannonball:(Cannonball *)cannonball impactType:(ImpactType)impactType ricochetTarget:(Actor *)ricochetTarget {
    if (self = [super init]) {
		mImpactType = impactType;
        mCannonball = [cannonball retain];
		mRicochetTarget = [ricochetTarget retain];
		mGroupMissed = NO;
		mMayRicochet = NO;
		mShouldPlaySounds = NO;
	}
	return self;
}

- (void)dealloc {
    [mCannonball release]; mCannonball = nil;
	[mRicochetTarget release]; mRicochetTarget = nil;
	[super dealloc];
    
   // NSLog(@"CannonballImpactLog dealloc'ed");
}

- (BOOL)missed {
	return (mImpactType == ImpactWater || mImpactType == ImpactLand);
}

- (BOOL)isCannonballMarkedForRemoval {
	return (mImpactType == ImpactRemoveMe);
}

@end
