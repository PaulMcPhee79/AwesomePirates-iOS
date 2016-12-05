//
//  CCOFManager.h
//  CutlassCove
//
//  Created by Paul McPhee on 3/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameCenterManager.h"

#ifdef CHEEKY_LITE_VERSION
    #define CC_OF_LBID_HALL_OF_INFAMY @"1093087"
#else
    #define CC_OF_LBID_HALL_OF_INFAMY @"1071097"
#endif

#define CC_OF_CLOUD_KEY_GAME_PROGRESS @"CutlassCoveOFCloudGameProgress"

// Events
#define CUST_EVENT_TYPE_GC_USER_LOGIN_CHANGED @"GCUserLoginChangedEvent"
#define CUST_EVENT_TYPE_GC_PLAYER_AUTH_WILL_CHANGE @"GCPlayerAuthWillChangeEvent"

#define CUST_EVENT_TYPE_OFFLINE_SAVE_REQUIRED @"OFOfflineSaveRequired"
#define CUST_EVENT_TYPE_GC_ACH_REFRESH_REQUIRED @"GCAchRefreshRequired"
#define CUST_EVENT_TYPE_OF_ACH_REFRESH_REQUIRED @"OFAchRefreshRequired"

#define CUST_EVENT_TYPE_GC_SCORE_SUBMITTED @"GCScoreSubmitted"
#define CUST_EVENT_TYPE_GC_SCORES_FETCHED @"GCScoresFetched"

typedef enum {
    CCOFOfflineScoreNull = 0,
    CCOFOfflineScoreToday,
    CCOFOfflineScoreThisWeek,
    CCOFOfflineScoreAllTime,
    CCOFOfflineScoreDone
} CCOFOfflineScoreState;


@class SceneController;

@interface CCOFManager : SPEventDispatcher <GameCenterManagerDelegate> {
    BOOL mQueuedAchievementsPending;
    uint mOnlineSyncInProgress; // 0x0: Not in progress, 0x1: GC bit, 0x2 OF bit, 0x3: No progress
    
    CGRect mViewFrame;
    
    CCOFOfflineScoreState mOfflineScoreState;
    int64_t mLastSubmittedScore;
    
    SceneController *mScene; // Weak reference
    
    // For non-OpenFeint Game Center management
    //BOOL mIsGCAuthenticating;
    NSDictionary *mQueryIDs; // Remote Query sequencer
    GameCenterManager *mGcManager;
}

- (void)setScene:(SceneController *)scene;

- (void)saveScore:(int64_t)score;
- (void)saveOfflineScore:(GKScore *)score;
- (void)saveSpeed:(int64_t)speed;
- (void)saveAchievement:(NSString *)achID percentComplete:(double)percentComplete showNotification:(BOOL)showNotification;
- (void)queueUpdateAchievement:(NSString *)achID percentComplete:(double)percentComplete showNotification:(BOOL)showNotification;
- (void)submitQueuedUpdateAchievements;

- (void)reportOfflineAchievements;
- (void)gcReportScore:(int64_t)score;
- (void)gcReportSpeed:(int64_t)speed;
- (void)gcReportAchievement:(NSString *)achID percentComplete:(double)percentComplete;
- (void)gcResetAchievements;
- (void)gcFetchScoresForCategory:(NSString *)category
                           range:(NSRange)range
                     playerScope:(GKLeaderboardPlayerScope)playerScope
                       timeScope:(GKLeaderboardTimeScope)timeScope;


- (void)syncOnlineAchievements;
- (void)cancelOnlineSync;

// Game Center
- (BOOL)isUserLoggedIntoGameCenter;
- (BOOL)hasGameCenterLoginChanged;
- (void)loginToGameCenter;


@end
