//
//  ProfileResultEvent.h
//  Cutlass Cove
//
//  Created by Paul McPhee on 12/01/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AchievementsDescription.h"
#import "LeaderboardDescription.h"

#define CHEEKY_ERROR_DOMAIN @"CheekyMammothErrorDomain"

#define CUST_EVENT_TYPE_LOGIN_COMPLETE @"loginCompleteEvent"
#define CUST_EVENT_TYPE_LOGIN_INCOMPLETE @"loginIncompleteEvent"
#define CUST_EVENT_TYPE_LOGGED_OUT @"loggedOutEvent"
#define CUST_EVENT_TYPE_LEADERBOARD_FETCHED @"leaderboardFetchedEvent"
#define CUST_EVENT_TYPE_ACHIEVEMENTS_FETCHED @"achievementsFetchedEvent"

typedef enum {
	ScoreGC = 0,
	ScoreFB,
	ScoreOF
} ScoreState;

typedef enum {
	ScopeGlobal = 0,
	ScopeToday,
	ScopeThisWeek,
	ScopeAllTime,
	ScopeFriends,
	ScopeLocal
} ScopeState;

typedef enum {
	AchievementLocal = 0,
	AchievementGC,
	AchievementFB,
	AchievementOF
} AchievementState;


@interface ProfileResultEvent : SPEvent {
	NSError *mError;
	
	NSArray *mAchievements;
	NSArray *mLeaderboard;
	LeaderboardDescription *mLocalPlayerScore;
}

@property (nonatomic,readonly) NSError *error;
@property (nonatomic,readonly) NSString *errorString;
@property (nonatomic,readonly) NSArray *achievements;
@property (nonatomic,readonly) NSArray *leaderboard;
@property (nonatomic,readonly) LeaderboardDescription *localPlayerScore;

+ (ProfileResultEvent *)profileResultEventWithType:(NSString *)type
									  achievements:(NSArray *)achievements
									   leaderboard:(NSArray *)leaderboard
								  localPlayerScore:(LeaderboardDescription *)localPlayerScore
                                             error:(NSError *)error
										   bubbles:(BOOL)bubbles;
- (id)initWithType:(NSString *)type
	  achievements:(NSArray *)achievements
	   leaderboard:(NSArray *)leaderboard
  localPlayerScore:(LeaderboardDescription *)localPlayerScore
             error:(NSError *)error
		   bubbles:(BOOL)bubbles;

@end
