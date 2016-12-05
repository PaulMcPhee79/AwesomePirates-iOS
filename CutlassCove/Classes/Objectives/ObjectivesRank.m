//
//  ObjectivesRank.m
//  Cutlass Cove
//
//  Created by Paul McPhee on 6/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ObjectivesRank.h"

@implementation ObjectivesRank

@synthesize rank = mRank;
@dynamic isCompleted,isMaxRank,displayRank,title,requiredNpcShipType,requiredAshType;

+ (ObjectivesRank *)objectivesRankWithRank:(uint)rank {
    return [[[ObjectivesRank alloc] initWithRank:rank] autorelease];
}

- (id)initWithRank:(uint)rank {
    if (self = [super init]) {
        mRank = rank;
        mObjectiveDescs = [[ObjectivesRank objectivesDescriptionsForRank:rank] retain];
    }
    return self;
}

- (void)dealloc {
    [mObjectiveDescs release]; mObjectiveDescs = nil;
    [super dealloc];
}

- (BOOL)isCompleted {
    BOOL completed = YES;
    
    for (ObjectivesDescription *objDesc in mObjectiveDescs)
        completed = completed && objDesc.isCompleted;
    
    return completed;
}

- (BOOL)isMaxRank {
    return (mRank == [ObjectivesRank maxRank]);
}

- (uint)displayRank {
    return mRank + 1;
}

- (NSString *)title {
    return [ObjectivesRank titleForRank:mRank];
}

- (uint)requiredNpcShipType {
    uint shipType = 0;
    
    for (ObjectivesDescription *objDesc in mObjectiveDescs) {
        if (objDesc.isCompleted == NO)
            shipType = [ObjectivesDescription requiredNpcShipTypeForKey:objDesc.key];
        
        if (shipType != 0)
            break;
    }
    
    return shipType;
}

- (uint)requiredAshType {
    uint ashType = 0;
    
    for (ObjectivesDescription *objDesc in mObjectiveDescs) {
        if (objDesc.isCompleted == NO)
            ashType = [ObjectivesDescription requiredAshTypeForKey:objDesc.key];
        
        if (ashType != 0)
            break;
    }
    
    return ashType;
}

- (void)forceCompletion {
    for (ObjectivesDescription *objDesc in mObjectiveDescs)
        [objDesc forceCompletion];
}

- (void)prepareForNewGame {
    for (ObjectivesDescription *objDesc in mObjectiveDescs) {
        if (objDesc.isCompleted == NO && objDesc.isCumulative == NO)
            [objDesc reset];
    }
}

- (ObjectivesDescription *)objectiveDescAtIndex:(uint)index {
    ObjectivesDescription *objDesc = nil;
    
    if (index < mObjectiveDescs.count)
        objDesc = (ObjectivesDescription *)[mObjectiveDescs objectAtIndex:index];
    
    return objDesc;
}

- (BOOL)isObjectiveCompletedAtIndex:(uint)index {
    BOOL completed = YES;
    
    if (index < mObjectiveDescs.count)
        completed = [(ObjectivesDescription *)[mObjectiveDescs objectAtIndex:index] isCompleted];
    
    return completed;
}

- (BOOL)isObjectiveFailedAtIndex:(uint)index {
    BOOL failed = NO;
    
    if (index < mObjectiveDescs.count)
        failed = [(ObjectivesDescription *)[mObjectiveDescs objectAtIndex:index] isFailed];
    
    return failed;
}

- (uint)objectiveCountAtIndex:(uint)index {
    uint count = 0;
    
    if (index < mObjectiveDescs.count)
        count = [(ObjectivesDescription *)[mObjectiveDescs objectAtIndex:index] count];
    
    return count;
}

- (uint)objectiveQuotaAtIndex:(uint)index {
    uint quota = 0;
    
    if (index < mObjectiveDescs.count)
        quota = [(ObjectivesDescription *)[mObjectiveDescs objectAtIndex:index] quota];
    
    return quota;
}

- (NSString *)objectiveTextAtIndex:(uint)index {
    NSString *text = nil;
    
    if (index < mObjectiveDescs.count)
        text = [(ObjectivesDescription *)[mObjectiveDescs objectAtIndex:index] description];
    
    return text;
}

- (NSString *)objectiveLogbookTextAtIndex:(uint)index {
    NSString *text = nil;
    
    if (index < mObjectiveDescs.count && self.isMaxRank == NO)
        text = [(ObjectivesDescription *)[mObjectiveDescs objectAtIndex:index] logbookDescription];
    
    return text;
}

- (void)increaseObjectiveCountAtIndex:(uint)index byAmount:(uint)amount {
    if (index < mObjectiveDescs.count) {
        ObjectivesDescription *objDesc = (ObjectivesDescription *)[mObjectiveDescs objectAtIndex:index];
        
        if (objDesc.isFailed == NO)
            objDesc.count += amount;
    }
}

- (void)setObjectiveCount:(uint)count atIndex:(uint)index {
    if (index < mObjectiveDescs.count) {
        ObjectivesDescription *objDesc = (ObjectivesDescription *)[mObjectiveDescs objectAtIndex:index];
        objDesc.count = count;
    }
}

- (void)setObjectiveFailed:(BOOL)isFailed atIndex:(uint)index {
    if (index < mObjectiveDescs.count) {
        ObjectivesDescription *objDesc = (ObjectivesDescription *)[mObjectiveDescs objectAtIndex:index];
        objDesc.isFailed = isFailed;
    }
}

