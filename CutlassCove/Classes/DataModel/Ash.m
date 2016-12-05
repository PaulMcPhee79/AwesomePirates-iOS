//
//  Ash.m
//  Cutlass Cove
//
//  Created by Paul McPhee on 29/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Ash.h"
#import "GuiHelper.h"
#import "Idol.h"
#import "GameStats.h"
#import "GameSettings.h"
#import "GameController.h"

@implementation Ash

@synthesize key = mKey;
@synthesize rank = mRank;
@dynamic nextRank,isMaxRank,sortOrder,keyAsString;

+ (Ash *)ashWithKey:(uint)key rank:(int)rank {
	return [[[Ash alloc] initWithAshKey:key rank:rank] autorelease];
}

+ (Ash *)ashWithKey:(uint)key {
	return [Ash ashWithKey:key rank:1];
}

- (id)initWithAshKey:(uint)key rank:(int)rank {
	if (self = [super init]) {
		mKey = key;
		mRank = rank;
	}
	return self;
}

- (id)initWithAshKey:(uint)key {
	return [self initWithAshKey:key rank:1];
}

- (void)setRank:(int)value {
	mRank = MIN([Ash maxRankForKey:mKey], value);
}

- (int)nextRank {
	return MIN([Ash maxRankForKey:mKey], mRank+1);
}

- (BOOL)isMaxRank {
	return (mRank == [Ash maxRankForKey:mKey]);
}

- (int)sortOrder {
    return [Ash sortOrderForKey:mKey];
}

- (NSString *)keyAsString {
	return [Ash keyAsString:mKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		mKey = [(NSNumber *)[decoder decodeObjectForKey:@"key"] unsignedIntValue];
		mRank = [(NSNumber *)[decoder decodeObjectForKey:@"rank"] intValue];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:[NSNumber numberWithUnsignedInt:mKey] forKey:@"key"];
	[coder encodeObject:[NSNumber numberWithInt:mRank] forKey:@"rank"];
}

+ (NSString *)keyAsString:(uint)key {
    return [NSString stringWithFormat:@"%u", key];
}

+ (uint)maxRankForKey:(uint)key {
    return 1;
}

+ (uint)numProcableAshes {
    return ASH_KEY_COUNT-1;
}

+ (AshProc *)ashProcForAsh:(Ash *)ash {
    AshProc *ashProc = [[[AshProc alloc] init] autorelease];
    
    ashProc.proc = ash.key;
    ashProc.chanceToProc = 0;
	ashProc.specialChanceToProc = 0;
	ashProc.specialProcEventKey = nil;
	ashProc.chargesRemaining = ashProc.totalCharges = [Ash totalChargesForAsh:ash] + [Potion longevityBonusCountForPotion:[GCTRL.gameStats potionForKey:POTION_LONGEVITY]];
	ashProc.requirementCount = 0;
	ashProc.requirementCeiling = 0;
	ashProc.addition = 0;
	ashProc.multiplier = [Ash infamyFactorForAsh:ash];
	ashProc.ricochetAddition = 0;
	ashProc.ricochetMultiplier = 1;
	ashProc.deactivatesOnMiss = NO;
    ashProc.soundName = nil;
    ashProc.texturePrefix = [Ash texturePrefixForKey:ash.key];
    
    return ashProc;
}

+ (NSArray *)ashKeys {
    return [NSArray arrayWithObjects:
			[NSNumber numberWithUnsignedInt:ASH_DEFAULT],
			[NSNumber numberWithUnsignedInt:ASH_NOXIOUS],
			[NSNumber numberWithUnsignedInt:ASH_MOLTEN],
			[NSNumber numberWithUnsignedInt:ASH_SAVAGE],
            [NSNumber numberWithUnsignedInt:ASH_ABYSSAL],
			nil];
}

+ (NSArray *)procableAshKeys {
    return [NSArray arrayWithObjects:
			[NSNumber numberWithUnsignedInt:ASH_NOXIOUS],
			[NSNumber numberWithUnsignedInt:ASH_MOLTEN],
			[NSNumber numberWithUnsignedInt:ASH_SAVAGE],
            [NSNumber numberWithUnsignedInt:ASH_ABYSSAL],
			nil];
}

// Safe for OF challenges that need to test for ricochets.
+ (NSArray *)ricochetSafeAshKeys {
    return [NSArray arrayWithObjects:
			[NSNumber numberWithUnsignedInt:ASH_NOXIOUS],
			[NSNumber numberWithUnsignedInt:ASH_SAVAGE],
			nil];
}

+ (NSArray *)ashShopKeys {
    return [NSArray arrayWithObjects:
			[NSNumber numberWithUnsignedInt:ASH_NOXIOUS],
			[NSNumber numberWithUnsignedInt:ASH_MOLTEN],
			[NSNumber numberWithUnsignedInt:ASH_SAVAGE],
            [NSNumber numberWithUnsignedInt:ASH_ABYSSAL],
			nil];
}

