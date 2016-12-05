//
//  AshProc.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 27/05/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>


#define CUST_EVENT_TYPE_ASH_PROC @"ashProcEvent"


@interface AshProc : SPEventDispatcher <NSCoding> {
	uint mProc;
	uint mChargesRemaining;
	uint mTotalCharges;
	uint mRequirementCount;
	uint mRequirementCeiling;
	uint mAddition;
	uint mRicochetAddition;
	uint mMultiplier;
	float mRicochetMultiplier;
	BOOL mDeactivatesOnMiss;
	float mChanceToProc;
	float mSpecialChanceToProc;
	NSString *mSpecialProcEventKey;
	NSString *mTexturePrefix;
	NSString *mSoundName;
}

@property (nonatomic,assign) uint proc;
@property (nonatomic,assign) uint chargesRemaining;
@property (nonatomic,assign) uint totalCharges;
@property (nonatomic,assign) uint requirementCount;
@property (nonatomic,assign) uint requirementCeiling;
@property (nonatomic,assign) uint addition;
@property (nonatomic,assign) uint ricochetAddition;
@property (nonatomic,assign) uint multiplier;
@property (nonatomic,assign) float ricochetMultiplier;
@property (nonatomic,assign) BOOL deactivatesOnMiss;
@property (nonatomic,assign) float chanceToProc;
@property (nonatomic,assign) float specialChanceToProc;
@property (nonatomic,copy) NSString *specialProcEventKey;
@property (nonatomic,copy) NSString *texturePrefix;
@property (nonatomic,copy) NSString *soundName;

+ (AshProc *)ashProc;
- (BOOL)isActive;
- (void)deactivate;
- (BOOL)chanceProc;
- (uint)consumeCharge;

@end