- (void)syncWithObjectivesRank:(ObjectivesRank *)objRank {
    assert(objRank);
    
    uint i = 0;
    
    for (ObjectivesDescription *objDesc in mObjectiveDescs) {
        objDesc.count = [objRank objectiveCountAtIndex:i];
        objDesc.isFailed = [objRank isObjectiveFailedAtIndex:i];
        ++i;
    }
}

- (BOOL)upgradeToObjectivesRank:(ObjectivesRank *)objRank {
    BOOL didUpgrade = NO;
    uint i = 0;
    
    for (ObjectivesDescription *objDesc in mObjectiveDescs) {
        uint count = [objRank objectiveCountAtIndex:i];
        
        if (count > objDesc.count) {
            objDesc.count = count;
            didUpgrade = YES;
        }
        
        BOOL isFailed = [objRank isObjectiveFailedAtIndex:i];
        
        if (objDesc.isFailed && isFailed == NO)
            objDesc.isFailed = isFailed;
        
        ++i;
    }
    
    return didUpgrade;
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
        mRank = [(NSNumber *)[decoder decodeObjectForKey:@"rank"] unsignedIntValue];
        mObjectiveDescs = [(NSArray *)[decoder decodeObjectForKey:@"obejctiveDescs"] retain];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:[NSNumber numberWithUnsignedInt:mRank] forKey:@"rank"];
    [coder encodeObject:mObjectiveDescs forKey:@"obejctiveDescs"];
}

+ (uint)maxRank {
    return MAX_OBJECTIVES_RANK;
}

+ (uint)multiplierForRank:(uint)rank {
    return rank + 10;
}

+ (NSString *)titleForRank:(uint)rank {
    NSString *title = nil;
    
    switch (rank) {
        case RANK_UNRANKED: title = @"Unranked"; break;
#ifndef CHEEKY_LITE_VERSION
        case RANK_SWABBY: title = @"Swabby"; break;
        case RANK_DECKHAND: title = @"Deckhand"; break;
        case RANK_JACK_TAR: title = @"Jack Tar"; break;
        case RANK_OLD_SALT: title = @"Old Salt"; break;
        case RANK_HELMSMAN: title = @"Helmsman"; break;
#else
        case RANK_SWABBY: title = @"Jiker"; break;
        case RANK_DECKHAND: title = @"Powder Monkey"; break;
        case RANK_JACK_TAR: title = @"Boatswain"; break;
        case RANK_OLD_SALT: title = @"Quartermaster"; break;
        case RANK_HELMSMAN: title = @"Marauder"; break;
#endif
        case RANK_SEA_DOG: title = @"Sea Dog"; break;
        case RANK_VILLAIN: title = @"Villain"; break;
        case RANK_BRIGAND: title = @"Brigand"; break;
        case RANK_LOOTER: title = @"Looter"; break;
        case RANK_GALLOWS_BIRD: title = @"Gallows Bird"; break;
        case RANK_SCOUNDREL: title = @"Scoundrel"; break;
        case RANK_ROGUE: title = @"Rogue"; break;
        case RANK_PILLAGER: title = @"Pillager"; break;
        case RANK_PLUNDERER: title = @"Plunderer"; break;
        case RANK_FREEBOOTER: title = @"Freebooter"; break;
        case RANK_PRIVATEER: title = @"Privateer"; break;
        case RANK_CORSAIR: title = @"Corsair"; break;
        case RANK_BUCCANEER: title = @"Buccaneer"; break;
        case RANK_SEA_WOLF: title = @"Sea Wolf"; break;
        case RANK_SWASHBUCKLER: title = @"Swashbuckler"; break;
        case RANK_CALICO_JACK: title = @"Calico Jack"; break;
        case RANK_BLACK_BART: title = @"Black Bart"; break;
        case RANK_BARBAROSSA: title = @"Barbarossa"; break;
        case RANK_CAPTAIN_KIDD: title = @"Captain Kidd"; break;
        case RANK_CAPTAIN_OMALLEY: title = @"Captain O'Malley"; break;
        case RANK_MAJOR_STEDE: title = @"Major Stede"; break;
        case RANK_BLACK_BELLAMY: title = @"Black Bellamy"; break;
        case RANK_LONG_BEN: title = @"Long Ben"; break;
        case RANK_ADMIRAL_MORGAN: title = @"Admiral Morgan"; break;
        case RANK_THE_DRAGON: title = @"The Dragon"; break;
        default: title = @"Unranked"; break;
    }
    
    return title;
}

+ (NSArray *)objectivesDescriptionsForRank:(uint)rank {
    uint key = 3 * rank + 1;
    NSArray *descs = [NSArray arrayWithObjects:
                      [ObjectivesDescription objectivesDescriptionWithKey:key count:0],
                      [ObjectivesDescription objectivesDescriptionWithKey:key+1 count:0],
                      [ObjectivesDescription objectivesDescriptionWithKey:key+2 count:0],
                      nil];
    return descs;
}

+ (ObjectivesRank *)getCurrentRankFromRanks:(NSArray *)ranks {
    ObjectivesRank *currentRank = nil;
    
    for (ObjectivesRank *rank in ranks) {
        if (rank.isCompleted == NO || rank.isMaxRank) {
            currentRank = rank;
            break;
        }
    }
    
    if (currentRank == nil)
        currentRank = (ObjectivesRank *)[ranks lastObject];
    
    return currentRank;
}

+ (ObjectivesRank *)getRank:(uint)rank fromRanks:(NSArray *)ranks {
    ObjectivesRank *objRank = nil;
    
    if (rank < ranks.count)
        objRank = (ObjectivesRank *)[ranks objectAtIndex:rank];
    return objRank;
}

@end