+ (NSArray *)ashList {
    return [NSArray arrayWithObjects:
			[Ash ashWithKey:ASH_DEFAULT],
			[Ash ashWithKey:ASH_NOXIOUS],
			[Ash ashWithKey:ASH_MOLTEN],
			[Ash ashWithKey:ASH_SAVAGE],
            [Ash ashWithKey:ASH_ABYSSAL],
			nil];
}

+ (NSArray *)procableAshList {
    return [NSArray arrayWithObjects:
			[Ash ashWithKey:ASH_NOXIOUS],
			[Ash ashWithKey:ASH_MOLTEN],
			[Ash ashWithKey:ASH_SAVAGE],
            [Ash ashWithKey:ASH_ABYSSAL],
			nil];
}

+ (Ash *)ashForKey:(uint)key inArray:(NSArray *)array {
    Ash *foundIt = nil;
	
	for (Ash *ash in array) {
		if (ash.key == key) {
			foundIt = ash;
			break;
		}
	}
	
	return foundIt;
}

+ (uint)totalChargesForAsh:(Ash *)ash {
    uint totalCharges = 20UL;
    
    if (ash.key == ASH_DUTCHMAN_SHOT)
        assert(0); // Don't use this ash directly
    return totalCharges;
}

+ (int)sortOrderForKey:(uint)key {
    int sortOrder = 0;
    
    switch (key) {
        case ASH_DEFAULT: sortOrder = 0; break;
		case ASH_NOXIOUS: sortOrder = 1; break;
		case ASH_MOLTEN: sortOrder = 2; break;
		case ASH_SAVAGE: sortOrder = 3; break;
        case ASH_ABYSSAL: sortOrder = 4; break;
        default: break;
	}
    
    return sortOrder;
}

+ (uint)priceForAshUpgrade:(Ash *)ash {
    assert(ash);
	uint price = 0;
	
	switch (ash.key) {
		case ASH_DEFAULT:
			price = 0;
			break;
		case ASH_NOXIOUS:
			switch (ash.rank) {
				case 1: price = 7500; break;
				case 2: price = 28000; break;
				case 3: price = 97500; break;
				default: assert(0); break;
			}
			break;
		case ASH_MOLTEN:
			switch (ash.rank) {
				case 1: price = 7500; break;
				case 2: price = 28000; break;
				case 3: price = 97500; break;
				default: assert(0); break;
			}
			break;
		case ASH_SAVAGE:
			switch (ash.rank) {
				case 1: price = 7500; break;
				case 2: price = 28000; break;
				case 3: price = 97500; break;
				default: assert(0); break;
			}
			break;
        case ASH_ABYSSAL:
			switch (ash.rank) {
				case 1: price = 7500; break;
				case 2: price = 28000; break;
				case 3: price = 97500; break;
				default: assert(0); break;
			}
			break;
		default:
			assert(0);
			break;
	}
	
	return price;
}

+ (NSString *)priceStringForAshUpgrade:(Ash *)ash {
    uint price = [Ash priceForAshUpgrade:ash];
    return [GuiHelper commaSeparatedValue:price];
}

+ (NSString *)descForAsh:(Ash *)ash {
    if (ash == nil)
		return nil;
	
	NSString *desc = nil;
    uint infamyFactor = [Ash infamyFactorForAsh:ash];
    
    switch (ash.key) {
        case ASH_DEFAULT:
            desc = [NSString stringWithFormat:@"%ux score from shooting ships.", infamyFactor];
            break;
		case ASH_NOXIOUS:
            desc = [NSString stringWithFormat:@"%ux score from shooting ships.", infamyFactor];
			break;
		case ASH_MOLTEN:
            desc = [NSString stringWithFormat:@"%ux score from shooting ships.", infamyFactor];
			break;
		case ASH_SAVAGE:
            desc = [NSString stringWithFormat:@"%ux score from shooting ships.", infamyFactor];
			break;
        case ASH_ABYSSAL:
            desc = [NSString stringWithFormat:@"%ux score from shooting ships.", infamyFactor];
			break;
        default:
            assert(0);
            break;
	}
    
    return desc;
}

+ (NSString *)shopDescForAsh:(Ash *)ash {
    if (ash == nil)
		return nil;
	
	NSString *desc = nil;
    NSString *price = [self priceStringForAshUpgrade:ash];
    uint infamyFactor = [Ash infamyFactorForAsh:ash];
    
    switch (ash.key) {
        case ASH_DEFAULT:
            desc = [NSString stringWithFormat:@"%ux score from shooting ships. All yours for %@ doubloons.", infamyFactor, price];
            break;
		case ASH_NOXIOUS:
            desc = [NSString stringWithFormat:@"%ux score from shooting ships. All yours for %@ doubloons.", infamyFactor, price];
			break;
		case ASH_MOLTEN:
            desc = [NSString stringWithFormat:@"%ux score from shooting ships. All yours for %@ doubloons.", infamyFactor, price];
			break;
		case ASH_SAVAGE:
            desc = [NSString stringWithFormat:@"%ux score from shooting ships. All yours for %@ doubloons.", infamyFactor, price];
			break;
        case ASH_ABYSSAL:
            desc = [NSString stringWithFormat:@"%ux score from shooting ships. All yours for %@ doubloons.", infamyFactor, price];
			break;
        default:
            assert(0);
            break;
	}
    
    return desc;
}

