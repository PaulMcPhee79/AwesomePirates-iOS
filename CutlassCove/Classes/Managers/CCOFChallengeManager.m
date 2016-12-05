//
//  CCOFChallengeManager.m
//  CutlassCove
//
//  Created by Paul McPhee on 3/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCOFChallengeManager.h"
#import "OpenFeint/OpenFeint.h"
#import "OpenFeint/OFChallengeService.h"
#import "OpenFeint/OFChallenge.h"
#import "OpenFeint/OFChallengeDefinition.h"
#import "OpenFeint/OFUser.h"
#import "OpenFeint/OFCurrentUser.h"
#import "OpenFeint/OpenFeint+NSNotification.h"
#import "MultiPurposeEvent.h"
#import "GameStats.h"
#import "GameController.h"
#import "Globals.h"

@interface CCOFChallengeManager ()

@property (nonatomic,retain) OFChallengeToUser *currentChallengeToUser;
@property (nonatomic,assign) NSUInteger numOFUnviewedChallenges;

- (void)setChallengeType:(CCOFChallengeType)challengeType;
- (void)setChallengeMode:(CCOFChallengeMode)challengeMode;

- (void)submitCreatedChallengeWithScore:(int64_t)score;
- (void)submitCreatedChallengeWithSpeed:(double)speed;
- (void)submitAttemptedChallengeWithScore:(int64_t)score;
- (void)submitAttemptedChallengeWithSpeed:(double)speed;

- (void)submitAttemptedChallenge:(OFChallengeToUser *)challengeToUser;
- (NSString *)descriptionForChallengeType:(CCOFChallengeType)type withResult:(OFChallengeResult)result score:(NSString *)score scoreToBeat:(NSString *)scoreToBeat;

// Registered Notification Callbacks
- (void)onUnviewedChallengeCountChanged:(NSNotification *)notice;

// OFInvocation Callbacks
- (void)onUserApprovedFeintCreateChallenge;
- (void)onUserDeniedFeintCreateChallenge;
- (void)onSubmitChallengeResultSucceeded;
- (void)onSubmitChallengeResultFailed;

@end


@implementation CCOFChallengeManager

@synthesize numOFUnviewedChallenges = mNumOFUnviewedChallenges;

@synthesize currentChallengeToUser = mCurrentChallengeToUser;
@synthesize challengeType = mChallengeType;
@synthesize challengeMode = mChallengeMode;
@dynamic numUnviewedChallenges;

- (id)init {
    if (self = [super init]) {
        // DON'T USE GAMECONTROLLER IN HERE
        mNumCCViewedChallenges = 0;
        mNumOFUnviewedChallenges = 0;
        mQueuedChallengeType = CCOFChallengeNull;
        mChallengeType = CCOFChallengeNull;
        mChallengeMode = CCOFChallengeModeNull;
        mCompleteChallengeResendCount = 0;
        mCurrentChallengeToUser = nil;
#if CC_OF_ENABLED
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUnviewedChallengeCountChanged:) name:OFNSNotificationUnviewedChallengeCountChanged object:nil];
        //[OFChallengeToUser setDelegate:self];
#endif
    }
    return self;
}

- (void)dealloc {
#if CC_OF_ENABLED
    [OFChallengeToUser setDelegate:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OFNSNotificationUnviewedChallengeCountChanged object:nil];
#endif
    [mCurrentChallengeToUser release]; mCurrentChallengeToUser = nil;
    [super dealloc];
}

- (NSUInteger)numUnviewedChallenges {
    if (mNumOFUnviewedChallenges >= mNumCCViewedChallenges)
        return mNumOFUnviewedChallenges - mNumCCViewedChallenges;
    else
        return 0;
}

- (void)setNumOFUnviewedChallenges:(NSUInteger)numOFUnviewedChallenges {
    mNumOFUnviewedChallenges = numOFUnviewedChallenges;
    mNumCCViewedChallenges = MIN(mNumCCViewedChallenges,mNumOFUnviewedChallenges);
}

