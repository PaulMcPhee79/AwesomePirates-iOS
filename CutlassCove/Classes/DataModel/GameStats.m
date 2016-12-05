//
//  GameStats.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 8/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameStats.h"
#import "ObjectivesRank.h"
#import <GameKit/GKScore.h>
#import "DeathBitmaps.h"
#import "Globals.h"

//#define GAME_STATS_DATA_VERSION @"Version_1.0"
//#define GAME_STATS_DATA_VERSION @"Version_1.1"
#define GAME_STATS_DATA_VERSION @"Version_2.1"

const int kGSNoUpgrade = 0x0;
const int kGSLocalUpgrade = 0x1;
const int kGSCloudUpgrade = 0x2;
const int kGSAllUpgrade = kGSLocalUpgrade | kGSCloudUpgrade;

@interface GameStats ()

@property (nonatomic,copy) NSString *dataVersion;
@property (nonatomic,assign) uint powderKegSinkings;
@property (nonatomic,assign) uint whirlpoolSinkings;
@property (nonatomic,assign) uint damascusSinkings;
@property (nonatomic,assign) uint brandySlickSinkings;
@property (nonatomic,assign) uint davySinkings;

- (NSString *)keyAsString:(uint)key;
- (GKScore *)worstOfflineScore;
- (GKScore *)earliestOfflineScore;
- (GKScore *)offlineScoreForPlayerID:(NSString *)playerID range:(NSTimeInterval)range;
- (int)idolIndexInArray:(NSArray *)array forKey:(uint)key;
- (BOOL)stringExists:(NSString *)str inArray:(NSArray *)array;
- (int)indexOfString:(NSString *)str inArray:(NSArray *)array;
- (void)zeroUnsignedIntArray:(uint *)array count:(int)count;
- (void)fillUnsignedIntArray:(uint *)dest withArray:(NSArray *)src;
- (NSArray *)arrayFromUnsignedIntArray:(uint *)src count:(int)count;
- (NSString *)keyToString:(uint)key;
- (uint)achievementPoints:(NSArray *)achievementDefs completed:(BOOL)completed;

@end


@implementation GameStats

static NSArray *_liteIndexes = nil;

@synthesize dataVersion = mDataVersion;
@synthesize powderKegSinkings = mPowderKegSinkings;
@synthesize whirlpoolSinkings = mWhirlpoolSinkings;
@synthesize damascusSinkings = mDamascusSinkings;
@synthesize brandySlickSinkings = mBrandySlickSinkings;
@synthesize davySinkings = mDavySinkings;

@synthesize alias = mAlias;
@synthesize shipName = mShipName;
@synthesize cannonName = mCannonName;
@synthesize objectives = mObjectives;
@synthesize cannonballsShot = mCannonballsShot;
@synthesize cannonballsHit = mCannonballsHit;
@synthesize merchantShipsSunk = mMerchantShipsSunk;
@synthesize pirateShipsSunk = mPirateShipsSunk;
@synthesize navyShipsSunk = mNavyShipsSunk;
@synthesize escortShipsSunk = mEscortShipsSunk;
@synthesize silverTrainsSunk = mSilverTrainsSunk;
@synthesize treasureFleetsSunk = mTreasureFleetsSunk;
@synthesize plankings = mPlankings;
@synthesize hostages = mHostages;
@synthesize sharkAttacks = mSharkAttacks;
@synthesize acidPlankings = mAcidPlankings;
@synthesize daysAtSea = mDaysAtSea;
@synthesize ofChallenge = mOFChallenge;
@synthesize offlineScores = mOfflineScores;
@synthesize potions = mPotions;
@synthesize potionsTimestamp = mPotionsTimestamp;
@dynamic cannonballAccuracy,writableForm,numProfileStats;
@dynamic trinkets,gadgets,abilities,trinketAbilities,gadgetAbilities,shipNames,cannonNames;

+ (uint)achievementBitForIndex:(int)index {
	if (index < 30)
		return 1<<index;
	else
		return (1 << 30) | (1<<(index - 30));
}

+ (NSArray *)liteAchievementIndexes {
    return [NSArray arrayWithObjects:
            [NSNumber numberWithUnsignedInt:ACHIEVEMENT_INDEX_POT_SHOT],
            [NSNumber numberWithUnsignedInt:ACHIEVEMENT_INDEX_DEADEYE_DAVY],
            [NSNumber numberWithUnsignedInt:ACHIEVEMENT_INDEX_SMORGASBORD],
            [NSNumber numberWithUnsignedInt:ACHIEVEMENT_INDEX_CLOSE_BUT_NO_CIGAR],
            [NSNumber numberWithUnsignedInt:ACHIEVEMENT_INDEX_NO_PLACE_LIKE_HOME],
            [NSNumber numberWithUnsignedInt:ACHIEVEMENT_INDEX_KABOOM],
            [NSNumber numberWithUnsignedInt:ACHIEVEMENT_INDEX_ROYAL_FLUSH],
            [NSNumber numberWithUnsignedInt:ACHIEVEMENT_INDEX_MASTER_PLANKER],
            [NSNumber numberWithUnsignedInt:ACHIEVEMENT_INDEX_ROBBIN_DA_HOOD],
            [NSNumber numberWithUnsignedInt:ACHIEVEMENT_INDEX_LIKE_A_RECORD_BABY],
            nil];
}

+ (BOOL)isLiteAchievementIndex:(uint)index liteIndexes:(NSArray *)liteIndexes {
    BOOL isValidIndex = NO;
    
    if (liteIndexes == nil) {
        if (_liteIndexes == nil)
            _liteIndexes = [[NSArray alloc] initWithArray:[GameStats liteAchievementIndexes]];
        liteIndexes = _liteIndexes;
    }
    
    for (NSNumber *liteIndex in liteIndexes) {
        if ([liteIndex unsignedIntValue] == index) {
            isValidIndex = YES;
            break;
        }
    }
    
    return isValidIndex;
}

+ (NSDictionary *)blankStatsDictionaryForAlias:(NSString *)alias {
	NSArray *trinkets = [Idol trinketList];
	NSArray *gadgets = [Idol gadgetList];
    NSDictionary *potions = [Potion potionDictionary];
    
	NSArray *achievements = [NSArray arrayWithObjects:
							 [NSNumber numberWithUnsignedInt:0],
							 [NSNumber numberWithUnsignedInt:0],
							 [NSNumber numberWithUnsignedInt:0],
							 [NSNumber numberWithUnsignedInt:0],
							 nil];
    
    NSMutableArray *objectives = [NSMutableArray arrayWithCapacity:NUM_OBJECTIVES_RANKS];
    
    for (int i = 0; i < NUM_OBJECTIVES_RANKS; ++i)
        [objectives addObject:[ObjectivesRank objectivesRankWithRank:i]];
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
            GAME_STATS_DATA_VERSION, @"dataVersion",
			alias, @"alias",
			@"Man o' War", @"shipName",
			@"Perisher", @"cannonName",
			[NSArray arrayWithObjects:@"Man o' War", @"Speedboat", nil], @"shipNames",
			[NSArray arrayWithObjects:@"Perisher", nil], @"cannonNames",
			trinkets, @"trinkets",
			gadgets, @"gadgets",
            potions, @"potions",
            [NSDictionary dictionary], @"hiScores",
			achievements, @"achievements",
            [NSArray arrayWithArray:objectives], @"objectives",
			[NSNumber numberWithUnsignedInt:0], @"cannonballsShot",
			[NSNumber numberWithUnsignedInt:0], @"cannonballsHit",
			[NSNumber numberWithUnsignedInt:0], @"merchantShipsSunk",
			[NSNumber numberWithUnsignedInt:0], @"pirateShipsSunk",
			[NSNumber numberWithUnsignedInt:0], @"navyShipsSunk",
			[NSNumber numberWithUnsignedInt:0], @"escortShipsSunk",
			[NSNumber numberWithUnsignedInt:0], @"silverTrainsSunk",
			[NSNumber numberWithUnsignedInt:0], @"treasureFleetsSunk",
			[NSNumber numberWithUnsignedInt:0], @"plankings",
            [NSNumber numberWithUnsignedInt:0], @"hostages",
            [NSNumber numberWithUnsignedInt:0], @"sharkAttacks",
            [NSNumber numberWithUnsignedInt:0], @"acidPlankings",
            [NSNumber numberWithFloat:0], @"daysAtSea",
            [NSNumber numberWithInt:0], @"fastestSpeed",
            [NSNumber numberWithUnsignedInt:0], @"powderKegSinkings",
            [NSNumber numberWithUnsignedInt:0], @"whirlpoolSinkings",
            [NSNumber numberWithUnsignedInt:0], @"damascusSinkings",
            [NSNumber numberWithUnsignedInt:0], @"brandySlickSinkings",
            [NSNumber numberWithUnsignedInt:0], @"slimerSinkings",
            [NSNumber numberWithUnsignedInt:0], @"davySinkings",
            [NSNumber numberWithDouble:(double)CFAbsoluteTimeGetCurrent() - (double)kCFAbsoluteTimeIntervalSince1970],
			[NSArray array], @"checksums",
			nil];
}

