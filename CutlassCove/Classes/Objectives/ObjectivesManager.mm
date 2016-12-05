//
//  ObjectivesManager.m
//  Cutlass Cove
//
//  Created by Paul McPhee on 6/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ObjectivesManager.h"
#import "ObjectivesView.h"
#import "ObjectivesRank.h"
#import "ShipActors.h"
#import "SceneController.h"
#import "PlayerDetails.h"
#import "CannonDetails.h"
#import "ShipDetails.h"
#import "BinaryEvent.h"
#import "GameStats.h"
#import "GameController.h"
#import "Globals.h"

@interface ObjectivesManager ()

@property (nonatomic,retain) NSArray *ranks;
@property (nonatomic,retain) ObjectivesRank *currentRank;

- (void)refreshCachedStateDetails;
- (void)createView;
- (void)destroyView;
- (ObjectivesRank *)getNextRankFromRanks:(NSArray *)ranks;
- (BOOL)wasProgressMade;
- (void)processRecentlyCompletedObjectives;
- (void)onCurrentPanelDismissed:(SPEvent *)event;
- (void)onRankupPanelDismissed:(SPEvent *)event;

// Misc Helpers
- (BOOL)wasFleetDestroyed:(ShipActor *)ship;

@end


@implementation ObjectivesManager

@synthesize ranks = mRanks;
@synthesize currentRank = mCurrentRank;
@dynamic isMaxRank,isCurrentRankCompleted,rank,rankLabel,rankTitle,syncedObjectivesRank,scoreMultiplier,requiredNpcShipType,requiredAshType;

- (id)initWithRanks:(NSArray *)ranks scene:(SceneController *)scene {
    if (self = [super init]) {
        mRanks = [ranks retain];
        mIsGameOver = NO;
        mShadowRank = nil;
        mProgressMarkerRank = nil;
        self.currentRank = [ObjectivesRank getCurrentRankFromRanks:ranks];
        mScene = scene;
        mView = nil;
        [self createView];
    }
    return self;
}

- (void)dealloc {
    [self setScene:nil];
    
    [mCurrentRank release]; mCurrentRank = nil;
    [mShadowRank release]; mShadowRank = nil;
    [mProgressMarkerRank release]; mProgressMarkerRank = nil;
    [mRanks release]; mRanks = nil;
    [super dealloc];
}

- (BOOL)isMaxRank {
    return self.rank == [ObjectivesRank maxRank];
}

- (BOOL)isCurrentRankCompleted {
    return (mCurrentRank && mCurrentRank.isCompleted && mCurrentRank.isMaxRank == NO);
}

- (uint)rank {
    return self.currentRank.rank;
}

- (NSString *)rankLabel {
    return [self rankLabelForRank:self.rank];
}

- (NSString *)rankLabelForRank:(uint)rank {
    NSString *label = nil;
    
    if (rank == 0)
        label = @"Unranked";
    else
        label = [NSString stringWithFormat:@"Rank %u", rank];
    return label;
}

- (NSString *)rankTitle {
    return [ObjectivesRank titleForRank:self.rank];
}

- (ObjectivesRank *)syncedObjectivesRank {
    ObjectivesRank *objRank = [ObjectivesRank objectivesRankWithRank:self.rank];
    [objRank syncWithObjectivesRank:self.currentRank];
    return objRank;
}

- (ObjectivesRank *)syncedObjectivesForRank:(uint)rank {
    ObjectivesRank *objRank = [ObjectivesRank objectivesRankWithRank:rank];
    [objRank syncWithObjectivesRank:[ObjectivesRank getRank:rank fromRanks:self.ranks]];
    return objRank;
}

- (uint)scoreMultiplier {
    return [ObjectivesRank multiplierForRank:self.rank];
}

- (uint)requiredNpcShipType {
    return (([self isMaxRank]) ? 0 : mCurrentRank.requiredNpcShipType);
}

- (uint)requiredAshType {
    return (([self isMaxRank]) ? 0 : mCurrentRank.requiredAshType);
}

- (void)setCurrentRank:(ObjectivesRank *)currentRank {
    if (mCurrentRank != currentRank) {
        [mCurrentRank autorelease];
        mCurrentRank = [currentRank retain];
        
        if (mShadowRank) {
            [mShadowRank release];
            mShadowRank = nil;
        }
        
        if (mProgressMarkerRank) {
            [mProgressMarkerRank release];
            mProgressMarkerRank = nil;
        }
        
        if (mCurrentRank) {
            mShadowRank = [[ObjectivesRank alloc] initWithRank:mCurrentRank.rank];
            [mShadowRank syncWithObjectivesRank:mCurrentRank];
            
            mProgressMarkerRank = [[ObjectivesRank alloc] initWithRank:mCurrentRank.rank];
            [mProgressMarkerRank syncWithObjectivesRank:mCurrentRank];
        }
    }    
}

- (void)setScene:(SceneController *)scene {
    // Remove from old scene
    [self destroyView];
    
    // Add to new scene
    mScene = scene;
    [self createView];
    [mView populateWithObjectivesRank:self.currentRank];
}

- (void)setupWithRanks:(NSArray *)ranks {
    self.ranks = ranks;
    self.currentRank = [ObjectivesRank getCurrentRankFromRanks:ranks];
    [mView populateWithObjectivesRank:self.currentRank];
}

- (void)enableTouchBarrier:(BOOL)enable {
    [mView enableTouchBarrier:enable];
}

- (void)flip:(BOOL)enable {
    [mView flip:enable];
}

- (void)prepareForNewGame {
    [self refreshCachedStateDetails];
    
    if (mCurrentRank.isCompleted)
        self.currentRank = [ObjectivesRank getCurrentRankFromRanks:mRanks];
    [mCurrentRank prepareForNewGame];
    [mShadowRank prepareForNewGame];
    [mProgressMarkerRank prepareForNewGame];
    [self progressObjectiveWithEventType:OBJ_TYPE_REQUIREMENTS];
    [mView populateWithObjectivesRank:self.currentRank];
    [mView fillCompletedCacheWithRank:self.currentRank];
    mIsGameOver = NO;
}

