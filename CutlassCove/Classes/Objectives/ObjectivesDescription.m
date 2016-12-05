//
//  ObjectivesDescription.m
//  Cutlass Cove
//
//  Created by Paul McPhee on 6/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ObjectivesDescription.h"
#import "GuiHelper.h"
#import "Ash.h"

@implementation ObjectivesDescription

@synthesize count = mCount;
@synthesize key = mKey;
@synthesize isFailed = mFailed;
@dynamic quota,isCompleted,isCumulative,description,logbookDescription;

- (id)initWithKey:(uint)key count:(uint)count {
    if (self = [super init]) {
        mKey = key;
        mCount = count;
        mFailed = NO;
    }
    return self;
}

- (id)initWithKey:(uint)key {
    return [self initWithKey:key count:0];
}

- (id)init {
    return [self initWithKey:0];
}

- (void)setCount:(uint)count {
    mCount = MIN(count,self.quota);
}

- (uint)quota {
    return [ObjectivesDescription quotaForKey:mKey];
}

- (void)setIsFailed:(BOOL)isFailed {
    // Don't set a completed objective to a failed state
    if (isFailed == NO || self.isCompleted == NO)
        mFailed = isFailed;
}

- (BOOL)isCompleted {
    return (mCount >= self.quota);
}

- (BOOL)isCumulative {
    return [ObjectivesDescription isCumulativeForKey:mKey];
}

- (NSString *)description {
    return [ObjectivesDescription descriptionTextForKey:mKey];
}

- (NSString *)logbookDescription {
    return [ObjectivesDescription logbookDescriptionTextForKey:mKey];
}

- (void)forceCompletion {
    self.count = self.quota;
     self.isFailed = NO;
}

- (void)reset {
    self.count = 0;
    self.isFailed = NO;
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
        mKey = [(NSNumber *)[decoder decodeObjectForKey:@"key"] unsignedIntValue];
        mCount = [(NSNumber *)[decoder decodeObjectForKey:@"count"] unsignedIntValue];
        mFailed = [(NSNumber *)[decoder decodeObjectForKey:@"failed"] boolValue];
        
        mCount = MIN(mCount,[ObjectivesDescription quotaForKey:mKey]);
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:[NSNumber numberWithUnsignedInt:mKey] forKey:@"key"];
    [coder encodeObject:[NSNumber numberWithUnsignedInt:mCount] forKey:@"count"];
    [coder encodeObject:[NSNumber numberWithBool:mFailed] forKey:@"failed"];
}

+ (ObjectivesDescription *)objectivesDescriptionWithKey:(uint)key count:(uint)count {
    return [[[ObjectivesDescription alloc] initWithKey:key count:count] autorelease];
}

+ (ObjectivesDescription *)objectivesDescriptionWithKey:(uint)key {
    return [ObjectivesDescription objectivesDescriptionWithKey:key count:0];
}