- (void)broadcastUnviewedChallengeCount {
    [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_OF_USER_HAS_UNVIEWED_CHALLENGES]];
}

- (void)resetUnviewedChallengeCount {
    mNumCCViewedChallenges = mNumOFUnviewedChallenges;
    [self broadcastUnviewedChallengeCount];
}

- (void)onUnviewedChallengeCountChanged:(NSNotification*)notice {
    self.numOFUnviewedChallenges = [(NSNumber*)[[notice userInfo] objectForKey:OFNSNotificationInfoUnviewedChallengeCount] unsignedIntegerValue];
    [self broadcastUnviewedChallengeCount];
}

- (void)setCurrentChallengeToUser:(OFChallengeToUser *)currentChallengeToUser {
    if (mCurrentChallengeToUser == currentChallengeToUser)
        return;
    [currentChallengeToUser retain];
    [mCurrentChallengeToUser autorelease];
    mCurrentChallengeToUser = currentChallengeToUser;
    
    [self beginChallengeWithType:[CCOFChallengeManager challengeTypeForTitle:mCurrentChallengeToUser.challenge.challengeDefinition.title]];
}

- (void)setChallengeType:(CCOFChallengeType)challengeType {
    mChallengeType = challengeType;
}

- (void)setChallengeMode:(CCOFChallengeMode)challengeMode {
    mChallengeMode = challengeMode;
}

- (void)createChallengeWithType:(CCOFChallengeType)type {
#if CC_OF_ENABLED
    if (type == CCOFChallengeNull || mChallengeMode != CCOFChallengeModeNull)
        return;
    
    if ([OpenFeint hasUserApprovedFeint]) {
        MultiPurposeEvent *event = [MultiPurposeEvent multiPurposeEventWithType:CUST_EVENT_TYPE_OF_CHALLENGE_CREATED bubbles:NO];

        if ([OpenFeint isOnline]) {
            self.challengeMode = CCOFChallengeModeCreating;
            self.challengeType = type;
            [event.data setObject:[NSNumber numberWithBool:YES] forKey:CUST_EVENT_TYPE_OF_CHALLENGE_CREATED];
        } else {
            [event.data setObject:[NSNumber numberWithBool:NO] forKey:CUST_EVENT_TYPE_OF_CHALLENGE_CREATED];
        }
        
        [self dispatchEvent:event];
    } else {
        mQueuedChallengeType = type;
        [OpenFeint presentUserFeintApprovalModalInvocation:[OFInvocation invocationForTarget:self selector:@selector(onUserApprovedFeintCreateChallenge)]
                                          deniedInvocation:[OFInvocation invocationForTarget:self selector:@selector(onUserDeniedFeintCreateChallenge)]];
    }
#endif
}

- (void)beginChallengeWithType:(CCOFChallengeType)type {
#if CC_OF_ENABLED
    if (type == CCOFChallengeNull || mChallengeMode != CCOFChallengeModeNull)
        return;
    
    if ([OpenFeint hasUserApprovedFeint]) {
        self.challengeMode = CCOFChallengeModeAttempting;
        self.challengeType = type;
    }
    
    [OFChallengeToUser setDelegate:self];
#endif
}

- (void)challengeConditionBreachedForType:(CCOFChallengeType)type {
    if (self.challengeType == type)
        [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_OF_CHALLENGE_CONDITION_BREACHED]];
}

- (void)finishChallenge {
    self.challengeMode = CCOFChallengeModeNull;
    self.challengeType = CCOFChallengeNull;
}

- (void)submitCreatedChallenge {
    if (self.challengeType == CCOFChallengeNull || self.challengeMode != CCOFChallengeModeCreating)
        return;
    if (self.challengeType == CCOFChallengeAverageSpeed)
        [self submitCreatedChallengeWithSpeed:GCTRL.thisTurn.speed];
    else
        [self submitCreatedChallengeWithScore:GCTRL.thisTurn.infamy];
}

