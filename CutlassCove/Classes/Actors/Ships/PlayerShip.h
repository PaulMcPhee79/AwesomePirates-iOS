//
//  PlayerShip.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 6/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShipActor.h"
#import "Cannonball.h"

#define CUST_EVENT_TYPE_PLAYER_SHIP_SINKING @"playerShipSinkingEvent"
#define CUST_EVENT_TYPE_MONTY_SKIPPERED @"montySkippered"

typedef enum {
    MSFirstMate = 0,
    MSSkipper,
    MSTripper,
    MSConsipirator,
    MSMutineer
} MontyState;


@class ShipDetails,ShipDeck,OffscreenArrow,NetActor,BrandySlickActor,AshProc,Destination;
class RayCastClosest;

@interface PlayerShip : ShipActor {
	BOOL mCamouflaged;
	BOOL mFlyingDutchman;
	BOOL mSinking;
	BOOL mMotorBoatingSob;
	BOOL mTimeTravelling;
	BOOL mSuspendedMode;
	BOOL mDroppingKegs;
    BOOL mPlankEnabled;
    BOOL mFailedMotorboating;
    
    int mRecentHitCount;
    int mRecentShotCount;
    
    int mRaceUpdateIndex;
    
    BOOL mCannonsOverheated;
    double mCannonSpamCapacitor;
    
    double mTripCounter;
    double mPowderKegTimer;
    double mDashDialFlashTimer;
    double mAccuracyCooldownTimer;
    
	float mCannonRange;
    float mGravityFactor;
	float mSpeedNormalizer;
    float mDragDuration;
	uint mKegsRemaining;
	CannonballInfamyBonus *mCannonInfamyBonus;

	int mSpeedRatingBonus;
	int mControlRatingBonus;
	
	AshProc *mAshProc;
	ShipDeck *mShipDeck;
	RayCastClosest *mCrewAiming;
	OffscreenArrow *mOffscreenArrow;
	
	NetActor *mNet;
	BrandySlickActor *mBrandySlick;
	
	NSArray *mDutchmanCostumeImages;
	NSArray *mCamoCostumeImages;
	
	ResOffset *mResOffset;
    
    // Monty
    MontyState mMonty;
    Destination *mMontyDest;
}

@property (nonatomic, readonly) BOOL isCamouflaged;
@property (nonatomic, readonly) BOOL isFlyingDutchman;
@property (nonatomic,readonly) BOOL assistedAiming;
@property (nonatomic,retain) ShipDeck *shipDeck;
@property (nonatomic,retain) AshProc *ashProc;
@property (nonatomic,readonly) BOOL anchored;
@property (nonatomic,assign) BOOL motorBoating;
@property (nonatomic,readonly) BOOL suspendedMode;
@property (nonatomic,assign) BOOL sinking;
@property (nonatomic,readonly) BOOL isPlankingEnqueued;
@property (nonatomic,assign) MontyState monty;
@property (nonatomic,readonly) uint kegsRemaining;
@property (nonatomic,retain) CannonballInfamyBonus *cannonInfamyBonus;

@property (nonatomic,readonly) double cannonSpamCapacitor;

@property (nonatomic,assign) int speedRatingBonus;
@property (nonatomic,assign) int controlRatingBonus;

@property (nonatomic,readonly) uint procType;
@property (nonatomic,readonly) NetActor *net;
@property (nonatomic,readonly) BrandySlickActor *brandySlick;

- (void)enableSuspendedMode:(BOOL)enable;
- (void)automatorFireCannons;
- (void)dropPowderKegs:(uint)quantity;
- (NetActor *)deployNetWithScale:(float)scale duration:(float)duration;
- (NetActor *)deployNetAtX:(float)x y:(float)y rotation:(float)rotation scale:(float)scale duration:(float)duration ignited:(BOOL)ignited;
- (void)despawnNetOverTime:(float)duration;
- (BrandySlickActor *)deployBrandySlickWithDuration:(float)duration;
- (BrandySlickActor *)deployBrandySlickAtX:(float)x y:(float)y rotation:(float)rotation scale:(float)scale duration:(float)duration ignited:(BOOL)ignited;
- (void)enablePlank:(BOOL)enable;
- (void)activateCamouflage;
- (void)deactivateCamouflage;
- (void)activateFlyingDutchman;
- (void)deactivateFlyingDutchman;
- (void)travelThroughTime:(float)duration;
- (void)emergeInPresentAtX:(float)x y:(float)y duration:(float)duration;
- (void)assistedAimingChanged:(BOOL)value;
- (void)cannonballHitTarget:(BOOL)hit ricochet:(BOOL)ricochet proc:(BOOL)proc;
- (void)prepareForGameOver;

@end
