//
//  AshProc.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 27/05/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "AshProc.h"
#import "GameController.h"
#import "Globals.h"

@implementation AshProc

@synthesize proc = mProc;
@synthesize chargesRemaining = mChargesRemaining;
@synthesize totalCharges = mTotalCharges;
@synthesize requirementCount = mRequirementCount;
@synthesize requirementCeiling = mRequirementCeiling;
@synthesize addition = mAddition;
@synthesize ricochetAddition = mRicochetAddition;
@synthesize multiplier = mMultiplier;
@synthesize ricochetMultiplier = mRicochetMultiplier;
@synthesize deactivatesOnMiss = mDeactivatesOnMiss;
@synthesize chanceToProc = mChanceToProc;
@synthesize specialChanceToProc = mSpecialChanceToProc;
@synthesize specialProcEventKey = mSpecialProcEventKey;
@synthesize texturePrefix = mTexturePrefix;
@synthesize soundName = mSoundName;

+ (AshProc *)ashProc {
	return [[[AshProc alloc] init] autorelease];
}

- (id)init {
	if (self = [super init]) {
		mSpecialProcEventKey = nil;
		mTexturePrefix = [[NSString alloc] initWithFormat:@"single-shot_"];
		mSoundName = nil;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		mProc = [(NSNumber *)[decoder decodeObjectForKey:@"proc"] unsignedIntValue];
		mChargesRemaining = [(NSNumber *)[decoder decodeObjectForKey:@"chargesRemaining"] unsignedIntValue];
		mTotalCharges = [(NSNumber *)[decoder decodeObjectForKey:@"totalCharges"] unsignedIntValue];
		mRequirementCount = [(NSNumber *)[decoder decodeObjectForKey:@"requirementCount"] unsignedIntValue];
		mRequirementCeiling = [(NSNumber *)[decoder decodeObjectForKey:@"requirementCeiling"] unsignedIntValue];
		mAddition = [(NSNumber *)[decoder decodeObjectForKey:@"addition"] unsignedIntValue];
		mRicochetAddition = [(NSNumber *)[decoder decodeObjectForKey:@"ricochetAddition"] unsignedIntValue];
		mMultiplier = [(NSNumber *)[decoder decodeObjectForKey:@"multiplier"] unsignedIntValue];
		mRicochetMultiplier = [(NSNumber *)[decoder decodeObjectForKey:@"ricochetMultiplier"] floatValue];
		mDeactivatesOnMiss = [(NSNumber *)[decoder decodeObjectForKey:@"deactivatesOnMiss"] boolValue];
		mChanceToProc = [(NSNumber *)[decoder decodeObjectForKey:@"chanceToProc"] floatValue];
		mSpecialChanceToProc = [(NSNumber *)[decoder decodeObjectForKey:@"specialChanceToProc"] floatValue];
		mSpecialProcEventKey = [(NSString *)[decoder decodeObjectForKey:@"specialProcEventKey"] copy];
		mTexturePrefix = [(NSString *)[decoder decodeObjectForKey:@"texturePrefix"] copy];
		mSoundName = [(NSString *)[decoder decodeObjectForKey:@"soundName"] copy];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:[NSNumber numberWithUnsignedInt:mProc] forKey:@"proc"];
	[coder encodeObject:[NSNumber numberWithUnsignedInt:mChargesRemaining] forKey:@"chargesRemaining"];
	[coder encodeObject:[NSNumber numberWithUnsignedInt:mTotalCharges] forKey:@"totalCharges"];
	[coder encodeObject:[NSNumber numberWithUnsignedInt:mRequirementCount] forKey:@"requirementCount"];
	[coder encodeObject:[NSNumber numberWithUnsignedInt:mRequirementCeiling] forKey:@"requirementCeiling"];
	[coder encodeObject:[NSNumber numberWithUnsignedInt:mAddition] forKey:@"addition"];
	[coder encodeObject:[NSNumber numberWithUnsignedInt:mRicochetAddition] forKey:@"ricochetAddition"];
	[coder encodeObject:[NSNumber numberWithUnsignedInt:mMultiplier] forKey:@"multiplier"];
	[coder encodeObject:[NSNumber numberWithFloat:mRicochetMultiplier] forKey:@"ricochetMultiplier"];
	[coder encodeObject:[NSNumber numberWithBool:mDeactivatesOnMiss] forKey:@"deactivatesOnMiss"];
	[coder encodeObject:[NSNumber numberWithFloat:mChanceToProc] forKey:@"chanceToProc"];
	[coder encodeObject:[NSNumber numberWithFloat:mSpecialChanceToProc] forKey:@"specialProcEventKey"];
	[coder encodeObject:mSpecialProcEventKey forKey:@"texturePrefix"];
	[coder encodeObject:mTexturePrefix forKey:@"texturePrefix"];
	[coder encodeObject:mSoundName forKey:@"soundName"];
}

- (BOOL)isActive {
	return (mChargesRemaining > 0);
}

- (void)setChargesRemaining:(uint)chargesRemaining {
    mChargesRemaining = MIN(chargesRemaining,mTotalCharges);
}

- (void)setRequirementCount:(uint)value {
	mRequirementCount = value;
	
	if (mRequirementCeiling > 0 && mRequirementCount >= mRequirementCeiling) {
		mRequirementCount = 0;
		
		if ([self isActive] == NO)
			mChargesRemaining = mTotalCharges;
	}
}

- (void)deactivate {
	mChargesRemaining = 0;
	mRequirementCount = 0;
}

- (BOOL)chanceProc {
	if (mChargesRemaining > 0)
		return YES;
	int randInt = RANDOM_INT(0,1000);
	float chance = randInt / 1000.0f;
	
	if (chance < mChanceToProc)
		mChargesRemaining = mTotalCharges;
	return (mChargesRemaining > 0);
}

- (uint)consumeCharge {
	if (mChargesRemaining > 0)
		--mChargesRemaining;
	return mChargesRemaining;
}

- (void)dealloc {
	[mSpecialProcEventKey release]; mSpecialProcEventKey = nil;
	[mTexturePrefix release]; mTexturePrefix = nil;
	[mSoundName release]; mSoundName = nil;
	[super dealloc];
}

@end