- (void)submitAttemptedChallenge {
    if (self.currentChallengeToUser == nil || self.challengeType == CCOFChallengeNull || self.challengeMode != CCOFChallengeModeAttempting)
        return;
    if (self.challengeType == CCOFChallengeAverageSpeed)
        [self submitAttemptedChallengeWithSpeed:GCTRL.thisTurn.speed];
    else
        [self submitAttemptedChallengeWithScore:GCTRL.thisTurn.infamy];
}

- (void)submitCreatedChallengeWithScore:(int64_t)score {
#if CC_OF_ENABLED
    if (self.challengeType == CCOFChallengeNull || self.challengeMode != CCOFChallengeModeCreating)
        return;
    
    [OFChallengeService displaySendChallengeModal:[CCOFChallengeManager uniqueOFIDForCCOFChallengeType:self.challengeType]
                                    challengeText:[CCOFChallengeManager challengeTextForChallengeType:self.challengeType scoreText:[Globals commaSeparatedScore:score]]
                                    challengeData:[NSData dataWithBytes:&score length:sizeof(score)]];
#endif
}

- (void)submitCreatedChallengeWithSpeed:(double)speed {
#if CC_OF_ENABLED
    if (self.challengeType == CCOFChallengeNull || self.challengeMode != CCOFChallengeModeCreating)
        return;
    
    [OFChallengeService displaySendChallengeModal:[CCOFChallengeManager uniqueOFIDForCCOFChallengeType:self.challengeType]
                                    challengeText:[CCOFChallengeManager challengeTextForChallengeType:self.challengeType scoreText:[NSString stringWithFormat:@"%.3f", speed]]
                                    challengeData:[NSData dataWithBytes:&speed length:sizeof(speed)]];
#endif
}

- (void)submitAttemptedChallengeWithScore:(int64_t)score {
    if (mCurrentChallengeToUser == nil || self.challengeType == CCOFChallengeNull || self.challengeMode != CCOFChallengeModeAttempting)
        return;
    
    int64_t scoreToBeat = GCTRL.gameStats.ofChallenge.score;
    OFChallengeResult challengeResult = (score > scoreToBeat) ? kChallengeResultRecipientWon : ((score == scoreToBeat) ? kChallengeResultTie : kChallengeResultRecipientLost);
    NSString *resultDesc = [self descriptionForChallengeType:self.challengeType
                                                  withResult:challengeResult
                                                       score:[Globals commaSeparatedScore:score]
                                                 scoreToBeat:[Globals commaSeparatedScore:scoreToBeat]];
    //NSString *rechallengeDesc = [CCOFChallengeManager reChallengeTextForChallengeType:self.challengeType scoreText:[Globals commaSeparatedScore:score]];
    //NSData *resultData = [NSData dataWithBytes:&score length:sizeof(score)];
    
    self.currentChallengeToUser.result = challengeResult;
    self.currentChallengeToUser.resultDescription = resultDesc;
    [self submitAttemptedChallenge:self.currentChallengeToUser];
}

