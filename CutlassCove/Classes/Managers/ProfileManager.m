//
//  ProfileManager.m
//  Cutlass Cove
//
//  Created by Paul McPhee on 11/01/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "ProfileManager.h"
#import "FileManager.h"
#import "NSMutableData_Extension.h"
#import "MultiPurposeEvent.h"
#import "ObjectivesManager.h"
#import "GameCenterManager.h"
#import "GameSettings.h"
#import "CCOFManager.h"
#import "PersistenceManager.h"
#import "GameController.h"
#import "Globals.h"

@interface ProfileManager ()

- (NSString *)keyForIndex:(uint)index;
- (void)createProfileWithAlias:(NSString *)alias;
- (NSArray *)achievementDescriptions;
- (int)gcIndexOfAchievement:(NSString *)identifier;
- (int)ofIndexOfAchievement:(NSString *)identifier;
- (void)onGCAchievementsFetched:(MultiPurposeEvent *)event;
- (void)onOFAchievementsFetched:(MultiPurposeEvent *)event;

@end


@implementation ProfileManager

@synthesize playerStats = mPlayerStats;

- (id)initWithAchievementDefs:(NSArray *)achDefs {
	if (self = [super init]) {
        mProcessingFetchedGCAchievements = NO;
        mProcessingFetchedOFAchievements = NO;
        mOnlineSyncInProgress = 0;
		mKey = [[NSString stringWithFormat:@"th4#H1rK!^*gk(CV{868}$!ZzaAs)(.,"] copy];
		mPlayerStats = nil;
		mAchievementDefs = [achDefs retain];
        mAchUpdateQueue = (BOOL*)malloc(mAchievementDefs.count * sizeof(BOOL));
        for (int i = 0; i < mAchievementDefs.count; ++i)
            mAchUpdateQueue[i] = false;
        
        // Achievements
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:mAchievementDefs.count];
        
		for (NSDictionary *def in mAchievementDefs) {
			NSString *key = (NSString *)[def objectForKey:@"id"];
            
            if (key)
                [dict setObject:def forKey:key];
		}
		
		mAchievementIDsDict = [[NSDictionary alloc] initWithDictionary:dict];
        
        // Game Center reference dictionary
        dict = [NSMutableDictionary dictionaryWithCapacity:mAchievementDefs.count];
        
        for (NSDictionary *def in mAchievementDefs) {
			NSString *key = (NSString *)[def objectForKey:@"GCID"];
            
            if (key)
                [dict setObject:def forKey:key];
		}
        
        mGCAchievementIDsDict = [[NSDictionary alloc] initWithDictionary:dict];
        
        // OpenFeint reference dictionary
        dict = [NSMutableDictionary dictionaryWithCapacity:mAchievementDefs.count];
        
        for (NSDictionary *def in mAchievementDefs) {
			NSString *key = (NSString *)[def objectForKey:@"OFID"];
            
            if (key)
                [dict setObject:def forKey:key];
		}
        
        mOFAchievementIDsDict = [[NSDictionary alloc] initWithDictionary:dict];
        
        [GCTRL.ofManager addEventListener:@selector(onGCAchievementsFetched:) atObject:self forType:CUST_EVENT_TYPE_GC_ACH_REFRESH_REQUIRED];
        [GCTRL.ofManager addEventListener:@selector(onOFAchievementsFetched:) atObject:self forType:CUST_EVENT_TYPE_OF_ACH_REFRESH_REQUIRED];
	}
	return self;
}

- (NSString *)keyForIndex:(uint)index {
    return [NSString stringWithFormat:@"%u", index];
}

- (void)prepareForNewGame {
	[mPlayerStats prepareForNewGame];
}

- (void)loadProgress {
    self.playerStats = [[PersistenceManager PM] load];
    assert(self.playerStats);
    [self.playerStats enforcePotionConstraints];
    [self.playerStats enforcePotionRequirements];
}

- (void)saveProgress {
	if (mPlayerStats) {
        [[PersistenceManager PM] save:mPlayerStats];
        NSLog(@"Progress Saved");
    }
    
    // Commented: v1.0 - 1.1
    //[data maskWithOffset:0x10];
    //BOOL progressSaved = [FileManager saveNSData:data withFilename:@"PlayerStatsData"];
    //NSLog(@"Progress Saved: %@", ((progressSaved) ? @"YES" : @"NO"));
}