- (id)initWithAlias:(NSString *)alias {
	if (self = [super init]) {
        self.dataVersion = GAME_STATS_DATA_VERSION;
		self.alias = alias;
		[self resetAllStats];
        mPotionsTimestamp = (double)CFAbsoluteTimeGetCurrent() - (double)kCFAbsoluteTimeIntervalSince1970;
		mShipName = [[NSString stringWithFormat:@"%@", @"Man o' War"] copy];
		mCannonName = [[NSString stringWithFormat:@"%@", @"Perisher"] copy];
		mShipNames = [[NSMutableArray alloc] initWithObjects:
					  @"Man o' War",
                      @"Speedboat",
					  nil];
		mCannonNames = [[NSMutableArray alloc] initWithObjects:
						@"Perisher",
						nil];
        mHiScores = [[NSMutableDictionary alloc] init];
		mTrinkets = [[NSMutableArray alloc] initWithArray:[Idol trinketList]];
		mGadgets = [[NSMutableArray alloc] initWithArray:[Idol gadgetList]];
        mPotions = [[NSDictionary alloc] initWithDictionary:[Potion potionDictionary]];
		
        NSMutableArray *objectives = [NSMutableArray arrayWithCapacity:NUM_OBJECTIVES_RANKS];
        
        for (int i = 0; i < NUM_OBJECTIVES_RANKS; ++i)
            [objectives addObject:[ObjectivesRank objectivesRankWithRank:i]];
        mObjectives = [[NSMutableArray alloc] initWithArray:objectives];
        
        mOfflineScores = [[NSMutableArray alloc] init];
	}
	return self;
}

- (id)initWithStatsDictionary:(NSDictionary *)dict {
	if (self = [super init]) {
        mDataVersion = nil;
		mAlias = nil;
		[self resetAllStats];
		
		if (dict != nil) {
            self.dataVersion = (NSString *)[dict objectForKey:@"dataVersion"];
			self.alias = (NSString *)[dict objectForKey:@"alias"];
			mShipName = [(NSString *)[dict objectForKey:@"shipName"] copy];
			mCannonName = [(NSString *)[dict objectForKey:@"cannonName"] copy];
			mShipNames = [[NSMutableArray arrayWithArray:(NSArray *)[dict objectForKey:@"shipNames"]] retain];
			mCannonNames = [[NSMutableArray arrayWithArray:(NSArray *)[dict objectForKey:@"cannonNames"]] retain];
			mTrinkets = [[NSMutableArray arrayWithArray:(NSArray *)[dict objectForKey:@"trinkets"]] retain];
			mGadgets = [[NSMutableArray arrayWithArray:(NSArray *)[dict objectForKey:@"gadgets"]] retain];
            mPotions = [[NSDictionary alloc] initWithDictionary:(NSDictionary *)[dict objectForKey:@"potions"]];
            mHiScores = [[NSMutableDictionary alloc] initWithDictionary:(NSDictionary *)[dict objectForKey:@"hiScores"]];
			[self fillUnsignedIntArray:mAchievementBitmap withArray:(NSArray *)[dict objectForKey:@"achievements"]];
            mObjectives = [[NSArray alloc] initWithArray:(NSArray *)[dict objectForKey:@"objectives"]];
			mCannonballsShot = [(NSNumber *)[dict objectForKey:@"cannonballsShot"] unsignedIntValue];
			mCannonballsHit = [(NSNumber *)[dict objectForKey:@"cannonballsHit"] unsignedIntValue];
            [self fillUnsignedIntArray:mRicochets withArray:(NSArray *)[dict objectForKey:@"ricochets"]];
			mMerchantShipsSunk = [(NSNumber *)[dict objectForKey:@"merchantShipsSunk"] unsignedIntValue];
			mPirateShipsSunk = [(NSNumber *)[dict objectForKey:@"pirateShipsSunk"] unsignedIntValue];
			mNavyShipsSunk = [(NSNumber *)[dict objectForKey:@"navyShipsSunk"] unsignedIntValue];
			mEscortShipsSunk = [(NSNumber *)[dict objectForKey:@"escortShipsSunk"] unsignedIntValue];
			mSilverTrainsSunk = [(NSNumber *)[dict objectForKey:@"silverTrainsSunk"] unsignedIntValue];
			mTreasureFleetsSunk = [(NSNumber *)[dict objectForKey:@"treasureFleetsSunk"] unsignedIntValue];
			mPlankings = [(NSNumber *)[dict objectForKey:@"plankings"] unsignedIntValue];
            mHostages = [(NSNumber *)[dict objectForKey:@"hostages"] unsignedIntValue];
            mSharkAttacks = [(NSNumber *)[dict objectForKey:@"sharkAttacks"] unsignedIntValue];
            mAcidPlankings = [(NSNumber *)[dict objectForKey:@"acidPlankings"] unsignedIntValue];
            mDaysAtSea = [(NSNumber *)[dict objectForKey:@"daysAtSea"] floatValue];
            mFastestSpeed = [(NSNumber *)[dict objectForKey:@"fastestSpeed"] intValue];
            mPowderKegSinkings = [(NSNumber *)[dict objectForKey:@"powderKegSinkings"] unsignedIntValue];
            mWhirlpoolSinkings = [(NSNumber *)[dict objectForKey:@"whirlpoolSinkings"] unsignedIntValue];
            mDamascusSinkings = [(NSNumber *)[dict objectForKey:@"damascusSinkings"] unsignedIntValue];
            mBrandySlickSinkings = [(NSNumber *)[dict objectForKey:@"brandySlickSinkings"] unsignedIntValue];
            mDavySinkings = [(NSNumber *)[dict objectForKey:@"davySinkings"] unsignedIntValue];
            mOfflineScores = [[NSMutableArray alloc] initWithArray:(NSArray *)[dict objectForKey:@"checksums"]];
            mPotionsTimestamp = [(NSNumber *)[dict objectForKey:@"potionsTimestamp"] doubleValue];
		}
	}
	return self;
}

- (NSString *)keyAsString:(uint)key {
    return [NSString stringWithFormat:@"%u", key];
}

- (void)zeroUnsignedIntArray:(uint *)array count:(int)count {
	for (int i = 0; i < count; ++i)
		array[i] = 0;
}

- (void)fillUnsignedIntArray:(uint *)dest withArray:(NSArray *)src {
	for (NSNumber *number in src) {
		*dest = [number unsignedIntValue];
		++dest;
	}
}

- (NSArray *)arrayFromUnsignedIntArray:(uint *)src count:(int)count {
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
	
	for (int i = 0; i < count; ++i)
		[array addObject:[NSNumber numberWithUnsignedInt:src[i]]];
	return [NSArray arrayWithArray:array];
}

- (Score *)hiScore {
    return [self hiScoreForGameMode:CC_GAME_MODE_DEFAULT];
}

- (void)setHiScore:(int64_t)value {
    [self setHiScore:value forGameMode:CC_GAME_MODE_DEFAULT];
}

- (Score *)hiScoreForGameMode:(NSString *)mode {
    Score *score = (Score *)[mHiScores objectForKey:mode];
    
    if (score == nil) {
        score = [Score scoreWithName:self.alias score:0 date:[NSDate date]];
        [mHiScores setObject:score forKey:mode];
    }
    
    return score;
}

- (void)setHiScore:(int64_t)value forGameMode:(NSString *)mode {
    Score *score = [self hiScoreForGameMode:mode];
    
    if (value > score.score) {
        score.playerName = self.alias;
        score.score = value;
    }
}

- (int64_t)fastestSpeed {
    return (int64_t)mFastestSpeed;
}

- (void)setFastestSpeed:(int64_t)value {
    mFastestSpeed = (int)value;
}

- (GKScore *)offlineScoreForPlayerID:(NSString *)playerID range:(NSTimeInterval)range {
#if 1
    return nil;
#else
    if ([ResManager isGameCenterAvailable] == NO || playerID == nil)
        return nil;
    
    GKScore *score = nil;
    NSDate *cutoffDate = [NSDate date];
    
    if ([cutoffDate respondsToSelector:@selector(dateByAddingTimeInterval:)] == NO)
        return nil;
    
    cutoffDate = [cutoffDate dateByAddingTimeInterval:range];
    
    for (GKScore *offlineScore in mOfflineScores) {
        if ([offlineScore.playerID isEqualToString:playerID] && [cutoffDate earlierDate:offlineScore.date] == cutoffDate) {
            if (score == nil || offlineScore.value > score.value)
                score = offlineScore;
        }
    }
    
    return score;
#endif
}