- (void)submitAttemptedChallengeWithSpeed:(double)speed {
    if (mCurrentChallengeToUser == nil || self.challengeType == CCOFChallengeNull || self.challengeMode != CCOFChallengeModeAttempting)
        return;
    
    double speedToBeat = GCTRL.gameStats.ofChallenge.speed;
    OFChallengeResult challengeResult = kChallengeResultRecipientLost;
    
    // Determine who won (rounded to 3 decimal places)
    if (speed >= speedToBeat) {
        int speedToBeatWhole = (int)speedToBeat;
        double speedToBeatFraction = 1000 * (speedToBeat - (double)speedToBeatWhole);
        speedToBeatWhole = (int)speedToBeatFraction;
        
        int speedWhole = (int)speed;
        double speedFraction = 1000 * (speed - (double)speedWhole);
        speedWhole = (int)speedFraction;
        
        if (speedWhole > speedToBeatWhole)
            challengeResult = kChallengeResultRecipientWon;
        else
            challengeResult = kChallengeResultTie;
    }
    
    NSString *resultDesc = [self descriptionForChallengeType:self.challengeType
                                                  withResult:challengeResult
                                                       score:[NSString stringWithFormat:@"%.3f", speed]
                                                 scoreToBeat:[NSString stringWithFormat:@"%.3f", speedToBeat]];
    //NSString *rechallengeDesc = [CCOFChallengeManager reChallengeTextForChallengeType:self.challengeType scoreText:[NSString stringWithFormat:@"%.3f", speed]];
    //NSData *resultData = [NSData dataWithBytes:&speed length:sizeof(speed)];
    
    self.currentChallengeToUser.result = challengeResult;
    self.currentChallengeToUser.resultDescription = resultDesc;
    [self submitAttemptedChallenge:self.currentChallengeToUser];
}

- (void)submitAttemptedChallenge:(OFChallengeToUser *)challengeToUser {
#if CC_OF_ENABLED
    mCompleteChallengeResendCount = 0;
    
    [challengeToUser completeWithResult:challengeToUser.result];
    [challengeToUser displayCompletionWithData:nil reChallengeDescription:nil];
    
    /*
    [OFChallengeService submitChallengeResult:self.currentChallengeToUser.resourceId
                                       result:self.currentChallengeToUser.result
                            resultDescription:resultDesc
                          onSuccessInvocation:[OFInvocation invocationForTarget:self selector:@selector(onSubmitChallengeResultSucceeded)]
                          onFailureInvocation:[OFInvocation invocationForTarget:self selector:@selector(onSubmitChallengeResultFailed)]];
    
    [OFChallengeService displayChallengeCompletedModal:self.currentChallengeToUser
                                            resultData:resultData
                                     resultDescription:resultDesc
                                reChallengeDescription:rechallengeDesc];
     */
#endif
}

- (void)resumeSavedChallenge {
#if CC_OF_ENABLED
    if (self.currentChallengeToUser)
        return;
    self.currentChallengeToUser = [OFChallengeService readChallengeToUserFromFile:@"CCOF_SavedChallenge"];
#endif
}

- (void)saveChallenge {
#if CC_OF_ENABLED
    if (self.currentChallengeToUser == nil)
        return;
    [OFChallengeService writeChallengeToUserToFile:@"CCOF_SavedChallenge" challengeToUser:self.currentChallengeToUser];
#endif
}

- (NSString *)descriptionForChallengeType:(CCOFChallengeType)type withResult:(OFChallengeResult)result score:(NSString *)score scoreToBeat:(NSString *)scoreToBeat {
    NSString *desc = nil;
    
    // Note: Use mCurrentChallengeToUser.challenge.challenger.name to insert the challenger's name into the description text.
    
    switch (result) {
        case kChallengeResultRecipientWon:
        case kChallengeResultRecipientLost:
        case kChallengeResultTie:
            if (type == CCOFChallengeAverageSpeed)
                desc = [NSString stringWithFormat:@"%@ completed 3 laps with an average speed of %@ Mph in response to the challenge of %@ Mph.", @"%@", score, scoreToBeat];
            else
                desc = [NSString stringWithFormat:@"%@ scored %@ in response to the challenge of %@.", @"%@", score, scoreToBeat];
            break;
        case kChallengeIncomplete:
        default:
            desc = @"";
            break;
    }
    
    return desc;
}

// OFInvocation Callbacks
- (void)onUserApprovedFeintCreateChallenge {
    CCOFChallengeType type = mQueuedChallengeType;
    mQueuedChallengeType = CCOFChallengeNull;
    [self createChallengeWithType:type];
}

- (void)onUserDeniedFeintCreateChallenge {
    mQueuedChallengeType = CCOFChallengeNull;
    // TODO: Fire some event
}

- (void)onSubmitChallengeResultSucceeded {
    
}