+ (NSString *)descriptionTextForKey:(uint)key {
    NSString *desc = nil;
    uint value = [ObjectivesDescription valueForKey:key], quota = [ObjectivesDescription quotaForKey:key];
    
    switch (key) {
#ifndef CHEEKY_LITE_VERSION 
        // 0 Unranked
        case 1: desc = [NSString stringWithFormat:@"Make a rival pirate walk the plank."]; break;
        case 2: desc = [NSString stringWithFormat:@"Sink %u ships with a Powder Keg deployment.", quota]; break;
        case 3: desc = [NSString stringWithFormat:@"Survive until sunset on Day %u.", value]; break;
        
        // 1 Swabby
        case 4: desc = [NSString stringWithFormat:@"Sink the Treasure Fleet."]; break;
        case 5: desc = [NSString stringWithFormat:@"Score a ricochet by shooting %u ships with one cannonball.", value]; break;
        case 6: desc = [NSString stringWithFormat:@"Remove a red cross by sinking 10 ships."]; break;
            
        // 2 Deckhand
        case 7: desc = [NSString stringWithFormat:@"Sink %u navy ships.", quota]; break;
        case 8: desc = [NSString stringWithFormat:@"Sink %u ships in a Whirlpool.", quota]; break;
        case 9: desc = [NSString stringWithFormat:@"Score %u ricochets.", quota]; break;
            
        // 3 Jack Tar
        case 10: desc = [NSString stringWithFormat:@"Shoot %u ships with a pickup of Molten Shot.", quota]; break;
        case 11: desc = [NSString stringWithFormat:@"Shoot %u ships without missing.", quota]; break;
        case 12: desc = [NSString stringWithFormat:@"Survive until sunrise on Day %u.", value]; break;
            
        // 4 Old Salt
        case 13: desc = [NSString stringWithFormat:@"Trap %u ships in a Trawling Net.", value]; break;
        case 14: desc = [NSString stringWithFormat:@"Sink %u rival pirate ships.", quota]; break;
        case 15: desc = [NSString stringWithFormat:@"Achieve a score of %@ without getting any ricochets.", [GuiHelper commaSeparatedValue:value]]; break;
#else
        // 0 Unranked
        case 1: desc = [NSString stringWithFormat:@"Remove a red cross by sinking 10 ships."]; break;
        case 2: desc = [NSString stringWithFormat:@"Sink %u ships with a Tornado Storm.", quota]; break;
        case 3: desc = [NSString stringWithFormat:@"Shoot %u ships wihout missing", quota]; break;
            
        // 1 Jiker
        case 4: desc = [NSString stringWithFormat:@"Score a ricochet by shooting %u ships with one cannonball.", value]; break;
        case 5: desc = [NSString stringWithFormat:@"Sink a navy ship with a Powder Keg deployment."]; break;
        case 6: desc = [NSString stringWithFormat:@"Survive until midnight on Day %u.", value]; break;
            
        // 2 Powder Monkey
        case 7: desc = [NSString stringWithFormat:@"Make %u rival pirates walk the plank.", quota]; break;
        case 8: desc = [NSString stringWithFormat:@"Sink %u ships in acid pools with a pickup of Venom Shot.", quota]; break;
        case 9: desc = [NSString stringWithFormat:@"Achieve a score of %@ before sunset on Day %u.", [GuiHelper commaSeparatedValue:25000], value]; break;
            
        // 3 Boatswain
        case 10: desc = [NSString stringWithFormat:@"Trap %u ships in a Trawling Net.", value]; break;
        case 11: desc = [NSString stringWithFormat:@"Knock %u enemy crew overboard with a pickup of Crimson Shot.", quota]; break;
        case 12: desc = [NSString stringWithFormat:@"Sink %u ships in a row without firing a cannonball.", quota]; break;
            
        // 4 Quartermaster
        case 13: desc = [NSString stringWithFormat:@"Sink the Treasure Fleet twice."]; break;
        case 14: desc = [NSString stringWithFormat:@"Sink a navy ship and a rival pirate ship in a Whirlpool."]; break;
        case 15: desc = [NSString stringWithFormat:@"Achieve a score of %@.", [GuiHelper commaSeparatedValue:value]]; break;
#endif
        // 5 Helmsman
        case 16: desc = [NSString stringWithFormat:@"Sink the Silver Train twice."]; break;
        case 17: desc = [NSString stringWithFormat:@"Survive until midnight on Day %u without getting a red cross.", value]; break;
        case 18: desc = [NSString stringWithFormat:@"Shoot %u ships with one cannon-^ball.", value]; break;
            
        // 6 Sea Dog
        case 19: desc = [NSString stringWithFormat:@"Make %u rival pirates walk the plank.", quota]; break;
        case 20: desc = [NSString stringWithFormat:@"Sink %u ships with the Hand of Davy.", quota]; break;
        case 21: desc = [NSString stringWithFormat:@"Survive until midnight on Day %u.", value]; break;
            
        // 7 Villain
        case 22: desc = [NSString stringWithFormat:@"Shoot %u navy ships with one cannonball.", value]; break;
        case 23: desc = [NSString stringWithFormat:@"Score %u ricochets.", quota]; break;
        case 24: desc = [NSString stringWithFormat:@"Knock %u enemy crew overboard with a pickup of Crimson Shot.", quota]; break;
            
        // 8 Brigand
        case 25: desc = [NSString stringWithFormat:@"Sink %u navy ships.", quota]; break;
        case 26: desc = [NSString stringWithFormat:@"Sink %u ships in a Brandy Slick.", quota]; break;
        case 27: desc = [NSString stringWithFormat:@"Achieve a score of %@.", [GuiHelper commaSeparatedValue:value]]; break;
            
        // 9 Looter
        case 28: desc = [NSString stringWithFormat:@"Shoot %u ships without missing.", quota]; break;
        case 29: desc = [NSString stringWithFormat:@"Survive until sunrise on Day %u without sinking a navy ship.", value]; break;
        case 30: desc = [NSString stringWithFormat:@"Shoot %u rival pirate ships with one cannonball.", value]; break;
            
        // 10 Gallows Bird
        case 31: desc = [NSString stringWithFormat:@"Sink %u rival pirate ships.", quota]; break;
        case 32: desc = [NSString stringWithFormat:@"Shoot %u ships while aboard the Ghost Ship.", quota]; break;
        case 33: desc = [NSString stringWithFormat:@"Survive until sunrise on Day %u.", value]; break;
            
        // 11 Scoundrel
        case 34: desc = [NSString stringWithFormat:@"Sink the Treasure Fleet %u times.", quota]; break;
        case 35: desc = [NSString stringWithFormat:@"Sink %u ships in acid pools with a pickup of Venom Shot.", quota]; break;
        case 36: desc = [NSString stringWithFormat:@"Shoot %u ships with one cannon-^ball.", value]; break;
            
        // 12 Rogue
        case 37: desc = [NSString stringWithFormat:@"Shoot %u ships while flying Navy Colors.", quota]; break;
        case 38: desc = [NSString stringWithFormat:@"Make %u rival pirates walk the plank.", quota]; break;
        case 39: desc = [NSString stringWithFormat:@"Achieve a score of %@.", [GuiHelper commaSeparatedValue:value]]; break;
            
        // 13 Pillager
        case 40: desc = [NSString stringWithFormat:@"Shoot %u ships without missing.", quota]; break;
        case 41: desc = [NSString stringWithFormat:@"Survive until sunrise on Day %u without being shot.", value]; break;
        case 42: desc = [NSString stringWithFormat:@"Score %u ricochets.", quota]; break;
            
        // 14 Plunderer
        case 43: desc = [NSString stringWithFormat:@"Shoot a navy ship and a rival pirate ship with one cannonball."]; break;
        case 44: desc = [NSString stringWithFormat:@"Sink %u ships with a Tornado Storm.", quota]; break;
        case 45: desc = [NSString stringWithFormat:@"Survive until midnight on Day %u.", value]; break;
            
        // 15 Freebooter
        case 46: desc = [NSString stringWithFormat:@"Sink %u navy ships.", quota]; break;
        case 47: desc = [NSString stringWithFormat:@"Knock %u enemy crew overboard with a pickup of Crimson Shot.", quota]; break;
        case 48: desc = [NSString stringWithFormat:@"Achieve a score of %@.", [GuiHelper commaSeparatedValue:value]]; break;
            
        // 16 Privateer
        case 49: desc = [NSString stringWithFormat:@"Sink %u rival pirate ships.", quota]; break;
        case 50: desc = [NSString stringWithFormat:@"Survive until midnight on Day %u without getting a red cross.", value]; break;
        case 51: desc = [NSString stringWithFormat:@"Score %u ricochets in a row.", quota]; break;
            
        // 17 Corsair
        case 52: desc = [NSString stringWithFormat:@"Remove %u red crosses.", quota]; break;
        case 53: desc = [NSString stringWithFormat:@"Survive until noon on Day %u without sinking a navy ship.", value]; break;
        case 54: desc = [NSString stringWithFormat:@"Achieve a score of %@ without getting any ricochets.", [GuiHelper commaSeparatedValue:value]]; break;

        // 18 Buccaneer
        case 55: desc = [NSString stringWithFormat:@"Shoot %u ships with a pickup of Molten Shot.", quota]; break;
        case 56: desc = [NSString stringWithFormat:@"Sink the Treasure Fleet twice with a Powder Keg deployment."]; break;
        case 57: desc = [NSString stringWithFormat:@"Survive until sunrise on Day %u without using spells or munitions.", value]; break;
            
        // 19 Sea Wolf
        case 58: desc = [NSString stringWithFormat:@"Sink %u ships in a row without firing a cannonball.", quota]; break;
        case 59: desc = [NSString stringWithFormat:@"Achieve a score of %@.", [GuiHelper commaSeparatedValue:value]]; break;
        case 60: desc = [NSString stringWithFormat:@"Survive until noon on Day %u without sinking a pirate ship.", value]; break;
        
        // 20 Swashbuckler
        case 61: desc = [NSString stringWithFormat:@"Spawn %u pools of magma with a Sea of Lava.", quota]; break;
        case 62: desc = [NSString stringWithFormat:@"Sink %u ships in abyssal surges with a pickup of Abyssal Shot.", quota]; break;
        case 63: desc = [NSString stringWithFormat:@"Survive until sunrise on Day %u.", value]; break;
            
        // 21 Calico Jack
        case 64: desc = [NSString stringWithFormat:@"Achieve a score of %@ before sunrise on Day %u.", [GuiHelper commaSeparatedValue:5000000], value]; break;
        case 65: desc = [NSString stringWithFormat:@"Sink the Silver Train twice with a pickup of Molten Shot."]; break;
        case 66: desc = [NSString stringWithFormat:@"Sink %u rival pirate ships with a Powder Keg deployment.", quota]; break;
            
        // 22 Black Bart
        case 67: desc = [NSString stringWithFormat:@"Survive until midnight on Day %u without shooting a ship.", value]; break;
        case 68: desc = [NSString stringWithFormat:@"Remove %u red crosses while flying Navy Colors.", quota]; break;
        case 69: desc = [NSString stringWithFormat:@"Shoot %u navy ships with a pickup of Crimson Shot.", quota]; break;
            
        // 23 Barbarossa
        case 70: desc = [NSString stringWithFormat:@"Score %u ricochets before sunset on Day %u.", quota, value]; break;
        case 71: desc = [NSString stringWithFormat:@"Achieve a score of %@.", [GuiHelper commaSeparatedValue:value]]; break;
        case 72: desc = [NSString stringWithFormat:@"Shoot %u ships with one cannon-^ball.", value]; break;
            
        // 24 Captain Kidd
        case 73: desc = [NSString stringWithFormat:@"Sink %u navy ships with the Hand of Davy.", quota]; break;
        case 74: desc = [NSString stringWithFormat:@"Knock %u enemy crew overboard with a pickup of Crimson Shot.", quota]; break;
        case 75: desc = [NSString stringWithFormat:@"Survive until noon on Day %u.", value]; break;
            
        // 25 Captain O'Malley
        case 76: desc = [NSString stringWithFormat:@"Sink %u rival pirate ships with a Tornado Storm.", quota]; break;
        case 77: desc = [NSString stringWithFormat:@"Make %u rival pirates walk the plank during Day %u.", quota, value]; break;
        case 78: desc = [NSString stringWithFormat:@"Achieve a score of %@.", [GuiHelper commaSeparatedValue:value]]; break;
            
        // 26 Major Stede
        case 79: desc = [NSString stringWithFormat:@"Score %u ricochets that sink %u or more ships.", quota, value]; break;
        case 80: desc = [NSString stringWithFormat:@"Score %u ricochets that sink %u or more ships.", quota, value]; break;
        case 81: desc = [NSString stringWithFormat:@"Score %u ricochets that sink %u or more ships.", quota, value]; break;
            
        // 27 Black Bellamy
        case 82: desc = [NSString stringWithFormat:@"Sink %u ships in abyssal surges with a pickup of Abyssal Shot.", quota]; break;
        case 83: desc = [NSString stringWithFormat:@"Survive until dusk on Day %u.", value]; break;
        case 84: desc = [NSString stringWithFormat:@"Achieve a score of %@.", [GuiHelper commaSeparatedValue:value]]; break;
            
        // 28 Long Ben
        case 85: desc = [NSString stringWithFormat:@"Incinerate %u overboard sailors in a Sea of Lava.", quota]; break;
        case 86: desc = [NSString stringWithFormat:@"Drown %u overboard sailors in a Whirlpool.", quota]; break;
        case 87: desc = [NSString stringWithFormat:@"Score %u ricochets while aboard the Ghost Ship.", quota]; break;

        // 29 Admiral Morgan
        case 88: desc = [NSString stringWithFormat:@"Shoot %u ships with one cannon-^ball.", value]; break;
        case 89: desc = [NSString stringWithFormat:@"Survive until sunset on Day %u.", value]; break;
        case 90: desc = [NSString stringWithFormat:@"Achieve a score of %@.", [GuiHelper commaSeparatedValue:value]]; break;
            
        // 30 The Dragon
        default: desc = nil; break;
    }
    
    return desc;
}

