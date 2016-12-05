//
//  ActorAi.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 13/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameController.h"
#import <Box2D/Box2D.h>

#define CUST_EVENT_TYPE_CLOSE_BUT_NO_CIGAR_STATE_REACHED @"closeButNoCigarStateReached"
#define CUST_EVENT_TYPE_TREASURE_FLEET_SPAWNED @"treasureFleetSpawnedEvent"
#define CUST_EVENT_TYPE_TREASURE_FLEET_ATTACKED @"treasureFleetAttackedEvent"
#define CUST_EVENT_TYPE_SILVER_TRAIN_SPAWNED @"silverTrainSpawnedEvent"
#define CUST_EVENT_TYPE_SILVER_TRAIN_ATTACKED @"silverTrainAttackedEvent"

#define THINK_SPECIAL 0
#define THINK_NAVY 1
#define THINK_PIRATE 2
#define THINK_MERCHANT 3
#define THINK_SHARK 4
#define THINK_CYCLE 5
#define THINK_TANK_COUNT 6

@class Actor,ShipActor,Shark,OverboardActor,PrimeShip,PlayfieldController,TempestActor,DeathFromDeep,GameCoder,Prisoner;

const int kSpawnPlanesCount = 6;
const int kPlaneIdNorth = 0;
const int kPlaneIdEast = 1;
const int kPlaneIdSouth = 2;
const int kPlaneIdWest = 3;
const int kPlaneIdTown = 4;
const int kPlaneIdCove = 5;

@interface ActorAi : SPEventDispatcher{
	BOOL mLocked;
    BOOL mSuspendedMode;
	BOOL mShipsPaused;
	BOOL mInFuture;
	int mRandomInt;
    uint mFleetID;
	float mDifficultyFactor;
    
    // Timers
	double mPirateSpawnTimer;
	double mNavySpawnTimer;
    double mCamouflageTimer;
    
	AiKnob *mAiKnob;
    
    BOOL mThinking;
    double mThinkTank[THINK_TANK_COUNT];
	
    // Ash Pickups
    float mAshPickupSpawnTimer;
    NSMutableArray *mAshPickupQueue;
    
	// Voodoo Objects
	NSMutableSet *mTempests;
	NSMutableSet *mDeathFromDeeps;
	
	// Ships
	PrimeShip *mFleet;
	NSMutableSet *mMerchantShips;
	NSMutableSet *mNavyShips;
	NSMutableSet *mPirateShips;
	NSMutableSet *mPlayerShips;
	NSMutableSet *mEscortShips;
	NSMutableSet *mSharks;
	NSMutableSet *mPeople;
    NSMutableSet *mAshPickups;
	NSArray *mShipTypes;
	
	SPPoint *mTownEntrance;
	SPPoint *mTownDock;
	SPPoint *mCoveDock;
	SPPoint *mSilverTrainDest; // Weak reference
	SPPoint *mTreasureFleetSpawn; // Weak reference
	NSMutableArray *mSpawnPlanes;
	NSMutableArray *mVacantSpawnPlanes;
	NSMutableArray *mOccupiedSpawnPlanes;
	
	PlayfieldController *mScene; // Weak reference
}

@property (nonatomic,assign) AiKnob *aiKnob;
@property (nonatomic,assign) float difficultyFactor;
@property (nonatomic,assign) BOOL shipsPaused;
@property (nonatomic,assign) BOOL inFuture;
@property (nonatomic,readonly) BOOL isPlayfieldClear;
@property (nonatomic,readonly) BOOL isPlayfieldClearOfNpcShips;
@property (nonatomic,readonly) NSSet *tempests;
@property (nonatomic,readonly) NSSet *deathFromDeeps;
@property (nonatomic,readonly) Actor *fleet;

+ (void)setupAiKnob:(AiKnob *)aiKnob;
- (id)initWithController:(PlayfieldController *)scene;
//- (void)wakeUp;
//- (void)goToSleep;
- (void)enableSuspendedMode:(BOOL)enable;
- (void)turnAiKnob;
- (void)think;
- (void)stopThinking;
- (void)advanceTime:(double)time;
- (b2Vec2)randomPickupLocation;
- (void)dockAllShips;
- (void)prepareForNewGame;
- (void)prepareForGameOver;
- (void)prepareForMontyMutiny;
- (void)sinkAllShipsWithDeathBitmap:(uint)deathBitmap;
- (void)addActor:(Actor *)actor;
- (void)removeActor:(Actor *)actor;
- (ShipActor *)requestNewMerchantEnemy:(ShipActor *)ship;
- (ShipActor *)requestNewVoodooTarget;
- (ShipActor *)requestClosestTarget:(Actor *)actor;
- (void)actorDepartedPort:(Actor *)actor;
- (void)actorArrivedAtDestination:(Actor *)actor;
- (void)requestTargetForPursuer:(NSObject *)pursuer;
- (void)prisonerOverboard:(Prisoner *)prisoner ship:(ShipActor *)ship;
- (void)enactMontysMutiny;
- (void)markPlayerAsEdible;
- (TempestActor *)summonTempest;
- (TempestActor *)summonTempestAtX:(float)x y:(float)y duration:(float)duration;
- (DeathFromDeep *)summonDeathFromDeepWithDuration:(float)duration;
- (void)activateCamouflageForDuration:(float)duration;
- (void)deactivateCamouflage;

- (void)loadGameState:(GameCoder *)coder;
- (void)saveGameState:(GameCoder *)coder;

@end
