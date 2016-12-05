//
//  Potion.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 14/09/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>

// Valerie Potions
#define POTION_POTENCY (1UL<<0)
#define POTION_LONGEVITY (1UL<<1)
#define POTION_RESURGENCE (1UL<<2)
#define POTION_NOTORIETY (1UL<<3)
#define POTION_BLOODLUST (1UL<<4)
#define POTION_MOBILITY (1UL<<5)
#define POTION_RICOCHET (1UL<<6)
#define POTION_SWIFTNESS (1UL<<7)

@class TextureManager;

@interface Potion : NSObject <NSCoding> {
    BOOL mActive;
    uint mActivationIndex;
	uint mKey;
	int mRank;
}

@property (nonatomic,assign) BOOL isActive;
@property (nonatomic,assign) uint key;
@property (nonatomic,assign) int rank;
@property (nonatomic,readonly) uint activationIndex;
@property (nonatomic,readonly) int nextRank;
@property (nonatomic,readonly) BOOL isMaxRank;
@property (nonatomic,readonly) int sortOrder;
@property (nonatomic,readonly) uint color;
@property (nonatomic,readonly) NSString *keyAsString;
@property (nonatomic,readonly) NSString *name;


- (id)initWithKey:(uint)key;
- (NSComparisonResult)comparePotion:(Potion *)potion;

+ (Potion *)potencyPotion;
+ (Potion *)longevityPotion;
+ (Potion *)resurgencePotion;
+ (Potion *)notorietyPotion;
+ (Potion *)bloodlustPotion;
+ (Potion *)mobilityPotion;
+ (Potion *)ricochetPotion;
+ (Potion *)swiftnessPotion;
+ (Potion *)potionWithKey:(uint)key;
+ (Potion *)potionWithPotion:(Potion *)potion;

+ (NSString *)nameForKey:(uint)key;
+ (NSString *)keyAsString:(uint)key;
+ (uint)maxRankForKey:(uint)key;
+ (uint)numPotions;
+ (BOOL)isPotionUnlockedAtRank:(uint)rank;
+ (uint)minPotionRank;
+ (uint)requiredRankForTwoPotions;
+ (uint)unlockedPotionKeyForRank:(uint)rank;
+ (NSArray *)potionKeys;
+ (NSArray *)potionKeysForRank:(uint)rank;
+ (NSArray *)potionList;
+ (NSDictionary *)potionDictionary;
+ (int)sortOrderForKey:(uint)key;
+ (Potion *)potionForKey:(uint)key inArray:(NSArray *)array;
+ (uint)activePotionLimitForRank:(uint)rank;
+ (uint)requiredRankForPotion:(Potion *)potion;
+ (NSString *)requiredRankStringForPotion:(Potion *)potion;
+ (NSString *)descForPotion:(Potion *)potion;
+ (uint)colorForKey:(uint)key;
+ (NSString *)soundNameForKey:(uint)key;
+ (NSArray *)syncPotions:(NSArray *)syncPotions withPotions:(NSArray *)withPotions;

+ (float)potencyCountFactorForPotion:(Potion *)potion;
+ (float)potencyDurationFactorForPotion:(Potion *)potion;
+ (uint)longevityBonusCountForPotion:(Potion *)potion;
+ (float)resurgenceFactorForPotion:(Potion *)potion;
+ (float)notorietyFactorForPotion:(Potion *)potion;
+ (float)bloodlustFactorForPotion:(Potion *)potion;
+ (float)mobilityReductionDurationForPotion:(Potion *)potion;
+ (uint)ricochetBonusForPotion:(Potion *)potion;
+ (float)swiftnessFactorForPotion:(Potion *)potion;

@end
