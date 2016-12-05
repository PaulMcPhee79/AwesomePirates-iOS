//
//  CCOFChallengeManager.h
//  CutlassCove
//
//  Created by Paul McPhee on 3/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenFeint/OFChallengeDelegate.h"
#import "OpenFeint/OFChallengeToUser.h"

#define CUST_EVENT_TYPE_OF_CHALLENGE_CONDITION_BREACHED @"OFChallengeConditionBreachedEvent"
#define CUST_EVENT_TYPE_OF_CHALLENGE_CREATED @"OFChallengeCreatedEvent"
#define CUST_EVENT_TYPE_OF_CHALLENGE_SENT @"OFChallengeSentEvent"
#define CUST_EVENT_TYPE_OF_CHALLENGE_LAUNCH_REQUEST @"OFChallengeLaunchRequestEvent"
#define CUST_EVENT_TYPE_OF_CHALLENGE_LAUNCHED_FROM_DASHBOARD @"OFChallengeLaunchedFromDashboardEvent"
#define CUST_EVENT_TYPE_OF_USER_HAS_UNVIEWED_CHALLENGES @"OFUserHasUnviewedChallengesEvent"

typedef enum {
    CCOFChallengeNull = 0,
    CCOFChallengeOnlyBlueCrosses,
    CCOFChallengeOnlyRicochets,
    CCOFChallengeNoRicochets,
    CCOFChallengeNoMisses,
    CCOFChallengeNoHitsTaken,
    CCOFChallengeNoVoodooSpellsOrMunitions,
    CCOFChallengeNoNavyShipsSunk,
    CCOFChallengeNoPirateShipsSunk,
    CCOFChallengeAverageSpeed
} CCOFChallengeType;

typedef enum {
    CCOFChallengeModeNull = 0,
    CCOFChallengeModeCreating,
    CCOFChallengeModeAttempting
} CCOFChallengeMode;


@class OFChallengeToUser;

@interface CCOFChallengeManager : SPEventDispatcher <OFChallengeDelegate,OFChallengeToUserDelegate> {
    NSUInteger mNumCCViewedChallenges;
    NSUInteger mNumOFUnviewedChallenges;
    
    CCOFChallengeType mQueuedChallengeType;
    CCOFChallengeType mChallengeType;
    CCOFChallengeMode mChallengeMode;
    
    // Most recent challenge
    uint mCompleteChallengeResendCount;
    OFChallengeToUser *mCurrentChallengeToUser;
}

@property (nonatomic,readonly) NSUInteger numUnviewedChallenges;
@property (nonatomic,readonly) CCOFChallengeType challengeType;
@property (nonatomic,readonly) CCOFChallengeMode challengeMode;


- (void)broadcastUnviewedChallengeCount;
- (void)resetUnviewedChallengeCount;
- (void)createChallengeWithType:(CCOFChallengeType)type;
- (void)beginChallengeWithType:(CCOFChallengeType)type;
- (void)challengeConditionBreachedForType:(CCOFChallengeType)type;
- (void)finishChallenge;

- (void)submitCreatedChallenge;
- (void)submitAttemptedChallenge;

- (void)resumeSavedChallenge;
- (void)saveChallenge;

+ (NSInteger)indexForChallengeType:(CCOFChallengeType)type;
+ (CCOFChallengeType)challengeTypeForIndex:(NSInteger)index;
+ (NSString *)challengeTitleForType:(CCOFChallengeType)type;
+ (CCOFChallengeType)challengeTypeForTitle:(NSString *)challengeTitle;
+ (CCOFChallengeType)challengeTypeFromUniqueOFID:(NSString *)uniqueID;
+ (NSString *)uniqueOFIDForCCOFChallengeType:(CCOFChallengeType)type;
+ (NSString *)createChallengeTextForChallengeType:(CCOFChallengeType)type;
+ (NSString *)challengeTextForChallengeType:(CCOFChallengeType)type scoreText:(NSString *)scoreText;
+ (NSString *)reChallengeTextForChallengeType:(CCOFChallengeType)type scoreText:(NSString *)scoreText;
+ (NSString *)textureNameForChallengeType:(CCOFChallengeType)type;

@end

@interface CCOFChallenge : NSObject <NSCoding> {
    CCOFChallengeType type;
    NSData *data;
}

@property (nonatomic,readonly) CCOFChallengeType type;
@property (nonatomic,readonly) int64_t score;
@property (nonatomic,readonly) double speed;

+ (CCOFChallenge *)challengeWithType:(CCOFChallengeType)challengeType challengeData:(NSData *)challengeData;
- (id)initWithChallengeType:(CCOFChallengeType)challengeType challengeData:(NSData *)challengeData;

@end

