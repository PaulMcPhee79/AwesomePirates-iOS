//
//  AchievementManager.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 31/10/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "AchievementManager.h"
#import "AchievementPanel.h"
#import "CombatText.h"
#import "Score.h"
#import "ShipActor.h"
#import "OverboardActor.h"
#import "FileManager.h"
#import "NumericValueChangedEvent.h"
#import "NumericRatioChangedEvent.h"
#import "NavyShip.h"
#import "PlayerShip.h"
#import "PlayerCannon.h"
#import "PlayerCannonFiredEvent.h"
#import "PlayerDetails.h"
#import "MultiPurposeEvent.h"
#import "GameSettings.h"
#import "ProfileManager.h"
#import "GameCoder.h"
#import "Countdown.h"
#import "CCMiscConstants.h"
#import "GameController.h"
#import "Globals.h"

const int kComboMax = 3;
const float kCritBonus = 1.25f;

@interface AchievementManager ()

- (void)saveAchievement:(uint)achievementIndex percentComplete:(double)percentComplete;
- (void)onAchievementSyncStepComplete:(MultiPurposeEvent *)event;
- (void)displayView;
- (void)setComboMultiplier:(int)value;
- (void)displayInfamyBonus:(uint)bonus x:(float)x y:(float)y twoBy:(BOOL)twoBy numHops:(uint)hops color:(uint)color;
- (void)displayAchievement:(int)index;
- (void)pumpAchievementQueue;
- (void)playAchievementSound;
- (void)grantRobbinDaHoodAchievement;
- (void)grantAchievementForDeathBitmap:(uint)deathBitmap;
- (void)enemyShipSunk:(ShipActor *)ship;
//- (uint)addInfamy:(uint)infamy;
- (void)setAchievementViewData:(NSArray *)data;
- (void)setPlayerViewData:(LeaderboardDescription *)data;

@end

// This class should be a Singleton.
@implementation AchievementManager

@synthesize profileManager = mProfileManager;
@synthesize delaySavingAchievements = mDelaySavingAchievements;
@synthesize stats = mStats;
@synthesize view = mView;
@synthesize atlas = mAtlas;
@synthesize timeOfDay = mTimeOfDay;
@synthesize kabooms = mKabooms;
@synthesize slimerCount = mSlimerCount;
@synthesize comboMultiplierMax = mComboMultiplierMax;
@synthesize modelState = mModelState;
@dynamic isComboMultiplierMaxed,numAchievements,numAchievementsCompleted;

// Pass through to GameStats
@dynamic hostages,daysAtSea;

- (id)init {
	if (self = [super init]) {
		mTimeOfDay = Dawn;
		mSuspendedMode = NO;
		mDelaySavingAchievements = NO;
		mConsecutiveCannonballsHit = 0;
		mFriendlyFires = 0;
		mKabooms = 0;
        mSlimerCount = 0;
		mComboMultiplier = 0;
		mComboMultiplierMax = kComboMax;
		mModelState = StatePlayerAchievements;
		mDisplayQueue = [[NSMutableArray alloc] init];
		mAtlas = [[SPTextureAtlas atlasWithContentsOfFile:@"achievements-atlas.xml"] retain];
		mView = nil;
		mComboTextOwner = nil;
		mCombatText = nil;
		
		mAchievementViewData = nil;
		mLeaderboardViewData = nil;
		mPlayerViewData = nil;
		
		mAchievementDefs = [[Globals loadPlistArray:@"Achievements"] retain];
		mProfileManager = [[ProfileManager alloc] initWithAchievementDefs:mAchievementDefs];
        
		[mProfileManager addEventListener:@selector(onAchievementEarned:) atObject:self forType:CUST_EVENT_TYPE_ACHIEVEMENT_EARNED];
		[mProfileManager addEventListener:@selector(onAchievementsFetchedEvent:) atObject:self forType:CUST_EVENT_TYPE_ACHIEVEMENTS_FETCHED];
        [mProfileManager addEventListener:@selector(onAchievementSyncStepComplete:) atObject:self forType:CUST_EVENT_TYPE_ACH_SYNC_COMPLETE];
		[mProfileManager loadProgress];
	}
	return self;
}

- (GameStats *)stats {
	return mProfileManager.playerStats;
}

- (void)enableSuspendedMode:(BOOL)enable {
    mSuspendedMode = enable;
}

- (void)loadCombatTextWithCategory:(int)category bufferSize:(uint)bufferSize owner:(NSString *)owner {
	if (mCombatText == nil) {
		mCombatText = [[CombatText alloc] initWithCategory:category bufferSize:bufferSize];
		mComboTextOwner = [owner copy];
	}
}

- (void)fillCombatTextCache {
    [mCombatText fillCombatSpriteCache];
}

- (void)resetCombatTextCache {
    [mCombatText resetCombatSpriteCache];
}

- (void)unloadCombatTextWithOwner:(NSString *)owner {
	if ([owner isEqualToString:mComboTextOwner]) {
		[mCombatText cleanUp];
		[mCombatText autorelease];
		mCombatText = nil;
		[mComboTextOwner autorelease];
		mComboTextOwner = nil;
	}
}

- (void)hideCombatText {
	[mCombatText hideAllText];
}

- (void)setCombatTextColor:(uint)value {
	[mCombatText setColor:value];
}

- (void)resetStats {
	[mProfileManager resetStats];
}