- (void)onSubmitChallengeResultFailed {
    
}


// Class Functions
+ (NSInteger)indexForChallengeType:(CCOFChallengeType)type {
    return ((NSInteger)type - 1);
}

+ (CCOFChallengeType)challengeTypeForIndex:(NSInteger)index {
    NSInteger adjustedIndex = index + 1;
    
    if (adjustedIndex >= CCOFChallengeOnlyBlueCrosses && adjustedIndex <= CCOFChallengeAverageSpeed)
        return (CCOFChallengeType)adjustedIndex;
    else
        return CCOFChallengeNull;
}

+ (NSString *)challengeTitleForType:(CCOFChallengeType)type {
    NSString *title = nil;
    
    switch (type) {
        case CCOFChallengeOnlyBlueCrosses: title = @"Only Blue Crosses"; break;
        case CCOFChallengeOnlyRicochets: title = @"Only Ricochets"; break;
        case CCOFChallengeNoRicochets: title = @"No Ricochets"; break;
        case CCOFChallengeNoMisses: title = @"No Misses"; break;
        case CCOFChallengeNoHitsTaken: title = @"No Hits Taken"; break;
        case CCOFChallengeNoVoodooSpellsOrMunitions: title = @"No Voodoo Spells or Munitions"; break;
        case CCOFChallengeNoNavyShipsSunk: title = @"No Navy Ships Sunk"; break;
        case CCOFChallengeNoPirateShipsSunk: title = @"No Rival Pirate Ships Sunk"; break;
        case CCOFChallengeAverageSpeed: title = @"Fastest"; break;
        case CCOFChallengeNull:
        default:
            title = nil;
            break;
    }
    
    return title;
}

+ (CCOFChallengeType)challengeTypeForTitle:(NSString *)challengeTitle {
    NSArray *allTitles = [NSArray arrayWithObjects:
                          @"Only Blue Crosses",
                          @"Only Ricochets",
                          @"No Ricochets",
                          @"No Misses",
                          @"No Hits Taken",
                          @"No Voodoo Spells or Munitions",
                          @"No Navy Ships Sunk",
                          @"No Rival Pirate Ships Sunk",
                          @"Fastest",
                          nil];
    NSInteger index = 0;
    
    for (NSString *title in allTitles) {
        if ([title isEqualToString:challengeTitle])
            break;
        ++index;
    }
    
    return [self challengeTypeForIndex:index];
}

+ (CCOFChallengeType)challengeTypeFromUniqueOFID:(NSString *)uniqueID {
    CCOFChallengeType challengeType = CCOFChallengeNull;
    
    for (int i = CCOFChallengeOnlyBlueCrosses; i <= CCOFChallengeAverageSpeed; ++i) {
        if ([uniqueID isEqualToString:[self uniqueOFIDForCCOFChallengeType:(CCOFChallengeType)i]]) {
            challengeType = (CCOFChallengeType)i;
            break;
        }
    }
    
    return challengeType;
}