- (GKScore *)todayOfflineScoreForPlayerID:(NSString *)playerID {
    return [self offlineScoreForPlayerID:playerID range:-24 * 60 * 60];
}

- (GKScore *)thisWeekOfflineScoreForPlayerID:(NSString *)playerID {
    return [self offlineScoreForPlayerID:playerID range:-7 * 24 * 60 * 60];
}

- (GKScore *)allTimeOfflineScoreForPlayerID:(NSString *)playerID {
    // One year is long enough to store a score offline
    return [self offlineScoreForPlayerID:playerID range:-365 * 24 * 60 * 60];
}

- (void)addOfflineScore:(GKScore *)score {
#if 0
    if ([ResManager isGameCenterAvailable] == NO || score == nil || score.playerID == nil)
        return;
    if ([score.date respondsToSelector:@selector(dateByAddingTimeInterval:)] == NO)
        return;
    
    NSDate *cutoffDate = [score.date dateByAddingTimeInterval:-24 * 60 * 60];
    GKScore *replacableScore = nil;
    BOOL hasOfflineScore = NO;
    
    for (GKScore *offlineScore in mOfflineScores) {
        // Replace other scores that have been recorded within the last 24 hours and that are less than the score parameter
        if ([offlineScore.playerID isEqualToString:score.playerID]) {
            hasOfflineScore = YES;
            
            if ([cutoffDate earlierDate:offlineScore.date] == cutoffDate) {
                if (score.value > offlineScore.value) {
                    replacableScore = offlineScore;
                    break;
                }
            }
        }
    }
    
    if (replacableScore == nil && mOfflineScores.count >= 10) {
        replacableScore = [self worstOfflineScore];
        
        // If the user has a better score than this, then ignore it
        if (hasOfflineScore && replacableScore && replacableScore.value >= score.value)
            return;
    }
    
    [self removeOfflineScore:replacableScore];
    [mOfflineScores addObject:score];
    
    //for (GKScore *offlineScore in mOfflineScores)
    //    NSLog(@"OFFLINE SCORE: %lld", offlineScore.value);
#endif
}

- (void)removeOfflineScore:(GKScore *)score {
#if 0
    if (score)
        [mOfflineScores removeObject:score];
#endif
}

- (void)clearOfflineScores {
#if 0
    [mOfflineScores removeAllObjects];
#endif
}

- (void)clearOfflineScoreForPlayerID:(NSString *)playerID range:(NSTimeInterval)range {
#if 0
    if ([ResManager isGameCenterAvailable] == NO || playerID == nil)
        return;
    
    NSDate *cutoffDate = [NSDate date];
    
    if ([cutoffDate respondsToSelector:@selector(dateByAddingTimeInterval:)] == NO)
        return;
    
    cutoffDate = [cutoffDate dateByAddingTimeInterval:range];
    NSMutableArray *clearArray = [NSMutableArray arrayWithCapacity:mOfflineScores.count];
    
    for (GKScore *offlineScore in mOfflineScores) {
        if ([offlineScore.playerID isEqualToString:playerID] && [cutoffDate earlierDate:offlineScore.date] == cutoffDate)
            [clearArray addObject:offlineScore];
    }
    
    [mOfflineScores removeObjectsInArray:clearArray];
#endif
}
            
- (GKScore *)worstOfflineScore {
#if 1
    return nil;
#else
    GKScore *worstScore = nil;
    
    for (GKScore *score in mOfflineScores) {
        if (worstScore == nil)
            worstScore = score;
        else if (score.value < worstScore.value)
            worstScore = score;
    }
    
    return worstScore;
#endif
}

- (GKScore *)earliestOfflineScore {
#if 1
    return nil;
#else
    GKScore *earliestScore = nil;
    NSDate *earliestDate = nil;
    
    for (GKScore *score in mOfflineScores) {
        if (earliestDate == nil)
            earliestDate = score.date;
        else if (earliestDate != [earliestDate earlierDate:score.date])
            earliestDate = score.date;
        
        if (earliestDate == score.date)
            earliestScore = score;
        
        // Remove scores with nil dates first
        if (earliestDate == nil)
            break;
    }

    return earliestScore;
#endif
}

- (int)idolIndexInArray:(NSArray *)array forKey:(uint)key {
	int index = 0;
	
	for (Idol *idol in array) {
		if (idol.key == key)
			return index;
		++index;
	}
	return -1;
}

- (void)addRicochets:(uint)count forHops:(uint)hops {
    if (hops >= 1 && hops <= 5)
        mRicochets[hops-1] += count;
}

- (uint)numRicochetsForHops:(uint)hops {
    uint count = 0;
    
    if (hops >= 1 && hops <= 5)
        count = mRicochets[hops-1];
    return count;
}

- (Idol *)idolForKey:(uint)key {
    return [self equippedIdolForKey:key];
}

- (Idol *)equippedIdolForKey:(uint)key {
	Idol *idol = nil;
	
	for (Idol *trinket in mTrinkets) {
		if (trinket.key == key) {
			idol = trinket;
			break;
		}
	}
	
	if (idol == nil) {
		for (Idol *gadget in mGadgets) {
			if (gadget.key == key) {
				idol = gadget;
				break;
			}
		}
	}
	
	return idol;
}

- (Idol *)trinketAtSlot:(int)slot {
	Idol *trinket = nil;
	
	if (slot < mTrinkets.count)
		trinket = (Idol *)[mTrinkets objectAtIndex:slot];
	return trinket;
}

- (void)setTrinket:(uint)trinket atSlot:(int)slot {
	assert((trinket<<16) == 0);
	
	Idol *idol = [self idolForKey:trinket];
	
	if (slot < mTrinkets.count && idol) {
		int index = [self idolIndexInArray:mTrinkets forKey:trinket];
		
		if (index != slot) {
			[mTrinkets insertObject:idol atIndex:slot];
			[mTrinkets removeObjectAtIndex:slot+1];
		}
	}
}

- (Idol *)gadgetAtSlot:(int)slot {
	Idol *gadget = nil;
	
	if (slot < mGadgets.count)
		gadget = (Idol *)[mGadgets objectAtIndex:slot];
	return gadget;
}

- (void)setGadget:(uint)gadget atSlot:(int)slot {
	assert((gadget>>16) == 0);
	
	Idol *idol = [self idolForKey:gadget];
	
	if (slot < mGadgets.count && idol) {
		int index = [self idolIndexInArray:mGadgets forKey:gadget];
		
		if (index != slot) {
			[mGadgets insertObject:idol atIndex:slot];
			[mGadgets removeObjectAtIndex:slot+1];
		}
	}
}

- (void)addTrinket:(uint)trinket {
	Idol *idol = [self idolForKey:trinket];
	
	if (idol)
		++idol.rank;
	else
        [mTrinkets addObject:[Idol idolWithKey:trinket]];
}

- (void)removeTrinket:(uint)trinket {
	int index = [self idolIndexInArray:mTrinkets forKey:trinket];
	
	if (index != -1)
        [mTrinkets removeObjectAtIndex:index];
}

- (BOOL)containsTrinket:(uint)trinket {
	return ([self idolForKey:trinket] != nil);
}

- (void)addGadget:(uint)gadget {
	Idol *idol = [self idolForKey:gadget];
	
	if (idol)
		++idol.rank;
	else
		[mGadgets addObject:[Idol idolWithKey:gadget]];
}

- (void)removeGadget:(uint)gadget {
	int index = [self idolIndexInArray:mGadgets forKey:gadget];
	
	if (index != -1)
        [mGadgets removeObjectAtIndex:index];
}

- (BOOL)containsGadget:(uint)gadget {
	return ([self idolForKey:gadget] != nil);
}

- (Potion *)potionForKey:(uint)key {
    return [mPotions objectForKey:[self keyAsString:key]];
}

+ (NSArray *)activatedPotionsFromPotions:(NSDictionary *)potions {
    if (potions == nil || potions.count == 0)
        return [NSArray array];
    
    NSMutableArray *potionArray = [NSMutableArray arrayWithCapacity:potions.count];
    
    for (NSString *key in potions) {
        Potion *potion = (Potion *)[potions objectForKey:key];
        
        if (potion.isActive)
            [potionArray addObject:potion];
    }
    
    [potionArray sortUsingSelector:@selector(comparePotion:)];
    return [NSArray arrayWithArray:potionArray];
}