- (void)prepareForNewGame {
	mConsecutiveCannonballsHit = 0;
	mFriendlyFires = 0;
	mKabooms = 0;
    mSlimerCount = 0;
	[self resetComboMultiplier];
	[mCombatText prepareForNewGame];
	[mProfileManager prepareForNewGame];
}

- (void)loadGameState:(GameCoder *)coder; {
	GCAchievementManager *gcam = (GCAchievementManager *)[coder objectForKey:GAME_CODER_KEY_ACHIEVEMENT_MANAGER];
	mConsecutiveCannonballsHit = gcam.consecutiveCannonballsHit;
	mFriendlyFires = gcam.friendlyFires;
	mKabooms = gcam.kabooms;
    mSlimerCount = gcam.slimerCount;
	[self setComboMultiplierMax:gcam.comboMultiplierMax];
	[self setComboMultiplier:gcam.comboMultiplier];
	[mDisplayQueue addObjectsFromArray:gcam.displayQueue];
}

- (void)saveGameState:(GameCoder *)coder {
	GCAchievementManager *gcam = (GCAchievementManager *)[coder objectForKey:GAME_CODER_KEY_ACHIEVEMENT_MANAGER];
	gcam.consecutiveCannonballsHit = mConsecutiveCannonballsHit;
	gcam.friendlyFires = mFriendlyFires;
	gcam.kabooms = mKabooms;
    gcam.slimerCount = mSlimerCount;
	gcam.comboMultiplierMax = mComboMultiplierMax;
	gcam.comboMultiplier = mComboMultiplier;
	gcam.displayQueue = mDisplayQueue;
}

- (void)saveProgress {
	mDelayedSaveRequired = NO;
	[mProfileManager saveProgress];
    [mProfileManager submitQueuedUpdateAchievements];
}

- (void)processDelayedSaves {
	if (mDelayedSaveRequired == YES)
		[self saveProgress];
}

- (void)saveAchievement:(uint)achievementIndex percentComplete:(double)percentComplete {
#ifdef CHEEKY_LITE_VERSION
    if ([GameStats isLiteAchievementIndex:achievementIndex liteIndexes:nil] == NO)
        return;
#endif
    
	if (self.delaySavingAchievements) {
        mDelayedSaveRequired = YES;
        [mProfileManager queueUpdateAchievement:achievementIndex percentComplete:percentComplete];
	} else {
		[self saveProgress];
        [mProfileManager saveAchievement:achievementIndex percentComplete:percentComplete];
    }
}

- (void)saveScore:(int64_t)score {
	[mProfileManager saveScore:score];
}

- (void)saveSpeed:(double)speed {
    [mProfileManager saveSpeed:speed];
}

- (void)syncOnlineAchievements {
    [mProfileManager syncOnlineAchievements];
}

- (void)cancelOnlineSync {
    [mProfileManager cancelOnlineSync];
}

- (void)onAchievementSyncStepComplete:(MultiPurposeEvent *)event {
    [self dispatchEvent:event];
}

- (void)applyPurchasedComboUpgrade:(int)value {
	// Do nothing
}

- (void)setComboBonusCharges:(uint)value {
	// Do nothing
}

- (void)setComboMultiplierMax:(int)value {
	mComboMultiplierMax = kComboMax;
}

- (BOOL)isComboMultiplierMaxed {
	return mComboMultiplier == mComboMultiplierMax;
}

- (void)setComboMultiplier:(int)value {
	mComboMultiplier = MAX(0, MIN(mComboMultiplierMax,value));
	[NumericValueChangedEvent dispatchEventWithDispatcher:self type:CUST_EVENT_TYPE_COMBO_MULTIPLIER_CHANGED value:[NSNumber numberWithInt:mComboMultiplier] bubbles:NO];
}

- (void)broadcastComboMultiplier {
	[self setComboMultiplier:mComboMultiplier];
}

- (void)resetComboMultiplier {
	self.comboMultiplierMax = kComboMax;
	[self setComboMultiplier:0];
}

- (uint)numAchievements {
	return ACHIEVEMENT_COUNT;
}

- (uint)numAchievementsCompleted {
	return [mProfileManager.playerStats numAchievementsCompleted];
}

- (void)onInfamyChanged:(NumericValueChangedEvent *)event {
	int64_t value = [event.value longLongValue];
	
	if (value >= 7500000) {
        if ([self achievementEarned:ACHIEVEMENT_BIT_SCOURGE_OF_THE_7_SEAS] == NO) {
            [self saveAchievement:ACHIEVEMENT_INDEX_SCOURGE_OF_THE_7_SEAS percentComplete:kAchievementCompletePercent];
        }
    }
}

- (void)prisonerPushedOverboard {
    GameController *gc = GCTRL;

    ++mProfileManager.playerStats.plankings;
    [gc.objectivesManager progressObjectiveWithEventType:OBJ_TYPE_PLANKING];
	[self grantMasterPlankerAchievement];
}

