//
//  NpcShip.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 9/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShipActor.h"
#import "PathFollower.h"
#import "Infamous.h"
#import "ResourceClient.h"

#define CUST_EVENT_TYPE_ESCORTEE_DESTROYED @"escorteeDestroyedEvent"
#define CUST_EVENT_TYPE_ESCORT_DESTROYED @"escortDestroyedEvent"

#define kSpeedRatingMax 11.0f
#define kControlRatingMax 10.0f

extern const int kStateAvoidNull;
extern const int kStateAvoidDecelerating;
extern const int kStateAvoidSlowed;
extern const int kStateAvoidAccelerating;

@interface NpcShip : ShipActor <PathFollower,Infamous,ResourceClient> {
	BOOL mIsCollidable;
	BOOL mHasLeftPort;
	BOOL mDocking;
	BOOL mReloading;
	BOOL mInWhirlpoolVortex;
	BOOL mInDeathsHands;
	BOOL mBootyGoneWanting;
	BOOL mInFuture;
	BOOL mGoods; // Does this ship carry goods onboard?
	float mAiModifier;
    
    double mReloadInterval;
    double mReloadTimer;
	double mWhirlpoolOverboardDelay;
    double mSinkingTimer;
	Destination *mDestination;
	
	b2Fixture *mFeeler; // Collision Avoidance Detector
    b2Fixture *mHitBox; // What the player shots are tested against
	int mAvoidState;
	float mAvoidAccel;
	float mSlowedFraction;
	NpcShip *mAvoiding;
	
	@private
	ResourceServer *mResources;
}

@property (nonatomic,assign) BOOL isCollidable;
@property (nonatomic,assign) BOOL inWhirlpoolVortex;
@property (nonatomic,assign) BOOL inDeathsHands;
@property (nonatomic,assign) BOOL inFuture;
@property (nonatomic,assign) float aiModifier;
@property (nonatomic,retain) Destination *destination;
@property (nonatomic,assign) b2Fixture *feeler;
@property (nonatomic,assign) b2Fixture *hitBox;
@property (nonatomic,assign) int avoidState;
@property (nonatomic,retain) NpcShip *avoiding;
@property (nonatomic,readonly) BOOL docking;

- (void)recalculateForces;
- (void)dock;
- (float)navigate;
- (void)updatePositionOrientation;
- (void)negotiateTarget:(ShipActor *)target;
- (void)creditPlayerSinker;
- (void)didLeavePort;
- (void)didReachDestination;
- (void)requestNewDestination;
- (BOOL)hasBootyGoneWanting:(SPSprite *)shooter;
- (void)throwCrewOverboard:(int)count;
- (void)spawnAcidPool;
- (void)spawnMagmaPool;
- (void)shrinkOverTime:(float)duration;

@end
