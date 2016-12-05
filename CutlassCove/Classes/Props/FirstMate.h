//
//  FirstMate.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 6/10/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

#define CUST_EVENT_TYPE_FIRST_MATE_NEXT_MSG @"firstMateNextMsgEvent"
#define CUST_EVENT_TYPE_FIRST_MATE_ALL_MSGS_SPOKEN @"firstMateAllMsgsSpokenEvent"
#define CUST_EVENT_TYPE_FIRST_MATE_DECISION @"firstMateDecisionEvent"
#define CUST_EVENT_TYPE_FIRST_MATE_RETIRED @"firstMateRetiredEvent"

@class MessageCloud;

@interface FirstMate : Prop {
	BOOL mRetiring;
	BOOL mChoice;
	BOOL mDecision;
	BOOL mContinuousFeed;
	
    int mDir;
	int mMsgIndex;
	int mUserData;
    
    NSString *mTextureName;
    
	SPPoint *mDest;
	SPPoint *mDespawn;
	
    NSArray *mMsgs;
	Prop *mTouchBarrier;
	MessageCloud *mMsgCloud;
}

@property (nonatomic,readonly) BOOL decision;
@property (nonatomic,retain) SPPoint *dest;
@property (nonatomic,retain) SPPoint *despawn;
@property (nonatomic,assign) BOOL continuousFeed;
@property (nonatomic,assign) int userData;

+ (FirstMate *)firstMateWithCategory:(int)category msgs:(NSArray *)msgs textureName:(NSString *)textureName dir:(int)dir choice:(BOOL)choice;
- (id)initWithCategory:(int)category msgs:(NSArray *)msgs textureName:(NSString *)textureName dir:(int)dir choice:(BOOL)choice;
- (void)deployTouchBarrier;
- (void)retractTouchBarrier;
- (void)beginAnnoucements;
- (void)retireToCabin;
- (void)addMsgs:(NSArray *)msgs;

@end