- (void)activatePotion:(BOOL)activate forKey:(uint)key {
    Potion *potion = [self potionForKey:key];
    potion.isActive = activate;
    
    if (activate)
        [self enforcePotionConstraints];
}

- (void)enforcePotionConstraints {
#ifndef CHEEKY_LITE_VERSION
    ObjectivesRank *objRank = [ObjectivesRank getCurrentRankFromRanks:mObjectives];
    uint rank = (objRank) ? objRank.rank : 0;
    NSMutableArray *potionArray = [NSMutableArray arrayWithCapacity:mPotions.count];
    
    // Gather active potions and deactivate potions that shouldn't be active due to rank restrictions.
    for (NSString *key in mPotions) {
        Potion *potion = (Potion *)[mPotions objectForKey:key];
        
        if (potion.isActive) {
            if ([Potion requiredRankForPotion:potion] > rank)
                potion.isActive = NO;
            else
                [potionArray addObject:potion];
        }
    }
    
    // Deactivate potions that exceed the limit of permitted active potions.
    uint i = 0, limit = [Potion activePotionLimitForRank:rank];
    [potionArray sortUsingSelector:@selector(comparePotion:)];
    
    for (Potion *potion in potionArray) {
        if (i >= limit)
            potion.isActive = NO;
        ++i;
    }
#else
    for (NSString *key in mPotions) {
        Potion *potion = (Potion *)[mPotions objectForKey:key];
        potion.isActive = NO;
    }
#endif
}

- (void)enforcePotionRequirements {
#ifndef CHEEKY_LITE_VERSION
    NSArray *activatedPotions = [GameStats activatedPotionsFromPotions:self.potions];
    ObjectivesRank *objRank = [ObjectivesRank getCurrentRankFromRanks:mObjectives];
    uint rank = (objRank) ? objRank.rank : 0;
    uint limit = [Potion activePotionLimitForRank:rank];
    uint activeCount = activatedPotions.count;
    
    // Activate potions up to the expected level for this rank
    if (activeCount < limit) {
        NSArray *unlockedPotionKeys = [Potion potionKeysForRank:rank];
        
        for (NSNumber *key in unlockedPotionKeys) {
            if (activeCount >= limit)
                break;
            Potion *potion = [self.potions objectForKey:[self keyAsString:[key unsignedIntValue]]];
            
            if (potion && potion.isActive == NO) {
                potion.isActive = YES;
                ++activeCount;
            }
        }
    }
#endif
}

- (uint)numProfileStats {
	return 18;
}

- (NSArray *)trinkets {
	return [NSArray arrayWithArray:mTrinkets];
}

- (NSArray *)gadgets {
	return [NSArray arrayWithArray:mGadgets];
}

- (uint)abilities {
	return (self.trinketAbilities | self.gadgetAbilities);
}

- (uint)trinketAbilities {
	uint abilities = 0;
	
	for (Idol *trinket in mTrinkets)
		abilities |= trinket.key;
	return abilities;
}

- (uint)gadgetAbilities {
	uint abilities = 0;
	
	for (Idol *gadget in mGadgets)
		abilities |= gadget.key;
	return abilities;
}

- (uint *)getAchievementBitmap {
	return mAchievementBitmap;
}

- (uint)getAchievementBit:(uint)key {
	uint index = key>>30;
	assert(index < 4);
	return mAchievementBitmap[index] & (key & 0x3fffffff);
}

- (void)setAchievementBit:(uint)key {
	uint index = key>>30;
	assert(index < 4);
	mAchievementBitmap[index] |= (key & 0x3fffffff);
}

- (BOOL)stringExists:(NSString *)str inArray:(NSArray *)array {
	for (NSString *key in array) {
		if ([str isEqualToString:key])
			return YES;
	}
	return NO;
}

- (int)indexOfString:(NSString *)str inArray:(NSArray *)array {
	int index = 0;
	
	for (NSString *key in array) {
		if ([str isEqualToString:key])
			return index;
		++index;
	}
	return -1;
}

- (NSArray *)shipNames {
	return [NSArray arrayWithArray:mShipNames];
}

- (void)setShipName:(NSString *)name {
	if ([mShipName isEqualToString:name] || [self stringExists:name inArray:mShipNames] == NO)
		return;
	NSString *temp = [name copy];
	[mShipName release];
	mShipName = temp;
	[self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_SHIP_TYPE_CHANGED]];
}

- (BOOL)containsShipName:(NSString *)name {
	BOOL result = NO;
	
	for (NSString *shipName in mShipNames) {
		if ([shipName isEqualToString:name]) {
			result = YES;
			break;
		}
	}
	return result;
}

- (void)addShipName:(NSString *)name {
	if ([self stringExists:name inArray:mShipNames] == NO)
		[mShipNames addObject:name];
}

- (void)removeShipName:(NSString *)name {
	int index = [self indexOfString:name inArray:mShipNames];
	
	if (index != -1)
		[mShipNames removeObjectAtIndex:index];
}

- (NSArray *)cannonNames {
	return [NSArray arrayWithArray:mCannonNames];
}

- (void)setCannonName:(NSString *)name {
	if ([mCannonName isEqualToString:name] || [self stringExists:name inArray:mCannonNames] == NO)
		return;
	NSString *temp = [name copy];
	[mCannonName release];
	mCannonName = nil;
	mCannonName = temp;
	[self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_CANNON_TYPE_CHANGED]];
}

- (BOOL)containsCannonName:(NSString *)name {
	BOOL result = NO;
	
	for (NSString *cannonName in mCannonNames) {
		if ([cannonName isEqualToString:name]) {
			result = YES;
			break;
		}
	}
	return result;
}

- (void)addCannonName:(NSString *)name {
	if ([self stringExists:name inArray:mCannonNames] == NO)
		[mCannonNames addObject:name];
}

- (void)removeCannonName:(NSString *)name {
	int index = [self indexOfString:name inArray:mCannonNames];
	
	if (index != -1)
		[mCannonNames removeObjectAtIndex:index];
}

- (uint)earnedAchievementPoints:(NSArray *)achievementDefs {
    return [self achievementPoints:achievementDefs completed:YES];
}

- (uint)totalAchievementPoints:(NSArray *)achievementDefs {
    return [self achievementPoints:achievementDefs completed:NO];
}

- (uint)achievementPoints:(NSArray *)achievementDefs completed:(BOOL)completed {
	uint points = 0;
	
	for (int i = 0, bitmapIndex = 0, bitMask = 0; i < ACHIEVEMENT_COUNT; ++i) {
#ifdef CHEEKY_LITE_VERSION
        if ([GameStats isLiteAchievementIndex:(uint)i liteIndexes:nil])
        {
#endif
		if (completed == NO || (mAchievementBitmap[bitmapIndex] & (1<<bitMask))) {
			if (achievementDefs.count > i) {
				NSDictionary *dict = [achievementDefs objectAtIndex:i];
				
				if (dict != nil)
					points += [(NSNumber *)[dict objectForKey:@"points"] unsignedIntValue];
			}
		}
#ifdef CHEEKY_LITE_VERSION
        }      
#endif
		if (++bitMask == 30) {
			bitMask = 0;
			++bitmapIndex;
		}
	}
	return points;
}

- (uint)numAchievementsCompleted {
	uint count = 0;
	
	for (int i = 0, bitmapIndex = 0, bitMask = 0; i < ACHIEVEMENT_COUNT; ++i) {
		if (mAchievementBitmap[bitmapIndex] & (1<<bitMask))
			++count;
		
		if (++bitMask == 30) {
			bitMask = 0;
			++bitmapIndex;
		}
	}
	return count;
}

- (float)cannonballAccuracy {
	float value = 0;
	
	if (mCannonballsShot != 0)
		value = mCannonballsHit / (float)mCannonballsShot;
	return value;
}

