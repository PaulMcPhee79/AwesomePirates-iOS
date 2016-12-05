//
//  CannonballGroup.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 11/07/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"
#import "CannonballImpactLog.h"

@class Cannonball;

@interface CannonballGroup : Prop {
	int groupId;
	int hitQuota;
	int hitCounter;
	double mSplashSoundTimer;
	double mExplosionSoundTimer;
    BOOL mIgnoreGroupMiss;
	NSMutableArray *mCannonballs;
	NSMutableArray *mRicochetTargets;
}

@property (nonatomic,readonly) int groupId;
@property (nonatomic,assign) int hitQuota;

+ (CannonballGroup *)cannonballGroupWithHitQuota:(int)quota;
- (id)initWithHitQuota:(int)quota;
- (void)addCannonball:(Cannonball *)cannonball;
- (void)removeCannonball:(Cannonball *)cannonball;
- (void)cannonballImpacted:(CannonballImpactLog *)log;
- (void)ignoreGroupMiss;

@end