+ (NSString *)uniqueOFIDForCCOFChallengeType:(CCOFChallengeType)type {
    NSString *uniqueOFID = nil;
    
#ifdef CHEEKY_LITE_VERSION
    switch (type) {
        case CCOFChallengeOnlyBlueCrosses: uniqueOFID = @"29852"; break;
        case CCOFChallengeOnlyRicochets: uniqueOFID = @"29862"; break;
        case CCOFChallengeNoRicochets: uniqueOFID = @"29872"; break;
        case CCOFChallengeNoMisses: uniqueOFID = @"29882"; break;
        case CCOFChallengeNoHitsTaken: uniqueOFID = @"29892"; break;
        case CCOFChallengeNoVoodooSpellsOrMunitions: uniqueOFID = @"29902"; break;
        case CCOFChallengeNoNavyShipsSunk: uniqueOFID = @"29912"; break;
        case CCOFChallengeNoPirateShipsSunk: uniqueOFID = @"29922"; break;
        case CCOFChallengeNull:
        default:
            uniqueOFID = nil;
            break;
    }
#else
    switch (type) {
        case CCOFChallengeOnlyBlueCrosses: uniqueOFID = @"29393"; break;
        case CCOFChallengeOnlyRicochets: uniqueOFID = @"29403"; break;
        case CCOFChallengeNoRicochets: uniqueOFID = @"29413"; break;
        case CCOFChallengeNoMisses: uniqueOFID = @"29423"; break;
        case CCOFChallengeNoHitsTaken: uniqueOFID = @"29433"; break;
        case CCOFChallengeNoVoodooSpellsOrMunitions: uniqueOFID = @"29443"; break;
        case CCOFChallengeNoNavyShipsSunk: uniqueOFID = @"29453"; break;
        case CCOFChallengeNoPirateShipsSunk: uniqueOFID = @"29463"; break;
        case CCOFChallengeAverageSpeed: uniqueOFID = @"29473"; break;
        case CCOFChallengeNull:
        default:
            uniqueOFID = nil;
            break;
    }
#endif
    
    return uniqueOFID;
}

+ (NSString *)createChallengeTextForChallengeType:(CCOFChallengeType)type {
    NSString *challengeText = nil;
    
    switch (type) {
        case CCOFChallengeOnlyBlueCrosses: challengeText = @"Maximize your score without getting a red cross."; break;
        case CCOFChallengeOnlyRicochets: challengeText = @"Maximize your score without firing a shot that sinks fewer than two ships."; break;
        case CCOFChallengeNoRicochets: challengeText = @"Maximize your score without firing a shot that sinks more than one ship."; break;
        case CCOFChallengeNoMisses: challengeText = @"Maximize your score without missing."; break;
        case CCOFChallengeNoHitsTaken: challengeText = @"Maximize your score without being shot."; break;
        case CCOFChallengeNoVoodooSpellsOrMunitions: challengeText = @"Maximize your score without using Voodoo Spells or Munitions."; break;
        case CCOFChallengeNoNavyShipsSunk: challengeText = @"Maximize your score without sinking any navy ships."; break;
        case CCOFChallengeNoPirateShipsSunk: challengeText = @"Maximize your score without sinking any rival pirate ships."; break;
        case CCOFChallengeAverageSpeed: challengeText = @"Complete 3 laps of the race circuit as quickly as possible."; break;
        case CCOFChallengeNull:
        default:
            challengeText = nil;
            break;
    }
    
    return challengeText;
}

+ (NSString *)challengeTextForChallengeType:(CCOFChallengeType)type scoreText:(NSString *)scoreText {
    NSString *challengeText = nil;
    
    switch (type) {
        case CCOFChallengeOnlyBlueCrosses:
            challengeText = [NSString stringWithFormat:@"Score more than %@ without getting a red cross.", scoreText];
            break;
        case CCOFChallengeOnlyRicochets:
            challengeText = [NSString stringWithFormat:@"Score more than %@ without firing a shot that sinks fewer than two ships.", scoreText];
            break;
        case CCOFChallengeNoRicochets:
            challengeText = [NSString stringWithFormat:@"Score more than %@ without firing a shot that sinks more than one ship.", scoreText];
            break;
        case CCOFChallengeNoMisses:
            challengeText = [NSString stringWithFormat:@"Score more than %@ without missing.", scoreText];
            break;
        case CCOFChallengeNoHitsTaken:
            challengeText = [NSString stringWithFormat:@"Score more than %@ without being shot.", scoreText];
            break;
        case CCOFChallengeNoVoodooSpellsOrMunitions:
            challengeText = [NSString stringWithFormat:@"Score more than %@ without using Voodoo Spells or Munitions.", scoreText];
            break;
        case CCOFChallengeNoNavyShipsSunk:
            challengeText = [NSString stringWithFormat:@"Score more than %@ without sinking any navy ships.", scoreText];
            break;
        case CCOFChallengeNoPirateShipsSunk:
            challengeText = [NSString stringWithFormat:@"Score more than %@ without sinking any rival pirate ships.", scoreText];
            break;
        case CCOFChallengeAverageSpeed:
            challengeText = [NSString stringWithFormat:@"Complete 3 laps of the race circuit with an average speed of more than %@ Mph.", scoreText];
            break;
        case CCOFChallengeNull:
        default:
            challengeText = nil;
            break;
    }
    
    return challengeText;
}