+ (NSString *)logbookDescriptionTextForKey:(uint)key {
    NSString *desc = nil;
#ifndef CHEEKY_LITE_VERSION
    uint value = [ObjectivesDescription valueForKey:key];
#endif
    uint quota = [ObjectivesDescription quotaForKey:key];
    
    switch (key) {
#ifndef CHEEKY_LITE_VERSION
        case 18: desc = [NSString stringWithFormat:@"Shoot %u ships with one cannonball.", value]; break;
        case 36: desc = [NSString stringWithFormat:@"Shoot %u ships with one cannonball.", value]; break;
        case 53: desc = [NSString stringWithFormat:@"Survive until noon on^Day %u without sinking a^navy ship.", value]; break;
        case 58: desc = [NSString stringWithFormat:@"Sink %u ships in a row without firing a cannon-^ball.", quota]; break;
        case 60: desc = [NSString stringWithFormat:@"Survive until noon on^Day %u without sinking a pirate ship.", value]; break;
        case 64: desc = [NSString stringWithFormat:@"Achieve a score of %@ before^sunrise on Day %u.", [GuiHelper commaSeparatedValue:5000000], value]; break;
        case 72: desc = [NSString stringWithFormat:@"Shoot %u ships with one cannonball.", value]; break;
        case 75: desc = [NSString stringWithFormat:@"Survive until noon on^Day %u.", value]; break;
        case 83: desc = [NSString stringWithFormat:@"Survive until dusk on^Day %u.", value]; break;
        case 88: desc = [NSString stringWithFormat:@"Shoot %u ships with one cannonball.", value]; break;
#else
        case 12: desc = [NSString stringWithFormat:@"Sink %u ships in a row without firing a cannon-^ball.", quota]; break;
#endif
        default: desc = [ObjectivesDescription descriptionTextForKey:key]; break;
    }
    
    return desc;
}

