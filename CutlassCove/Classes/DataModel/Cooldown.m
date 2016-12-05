//
//  Cooldown.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 10/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Cooldown.h"


@implementation Cooldown

@synthesize gcd = mGcd;
@synthesize timeRemaining = mTimeRemaining;
@synthesize timeTotal = mTimeTotal;
@dynamic ratioRemaining,ratioPassed;

- (id)init {
	if (self = [super init]) {
		mGcd = NO;
		mTimeRemaining = 0;
		mTimeTotal = 0;
	}
	return self;
}

- (double)ratioRemaining {
	double ratio = 0;
	
	if (mTimeTotal > 0)
		ratio = mTimeRemaining / mTimeTotal;
	return ratio;
}

- (double)ratioPassed {
	double ratio = 0;
	
	if (mTimeTotal > 0)
		ratio = (mTimeTotal - mTimeRemaining) / mTimeTotal;
	return ratio;
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		mGcd = [(NSNumber *)[decoder decodeObjectForKey:@"gcd"] boolValue];
		mTimeRemaining = [(NSNumber *)[decoder decodeObjectForKey:@"timeRemaining"] doubleValue];
		mTimeTotal = [(NSNumber *)[decoder decodeObjectForKey:@"timeTotal"] doubleValue];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:[NSNumber numberWithBool:mGcd] forKey:@"gcd"];
	[coder encodeObject:[NSNumber numberWithDouble:mTimeRemaining] forKey:@"timeRemaining"];
	[coder encodeObject:[NSNumber numberWithDouble:mTimeTotal] forKey:@"timeTotal"];
}

@end
