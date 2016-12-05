//
//  CannonDetails.m
//  Pirates
//
//  Created by Paul McPhee on 23/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "CannonDetails.h"
#import "GameController.h"

const float kMaxCannonDamageRating = 7.0f;

@implementation CannonDetails

@synthesize type = mType;
@synthesize price = mPrice;
@synthesize rangeRating = mRangeRating;
@synthesize damageRating = mDamageRating;
@synthesize bitmap = mBitmap;
@synthesize comboMax = mComboMax;
@synthesize ricochetBonus = mRicochetBonus;
@synthesize imbues = mImbues;
@synthesize reloadInterval = mReloadInterval;
@synthesize shotType = mShotType;
@synthesize textureNameBase = mTextureNameBase;
@synthesize textureNameBarrel = mTextureNameBarrel;
@synthesize textureNameWheel = mTextureNameWheel;
@synthesize textureNameMenu = mTextureNameMenu;
@synthesize textureNameFlash = mTextureNameFlash;
@synthesize deckSettings = mDeckSettings;
@dynamic bore;

- (id)initWithType:(NSString *)type {
	if (self = [super init]) {
		mType = [type retain];
		mPrice = 0;
		mRangeRating = 0;
		mDamageRating = 0;
		mBitmap = 0;
		mComboMax = 0;
		mRicochetBonus = 0;
		mImbues = 0;
		mReloadInterval = 1.25f;
		mShotType = nil;
		mTextureNameBase = nil;
		mTextureNameBarrel = nil;
		mTextureNameWheel = nil;
		mTextureNameMenu = nil;
		mTextureNameFlash = nil;
		mDeckSettings = nil;
	}
	return self;
}

- (int)rangeRating {
	return mRangeRating;
}

- (float)bore {
	return (2 * mDamageRating + 18) / (2 * kMaxCannonDamageRating + 18);  // Normalize at 32 to match reticle image dimensions
}

- (void)dealloc {
	[mType release]; mType = nil;
	[mShotType release]; mShotType = nil;
	[mTextureNameBase release]; mTextureNameBase = nil;
	[mTextureNameBarrel release]; mTextureNameBarrel = nil;
	[mTextureNameWheel release]; mTextureNameWheel = nil;
	[mTextureNameMenu release]; mTextureNameMenu = nil;
	[mTextureNameFlash release]; mTextureNameFlash = nil;
	[mDeckSettings release]; mDeckSettings = nil;
	[super dealloc];
}

@end