- (void)deleteProgress {
    //if (![FileManager deletePlistFile:@"PlayerStats"])
    //    NSLog(@"Failed to delete progress.");
}

- (void)setPlayerStats:(GameStats *)playerStats {
    if (playerStats == mPlayerStats)
        return;
    [mPlayerStats autorelease];
    [mPlayerStats removeEventListener:@selector(onAchievementEarned:) atObject:self forType:CUST_EVENT_TYPE_ACHIEVEMENT_EARNED];
    
    mPlayerStats = [playerStats retain];
    
    if (mPlayerStats) {
        [mPlayerStats addEventListener:@selector(onAchievementEarned:) atObject:self forType:CUST_EVENT_TYPE_ACHIEVEMENT_EARNED];
    
        [GCTRL.objectivesManager setupWithRanks:mPlayerStats.objectives];
        [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_PLAYER_CHANGED]];
    }
}

- (void)createProfileWithAlias:(NSString *)alias {
	if (alias == nil)
		alias = CC_ALIAS_DEFAULT;
	self.playerStats = [[[GameStats alloc] initWithAlias:alias] autorelease];
}

- (void)resetStats {
	[mPlayerStats resetAllStats];
}

- (void)saveScore:(int64_t)score {
    if (score <= 0)
        return;
    
    GameController *gc = GCTRL;
    gc.thisTurn.wasGameProgressMade = YES;
    
    Score *hiScore = [mPlayerStats hiScore];
    
    if (score > hiScore.score)
        [mPlayerStats setHiScore:score];
    
    [gc.ofManager saveScore:score];
}

- (void)saveSpeed:(double)speed {
    if (speed <= 0)
        return;
    
    GameController *gc = GCTRL;
    int64_t gcSpeed = (int64_t)(speed * 1000.0);
    
    if (gcSpeed > [mPlayerStats fastestSpeed]) {
        [mPlayerStats setFastestSpeed:gcSpeed];
        GameController *gc = GCTRL;
        gc.thisTurn.wasGameProgressMade = YES;
    }
    
    [gc.ofManager saveSpeed:gcSpeed];
}

- (BOOL)achievementEarned:(int)key {
	BOOL result = NO;
	
	if (mPlayerStats != nil)
		result = ([mPlayerStats getAchievementBit:key] != 0);
	return result;
}

- (void)queueUpdateAchievement:(uint)achievementIndex percentComplete:(double)percentComplete {
    GameController *gc = GCTRL;
    
    if (gc.thisTurn.isGameOver)
        return;
    
    if (!(achievementIndex < mAchievementDefs.count)) {
        NSLog(@"Failed to save Achievement. Achievement index out of range.");
        return;
    }
    
#ifdef CHEEKY_LITE_VERSION
    if ([GameStats isLiteAchievementIndex:achievementIndex liteIndexes:nil] == NO)
        return;
#endif
    

    uint achBit = [GameStats achievementBitForIndex:achievementIndex];
    
    if ([self achievementEarned:achBit] == NO) {
        gc.thisTurn.wasGameProgressMade = YES;
        [mPlayerStats updatePercentComplete:percentComplete forAchievementBit:achBit achievementIndex:achievementIndex];
        mAchUpdateQueue[achievementIndex] = true;
    }
}

- (void)submitQueuedUpdateAchievements {
    int numUpdates = 0;
    for (int i = 0; i < mAchievementDefs.count; ++i) {
        if (mAchUpdateQueue[i])
        {
            ++numUpdates;
            mAchUpdateQueue[i] = false;
            [self saveAchievement:i percentComplete:[mPlayerStats percentComplete:[GameStats achievementBitForIndex:i]]];
        }
    }
    
//    if (numUpdates > 0)
//    {
//        GameController *gc = GCTRL;
//        
//        if ([gc.gameSettings settingForKey:GAME_SETTINGS_KEY_SYNCED_ACHIEVEMENTS])
//            [gc.gameSettings setSettingForKey:GAME_SETTINGS_KEY_SYNCED_ACHIEVEMENTS value:NO];
//    }
}