+ (NSString *)reChallengeTextForChallengeType:(CCOFChallengeType)type scoreText:(NSString *)scoreText {
    return [self challengeTextForChallengeType:type scoreText:scoreText];
}

+ (NSString *)textureNameForChallengeType:(CCOFChallengeType)type {
    NSString *textureName = nil;
    
    switch (type) {
        case CCOFChallengeOnlyBlueCrosses: textureName = @"cc-of-challenge-only-blue-crosses"; break;
        case CCOFChallengeOnlyRicochets: textureName = @"cc-of-challenge-only-ricochets"; break;
        case CCOFChallengeNoRicochets: textureName = @"cc-of-challenge-no-ricochets"; break;
        case CCOFChallengeNoMisses: textureName = @"cc-of-challenge-no-misses"; break;
        case CCOFChallengeNoHitsTaken: textureName = @"cc-of-challenge-no-hits-taken"; break;
        case CCOFChallengeNoVoodooSpellsOrMunitions: textureName = @"cc-of-challenge-no-spells-munitions"; break;
        case CCOFChallengeNoNavyShipsSunk: textureName = @"cc-of-challenge-no-navy"; break;
        case CCOFChallengeNoPirateShipsSunk: textureName = @"cc-of-challenge-no-pirates"; break;
        case CCOFChallengeAverageSpeed: textureName = @"cc-of-challenge-avg-speed"; break;
        case CCOFChallengeNull:
        default:
            textureName = nil;
            break;
    }
    
    return textureName;
}

///////////////////////////////////////////////////////
//////////////// OFChallengeDelegate //////////////////
///////////////////////////////////////////////////////

/// @note	It is recommended to present the user with a start challenge screen before launching the actual challenge
- (void)userLaunchedChallenge:(OFChallengeToUser *)challengeToLaunch withChallengeData:(NSData *)challengeData {
    MultiPurposeEvent *event = [MultiPurposeEvent multiPurposeEventWithType:CUST_EVENT_TYPE_OF_CHALLENGE_LAUNCH_REQUEST bubbles:NO];
    [event.data setObject:[NSNumber numberWithBool:YES] forKey:CUST_EVENT_TYPE_OF_CHALLENGE_LAUNCH_REQUEST];
    [self dispatchEvent:event];
    
    NSNumber *requestReply = (NSNumber *)[event.data objectForKey:CUST_EVENT_TYPE_OF_CHALLENGE_LAUNCH_REQUEST];
    
    if (requestReply == nil || [requestReply boolValue] == NO)
        return;
    
    self.currentChallengeToUser = challengeToLaunch;
    
    if (self.challengeType != CCOFChallengeNull) {
        GCTRL.gameStats.ofChallenge = [CCOFChallenge challengeWithType:self.challengeType challengeData:challengeData];
        [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_OF_CHALLENGE_LAUNCHED_FROM_DASHBOARD]];
    }
}

/// @note	This gets called when the user selects Try Again after completing a challenge.
///			You must keep track of what challenge the player is in. The challenge data will not be downloaded again. 
///			For one shot challenges this method may be left empty.
- (void)userRestartedChallenge {
    // TODO: Fire an event to reset the scene so that the challenge can be attempted again.
}

/// @note	If this is implemented the send challenge screen will have a "Create Stronger Challenge" button (MultiAttempts challenges only)
///			If this is not implemented the "Create Stronger Challenge" is left out
///			This gets called when the user select the "Create Stronger Challenge" button
//- (void)userRestartedCreateChallenge {
//    [self createChallengeWithType:mChallengeType];
//}

