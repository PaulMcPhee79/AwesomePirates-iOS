//
//  GCShipDetails.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 30/01/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "GCShipDetails.h"

@implementation GCShipDetails

@synthesize condition,prisoners;

+ (GCShipDetails *)gcShipDetails {
	return [[[GCShipDetails alloc] init] autorelease];
}

- (id)init {
	if (self = [super init]) {
		condition = 1; // Set to 1 so ship does not sink immediately on load in case of semantic error resulting in properties not being set)
		prisoners = nil;
	}
	return self;
}

- (void)addPrisoner:(Prisoner *)aPrisoner {
	if (prisoners == nil)
		prisoners = [[NSMutableDictionary alloc] init];
	[prisoners setObject:aPrisoner forKey:aPrisoner.name];
}

- (void)setPrisoners:(NSDictionary *)prisonerDict {
	if (prisoners != nil)
		[prisoners release];
	prisoners = [[NSMutableDictionary alloc] initWithDictionary:prisonerDict];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		condition = [(NSNumber *)[decoder decodeObjectForKey:@"condition"] intValue];
		prisoners = [[NSMutableDictionary alloc] initWithDictionary:(NSDictionary *)[decoder decodeObjectForKey:@"prisoners"]];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:[NSNumber numberWithInt:condition] forKey:@"condition"];
	[coder encodeObject:prisoners forKey:@"prisoners"];
}

- (void)dealloc {
	[prisoners release]; prisoners = nil;
	[super dealloc];
}

@end
