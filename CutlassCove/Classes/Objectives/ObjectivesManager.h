//
//  ObjectivesManager.h
//  Cutlass Cove
//
//  Created by Paul McPhee on 6/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectivesRank.h"

#define CUST_EVENT_TYPE_OBJECTIVES_RANKUP_COMPLETED @"objectivesRankupCompletedEvent"

#define OBJ_TYPE_REQUIREMENTS 1UL
#define OBJ_TYPE_PLANKING 2UL
#define OBJ_TYPE_SINKING 3UL
#define OBJ_TYPE_TIME_OF_DAY 4UL
#define OBJ_TYPE_SCORE 5UL
#define OBJ_TYPE_RICOCHET 6UL
#define OBJ_TYPE_LOOT 7UL
#define OBJ_TYPE_RED_CROSS 8UL
#define OBJ_TYPE_BLUE_CROSS 9UL
#define OBJ_TYPE_SHOT_MISSED 10UL
#define OBJ_TYPE_TRAWLING_NET 11UL
#define OBJ_TYPE_ASH_PICKED_UP 12UL
#define OBJ_TYPE_SPELL_USED 13UL
#define OBJ_TYPE_MUNITION_USED 14UL
#define OBJ_TYPE_SHOT_FIRED 15UL
#define OBJ_TYPE_PLAYER_HIT 16UL
#define OBJ_TYPE_VOODOO_GADGET_EXPIRED 17UL
#define OBJ_TYPE_BLAST_VICTIMS 18UL
#define OBJ_TYPE_OVERBOARD_DEATH 19UL

typedef enum {
    ObjViewTypeView = 0,
    ObjViewTypeCompleted,
    ObjViewTypeCurrent,
    ObjViewTypeNotices
} ObjectivesViewType;

@class ObjectivesRank,ObjectivesView,SceneController,ShipActor;

@interface ObjectivesManager : SPEventDispatcher {
    BOOL mIsGameOver;
    
    ObjectivesRank *mCurrentRank;
    ObjectivesRank *mShadowRank;
    ObjectivesRank *mProgressMarkerRank;
    NSArray *mRanks;
    
    ObjectivesView *mView;
    SceneController *mScene; // Weak reference
    
    // Cached state details
    uint mRedCrossCount;
    uint mShotCount;
    uint mRicochetCount;
    uint mPlayerHitCount;
    uint mSpellUseCount;
    uint mMunitionUseCount;
    uint mFleetID;
    uint mFleetIDCount;
    uint mNavyShipsSunkCount;
    uint mPirateShipsSunkCount;
    uint mExpiredTempestCount;
    uint mActiveSpellsMunitionsBitmap;
    int mLivePowderKegs;
}

@property (nonatomic,readonly) BOOL isMaxRank;
@property (nonatomic,readonly) BOOL isCurrentRankCompleted;
@property (nonatomic,readonly) uint rank;
@property (nonatomic,readonly) NSString *rankLabel;
@property (nonatomic,readonly) NSString *rankTitle;
@property (nonatomic,readonly) ObjectivesRank *syncedObjectivesRank;
@property (nonatomic,readonly) uint scoreMultiplier;
@property (nonatomic,readonly) uint requiredNpcShipType;
@property (nonatomic,readonly) uint requiredAshType;

- (id)initWithRanks:(NSArray *)ranks scene:(SceneController *)scene;
- (void)setScene:(SceneController *)scene;
- (void)setupWithRanks:(NSArray *)ranks;
- (ObjectivesRank *)syncedObjectivesForRank:(uint)rank;
- (NSString *)rankLabelForRank:(uint)rank;
- (void)enableTouchBarrier:(BOOL)enable;
- (void)flip:(BOOL)enable;

- (void)prepareForNewGame;
- (void)prepareForGameOver;
- (void)testRankup;

// Current Panel
- (void)showCurrentPanel;
- (void)hideCurrentPanel;
- (void)enableCurrentPanelButtons:(BOOL)enable;
- (SPSprite *)maxRankSprite;

// Completed Panel
- (void)testCompletedObjectivesPanel;

// Rankup Panel
- (void)processEndOfTurn;
- (void)testRankupPanel;

// Misc Panel
- (void)enqueueNotice:(NSString *)msg;
- (void)hideNoticesPanel;

// Objectives Events
- (void)progressObjectiveWithRicochetVictims:(NSSet *)victims;
- (void)progressObjectiveWithEventType:(uint)eventType;
- (void)progressObjectiveWithEventType:(uint)eventType count:(uint)count;
- (void)progressObjectiveWithEventType:(uint)eventType ship:(ShipActor *)ship;
- (void)progressObjectiveWithEventType:(uint)eventType tag:(uint)tag;
- (void)progressObjectiveWithEventType:(uint)eventType count:(uint)count ship:(ShipActor *)ship victims:(NSSet *)victims;
- (void)progressObjectiveWithEventType:(uint)eventType tag:(uint)tag count:(uint)count ship:(ShipActor *)ship victims:(NSSet *)victims;

@end