+ (NSString *)nameForAsh:(Ash *)ash {
    if (ash == nil)
		return nil;
	
	NSString *desc = nil;
	
	switch (ash.key) {
		case ASH_DEFAULT: desc = @"Gunpowder"; break;
		case ASH_NOXIOUS: desc = @"Caustic Gunpowder"; break;
		case ASH_MOLTEN: desc = @"Scorched Gunpowder"; break;
		case ASH_SAVAGE: desc = @"Savage Gunpowder"; break;
        case ASH_ABYSSAL: desc = @"Abyssal Gunpowder"; break;
		default: break;
	}
	
	if (desc)
		desc = [NSString stringWithFormat:@"%@ %@", desc, [GuiHelper romanNumeralsForDecimalValueToX:ash.rank]];
	return desc;
}

+ (uint)colorForAsh:(Ash *)ash {
    uint color = 0x808080;
    
    switch (ash.key) {
		case ASH_DEFAULT: color = 0x808080; break;
		case ASH_NOXIOUS: color = 0x05fc00 - ash.rank * 0x002000; break;
		case ASH_MOLTEN: color = 0xff8000 - ash.rank * 0x140a00; break;
		case ASH_SAVAGE: color = 0xff0000 - ash.rank * 0x200000; break;
        case ASH_ABYSSAL: color = 0xff0000 - ash.rank * 0x300000; break;
		default: break;
	}
    
    return color;
}

+ (NSString *)hintForKey:(uint)key {
    NSString *hint = nil;
    
    switch (key) {
		case ASH_NOXIOUS:
			hint = @"Venom Shot";
			break;
		case ASH_MOLTEN:
			hint = @"Molten Shot";
			break;
		case ASH_SAVAGE:
			hint = @"Crimson Shot";
			break;
        case ASH_ABYSSAL:
			hint = @"Abyssal Shot";
			break;
        case ASH_DUTCHMAN_SHOT:
        case ASH_DEFAULT:
        default:
            hint = nil;
            break;
	}
    
    return hint;
}

+ (NSString *)gameSettingForKey:(uint)key {
    NSString *settingKey = nil;
    
    switch (key) {
		case ASH_NOXIOUS:
			settingKey = GAME_SETTINGS_KEY_PICKUP_VENOM_TIPS;
			break;
		case ASH_MOLTEN:
			settingKey = GAME_SETTINGS_KEY_PICKUP_MOLTEN_TIPS;
			break;
		case ASH_SAVAGE:
			settingKey = GAME_SETTINGS_KEY_PICKUP_CRIMSON_TIPS;
			break;
        case ASH_ABYSSAL:
			settingKey = GAME_SETTINGS_KEY_PICKUP_ABYSSAL_TIPS;
			break;
        case ASH_DUTCHMAN_SHOT:
        case ASH_DEFAULT:
        default:
            settingKey = nil;
            break;
	}
    
    return settingKey;
}

+ (NSString *)soundNameForKey:(uint)key {
    NSString *texturePrefix = nil;
    
    switch (key) {
		case ASH_NOXIOUS:
			texturePrefix = @"AshNoxious";
			break;
		case ASH_MOLTEN:
			texturePrefix = @"AshMolten";
			break;
		case ASH_SAVAGE:
			texturePrefix = @"AshSavage";
			break;
        case ASH_ABYSSAL:
			texturePrefix = @"AshAbyssal";
			break;
        case ASH_DUTCHMAN_SHOT:
        case ASH_DEFAULT:
        default:
            texturePrefix = nil;
            break;
	}
    
    return texturePrefix;
}

+ (NSString *)iconTextureNameForKey:(uint)key {
    return @"ash";
}

+ (NSString *)texturePrefixForKey:(uint)key {
    NSString *texturePrefix = nil;
    
    switch (key) {
        case ASH_DUTCHMAN_SHOT:
            texturePrefix = @"dutchman-shot_";
            break;
		case ASH_NOXIOUS:
			texturePrefix = @"venom-shot_";
			break;
		case ASH_MOLTEN:
			texturePrefix = @"magma-shot_";
			break;
		case ASH_SAVAGE:
			texturePrefix = @"crimson-shot_";
			break;
        case ASH_ABYSSAL:
			texturePrefix = @"abyssal-shot_";
			break;
        case ASH_DEFAULT:
        default:
            texturePrefix = @"single-shot_";
            break;
	}
    
    return texturePrefix;
}

+ (NSArray *)allTexturePrefixes {
    return [NSArray arrayWithObjects:@"single-shot_", @"dutchman-shot_", @"venom-shot_", @"magma-shot_", @"crimson-shot_", @"abyssal-shot_", nil];
}

+ (uint)infamyFactorForAsh:(Ash *)ash {
    uint factor = 1;
    return factor;
}

@end