- (void)prisonerKilled:(OverboardActor *)prisoner {
	GameController *gc = GCTRL;
	uint infamyBonus = 0;
    BOOL crit = self.isComboMultiplierMaxed;
    
    if (gc.thisTurn.isGameOver || prisoner.isPreparingForNewGame)
        return;
    
    if (prisoner.isPlayer) {
        crit = YES;
        infamyBonus = prisoner.infamyBonus;
        infamyBonus = (uint)[gc.thisTurn addInfamyUnfiltered:infamyBonus];
        [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_PLAYER_EATEN]];
    } else {
        uint basePrisonerScore = CC_OVERBOARD_SCORE_BONUS;
        infamyBonus = basePrisonerScore * (crit ? kCritBonus : 1.0f);
        
        if (prisoner.deathBitmap == DEATH_BITMAP_SHARK)
            ++mProfileManager.playerStats.sharkAttacks;
        else if (prisoner.deathBitmap == DEATH_BITMAP_ACID_POOL && prisoner.prisoner && prisoner.prisoner.planked) {
            ++mProfileManager.playerStats.acidPlankings;
            [self grantBetterCallSaulAchievement];
        }
        
        infamyBonus *= [Potion bloodlustFactorForPotion:[mProfileManager.playerStats potionForKey:POTION_BLOODLUST]];
        infamyBonus = (uint)[gc.thisTurn addInfamy:infamyBonus];
    }
	
	[self displayInfamyBonus:infamyBonus
                           x:prisoner.x
                           y:prisoner.y
                       twoBy:crit
                     numHops:0
                       color:[CombatText redCombatTextColor]]; // ((crit) ? [CombatText redCombatTextColor] : SP_WHITE)];
}

- (void)setKabooms:(uint)value {
	mKabooms = value;
	
	if (mKabooms >= 12 && [self achievementEarned:ACHIEVEMENT_BIT_KABOOM] == NO) {
		[self saveAchievement:ACHIEVEMENT_INDEX_KABOOM percentComplete:kAchievementCompletePercent];
	}
}

- (void)setSlimerCount:(uint)value {
    mSlimerCount = value;
	
	if (mSlimerCount >= 15 && [self achievementEarned:ACHIEVEMENT_BIT_SLIMER] == NO) {
		[self saveAchievement:ACHIEVEMENT_INDEX_SLIMER percentComplete:kAchievementCompletePercent];
	}
}

- (uint)hostages {
    return mProfileManager.playerStats.hostages;
}

- (void)setHostages:(uint)hostages {
    mProfileManager.playerStats.hostages = hostages;
}

- (float)daysAtSea {
    return mProfileManager.playerStats.daysAtSea;
}

- (void)setDaysAtSea:(float)daysAtSea {
    mProfileManager.playerStats.daysAtSea = daysAtSea;
}

- (void)grantMasterPlankerAchievement {
	if ([self achievementEarned:ACHIEVEMENT_BIT_MASTER_PLANKER] == NO) {
		[self saveAchievement:ACHIEVEMENT_INDEX_MASTER_PLANKER percentComplete:[mProfileManager.playerStats percentComplete:ACHIEVEMENT_BIT_MASTER_PLANKER]];
	}
}

- (void)grantSmorgasbordAchievement {
	if ([self achievementEarned:ACHIEVEMENT_BIT_SMORGASBORD] == NO) {
		[self saveAchievement:ACHIEVEMENT_INDEX_SMORGASBORD percentComplete:kAchievementCompletePercent];
	}
}

- (void)grantCloseButNoCigarAchievement {
	if ([self achievementEarned:ACHIEVEMENT_BIT_CLOSE_BUT_NO_CIGAR] == NO) {
		[self saveAchievement:ACHIEVEMENT_INDEX_CLOSE_BUT_NO_CIGAR percentComplete:kAchievementCompletePercent];
	}
}

- (void)grantNoPlaceLikeHomeAchievement {
	if ([self achievementEarned:ACHIEVEMENT_BIT_NO_PLACE_LIKE_HOME] == NO) {
		[self saveAchievement:ACHIEVEMENT_INDEX_NO_PLACE_LIKE_HOME percentComplete:kAchievementCompletePercent];
	}
}

- (void)grantEntrapmentAchievement {
	if ([self achievementEarned:ACHIEVEMENT_BIT_ENTRAPMENT] == NO) {
		[self saveAchievement:ACHIEVEMENT_INDEX_ENTRAPMENT percentComplete:kAchievementCompletePercent];
	}
}

- (void)grantDeepFriedAchievement {
	if ([self achievementEarned:ACHIEVEMENT_BIT_DEEP_FRIED] == NO) {
		[self saveAchievement:ACHIEVEMENT_INDEX_DEEP_FRIED percentComplete:kAchievementCompletePercent];
	}
}

- (void)grantRoyalFlushAchievement {
	if ([self achievementEarned:ACHIEVEMENT_BIT_ROYAL_FLUSH] == NO) {
		[self saveAchievement:ACHIEVEMENT_INDEX_ROYAL_FLUSH percentComplete:kAchievementCompletePercent];
	}
}

- (BOOL)hasCopsAndRobbersAchievement {
    return [self achievementEarned:ACHIEVEMENT_BIT_COPS_AND_ROBBERS];
}

- (void)grantCopsAndRobbersAchievement {
    if ([self hasCopsAndRobbersAchievement] == NO) {
		[self saveAchievement:ACHIEVEMENT_INDEX_COPS_AND_ROBBERS percentComplete:kAchievementCompletePercent];
	}
}

- (void)grantSteamTrainAchievement {
    if ([self achievementEarned:ACHIEVEMENT_BIT_STEAM_TRAIN] == NO) {
		[self saveAchievement:ACHIEVEMENT_INDEX_STEAM_TRAIN percentComplete:kAchievementCompletePercent];
	}
}

- (void)grantBetterCallSaulAchievement {
    if ([self achievementEarned:ACHIEVEMENT_BIT_BETTER_CALL_SAUL] == NO) {
		[self saveAchievement:ACHIEVEMENT_INDEX_BETTER_CALL_SAUL percentComplete:[mProfileManager.playerStats percentComplete:ACHIEVEMENT_BIT_BETTER_CALL_SAUL]];
	}
}

