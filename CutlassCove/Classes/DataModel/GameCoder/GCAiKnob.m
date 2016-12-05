//
//  GCAiKnob.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 31/01/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "GCAiKnob.h"


@implementation GCAiKnob

@synthesize aiKnob;

+ (GCAiKnob *)gcAiKnob {
	return [[[GCAiKnob alloc] init] autorelease];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		aiKnob.merchantShipsMin = [(NSNumber *)[decoder decodeObjectForKey:@"aiKnob.merchantShipsMin"] intValue];
		aiKnob.merchantShipsMax = [(NSNumber *)[decoder decodeObjectForKey:@"aiKnob.merchantShipsMax"] intValue];
		aiKnob.pirateShipsMax = [(NSNumber *)[decoder decodeObjectForKey:@"aiKnob.pirateShipsMax"] intValue];
		aiKnob.navyShipsMax = [(NSNumber *)[decoder decodeObjectForKey:@"aiKnob.navyShipsMax"] intValue];
		aiKnob.merchantShipsChance = [(NSNumber *)[decoder decodeObjectForKey:@"aiKnob.merchantShipsChance"] intValue];
		aiKnob.pirateShipsChance = [(NSNumber *)[decoder decodeObjectForKey:@"aiKnob.pirateShipsChance"] intValue];
		aiKnob.navyShipsChance = [(NSNumber *)[decoder decodeObjectForKey:@"aiKnob.navyShipsChance"] intValue];
		aiKnob.specialShipsChance = [(NSNumber *)[decoder decodeObjectForKey:@"aiKnob.specialShipsChance"] intValue];
		aiKnob.fleetShouldSpawn = [(NSNumber *)[decoder decodeObjectForKey:@"aiKnob.fleetShouldSpawn"] boolValue];
		aiKnob.fleetTimer = [(NSNumber *)[decoder decodeObjectForKey:@"aiKnob.fleetTimer"] doubleValue];
		aiKnob.difficulty = [(NSNumber *)[decoder decodeObjectForKey:@"aiKnob.difficulty"] intValue];
		aiKnob.difficultyIncrement = [(NSNumber *)[decoder decodeObjectForKey:@"aiKnob.difficultyIncrement"] intValue];
		aiKnob.difficultyFactor = [(NSNumber *)[decoder decodeObjectForKey:@"aiKnob.difficultyFactor"] floatValue];
		aiKnob.aiModifier = [(NSNumber *)[decoder decodeObjectForKey:@"aiKnob.aiModifier"] floatValue];
		aiKnob.stateCeiling = [(NSNumber *)[decoder decodeObjectForKey:@"aiKnob.stateCeiling"] intValue];
		aiKnob.state = [(NSNumber *)[decoder decodeObjectForKey:@"aiKnob.state"] intValue];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:[NSNumber numberWithInt:aiKnob.merchantShipsMin] forKey:@"aiKnob.merchantShipsMin"];
	[coder encodeObject:[NSNumber numberWithInt:aiKnob.merchantShipsMax] forKey:@"aiKnob.merchantShipsMax"];
	[coder encodeObject:[NSNumber numberWithInt:aiKnob.pirateShipsMax] forKey:@"aiKnob.pirateShipsMax"];
	[coder encodeObject:[NSNumber numberWithInt:aiKnob.navyShipsMax] forKey:@"aiKnob.navyShipsMax"];
	[coder encodeObject:[NSNumber numberWithInt:aiKnob.merchantShipsChance] forKey:@"aiKnob.merchantShipsChance"];
	[coder encodeObject:[NSNumber numberWithInt:aiKnob.pirateShipsChance] forKey:@"aiKnob.pirateShipsChance"];
	[coder encodeObject:[NSNumber numberWithInt:aiKnob.navyShipsChance] forKey:@"aiKnob.navyShipsChance"];
	[coder encodeObject:[NSNumber numberWithInt:aiKnob.specialShipsChance] forKey:@"aiKnob.specialShipsChance"];
	[coder encodeObject:[NSNumber numberWithBool:aiKnob.fleetShouldSpawn] forKey:@"aiKnob.fleetShouldSpawn"];
	[coder encodeObject:[NSNumber numberWithDouble:aiKnob.fleetTimer] forKey:@"aiKnob.fleetTimer"];
	[coder encodeObject:[NSNumber numberWithInt:aiKnob.difficulty] forKey:@"aiKnob.difficulty"];
	[coder encodeObject:[NSNumber numberWithInt:aiKnob.difficultyIncrement] forKey:@"aiKnob.difficultyIncrement"];
	[coder encodeObject:[NSNumber numberWithFloat:aiKnob.difficultyFactor] forKey:@"aiKnob.difficultyFactor"];
	[coder encodeObject:[NSNumber numberWithFloat:aiKnob.aiModifier] forKey:@"aiKnob.aiModifier"];
	[coder encodeObject:[NSNumber numberWithInt:aiKnob.stateCeiling] forKey:@"aiKnob.stateCeiling"];
	[coder encodeObject:[NSNumber numberWithInt:aiKnob.state] forKey:@"aiKnob.state"];
}

@end
