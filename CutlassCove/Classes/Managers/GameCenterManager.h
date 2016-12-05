//
//  GameCenterManager.h
//  Cutlass Cove
//
//  Created by Paul McPhee on 6/01/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

// Note: Concepts and some code modified from Apple's GKTapper sample GameKit project.

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

// Archive GKScore and GKAchievements separately for different users. Otherwise, the system will incorrectly award hi scores
// from Player A to Player B because it awards them to whomever is currently logged in, not to whomever achieved them!

// Some people are using threads to do their achievement submission. Look at NSOperation class for thread support.

//#define LBCAT_ADVENTURE_INFAMY @"xyzAdvInfamyxyz"
//#define LBCAT_SKIRMISH_INFAMY @"xyzSkirmishInfamyxyz"

#define GCM_ACHIEVEMENT_COUNT 25

@class GKLeaderboard, GKAchievement, GKPlayer;

// Communication helpers
@interface QueryID : NSObject {
	uint mSeqNo;
	NSString *mTag;
}

@property (nonatomic,assign) uint seqNo;
@property (nonatomic,copy) NSString *tag;

- (id)initWithQueryID:(QueryID *)qid;
+ (QueryID *)qidWithTag:(NSString *)tag;

@end

@interface GCInfo : NSObject {
	QueryID *mQid;
    NSObject *mData;
	NSError *mError;
}

@property (nonatomic,retain) QueryID *qid;
@property (nonatomic,assign) NSObject *data;
@property (nonatomic,retain) NSError *error;

+ (GCInfo *)gcInfoWithQid:(QueryID *)qid error:(NSError *)error;
+ (GCInfo *)gcInfoWithQid:(QueryID *)qid data:(NSObject *)data error:(NSError *)error;
- (id)initWithQid:(QueryID *)qid data:(NSObject *)data error:(NSError *)error;

@end
////////////////////////////////////

@protocol GameCenterManagerDelegate <NSObject>

@optional
- (void)processGameCenterAuthentication:(GCInfo *)info;
- (void)playerAuthenticationWillChange;

- (void)scoreReported:(GKScore *)score error:(NSError *)error;
- (void)fetchScoresComplete:(GKLeaderboard *)leaderBoard info:(GCInfo *)info;

- (void)achievementSubmitted:(GKAchievement *)achievement error:(NSError *)error;
- (void)fetchAchievementsComplete:(NSDictionary *)achievements info:(GCInfo *)info;
- (void)resetAchievementsComplete:(NSError *)ignoreThis error:(NSError *)error;

- (void)playerFetched:(GKPlayer *)player info:(GCInfo *)info;
- (void)playersFetched:(NSArray *)players info:(GCInfo *)info;

@end

@interface GameCenterManager : NSObject {
    NSString *mPlayerID;
	NSMutableDictionary *mEarnedAchievementCache;
	
	id <GameCenterManagerDelegate, NSObject> mDelegate; // Weak reference
}

// This property must be attomic to ensure that the cache is always in a viable state. TODO: if this needs to be thread-safe rather than atomic, re-implement it.
@property (nonatomic,retain) NSMutableDictionary* earnedAchievementCache;
@property (nonatomic,assign) id <GameCenterManagerDelegate> delegate;
@property (nonatomic,copy) NSString *playerID;
@property (nonatomic,readonly) BOOL authenticated;

- (BOOL)authenticateLocalUser:(QueryID *)qid;
- (void)resetAchievementCache;
- (void)fetchScoresForCategory:(NSString *)category range:(NSRange)range playerScope:(GKLeaderboardPlayerScope)playerScope timeScope:(GKLeaderboardTimeScope)timeScope qid:(QueryID *)qid;
- (void)fetchAchievements:(QueryID *)qid;
- (void)resetAchievements;
- (void)reportScore:(GKScore *)score;
- (void)reportScore:(int64_t)score forCategory:(NSString *)category;
- (void)submitAchievement:(NSString *)identifier percentComplete:(double)percentComplete;
- (void)fetchPlayerForID:(NSString *)playerID qid:(QueryID *)qid;
- (void)fetchPlayersForIDs:(NSArray *)playerIDs qid:(QueryID *)qid;

@end