/// @note	This gets called as the OFCompletedChallenge screen is closing if the user did not send out challenges. 
///			You should here direct the user to an appropriate screen.
- (void)completedChallengeScreenClosed {
    // NOTE: I think this is called from when the user exits the CHALLENGE OVER screen and chose NOT to send out a harder challenge in response.
    //self.currentChallengeToUser = nil;
    
}

/// @note	This gets called as the OFSendChallenge screen is closing if the user did not send out challenges. 
///			You should here direct the user to an appropriate screen.
- (void)sendChallengeScreenClosed {
    // NOTE: I think this is called from when the user exits the CHALLENGE CREATED screen and chose NOT to send out the created challenge. 
     //self.currentChallengeToUser = nil;
}

/// @note	Gets called after user logs into OpenFeint
///			If he has pending challenges.  If you use custom UI it is
///			recommended to somewhere indicate the number of new challenges
- (void)userBootedWithUnviewedChallenges:(NSUInteger)numChallenges {
    self.numOFUnviewedChallenges = MAX(numChallenges,mNumOFUnviewedChallenges);
    [self broadcastUnviewedChallengeCount];
}

/// @note	This gets called from the send challenge controller or completed challenge controller or if the user sends out challenges.
///			sendChallengeScreenClosed or completedChallengeScreenClosed will get called after this depending on what screen its called from
- (void)userSentChallenges {
    // NOTE: I think this is called from when the user exits the CHALLENGE CREATED screen or the CHALLENGE OVER screen.
    [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_OF_CHALLENGE_SENT]];
}


///////////////////////////////////////////////////////
///////////// OFChallengeToUserDelegate ///////////////
///////////////////////////////////////////////////////
/// Invoked by an OFChallengeToUser class when completeWithResult successfully completes.
- (void)didCompleteChallenge:(OFChallengeToUser*)challengeToUser {
    mCompleteChallengeResendCount = 0;
}

/// Invoked by an OFChallengeToUser class when completeWithResult fails.
- (void)didFailCompleteChallenge:(OFChallengeToUser*)challengeToUser {
    if (self.currentChallengeToUser == challengeToUser && ++mCompleteChallengeResendCount > 3)
        return;
    [challengeToUser completeWithResult:challengeToUser.result];
}

/// Invoked by an OFChallengeToUser class when reject successfully completes.
- (void)didRejectChallenge:(OFChallengeToUser*)challengeToUser {
    NSLog(@"Challenge Rejection Succeeded");
}

/// Invoked by an OFChallengeToUser class when reject fails.
- (void)didFailRejectChallenge:(OFChallengeToUser*)challengeToUser {
    NSLog(@"Challenge Rejection Failed");
}

@end


@implementation CCOFChallenge

@synthesize type;
@dynamic score,speed;

+ (CCOFChallenge *)challengeWithType:(CCOFChallengeType)challengeType challengeData:(NSData *)challengeData {
    return [[[CCOFChallenge alloc] initWithChallengeType:challengeType challengeData:challengeData] autorelease];
}

- (id)initWithChallengeType:(CCOFChallengeType)challengeType challengeData:(NSData *)challengeData {
    if (self = [super init]) {
        type = challengeType;
        data = [challengeData retain];
    }
    return self;
}

- (int64_t)score {
    int64_t score = 0;
    [data getBytes:&score length:sizeof(score)];
    return score;
}

- (double)speed {
    double speed = 0;
    [data getBytes:&speed length:sizeof(speed)];
    return speed;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:(int)type forKey:@"type"];
	[coder encodeObject:data forKey:@"data"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
        type = (CCOFChallengeType)[decoder decodeIntForKey:@"type"];
        data = [[decoder decodeObjectForKey:@"data"] retain];
	}
	return self;
}

- (void)dealloc {
    [data release]; data = nil;
    [super dealloc];
}

@end
