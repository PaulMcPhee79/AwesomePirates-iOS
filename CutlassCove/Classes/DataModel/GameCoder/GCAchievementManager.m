//
//  GCAchievementManager.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 31/01/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "GCAchievementManager.h"


@implementation GCAchievementManager

@synthesize consecutiveCannonballsHit,friendlyFires,kabooms,slimerCount,comboMultiplier,comboMultiplierMax,comboBonusCharges,displayQueue;

+ (GCAchievementManager *)gcAchievementManager {
	return [[[GCAchievementManager alloc] init] autorelease];
}

- (id)init {
	if (self = [super init]) {
		consecutiveCannonballsHit = 0;
		friendlyFires = 0;
		kabooms = 0;
        slimerCount = 0;
		comboMultiplierMax = 0;
		comboMultiplier = 0;
		comboBonusCharges = 0;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		consecutiveCannonballsHit = [(NSNumber *)[decoder decodeObjectForKey:@"consecutiveCannonballsHit"] unsignedIntValue];
		friendlyFires = [(NSNumber *)[decoder decodeObjectForKey:@"friendlyFires"] unsignedIntValue];
		kabooms = [(NSNumber *)[decoder decodeObjectForKey:@"kabooms"] unsignedIntValue];
        slimerCount = [(NSNumber *)[decoder decodeObjectForKey:@"slimerCount"] unsignedIntValue];
		comboMultiplierMax = [(NSNumber *)[decoder decodeObjectForKey:@"comboMultiplierMax"] intValue];
		comboMultiplier = [(NSNumber *)[decoder decodeObjectForKey:@"comboMultiplier"] intValue];
		comboBonusCharges = [(NSNumber *)[decoder decodeObjectForKey:@"comboBonusCharges"] unsignedIntValue];
		displayQueue = [(NSArray *)[decoder decodeObjectForKey:@"displayQueue"] retain];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:[NSNumber numberWithUnsignedInt:consecutiveCannonballsHit] forKey:@"consecutiveCannonballsHit"];
	[coder encodeObject:[NSNumber numberWithUnsignedInt:friendlyFires] forKey:@"friendlyFires"];
	[coder encodeObject:[NSNumber numberWithUnsignedInt:kabooms] forKey:@"kabooms"];
    [coder encodeObject:[NSNumber numberWithUnsignedInt:slimerCount] forKey:@"slimerCount"];
	[coder encodeObject:[NSNumber numberWithInt:comboMultiplierMax] forKey:@"comboMultiplierMax"];
	[coder encodeObject:[NSNumber numberWithInt:comboMultiplier] forKey:@"comboMultiplier"];
	[coder encodeObject:[NSNumber numberWithUnsignedInt:comboBonusCharges] forKey:@"comboBonusCharges"];
	[coder encodeObject:displayQueue forKey:@"displayQueue"];
}

- (void)dealloc {
	[displayQueue release]; displayQueue = nil;
	[super dealloc];
}

@end
