//
//  CCOFManager.m
//  CutlassCove
//
//  Created by Paul McPhee on 3/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/*
    FEATURE LIST:

        1. Add support for iCade: https://github.com/scarnie/iCade-iOS
 */

//#define CC_OFFLINE_MODE

#import "CCOFManager.h"
#import "MultiPurposeEvent.h"
#import "GameSettings.h"
#import "GameStats.h"
#import "SceneController.h"
#import "GameController.h"

#import "CutlassCoveAppDelegate.h"

@interface CCOFManager ()

- (void)setOfflineScoreState:(CCOFOfflineScoreState)state;

- (void)ofFetchAchievements;

// For non-OpenFeint Game Center management.
- (void)populateQueryIDs;
- (QueryID *)qidForKey:(NSString *)key;
- (BOOL)validateQid:(QueryID *)qid;
- (void)gcReportScore:(int64_t)score;
- (void)gcFetchAchievements;
- (void)setOfflineAchievementsFlag:(BOOL)value;

@end

@implementation CCOFManager

- (id)init {
    if (self = [super init]) {
        // DON'T USE GAMECONTROLLER IN HERE
        mQueuedAchievementsPending = NO;
        mOnlineSyncInProgress = 0;
        mOfflineScoreState = CCOFOfflineScoreNull;
        mLastSubmittedScore = 0;
        
		if ([ResManager isGameCenterAvailable]) {
			mGcManager = [[GameCenterManager alloc] init];
			mGcManager.delegate = self;
            [self populateQueryIDs];
		}
    }
    
    return self;
}

- (void)dealloc {
    [mQueryIDs release]; mQueryIDs = nil;
    mGcManager.delegate = nil;
    [mGcManager release]; mGcManager = nil;
    mScene = nil;
    [super dealloc];
}

- (void)setScene:(SceneController *)scene {
    mScene = scene;
}

- (void)setOfflineScoreState:(CCOFOfflineScoreState)state {
    mOfflineScoreState = CCOFOfflineScoreNull;
}

- (void)saveScore:(int64_t)score {
#ifdef CC_OFFLINE_MODE
    return;
#endif
    if (GCTRL.isGameDataValid == NO)
        return;

    mLastSubmittedScore = score;
    [self gcReportScore:score];
}

- (void)saveSpeed:(int64_t)speed {
#ifdef CC_OFFLINE_MODE
    return;
#endif
    if (GCTRL.isGameDataValid == NO)
        return;
    
    [self gcReportSpeed:speed];
}

- (void)saveOfflineScore:(GKScore *)score {
#ifdef CC_OFFLINE_MODE
    return;
#endif
    
    if (GCTRL.isGameDataValid == NO)
        return;
    if ([ResManager isGameCenterAvailable] && [self isUserLoggedIntoGameCenter] && [ResManager isOSFeatureSupported:@"5.0"] == NO)
        [mGcManager reportScore:score];
}

- (void)saveAchievement:(NSString *)achID percentComplete:(double)percentComplete showNotification:(BOOL)showNotification {
    [self gcReportAchievement:achID percentComplete:percentComplete];
}

- (void)queueUpdateAchievement:(NSString *)achID percentComplete:(double)percentComplete showNotification:(BOOL)showNotification {
    return;
}

- (void)submitQueuedUpdateAchievements {
    return;
}

- (BOOL)isUserLoggedIntoGameCenter {
    return [GKLocalPlayer localPlayer].isAuthenticated;
}

- (BOOL)hasGameCenterLoginChanged {
    return ((![GKLocalPlayer localPlayer].isAuthenticated && mGcManager.playerID != nil)
            || ([GKLocalPlayer localPlayer].isAuthenticated && (mGcManager.playerID == nil || ![mGcManager.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID])));
}

- (void)ofFetchAchievements {
    MultiPurposeEvent *event = [MultiPurposeEvent multiPurposeEventWithType:CUST_EVENT_TYPE_OF_ACH_REFRESH_REQUIRED bubbles:NO];
    mOnlineSyncInProgress &=~ 0x2;
    [self dispatchEvent:event];
}

