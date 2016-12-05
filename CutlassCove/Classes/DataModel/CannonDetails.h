//
//  CannonDetails.h
//  Pirates
//
//  Created by Paul McPhee on 23/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ShipActor;

@interface CannonDetails : NSObject {
	NSString *mType;
	int mPrice;
	int mRangeRating;
	int mDamageRating;
	uint mBitmap;
	int mComboMax;
	int mRicochetBonus;
	uint mImbues;
	float mReloadInterval;
	NSString *mShotType;
	NSString *mTextureNameBase;
	NSString *mTextureNameBarrel;
	NSString *mTextureNameWheel;
	NSString *mTextureNameMenu;
	NSString *mTextureNameFlash;
	NSDictionary *mDeckSettings;
}

@property (nonatomic,readonly) NSString *type;
@property (nonatomic,assign) int price;
@property (nonatomic,assign) int rangeRating;
@property (nonatomic,assign) int damageRating;
@property (nonatomic,readonly) float bore;
@property (nonatomic,assign) uint bitmap;
@property (nonatomic,assign) int comboMax;
@property (nonatomic,assign) int ricochetBonus;
@property (nonatomic,assign) uint imbues;
@property (nonatomic,assign) float reloadInterval;
@property (nonatomic,copy) NSString *shotType;
@property (nonatomic,copy) NSString *textureNameBase;
@property (nonatomic,copy) NSString *textureNameBarrel;
@property (nonatomic,copy) NSString *textureNameWheel;
@property (nonatomic,copy) NSString *textureNameMenu;
@property (nonatomic,copy) NSString *textureNameFlash;
@property (nonatomic,retain) NSDictionary *deckSettings;

- (id)initWithType:(NSString *)type;

@end