// For non-binary events
+ (uint)quotaForKey:(uint)key {
    uint quota = 0;
    
    switch (key) {
#ifndef CHEEKY_LITE_VERSION
            // Unranked
        case 1: quota = 1; break;
        case 2: quota = 3; break;
        case 3: quota = 1; break;
            
            // Swabby
        case 4: quota = 1; break;
        case 5: quota = 1; break;
        case 6: quota = 1; break;
            
            // Deckhand
        case 7: quota = 5; break;
        case 8: quota = 10; break;
        case 9: quota = 5; break;
            
            // Jack Tar
        case 10: quota = 10; break;
        case 11: quota = 10; break;
        case 12: quota = 1; break;
            
            // Old Salt
        case 13: quota = 1; break;
        case 14: quota = 10; break;
        case 15: quota = 1; break;
#else
            // Unranked
        case 1: quota = 1; break;
        case 2: quota = 10; break;
        case 3: quota = 5; break;
            
            // Jiker
        case 4: quota = 1; break;
        case 5: quota = 1; break;
        case 6: quota = 1; break;
            
            // Powder Monkey
        case 7: quota = 3; break;
        case 8: quota = 5; break;
        case 9: quota = 1; break;
            
            // Boatswain
        case 10: quota = 1; break;
        case 11: quota = 10; break;
        case 12: quota = 25; break;
            
            // Quartermaster
        case 13: quota = 2; break;
        case 14: quota = 1; break;
        case 15: quota = 1; break;
#endif
            
            // Helmsman
        case 16: quota = 2; break;
        case 17: quota = 1; break;
        case 18: quota = 1; break;
            
            // Sea Dog
        case 19: quota = 15; break;
        case 20: quota = 20; break;
        case 21: quota = 1; break;
            
            // Villain
        case 22: quota = 1; break;
        case 23: quota = 10; break;
        case 24: quota = 15; break;
            
            // Brigand
        case 25: quota = 10; break;
        case 26: quota = 10; break;
        case 27: quota = 1; break;
            
            // Looter
        case 28: quota = 20; break;
        case 29: quota = 1; break;
        case 30: quota = 1; break;
            
            // Gallows Bird
        case 31: quota = 20; break;
        case 32: quota = 20; break;
        case 33: quota = 1; break;
            
            // Scoundrel
        case 34: quota = 3; break;
        case 35: quota = 20; break;
        case 36: quota = 1; break;
            
            // Rogue
        case 37: quota = 30; break;
        case 38: quota = 25; break;
        case 39: quota = 1; break;
            
            // Pillager
        case 40: quota = 30; break;
        case 41: quota = 1; break;
        case 42: quota = 20; break;
            
            // Plunderer
        case 43: quota = 1; break;
        case 44: quota = 25; break;
        case 45: quota = 1; break;
            
            // Freebooter
        case 46: quota = 25; break;
        case 47: quota = 30; break;
        case 48: quota = 1; break;
            
            // Privateer
        case 49: quota = 40; break;
        case 50: quota = 1; break;
        case 51: quota = 6; break;
            
            // Corsair
        case 52: quota = 25; break;
        case 53: quota = 1; break;
        case 54: quota = 1; break;
            
            // Buccaneer
        case 55: quota = 40; break;
        case 56: quota = 2; break;
        case 57: quota = 1; break;
            
            // Sea Wolf
        case 58: quota = 80; break;
        case 59: quota = 1; break;
        case 60: quota = 1; break;
            
            // Swashbuckler
        case 61: quota = 12; break;
        case 62: quota = 40; break;
        case 63: quota = 1; break;
            
            // Calico Jack
        case 64: quota = 1; break;
        case 65: quota = 2; break;
        case 66: quota = 6; break;
            
            // Black Bart
        case 67: quota = 1; break;
        case 68: quota = 6; break;
        case 69: quota = 10; break;
            
            // Barbarossa
        case 70: quota = 25; break;
        case 71: quota = 1; break;
        case 72: quota = 1; break;
            
            // Captain Kidd
        case 73: quota = 5; break;
        case 74: quota = 60; break;
        case 75: quota = 1; break;
            
            // Captain O'Malley
        case 76: quota = 5; break;
        case 77: quota = 24; break;
        case 78: quota = 1; break;
            
            // Major Stede
        case 79: quota = 8; break;
        case 80: quota = 4; break;
        case 81: quota = 2; break;
            
            // Black Bellamy
        case 82: quota = 55; break;
        case 83: quota = 1; break;
        case 84: quota = 1; break;
            
            // Long Ben
        case 85: quota = 15; break;
        case 86: quota = 15; break;
        case 87: quota = 10; break;
            
            // Admiral Morgan
        case 88: quota = 1; break;
        case 89: quota = 1; break;
        case 90: quota = 1; break;
            
            // The Dragon
        default: quota = 1; break; // Make it 1 so that isCompleted returns NO
    }
    
    return quota;
}