- (void)grantSpeedDemonAchievement {
	if ([self achievementEarned:ACHIEVEMENT_BIT_SPEED_DEMON] == NO) {
		[self saveAchievement:ACHIEVEMENT_INDEX_SPEED_DEMON percentComplete:kAchievementCompletePercent];
	}
}

- (void)grant88MphAchievement {
	if ([self achievementEarned:ACHIEVEMENT_BIT_88_MPH] == NO) {
		[self saveAchievement:ACHIEVEMENT_INDEX_88_MPH percentComplete:kAchievementCompletePercent];
	}
}

- (void)grantRicochetAchievement:(uint)ricochetCount {
    if (ricochetCount > 0) {
        [mProfileManager.playerStats addRicochets:1 forHops:ricochetCount];
        
        if (ricochetCount == 5 && [self achievementEarned:ACHIEVEMENT_BIT_RICOCHET_MASTER] == NO)
            [self saveAchievement:ACHIEVEMENT_INDEX_RICOCHET_MASTER percentComplete:kAchievementCompletePercent];
    }
}

- (void)grantRobbinDaHoodAchievement {
    if ([self achievementEarned:ACHIEVEMENT_BIT_ROBBIN_DA_HOOD] == NO) {
		[self saveAchievement:ACHIEVEMENT_INDEX_ROBBIN_DA_HOOD percentComplete:[mProfileManager.playerStats percentComplete:ACHIEVEMENT_BIT_ROBBIN_DA_HOOD]];
	}
}

- (void)grantAchievementForDeathBitmap:(uint)deathBitmap {
    uint achBit = 0, achIndex = 0;
    
    switch (deathBitmap) {
        case DEATH_BITMAP_POWDER_KEG:
            achBit = ACHIEVEMENT_BIT_BOOM_SHAKALAKA;
            achIndex = ACHIEVEMENT_INDEX_BOOM_SHAKALAKA;
            break;
        case DEATH_BITMAP_WHIRLPOOL:
            achBit = ACHIEVEMENT_BIT_LIKE_A_RECORD_BABY;
            achIndex = ACHIEVEMENT_INDEX_LIKE_A_RECORD_BABY;
            break;
        case DEATH_BITMAP_DAMASCUS:
            achBit = ACHIEVEMENT_BIT_ROAD_TO_DAMASCUS;
            achIndex = ACHIEVEMENT_INDEX_ROAD_TO_DAMASCUS;
            break;
        case DEATH_BITMAP_BRANDY_SLICK:
            achBit = ACHIEVEMENT_BIT_WELL_DONE;
            achIndex = ACHIEVEMENT_INDEX_WELL_DONE;
            break;
        case DEATH_BITMAP_DEATH_FROM_THE_DEEP:
            achBit = ACHIEVEMENT_BIT_DAVY_JONES_LOCKER;
            achIndex = ACHIEVEMENT_INDEX_DAVY_JONES_LOCKER;
            break;
        default: break;
    }
    
    if (achBit && [self achievementEarned:achBit] == NO)
        [self saveAchievement:achIndex percentComplete:[mProfileManager.playerStats percentComplete:achBit]];
}

- (void)playerHitShip:(ShipActor *)ship distSq:(float)distSq ricocheted:(BOOL)ricocheted {
	GameController *gc = [GameController GC];
    ++mConsecutiveCannonballsHit;
    
	if (ricocheted == NO) {
        ++gc.thisTurn.cannonballsShot;
        ++gc.thisTurn.cannonballsHit;
        [GCTRL.objectivesManager progressObjectiveWithEventType:OBJ_TYPE_SHOT_FIRED];
        
        if (distSq > 122500.0f && [self achievementEarned:ACHIEVEMENT_BIT_POT_SHOT] == NO)
            [self saveAchievement:ACHIEVEMENT_INDEX_POT_SHOT percentComplete:kAchievementCompletePercent];
	}
	
	if (gc.playerShip.isCamouflaged && [ship isKindOfClass:[NavyShip class]]) {
		++mFriendlyFires;
		
		if (mFriendlyFires == 5 && [self achievementEarned:ACHIEVEMENT_BIT_FRIENDLY_FIRE] == NO) {
			[self saveAchievement:ACHIEVEMENT_INDEX_FRIENDLY_FIRE percentComplete:kAchievementCompletePercent];
		}
	}
	
	if (mConsecutiveCannonballsHit == 100 && [self achievementEarned:ACHIEVEMENT_BIT_DEADEYE_DAVY] == NO) {
		[self saveAchievement:ACHIEVEMENT_INDEX_DEADEYE_DAVY percentComplete:kAchievementCompletePercent];
	}
}

- (void)playerMissed:(uint)procType {
    GameController *gc = GCTRL;
    
	if (mSuspendedMode == NO) {
		mConsecutiveCannonballsHit = 0;
        ++gc.thisTurn.cannonballsShot;
		[self setComboMultiplier:mComboMultiplier-1];
        [gc.objectivesManager progressObjectiveWithEventType:OBJ_TYPE_SHOT_FIRED];
        [gc.objectivesManager progressObjectiveWithEventType:OBJ_TYPE_SHOT_MISSED];
	}
}

- (void)displayInfamyBonus:(uint)bonus x:(float)x y:(float)y twoBy:(BOOL)twoBy numHops:(uint)hops {
	[self displayInfamyBonus:bonus
						   x:x
						   y:y
					   twoBy:twoBy
                     numHops:hops
					   color:mCombatText.color];
}

