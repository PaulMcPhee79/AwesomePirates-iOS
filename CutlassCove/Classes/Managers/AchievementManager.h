//
//  AchievementManager.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 31/10/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameStats.h"
#import "TimeOfDayChangedEvent.h"
#import "ProfileResultEvent.h"
#import "StringValueEvent.h"

#define CUST_EVENT_TYPE_GK_DATA_WILL_CHANGE @"GKViewWillChangeEvent"
#define CUST_EVENT_TYPE_PLAYER_EATEN @"playerEatenEvent"

typedef enum {
	StatePlayerAchievements = 0,
	StatePlayerStats
} AchievementModelState;

@class AchievementPanel,CombatText,ShipActor,NumericValueChangedEvent,OverboardActor;
@class PlayerCannonFiredEvent,ProfileManager,BootySoldEvent,GameCoder;

@interface AchievementManager : SPEventDispatcher {
	TimeOfDay mTimeOfDay;
	
	BOOL mSuspendedMode;
	BOOL mDelaySavingAchievements;
	BOOL mDelayedSaveRequired;
	
	uint mConsecutiveCannonballsHit;
	uint mFriendlyFires;
	uint mKabooms;
    uint mSlimerCount;
	int mComboMultiplier;
	int mComboMultiplierMax;
	
	AchievementModelState mModelState;
	NSArray *mAchievementDefs;
	NSMutableArray *mDisplayQueue;
	SPTextureAtlas *mAtlas;
	
	AchievementPanel *mView;
	NSString *mComboTextOwner;
	CombatText *mCombatText;
	
	ProfileManager *mProfileManager;
	NSArray *mAchievementViewData;
	NSArray *mLeaderboardViewData;
	LeaderboardDescription *mPlayerViewData;
}

@property (nonatomic,assign) BOOL delaySavingAchievements;
@property (nonatomic,readonly) GameStats *stats;
@property (nonatomic,retain) SPTextureAtlas *atlas;
@property (nonatomic,retain) AchievementPanel *view;
@property (nonatomic,assign) TimeOfDay timeOfDay;
@property (nonatomic,assign) uint kabooms;
@property (nonatomic,assign) uint slimerCount;
@property (nonatomic,assign) int comboMultiplierMax;
@property (nonatomic,readonly) BOOL isComboMultiplierMaxed;
@property (nonatomic,assign) AchievementModelState modelState;
@property (nonatomic,readonly) ProfileManager *profileManager;
@property (nonatomic,readonly) uint numAchievements;
@property (nonatomic,readonly) uint numAchievementsCompleted;

// Pass through to GameStats
@property (nonatomic,assign) uint hostages;
@property (nonatomic,assign) float daysAtSea;

- (void)enableSuspendedMode:(BOOL)enable;
- (void)loadCombatTextWithCategory:(int)category bufferSize:(uint)bufferSize owner:(NSString *)owner;
- (void)fillCombatTextCache;
- (void)resetCombatTextCache;
- (void)unloadCombatTextWithOwner:(NSString *)owner;
- (void)hideCombatText;
- (void)setCombatTextColor:(uint)value;
- (void)onAchievementHidden:(SPEvent *)event;
- (void)randomAchievement;
- (void)resetStats;
- (void)prepareForNewGame;
- (void)saveProgress;
- (void)processDelayedSaves;
- (void)saveScore:(int64_t)score;
- (void)saveSpeed:(double)speed;
- (BOOL)achievementEarned:(int)key;
- (void)onTimeOfDayChanged:(TimeOfDayChangedEvent *)event;
- (void)flip:(BOOL)enable;
- (void)advanceTime:(double)time;

- (void)applyPurchasedComboUpgrade:(int)value;
- (void)merchantShipSunk:(ShipActor *)ship;
- (void)pirateShipSunk:(ShipActor *)ship;
- (void)navyShipSunk:(ShipActor *)ship;
- (void)escortShipSunk:(ShipActor *)ship;
- (void)silverTrainSunk:(ShipActor *)ship;
- (void)treasureFleetSunk:(ShipActor *)ship;
- (void)playerHitShip:(ShipActor *)ship distSq:(float)distSq ricocheted:(BOOL)ricocheted;
- (void)playerMissed:(uint)procType;
- (void)displayInfamyBonus:(uint)bonus x:(float)x y:(float)y twoBy:(BOOL)twoBy numHops:(uint)hops;
- (void)resetComboMultiplier;
- (void)broadcastComboMultiplier;
- (void)onInfamyChanged:(NumericValueChangedEvent *)event;
- (void)prisonerPushedOverboard;
- (void)prisonerKilled:(OverboardActor *)prisoner;
- (void)onAchievementEarned:(AchievementEarnedEvent *)event;
- (void)grantMasterPlankerAchievement;
- (void)grantSmorgasbordAchievement;
- (void)grantCloseButNoCigarAchievement;
- (void)grantNoPlaceLikeHomeAchievement;
- (void)grantEntrapmentAchievement;
- (void)grantDeepFriedAchievement;
- (void)grantRoyalFlushAchievement;
- (BOOL)hasCopsAndRobbersAchievement;
- (void)grantCopsAndRobbersAchievement;
- (void)grantSteamTrainAchievement;
- (void)grantBetterCallSaulAchievement;
- (void)grantSpeedDemonAchievement;
- (void)grant88MphAchievement;
- (void)grantRicochetAchievement:(uint)ricochetCount;

- (void)loadGameState:(GameCoder *)coder;
- (void)saveGameState:(GameCoder *)coder;

- (void)syncOnlineAchievements;
- (void)cancelOnlineSync;

// Data Model interface for UITableViews... TODO: depending on whether we go with Open Feint, Crystal, GameCenter, etc.
- (void)fetchAchievements;
- (void)onAchievementsFetchedEvent:(ProfileResultEvent *)event;

- (NSInteger)rowCount;
- (NSString *)textForHeader;
- (NSString *)titleForIndex:(NSIndexPath *)indexPath;
- (NSString *)descForIndex:(NSIndexPath *)indexPath;
- (NSString *)valueForIndex:(NSIndexPath *)indexPath;
- (NSString *)subTextForIndex:(NSIndexPath *)indexPath;
- (double)percentForIndex:(NSIndexPath *)indexPath;
- (NSString *)imageNameForIndex:(NSIndexPath *)indexPath;
- (NSString *)prizeImageNameForIndex:(NSIndexPath *)indexPath completed:(BOOL)completed;
- (NSString *)backgroundImageNameForIndex:(NSIndexPath *)indexPath;
- (BOOL)isBinaryForIndex:(NSIndexPath *)indexPath;
- (BOOL)completedForIndex:(NSIndexPath *)indexPath;
- (BOOL)unlockedForIndex:(NSIndexPath *)indexPath;

@end