- (NSDictionary *)writableForm {
	return [NSDictionary dictionaryWithObjectsAndKeys:
			mAlias, @"alias",
			mShipName, @"shipName",
			mCannonName, @"cannonName",
			mShipNames, @"shipNames",
			mCannonNames, @"cannonNames",
			self.trinkets, @"trinkets",
			self.gadgets, @"gadgets",
			[self arrayFromUnsignedIntArray:mAchievementBitmap count:4], @"achievements",
			[NSNumber numberWithUnsignedInt:mCannonballsShot], @"cannonballsShot",
			[NSNumber numberWithUnsignedInt:mCannonballsHit], @"cannonballsHit",
            [self arrayFromUnsignedIntArray:mRicochets count:5], @"ricochets",
			[NSNumber numberWithUnsignedInt:mMerchantShipsSunk], @"merchantShipsSunk",
			[NSNumber numberWithUnsignedInt:mPirateShipsSunk], @"pirateShipsSunk",
			[NSNumber numberWithUnsignedInt:mNavyShipsSunk], @"navyShipsSunk",
			[NSNumber numberWithUnsignedInt:mEscortShipsSunk], @"escortShipsSunk",
			[NSNumber numberWithUnsignedInt:mSilverTrainsSunk], @"silverTrainsSunk",
			[NSNumber numberWithUnsignedInt:mTreasureFleetsSunk], @"treasureFleetsSunk",
			[NSNumber numberWithUnsignedInt:mPlankings], @"plankings",
            [NSNumber numberWithUnsignedInt:mHostages], @"hostages",
            [NSNumber numberWithUnsignedInt:mSharkAttacks], @"sharkAttacks",
            [NSNumber numberWithUnsignedInt:mAcidPlankings], @"acidPlankings",
            [NSNumber numberWithFloat:mDaysAtSea], @"daysAtSea",
            [NSNumber numberWithInt:mFastestSpeed], @"fastestSpeed",
            [NSNumber numberWithUnsignedInt:mPowderKegSinkings], @"powderKegSinkings",
            [NSNumber numberWithUnsignedInt:mWhirlpoolSinkings], @"whirlpoolSinkings",
            [NSNumber numberWithUnsignedInt:mDamascusSinkings], @"damascusSinkings",
            [NSNumber numberWithUnsignedInt:mBrandySlickSinkings], @"brandySlickSinkings",
            [NSNumber numberWithUnsignedInt:mDavySinkings], @"davySinkings",
            [NSNumber numberWithDouble:mPotionsTimestamp], @"potionsTimestamp",
			nil];
}

- (void)prepareForNewGame {
    // Do nothing
}

- (void)resetObjectives {
    [mObjectives release]; mObjectives = nil;
    
    NSMutableArray *objectives = [NSMutableArray arrayWithCapacity:NUM_OBJECTIVES_RANKS];
    
    for (int i = 0; i < NUM_OBJECTIVES_RANKS; ++i)
        [objectives addObject:[ObjectivesRank objectivesRankWithRank:i]];
    mObjectives = [[NSMutableArray alloc] initWithArray:objectives];
}

- (void)resetAchievements {
    for (int i = 0; i < 4; ++i)
        mAchievementBitmap[i] = 0;
    
    mTreasureFleetsSunk = 0;
    mPlankings = 0;
    mPowderKegSinkings = 0;
    mWhirlpoolSinkings = 0;
    mDamascusSinkings = 0;
    mBrandySlickSinkings = 0;
    mDavySinkings = 0;
    mAcidPlankings = 0;
}

- (void)resetAllStats {
	self.shipName = nil;
	self.cannonName = nil;
	[mShipNames release];
	mShipNames = nil;
	[mCannonNames release];
	mCannonNames = nil;
    [mHiScores removeAllObjects];
	[mTrinkets release];
	mTrinkets = nil;
	[mGadgets release];
	mGadgets = nil;
	
	mCannonballsShot = 0;
	mCannonballsHit = 0;
	mMerchantShipsSunk = 0;
	mPirateShipsSunk = 0;
	mNavyShipsSunk = 0;
	mEscortShipsSunk = 0;
	mSilverTrainsSunk = 0;
	mTreasureFleetsSunk = 0;
	mPlankings = 0;
    mHostages = 0;
    mSharkAttacks = 0;
    mAcidPlankings = 0;
    mDaysAtSea = 0;
    mFastestSpeed = 0;
    
    mPowderKegSinkings = 0;
    mWhirlpoolSinkings = 0;
    mDamascusSinkings = 0;
    mBrandySlickSinkings = 0;
    mDavySinkings = 0;
    
	[self zeroUnsignedIntArray:mAchievementBitmap count:4];
    [self zeroUnsignedIntArray:mRicochets count:5];
}

- (int)upgradeToOther:(GameStats *)other {
    if (other == nil)
        return kGSNoUpgrade;
    
    int didUpgrade = kGSNoUpgrade;
    
    // Score
    for (NSString *gameMode in mHiScores) {
        Score *score = [self hiScoreForGameMode:gameMode];
        Score *scoreOther = [other hiScoreForGameMode:gameMode];
        
        if (scoreOther.score > score.score)
        {
            [self setHiScore:scoreOther.score forGameMode:gameMode];
            didUpgrade |= kGSLocalUpgrade;
        }
        else if (scoreOther.score < score.score)
            didUpgrade |= kGSCloudUpgrade;
    }
    
    // Achievements
    uint *achBitmapOther = [other getAchievementBitmap];
    
    for (int i = 0; i < 4; ++i) {
        for (int j = 0; j < 30; ++j) {
            if ((achBitmapOther[i] & (1<<j)) == (1<<j) && (mAchievementBitmap[i] & (1<<j)) != (1<<j)) {
                mAchievementBitmap[i] |= (1<<j);
                didUpgrade |= kGSLocalUpgrade;
            } else if ((mAchievementBitmap[i] & (1<<j)) == (1<<j) && (achBitmapOther[i] & (1<<j)) != (1<<j)) {
                didUpgrade |= kGSCloudUpgrade;
            }
        }
    }
    
    // Objectives
    {
        uint i = 0;
        
        for (ObjectivesRank *rank in mObjectives) {
            if (i >= other.objectives.count)
                break;
            ObjectivesRank *rankOther = (ObjectivesRank *)[other.objectives objectAtIndex:i];
            if ([rank upgradeToObjectivesRank:rankOther])
                didUpgrade |= kGSLocalUpgrade;
            else if ([rankOther upgradeToObjectivesRank:rank])
                didUpgrade |= kGSCloudUpgrade;
            ++i;
        }
    }
    
    // Potions
    {
        if (other.potionsTimestamp > self.potionsTimestamp) {
            self.potionsTimestamp = other.potionsTimestamp;
            didUpgrade |= kGSLocalUpgrade;
            
            NSArray *activatedPotions = [GameStats activatedPotionsFromPotions:self.potions];
            NSArray *otherActivatedPotions = [GameStats activatedPotionsFromPotions:other.potions];
            
            if (otherActivatedPotions.count >= activatedPotions.count) {
                BOOL validPotionActivations = YES;
                ObjectivesRank *objRank = [ObjectivesRank getCurrentRankFromRanks:mObjectives];
                uint rank = (objRank) ? objRank.rank : 0;
                
                for (Potion *potion in otherActivatedPotions) {
                    if ([Potion requiredRankForPotion:potion] > rank) {
                        validPotionActivations = NO;
                        break;
                    }
                }
                
                if (validPotionActivations) {
                    for (Potion *potion in otherActivatedPotions)
                        [self activatePotion:YES forKey:potion.key];
                }
            }
            
            [self enforcePotionConstraints];
            [self enforcePotionRequirements];
        } else if (other.potionsTimestamp < self.potionsTimestamp) {
            didUpgrade |= kGSCloudUpgrade;
        }
    }
    
	// Stats Log
    if (other.cannonballsShot > self.cannonballsShot) {
        self.cannonballsShot = other.cannonballsShot;
        self.cannonballsHit = other.cannonballsHit;
        didUpgrade |= kGSLocalUpgrade;
    } else if (other.cannonballsShot < self.cannonballsShot)
        didUpgrade |= kGSCloudUpgrade;
    
    for (int hops = 1; hops <= 5; ++hops) {
        uint numRicochets = [self numRicochetsForHops:hops];
        uint numRicochetsOther = [other numRicochetsForHops:hops];
        
        if (numRicochetsOther > numRicochets) {
            [self addRicochets:numRicochetsOther-numRicochets forHops:hops];
            didUpgrade |= kGSLocalUpgrade;
        } else if (numRicochetsOther < numRicochets)
            didUpgrade |= kGSCloudUpgrade;
    }
    
    if (other.merchantShipsSunk > self.merchantShipsSunk) {
        self.merchantShipsSunk = other.merchantShipsSunk;
        didUpgrade |= kGSLocalUpgrade;
    }
    else if (other.merchantShipsSunk < self.merchantShipsSunk)
        didUpgrade |= kGSCloudUpgrade;
        
    if (other.pirateShipsSunk > self.pirateShipsSunk) {
        self.pirateShipsSunk = other.pirateShipsSunk;
        didUpgrade |= kGSLocalUpgrade;
    } else if (other.pirateShipsSunk < self.pirateShipsSunk)
        didUpgrade |= kGSCloudUpgrade;
    
    if (other.navyShipsSunk > self.navyShipsSunk) {
        self.navyShipsSunk = other.navyShipsSunk;
        didUpgrade |= kGSLocalUpgrade;
    } else if (other.navyShipsSunk < self.navyShipsSunk)
        didUpgrade |= kGSCloudUpgrade;
    
    if (other.escortShipsSunk > self.escortShipsSunk) {
        self.escortShipsSunk = other.escortShipsSunk;
        didUpgrade |= kGSLocalUpgrade;
    } else if (other.escortShipsSunk < self.escortShipsSunk)
        didUpgrade |= kGSCloudUpgrade;
        
    if (other.silverTrainsSunk > self.silverTrainsSunk) {
        self.silverTrainsSunk = other.silverTrainsSunk;
        didUpgrade |= kGSLocalUpgrade;
    } else if (other.silverTrainsSunk < self.silverTrainsSunk)
        didUpgrade |= kGSCloudUpgrade;
        
    if (other.treasureFleetsSunk > self.treasureFleetsSunk) {
        self.treasureFleetsSunk = other.treasureFleetsSunk;
        didUpgrade |= kGSLocalUpgrade;
    } else if (other.treasureFleetsSunk < self.treasureFleetsSunk)
        didUpgrade |= kGSCloudUpgrade;
        
    if (other.plankings > self.plankings) {
        self.plankings = other.plankings;
        didUpgrade |= kGSLocalUpgrade;
    } else if (other.plankings < self.plankings)
        didUpgrade |= kGSCloudUpgrade;
        
    if (other.hostages > self.hostages) {
        self.hostages = other.hostages;
        didUpgrade |= kGSLocalUpgrade;
    } else if (other.hostages < self.hostages)
        didUpgrade |= kGSCloudUpgrade;
        
    if (other.sharkAttacks > self.sharkAttacks) {
        self.sharkAttacks = other.sharkAttacks;
        didUpgrade |= kGSLocalUpgrade;
    } else if (other.sharkAttacks < self.sharkAttacks)
        didUpgrade |= kGSCloudUpgrade;
        
    if (other.acidPlankings > self.acidPlankings) {
        self.acidPlankings = other.acidPlankings;
        didUpgrade |= kGSLocalUpgrade;
    } else if (other.acidPlankings < self.acidPlankings)
        didUpgrade |= kGSCloudUpgrade;
        
    if (other.daysAtSea > self.daysAtSea) {
        self.daysAtSea = other.daysAtSea;
        didUpgrade |= kGSLocalUpgrade;
    } else if (other.daysAtSea < self.daysAtSea)
        didUpgrade |= kGSCloudUpgrade;
        
    if (other.powderKegSinkings > self.powderKegSinkings) {
        self.powderKegSinkings = other.powderKegSinkings;
        didUpgrade |= kGSLocalUpgrade;
    } else if (other.powderKegSinkings < self.powderKegSinkings)
        didUpgrade |= kGSCloudUpgrade;
    
    if (other.whirlpoolSinkings > self.whirlpoolSinkings) {
        self.whirlpoolSinkings = other.whirlpoolSinkings;
        didUpgrade |= kGSLocalUpgrade;
    } else if (other.whirlpoolSinkings < self.whirlpoolSinkings)
        didUpgrade |= kGSCloudUpgrade;
        
    if (other.damascusSinkings > self.damascusSinkings) {
        self.damascusSinkings = other.damascusSinkings;
        didUpgrade |= kGSLocalUpgrade;
    } else if (other.damascusSinkings < self.damascusSinkings)
        didUpgrade |= kGSCloudUpgrade;
        
    if (other.brandySlickSinkings > self.brandySlickSinkings) {
        self.brandySlickSinkings = other.brandySlickSinkings;
        didUpgrade |= kGSLocalUpgrade;
    } else if (other.brandySlickSinkings < self.brandySlickSinkings)
        didUpgrade |= kGSCloudUpgrade;
        
    if (other.davySinkings > self.davySinkings) {
        self.davySinkings = other.davySinkings;
        didUpgrade |= kGSLocalUpgrade;
    } else if (other.davySinkings < self.davySinkings)
        didUpgrade |= kGSCloudUpgrade;
        
    if (other.acidPlankings > self.acidPlankings) {
        self.acidPlankings = other.acidPlankings;
        didUpgrade |= kGSLocalUpgrade;
    } else if (other.acidPlankings < self.acidPlankings)
        didUpgrade |= kGSCloudUpgrade;
    
    if (other.fastestSpeed > self.fastestSpeed) {
        self.fastestSpeed = other.fastestSpeed;
        didUpgrade |= kGSLocalUpgrade;
    } else if (other.fastestSpeed < self.fastestSpeed)
        didUpgrade |= kGSCloudUpgrade;
    
    return didUpgrade;
}