- (void)displayInfamyBonus:(uint)bonus x:(float)x y:(float)y twoBy:(BOOL)twoBy numHops:(uint)hops color:(uint)color {
	[mCombatText combatText:[NSString stringWithFormat:@"%u", bonus]
						  x:x
						  y:y
					  twoBy:twoBy
                    numHops:hops
					  color:color];
}

- (void)merchantShipSunk:(ShipActor *)ship {
    if (ship.isPreparingForNewGame)
        return;
	++mProfileManager.playerStats.merchantShipsSunk;
	[self enemyShipSunk:ship];
}

- (void)pirateShipSunk:(ShipActor *)ship {
    if (ship.isPreparingForNewGame)
        return;
	++mProfileManager.playerStats.pirateShipsSunk;
    
    GameController *gc = GCTRL;
    
    if (gc.playerShip.isCamouflaged) {
        [mProfileManager.playerStats shipSunkWithDeathBitmap:DEATH_BITMAP_DAMASCUS];
        [self grantAchievementForDeathBitmap:DEATH_BITMAP_DAMASCUS];
    }
    
	[self enemyShipSunk:ship];
}

- (void)navyShipSunk:(ShipActor *)ship {
    if (ship.isPreparingForNewGame)
        return;
	++mProfileManager.playerStats.navyShipsSunk;
	[self enemyShipSunk:ship];
}

- (void)escortShipSunk:(ShipActor *)ship {
    if (ship.isPreparingForNewGame)
        return;
	++mProfileManager.playerStats.escortShipsSunk;
	[self enemyShipSunk:ship];
}

- (void)silverTrainSunk:(ShipActor *)ship {
    if (ship.isPreparingForNewGame)
        return;
	++mProfileManager.playerStats.silverTrainsSunk;
    
    if (ship.deathBitmap == DEATH_BITMAP_SEA_OF_LAVA)
        [self grantSteamTrainAchievement];
    
	[self enemyShipSunk:ship];
}

- (void)treasureFleetSunk:(ShipActor *)ship {
    if (ship.isPreparingForNewGame)
        return;
	++mProfileManager.playerStats.treasureFleetsSunk;
    [self grantRobbinDaHoodAchievement];
	[self enemyShipSunk:ship];
}

- (void)enemyShipSunk:(ShipActor *)ship {
	GameController *gc = GCTRL;
    
    if (gc.thisTurn.isGameOver || ship.isPreparingForNewGame)
        return;
    
    [gc.objectivesManager progressObjectiveWithEventType:OBJ_TYPE_SINKING ship:ship];
    
    // Death bitmap achievements
    uint achDeathBitmap = ship.deathBitmap;
    [mProfileManager.playerStats shipSunkWithDeathBitmap:achDeathBitmap];
    [self grantAchievementForDeathBitmap:achDeathBitmap];
    
    // ThisTurn
    ++gc.thisTurn.shipsSunk;
    [gc.thisTurn reduceMutinyCountdown:ship.mutinyReduction * [Potion resurgenceFactorForPotion:[mProfileManager.playerStats potionForKey:POTION_RESURGENCE]]];
    
	BOOL crit = self.isComboMultiplierMaxed;
	uint infamyBonus = 0;
	
	if (ship.deathBitmap == DEATH_BITMAP_PLAYER_CANNON) {
		// Apply cannon kill multipliers
		infamyBonus = (ship.ricochetBonus + ship.sunkByPlayerCannonInfamyBonus) * (crit ? kCritBonus : 1.0f);
		[self setComboMultiplier:mComboMultiplier + 1];
	} else {
		// Apply Voodoo/Munition kill multipliers
		infamyBonus = ship.infamyBonus * (crit ? kCritBonus : 1.0f);
	}
    
	infamyBonus = (uint)[gc.thisTurn addInfamy:infamyBonus];
	[self displayInfamyBonus:infamyBonus
                           x:ship.centerX
                           y:ship.centerY
                       twoBy:crit
                     numHops:ship.ricochetHop];
}

// For testing purposes
- (void)randomAchievement {
	[mDisplayQueue addObject:[mAchievementDefs objectAtIndex:RANDOM_INT(ACHIEVEMENT_INDEX_MIN,ACHIEVEMENT_INDEX_MAX)]];
}

- (BOOL)achievementEarned:(int)key {
	return [mProfileManager achievementEarned:key];
}

- (void)playAchievementSound {
	[[GameController GC].audioPlayer playSoundWithKey:@"Achievement"];
}

- (void)displayAchievement:(int)index {
    if (index >= 0 && index < mAchievementDefs.count)
        [mDisplayQueue addObject:[mAchievementDefs objectAtIndex:index]];
}

- (void)onAchievementEarned:(AchievementEarnedEvent *)event {
	[self displayAchievement:event.index];
}

- (void)setView:(AchievementPanel *)view {
	if (mView == view)
		return;
	if (mView != nil) {
		[mView removeEventListener:@selector(onAchievementHidden:) atObject:self forType:CUST_EVENT_TYPE_ACHIEVEMENT_HIDDEN];
		[mView autorelease];
		mView = nil;
	}
	mView = [view retain];
	[mView addEventListener:@selector(onAchievementHidden:) atObject:self forType:CUST_EVENT_TYPE_ACHIEVEMENT_HIDDEN];
}

- (void)onTimeOfDayChanged:(TimeOfDayChangedEvent *)event {
	mTimeOfDay = event.timeOfDay;
}

