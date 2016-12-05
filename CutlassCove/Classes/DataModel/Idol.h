//
//  Idol.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 1/11/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IDOL_KEY_COUNT 9

// 0-15 Gadgets
#define GADGET_SPELL_BRANDY_SLICK (1UL<<0)
#define GADGET_SPELL_TNT_BARRELS (1UL<<1)
#define GADGET_SPELL_NET (1UL<<2)
#define GADGET_SPELL_CAMOUFLAGE (1UL<<3)
#define GADGET_MASK (GADGET_SPELL_BRANDY_SLICK | GADGET_SPELL_TNT_BARRELS | GADGET_SPELL_NET | GADGET_SPELL_CAMOUFLAGE)

// 16-31 Voodoo
#define VOODOO_SPELL_WHIRLPOOL (1UL<<16)
#define VOODOO_SPELL_TEMPEST (1UL<<17)
#define VOODOO_SPELL_DEATH_FROM_DEEP (1UL<<18)
#define VOODOO_SPELL_FLYING_DUTCHMAN (1UL<<19)
#define VOODOO_SPELL_SEA_OF_LAVA (1UL<<20)
#define VOODOO_MASK (VOODOO_SPELL_WHIRLPOOL | VOODOO_SPELL_TEMPEST | VOODOO_SPELL_DEATH_FROM_DEEP | VOODOO_SPELL_FLYING_DUTCHMAN | VOODOO_SPELL_SEA_OF_LAVA)

// Voodoo Durations
#define VOODOO_DESPAWN_DURATION 3.0f

@interface Idol : NSObject <NSCoding> {
	uint mKey;
	int mRank;
}

@property (nonatomic,assign) uint key;
@property (nonatomic,assign) int rank;
@property (nonatomic,readonly) int nextRank;
@property (nonatomic,readonly) BOOL isMaxRank;
@property (nonatomic,readonly) NSString *keyAsString;

+ (Idol *)idolWithKey:(uint)key rank:(int)rank;
+ (Idol *)idolWithKey:(uint)key;
- (id)initWithIdolKey:(uint)key rank:(int)rank;
- (id)initWithIdolKey:(uint)key;

+ (BOOL)isMunition:(uint)key;
+ (BOOL)isSpell:(uint)key;
+ (NSArray *)voodooKeys;
+ (NSArray *)gadgetKeys;
+ (NSArray *)voodooKeysLite;
+ (NSArray *)gadgetKeysLite;
+ (NSArray *)voodooGadgetKeys;
+ (NSArray *)trinketList;
+ (NSArray *)gadgetList;
+ (Idol *)idolForKey:(uint)key inArray:(NSArray *)array;
+ (NSArray *)syncIdols:(NSArray *)syncIdols withIdols:(NSArray *)withIdols;
+ (double)durationForIdol:(Idol *)idol;
+ (float)infamyMultiplierForIdol:(Idol *)idol;
+ (double)cooldownDurationForIdol:(Idol *)idol;
+ (uint)countForIdol:(Idol *)idol;
+ (uint)priceForIdolUpgrade:(Idol *)idol;
+ (NSString *)priceStringForIdolUpgrade:(Idol *)idol;
+ (float)scaleForIdol:(Idol *)idol;
+ (NSString *)descForIdol:(Idol *)idol;
+ (NSString *)shopDescForIdol:(Idol *)idol;
+ (NSString *)nameForIdol:(Idol *)idol;
+ (NSString *)textureNameForKey:(uint)key;
+ (NSString *)iconTextureNameForKey:(uint)key;
+ (NSString *)logbookIconTextureNameForKey:(uint)key;

@end
