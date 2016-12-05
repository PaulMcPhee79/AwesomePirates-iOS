//
//  ObjectivesRank.h
//  Cutlass Cove
//
//  Created by Paul McPhee on 6/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectivesDescription.h"

#define kNumObjectivesPerRank 3

#define RANK_UNRANKED 0
#define RANK_SWABBY 1
#define RANK_DECKHAND 2
#define RANK_JACK_TAR 3
#define RANK_OLD_SALT 4
#define RANK_HELMSMAN 5
#define RANK_SEA_DOG 6
#define RANK_VILLAIN 7
#define RANK_BRIGAND 8
#define RANK_LOOTER 9
#define RANK_GALLOWS_BIRD 10
#define RANK_SCOUNDREL 11
#define RANK_ROGUE 12
#define RANK_PILLAGER 13
#define RANK_PLUNDERER 14
#define RANK_FREEBOOTER 15
#define RANK_PRIVATEER 16
#define RANK_CORSAIR 17
#define RANK_BUCCANEER 18
#define RANK_SEA_WOLF 19
#define RANK_SWASHBUCKLER 20
#define RANK_CALICO_JACK 21
#define RANK_BLACK_BART 22
#define RANK_BARBAROSSA 23
#define RANK_CAPTAIN_KIDD 24
#define RANK_CAPTAIN_OMALLEY 25
#define RANK_MAJOR_STEDE 26
#define RANK_BLACK_BELLAMY 27
#define RANK_LONG_BEN 28
#define RANK_ADMIRAL_MORGAN 29
#define RANK_THE_DRAGON 30      // Sir Francis Drake: El Draque (Spanish), Draco (Latin, "The Dragon")

#ifdef CHEEKY_LITE_VERSION
    #define MAX_OBJECTIVES_RANK RANK_HELMSMAN
#else
    #define MAX_OBJECTIVES_RANK RANK_THE_DRAGON
#endif

#define NUM_OBJECTIVES_RANKS 31

@interface ObjectivesRank : NSObject <NSCoding> {
    uint mRank;
    NSArray *mObjectiveDescs;
}

@property (nonatomic,readonly) BOOL isCompleted;
@property (nonatomic,readonly) BOOL isMaxRank;
@property (nonatomic,readonly) uint rank;
@property (nonatomic,readonly) uint displayRank;
@property (nonatomic,readonly) NSString *title;
@property (nonatomic,readonly) uint requiredNpcShipType;
@property (nonatomic,readonly) uint requiredAshType;

+ (ObjectivesRank *)objectivesRankWithRank:(uint)rank;
- (id)initWithRank:(uint)rank;

- (void)forceCompletion;
- (void)prepareForNewGame;

// Getters
- (ObjectivesDescription *)objectiveDescAtIndex:(uint)index;
- (BOOL)isObjectiveCompletedAtIndex:(uint)index;
- (BOOL)isObjectiveFailedAtIndex:(uint)index;
- (uint)objectiveCountAtIndex:(uint)index;
- (uint)objectiveQuotaAtIndex:(uint)index;
- (NSString *)objectiveTextAtIndex:(uint)index;
- (NSString *)objectiveLogbookTextAtIndex:(uint)index;

// Setters
- (void)increaseObjectiveCountAtIndex:(uint)index byAmount:(uint)amount;
- (void)setObjectiveCount:(uint)count atIndex:(uint)index;
- (void)setObjectiveFailed:(BOOL)isFailed atIndex:(uint)index;
- (void)syncWithObjectivesRank:(ObjectivesRank *)objRank;
- (BOOL)upgradeToObjectivesRank:(ObjectivesRank *)objRank;

+ (uint)maxRank;
+ (uint)multiplierForRank:(uint)rank;
+ (NSString *)titleForRank:(uint)rank;
+ (NSArray *)objectivesDescriptionsForRank:(uint)rank;
+ (ObjectivesRank *)getCurrentRankFromRanks:(NSArray *)ranks;
+ (ObjectivesRank *)getRank:(uint)rank fromRanks:(NSArray *)ranks;

@end
