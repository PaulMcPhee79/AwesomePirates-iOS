//
//  Potion.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 14/09/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "Potion.h"
#import "TextureManager.h"
#import "GameController.h"
#import "GuiHelper.h"

@interface Potion ()



@end


@implementation Potion

const uint kTwoPotionsRank = 10;
const uint kNumPotions = 8;
// POTION_POTENCY, POTION_LONGEVITY, POTION_RESURGENCE, POTION_NOTORIETY, POTION_BLOODLUST, POTION_MOBILITY, POTION_RICOCHET, POTION_SWIFTNESS
const uint kPotionUnlockRanks[kNumPotions] = { 2, 5, 8, 12, 15, 17, 20, 30 };

@synthesize isActive = mActive;
@synthesize key = mKey;
@synthesize rank = mRank;
@synthesize activationIndex = mActivationIndex;
@synthesize color = mColor;
@dynamic nextRank,isMaxRank,sortOrder,keyAsString,name;

static uint _activationIndex = 0;

+ (Potion *)potencyPotion {
	return [Potion potionWithKey:POTION_POTENCY];
}

+ (Potion *)longevityPotion {
	return [Potion potionWithKey:POTION_LONGEVITY];
}

+ (Potion *)resurgencePotion {
	return [Potion potionWithKey:POTION_RESURGENCE];
}

+ (Potion *)notorietyPotion {
	return [Potion potionWithKey:POTION_NOTORIETY];
}

+ (Potion *)bloodlustPotion {
	return [Potion potionWithKey:POTION_BLOODLUST];
}

+ (Potion *)mobilityPotion {
	return [Potion potionWithKey:POTION_MOBILITY];
}

+ (Potion *)ricochetPotion {
	return [Potion potionWithKey:POTION_RICOCHET];
}

+ (Potion *)swiftnessPotion {
    return [Potion potionWithKey:POTION_SWIFTNESS];
}

+ (Potion *)potionWithKey:(uint)key {
	return [[[Potion alloc] initWithKey:key] autorelease];
}

+ (Potion *)potionWithPotion:(Potion *)potion {
	Potion *newPotion = nil;
	
	if (potion) {
		newPotion = [Potion potionWithKey:potion.key];
		newPotion.rank = potion.rank;
	}
	return newPotion;
}

- (id)initWithKey:(uint)key {
	if (self = [super init]) {
        mActive = NO;
        mActivationIndex = 0;
        mKey = key;
		mRank = 1;
	}
	return self;
}

- (id)init {
	return [self initWithKey:POTION_POTENCY];
}

- (void)setIsActive:(BOOL)isActive {
    if (isActive)
        mActivationIndex = ++_activationIndex;
    mActive = isActive;
}

- (void)setRank:(int)value {
	mRank = MIN([Potion maxRankForKey:mKey], value);
}

- (int)nextRank {
	return MIN([Potion maxRankForKey:mKey], mRank+1);
}

- (BOOL)isMaxRank {
	return (mRank == [Potion maxRankForKey:mKey]);
}

- (int)sortOrder {
    return [Potion sortOrderForKey:mKey];
}

- (uint)color {
    return [Potion colorForKey:mKey];
}

- (NSString *)keyAsString {
	return [Potion keyAsString:mKey];
}

- (NSString *)name {
    return [Potion nameForKey:mKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
        mActive = [(NSNumber *)[decoder decodeObjectForKey:@"active"] boolValue];
        mActivationIndex = [(NSNumber *)[decoder decodeObjectForKey:@"activationIndex"] unsignedIntValue];
		mKey = [(NSNumber *)[decoder decodeObjectForKey:@"key"] unsignedIntValue];
		mRank = [(NSNumber *)[decoder decodeObjectForKey:@"rank"] intValue];
        
        if (mActivationIndex >= _activationIndex)
            _activationIndex = mActivationIndex + 1;
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:[NSNumber numberWithBool:mActive] forKey:@"active"];
    [coder encodeObject:[NSNumber numberWithUnsignedInt:mActivationIndex] forKey:@"activationIndex"];
    [coder encodeObject:[NSNumber numberWithUnsignedInt:mKey] forKey:@"key"];
	[coder encodeObject:[NSNumber numberWithInt:mRank] forKey:@"rank"];
}

// Places most recently activated potions at the front of the queue
- (NSComparisonResult)comparePotion:(Potion *)potion {
    if (self.activationIndex < potion.activationIndex)
        return NSOrderedDescending;
    else if (self.activationIndex > potion.activationIndex)
        return NSOrderedAscending;
    else
        return NSOrderedSame;
}

+ (NSString *)nameForKey:(uint)key {
    NSString *name = nil;
    
    switch (key) {
		case POTION_POTENCY: name = @"Potency"; break;
        case POTION_LONGEVITY: name = @"Longevity"; break;
		case POTION_RESURGENCE: name = @"Resurgence"; break;
        case POTION_NOTORIETY: name = @"Notoriety"; break;
        case POTION_BLOODLUST: name = @"Bloodlust"; break;
        case POTION_MOBILITY: name = @"Mobility"; break;
        case POTION_RICOCHET: name = @"Ricochet"; break;
        case POTION_SWIFTNESS: name = @"Swiftness"; break;
        default: break;
	}
    
    return name;
}