- (void)saveAchievement:(uint)achievementIndex percentComplete:(double)percentComplete {
    if (!(achievementIndex < mAchievementDefs.count)) {
        NSLog(@"Failed to save Achievement. Achievement index out of range.");
        return;
    }
	
    uint achBit = [GameStats achievementBitForIndex:achievementIndex];
    [mPlayerStats updatePercentComplete:percentComplete forAchievementBit:achBit achievementIndex:achievementIndex];
    
    NSDictionary *achDef = (NSDictionary *)[mAchievementDefs objectAtIndex:achievementIndex];
    NSString *achID = (NSString *)[achDef objectForKey:@"GCID"];
    
    if (achID)
        [GCTRL.ofManager saveAchievement:achID percentComplete:percentComplete showNotification:NO];
}

- (void)fetchAchievements {
    NSArray *achievementDescriptions = [self achievementDescriptions];
    [self dispatchEvent:[ProfileResultEvent
                         profileResultEventWithType:CUST_EVENT_TYPE_ACHIEVEMENTS_FETCHED
                         achievements:achievementDescriptions
                         leaderboard:nil
                         localPlayerScore:nil
                         error:nil
                         bubbles:NO]];
}

- (void)syncOnlineAchievements {
    mOnlineSyncInProgress = 0x3;
    [GCTRL.ofManager syncOnlineAchievements];
}

- (void)cancelOnlineSync {
    mOnlineSyncInProgress = 0;
    [GCTRL.ofManager cancelOnlineSync];
}

- (void)onAchievementEarned:(AchievementEarnedEvent *)event {
	[self dispatchEvent:event];
}

- (int)indexOfAchievement:(NSString *)identifier {
	NSDictionary *achDef = (NSDictionary *)[mAchievementIDsDict objectForKey:identifier];
	return [mAchievementDefs indexOfObject:achDef];
}

- (int)gcIndexOfAchievement:(NSString *)identifier {
    NSDictionary *achDef = (NSDictionary *)[mGCAchievementIDsDict objectForKey:identifier];
	return [mAchievementDefs indexOfObject:achDef];
}

- (int)ofIndexOfAchievement:(NSString *)identifier {
    NSDictionary *achDef = (NSDictionary *)[mOFAchievementIDsDict objectForKey:identifier];
	return [mAchievementDefs indexOfObject:achDef];
}

- (void)onGCAchievementsFetched:(MultiPurposeEvent *)event {
    if (mProcessingFetchedGCAchievements)
        return;
    mProcessingFetchedGCAchievements = YES;
    
    uint syncKey = 0x1;
    
    do {
        // Check for error
        if ((mOnlineSyncInProgress & syncKey) && [event.data objectForKey:@"Error"]) {
            NSString *errorStr = [NSString stringWithFormat:@"Error"];
            MultiPurposeEvent *event = [MultiPurposeEvent multiPurposeEventWithType:CUST_EVENT_TYPE_ACH_SYNC_COMPLETE bubbles:NO];
            [event.data setObject:errorStr forKey:errorStr];
            [self dispatchEvent:event];
            break;
        }
        
        GameController *gc = GCTRL;
        NSDictionary *achievements = (NSDictionary *)[event.data objectForKey:event.type];

        if (achievements)
            NSLog(@"Processing Fetched GC Achievements: %u", achievements.count);
        
        for (NSString *key in mGCAchievementIDsDict) {
            uint achievementIndex = [self gcIndexOfAchievement:key];
            
            if (!(achievementIndex < mAchievementDefs.count))
                continue;
            
#ifdef CHEEKY_LITE_VERSION
            if ([GameStats isLiteAchievementIndex:achievementIndex liteIndexes:nil] == NO)
                continue;
#endif
            
            uint achBit = [GameStats achievementBitForIndex:achievementIndex];
            double percentComplete = [mPlayerStats percentComplete:achBit];
        
            GKAchievement *achievement = (GKAchievement *)[achievements objectForKey:key];
            
            if (achievement == nil) {
                if (SP_IS_FLOAT_EQUAL(percentComplete, 0) == NO) {
                    [gc.ofManager gcReportAchievement:key percentComplete:percentComplete];
                    //NSLog(@"Local: %f GameCenter: %f", percentComplete, 0.0);
                    //NSLog(@"Reporting a fetched GC Achievement");
                }
            } else if (SP_IS_FLOAT_EQUAL(percentComplete, achievement.percentComplete) == NO) {
                if (percentComplete > achievement.percentComplete)
                    [gc.ofManager gcReportAchievement:key percentComplete:percentComplete];
                else
                    [mPlayerStats setPercentComplete:achievement.percentComplete forAchievementBit:achBit achievementIndex:achievementIndex];
                //NSLog(@"%@ -- Local: %f GameCenter: %f", key, (float)percentComplete, (float)achievement.percentComplete);
                //NSLog(@"Reporting a fetched GC Achievement");
            }
        }
        
        // Notify of this portion of the online sync completing
        if (mOnlineSyncInProgress & syncKey) {
            MultiPurposeEvent *event = [MultiPurposeEvent multiPurposeEventWithType:CUST_EVENT_TYPE_ACH_SYNC_COMPLETE bubbles:NO];
            [event.data setObject:[NSNumber numberWithUnsignedInt:syncKey] forKey:event.type];
            [self dispatchEvent:event];
        }
    } while (NO);
    
    mOnlineSyncInProgress &= ~syncKey;
    mProcessingFetchedGCAchievements = NO;
}