// For binary events (e.g. you either score a 2x ricochet or you don't)
+ (uint)valueForKey:(uint)key {
    uint value = 0;
    
    switch (key) {
#ifndef CHEEKY_LITE_VERSION
        case 3: value = 1; break;
        case 5: value = 2; break;
        case 12: value = 2; break;
        case 13: value = 5; break;
        case 15: value = 250000; break;
#else
        case 4: value = 2; break;
        case 6: value = 1; break;
        case 9: value = 1; break;
        case 10: value = 3; break;
        case 15: value = 250000; break;
#endif
        case 17: value = 1; break;
        case 18: value = 3; break;
        case 21: value = 2; break;
        case 22: value = 2; break;
        case 27: value = 2000000; break;
        case 29: value = 2; break;
        case 30: value = 2; break;
        case 33: value = 3; break;
        case 36: value = 4; break;
        case 39: value = 3000000; break;
        case 41: value = 3; break;
        case 45: value = 3; break;
        case 48: value = 4500000; break;
        case 50: value = 2; break;
        case 53: value = 2; break;
        case 54: value = 1750000; break;
        case 57: value = 3; break;
        case 59: value = 6000000; break;
        case 60: value = 2; break;
        case 63: value = 4; break;
        case 64: value = 3; break;
        case 67: value = 2; break;
        case 70: value = 2; break;
        case 71: value = 7000000; break;
        case 72: value = 5; break;
        case 75: value = 5; break;
        case 77: value = 4; break;
        case 78: value = 15000000; break;
        case 79: value = 3; break;
        case 80: value = 4; break;
        case 81: value = 5; break;
        case 83: value = 6; break;
        case 84: value = 20000000; break;
        case 88: value = 6; break;
        case 89: value = 7; break;
        case 90: value = 30000000; break;
        default: value = 0; break;
    }
    
    return value;
}