- (void)prepareForGameOver {
    mIsGameOver = YES;
}

- (void)testRankup {
    [self.currentRank forceCompletion];
    self.currentRank = [ObjectivesRank getCurrentRankFromRanks:mRanks];
}

- (void)refreshCachedStateDetails {
    mRedCrossCount = 0;
    mShotCount = 0;
    mRicochetCount = 0;
    mPlayerHitCount = 0;
    mSpellUseCount = 0;
    mMunitionUseCount = 0;
    mFleetID = 0;
    mFleetIDCount = 0;
    mNavyShipsSunkCount = 0;
    mPirateShipsSunkCount = 0;
    mExpiredTempestCount = 0;
    mActiveSpellsMunitionsBitmap = 0;
    mLivePowderKegs = 0;
}

- (void)createView {
    if (mView || mScene == nil)
        return;
    
    mView = [[ObjectivesView alloc] initWithCategory:[mScene objectivesCategoryForViewType:ObjViewTypeView]];
    [mView addEventListener:@selector(onCurrentPanelDismissed:) atObject:self forType:CUST_EVENT_TYPE_OBJECTIVES_CURRENT_PANEL_DISMISSED];
    [mView addEventListener:@selector(onRankupPanelDismissed:) atObject:self forType:CUST_EVENT_TYPE_OBJECTIVES_RANKUP_PANEL_DISMISSED];
    [mScene addProp:mView];
}

- (void)destroyView {
    if (mView == nil)
        return;
    
    [mView removeEventListener:@selector(onCurrentPanelDismissed:) atObject:self forType:CUST_EVENT_TYPE_OBJECTIVES_CURRENT_PANEL_DISMISSED];
    [mView removeEventListener:@selector(onRankupPanelDismissed:) atObject:self forType:CUST_EVENT_TYPE_OBJECTIVES_RANKUP_PANEL_DISMISSED];
    [mScene.juggler removeTweensWithTarget:mView];
    [mScene removeProp:mView];
    [mView release]; mView = nil;
}

- (ObjectivesRank *)getNextRankFromRanks:(NSArray *)ranks {
    ObjectivesRank *nextRank = nil;
    
    if (ranks && mCurrentRank) {
        uint currentIndex = [ranks indexOfObject:mCurrentRank];
        
        if (currentIndex < ranks.count-1)
            nextRank = (ObjectivesRank *)[ranks objectAtIndex:currentIndex+1];
    }
    
    if (nextRank == nil)
        nextRank = (ObjectivesRank *)[ranks lastObject];
    
    return nextRank;
}

// Current Panel
- (void)showCurrentPanel {
    [mView populateWithObjectivesRank:self.currentRank];
    [mView showCurrentPanel];
}

- (void)hideCurrentPanel {
    [mView hideCurrentPanel];
}

- (void)enableCurrentPanelButtons:(BOOL)enable {
    [mView enableCurrentPanelButtons:enable];
}

- (SPSprite *)maxRankSprite {
    return [mView maxRankSprite];
}

- (void)onCurrentPanelDismissed:(SPEvent *)event {
    [mView hideCurrentPanel];
}

// Completed Panel
- (void)testCompletedObjectivesPanel {
    [mView enqueueCompletedObjectivesDescription:[mCurrentRank objectiveDescAtIndex:0]];
}

- (void)processRecentlyCompletedObjectives {
    for (int i = 0; i < kNumObjectivesPerRank; ++i) {
        if ([mCurrentRank isObjectiveCompletedAtIndex:i] == YES && [mShadowRank isObjectiveCompletedAtIndex:i] == NO)
            [mView enqueueCompletedObjectivesDescription:[mCurrentRank objectiveDescAtIndex:i]];
    }
}

// Rankup Panel
- (BOOL)wasProgressMade {
    BOOL progressMade = NO;
    
    for (int i = 0; i < kNumObjectivesPerRank; ++i) {
        if ([mCurrentRank isObjectiveCompletedAtIndex:i] == YES && [mProgressMarkerRank isObjectiveCompletedAtIndex:i] == NO) {
            progressMade = YES;
            break;
        }
    }
    
    return progressMade;
}

// Misc Panel
- (void)enqueueNotice:(NSString *)msg {
    [mView enqueueNotice:msg];
}

- (void)hideNoticesPanel {
    [mView hideNoticesPanel];
}

- (void)processEndOfTurn {
    mIsGameOver = YES;
    
    if ([self wasProgressMade])
        GCTRL.thisTurn.wasGameProgressMade = YES;
    
    if ([self isCurrentRankCompleted]) {
        self.currentRank = [ObjectivesRank getCurrentRankFromRanks:mRanks];
        [mView showRankupPanelWithRank:self.currentRank.rank];
        [mScene.achievementManager resetCombatTextCache];
    } else {
        [self dispatchEvent:[BinaryEvent binaryEventWithType:CUST_EVENT_TYPE_OBJECTIVES_RANKUP_COMPLETED value:NO bubbles:NO]];
    }
}

- (void)testRankupPanel {
    [mView showRankupPanelWithRank:self.currentRank.rank];
}

- (void)onRankupPanelDismissed:(SPEvent *)event {
    [mView hideRankupPanel];
    [self dispatchEvent:[BinaryEvent binaryEventWithType:CUST_EVENT_TYPE_OBJECTIVES_RANKUP_COMPLETED value:YES bubbles:NO]];
}

// Misc Helpers
- (BOOL)wasFleetDestroyed:(ShipActor *)ship {
    BOOL fleetDestroyed = NO;
    uint fleetID = 0;
    
    if ([ship isKindOfClass:[PrimeShip class]]) {
        PrimeShip *primeShip = (PrimeShip *)ship;
        fleetID = primeShip.fleetID;
    } else if ([ship isKindOfClass:[EscortShip class]]) {
        EscortShip *escortShip = (EscortShip *)ship;
        fleetID = escortShip.fleetID;
    }
    
    if (mFleetID == fleetID) {
        ++mFleetIDCount;
        
        if (mFleetIDCount >= 3) {
            fleetDestroyed = YES;
            mFleetID = 0;
            mFleetIDCount = 0;
        }
    } else {
        mFleetID = fleetID;
        mFleetIDCount = 1;
    }
    
    return fleetDestroyed;
}