- (void)onOFAchievementsFetched:(MultiPurposeEvent *)event {

    if (mProcessingFetchedOFAchievements)
        return;
    mProcessingFetchedOFAchievements = YES;
    
    uint syncKey = 0x2;
    
    if (mOnlineSyncInProgress & syncKey) {
        MultiPurposeEvent *mpEvent = [MultiPurposeEvent multiPurposeEventWithType:CUST_EVENT_TYPE_ACH_SYNC_COMPLETE bubbles:NO];
        [mpEvent.data setObject:[NSNumber numberWithUnsignedInt:syncKey] forKey:mpEvent.type];
        [self dispatchEvent:mpEvent];
    }
    
    mOnlineSyncInProgress &= ~syncKey;
    mProcessingFetchedOFAchievements = NO;
}

- (NSArray *)achievementDescriptions {
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:mAchievementDefs.count];

#ifdef CHEEKY_LITE_VERSION
    NSArray *liteIndexes = [GameStats liteAchievementIndexes];
#endif
    
    for (int i = ACHIEVEMENT_INDEX_MIN; i < mAchievementDefs.count; ++i) {
#ifdef CHEEKY_LITE_VERSION
        if ([GameStats isLiteAchievementIndex:(uint)i liteIndexes:liteIndexes] == NO)
            continue;
#endif
        
        uint achBit = [GameStats achievementBitForIndex:i];
        NSDictionary *achDef = (NSDictionary *)[mAchievementDefs objectAtIndex:i];
        
        if (achDef == nil)
            continue;
        
        AchievementsDescription *desc = [[AchievementsDescription alloc] init];
        
        desc.completed = [self achievementEarned:achBit];
        desc.achievementIndex = (uint)i;
        desc.percentComplete = [mPlayerStats percentComplete:achBit];
        desc.achievementDef = achDef;
        [array addObject:desc];
        [desc release];
    }

	return array;
}

- (void)dealloc {
    free(mAchUpdateQueue);
    [GCTRL.ofManager removeEventListener:@selector(onGCAchievementsFetched:) atObject:self forType:CUST_EVENT_TYPE_GC_ACH_REFRESH_REQUIRED];
    [GCTRL.ofManager removeEventListener:@selector(onOFAchievementsFetched:) atObject:self forType:CUST_EVENT_TYPE_OF_ACH_REFRESH_REQUIRED];
	[mAchievementDefs release]; mAchievementDefs = nil;
	[mAchievementIDsDict release]; mAchievementIDsDict = nil;
    [mGCAchievementIDsDict release]; mGCAchievementIDsDict = nil;
    [mOFAchievementIDsDict release]; mOFAchievementIDsDict = nil;
	[mPlayerStats release]; mPlayerStats = nil;
	[mKey release]; mKey = nil;
	[super dealloc];
}

@end


@implementation DelayedAchievement

@synthesize achievementIndex,percentComplete;

+ (DelayedAchievement *)delayedAchievementWithIndex:(uint)index percent:(double)percent {
    return [[[DelayedAchievement alloc] initWithIndex:index percent:percent] autorelease];
}

- (id)initWithIndex:(uint)index percent:(double)percent {
    if (self = [super init]) {
        achievementIndex = index;
        percentComplete = percent;
    }
    return self;
}

- (id)init {
    return [self initWithIndex:0 percent:0];
}

@end