- (void)flip:(BOOL)enable {
    [mView flip:enable];
}
	 
- (void)advanceTime:(double)time {
	[self pumpAchievementQueue];
}

- (void)displayView {
	[mView display];
}

- (void)pumpAchievementQueue {
	if (mDisplayQueue.count == 0 || mView == nil || mView.busy)
		return;
	NSDictionary *achievement = [mDisplayQueue objectAtIndex:0];
	mView.title = (NSString *)[achievement objectForKey:@"name"];
	mView.text = (NSString *)[achievement objectForKey:@"earnedDesc"];
	
	uint tier = [(NSNumber *)[achievement objectForKey:@"tier"] unsignedIntValue];
	mView.tier = tier;
	[mView display];
	[mDisplayQueue removeObjectAtIndex:0];
	[self playAchievementSound];
}

- (void)onAchievementHidden:(SPEvent *)event {
	// May remove this function
}

// UITableView Data Model interface
- (void)fetchAchievements {
	[self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_GK_DATA_WILL_CHANGE]];
	[mProfileManager fetchAchievements];
}

- (void)onAchievementsFetchedEvent:(ProfileResultEvent *)event {
    if (event.errorString == nil) {
        [self setAchievementViewData:event.achievements];
        [self dispatchEvent:[StringValueEvent stringValueEventWithType:CUST_EVENT_TYPE_GK_DATA_CHANGED stringValue:event.errorString bubbles:NO]];
    } else {
        NSLog(@"%@", event.errorString);
    }
}

- (void)setAchievementViewData:(NSArray *)data {
	if (data != mAchievementViewData) {
        [data retain];
        [mAchievementViewData release];
		mAchievementViewData = data;
	}
}

- (void)setPlayerViewData:(LeaderboardDescription *)data {
	if (data != mPlayerViewData) {
        [data retain];
		[mPlayerViewData release];
		mPlayerViewData = data;
	}
}

- (NSInteger)rowCount {
	uint count = 0;
	
	switch (mModelState) {
		case StatePlayerAchievements:
			if (mAchievementViewData != nil)
				count = mAchievementViewData.count;
            count += 1; // Header row
			break;
		case StatePlayerStats:
			if (mProfileManager.playerStats != nil)
				count = mProfileManager.playerStats.numProfileStats;
			break;
		default:
			assert(0);
			break;
	}
	return (NSInteger)count;
}

- (NSString *)textForHeader {
	NSString *text = nil;
	
	switch (mModelState) {
		case StatePlayerStats:
			if (mProfileManager.playerStats != nil)
				text = mProfileManager.playerStats.alias;
			break;
		default:
			assert(0);
			break;
	}
	return text;
}

- (NSString *)titleForIndex:(NSIndexPath *)indexPath {
	NSString *text = nil;
	uint row = indexPath.row;
	
	switch (mModelState) {
		case StatePlayerAchievements:
		{
            switch (row) {
                case 0:
                {
                    if (mAchievementDefs) {
                        uint totalAchievementPoints = [mProfileManager.playerStats totalAchievementPoints:mAchievementDefs];
                        uint earnedAchievementPoints = [mProfileManager.playerStats  earnedAchievementPoints:mAchievementDefs];
                        text = [NSString stringWithFormat:@"Achievement Points: %u/%u", earnedAchievementPoints, totalAchievementPoints];
                    } else {
                        text = @"Achievements";
                    }
                }
                    break;
                default:
                {
                    uint achRow = row - 1;
                    
                    if (mAchievementViewData && achRow < mAchievementViewData.count && achRow < mAchievementDefs.count) {
                        AchievementsDescription *desc = (AchievementsDescription *)[mAchievementViewData objectAtIndex:achRow];

                        if ((achRow == ACHIEVEMENT_INDEX_88_MPH || achRow == ACHIEVEMENT_INDEX_SPEED_DEMON) && [self unlockedForIndex:indexPath] == NO) {
                            text = @"Unlock with Achievement Points of at least 88.";
                        } else {
                            text = (NSString *)[desc.achievementDef objectForKey:@"name"];
                        }
                    }
                }
                    break;
            }
		}
			break;
		default:
			assert(0);
			break;
	}
	return text;
}

- (NSString *)descForIndex:(NSIndexPath *)indexPath {
	NSString *text = nil;
	int row = indexPath.row;
	
	switch (mModelState) {
		case StatePlayerAchievements:
		{
            if (row > 0) {
                uint achRow = row - 1;
                
                if (mAchievementViewData && achRow < mAchievementViewData.count) {
                    AchievementsDescription *desc = (AchievementsDescription *)[mAchievementViewData objectAtIndex:achRow];
                    
                    if (desc.completed == YES)
                        text = (NSString *)[desc.achievementDef objectForKey:@"earnedDesc"];
                    else
                        text = (NSString *)[desc.achievementDef objectForKey:@"unearnedDesc"];
                }
            }
		}
			break;
		case StatePlayerStats:
		{
			switch (row) {
				case 0: text = @"Highest Score"; break;
				case 1: text = @"Cannonballs Fired"; break;
				case 2: text = @"Cannon Accuracy"; break;
                case 3: text = @"2x Ricochets"; break;
                case 4: text = @"3x Ricochets"; break;
                case 5: text = @"4x Ricochets"; break;
                case 6: text = @"5x Ricochets"; break;
                case 7: text = @"6x Ricochets"; break;   
				case 8: text = @"Merchant Ships Sunk"; break;
				case 9: text = @"Rival Pirate Ships Sunk"; break;
				case 10: text = @"Navy Ships Sunk"; break;
				case 11: text = @"Silver Trains Sunk"; break;
				case 12: text = @"Treasure Fleets Sunk"; break;
                case 13: text = @"Rival Pirates Captured"; break;
				case 14: text = @"Plankings"; break;
                case 15: text = @"Shark Attacks"; break;
                case 16: text = @"Days at Sea"; break;
                case 17: text = @"Fastest Race Speed"; break;
				default: assert(0); break;
			}
		}
            break;
		default:
			assert(0);
			break;
	}
	return text;
}