// Objectives Events
- (void)progressObjectiveWithRicochetVictims:(NSSet *)victims {
    [self progressObjectiveWithEventType:OBJ_TYPE_RICOCHET count:victims.count ship:nil victims:victims];
}

- (void)progressObjectiveWithEventType:(uint)eventType {
    [self progressObjectiveWithEventType:eventType tag:0 count:0 ship:nil victims:nil];
}

- (void)progressObjectiveWithEventType:(uint)eventType count:(uint)count {
    [self progressObjectiveWithEventType:eventType tag:0 count:count ship:nil victims:nil];
}

- (void)progressObjectiveWithEventType:(uint)eventType ship:(ShipActor *)ship {
    [self progressObjectiveWithEventType:eventType tag:0 count:0 ship:ship victims:nil];
}

- (void)progressObjectiveWithEventType:(uint)eventType tag:(uint)tag {
    [self progressObjectiveWithEventType:eventType tag:tag count:0 ship:nil victims:nil];
}

- (void)progressObjectiveWithEventType:(uint)eventType count:(uint)count ship:(ShipActor *)ship victims:(NSSet *)victims {
    [self progressObjectiveWithEventType:eventType tag:0 count:count ship:ship victims:victims];
}

- (void)progressObjectiveWithEventType:(uint)eventType tag:(uint)tag count:(uint)count ship:(ShipActor *)ship victims:(NSSet *)victims {
    if (self.currentRank == nil || self.currentRank.isMaxRank || mIsGameOver || (ship && ship.isPreparingForNewGame))
        return;
    GameController *gc = GCTRL;
    TimeOfDay timeOfDay = gc.timeKeeper.timeOfDay;
    uint day = gc.timeKeeper.day, key = 0;
    
    [mShadowRank syncWithObjectivesRank:mCurrentRank];
    
    switch (mCurrentRank.rank) {
#ifndef CHEEKY_LITE_VERSION
        case RANK_UNRANKED:
        {
            key = 1;
            
            if (eventType == OBJ_TYPE_PLANKING)
                [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
            else if (eventType == OBJ_TYPE_SINKING && (ship.deathBitmap & DEATH_BITMAP_POWDER_KEG))
                [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
            else if (eventType == OBJ_TYPE_MUNITION_USED && tag == GADGET_SPELL_TNT_BARRELS)
                mLivePowderKegs = [Idol countForIdol:[Idol idolWithKey:tag]];
            else if (eventType == OBJ_TYPE_VOODOO_GADGET_EXPIRED && tag == GADGET_SPELL_TNT_BARRELS && mLivePowderKegs > 0) {
                int count = (int)[mCurrentRank objectiveCountAtIndex:1], quota = (int)[mCurrentRank objectiveQuotaAtIndex:1];
                int countRemaining = quota - count;
                
                --mLivePowderKegs;
                
                if (countRemaining > mLivePowderKegs)
                    [mCurrentRank setObjectiveFailed:YES atIndex:1];
            } else if (eventType == OBJ_TYPE_TIME_OF_DAY && day == [ObjectivesDescription valueForKey:key+2] && timeOfDay == Sunset)
                [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
            
        }
            break;
        case RANK_SWABBY:
        {
            key = 4;
            
            if (eventType == OBJ_TYPE_SINKING && ([ship isKindOfClass:[TreasureFleet class]] || [ship isKindOfClass:[EscortShip class]])) {
                if ([self wasFleetDestroyed:ship])
                    [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
            } else if (eventType == OBJ_TYPE_RICOCHET && count >= [ObjectivesDescription valueForKey:key+1])
                [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
            else if (eventType == OBJ_TYPE_BLUE_CROSS)
                [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
        }
            break;
        case RANK_DECKHAND:
        {
            key = 7;
            
            if (eventType == OBJ_TYPE_SINKING) {
                if ([ship isKindOfClass:[NavyShip class]])
                    [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
                if (ship.deathBitmap & DEATH_BITMAP_WHIRLPOOL)
                    [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
            } else if (eventType == OBJ_TYPE_VOODOO_GADGET_EXPIRED && tag == VOODOO_SPELL_WHIRLPOOL)
                [mCurrentRank setObjectiveFailed:YES atIndex:1];
            else if (eventType == OBJ_TYPE_RICOCHET && count >= 2)
                [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
        }
            break;
        case RANK_JACK_TAR:
        {
            key = 10;
            
            if (eventType == OBJ_TYPE_SINKING && (ship.deathBitmap & DEATH_BITMAP_PLAYER_CANNON)) {
                if (ship.ashBitmap == ASH_MOLTEN)
                    [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
                [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
            } else if (eventType == OBJ_TYPE_ASH_PICKED_UP && tag == ASH_MOLTEN && [mCurrentRank isObjectiveCompletedAtIndex:0] == NO)
                [mCurrentRank setObjectiveCount:0 atIndex:0];
            else if (eventType == OBJ_TYPE_SHOT_MISSED && [mCurrentRank isObjectiveCompletedAtIndex:1] == NO)
                [mCurrentRank setObjectiveCount:0 atIndex:1];
            else if (eventType == OBJ_TYPE_TIME_OF_DAY && day == [ObjectivesDescription valueForKey:key+2] && timeOfDay == Sunrise)
                [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
        }
            break;
        case RANK_OLD_SALT:
        {
            key = 13;
            
            if (eventType == OBJ_TYPE_TRAWLING_NET && count >= [ObjectivesDescription valueForKey:key])
                [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
            else if (eventType == OBJ_TYPE_VOODOO_GADGET_EXPIRED && tag == GADGET_SPELL_NET)
                [mCurrentRank setObjectiveFailed:YES atIndex:0];
            else if (eventType == OBJ_TYPE_SINKING) {
                if ([ship isKindOfClass:[PirateShip class]])
                    [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
            } else if (eventType == OBJ_TYPE_SCORE && gc.thisTurn.infamy >= [ObjectivesDescription valueForKey:key+2] && mRicochetCount == 0)
                [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
            else if (eventType == OBJ_TYPE_RICOCHET && count >= 2) {
                ++mRicochetCount;
                [mCurrentRank setObjectiveFailed:YES atIndex:2];
            }
        }
            break;
#else
        case RANK_UNRANKED:
        {
            key = 1;
            
            if (eventType == OBJ_TYPE_BLUE_CROSS)
                [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
            else if (eventType == OBJ_TYPE_SINKING) {
                if (ship.deathBitmap & DEATH_BITMAP_GHOSTLY_TEMPEST)
                    [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
                else if (ship.deathBitmap & DEATH_BITMAP_PLAYER_CANNON)
                    [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
            } else if (eventType == OBJ_TYPE_VOODOO_GADGET_EXPIRED && tag == VOODOO_SPELL_TEMPEST) {
                ++mExpiredTempestCount;
                
                if (mExpiredTempestCount >= 2)
                    [mCurrentRank setObjectiveFailed:YES atIndex:1];
            } else if (eventType == OBJ_TYPE_SHOT_MISSED && [mCurrentRank isObjectiveCompletedAtIndex:2] == NO)
                [mCurrentRank setObjectiveCount:0 atIndex:2];
        }
            break;
        case RANK_SWABBY: // Jiker
        {
            key = 4;
            
            if (eventType == OBJ_TYPE_RICOCHET && count >= [ObjectivesDescription valueForKey:key])
                [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
            else if (eventType == OBJ_TYPE_SINKING) {
                if ((ship.deathBitmap & DEATH_BITMAP_POWDER_KEG) && [ship isKindOfClass:[NavyShip class]])
                    [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
            } else if (eventType == OBJ_TYPE_MUNITION_USED && tag == GADGET_SPELL_TNT_BARRELS)
                mLivePowderKegs = [Idol countForIdol:[Idol idolWithKey:tag]];
            else if (eventType == OBJ_TYPE_VOODOO_GADGET_EXPIRED && tag == GADGET_SPELL_TNT_BARRELS && mLivePowderKegs > 0 && [mCurrentRank isObjectiveCompletedAtIndex:1] == NO) {
                --mLivePowderKegs;
                
                if (mLivePowderKegs == 0)
                    [mCurrentRank setObjectiveFailed:YES atIndex:1];
            } else if (eventType == OBJ_TYPE_TIME_OF_DAY && day == [ObjectivesDescription valueForKey:key+2] && timeOfDay == Midnight)
                [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
        }
            break;
        case RANK_DECKHAND: // Powder Monkey
        {
            key = 7;
            
            if (eventType == OBJ_TYPE_PLANKING)
                [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
            else if (eventType == OBJ_TYPE_SINKING) {
                if (ship.deathBitmap & DEATH_BITMAP_ACID_POOL)
                    [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
            } else if (eventType == OBJ_TYPE_ASH_PICKED_UP && tag == ASH_NOXIOUS && [mCurrentRank isObjectiveCompletedAtIndex:1] == NO)
                [mCurrentRank setObjectiveCount:0 atIndex:1];
            else if (eventType == OBJ_TYPE_SCORE && gc.thisTurn.infamy >= 25000)
                [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
            else if (eventType == OBJ_TYPE_TIME_OF_DAY && day == [ObjectivesDescription valueForKey:key+2] && timeOfDay == Sunset)
                [mCurrentRank setObjectiveFailed:YES atIndex:2];
        }
            break;
        case RANK_JACK_TAR: // Boatswain
        {
            key = 10;
            
            if (eventType == OBJ_TYPE_TRAWLING_NET && count >= [ObjectivesDescription valueForKey:key])
                [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
            else if (eventType == OBJ_TYPE_VOODOO_GADGET_EXPIRED && tag == GADGET_SPELL_NET)
                [mCurrentRank setObjectiveFailed:YES atIndex:0];
            else if (eventType == OBJ_TYPE_SINKING) {
                if (ship.deathBitmap & DEATH_BITMAP_PLAYER_CANNON) {
                    if (ship.ashBitmap == ASH_SAVAGE)
                        [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
                } else {
                    [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
                }
            } else if (eventType == OBJ_TYPE_ASH_PICKED_UP && tag == ASH_SAVAGE && [mCurrentRank isObjectiveCompletedAtIndex:1] == NO)
                [mCurrentRank setObjectiveCount:0 atIndex:1];
            else if (eventType == OBJ_TYPE_SHOT_FIRED) {
                if ([mCurrentRank isObjectiveCompletedAtIndex:2] == NO)
                    [mCurrentRank setObjectiveCount:0 atIndex:2];
            }
        }
            break;
        case RANK_OLD_SALT: // Quartermaster
        {
            key = 13;
            
            if (eventType == OBJ_TYPE_SINKING) {
                if ([ship isKindOfClass:[TreasureFleet class]] || [ship isKindOfClass:[EscortShip class]]) {
                    if ([self wasFleetDestroyed:ship])
                        [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
                } else if (ship.deathBitmap & DEATH_BITMAP_WHIRLPOOL) {
                    if ([ship isKindOfClass:[NavyShip class]])
                        ++mNavyShipsSunkCount;
                    else if ([ship isKindOfClass:[PirateShip class]])
                        ++mPirateShipsSunkCount;
                    
                    if (mNavyShipsSunkCount >= 1 && mPirateShipsSunkCount >= 1)
                        [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
                }
            } else if (eventType == OBJ_TYPE_VOODOO_GADGET_EXPIRED && tag == VOODOO_SPELL_WHIRLPOOL)
                [mCurrentRank setObjectiveFailed:YES atIndex:1];
            else if (eventType == OBJ_TYPE_SCORE && gc.thisTurn.infamy >= [ObjectivesDescription valueForKey:key+2])
                [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
        }
            break;
#endif
        case RANK_HELMSMAN:
        {
            key = 16;
            
            if (eventType == OBJ_TYPE_SINKING && ([ship isKindOfClass:[SilverTrain class]] || [ship isKindOfClass:[EscortShip class]])) {
                if ([self wasFleetDestroyed:ship])
                    [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
            } else if (eventType == OBJ_TYPE_TIME_OF_DAY && day == [ObjectivesDescription valueForKey:key+1] && timeOfDay == Midnight && mRedCrossCount == 0)
                [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
            else if (eventType == OBJ_TYPE_RED_CROSS) {
                ++mRedCrossCount;
                [mCurrentRank setObjectiveFailed:YES atIndex:1];
            } else if (eventType == OBJ_TYPE_RICOCHET && count >= [ObjectivesDescription valueForKey:key+2])
                [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
        }
            break;
        case RANK_SEA_DOG:
        {
            key = 19;
            
            if (eventType == OBJ_TYPE_PLANKING)
                [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
            else if (eventType == OBJ_TYPE_SINKING && (ship.deathBitmap & DEATH_BITMAP_DEATH_FROM_THE_DEEP))
                [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
            else if (eventType == OBJ_TYPE_VOODOO_GADGET_EXPIRED && tag == VOODOO_SPELL_DEATH_FROM_DEEP)
                [mCurrentRank setObjectiveFailed:YES atIndex:1];
            else if (eventType == OBJ_TYPE_TIME_OF_DAY && day == [ObjectivesDescription valueForKey:key+2] && timeOfDay == Midnight)
                [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
        }
            break;
        case RANK_VILLAIN:
        {
            key = 22;
            
            if (eventType == OBJ_TYPE_RICOCHET && count >= 2) {
                uint navyShipCount = 0;
                
                for (ShipActor *victim in victims) {
                    if ([victim isKindOfClass:[NavyShip class]])
                        ++navyShipCount;
                }
                
                if (navyShipCount >= [ObjectivesDescription valueForKey:key])
                    [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
                [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
            } else if (eventType == OBJ_TYPE_SINKING && (ship.deathBitmap & DEATH_BITMAP_PLAYER_CANNON) && ship.ashBitmap == ASH_SAVAGE)
                [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
            else if (eventType == OBJ_TYPE_ASH_PICKED_UP && tag == ASH_SAVAGE && [mCurrentRank isObjectiveCompletedAtIndex:2] == NO)
                [mCurrentRank setObjectiveCount:0 atIndex:2];
        }
            break;
        case RANK_BRIGAND:
        {
            key = 25;
            
            if (eventType == OBJ_TYPE_SINKING) {
                if ([ship isKindOfClass:[NavyShip class]])
                    [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
                if (ship.deathBitmap & DEATH_BITMAP_BRANDY_SLICK)
                    [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
            } else if (eventType == OBJ_TYPE_VOODOO_GADGET_EXPIRED && tag == GADGET_SPELL_BRANDY_SLICK)
                [mCurrentRank setObjectiveFailed:YES atIndex:1];
            else if (eventType == OBJ_TYPE_SCORE && gc.thisTurn.infamy >= [ObjectivesDescription valueForKey:key+2])
                [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
        }
            break;
        case RANK_LOOTER:
        {
            key = 28;
            
            if (eventType == OBJ_TYPE_SINKING) {
                if (ship.deathBitmap & DEATH_BITMAP_PLAYER_CANNON)
                    [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
                if ([ship isKindOfClass:[NavyShip class]]) {
                    ++mNavyShipsSunkCount;
                    [mCurrentRank setObjectiveFailed:YES atIndex:1];
                }
            } else if (eventType == OBJ_TYPE_SHOT_MISSED && [mCurrentRank isObjectiveCompletedAtIndex:0] == NO)
                [mCurrentRank setObjectiveCount:0 atIndex:0];
            else if (eventType == OBJ_TYPE_TIME_OF_DAY && day == [ObjectivesDescription valueForKey:key+1] && timeOfDay == Sunrise && mNavyShipsSunkCount == 0)
                [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
            else if (eventType == OBJ_TYPE_RICOCHET && count >= 2) {
                uint pirateShipCount = 0;
                
                for (ShipActor *victim in victims) {
                    if ([victim isKindOfClass:[PirateShip class]])
                        ++pirateShipCount;
                }
                
                if (pirateShipCount >= [ObjectivesDescription valueForKey:key+2])
                    [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
            }
        }
            break;
        case RANK_GALLOWS_BIRD:
        {
            key = 31;
            
            if (eventType == OBJ_TYPE_SINKING) {
                if ([ship isKindOfClass:[PirateShip class]])
                    [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
                if ((ship.deathBitmap & DEATH_BITMAP_PLAYER_CANNON) && gc.playerShip.isFlyingDutchman)
                    [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
            } else if (eventType == OBJ_TYPE_VOODOO_GADGET_EXPIRED && tag == VOODOO_SPELL_FLYING_DUTCHMAN)
                [mCurrentRank setObjectiveFailed:YES atIndex:1];
            else if (eventType == OBJ_TYPE_TIME_OF_DAY && day == [ObjectivesDescription valueForKey:key+2] && timeOfDay == Sunrise)
                [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
        }
            break;
        case RANK_SCOUNDREL:
        {
            key = 34;
            
            if (eventType == OBJ_TYPE_SINKING) {
                if ([ship isKindOfClass:[TreasureFleet class]] || [ship isKindOfClass:[EscortShip class]]) {
                    if ([self wasFleetDestroyed:ship])
                        [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
                }
                
                if (ship.deathBitmap & DEATH_BITMAP_ACID_POOL)
                    [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
            } else if (eventType == OBJ_TYPE_ASH_PICKED_UP && tag == ASH_NOXIOUS && [mCurrentRank isObjectiveCompletedAtIndex:1] == NO)
                [mCurrentRank setObjectiveCount:0 atIndex:1];
            else if (eventType == OBJ_TYPE_RICOCHET && count >= [ObjectivesDescription valueForKey:key+2])
                [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
        }
            break;
        case RANK_ROGUE:
        {
            key = 37;
            
            if (eventType == OBJ_TYPE_SINKING && (ship.deathBitmap & DEATH_BITMAP_PLAYER_CANNON) && gc.playerShip.isCamouflaged)
                [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
            else if (eventType == OBJ_TYPE_VOODOO_GADGET_EXPIRED && tag == GADGET_SPELL_CAMOUFLAGE)
                [mCurrentRank setObjectiveFailed:YES atIndex:0];
            else if (eventType == OBJ_TYPE_PLANKING)
                [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
            else if (eventType == OBJ_TYPE_SCORE && gc.thisTurn.infamy >= [ObjectivesDescription valueForKey:key+2])
                [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
        }
            break;
        case RANK_PILLAGER:
        {
            key = 40;
            
            if (eventType == OBJ_TYPE_SINKING && (ship.deathBitmap & DEATH_BITMAP_PLAYER_CANNON))
                [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
            else if (eventType == OBJ_TYPE_SHOT_MISSED && [mCurrentRank isObjectiveCompletedAtIndex:0] == NO)
                [mCurrentRank setObjectiveCount:0 atIndex:0];
            else if (eventType == OBJ_TYPE_TIME_OF_DAY && day == [ObjectivesDescription valueForKey:key+1] && timeOfDay == Sunrise && mPlayerHitCount == 0)
                [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
            else if (eventType == OBJ_TYPE_PLAYER_HIT) {
                ++mPlayerHitCount;
                [mCurrentRank setObjectiveFailed:YES atIndex:1];
            } else if (eventType == OBJ_TYPE_RICOCHET && count >= 2)
                [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
        }
            break;
        case RANK_PLUNDERER:
        {
            key = 43;
            
            if (eventType == OBJ_TYPE_RICOCHET && count >= 2) {
                uint navyShipCount = 0, pirateShipCount = 0;
                
                for (ShipActor *victim in victims) {
                    if ([victim isKindOfClass:[NavyShip class]])
                        ++navyShipCount;
                    else if ([victim isKindOfClass:[PirateShip class]])
                        ++pirateShipCount;
                }
                
                if (navyShipCount > 0 && pirateShipCount > 0)
                    [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
            } else if (eventType == OBJ_TYPE_SINKING && (ship.deathBitmap & DEATH_BITMAP_GHOSTLY_TEMPEST))
                [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
            else if (eventType == OBJ_TYPE_VOODOO_GADGET_EXPIRED && tag == VOODOO_SPELL_TEMPEST) {
                ++mExpiredTempestCount;
                
                if (mExpiredTempestCount >= 2)
                    [mCurrentRank setObjectiveFailed:YES atIndex:1];
            } else if (eventType == OBJ_TYPE_TIME_OF_DAY && day == [ObjectivesDescription valueForKey:key+2] && timeOfDay == Midnight)
                [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
        }
            break;
        case RANK_FREEBOOTER:
        {
            key = 46;
            
            if (eventType == OBJ_TYPE_SINKING) {
                if ([ship isKindOfClass:[NavyShip class]])
                    [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
                if ((ship.deathBitmap & DEATH_BITMAP_PLAYER_CANNON) && ship.ashBitmap == ASH_SAVAGE)
                    [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
            } else if (eventType == OBJ_TYPE_ASH_PICKED_UP && tag == ASH_MOLTEN && [mCurrentRank isObjectiveCompletedAtIndex:1] == NO)
                [mCurrentRank setObjectiveCount:0 atIndex:1];
            else if (eventType == OBJ_TYPE_SCORE && gc.thisTurn.infamy >= [ObjectivesDescription valueForKey:key+2])
                [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
        }
            break;
        case RANK_PRIVATEER:
        {
            key = 49;
            
            if (eventType == OBJ_TYPE_SINKING && [ship isKindOfClass:[PirateShip class]])
                [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
            else if (eventType == OBJ_TYPE_TIME_OF_DAY && day == [ObjectivesDescription valueForKey:key+1] && timeOfDay == Midnight && mRedCrossCount == 0)
                [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
            else if (eventType == OBJ_TYPE_RED_CROSS) {
                ++mRedCrossCount;
                [mCurrentRank setObjectiveFailed:YES atIndex:1];
            } else if (eventType == OBJ_TYPE_RICOCHET) {
                if (count >= 2)
                    [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
                else if ([mCurrentRank isObjectiveCompletedAtIndex:2] == NO)
                    [mCurrentRank setObjectiveCount:0 atIndex:2];
            }
        }
            break;
        case RANK_CORSAIR:
        {
            key = 52;
            
            if (eventType == OBJ_TYPE_BLUE_CROSS)
                [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
            else if (eventType == OBJ_TYPE_TIME_OF_DAY && day == [ObjectivesDescription valueForKey:key+1] && timeOfDay == Noon && mNavyShipsSunkCount == 0)
                [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
            else if (eventType == OBJ_TYPE_SINKING && [ship isKindOfClass:[NavyShip class]]) {
                ++mNavyShipsSunkCount;
                [mCurrentRank setObjectiveFailed:YES atIndex:1];
            } else if (eventType == OBJ_TYPE_SCORE && gc.thisTurn.infamy >= [ObjectivesDescription valueForKey:key+2] && mRicochetCount == 0)
                [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
            else if (eventType == OBJ_TYPE_RICOCHET && count >= 2) {
                ++mRicochetCount;
                [mCurrentRank setObjectiveFailed:YES atIndex:2];
            }
        }
            break;
        case RANK_BUCCANEER:
        {
            key = 55;
            
            if (eventType == OBJ_TYPE_SINKING) {
                if ((ship.deathBitmap & DEATH_BITMAP_PLAYER_CANNON) && ship.ashBitmap == ASH_MOLTEN)
                    [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
                if ([ship isKindOfClass:[TreasureFleet class]] || [ship isKindOfClass:[EscortShip class]]) {
                    if (ship.deathBitmap & DEATH_BITMAP_POWDER_KEG) {
                        if ([self wasFleetDestroyed:ship])
                            [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
                    } else {
                        mFleetIDCount = 0;
                    }
                }
            } else if (eventType == OBJ_TYPE_ASH_PICKED_UP && tag == ASH_SAVAGE && [mCurrentRank isObjectiveCompletedAtIndex:0] == NO)
                [mCurrentRank setObjectiveCount:0 atIndex:0];
            else if (eventType == OBJ_TYPE_VOODOO_GADGET_EXPIRED && tag == GADGET_SPELL_TNT_BARRELS && mLivePowderKegs > 0 && [mCurrentRank isObjectiveCompletedAtIndex:1] == NO) {
                int count = (int)[mCurrentRank objectiveCountAtIndex:1], quota = (int)[mCurrentRank objectiveQuotaAtIndex:1];
                int countRemaining = 3 * (quota - count) - mFleetIDCount;
                
                --mLivePowderKegs;
                
                if (countRemaining > mLivePowderKegs)
                    [mCurrentRank setObjectiveFailed:YES atIndex:1];
            } else if (eventType == OBJ_TYPE_TIME_OF_DAY && day == [ObjectivesDescription valueForKey:key+2] && timeOfDay == Sunrise
                       && mSpellUseCount == 0 && mMunitionUseCount == 0)
                [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
            else if (eventType == OBJ_TYPE_SPELL_USED) {
                ++mSpellUseCount;
                [mCurrentRank setObjectiveFailed:YES atIndex:2];
            } else if (eventType == OBJ_TYPE_MUNITION_USED) {
                ++mMunitionUseCount;
                [mCurrentRank setObjectiveFailed:YES atIndex:2];
            }
        }
            break;
        case RANK_SEA_WOLF:
        {
            key = 58;

            if (eventType == OBJ_TYPE_SINKING) {
                if ((ship.deathBitmap & DEATH_BITMAP_PLAYER_CANNON) == 0)
                    [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
                
                if ([ship isKindOfClass:[PirateShip class]]) {
                    ++mPirateShipsSunkCount;
                    [mCurrentRank setObjectiveFailed:YES atIndex:2];
                }
            } else if (eventType == OBJ_TYPE_SHOT_FIRED) {
                if ([mCurrentRank isObjectiveCompletedAtIndex:0] == NO)
                    [mCurrentRank setObjectiveCount:0 atIndex:0];
            } else if (eventType == OBJ_TYPE_SCORE && gc.thisTurn.infamy >= [ObjectivesDescription valueForKey:key+1])
                [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
            else if (eventType == OBJ_TYPE_TIME_OF_DAY && day == [ObjectivesDescription valueForKey:key+2]
                     && timeOfDay == Noon && mPirateShipsSunkCount == 0)
                [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
        }
            break;
        case RANK_SWASHBUCKLER:
        {
            key = 61;

            if (eventType == OBJ_TYPE_SINKING) {
                if (ship.deathBitmap & DEATH_BITMAP_SEA_OF_LAVA)
                    [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
                else if (ship.deathBitmap & DEATH_BITMAP_ABYSSAL_SURGE)
                    [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
            } else if (eventType == OBJ_TYPE_VOODOO_GADGET_EXPIRED && tag == VOODOO_SPELL_SEA_OF_LAVA)
                [mCurrentRank setObjectiveFailed:YES atIndex:0];
            else if (eventType == OBJ_TYPE_ASH_PICKED_UP && tag == ASH_ABYSSAL && [mCurrentRank isObjectiveCompletedAtIndex:1] == NO)
                [mCurrentRank setObjectiveCount:0 atIndex:1];
            else if (eventType == OBJ_TYPE_TIME_OF_DAY && day == [ObjectivesDescription valueForKey:key+2] && timeOfDay == Sunrise)
                [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
        }
            break;
        case RANK_CALICO_JACK:
        {
            key = 64;
            
            if (eventType == OBJ_TYPE_SCORE && gc.thisTurn.infamy >= 5000000)
                [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
            else if (eventType == OBJ_TYPE_TIME_OF_DAY && day == [ObjectivesDescription valueForKey:key] && timeOfDay == Sunrise)
                [mCurrentRank setObjectiveFailed:YES atIndex:0];
            else if (eventType == OBJ_TYPE_SINKING) {
                if ([ship isKindOfClass:[SilverTrain class]] || [ship isKindOfClass:[EscortShip class]]) {
                    if ((ship.deathBitmap & DEATH_BITMAP_PLAYER_CANNON) && ship.ashBitmap == ASH_MOLTEN) {
                        if ([self wasFleetDestroyed:ship])
                            [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
                    } else {
                        mFleetIDCount = 0;
                    }
                } else if ([ship isKindOfClass:[PirateShip class]] && (ship.deathBitmap & DEATH_BITMAP_POWDER_KEG))
                    [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
            } else if (eventType == OBJ_TYPE_MUNITION_USED && tag == GADGET_SPELL_TNT_BARRELS)
                mLivePowderKegs = [Idol countForIdol:[Idol idolWithKey:tag]];
            else if (eventType == OBJ_TYPE_VOODOO_GADGET_EXPIRED && tag == GADGET_SPELL_TNT_BARRELS && mLivePowderKegs > 0) {
                int count = (int)[mCurrentRank objectiveCountAtIndex:2], quota = (int)[mCurrentRank objectiveQuotaAtIndex:2];
                int countRemaining = quota - count;
                
                --mLivePowderKegs;
                
                if (countRemaining > mLivePowderKegs)
                    [mCurrentRank setObjectiveFailed:YES atIndex:2];
            }
        }
            break;
        case RANK_BLACK_BART:
        {
            key = 67;
            
            if (eventType == OBJ_TYPE_SINKING) {
                if (ship.deathBitmap & DEATH_BITMAP_PLAYER_CANNON) {
                    [mCurrentRank setObjectiveFailed:YES atIndex:0];
                    
                    if (ship.ashBitmap == ASH_SAVAGE && [ship isKindOfClass:[NavyShip class]])
                        [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
                }
            } else if (eventType == OBJ_TYPE_TIME_OF_DAY && day == [ObjectivesDescription valueForKey:key] && timeOfDay == Midnight && [mCurrentRank isObjectiveFailedAtIndex:0] == NO)
                [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
            else if (eventType == OBJ_TYPE_BLUE_CROSS && gc.playerShip.isCamouflaged)
                [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
            else if (eventType == OBJ_TYPE_VOODOO_GADGET_EXPIRED && tag == GADGET_SPELL_CAMOUFLAGE)
                [mCurrentRank setObjectiveFailed:YES atIndex:1];
            else if (eventType == OBJ_TYPE_ASH_PICKED_UP && tag == ASH_SAVAGE && [mCurrentRank isObjectiveCompletedAtIndex:2] == NO)
                [mCurrentRank setObjectiveCount:0 atIndex:2];
        }
            break;
        case RANK_BARBAROSSA:
        {
            key = 70;
            
            if (eventType == OBJ_TYPE_RICOCHET) {
                if (count >= 2)
                    [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
                if (count >= [ObjectivesDescription valueForKey:key+2])
                    [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
            } else if (eventType == OBJ_TYPE_TIME_OF_DAY && day == [ObjectivesDescription valueForKey:key] && timeOfDay == Sunset)
                [mCurrentRank setObjectiveFailed:YES atIndex:0];
            else if (eventType == OBJ_TYPE_SCORE && gc.thisTurn.infamy >= [ObjectivesDescription valueForKey:key+1])
                [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
        }
            break;
        case RANK_CAPTAIN_KIDD:
        {
            key = 73;
            
            if (eventType == OBJ_TYPE_SINKING) {
                if (ship.deathBitmap & DEATH_BITMAP_PLAYER_CANNON) {
                    if (ship.ashBitmap == ASH_SAVAGE)
                        [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
                } else if ((ship.deathBitmap & DEATH_BITMAP_DEATH_FROM_THE_DEEP) && [ship isKindOfClass:[NavyShip class]])
                    [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
            } else if (eventType == OBJ_TYPE_VOODOO_GADGET_EXPIRED && tag == VOODOO_SPELL_DEATH_FROM_DEEP)
                [mCurrentRank setObjectiveFailed:YES atIndex:0];
            else if (eventType == OBJ_TYPE_ASH_PICKED_UP && tag == ASH_SAVAGE && [mCurrentRank isObjectiveCompletedAtIndex:1] == NO)
                [mCurrentRank setObjectiveCount:0 atIndex:1];
            else if (eventType == OBJ_TYPE_TIME_OF_DAY && day == [ObjectivesDescription valueForKey:key+2] && timeOfDay == Noon)
                [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
        }
            break;
        case RANK_CAPTAIN_OMALLEY:
        {
            key = 76;
            
            if (eventType == OBJ_TYPE_SINKING && (ship.deathBitmap & DEATH_BITMAP_GHOSTLY_TEMPEST) && [ship isKindOfClass:[PirateShip class]])
                [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
            else if (eventType == OBJ_TYPE_VOODOO_GADGET_EXPIRED && tag == VOODOO_SPELL_TEMPEST)
                [mCurrentRank setObjectiveFailed:YES atIndex:0];
            else if (eventType == OBJ_TYPE_PLANKING && day == 4)
                [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
            else if (eventType == OBJ_TYPE_SCORE && gc.thisTurn.infamy >= [ObjectivesDescription valueForKey:key+2])
                [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
        }
            break;
        case RANK_MAJOR_STEDE:
        {
            key = 79;
            
            if (eventType == OBJ_TYPE_RICOCHET) {
                if (count >= [ObjectivesDescription valueForKey:key]) {
                    [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
                    
                    if (count >= [ObjectivesDescription valueForKey:key+1]) {
                        [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
                        
                        if (count >= [ObjectivesDescription valueForKey:key+2])
                            [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
                    }
                }
            }
        }
            break;
        case RANK_BLACK_BELLAMY:
        {
            key = 82;
            
            if (eventType == OBJ_TYPE_SINKING) {
                if (ship.deathBitmap & DEATH_BITMAP_ABYSSAL_SURGE)
                    [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
            } else if (eventType == OBJ_TYPE_ASH_PICKED_UP && tag == ASH_ABYSSAL && [mCurrentRank isObjectiveCompletedAtIndex:0] == NO)
                [mCurrentRank setObjectiveCount:0 atIndex:0];
            else if (eventType == OBJ_TYPE_TIME_OF_DAY && day == [ObjectivesDescription valueForKey:key+1] && timeOfDay == Dusk)
                [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
            else if (eventType == OBJ_TYPE_SCORE && gc.thisTurn.infamy >= [ObjectivesDescription valueForKey:key+2])
                [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
        }
            break;
        case RANK_LONG_BEN:
        {
            key = 85;
            
            if (eventType == OBJ_TYPE_VOODOO_GADGET_EXPIRED) {
                if (tag == VOODOO_SPELL_SEA_OF_LAVA)
                    [mCurrentRank setObjectiveFailed:YES atIndex:0];
                else if (tag == VOODOO_SPELL_WHIRLPOOL)
                    [mCurrentRank setObjectiveFailed:YES atIndex:1];
                else if (tag == VOODOO_SPELL_FLYING_DUTCHMAN)
                    [mCurrentRank setObjectiveFailed:YES atIndex:2];
            } else if (eventType == OBJ_TYPE_OVERBOARD_DEATH) {
                if (tag == DEATH_BITMAP_SEA_OF_LAVA)
                    [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
                else if (tag == DEATH_BITMAP_WHIRLPOOL)
                    [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
            }
            else if (eventType == OBJ_TYPE_RICOCHET && count >= 2 && gc.playerShip.isFlyingDutchman)
                [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
        }
            break;
        case RANK_ADMIRAL_MORGAN:
        {
            key = 88;
            
            if (eventType == OBJ_TYPE_RICOCHET && count >= [ObjectivesDescription valueForKey:key])
                [mCurrentRank increaseObjectiveCountAtIndex:0 byAmount:1];
            else if (eventType == OBJ_TYPE_TIME_OF_DAY && day == [ObjectivesDescription valueForKey:key+1] && timeOfDay == Sunset)
                [mCurrentRank increaseObjectiveCountAtIndex:1 byAmount:1];
            else if (eventType == OBJ_TYPE_SCORE && gc.thisTurn.infamy >= [ObjectivesDescription valueForKey:key+2])
                [mCurrentRank increaseObjectiveCountAtIndex:2 byAmount:1];
        }
            break;
        case RANK_THE_DRAGON:
        default:
            break;
    }
    
    [self processRecentlyCompletedObjectives];
}

@end
