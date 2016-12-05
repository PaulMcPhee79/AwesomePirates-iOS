//
//  Ash.h
//  Cutlass Cove
//
//  Created by Paul McPhee on 29/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AshProc.h"

#define ASH_KEY_COUNT 6

// Non-procable
#define ASH_DEFAULT (1UL<<0)
#define ASH_DUTCHMAN_SHOT (1UL<<1)

// Procable (pickups)
#define ASH_NOXIOUS (1UL<<2)
#define ASH_MOLTEN (1UL<<3)
#define ASH_SAVAGE (1UL<<4)
#define ASH_ABYSSAL (1UL<<5)

@interface Ash : NSObject <NSCoding> {
    uint mKey;
	int mRank;
}

@property (nonatomic,assign) uint key;
@property (nonatomic,assign) int rank;
@property (nonatomic,readonly) int nextRank;
@property (nonatomic,readonly) BOOL isMaxRank;
@property (nonatomic,readonly) int sortOrder;
@property (nonatomic,readonly) NSString *keyAsString;

+ (Ash *)ashWithKey:(uint)key rank:(int)rank;
+ (Ash *)ashWithKey:(uint)key;
- (id)initWithAshKey:(uint)key rank:(int)rank;
- (id)initWithAshKey:(uint)key;

+ (uint)numProcableAshes;
+ (NSString *)keyAsString:(uint)key;
+ (uint)maxRankForKey:(uint)key;
+ (AshProc *)ashProcForAsh:(Ash *)ash;
+ (NSArray *)ashKeys;
+ (NSArray *)procableAshKeys;
+ (NSArray *)ricochetSafeAshKeys;
+ (NSArray *)ashShopKeys;
+ (NSArray *)ashList;
+ (NSArray *)procableAshList;
+ (int)sortOrderForKey:(uint)key;
+ (Ash *)ashForKey:(uint)key inArray:(NSArray *)array;
+ (uint)totalChargesForAsh:(Ash *)ash;
+ (uint)priceForAshUpgrade:(Ash *)ash;
+ (NSString *)priceStringForAshUpgrade:(Ash *)ash;
+ (NSString *)descForAsh:(Ash *)ash;
+ (NSString *)shopDescForAsh:(Ash *)ash;
+ (NSString *)nameForAsh:(Ash *)ash;
+ (uint)colorForAsh:(Ash *)ash;
+ (NSString *)hintForKey:(uint)key;
+ (NSString *)gameSettingForKey:(uint)key;
+ (NSString *)soundNameForKey:(uint)key;
+ (NSString *)iconTextureNameForKey:(uint)key;
+ (NSString *)texturePrefixForKey:(uint)key;
+ (NSArray *)allTexturePrefixes;
+ (uint)infamyFactorForAsh:(Ash *)ash;

@end
