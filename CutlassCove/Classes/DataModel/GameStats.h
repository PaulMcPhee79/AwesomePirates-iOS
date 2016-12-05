//
//  GameStats.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 8/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "Score.h"
#import "Idol.h"
#import "Potion.h"
#import "Ash.h"
#import "AchievementEarnedEvent.h"

#define CUST_EVENT_TYPE_SHIP_TYPE_CHANGED @"shipTypeChangedEvent"
#define CUST_EVENT_TYPE_CANNON_TYPE_CHANGED @"cannonTypeChangedEvent"
#define CUST_EVENT_TYPE_PLAYER_CHANGED @"playerChangedEvent"

#define ACHIEVEMENT_INDEX_MIN 0
#define ACHIEVEMENT_INDEX_POT_SHOT 0 // Done
#define ACHIEVEMENT_INDEX_DEADEYE_DAVY 1 // Done
#define ACHIEVEMENT_INDEX_SMORGASBORD 2 // Done
#define ACHIEVEMENT_INDEX_CLOSE_BUT_NO_CIGAR 3 // Done
#define ACHIEVEMENT_INDEX_NO_PLACE_LIKE_HOME 4 // Done
#define ACHIEVEMENT_INDEX_ENTRAPMENT 5 // Done
#define ACHIEVEMENT_INDEX_FRIENDLY_FIRE 6 // Done
#define ACHIEVEMENT_INDEX_KABOOM 7 // Done
#define ACHIEVEMENT_INDEX_DEEP_FRIED 8 // Done
#define ACHIEVEMENT_INDEX_ROYAL_FLUSH 9 // Done
#define ACHIEVEMENT_INDEX_SLIMER 10 // Done
#define ACHIEVEMENT_INDEX_RICOCHET_MASTER 11 // Done
#define ACHIEVEMENT_INDEX_SCOURGE_OF_THE_7_SEAS 12 // Done
#define ACHIEVEMENT_INDEX_MASTER_PLANKER 13 // Done
#define ACHIEVEMENT_INDEX_ROBBIN_DA_HOOD 14 // Done
#define ACHIEVEMENT_INDEX_BOOM_SHAKALAKA 15 // Done
#define ACHIEVEMENT_INDEX_LIKE_A_RECORD_BABY 16 // Done
#define ACHIEVEMENT_INDEX_ROAD_TO_DAMASCUS 17 // Done
#define ACHIEVEMENT_INDEX_WELL_DONE 18 // Done
#define ACHIEVEMENT_INDEX_DAVY_JONES_LOCKER 19 // Done
#define ACHIEVEMENT_INDEX_88_MPH 20 // Done
#define ACHIEVEMENT_INDEX_COPS_AND_ROBBERS 21 // Done
#define ACHIEVEMENT_INDEX_STEAM_TRAIN 22 // Done
#define ACHIEVEMENT_INDEX_BETTER_CALL_SAUL 23 // Done
#define ACHIEVEMENT_INDEX_SPEED_DEMON 24 // Done
#define ACHIEVEMENT_INDEX_MAX 24


// Two MSB decide on which element of the array the bitshift should be performed 
#define ACHIEVEMENT_BIT_POT_SHOT (1<<0)
#define ACHIEVEMENT_BIT_DEADEYE_DAVY (1<<1)
#define ACHIEVEMENT_BIT_SMORGASBORD (1<<2)
#define ACHIEVEMENT_BIT_CLOSE_BUT_NO_CIGAR (1<<3)
#define ACHIEVEMENT_BIT_NO_PLACE_LIKE_HOME (1<<4)
#define ACHIEVEMENT_BIT_ENTRAPMENT (1<<5)
#define ACHIEVEMENT_BIT_FRIENDLY_FIRE (1<<6)
#define ACHIEVEMENT_BIT_KABOOM (1<<7)
#define ACHIEVEMENT_BIT_DEEP_FRIED (1<<8)
#define ACHIEVEMENT_BIT_ROYAL_FLUSH (1<<9)
#define ACHIEVEMENT_BIT_SLIMER (1<<10)
#define ACHIEVEMENT_BIT_RICOCHET_MASTER (1<<11)
#define ACHIEVEMENT_BIT_SCOURGE_OF_THE_7_SEAS (1<<12)
#define ACHIEVEMENT_BIT_MASTER_PLANKER (1<<13)
#define ACHIEVEMENT_BIT_ROBBIN_DA_HOOD (1<<14)
#define ACHIEVEMENT_BIT_BOOM_SHAKALAKA (1<<15)
#define ACHIEVEMENT_BIT_LIKE_A_RECORD_BABY (1<<16)
#define ACHIEVEMENT_BIT_ROAD_TO_DAMASCUS (1<<17)
#define ACHIEVEMENT_BIT_WELL_DONE (1<<18)
#define ACHIEVEMENT_BIT_DAVY_JONES_LOCKER (1<<19)
#define ACHIEVEMENT_BIT_88_MPH (1<<20)
#define ACHIEVEMENT_BIT_COPS_AND_ROBBERS (1<<21)
#define ACHIEVEMENT_BIT_STEAM_TRAIN (1<<22)
#define ACHIEVEMENT_BIT_BETTER_CALL_SAUL (1<<23)
#define ACHIEVEMENT_BIT_SPEED_DEMON (1<<24)
#define ACHIEVEMENT_COUNT 25 // Also update GCM_ACHIEVEMENT_COUNT in GameCenterManager.h