+ (NSString *)keyAsString:(uint)key {
    return [NSString stringWithFormat:@"%u", key];
}

+ (uint)maxRankForKey:(uint)key {
    return 1;
}

+ (uint)numPotions {
    return kNumPotions;
}

+ (BOOL)isPotionUnlockedAtRank:(uint)rank {
    BOOL unlocked = NO;
    
    for (uint i = 0; i < [Potion numPotions]; ++i) {
        if (rank == kPotionUnlockRanks[i]) {
            unlocked = YES;
            break;
        }
    }
    
    return unlocked;
}

+ (uint)minPotionRank {
    return kPotionUnlockRanks[0];
}

+ (uint)requiredRankForTwoPotions {
    return kTwoPotionsRank;
}

+ (uint)unlockedPotionKeyForRank:(uint)rank {
    uint key = 0;
    
    switch (rank) {
        case 2: key = POTION_POTENCY; break;
        case 5: key = POTION_LONGEVITY; break;
        case 8: key = POTION_RESURGENCE; break;
        case 12: key = POTION_NOTORIETY; break;
        case 15: key = POTION_BLOODLUST; break;
        case 17: key = POTION_MOBILITY; break;
        case 20: key = POTION_RICOCHET; break;
        case 30: key = POTION_SWIFTNESS; break;
        default: key = 0; break;
    }
    
    return key;
}

+ (NSArray *)potionKeys {
    return [NSArray arrayWithObjects:
            [NSNumber numberWithUnsignedInt:POTION_POTENCY],
            [NSNumber numberWithUnsignedInt:POTION_LONGEVITY],
            [NSNumber numberWithUnsignedInt:POTION_RESURGENCE],
            [NSNumber numberWithUnsignedInt:POTION_NOTORIETY],
            [NSNumber numberWithUnsignedInt:POTION_BLOODLUST],
            [NSNumber numberWithUnsignedInt:POTION_MOBILITY],
            [NSNumber numberWithUnsignedInt:POTION_RICOCHET],
            [NSNumber numberWithUnsignedInt:POTION_SWIFTNESS],
			nil];
}

+ (NSArray *)potionKeysForRank:(uint)rank {
    NSArray *allKeys = [Potion potionKeys];
    NSMutableArray *rankKeys = [NSMutableArray arrayWithCapacity:[Potion numPotions]];
    
    for (uint i = 0; i < [Potion numPotions]; ++i) {
        if (rank >= kPotionUnlockRanks[i]) {
            if (i < allKeys.count)
                [rankKeys addObject:[allKeys objectAtIndex:i]];
        }
    }
    
    return rankKeys;
}

+ (NSArray *)potionList {
	return [NSArray arrayWithObjects:
			[Potion potencyPotion],
            [Potion longevityPotion],
            [Potion resurgencePotion],
            [Potion notorietyPotion],
            [Potion bloodlustPotion],
            [Potion mobilityPotion],
            [Potion ricochetPotion],
            [Potion swiftnessPotion],
			nil];
}

+ (NSDictionary *)potionDictionary {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [Potion potencyPotion],[Potion keyAsString:POTION_POTENCY],
            [Potion longevityPotion],[Potion keyAsString:POTION_LONGEVITY],
            [Potion resurgencePotion],[Potion keyAsString:POTION_RESURGENCE],
            [Potion notorietyPotion],[Potion keyAsString:POTION_NOTORIETY],
            [Potion bloodlustPotion],[Potion keyAsString:POTION_BLOODLUST],
            [Potion mobilityPotion],[Potion keyAsString:POTION_MOBILITY],
            [Potion ricochetPotion], [Potion keyAsString:POTION_RICOCHET],
            [Potion swiftnessPotion], [Potion keyAsString:POTION_SWIFTNESS],
            nil];
}

+ (int)sortOrderForKey:(uint)key {
    int sortOrder = 0;
    
    switch (key) {
        case POTION_POTENCY: sortOrder = 0; break;
        case POTION_LONGEVITY: sortOrder = 1; break;
        case POTION_RESURGENCE: sortOrder = 2; break;
        case POTION_NOTORIETY: sortOrder = 3; break;
        case POTION_BLOODLUST: sortOrder = 4; break;
        case POTION_MOBILITY: sortOrder = 5; break;
        case POTION_RICOCHET: sortOrder = 6; break;
        case POTION_SWIFTNESS: sortOrder = 7; break;
        default: break;
	}
    
    return sortOrder;
}

+ (Potion *)potionForKey:(uint)key inArray:(NSArray *)array {
	Potion *foundIt = nil;
	
	for (Potion *potion in array) {
		if (potion.key == key) {
			foundIt = potion;
			break;
		}
	}
	
	return foundIt;
}