#define LOGIN_QID @"LoginQuery"
#define ACHIEVEMENTS_QID @"AchievementsQuery"
#define SCORES_QID @"ScoresQuery"

- (void)setOfflineAchievementsFlag:(BOOL)value {
    return;
}

- (void)reportOfflineAchievements {
    return;
}

- (void)populateQueryIDs {
	[mQueryIDs release]; mQueryIDs = nil;
	
	mQueryIDs = [[NSDictionary alloc] initWithObjectsAndKeys:
				 [QueryID qidWithTag:LOGIN_QID], LOGIN_QID,
                 [QueryID qidWithTag:ACHIEVEMENTS_QID], ACHIEVEMENTS_QID,
                 [QueryID qidWithTag:SCORES_QID], SCORES_QID,
				 nil];
}

- (QueryID *)qidForKey:(NSString *)key {
	QueryID *qid = (QueryID *)[mQueryIDs objectForKey:key];
	++qid.seqNo;
	
	QueryID *qidCopy = [[[QueryID alloc] initWithQueryID:qid] autorelease];
	return qidCopy;
}

- (BOOL)validateQid:(QueryID *)qid {
	QueryID *qidLocal = (QueryID *)[mQueryIDs objectForKey:qid.tag];
	assert(qidLocal);
	
	return (qidLocal.seqNo == qid.seqNo);
}

- (void)loginToGameCenter {
    if ([self isUserLoggedIntoGameCenter] == NO || [self hasGameCenterLoginChanged]) {
        [mGcManager authenticateLocalUser:[self qidForKey:LOGIN_QID]];
    } else {
        mGcManager.playerID = [GKLocalPlayer localPlayer].playerID;
    }
}

- (void)gcReportScore:(int64_t)score {
#ifdef CC_OFFLINE_MODE
    return;
#endif
    
    if ([ResManager isGameCenterAvailable] && [self isUserLoggedIntoGameCenter]) {
        GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
        
        if (localPlayer && localPlayer.playerID)
            [mGcManager reportScore:score forCategory:CC_GAME_MODE_DEFAULT];
    }
}

- (void)gcReportSpeed:(int64_t)speed {
#ifdef CC_OFFLINE_MODE
    return;
#endif
    
    if ([ResManager isGameCenterAvailable] && [self isUserLoggedIntoGameCenter]) {
        GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
        
        if (localPlayer && localPlayer.playerID)
            [mGcManager reportScore:speed forCategory:CC_GAME_MODE_SPEED_DEMONS];
    }
}

- (void)gcReportAchievement:(NSString *)achID percentComplete:(double)percentComplete {
#ifdef CC_OFFLINE_MODE
    return;
#endif
    
    if ([ResManager isGameCenterAvailable] && [self isUserLoggedIntoGameCenter])
        [mGcManager submitAchievement:achID percentComplete:percentComplete];
}

- (void)gcFetchAchievements {
    if ([ResManager isGameCenterAvailable] && [self isUserLoggedIntoGameCenter])
        [mGcManager fetchAchievements:[self qidForKey:ACHIEVEMENTS_QID]];
}

- (void)gcResetAchievements {
    if ([ResManager isGameCenterAvailable] && [self isUserLoggedIntoGameCenter])
        [mGcManager resetAchievements];
}

- (void)syncOnlineAchievements {
    if ([ResManager isGameCenterAvailable] && [self isUserLoggedIntoGameCenter]) {
        mOnlineSyncInProgress = 0x3;
        [self gcFetchAchievements];
        [self ofFetchAchievements];
    }
}

- (void)cancelOnlineSync {
    mOnlineSyncInProgress = 0;
}

- (void)gcFetchScoresForCategory:(NSString *)category
                           range:(NSRange)range
                     playerScope:(GKLeaderboardPlayerScope)playerScope
                       timeScope:(GKLeaderboardTimeScope)timeScope
{
    if ([ResManager isGameCenterAvailable] && [self isUserLoggedIntoGameCenter])
        [mGcManager fetchScoresForCategory:category range:range playerScope:playerScope timeScope:timeScope qid:[self qidForKey:SCORES_QID]];
}