+ (BOOL)isCumulativeForKey:(uint)key {
    return NO;
    
    /*
    BOOL cumulative = NO;
    
    switch (key) {
            // Unranked
        case 1: cumulative = NO; break;
        case 2: cumulative = NO; break;
        case 3: cumulative = NO; break;
            
            // Swabby
        case 4: cumulative = YES; break;
        case 5: cumulative = NO; break;
        case 6: cumulative = NO; break;
            
            // Deckhand
        case 7: cumulative = NO; break;
        case 8: cumulative = NO; break;
        case 9: cumulative = NO; break;
            
            // Jack Tar
        case 10: cumulative = NO; break;
        case 11: cumulative = NO; break;
        case 12: cumulative = NO; break;
            
            // Old Salt
        case 13: cumulative = NO; break;
        case 14: cumulative = NO; break;
        case 15: cumulative = NO; break;
            
            // Helmsman
        case 16: cumulative = NO; break;
        case 17: cumulative = NO; break;
        case 18: cumulative = NO; break;
            
            // Sea Dog
        case 19: cumulative = NO; break;
        case 20: cumulative = YES; break;
        case 21: cumulative = NO; break;
            
            // Villain
        case 22: cumulative = NO; break;
        case 23: cumulative = NO; break;
        case 24: cumulative = NO; break;
            
            // Brigand
        case 25: cumulative = NO; break;
        case 26: cumulative = NO; break;
        case 27: cumulative = NO; break;
            
            // Looter
        case 28: cumulative = NO; break;
        case 29: cumulative = NO; break;
        case 30: cumulative = NO; break;
            
            // Gallows Bird
        case 31: cumulative = NO; break;
        case 32: cumulative = NO; break;
        case 33: cumulative = NO; break;
            
            // Scoundrel
        case 34: cumulative = NO; break;
        case 35: cumulative = NO; break;
        case 36: cumulative = NO; break;
            
            // Rogue
        case 37: cumulative = NO; break;
        case 38: cumulative = NO; break;
        case 39: cumulative = NO; break;
            
            // Pillager
        case 40: cumulative = NO; break;
        case 41: cumulative = NO; break;
        case 42: cumulative = NO; break;
            
            // Plunderer
        case 43: cumulative = NO; break;
        case 44: cumulative = NO; break;
        case 45: cumulative = NO; break;
            
            // Freebooter
        case 46: cumulative = NO; break;
        case 47: cumulative = NO; break;
        case 48: cumulative = NO; break;
            
            // Privateer
        case 49: cumulative = NO; break;
        case 50: cumulative = NO; break;
        case 51: cumulative = NO; break;
            
            // Corsair
        case 52: cumulative = NO; break;
        case 53: cumulative = NO; break;
        case 54: cumulative = NO; break;
            
            // Buccaneer
        case 55: cumulative = NO; break;
        case 56: cumulative = NO; break;
        case 57: cumulative = NO; break;
            
            // Sea Wolf
        case 58: cumulative = NO; break;
        case 59: cumulative = NO; break;
        case 60: cumulative = NO; break;
            
            // Swashbuckler
        default: cumulative = NO; break;
    }
    
    return cumulative;
     */
}