- (NSString *)keyToString:(uint)key {
	return [NSString stringWithFormat:@"%u", key];
}

- (void)shipSunkWithDeathBitmap:(uint)deathBitmap {
    switch (deathBitmap) {
        case DEATH_BITMAP_POWDER_KEG: ++mPowderKegSinkings; break;
        case DEATH_BITMAP_WHIRLPOOL: ++mWhirlpoolSinkings; break;
        case DEATH_BITMAP_DAMASCUS: ++mDamascusSinkings; break;
        case DEATH_BITMAP_BRANDY_SLICK: ++mBrandySlickSinkings; break;
        case DEATH_BITMAP_DEATH_FROM_THE_DEEP: ++mDavySinkings; break;
        default: break;
    }
}

//#define GAME_STATS_DEBUG

- (double)percentComplete:(uint)achievementBit {
	double percentComplete = 0;

#ifndef GAME_STATS_DEBUG
	switch (achievementBit) {
		case ACHIEVEMENT_BIT_MASTER_PLANKER: percentComplete = MIN(1, mPlankings / 500.0); break;
        case ACHIEVEMENT_BIT_ROBBIN_DA_HOOD: percentComplete = mTreasureFleetsSunk / 250.0; break;
        case ACHIEVEMENT_BIT_BOOM_SHAKALAKA: percentComplete = mPowderKegSinkings / 500.0; break;
        case ACHIEVEMENT_BIT_LIKE_A_RECORD_BABY: percentComplete = mWhirlpoolSinkings / 500.0; break;
        case ACHIEVEMENT_BIT_ROAD_TO_DAMASCUS: percentComplete = mDamascusSinkings / 250.0; break;
        case ACHIEVEMENT_BIT_WELL_DONE: percentComplete = mBrandySlickSinkings / 250.0; break;
        case ACHIEVEMENT_BIT_DAVY_JONES_LOCKER: percentComplete = mDavySinkings / 500.0; break;
        case ACHIEVEMENT_BIT_BETTER_CALL_SAUL: percentComplete = mAcidPlankings / 100.0; break;
		default: percentComplete = ([self getAchievementBit:achievementBit]) ? 1 : 0; break;
	}
#else
    switch (achievementBit) {
		case ACHIEVEMENT_BIT_MASTER_PLANKER: percentComplete = MIN(1, mPlankings / 5.0); break;
        case ACHIEVEMENT_BIT_ROBBIN_DA_HOOD: percentComplete = mTreasureFleetsSunk / 2.0; break;
        case ACHIEVEMENT_BIT_BOOM_SHAKALAKA: percentComplete = mPowderKegSinkings / 5.0; break;
        case ACHIEVEMENT_BIT_LIKE_A_RECORD_BABY: percentComplete = mWhirlpoolSinkings / 10.0; break;
        case ACHIEVEMENT_BIT_ROAD_TO_DAMASCUS: percentComplete = mDamascusSinkings / 3.0; break;
        case ACHIEVEMENT_BIT_WELL_DONE: percentComplete = mBrandySlickSinkings / 3.0; break;
        case ACHIEVEMENT_BIT_DAVY_JONES_LOCKER: percentComplete = mDavySinkings / 5.0; break;
        case ACHIEVEMENT_BIT_BETTER_CALL_SAUL: percentComplete = mAcidPlankings / 3.0; break;
		default: percentComplete = ([self getAchievementBit:achievementBit]) ? 1 : 0; break;
	}
#endif
	return MIN(100.0, 100 * percentComplete);
}

