//
//  ProfileManager.h
//  Cutlass Cove
//
//  Created by Paul McPhee on 11/01/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameStats.h"
#import "ProfileResultEvent.h"

#define kAchievementCompletePercent 100.0

#define CUST_EVENT_TYPE_ACH_SYNC_COMPLETE @"AchSyncComplete"


@interface DelayedAchievement : NSObject {
@package
    uint achievementIndex;
    double percentComplete;
}

@property (nonatomic,assign) uint achievementIndex;
@property (nonatomic,assign) double percentComplete;

+ (DelayedAchievement *)delayedAchievementWithIndex:(uint)index percent:(double)percent;
- (id)initWithIndex:(uint)index percent:(double)percent;
@end


@interface ProfileManager : SPEventDispatcher {
    BOOL mProcessingFetchedGCAchievements;
    BOOL mProcessingFetchedOFAchievements;
    uint mOnlineSyncInProgress;
	NSString *mKey;

	// Persistent Stats
	GameStats *mPlayerStats;
	
	// Achievement Data
    BOOL *mAchUpdateQueue;
	NSArray *mAchievementDefs;
	NSDictionary *mAchievementIDsDict;
    NSDictionary *mGCAchievementIDsDict;
    NSDictionary *mOFAchievementIDsDict;
}

@property (nonatomic,retain) GameStats *playerStats;

- (id)initWithAchievementDefs:(NSArray *)achDefs;

- (void)resetStats;

- (void)saveScore:(int64_t)score;
- (void)saveSpeed:(double)speed;
- (void)saveAchievement:(uint)achievementIndex percentComplete:(double)percentComplete;
- (void)queueUpdateAchievement:(uint)achievementIndex percentComplete:(double)percentComplete;
- (void)submitQueuedUpdateAchievements;

- (void)loadProgress;
- (void)saveProgress;
- (void)deleteProgress;

- (void)fetchAchievements;

- (void)syncOnlineAchievements;
- (void)cancelOnlineSync;

- (void)prepareForNewGame;
- (BOOL)achievementEarned:(int)key;
- (void)onAchievementEarned:(AchievementEarnedEvent *)event;
- (int)indexOfAchievement:(NSString *)identifier;

@end
