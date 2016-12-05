//
//  GCTownAi.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 2/02/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "GCTownAi.h"


@implementation GCTownAi

@synthesize timeSinceLastShot,cannonballs;

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		timeSinceLastShot = [(NSNumber *)[decoder decodeObjectForKey:@"timeSinceLastShot"] doubleValue];
		cannonballs = [(NSArray *)[decoder decodeObjectForKey:@"cannonballs"] mutableCopy];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:[NSNumber numberWithDouble:timeSinceLastShot] forKey:@"timeSinceLastShot"];
	[coder encodeObject:cannonballs forKey:@"cannonballs"];
}

- (void)addCannonball:(GCCannonball *)cannonball {
	if (cannonballs == nil)
		cannonballs = [[NSMutableArray alloc] init];
	[cannonballs addObject:cannonball];
}

- (void)dealloc {
	[cannonballs release]; cannonballs = nil;
	[super dealloc];
}

@end
