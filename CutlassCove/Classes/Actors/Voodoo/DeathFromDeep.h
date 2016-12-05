//
//  DeathFromDeep.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 17/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"
#import "Pursuer.h"

#define CUST_EVENT_TYPE_DEATH_FROM_DEEP_DISMISSED @"deathFromDeepDismissedEvent"

@class NpcShip;

@interface DeathFromDeep : Prop <Pursuer> {
	int mState;
	double mSubmergedDelay;
	double mDuration;
	NpcShip *mTarget;
	SPMovieClip *mEmergeClip;
	SPMovieClip *mSubmergeClip;
}

@property (nonatomic,retain) NpcShip *target;

- (id)initWithCategory:(int)category duration:(float)duration;
- (void)despawn;

@end
