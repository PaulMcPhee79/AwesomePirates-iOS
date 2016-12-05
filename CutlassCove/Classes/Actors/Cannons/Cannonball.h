//
//  Cannonball.h
//  Pirates
//
//  Created by Paul McPhee on 18/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Actor.h"
#import "CannonballInfamyBonus.h"
#import "CannonballGroup.h"
#import "ResourceClient.h"

#define kGravity 0.065f   ///Original Value: 0.075f

@class CannonballInfamyBonus,CannonballGroup;

@interface Cannonball : Actor <ResourceClient> {
	int mGroupId;
    CannonballGroup *mGroup; // Weak reference
    
	NSString *mShotType;
	SPSprite *mShooter;
	b2Fixture *mCore;
	b2Fixture *mCone;
	b2Vec2 mOrigin;
	
	BOOL mHasProcced;
	float mBore;
	float mTrajectory;
	float mShadowFactor;
	
    float mGravity;
	float mScaleFactor;
	float mMidDistance;
	float mDistanceRemaining;
	
	BOOL mRicocheted;
	uint mRicochetCount;
    int mDamageFromImpact;
	CannonballInfamyBonus *mInfamyBonus;
	
	SPMovieClip *mBallClip;
	SPMovieClip *mShadowClip;
    
    SPSprite *mBallContainer;
    SPSprite *mShadowContainer;
    
    SPSprite *mBallCostume;
    SPSprite *mShadowCostume;
    
    NSMutableArray *mSensors;
	NSMutableSet *mDestroyedShips;
	ResourceServer *mResources;
}

@property (nonatomic,assign) int cannonballGroupId;
@property (nonatomic,assign) CannonballGroup *cannonballGroup;
@property (nonatomic,readonly) NSString *shotType;
@property (nonatomic,readonly) NSString *shooterName;
@property (nonatomic,readonly) SPSprite *shooter;
@property (nonatomic,assign) BOOL hasProcced;
@property (nonatomic,retain) CannonballInfamyBonus *infamyBonus;
@property (nonatomic,assign) uint ricochetCount;
@property (nonatomic,assign) b2Fixture *core;
@property (nonatomic,assign) b2Fixture *cone;
@property (nonatomic,readonly) float bore;
@property (nonatomic,assign) float trajectory; // DO NOT RE-IMPLEMENT IN SUBCLASS!
@property (nonatomic,assign) float distanceRemaining;
@property (nonatomic,assign) float gravity;
@property (nonatomic,readonly) float distSq;
@property (nonatomic,readonly) int damageFromImpact;

- (id)initWithActorDef:(ActorDef *)def shotType:(NSString *)shotType shooter:(SPSprite *)shooter bore:(float)bore trajectory:(float)trajectory;
- (id)initWithActorDef:(ActorDef *)def shotType:(NSString *)shotType shooter:(SPSprite *)shooter bore:(float)bore;
- (void)setupCannonball;
- (void)calculateTrajectoryFromTarget:(b2Body *)target;
- (void)calculateTrajectoryFromTargetX:(float)targetX targetY:(float)targetY;
- (void)copyTrajectoryFrom:(Cannonball *)other;
+ (NSString *)shooterName:(SPSprite *)shooter;
- (void)playExplosionSound;
- (void)playSplashSound;

+ (float)fps;

@end