- (NSString *)valueForIndex:(NSIndexPath *)indexPath {
	NSString *text = nil;
	int row = indexPath.row;
	
	switch (mModelState) {
		case StatePlayerAchievements:
		{
            if (row > 0) {
                uint achRow = row - 1;
                
                if (achRow < mAchievementViewData.count) {
                    AchievementsDescription *desc = (AchievementsDescription *)[mAchievementViewData objectAtIndex:achRow];
                    int value = [(NSNumber *)[desc.achievementDef objectForKey:@"points"] intValue];
                    text = [NSString stringWithFormat:@"%d pts", value];
                }
            }
		}
            break;
		case StatePlayerStats:
		{
			if (mProfileManager.playerStats != nil) {
				switch (row) {
					case 0: text = [NSString stringWithFormat:@"%@", [Globals commaSeparatedScore:mProfileManager.playerStats.hiScore.score]]; break;
					case 1: text = [NSString stringWithFormat:@"%@", [Globals commaSeparatedValue:mProfileManager.playerStats.cannonballsShot]]; break;
					case 2: text = [NSString stringWithFormat:@"%6.2f%%", 100 * mProfileManager.playerStats.cannonballAccuracy]; break;
                    case 3:
                    case 4:
                    case 5:
                    case 6:
                    case 7:
                        // Must index from 1 to 5 (eg row-2 for row == 3)
                        text = [NSString stringWithFormat:@"%@", [Globals commaSeparatedValue:[mProfileManager.playerStats numRicochetsForHops:row-2]]]; break;
					case 8: text = [NSString stringWithFormat:@"%@", [Globals commaSeparatedValue:mProfileManager.playerStats.merchantShipsSunk]]; break;
					case 9: text = [NSString stringWithFormat:@"%@", [Globals commaSeparatedValue:mProfileManager.playerStats.pirateShipsSunk]]; break;
					case 10: text = [NSString stringWithFormat:@"%@", [Globals commaSeparatedValue:mProfileManager.playerStats.navyShipsSunk]]; break;
					case 11: text = [NSString stringWithFormat:@"%@", [Globals commaSeparatedValue:mProfileManager.playerStats.silverTrainsSunk]]; break;
					case 12: text = [NSString stringWithFormat:@"%@", [Globals commaSeparatedValue:mProfileManager.playerStats.treasureFleetsSunk]]; break;
                    case 13: text = [NSString stringWithFormat:@"%@", [Globals commaSeparatedValue:self.hostages]]; break;
					case 14: text = [NSString stringWithFormat:@"%@", [Globals commaSeparatedValue:mProfileManager.playerStats.plankings]]; break;
                    case 15: text = [NSString stringWithFormat:@"%@", [Globals commaSeparatedValue:mProfileManager.playerStats.sharkAttacks]]; break;
                    case 16: text = [NSString stringWithFormat:@"%.2f", self.daysAtSea]; break;
                    case 17: text = [NSString stringWithFormat:@"%.3f mph", (float)(mProfileManager.playerStats.fastestSpeed / 1000.0)]; break;
					default: assert(0); break;
				}
			}
		}
            break;
		default:
			assert(0);
			break;
	}
	return text;	
}

- (NSString *)subTextForIndex:(NSIndexPath *)indexPath {
	NSString *text = nil;
	return text;
}

- (double)percentForIndex:(NSIndexPath *)indexPath {
    double percent = 0;
	uint row = indexPath.row;
	
	switch (mModelState) {
		case StatePlayerAchievements:
		{
            if (row > 0) {
                uint achRow = row - 1;
                
                if (mAchievementViewData != nil && achRow < mAchievementViewData.count && achRow < mAchievementDefs.count) {
                    AchievementsDescription *desc = (AchievementsDescription *)[mAchievementViewData objectAtIndex:achRow];
                    percent = desc.percentComplete;
                }
            }
		}
            break;
		default:
			assert(0);
			break;
	}
	return percent;
}

- (NSString *)imageNameForIndex:(NSIndexPath *)indexPath {
	NSString *imageName = nil;
	uint row = indexPath.row;
	
	switch (mModelState) {
		case StatePlayerAchievements:
		{
            switch (row) {
                case 0:
                {
                    // Header row
                    imageName = @"achievements-icon";
                }
                    break;
                default:
                {
                    uint achRow = row - 1;
                    
                    if (mAchievementViewData && achRow < mAchievementViewData.count && achRow < mAchievementDefs.count) {
                        if ((achRow == ACHIEVEMENT_INDEX_88_MPH || achRow == ACHIEVEMENT_INDEX_SPEED_DEMON) && [self unlockedForIndex:indexPath] == NO) {
                            imageName = @"locked-icon";
                        } else {
                            AchievementsDescription *desc = (AchievementsDescription *)[mAchievementViewData objectAtIndex:achRow];
                            
                            if (desc.completed)
                                imageName = @"complete";
                            else
                                imageName = @"incomplete";
                            
                            uint tier = MIN(2, [(NSNumber *)[desc.achievementDef objectForKey:@"tier"] unsignedIntValue]);
                            imageName = [NSString stringWithFormat:@"tier%u-%@", tier, imageName];
                        }
                    }
                }
                    break;
            }
		}
            break;
		default:
			assert(0);
			break;
	}
	
	return imageName;
}