- (void)setPercentComplete:(double)percentComplete forAchievementBit:(uint)achievementBit achievementIndex:(uint)achievementIndex {
    if ([self getAchievementBit:achievementBit] != 0) // Don't allow downgrading
        return;
    
    // 0.5 based on 250 being the smallest count. 1 / 250 = 0.04. 0.5 / 100 = 0.05.
    double decPercent = (percentComplete + 0.5) / 100.0; // Make sure we don't downgrade people. Game Center percentages are rounded down.
    
    switch (achievementBit) {
		case ACHIEVEMENT_BIT_MASTER_PLANKER: mPlankings = decPercent * 500; break;
        case ACHIEVEMENT_BIT_ROBBIN_DA_HOOD: mTreasureFleetsSunk = decPercent * 250; break;
        case ACHIEVEMENT_BIT_BOOM_SHAKALAKA: mPowderKegSinkings = decPercent * 500; break;
        case ACHIEVEMENT_BIT_LIKE_A_RECORD_BABY: mWhirlpoolSinkings = decPercent * 500; break;
        case ACHIEVEMENT_BIT_ROAD_TO_DAMASCUS: mDamascusSinkings = decPercent * 250; break;
        case ACHIEVEMENT_BIT_WELL_DONE: mBrandySlickSinkings = decPercent * 250; break;
        case ACHIEVEMENT_BIT_DAVY_JONES_LOCKER: mDavySinkings = decPercent * 500; break;
        case ACHIEVEMENT_BIT_BETTER_CALL_SAUL: mAcidPlankings = decPercent * 100; break;
		default: break;
	}
    
    [self updatePercentComplete:percentComplete forAchievementBit:achievementBit achievementIndex:achievementIndex];
}

- (void)updatePercentComplete:(double)percentComplete forAchievementBit:(uint)achievementBit achievementIndex:(uint)achievementIndex {
	BOOL earned = NO;
	
#ifndef GAME_STATS_DEBUG
	switch (achievementBit) {
		case ACHIEVEMENT_BIT_MASTER_PLANKER: earned = (mPlankings >= 500); break;
        case ACHIEVEMENT_BIT_ROBBIN_DA_HOOD: earned = (mTreasureFleetsSunk >= 250); break;
        case ACHIEVEMENT_BIT_BOOM_SHAKALAKA: earned = (mPowderKegSinkings >= 500); break;
        case ACHIEVEMENT_BIT_LIKE_A_RECORD_BABY: earned = (mWhirlpoolSinkings >= 500); break;
        case ACHIEVEMENT_BIT_ROAD_TO_DAMASCUS: earned = (mDamascusSinkings >= 250); break;
        case ACHIEVEMENT_BIT_WELL_DONE: earned = (mBrandySlickSinkings >= 250); break;
        case ACHIEVEMENT_BIT_DAVY_JONES_LOCKER: earned = (mDavySinkings >= 500); break;
        case ACHIEVEMENT_BIT_BETTER_CALL_SAUL: earned = (mAcidPlankings >= 100); break;
		default: earned = !SP_IS_FLOAT_EQUAL(0,percentComplete); break;
	}
#else
    switch (achievementBit) {
		case ACHIEVEMENT_BIT_MASTER_PLANKER: earned = (mPlankings >= 5); break;
        case ACHIEVEMENT_BIT_ROBBIN_DA_HOOD: earned = (mTreasureFleetsSunk >= 2); break;
        case ACHIEVEMENT_BIT_BOOM_SHAKALAKA: earned = (mPowderKegSinkings >= 5); break;
        case ACHIEVEMENT_BIT_LIKE_A_RECORD_BABY: earned = (mWhirlpoolSinkings >= 10); break;
        case ACHIEVEMENT_BIT_ROAD_TO_DAMASCUS: earned = (mDamascusSinkings >= 3); break;
        case ACHIEVEMENT_BIT_WELL_DONE: earned = (mBrandySlickSinkings >= 3); break;
        case ACHIEVEMENT_BIT_DAVY_JONES_LOCKER: earned = (mDavySinkings >= 5); break;
        case ACHIEVEMENT_BIT_BETTER_CALL_SAUL: earned = (mAcidPlankings >= 3); break;
		default: earned = !SP_IS_FLOAT_EQUAL(0,percentComplete); break;
	}
#endif
	
	if (earned == NO)
		earned = SP_IS_FLOAT_EQUAL([self percentComplete:achievementBit], 100.0);
	
	if (earned && [self getAchievementBit:achievementBit] == 0) {
		[self setAchievementBit:achievementBit];
		[self dispatchEvent:[AchievementEarnedEvent achievementEarnedEventWithBit:achievementBit index:achievementIndex bubbles:NO]];
	}
}