/*
#define ACHIEVEMENT_BIT_FRIENDLY_FIRE ((1<<30) | (1<<0))
#define ACHIEVEMENT_BIT_KABOOM ((1<<30) | (1<<1))
#define ACHIEVEMENT_BIT_DEEP_FRIED ((1<<30) | (1<<2))
#define ACHIEVEMENT_BIT_ROYAL_FLUSH ((1<<30) | (1<<3))
#define ACHIEVEMENT_BIT_DARING_SEAMAN ((1<<30) | (1<<4))
#define ACHIEVEMENT_BIT_88_MPH ((1<<30) | (1<<5))
#define ACHIEVEMENT_BIT_RICOCHET_MASTER ((1<<30) | (1<<6))
#define ACHIEVEMENT_BIT_MASTER_PLANKER ((1<<30) | (1<<7))
#define ACHIEVEMENT_BIT_ROBBIN_DA_HOOD ((1<<30) | (1<<8))
*/

// Example of indexing array element 0
//#define ACHIEVEMENT_BIT_EXAMPLE (1<<0)

// Example of indexing array element 1
//#define ACHIEVEMENT_BIT_EXAMPLE ((1<<30) | (1<<0))

// Example of indexing array element 2
//#define ACHIEVEMENT_BIT_EXAMPLE ((1<<31) | (1<<0))

// Example of indexing array element 3
//#define ACHIEVEMENT_BIT_EXAMPLE ((3<<30) | (1<<0))


@class GKScore,CCOFChallenge;

extern const int kGSNoUpgrade;
extern const int kGSLocalUpgrade;
extern const int kGSCloudUpgrade;
extern const int kGSAllUpgrade;

// TODO: grandchild of NSObject. Should we rely on NSObject's initWithCoder and encodeWithCoder always doing nothing (because we don't call them)?
@interface GameStats : SPEventDispatcher <NSCoding> {
    NSString *mDataVersion;     // To maintain data integrity between versions when restoring data from cloud and from disk.
	NSString *mAlias;           // The player's local alias/name (not GC)
	NSString *mShipName;
	NSString *mCannonName;
	NSMutableArray *mShipNames;
	NSMutableArray *mCannonNames;
	
	NSMutableArray *mTrinkets;
	NSMutableArray *mGadgets;
	
    NSMutableDictionary *mHiScores; // Hi scores for each game mode (game mode is the key)
    
	uint mAchievementBitmap[4];     // Overall achievements bitmap
    NSArray *mObjectives;           // Overall objectives list
	
	uint mCannonballsShot;
	uint mCannonballsHit;
    uint mRicochets[5];
	uint mMerchantShipsSunk;
	uint mPirateShipsSunk;
	uint mNavyShipsSunk;
	uint mEscortShipsSunk;
	uint mSilverTrainsSunk;
	uint mTreasureFleetsSunk;
	uint mPlankings;
    uint mHostages;
    uint mSharkAttacks;
    float mDaysAtSea;
    
    uint mPowderKegSinkings;
    uint mWhirlpoolSinkings;
    uint mDamascusSinkings;
    uint mBrandySlickSinkings;
    uint mDavySinkings;
    
    // GameCenter offline score
    NSMutableArray *mOfflineScores;
    
    // v1.1 additions
    NSDictionary *mPotions;
    
    // v2.0 additions
    uint mAcidPlankings;
    
    // v2.1 additions
    double mPotionsTimestamp;
    int mFastestSpeed;
}

@property (nonatomic,copy) NSString *alias;

@property (nonatomic,copy) NSString *shipName;
@property (nonatomic,copy) NSString *cannonName;
@property (nonatomic,readonly) NSArray *shipNames;
@property (nonatomic,readonly) NSArray *cannonNames;
@property (nonatomic,readonly) NSArray *trinkets;
@property (nonatomic,readonly) NSArray *gadgets;
@property (nonatomic,readonly) NSDictionary *potions;
@property (nonatomic,readonly) uint abilities;
@property (nonatomic,readonly) uint trinketAbilities;
@property (nonatomic,readonly) uint gadgetAbilities;

@property (nonatomic,readonly) NSArray *objectives;

