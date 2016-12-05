//
//  Idol.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 1/11/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "Idol.h"
#import "TimeKeeper.h"
#import "GuiHelper.h"
#import "GameStats.h"
#import "GameController.h"


const int kMaxIdolRank = 3;


@implementation Idol

@synthesize key = mKey;
@synthesize rank = mRank;
@dynamic nextRank,isMaxRank,keyAsString;

+ (Idol *)idolWithKey:(uint)key rank:(int)rank {
	return [[[Idol alloc] initWithIdolKey:key rank:rank] autorelease];
}

+ (Idol *)idolWithKey:(uint)key {
	return [Idol idolWithKey:key rank:1];
}

- (id)initWithIdolKey:(uint)key rank:(int)rank {
	if (self = [super init]) {
		mKey = key;
		mRank = kMaxIdolRank; // Force it to max rank (now that Swindlers Alley is gone)
	}
	return self;
}

- (id)initWithIdolKey:(uint)key {
	return [self initWithIdolKey:key rank:1];
}

- (void)setRank:(int)value {
	mRank = MIN(kMaxIdolRank, value);
}

- (int)nextRank {
	return MIN(kMaxIdolRank, mRank+1);
}

- (BOOL)isMaxRank {
	return (mRank == kMaxIdolRank);
}

- (NSString *)keyAsString {
	return [NSString stringWithFormat:@"%u", mKey];
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

+ (BOOL)isMunition:(uint)key {
    return ((key & GADGET_MASK) == key);
}

+ (BOOL)isSpell:(uint)key {
    return ((key & VOODOO_MASK) == key);
}

+ (NSArray *)voodooKeys {
	return [NSArray arrayWithObjects:
			[NSNumber numberWithUnsignedInt:VOODOO_SPELL_WHIRLPOOL],
			[NSNumber numberWithUnsignedInt:VOODOO_SPELL_TEMPEST],
			[NSNumber numberWithUnsignedInt:VOODOO_SPELL_DEATH_FROM_DEEP],
			[NSNumber numberWithUnsignedInt:VOODOO_SPELL_FLYING_DUTCHMAN],
            [NSNumber numberWithUnsignedInt:VOODOO_SPELL_SEA_OF_LAVA],
			nil];
}

+ (NSArray *)gadgetKeys {
	return [NSArray arrayWithObjects:
			[NSNumber numberWithUnsignedInt:GADGET_SPELL_BRANDY_SLICK],
			[NSNumber numberWithUnsignedInt:GADGET_SPELL_TNT_BARRELS],
			[NSNumber numberWithUnsignedInt:GADGET_SPELL_NET],
			[NSNumber numberWithUnsignedInt:GADGET_SPELL_CAMOUFLAGE],
			nil];
}

+ (NSArray *)voodooKeysLite {
    return [NSArray arrayWithObjects:
			[NSNumber numberWithUnsignedInt:VOODOO_SPELL_WHIRLPOOL],
			[NSNumber numberWithUnsignedInt:VOODOO_SPELL_TEMPEST],
			nil];
}

+ (NSArray *)gadgetKeysLite {
    return [NSArray arrayWithObjects:
			[NSNumber numberWithUnsignedInt:GADGET_SPELL_TNT_BARRELS],
			[NSNumber numberWithUnsignedInt:GADGET_SPELL_NET],
			nil];
}

+ (NSArray *)voodooGadgetKeys {
	NSMutableArray *array = [NSMutableArray arrayWithArray:[Idol voodooKeys]];
	[array addObjectsFromArray:[Idol gadgetKeys]];
	return array;
}

+ (NSArray *)trinketList {
	return [NSArray arrayWithObjects:
			[Idol idolWithKey:VOODOO_SPELL_WHIRLPOOL],
			[Idol idolWithKey:VOODOO_SPELL_TEMPEST],
			[Idol idolWithKey:VOODOO_SPELL_DEATH_FROM_DEEP],
			[Idol idolWithKey:VOODOO_SPELL_FLYING_DUTCHMAN],
            [Idol idolWithKey:VOODOO_SPELL_SEA_OF_LAVA],
			nil];
}

+ (NSArray *)gadgetList {
	return [NSArray arrayWithObjects:
			[Idol idolWithKey:GADGET_SPELL_BRANDY_SLICK],
			[Idol idolWithKey:GADGET_SPELL_TNT_BARRELS],
			[Idol idolWithKey:GADGET_SPELL_NET],
			[Idol idolWithKey:GADGET_SPELL_CAMOUFLAGE],
			nil];
}

+ (Idol *)idolForKey:(uint)key inArray:(NSArray *)array {
	Idol *foundIt = nil;
	
	for (Idol *idol in array) {
		if (idol.key == key) {
			foundIt = idol;
			break;
		}
	}
	
	return foundIt;
}

+ (NSArray *)syncIdols:(NSArray *)syncIdols withIdols:(NSArray *)withIdols {
	NSMutableArray *synced = [NSMutableArray arrayWithCapacity:syncIdols.count];
	
	for (Idol *syncIdol in syncIdols) {
		syncIdol.rank = 0;
		
		for (Idol *withIdol in withIdols) {
			if (syncIdol.key == withIdol.key) {
				syncIdol.rank = withIdol.rank;
				break;
			}
		}
		[synced addObject:syncIdol];
	}
	
	return synced;
}

+ (double)durationForIdol:(Idol *)idol {
	assert(idol);
	double duration = 0;
    BOOL potencyActive = [GCTRL.gameStats potionForKey:POTION_POTENCY].isActive;
	
	switch (idol.key) {
		case GADGET_SPELL_BRANDY_SLICK:
				switch (idol.rank) {
					case 1: duration = 20.0f; break;
					case 2: duration = 30.0f; break;
					case 3: duration = 40.0f; break;
					default: assert(0); break;
				}
            
            if (potencyActive)
                duration += 30.0f;
			break;
		case GADGET_SPELL_TNT_BARRELS:
			break;
		case GADGET_SPELL_NET:
			switch (idol.rank) {
                case 1: duration = 20.0f; break;
                case 2: duration = 30.0f; break;
                case 3: duration = 40.0f; break;
                default: assert(0); break;
            }
            
            if (potencyActive)
                duration += 30.0f;
			break;
		case GADGET_SPELL_CAMOUFLAGE:
			switch (idol.rank) {
				case 1: duration = 20.0f; break;
				case 2: duration = 30.0f; break;
				case 3: duration = 40.0f; break;
				default: assert(0); break;
			}
            
            if (potencyActive)
                duration += 30.0f;
			break;
		case VOODOO_SPELL_WHIRLPOOL:
			switch (idol.rank) {
				case 1: duration = 12.0f; break;
				case 2: duration = 18.0f; break;
				case 3: duration = 24.0f; break;
				default: assert(0); break;
			}
            
            if (potencyActive)
                duration += 6.0f;
			break;
		case VOODOO_SPELL_TEMPEST:
			switch (idol.rank) {
				case 1: duration = 14.0f; break;
				case 2: duration = 22.0f; break;
				case 3: duration = 30.0f; break;
				default: assert(0); break;
			}
            
            if (potencyActive)
                duration += 6.0f;
			break;
		case VOODOO_SPELL_DEATH_FROM_DEEP:
			switch (idol.rank) {
				case 1: duration = 14.0f; break;
				case 2: duration = 22.0f; break;
				case 3: duration = 30.0f; break;
				default: assert(0); break;
			}
            
            if (potencyActive)
                duration += 10.0f;
			break;
		case VOODOO_SPELL_FLYING_DUTCHMAN:
			switch (idol.rank) {
				case 1: duration = 12.0f; break;
				case 2: duration = 18.0f; break;
				case 3: duration = 24.0f; break;
				default: assert(0); break;
			}
            
            if (potencyActive)
                duration += 16.0f;
			break;
        case VOODOO_SPELL_SEA_OF_LAVA:
            duration = 6.0f;
            break;
		default:
			assert(0);
			break;
	}

	return duration;
}

+ (float)infamyMultiplierForIdol:(Idol *)idol {
    return 1.0f;
}

+ (double)cooldownDurationForIdol:(Idol *)idol {
	double duration = 0;
    
    if (idol == nil)
        return duration;
	
	switch (idol.key) {
		case GADGET_SPELL_BRANDY_SLICK:
			duration = DAY_CYCLE_IN_SEC;
			break;
		case GADGET_SPELL_TNT_BARRELS:
			duration = DAY_CYCLE_IN_SEC;
			break;
		case GADGET_SPELL_NET:
			duration = DAY_CYCLE_IN_SEC;
			break;
		case GADGET_SPELL_CAMOUFLAGE:
			duration = DAY_CYCLE_IN_SEC;
			break;
		case VOODOO_SPELL_WHIRLPOOL:
			duration = 1.5f * DAY_CYCLE_IN_SEC;
			break;
		case VOODOO_SPELL_TEMPEST:
			duration = 1.5f * DAY_CYCLE_IN_SEC;
			break;
		case VOODOO_SPELL_DEATH_FROM_DEEP:
			duration = 1.5f * DAY_CYCLE_IN_SEC;
			break;
		case VOODOO_SPELL_FLYING_DUTCHMAN:
			duration = 1.5f * DAY_CYCLE_IN_SEC;
			break;
        case VOODOO_SPELL_SEA_OF_LAVA:
			duration = 1.5f * DAY_CYCLE_IN_SEC;
			break;
		default:
			assert(0);
			break;
	}
	
	return duration;
}

+ (uint)countForIdol:(Idol *)idol {
	uint count = 0;
    
    if (idol == nil)
        return count;
	
	switch (idol.key) {
		case GADGET_SPELL_BRANDY_SLICK:
			count = 1;
			break;
		case GADGET_SPELL_TNT_BARRELS:
			count = 12 * [Potion potencyCountFactorForPotion:[GCTRL.gameStats potionForKey:POTION_POTENCY]];
			break;
		case GADGET_SPELL_NET:
			count = 1;
			break;
		case GADGET_SPELL_CAMOUFLAGE:
			count = 1;
			break;
		case VOODOO_SPELL_WHIRLPOOL:
			count = 1;
			break;
		case VOODOO_SPELL_TEMPEST:
            count = 2;
			break;
		case VOODOO_SPELL_DEATH_FROM_DEEP:
			count = 2;
			break;
		case VOODOO_SPELL_FLYING_DUTCHMAN:
            count = 0;
			break;
        case VOODOO_SPELL_SEA_OF_LAVA:
            count = 0;
			break;
		default:
			assert(0);
			break;
	}
	
	return count;
}

+ (float)scaleForIdol:(Idol *)idol {
    return 1.0f;
    
    /*
	assert(idol);
	float scale = 1;
	
	switch (idol.key) {
		case GADGET_SPELL_BRANDY_SLICK:
			break;
		case GADGET_SPELL_TNT_BARRELS:
			break;
		case GADGET_SPELL_NET:
			switch (idol.rank) {
				case 1: scale = 0.7f; break;
				case 2: scale = 0.85f; break;
				case 3: scale = 1.0f; break;
				default: assert(0); break;
			}
			break;
		case GADGET_SPELL_CAMOUFLAGE:
			break;
		case VOODOO_SPELL_WHIRLPOOL:
			break;
		case VOODOO_SPELL_TEMPEST:
			break;
		case VOODOO_SPELL_DEATH_FROM_DEEP:
			break;
		case VOODOO_SPELL_FLYING_DUTCHMAN:
			break;
		default:
			assert(0);
			break;
	}
	
	return scale;
*/
}

+ (NSString *)priceStringForIdolUpgrade:(Idol *)idol {
    uint price = [Idol priceForIdolUpgrade:idol];
    return [GuiHelper commaSeparatedValue:price];
}

+ (uint)priceForIdolUpgrade:(Idol *)idol {
	uint price = 0;
    
    if (idol == nil)
        return price;
	
	switch (idol.key) {
		case GADGET_SPELL_BRANDY_SLICK:
			switch (idol.rank) {
				case 1: price = 2500; break;
				case 2: price = 5000; break;
				case 3: price = 10000; break;
				default: assert(0); break;
			}
			break;
		case GADGET_SPELL_TNT_BARRELS:
			switch (idol.rank) {
				case 1: price = 2500; break;
				case 2: price = 5000; break;
				case 3: price = 10000; break;
				default: assert(0); break;
			}
			break;
		case GADGET_SPELL_NET:
			switch (idol.rank) {
				case 1: price = 2500; break;
				case 2: price = 5000; break;
				case 3: price = 10000; break;
				default: assert(0); break;
			}
			break;
		case GADGET_SPELL_CAMOUFLAGE:
			switch (idol.rank) {
				case 1: price = 2500; break;
				case 2: price = 5000; break;
				case 3: price = 10000; break;
				default: assert(0); break;
			}
			break;
		case VOODOO_SPELL_WHIRLPOOL:
			switch (idol.rank) {
				case 1: price = 5000; break;
				case 2: price = 10000; break;
				case 3: price = 20000; break;
				default: assert(0); break;
			}
			break;
		case VOODOO_SPELL_TEMPEST:
			switch (idol.rank) {
				case 1: price = 5000; break;
				case 2: price = 10000; break;
				case 3: price = 20000; break;
				default: assert(0); break;
			}
			break;
		case VOODOO_SPELL_DEATH_FROM_DEEP:
			switch (idol.rank) {
				case 1: price = 5000; break;
				case 2: price = 10000; break;
				case 3: price = 20000; break;
				default: assert(0); break;
			}
			break;
		case VOODOO_SPELL_FLYING_DUTCHMAN:
			switch (idol.rank) {
				case 1: price = 5000; break;
				case 2: price = 10000; break;
				case 3: price = 20000; break;
				default: assert(0); break;
			}
			break;
        case VOODOO_SPELL_SEA_OF_LAVA:
			switch (idol.rank) {
				case 1: price = 5000; break;
				case 2: price = 10000; break;
				case 3: price = 20000; break;
				default: assert(0); break;
			}
			break;
		default:
			assert(0);
			break;
	}
	
	return price;
}

+ (NSString *)descForIdol:(Idol *)idol {
	if (idol == nil)
		return nil;
	
	NSString *desc = nil;
    uint count = [Idol countForIdol:idol];
    uint duration = (uint)[Idol durationForIdol:idol];
    //float infamyMultiplier = 100 * [Idol infamyMultiplierForIdol:idol];
	
	switch (idol.key) {
		case GADGET_SPELL_BRANDY_SLICK:
			switch (idol.rank) {
				case 1: desc = [NSString stringWithFormat:@"Spills a flammable slick of brandy that will burn for %u seconds when ignited.", duration]; break;
				case 2: desc = [NSString stringWithFormat:@"Spills a flammable slick of brandy that will burn for %u seconds when ignited.", duration]; break;
				case 3: desc = [NSString stringWithFormat:@"Spills a flammable slick of brandy that will burn for %u seconds when ignited.", duration]; break;
				default: assert(0); break;
			}
			break;
		case GADGET_SPELL_TNT_BARRELS:
			switch (idol.rank) {
				case 1: desc = [NSString stringWithFormat:@"Leaves a trail of %u explosive barrels.", count]; break;
				case 2: desc = [NSString stringWithFormat:@"Leaves a trail of %u explosive barrels.", count]; break;
				case 3: desc = [NSString stringWithFormat:@"Leaves a trail of %u explosive barrels.", count]; break;
				default: assert(0); break;
			}
			break;
		case GADGET_SPELL_NET:
			switch (idol.rank) {
				case 1: desc = [NSString stringWithFormat:@"Casts a net that ensares all enemies for %u seconds.", duration]; break;
				case 2: desc = [NSString stringWithFormat:@"Casts a net that ensares all enemies for %u seconds.", duration]; break;
				case 3: desc = [NSString stringWithFormat:@"Casts a net that ensares all enemies for %u seconds.", duration]; break;
				default: assert(0); break;
			}
			break;
		case GADGET_SPELL_CAMOUFLAGE:
			switch (idol.rank) {
				case 1: desc = [NSString stringWithFormat:@"Disguises your ship with Spanish Royal Navy colors for %u seconds.", duration]; break;
				case 2: desc = [NSString stringWithFormat:@"Disguises your ship with Spanish Royal Navy colors for %u seconds.", duration]; break;
				case 3: desc = [NSString stringWithFormat:@"Disguises your ship with Spanish Royal Navy colors for %u seconds.", duration]; break;
				default: assert(0); break;
			}
			break;
		case VOODOO_SPELL_WHIRLPOOL:
			switch (idol.rank) {
				case 1: desc = [NSString stringWithFormat:@"Summons a vortex of water for %u seconds.", duration]; break;
				case 2: desc = [NSString stringWithFormat:@"Summons a vortex of water for %u seconds.", duration]; break;
				case 3: desc = [NSString stringWithFormat:@"Summons a vortex of water for %u seconds.", duration]; break;
				default: assert(0); break;
			}
			break;
		case VOODOO_SPELL_TEMPEST:
			switch (idol.rank) {
				case 1: desc = [NSString stringWithFormat:@"Calls upon the wrath of Thor to summon two twisters for %u seconds.", duration]; break;
				case 2: desc = [NSString stringWithFormat:@"Calls upon the wrath of Thor to summon two twisters for %u seconds.", duration]; break;
				case 3: desc = [NSString stringWithFormat:@"Calls upon the wrath of Thor to summon two twisters for %u seconds.", duration]; break;
				default: assert(0); break;
			}
			break;
		case VOODOO_SPELL_DEATH_FROM_DEEP:
			switch (idol.rank) {
				case 1: desc = [NSString stringWithFormat:@"Calls upon the dark spirits of the sea to do your bidding for %u seconds. ", duration]; break;
				case 2: desc = [NSString stringWithFormat:@"Calls upon the dark spirits of the sea to do your bidding for %u seconds.", duration]; break;
				case 3: desc = [NSString stringWithFormat:@"Calls upon the dark spirits of the sea to do your bidding for %u seconds.", duration]; break;
				default: assert(0); break;
			}
			break;
		case VOODOO_SPELL_FLYING_DUTCHMAN:
			switch (idol.rank) {
				case 1: desc = [NSString stringWithFormat:@"Channels the power of immunity for %u seconds.", duration]; break;
				case 2: desc = [NSString stringWithFormat:@"Channels the power of immunity for %u seconds.", duration]; break;
				case 3: desc = [NSString stringWithFormat:@"Channels the power of immunity for %u seconds.", duration]; break;
				default: assert(0); break;
			}
			break;
        case VOODOO_SPELL_SEA_OF_LAVA:
			switch (idol.rank) {
				case 1:
				case 2:
				case 3: desc = [NSString stringWithFormat:@"Turns the ocean into lava."]; break;
				default: assert(0); break;
			}
			break;
		default:
			assert(0);
			break;
	}
	
	return desc;
}

+ (NSString *)shopDescForIdol:(Idol *)idol {
	if (idol == nil)
		return nil;
	
	NSString *desc = nil;
	NSString *price = [self priceStringForIdolUpgrade:idol];
    uint count = [Idol countForIdol:idol];
    uint duration = (uint)[Idol durationForIdol:idol];
    //float infamyMultiplier = 100 * [Idol infamyMultiplierForIdol:idol];
	
	switch (idol.key) {
		case GADGET_SPELL_BRANDY_SLICK:
			switch (idol.rank) {
				case 1: desc = [NSString stringWithFormat:@"Spill a flammable slick of brandy that will burn for %u seconds when ignited. Just %@ doubloons.", duration, price]; break;
				case 2: desc = [NSString stringWithFormat:@"Spill a flammable slick of brandy that will burn for %u seconds when ignited. Just %@ doubloons.", duration, price]; break;
				case 3: desc = [NSString stringWithFormat:@"Spill a flammable slick of brandy that will burn for %u seconds when ignited. Just %@ doubloons.", duration, price]; break;
				default: assert(0); break;
			}
			break;
		case GADGET_SPELL_TNT_BARRELS:
			switch (idol.rank) {
				case 1: desc = [NSString stringWithFormat:@"Leave a trail of %u explosive barrels! You can have for %@ doubloons.", count, price]; break;
				case 2: desc = [NSString stringWithFormat:@"Leave a trail of %u explosive barrels! You can have for %@ doubloons.", count, price]; break;
				case 3: desc = [NSString stringWithFormat:@"Leave a trail of %u explosive barrels! You can have for %@ doubloons.", count, price]; break;
				default: assert(0); break;
			}
			break;
		case GADGET_SPELL_NET:
			switch (idol.rank) {
				case 1: desc = [NSString stringWithFormat:@"Casts a net that ensares all enemies for %u seconds. Just %@ doubloons.", duration, price]; break;
				case 2: desc = [NSString stringWithFormat:@"Casts a net that ensares all enemies for %u seconds. Just %@ doubloons.", duration, price]; break;
				case 3: desc = [NSString stringWithFormat:@"Casts a net that ensares all enemies for %u seconds. Just %@ doubloons.", duration, price]; break;
				default: assert(0); break;
			}
			break;
		case GADGET_SPELL_CAMOUFLAGE:
			switch (idol.rank) {
				case 1: desc = [NSString stringWithFormat:@"Disguise your ship with Spanish Royal Navy colors for %u seconds! You can take it for %@ doubloons.", duration, price]; break;
				case 2: desc = [NSString stringWithFormat:@"Disguise your ship with Spanish Royal Navy colors for %u seconds! You can take it for %@ doubloons.", duration, price]; break;
				case 3: desc = [NSString stringWithFormat:@"Disguise your ship with Spanish Royal Navy colors for %u seconds! You can take it for %@ doubloons.", duration, price]; break;
				default: assert(0); break;
			}
			break;
		case VOODOO_SPELL_WHIRLPOOL:
			switch (idol.rank) {
				case 1: desc = [NSString stringWithFormat:@"Summon a vortex of water for %u seconds! Only %@ doubloons.", duration, price]; break;
				case 2: desc = [NSString stringWithFormat:@"Summon a vortex of water for %u seconds! Only %@ doubloons.", duration, price]; break;
				case 3: desc = [NSString stringWithFormat:@"Summon a vortex of water for %u seconds! Only %@ doubloons.", duration, price]; break;
				default: assert(0); break;
			}
			break;
		case VOODOO_SPELL_TEMPEST:
			switch (idol.rank) {
				case 1: desc = [NSString stringWithFormat:@"Call upon da wrath of Thor to summon two twisters for %u seconds! Only %@ doubloons.", duration, price]; break;
				case 2: desc = [NSString stringWithFormat:@"Call upon da wrath of Thor to summon two twisters for %u seconds! Only %@ doubloons.", duration, price]; break;
				case 3: desc = [NSString stringWithFormat:@"Call upon da wrath of Thor to summon two twisters for %u seconds! Only %@ doubloons.", duration, price]; break;
				default: assert(0); break;
			}
			break;
		case VOODOO_SPELL_DEATH_FROM_DEEP:
			switch (idol.rank) {
				case 1: desc = [NSString stringWithFormat:@"Call upon da dark spirits of da sea to do ya bidding for %u seconds! A steal at %@ doubloons.", duration, price]; break;
				case 2: desc = [NSString stringWithFormat:@"Call upon da dark spirits of da sea to do ya bidding for %u seconds! A steal at %@ doubloons.", duration, price]; break;
				case 3: desc = [NSString stringWithFormat:@"Call upon da dark spirits of da sea to do ya bidding for %u seconds! A steal at %@ doubloons.", duration, price]; break;
				default: assert(0); break;
			}
			break;
		case VOODOO_SPELL_FLYING_DUTCHMAN:
			switch (idol.rank) {
				case 1: desc = [NSString stringWithFormat:@"Channel da power of immunity for %u seconds! Just %@ doubloons.", duration, price]; break;
				case 2: desc = [NSString stringWithFormat:@"Channel da power of immunity for %u seconds! Just %@ doubloons.", duration, price]; break;
				case 3: desc = [NSString stringWithFormat:@"Channel da power of immunity for %u seconds! Just %@ doubloons.", duration, price]; break;
				default: assert(0); break;
			}
			break;
        case VOODOO_SPELL_SEA_OF_LAVA:
			switch (idol.rank) {
				case 1:
				case 2:
				case 3: desc = [NSString stringWithFormat:@"Turns the ocean into lava! Just %@ doubloons.", price]; break;
				default: assert(0); break;
			}
			break;
		default:
			assert(0);
			break;
	}
	
	return desc;
}

+ (NSString *)nameForIdol:(Idol *)idol {
	if (idol == nil)
		return nil;
	
	NSString *desc = nil;
	
	switch (idol.key) {
		case GADGET_SPELL_BRANDY_SLICK: desc = @"Brandy Slick"; break;
		case GADGET_SPELL_TNT_BARRELS: desc = @"Powder Keg"; break;
		case GADGET_SPELL_NET: desc = @"Trawling Net"; break;
		case GADGET_SPELL_CAMOUFLAGE: desc = @"Camouflage"; break;
		case VOODOO_SPELL_WHIRLPOOL: desc = @"Swirling Abyss"; break;
		case VOODOO_SPELL_TEMPEST: desc = @"Ghostly Tempest"; break;
		case VOODOO_SPELL_DEATH_FROM_DEEP: desc = @"Death from the Deep"; break;
		case VOODOO_SPELL_FLYING_DUTCHMAN: desc = @"Flying Dutchman"; break;
        case VOODOO_SPELL_SEA_OF_LAVA: desc = @"Sea of Lava"; break;
		default: break;
	}
	
	if (desc)
		desc = [NSString stringWithFormat:@"%@ %@", desc, [GuiHelper romanNumeralsForDecimalValueToX:idol.rank]];
	return desc;
}

+ (NSString *)textureNameForKey:(uint)key {
	NSString *textureName = nil;
	
	switch (key) {
		case GADGET_SPELL_BRANDY_SLICK: textureName = @"brandy-slick"; break;
		case GADGET_SPELL_TNT_BARRELS: textureName = @"powder-keg"; break;
		case GADGET_SPELL_NET: textureName = @"net"; break;
		case GADGET_SPELL_CAMOUFLAGE: textureName = @"navy"; break;
		case VOODOO_SPELL_WHIRLPOOL: textureName = @"whirlpool-idol"; break;
		case VOODOO_SPELL_TEMPEST: textureName = @"tempest-idol"; break;
		case VOODOO_SPELL_DEATH_FROM_DEEP: textureName = @"death-from-the-deep-idol"; break;
		case VOODOO_SPELL_FLYING_DUTCHMAN: textureName = @"flying-dutchman-idol"; break;
        case VOODOO_SPELL_SEA_OF_LAVA:
		default: break;
	}
	
	return textureName;
}

+ (NSString *)iconTextureNameForKey:(uint)key {
	NSString *textureName = nil;
	
	switch (key) {
		case GADGET_SPELL_BRANDY_SLICK: textureName = @"brandy-slick-icon"; break;
		case GADGET_SPELL_TNT_BARRELS: textureName = @"powder-keg-icon"; break;
		case GADGET_SPELL_NET: textureName = @"net-icon"; break;
		case GADGET_SPELL_CAMOUFLAGE: textureName = @"camouflage-icon"; break;
		case VOODOO_SPELL_WHIRLPOOL: textureName = @"whirlpool-icon"; break;
		case VOODOO_SPELL_TEMPEST: textureName = @"tempest-icon"; break;
		case VOODOO_SPELL_DEATH_FROM_DEEP: textureName = @"death-from-the-deep-icon"; break;
		case VOODOO_SPELL_FLYING_DUTCHMAN: textureName = @"flying-dutchman-icon"; break;
        case VOODOO_SPELL_SEA_OF_LAVA: textureName = @"sea-of-lava-icon"; break;
		default: break;
	}
	
	return textureName;
}

+ (NSString *)logbookIconTextureNameForKey:(uint)key {
    NSString *textureName = nil;
	
	switch (key) {
		case GADGET_SPELL_BRANDY_SLICK: textureName = @"brandy-slick-logbook-icon"; break;
		case GADGET_SPELL_TNT_BARRELS: textureName = @"powder-keg-logbook-icon"; break;
		case GADGET_SPELL_NET: textureName = @"net-logbook-icon"; break;
		case GADGET_SPELL_CAMOUFLAGE: textureName = @"camouflage-logbook-icon"; break;
		case VOODOO_SPELL_WHIRLPOOL: textureName = @"whirlpool-logbook-icon"; break;
		case VOODOO_SPELL_TEMPEST: textureName = @"tempest-logbook-icon"; break;
		case VOODOO_SPELL_DEATH_FROM_DEEP: textureName = @"death-from-the-deep-logbook-icon"; break;
		case VOODOO_SPELL_FLYING_DUTCHMAN: textureName = @"flying-dutchman-logbook-icon"; break;
        case VOODOO_SPELL_SEA_OF_LAVA: textureName = @"sea-of-lava-logbook-icon"; break;
		default: break;
	}
	
	return textureName;
}

@end
