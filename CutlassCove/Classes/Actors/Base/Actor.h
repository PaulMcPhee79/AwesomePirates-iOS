//
//  Actor.h
//  Pirates
//
//  Created by Paul McPhee on 3/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Box2D/Box2D.h>
#import "PlayfieldController.h"
#import "ActorDef.h"

/*
#define ACTOR_KIND_PLAYER_SHIP			0x1UL
#define ACTOR_KIND_PIRATE_SHIP			0x2UL
#define ACTOR_KIND_NAVY_SHIP			0x4UL
#define ACTOR_KIND_MERCHANT_SHIP		0x8UL
#define ACTOR_KIND_VILLAIN_SHIP			0x10UL
#define ACTOR_KIND_PINK_PEARL_SHIP		0x20UL
#define ACTOR_KIND_ESCORT_SHIP			0x40UL
#define ACTOR_KIND_TREASURE_FLEET		0x80UL
#define ACTOR_KIND_SILVER_TRAIN			0x100UL
#define ACTOR_KIND_PRIMESHIP (ACTOR_KIND_TREASURE_FLEET | ACTOR_KIND_SILVER_TRAIN)
#define ACTOR_KIND_PURSUIT_SHIP (ACTOR_KIND_PIRATE_SHIP | ACTOR_KIND_NAVY_SHIP | ACTOR_KIND_VILLAIN_SHIP | ACTOR_KIND_ESCORT_SHIP)
#define ACTOR_KIND_NPC_SHIP (ACTOR_KIND_MERCHANT_SHIP | ACTOR_KIND_PINK_PEARL_SHIP | ACTOR_KIND_PRIMESHIP | ACTOR_KIND_PURSUIT_SHIP)	
#define ACTOR_KIND_SHIP (ACTOR_KIND_PLAYER_SHIP | ACTOR_KIND_NPC_SHIP)
#define ACTOR_KIND_CANNONBALL			0x200UL
#define ACTOR_KIND_BRANDY_SLICK			0x400UL
#define ACTOR_KIND_NET					0x800UL
#define ACTOR_KIND_POWDER_KEG			0x1000UL
#define ACTOR_KIND_ACID_POOL			0x2000UL
#define ACTOR_KIND_OVERBOARD			0x4000UL
#define ACTOR_KIND_SHARK				0x8000UL
#define ACTOR_KIND_TREASURE				0x10000UL
#define ACTOR_KIND_TEMPEST				0x20000UL
#define ACTOR_KIND_WHIRLPOOL			0x40000UL

#define IS_ACTOR_KIND(a,k) ((a) & (k))
*/

@class Prop;

@interface Actor : SPSprite {
	NSString *mKey;
	int mCategory;
    
	BOOL mAdvanceable;
	BOOL mRemoveMe;
    BOOL mRemovedContact; // Did the previous EndContact remove the Actor from our contact list, or do we still have colliding fixtures
    
    BOOL mPreparingForNewGame;
    float mNewGamePreparationDuration;
    
	b2Body *mBody;
	NSMutableSet *mContacts;
    
	PlayfieldController *mScene;
	
	@private
	int mActorId;
    uint mTurnID;
	NSMutableSet *mContactCounts;
	Prop *mZombieProp;
}

@property (nonatomic,readonly) NSString *key;
@property (nonatomic,assign) int actorId;
@property (nonatomic,readonly) uint turnID;
@property (nonatomic,readonly) float px;
@property (nonatomic,readonly) float py;
@property (nonatomic,readonly) float b2x;
@property (nonatomic,readonly) float b2y;
@property (nonatomic,readonly) float b2rotation;
@property (nonatomic,readonly) BOOL advanceable;
@property (nonatomic,readonly) BOOL markedForRemoval;
@property (nonatomic,readonly) BOOL isPreparingForNewGame;
@property (nonatomic,readonly) b2Body *body;
@property (nonatomic,assign) int category;

- (id)initWithActorDef:(ActorDef *)def;
- (id)initWithActorDef:(ActorDef *)def actorId:(int)actorId;
- (bool)isSensor;
- (void)flip:(BOOL)enable;
- (int)tagForContactWithActor:(Actor *)actor;
- (void)setTag:(int)tag forContactWithActor:(Actor *)actor;
- (void)fpsFactorChanged:(float)value;
- (void)advanceTime:(double)time;
- (void)respondToPhysicalInputs;
- (void)beginContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact;
- (bool)preSolve:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact;
- (void)endContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact;
- (void)prepareForNewGame;
- (void)checkoutPooledResources;
- (void)checkinPooledResources;
- (void)safeRemove;
- (void)destroyActorBody;
- (void)zeroOutFixtures;
- (void)cleanup;
+ (void)seedActorId:(int)seed;
+ (int)nextActorId;
+ (int)actorCount;
+ (void)printActors;
+ (SceneController *)actorsScene;
+ (void)setActorsScene:(PlayfieldController *)scene;

@end

@interface ActorContact : NSObject {
	int mTag;
	int mCount;
	Actor *mActor; // Weak reference
}

@property (nonatomic,assign) int tag;
@property (nonatomic,assign) int count;
@property (nonatomic,assign) Actor *actor;

+ (ActorContact *)actorContactWithActor:(Actor *)actor;

@end