@property (nonatomic,assign) uint cannonballsShot;
@property (nonatomic,assign) uint cannonballsHit;
@property (nonatomic,readonly) float cannonballAccuracy;
@property (nonatomic,assign) uint merchantShipsSunk;
@property (nonatomic,assign) uint pirateShipsSunk;
@property (nonatomic,assign) uint navyShipsSunk;
@property (nonatomic,assign) uint escortShipsSunk;
@property (nonatomic,assign) uint silverTrainsSunk;
@property (nonatomic,assign) uint treasureFleetsSunk;
@property (nonatomic,assign) uint plankings;
@property (nonatomic,assign) uint hostages;
@property (nonatomic,assign) uint sharkAttacks;
@property (nonatomic,assign) uint acidPlankings;
@property (nonatomic,assign) float daysAtSea;

@property (nonatomic,retain) CCOFChallenge *ofChallenge;
@property (nonatomic,readonly) NSDictionary *writableForm;
@property (nonatomic,readonly) uint numProfileStats;

@property (nonatomic,readonly) NSArray *offlineScores;

@property (nonatomic,assign) double potionsTimestamp;

+ (NSDictionary *)blankStatsDictionaryForAlias:(NSString *)alias;
+ (uint)achievementBitForIndex:(int)index;
+ (NSArray *)liteAchievementIndexes;
+ (BOOL)isLiteAchievementIndex:(uint)index liteIndexes:(NSArray *)liteIndexes;
- (id)initWithAlias:(NSString *)alias;
- (id)initWithStatsDictionary:(NSDictionary *)dict;
- (void)prepareForNewGame;
- (void)resetObjectives;
- (void)resetAchievements;
- (void)resetAllStats;
- (int)upgradeToOther:(GameStats *)other;
- (uint *)getAchievementBitmap;
- (uint)getAchievementBit:(uint)key;
- (void)setAchievementBit:(uint)key;
- (uint)earnedAchievementPoints:(NSArray *)achievementDefs;
- (uint)totalAchievementPoints:(NSArray *)achievementDefs;
- (uint)numAchievementsCompleted;

- (Score *)hiScore;                 // Returns hi score for original game mode: CC_GAME_MODE_DEFAULT
- (void)setHiScore:(int64_t)value;  // Sets hi score for original game mode: CC_GAME_MODE_DEFAULT
- (Score *)hiScoreForGameMode:(NSString *)mode;
- (void)setHiScore:(int64_t)value forGameMode:(NSString *)mode;

- (int64_t)fastestSpeed;
- (void)setFastestSpeed:(int64_t)value;

- (GKScore *)todayOfflineScoreForPlayerID:(NSString *)playerID;
- (GKScore *)thisWeekOfflineScoreForPlayerID:(NSString *)playerID;
- (GKScore *)allTimeOfflineScoreForPlayerID:(NSString *)playerID;
- (void)addOfflineScore:(GKScore *)score;
- (void)removeOfflineScore:(GKScore *)score;
- (void)clearOfflineScores;
- (void)clearOfflineScoreForPlayerID:(NSString *)playerID range:(NSTimeInterval)range;

- (void)addRicochets:(uint)count forHops:(uint)hops;
- (uint)numRicochetsForHops:(uint)hops;

- (Idol *)idolForKey:(uint)key;
- (Idol *)equippedIdolForKey:(uint)key;
- (Idol *)trinketAtSlot:(int)slot;
- (void)setTrinket:(uint)trinket atSlot:(int)slot;
- (Idol *)gadgetAtSlot:(int)slot;
- (void)setGadget:(uint)gadget atSlot:(int)slot;

- (void)addTrinket:(uint)trinket;
- (void)removeTrinket:(uint)trinket;
- (BOOL)containsTrinket:(uint)trinket;
- (void)addGadget:(uint)gadget;
- (void)removeGadget:(uint)gadget;
- (BOOL)containsGadget:(uint)gadget;

- (Potion *)potionForKey:(uint)key;
+ (NSArray *)activatedPotionsFromPotions:(NSDictionary *)potions;
- (void)activatePotion:(BOOL)activate forKey:(uint)key;
- (void)enforcePotionConstraints;
- (void)enforcePotionRequirements;

- (void)addShipName:(NSString *)name;
- (void)removeShipName:(NSString *)name;
- (BOOL)containsShipName:(NSString *)name;

- (void)addCannonName:(NSString *)name;
- (void)removeCannonName:(NSString *)name;
- (BOOL)containsCannonName:(NSString *)name;

- (void)shipSunkWithDeathBitmap:(uint)deathBitmap;
- (double)percentComplete:(uint)achievementBit;
- (void)setPercentComplete:(double)percentComplete forAchievementBit:(uint)achievementBit achievementIndex:(uint)achievementIndex;
- (void)updatePercentComplete:(double)percentComplete forAchievementBit:(uint)achievementBit achievementIndex:(uint)achievementIndex;

@end