- (NSString *)prizeImageNameForIndex:(NSIndexPath *)indexPath completed:(BOOL)completed {
    NSString *imageName = nil;
	uint row = indexPath.row;
    
    switch (mModelState) {
		case StatePlayerAchievements:
		{
            if (row > 0) {
                uint achRow = row - 1;
                
                if (mAchievementViewData != nil && achRow < mAchievementViewData.count) {
                    AchievementsDescription *desc = (AchievementsDescription *)[mAchievementViewData objectAtIndex:achRow];
                    
                    if (completed)
                        imageName = @"ach-prize-";
                    else
                        imageName = @"ach-prize-grey-";
                    
                    uint tier = MIN(2, [(NSNumber *)[desc.achievementDef objectForKey:@"tier"] unsignedIntValue]);
                    imageName = [NSString stringWithFormat:@"%@%u", imageName, tier];
                }
            }
		}
            break;
		default:
			assert(0);
			break;
	}
    
    return imageName;
}

- (NSString *)backgroundImageNameForIndex:(NSIndexPath *)indexPath {
	NSString *imageName = nil;
	uint row = indexPath.row;
	
	switch (mModelState) {
		case StatePlayerAchievements:
		{
            switch (row) {
                case 0:
                {
                    // Header row
                    imageName = @"tableview-cell-light";
                }
                    break;
                default:
                {
                    uint achRow = row - 1;
                    
                    if (mAchievementViewData != nil && achRow < mAchievementViewData.count) {
                        AchievementsDescription *desc = (AchievementsDescription *)[mAchievementViewData objectAtIndex:achRow];
                        
                        if (desc.completed) {
                            if (row & 1)
                                imageName = @"tableview-cell-dark";
                            else
                                imageName = @"tableview-cell-light";
                        } else {
                            imageName = @"tableview-cell-grey";
                        }
                    }
                }
                    break;
            }
		}
            break;
		default:
			assert(0);
			break;
	}
	
	return imageName;
}

- (BOOL)isBinaryForIndex:(NSIndexPath *)indexPath {
	BOOL isBinary = NO;
	uint row = indexPath.row;
	
	switch (mModelState) {
		case StatePlayerAchievements:
		{
            if (row > 0) {
                uint achRow = row - 1;
                if (mAchievementViewData != nil && achRow < mAchievementViewData.count) {
                    AchievementsDescription *desc = (AchievementsDescription *)[mAchievementViewData objectAtIndex:achRow];
                    isBinary = desc.isBinary;
                }
            }
		}
            break;
		default:
			assert(0);
			break;
	}
	
	return isBinary;
}

- (BOOL)completedForIndex:(NSIndexPath *)indexPath {
	BOOL completed = NO;
	uint row = indexPath.row;
	
	switch (mModelState) {
		case StatePlayerAchievements:
		{
            if (row > 0) {
                uint achRow = row - 1;
                if (mAchievementViewData != nil && achRow < mAchievementViewData.count) {
                    AchievementsDescription *desc = (AchievementsDescription *)[mAchievementViewData objectAtIndex:achRow];
                    completed = desc.completed;
                }
            }
		}
            break;
		default:
			assert(0);
			break;
	}
	
	return completed;
}

- (BOOL)unlockedForIndex:(NSIndexPath *)indexPath {
    BOOL unlocked = YES;
	uint row = indexPath.row;
	
	switch (mModelState) {
		case StatePlayerAchievements:
		{
            if (row > 0) {
                uint achRow = row - 1;
                
                if (mAchievementDefs && (achRow == ACHIEVEMENT_INDEX_88_MPH || achRow == ACHIEVEMENT_INDEX_SPEED_DEMON))
                    unlocked = [mProfileManager.playerStats earnedAchievementPoints:mAchievementDefs] >= 88;
            }
		}
            break;
		default:
			assert(0);
			break;
	}
	
	return unlocked;
}

- (void)dealloc {
	[mView removeEventListener:@selector(onAchievementHidden:) atObject:self forType:CUST_EVENT_TYPE_ACHIEVEMENT_HIDDEN];
	[mProfileManager removeEventListener:@selector(onAchievementEarned:) atObject:self forType:CUST_EVENT_TYPE_ACHIEVEMENT_EARNED];
	[mProfileManager removeEventListener:@selector(onAchievementsFetchedEvent:) atObject:self forType:CUST_EVENT_TYPE_ACHIEVEMENTS_FETCHED];
    [mProfileManager removeEventListener:@selector(onAchievementSyncStepComplete:) atObject:self forType:CUST_EVENT_TYPE_ACH_SYNC_COMPLETE];
	
	[mCombatText release]; mCombatText = nil;
	[mComboTextOwner release]; mComboTextOwner = nil;
	[mView release]; mView = nil;
	[mAtlas release]; mAtlas = nil;
	[mDisplayQueue release]; mDisplayQueue = nil;
	[mAchievementDefs release]; mAchievementDefs = nil;
	[mAchievementViewData release]; mAchievementViewData = nil;
	[mLeaderboardViewData release]; mLeaderboardViewData = nil;
	[mProfileManager release]; mProfileManager = nil;
	[super dealloc];
}

@end