- (void)encodeWithCoder:(NSCoder *)coder {
    /*
     // For testing purposes
    [mOfflineScores removeAllObjects];

    // Today
    GKScore *score = [[[GKScore alloc] initWithCategory:CC_GAME_MODE_DEFAULT] autorelease];
    score.value = 3870000;
    [mOfflineScores addObject:score];
    */
    
    [coder encodeObject:self.dataVersion forKey:@"dataVersion"];
	[coder encodeObject:self.alias forKey:@"alias"];
	//[coder encodeObject:mShipName forKey:@"shipName"];          // iCloud: unnecessary.
	//[coder encodeObject:mCannonName forKey:@"cannonName"];      // iCloud: unnecessary.
	//[coder encodeObject:mShipNames forKey:@"shipNames"];        // iCloud: unnecessary.
	//[coder encodeObject:mCannonNames forKey:@"cannonNames"];    // iCloud: unnecessary.
	//[coder encodeObject:self.trinkets forKey:@"trinkets"];      // iCloud: unnecessary.
	//[coder encodeObject:self.gadgets forKey:@"gadgets"];        // iCloud: unnecessary.
    [coder encodeObject:self.potions forKey:@"potions"];        // iCloud: optimizable.
    [coder encodeObject:mHiScores forKey:@"hiScores"];
	[coder encodeObject:[self arrayFromUnsignedIntArray:mAchievementBitmap count:4] forKey:@"achievements"];
    [coder encodeObject:self.objectives forKey:@"objectives"];
	[coder encodeObject:[NSNumber numberWithUnsignedInt:mCannonballsShot] forKey:@"cannonballsShot"];
	[coder encodeObject:[NSNumber numberWithUnsignedInt:mCannonballsHit] forKey:@"cannonballsHit"];
    [coder encodeObject:[self arrayFromUnsignedIntArray:mRicochets count:5] forKey:@"ricochets"];
	[coder encodeObject:[NSNumber numberWithUnsignedInt:mMerchantShipsSunk] forKey:@"merchantShipsSunk"];
	[coder encodeObject:[NSNumber numberWithUnsignedInt:mPirateShipsSunk] forKey:@"pirateShipsSunk"];
	[coder encodeObject:[NSNumber numberWithUnsignedInt:mNavyShipsSunk] forKey:@"navyShipsSunk"];
	[coder encodeObject:[NSNumber numberWithUnsignedInt:mEscortShipsSunk] forKey:@"escortShipsSunk"];
	[coder encodeObject:[NSNumber numberWithUnsignedInt:mSilverTrainsSunk] forKey:@"silverTrainsSunk"];
	[coder encodeObject:[NSNumber numberWithUnsignedInt:mTreasureFleetsSunk] forKey:@"treasureFleetsSunk"];
	[coder encodeObject:[NSNumber numberWithUnsignedInt:mPlankings] forKey:@"plankings"];
    [coder encodeObject:[NSNumber numberWithUnsignedInt:mHostages] forKey:@"hostages"];
    [coder encodeObject:[NSNumber numberWithUnsignedInt:mSharkAttacks] forKey:@"sharkAttacks"];
    [coder encodeObject:[NSNumber numberWithUnsignedInt:mAcidPlankings] forKey:@"acidPlankings"];
    [coder encodeObject:[NSNumber numberWithFloat:mDaysAtSea] forKey:@"daysAtSea"];
    [coder encodeObject:[NSNumber numberWithInt:mFastestSpeed] forKey:@"fastestSpeed"];
    [coder encodeObject:[NSNumber numberWithUnsignedInt:mPowderKegSinkings] forKey:@"powderKegSinkings"];
    [coder encodeObject:[NSNumber numberWithUnsignedInt:mWhirlpoolSinkings] forKey:@"whirlpoolSinkings"];
    [coder encodeObject:[NSNumber numberWithUnsignedInt:mDamascusSinkings] forKey:@"damascusSinkings"];
    [coder encodeObject:[NSNumber numberWithUnsignedInt:mBrandySlickSinkings] forKey:@"brandySlickSinkings"];
    [coder encodeObject:[NSNumber numberWithUnsignedInt:mDavySinkings] forKey:@"davySinkings"];
    [coder encodeObject:[NSNumber numberWithDouble:mPotionsTimestamp] forKey:@"potionsTimestamp"];
    
    //[coder encodeObject:mOfflineScores forKey:@"checksums"];
    
    //if (mOFChallenge)
    //    [coder encodeObject:mOFChallenge forKey:@"OFChallenge"]; // iCloud: unnecessary.
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		NSArray *tempArray = nil;
		
		[self resetAllStats];
		
        self.dataVersion = (NSString *)[decoder decodeObjectForKey:@"dataVersion"];
		self.alias = (NSString *)[decoder decodeObjectForKey:@"alias"];
		//mShipName = [(NSString *)[decoder decodeObjectForKey:@"shipName"] copy];
		//mCannonName = [(NSString *)[decoder decodeObjectForKey:@"cannonName"] copy];
		//mShipNames = [[decoder decodeObjectForKey:@"shipNames"] retain];
		//mCannonNames = [[decoder decodeObjectForKey:@"cannonNames"] retain];
		//mTrinkets = [[NSMutableArray alloc] initWithArray:[decoder decodeObjectForKey:@"trinkets"]];
		//mGadgets = [[NSMutableArray alloc] initWithArray:[decoder decodeObjectForKey:@"gadgets"]];
		mHiScores = [[NSMutableDictionary alloc] initWithDictionary:[decoder decodeObjectForKey:@"hiScores"]];
    
		tempArray = (NSArray *)[decoder decodeObjectForKey:@"achievements"];
		[self fillUnsignedIntArray:mAchievementBitmap withArray:tempArray];
        
        mObjectives = [[NSArray alloc] initWithArray:[decoder decodeObjectForKey:@"objectives"]];
		mCannonballsShot = [(NSNumber *)[decoder decodeObjectForKey:@"cannonballsShot"] unsignedIntValue];
		mCannonballsHit = [(NSNumber *)[decoder decodeObjectForKey:@"cannonballsHit"] unsignedIntValue];
        
        tempArray = (NSArray *)[decoder decodeObjectForKey:@"ricochets"];
		[self fillUnsignedIntArray:mRicochets withArray:tempArray];
        
		mMerchantShipsSunk = [(NSNumber *)[decoder decodeObjectForKey:@"merchantShipsSunk"] unsignedIntValue];
		mPirateShipsSunk = [(NSNumber *)[decoder decodeObjectForKey:@"pirateShipsSunk"] unsignedIntValue];
		mNavyShipsSunk = [(NSNumber *)[decoder decodeObjectForKey:@"navyShipsSunk"] unsignedIntValue];
		mEscortShipsSunk = [(NSNumber *)[decoder decodeObjectForKey:@"escortShipsSunk"] unsignedIntValue];
		mSilverTrainsSunk = [(NSNumber *)[decoder decodeObjectForKey:@"silverTrainsSunk"] unsignedIntValue];
		mTreasureFleetsSunk = [(NSNumber *)[decoder decodeObjectForKey:@"treasureFleetsSunk"] unsignedIntValue];
		mPlankings = [(NSNumber *)[decoder decodeObjectForKey:@"plankings"] unsignedIntValue];
        mHostages = [(NSNumber *)[decoder decodeObjectForKey:@"hostages"] unsignedIntValue];
        mSharkAttacks = [(NSNumber *)[decoder decodeObjectForKey:@"sharkAttacks"] unsignedIntValue];
        mDaysAtSea = [(NSNumber *)[decoder decodeObjectForKey:@"daysAtSea"] floatValue];
        mPowderKegSinkings = [(NSNumber *)[decoder decodeObjectForKey:@"powderKegSinkings"] unsignedIntValue];
        mWhirlpoolSinkings = [(NSNumber *)[decoder decodeObjectForKey:@"whirlpoolSinkings"] unsignedIntValue];
        mDamascusSinkings = [(NSNumber *)[decoder decodeObjectForKey:@"damascusSinkings"] unsignedIntValue];
        mBrandySlickSinkings = [(NSNumber *)[decoder decodeObjectForKey:@"brandySlickSinkings"] unsignedIntValue];
        mDavySinkings = [(NSNumber *)[decoder decodeObjectForKey:@"davySinkings"] unsignedIntValue];
        //mOFChallenge = [[decoder decodeObjectForKey:@"OFChallenge"] retain];
        //mOfflineScores = [[NSMutableArray alloc] initWithArray:[decoder decodeObjectForKey:@"checksums"]];
        
// Version 1.1 changes
        // Potions added in v1.1 and v2.1
        NSArray *potionList = [Potion potionList];
        NSDictionary *potions = (NSDictionary *)[decoder decodeObjectForKey:@"potions"];
        
        if (potions == nil)
            potions = [Potion potionDictionary];
        
        NSMutableDictionary *combinedPotions = [NSMutableDictionary dictionaryWithDictionary:potions];
        
        for (Potion *potion in potionList) {
            if ([combinedPotions objectForKey:potion.keyAsString] == nil)
                [combinedPotions setObject:potion forKey:potion.keyAsString];
        }
            
        mPotions = [[NSDictionary alloc] initWithDictionary:combinedPotions];
        
        // Objectives max rank increased from 20 to 24 (1.1) and from 24 to 30 (2.1), so add any missing ranks here.
        if (mObjectives.count < NUM_OBJECTIVES_RANKS) {
            NSMutableArray *objectives = [NSMutableArray arrayWithArray:mObjectives];
            [objectives removeLastObject]; // Remove "empty" final rank placeholder from v1.0 objectives.
            
            int objFrom = objectives.count, objTo = NUM_OBJECTIVES_RANKS;
            
            for (int i = objFrom; i < objTo; ++i)
                [objectives addObject:[ObjectivesRank objectivesRankWithRank:i]];
            [mObjectives autorelease];
            mObjectives = [[NSArray alloc] initWithArray:objectives];
        }
        
        // Added Sea of Lava trinket. From now on we just ignore saved trinkets/gadgets and recreate them each time we load.
        mTrinkets = [[NSMutableArray alloc] initWithArray:[Idol trinketList]];
		mGadgets = [[NSMutableArray alloc] initWithArray:[Idol gadgetList]];
// End Version 1.1 changes        
        
// Version 2.0 changes
        NSNumber *acidPlankings = (NSNumber *)[decoder decodeObjectForKey:@"acidPlankings"];
        if (acidPlankings)
            mAcidPlankings = [acidPlankings unsignedIntValue];
        
        mShipName = [[NSString stringWithFormat:@"%@", @"Man o' War"] copy];
		mCannonName = [[NSString stringWithFormat:@"%@", @"Perisher"] copy];
        mShipNames = [[NSMutableArray alloc] initWithObjects:
					  @"Man o' War",
                      @"Speedboat",
					  nil];
		mCannonNames = [[NSMutableArray alloc] initWithObjects:
						@"Perisher",
						nil];
        mOfflineScores = [[NSMutableArray alloc] init];
// End Version 2.0 changes
        
// Version 2.1 changes
        id obj = [decoder decodeObjectForKey:@"fastestSpeed"];
        if (obj)
            mFastestSpeed = [(NSNumber *)obj intValue];
        else
            mFastestSpeed = 0;
        
        obj = [decoder decodeObjectForKey:@"potionsTimestamp"];
        if (obj)
            mPotionsTimestamp = [(NSNumber *)obj doubleValue];
        else
            mPotionsTimestamp = (double)CFAbsoluteTimeGetCurrent() - (double)kCFAbsoluteTimeIntervalSince1970;
// End Version 2.1 changes
        
        //NSLog(@"OFFLINE SCORE COUNT: %u", mOfflineScores.count);
        
        
        // Screenshot debug - set our objectives rank for screenshots.
//        NSMutableArray *objectives = [NSMutableArray arrayWithCapacity:NUM_OBJECTIVES_RANKS];
//        for (int i = 0; i < NUM_OBJECTIVES_RANKS; ++i) {
//            ObjectivesRank *rank = [ObjectivesRank objectivesRankWithRank:i];
//            if (i < 28)
//                [rank forceCompletion];
//            //else if (i == 17) {
//            //    [rank setObjectiveCount:12 atIndex:0];
//            //    [rank setObjectiveCount:1 atIndex:2];
//            //}
//            [objectives addObject:rank];
//        }
//        mObjectives = [[NSMutableArray alloc] initWithArray:objectives];
        
        
	}
	return self;
}

- (void)dealloc {
    [mDataVersion release]; mDataVersion = nil;
	[mAlias release]; mAlias = nil;
	[mShipName release]; mShipName = nil;
	[mCannonName release]; mCannonName = nil;
	[mShipNames release]; mShipNames = nil;
	[mCannonNames release]; mCannonNames = nil;
    [mHiScores release]; mHiScores = nil;
	[mTrinkets release]; mTrinkets = nil;
	[mGadgets release]; mGadgets = nil;
    [mPotions release]; mPotions = nil;
    [mObjectives release]; mObjectives = nil;
    [mOFChallenge release]; mOFChallenge = nil;
    [mOfflineScores release]; mOfflineScores = nil;
	[super dealloc];
}

@end
