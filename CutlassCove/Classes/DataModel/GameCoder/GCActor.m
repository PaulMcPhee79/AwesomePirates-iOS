//
//  GCActor.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 31/01/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "GCActor.h"
#import "Prisoner.h"

@implementation GCActor

@synthesize key,actorId,fleetEscort,fleetID,duelState,x,y,rotation,dest,prisoner,cannonballs,enemyIds;
@dynamic firstEnemyId;

- (id)initWithKey:(NSString *)actorKey {
	if (self = [super init]) {
		key = [actorKey copy];
		actorId = 0;
		fleetEscort = 0;
        fleetID = 0;
		duelState = 0;
		prisoner = nil;
		cannonballs = nil;
		enemyIds = nil;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		key = [(NSString *)[decoder decodeObjectForKey:@"key"] copy];
		actorId = [(NSNumber *)[decoder decodeObjectForKey:@"actorId"] intValue];
		fleetEscort = [(NSNumber *)[decoder decodeObjectForKey:@"fleetEscort"] unsignedIntValue];
        fleetID = [(NSNumber *)[decoder decodeObjectForKey:@"fleetID"] unsignedIntValue];
		duelState = [(NSNumber *)[decoder decodeObjectForKey:@"duelState"] intValue];
		x = [(NSNumber *)[decoder decodeObjectForKey:@"x"] floatValue];
		y = [(NSNumber *)[decoder decodeObjectForKey:@"y"] floatValue];
		rotation = [(NSNumber *)[decoder decodeObjectForKey:@"rotation"] floatValue];
		dest = [(GCDestination *)[decoder decodeObjectForKey:@"dest"] retain];
		prisoner = [(Prisoner *)[decoder decodeObjectForKey:@"prisoner"] retain];
		cannonballs = [(NSArray *)[decoder decodeObjectForKey:@"cannonballs"] mutableCopy];
		enemyIds = [(NSArray *)[decoder decodeObjectForKey:@"enemyIds"] mutableCopy];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:key forKey:@"key"];
	[coder encodeObject:[NSNumber numberWithInt:actorId] forKey:@"actorId"];
	[coder encodeObject:[NSNumber numberWithUnsignedInt:fleetEscort] forKey:@"fleetEscort"];
    [coder encodeObject:[NSNumber numberWithUnsignedInt:fleetID] forKey:@"fleetID"];
	[coder encodeObject:[NSNumber numberWithInt:duelState] forKey:@"duelState"];
	[coder encodeObject:[NSNumber numberWithFloat:x] forKey:@"x"];
	[coder encodeObject:[NSNumber numberWithFloat:y] forKey:@"y"];
	[coder encodeObject:[NSNumber numberWithFloat:rotation] forKey:@"rotation"];
	[coder encodeObject:dest forKey:@"dest"];
	[coder encodeObject:prisoner forKey:@"prisoner"];
	[coder encodeObject:cannonballs forKey:@"cannonballs"];
	[coder encodeObject:enemyIds forKey:@"enemyIds"];
}

- (void)addCannonball:(GCCannonball *)cannonball {
	if (cannonballs == nil)
		cannonballs = [[NSMutableArray alloc] init];
	[cannonballs addObject:cannonball];
}

- (void)addEnemyId:(int)enemyId {
	if (enemyIds == nil)
		enemyIds = [[NSMutableArray alloc] init];
	[enemyIds addObject:[NSNumber numberWithInt:enemyId]];
}

- (int)firstEnemyId {
	int enemyId = 0;
	
	if (enemyIds != nil && enemyIds.count > 0)
		enemyId = [(NSNumber *)[enemyIds objectAtIndex:0] intValue];
	return enemyId;
}

- (void)dealloc {
	[key release]; key = nil;
	[dest release]; dest = nil;
	[prisoner release]; prisoner = nil;
	[cannonballs release]; cannonballs = nil;
	[enemyIds release]; enemyIds = nil;
	[super dealloc];
}

@end


@implementation GCDestination

@synthesize finishIsDest,spawnPlaneStart,spawnPlaneFinish,seaLaneA,seaLaneB,adjustedSeaLaneC;

- (id)init {
	if (self = [super init]) {
		finishIsDest = NO;
		spawnPlaneStart = spawnPlaneFinish = -1;
		seaLaneA = seaLaneB = -1;
		adjustedSeaLaneC = nil;
	}
	return self;
}

- (void)dealloc {
	[adjustedSeaLaneC release]; adjustedSeaLaneC = nil;
	[super dealloc];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		finishIsDest = [(NSNumber *)[decoder decodeObjectForKey:@"finishIsDest"] boolValue];
		spawnPlaneStart = [(NSNumber *)[decoder decodeObjectForKey:@"spawnPlaneStart"] intValue];
		spawnPlaneFinish = [(NSNumber *)[decoder decodeObjectForKey:@"spawnPlaneFinish"] intValue];
		seaLaneA = [(NSNumber *)[decoder decodeObjectForKey:@"seaLaneA"] intValue];
		seaLaneB = [(NSNumber *)[decoder decodeObjectForKey:@"seaLaneB"] intValue];
		adjustedSeaLaneC = nil;
		
		id adjX = [decoder decodeObjectForKey:@"adjX"];
		id adjY = [decoder decodeObjectForKey:@"adjY"];
		
		if (adjX && adjY)
			adjustedSeaLaneC = [[SPPoint alloc] initWithX:[(NSNumber *)adjX floatValue] y:[(NSNumber *)adjY floatValue]];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:[NSNumber numberWithBool:finishIsDest] forKey:@"finishIsDest"];
	[coder encodeObject:[NSNumber numberWithInt:spawnPlaneStart] forKey:@"spawnPlaneStart"];
	[coder encodeObject:[NSNumber numberWithInt:spawnPlaneFinish] forKey:@"spawnPlaneFinish"];
	[coder encodeObject:[NSNumber numberWithInt:seaLaneA] forKey:@"seaLaneA"];
	[coder encodeObject:[NSNumber numberWithInt:seaLaneB] forKey:@"seaLaneB"];
	
	if (adjustedSeaLaneC != nil) {
		[coder encodeObject:[NSNumber numberWithFloat:adjustedSeaLaneC.x] forKey:@"adjX"];
		[coder encodeObject:[NSNumber numberWithFloat:adjustedSeaLaneC.y] forKey:@"adjY"];
	}
}

@end
