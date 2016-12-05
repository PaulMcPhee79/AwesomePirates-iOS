//
//  CannonballImpactLog.h
//  CutlassCove
//
//  Created by Paul McPhee on 2/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	ImpactWater = 0,
	ImpactLand,
	ImpactNpcShip,
	ImpactPlayerShip,
	ImpactRemoveMe
} ImpactType;

@class Actor,Cannonball;

@interface CannonballImpactLog : NSObject {
    BOOL mGroupMissed;
	BOOL mMayRicochet;
	BOOL mShouldPlaySounds;
	ImpactType mImpactType;
    Cannonball *mCannonball;
	Actor *mRicochetTarget;
}

@property (nonatomic,readonly) ImpactType impactType;
@property (nonatomic,readonly) BOOL missed;
@property (nonatomic,readonly) Cannonball *cannonball;
@property (nonatomic,readonly) Actor *ricochetTarget;
@property (nonatomic,readonly) BOOL isCannonballMarkedForRemoval;

// Feedback properties (can be set by receivers)
@property (nonatomic,assign) BOOL groupMissed;
@property (nonatomic,assign) BOOL mayRicochet;
@property (nonatomic,assign) BOOL shouldPlaySounds;

+ (CannonballImpactLog *)logWithCannonball:(Cannonball *)cannonball impactType:(ImpactType)impactType ricochetTarget:(Actor *)ricochetTarget;
- (id)initWithCannonball:(Cannonball *)cannonball impactType:(ImpactType)impactType ricochetTarget:(Actor *)ricochetTarget;

@end
