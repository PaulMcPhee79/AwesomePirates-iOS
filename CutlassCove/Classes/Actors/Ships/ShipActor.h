//
//  ShipActor.h
//  Pirates
//
//  Created by Paul McPhee on 3/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Actor.h"
#import "ActorAi.h"
#import "Infamous.h"
#import "Pursuer.h"
#import "DeathBitmaps.h"


#define SAILFORCE_MAX 96.0f
#define TURNFORCE_MAX 16.0f

@class ShipDetails,Cannonball,CannonDetails,Lantern,ShipHitGlow,Wake,Booty,Ransom,Prisoner,RaceEvent;

@interface ShipActor : Actor <Infamous> {
	BOOL mCannonSoundEnabled;
	float mOdometer;
	float mWakePeriod;
	float mWakeFactor;
	float mSailForce;
	float mSailForceMax;
	float mTurnForceMax;
	float mDrag;
	float mSpeedModifier;
	float mControlModifier;
    uint mAshBitmap;
	uint mDeathBitmap;
    uint mMiscBitmap;
    uint mRicochetHop;
	int mWakeCount;
	int mRicochetBonus;
	int mPlayerCannonInfamyBonus;
    int mMutinyReduction;
	b2Fixture *mBow; // Front
	b2Fixture *mHull; // Center
	b2Fixture *mStern; // Rear
	b2Fixture *mPort; // Left
	b2Fixture *mStarboard; // Right
	b2Fixture *mOverboard; // Where to drop overboard crew members. Must point to one of the other fixtures.
	ShipDetails *mShipDetails;
	CannonDetails *mCannonDetails;
	//Lantern *mLantern;
	NSMutableArray *mShipHitGlows;
	SPMovieClip *mSinkingClip;
	SPMovieClip *mBurningClip;
	Wake *mWake;
    
    NSMutableSet *mPursuers;
	
	// Costume
	float mAngVelUpright;
	int mCostumeIndex;
	int mCostumeUprightIndex;
	int mNumCostumeImages;
	SPSprite *mCostume;
    SPSprite *mDeathCostume;
    SPSprite *mWardrobe;
	NSArray *mCostumeImages;
	NSArray *mCurrentCostumeImages; // Weak reference
	NSMutableArray *mCostumeStack;
}

@property (nonatomic,assign) b2Fixture *bow;
@property (nonatomic,assign) b2Fixture *hull;
@property (nonatomic,assign) b2Fixture *stern;
@property (nonatomic,assign) b2Fixture *port;
@property (nonatomic,assign) b2Fixture *starboard;
@property (nonatomic,retain) ShipDetails *shipDetails;
@property (nonatomic,retain) CannonDetails *cannonDetails;
@property (nonatomic,readonly) float sailForce;
@property (nonatomic,assign) float drag;
@property (nonatomic,assign) float speedModifier;
@property (nonatomic,assign) float controlModifier;
@property (nonatomic,assign) float wakeFactor;
@property (nonatomic,assign) uint ashBitmap;
@property (nonatomic,assign) uint deathBitmap;
@property (nonatomic,assign) uint miscBitmap;
@property (nonatomic,readonly) float centerX;
@property (nonatomic,readonly) float centerY;
@property (nonatomic,readonly) b2Vec2 overboardLocation;
@property (nonatomic,readonly) float sinkingClipFps;
@property (nonatomic,readonly) float burningClipFps;
@property (nonatomic,assign) uint ricochetHop;
@property (nonatomic,assign) int ricochetBonus;
@property (nonatomic,assign) int sunkByPlayerCannonInfamyBonus;
@property (nonatomic,assign) int mutinyReduction;

- (id)initWithActorDef:(ActorDef *)def key:(NSString *)key;
- (void)setupShip;
- (NSArray *)setupCostumeForTexturesStartingWith:(NSString *)texturePrefix cacheGroup:(NSString *)cacheGroup;
- (void)setImages:(NSArray *)images forCostume:(SPSprite *)costume;
- (void)enqueueCostumeImages:(NSArray *)images;
- (void)dequeueCostumeImages:(NSArray *)images;
- (void)updateCostumeWithAngularVelocity:(float)angVel;
- (void)saveFixture:(b2Fixture *)fixture atIndex:(int)index;
- (b2Vec2)closestPositionTo:(b2Vec2)pos;
- (void)sailWithForce:(float32)force;
- (void)turnWithForce:(float32)force;
- (void)sink;
- (void)burn;
- (b2Fixture *)portOrStarboard:(int)side;
- (void)addPrisoner:(NSString *)name;
- (Prisoner *)addRandomPrisoner;
- (BOOL)isFullOnPrisoners;
- (void)dropLoot;
- (void)damageShip:(int)damage;
- (void)damageShipWithCannonball:(Cannonball *)cannonball;
- (void)applyPerpendicularImpulse:(float)force toCannonball:(Cannonball *)cannonball;
- (Cannonball *)fireCannon:(int)side trajectory:(float)trajectory;
- (void)animateCannonSmokeWithX:(float)x y:(float)y rotation:(float)rotation;
- (void)tickWakeOdometer:(float)sailForce;
- (void)onRaceUpdate:(RaceEvent *)event;

- (void)addPursuer:(NSObject<Pursuer> *)pursuer;
- (void)removePursuer:(NSObject<Pursuer> *)pursuer;
- (void)removeAllPursuers;

- (void)playFireCannonSound;
- (void)playSunkSound;

+ (float)defaultSailForceMax;

@end