+ (uint)activePotionLimitForRank:(uint)rank {
    uint limit = 1;
    
    if (rank >= [Potion requiredRankForTwoPotions])
        limit = 2;
    return limit;
}

+ (uint)requiredRankForPotion:(Potion *)potion {
	uint rank = 0;
	
	switch (potion.key) {
        case POTION_POTENCY: rank = kPotionUnlockRanks[0]; break;
        case POTION_LONGEVITY: rank = kPotionUnlockRanks[1]; break;
        case POTION_RESURGENCE: rank = kPotionUnlockRanks[2]; break;
        case POTION_NOTORIETY: rank = kPotionUnlockRanks[3]; break;
        case POTION_BLOODLUST: rank = kPotionUnlockRanks[4]; break;
        case POTION_MOBILITY: rank = kPotionUnlockRanks[5]; break;
        case POTION_RICOCHET: rank = kPotionUnlockRanks[6]; break;
        case POTION_SWIFTNESS: rank = kPotionUnlockRanks[7]; break;
        default: break;
	}
	
	return rank;
}

+ (NSString *)requiredRankStringForPotion:(Potion *)potion {
    NSString *rankString = [NSString stringWithFormat:@"[Requires rank %u]", [Potion requiredRankForPotion:potion]];
    return rankString;
}

+ (NSString *)descForPotion:(Potion *)potion {
	NSString *desc = nil;
    
    switch (potion.key) {
        case POTION_POTENCY: desc = [NSString stringWithFormat:@"Increases the duration or quantity of spells and munitions."]; break;
        case POTION_LONGEVITY: desc = [NSString stringWithFormat:@"Increases the number of charges in pickups by 50%%."]; break;
        case POTION_RESURGENCE: desc = [NSString stringWithFormat:@"Red crosses are removed by sinking 7 ships instead of 10."]; break;
        case POTION_NOTORIETY: desc = [NSString stringWithFormat:@"Increases score gained from all sources by 20%%."]; break;
        case POTION_BLOODLUST: desc = [NSString stringWithFormat:@"Doubles the score gained from^shark attacks."]; break;
        case POTION_MOBILITY: desc = [NSString stringWithFormat:@"Getting shot only slows you for 1 second instead of 3."]; break;
        case POTION_RICOCHET: desc = [NSString stringWithFormat:@"Your ricochets receive double the normal score bonus for each hop."]; break;
        case POTION_SWIFTNESS: desc = [NSString stringWithFormat:@"The speedboat's engine has 10%% more power."]; break;
        default: break;
	}
	
	return desc;
}

+ (uint)colorForKey:(uint)key {
    uint color = 0xee2cee;
	
	switch (key) {
        case POTION_POTENCY: color = 0xee2cee; break;
        case POTION_LONGEVITY: color = 0x00ff00; break;
        case POTION_RESURGENCE: color = 0x126df5; break;
        case POTION_NOTORIETY: color = 0x00ffff; break;
        case POTION_BLOODLUST: color = 0xff100b; break;
        case POTION_MOBILITY: color = 0xdddddd; break;
        case POTION_RICOCHET: color = 0xffff00; break;
        case POTION_SWIFTNESS: color = 0xffa000; break;
        default: break;
	}
	
	return color;
}

+ (NSString *)soundNameForKey:(uint)key {
    return @"PotionRankup";
}

+ (NSArray *)syncPotions:(NSArray *)syncPotions withPotions:(NSArray *)withPotions {
    NSMutableArray *synced = [NSMutableArray arrayWithCapacity:syncPotions.count];
	
	for (Potion *syncPotion in syncPotions) {
		for (Potion *withPotion in withPotions) {
            if (syncPotion.key == withPotion.key) {
                syncPotion.rank = withPotion.rank;
				break;
            }
		}
		[synced addObject:syncPotion];
	}
	
	return synced;
}

+ (float)potencyCountFactorForPotion:(Potion *)potion {
    return ((potion.isActive) ? 1.5f : 1.0f);
}

+ (float)potencyDurationFactorForPotion:(Potion *)potion {
    return ((potion.isActive) ? 1.3f : 1.0f);
}

+ (uint)longevityBonusCountForPotion:(Potion *)potion {
    return ((potion.isActive) ? 10 : 0);
}

+ (float)resurgenceFactorForPotion:(Potion *)potion {
    return ((potion.isActive) ? 1.43f : 1.0f);
}

+ (float)notorietyFactorForPotion:(Potion *)potion {
    return ((potion.isActive) ? 1.2f : 1.0f);
}

+ (float)bloodlustFactorForPotion:(Potion *)potion {
    return ((potion.isActive) ? 2.0f : 1.0f);
}

+ (float)mobilityReductionDurationForPotion:(Potion *)potion {
    return ((potion.isActive) ? 2.0f : 0.0f);
}

+ (uint)ricochetBonusForPotion:(Potion *)potion {
    return ((potion.isActive) ? 500 : 250);
}

+ (float)swiftnessFactorForPotion:(Potion *)potion {
    return ((potion.isActive) ? 1.1f : 1.0f);
}

@end