- (void)processGameCenterAuthentication:(GCInfo *)info {
    // This test no longer holds due to iOS 6 Game Center authenticateHandler.
	//if ([self validateQid:info.qid] == NO)
	//	return;
    
    GameController *gc = GCTRL;
    
    BOOL loginSuccessful = (info.error == nil);
    
	if (loginSuccessful == NO) {
        switch (info.error.code) {
            case GKErrorCancelled:
                if ([gc.gameSettings settingForKey:GAME_SETTINGS_KEY_GAME_CENTER_ENABLED]) {
                    [gc.gameSettings setSettingForKey:GAME_SETTINGS_KEY_GAME_CENTER_ENABLED value:NO];
                    [gc.gameSettings saveSettings];
                }
                break;
            default:
                break;
        }

		NSLog(@"%@", [info.error localizedDescription]);
	}
    
	MultiPurposeEvent *event = [MultiPurposeEvent multiPurposeEventWithType:CUST_EVENT_TYPE_GC_USER_LOGIN_CHANGED bubbles:NO];
    [event.data setObject:[NSNumber numberWithBool:loginSuccessful] forKey:CUST_EVENT_TYPE_GC_USER_LOGIN_CHANGED];

    if (info.error)
        [event.data setObject:info.error forKey:@"Error"];
    if (info.data)
        [event.data setObject:info.data forKey:@"ViewController"];
    [event.data setObject:[NSNumber numberWithBool:[self hasGameCenterLoginChanged]] forKey:@"PlayerDidChange"];
    
    mGcManager.playerID = [GKLocalPlayer localPlayer].isAuthenticated ? [GKLocalPlayer localPlayer].playerID : nil;
    
    [self dispatchEvent:event];
}

- (void)playerAuthenticationWillChange {
    [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_GC_PLAYER_AUTH_WILL_CHANGE]];
}

- (void)scoreReported:(GKScore *)score error:(NSError *)error {
    NSLog(@"GKScore submitted: %@ Error: %@", score, error);
    [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_GC_SCORE_SUBMITTED]];
}

- (void)achievementSubmitted:(GKAchievement *)achievement error:(NSError *)error {
    NSLog(@"GKAchievement sSubmitted: %@ Error: %@", achievement, error);
}

- (void)fetchScoresComplete:(GKLeaderboard *)leaderBoard info:(GCInfo *)info {
    if ([self validateQid:info.qid] == NO)
		return;
    
    MultiPurposeEvent *event = [MultiPurposeEvent multiPurposeEventWithType:CUST_EVENT_TYPE_GC_SCORES_FETCHED bubbles:NO];
    [event.data setObject:leaderBoard forKey:@"Scores"];
    
    if (info.error)
        [event.data setObject:info.error forKey:@"Error"];
    [self dispatchEvent:event];
}

- (void)fetchAchievementsComplete:(NSDictionary *)achievements info:(GCInfo *)info {
	if ([self validateQid:info.qid] == NO)
		return;
    
    if (info.error && mOnlineSyncInProgress == 0) {
        if (info.error.code == GKErrorCommunicationsFailure)
            [self setOfflineAchievementsFlag:YES];
    }
    
    if (achievements || mOnlineSyncInProgress != 0) {
        MultiPurposeEvent *event = [MultiPurposeEvent multiPurposeEventWithType:CUST_EVENT_TYPE_GC_ACH_REFRESH_REQUIRED bubbles:NO];
        
        if (achievements)
            [event.data setObject:achievements forKey:event.type];
        
        if (info.error && (mOnlineSyncInProgress & 0x1)) {
            NSString *errorStr = @"Error";
            [event.data setObject:errorStr forKey:errorStr];
        }
        
        mOnlineSyncInProgress &=~ 0x1;
        [self dispatchEvent:event];
    }
}

- (void)resetAchievementsComplete:(NSError *)ignoreThis error:(NSError *)error {
    if (error == nil)
        NSLog(@"Achievements soccessfuly reset.");
}

@end