+ (uint)requiredNpcShipTypeForKey:(uint)key {
    uint shipType = 0;
    
    switch (key) {
#ifndef CHEEKY_LITE_VERSION
        case 4: shipType = SHIP_TYPE_TREASURE_FLEET; break;
        case 16: shipType = SHIP_TYPE_SILVER_TRAIN; break;
        case 34: shipType = SHIP_TYPE_TREASURE_FLEET; break;
        case 56: shipType = SHIP_TYPE_TREASURE_FLEET; break;
        case 65: shipType = SHIP_TYPE_SILVER_TRAIN; break;
#else
        case 13: shipType = SHIP_TYPE_TREASURE_FLEET; break;
#endif
        default: shipType = 0; break;
    }
    
    return shipType;
}

+ (uint)requiredAshTypeForKey:(uint)key {
    uint ashType = 0;
    
    switch (key) {
#ifndef CHEEKY_LITE_VERSION
        case 10: ashType = ASH_MOLTEN; break;
        case 24: ashType = ASH_SAVAGE; break;
        case 35: ashType = ASH_NOXIOUS; break;
        case 47: ashType = ASH_SAVAGE; break;
        case 55: ashType = ASH_MOLTEN; break;
        case 62: ashType = ASH_ABYSSAL; break;
        case 65: ashType = ASH_MOLTEN; break;
        case 69: ashType = ASH_SAVAGE; break;
        case 74: ashType = ASH_SAVAGE; break;
        case 82: ashType = ASH_ABYSSAL; break;
        case 85: ashType = ASH_SAVAGE; break;
        case 86: ashType = ASH_SAVAGE; break;
#else
        case 8: ashType = ASH_NOXIOUS; break;
        case 11: ashType = ASH_SAVAGE; break;
#endif
        default: ashType = 0; break;
    }
    
    return ashType;
}

@end
