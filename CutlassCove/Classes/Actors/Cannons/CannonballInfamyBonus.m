//
//  CannonballInfamyBonus.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 6/09/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "CannonballInfamyBonus.h"


@implementation CannonballInfamyBonus

@synthesize procType,procMultiplier,procAddition,ricochetBonus,ricochetAddition,ricochetMultiplier,miscBitmap;

+ (CannonballInfamyBonus *)cannonballInfamyBonus {
	return [[[CannonballInfamyBonus alloc] init] autorelease];
}

- (id)init {
	if (self = [super init]) {
		procType = 0;
		procMultiplier = 1;
		procAddition = 0;
		
		ricochetBonus = 0;
		ricochetAddition = 0;
		ricochetMultiplier = 1;
        
        miscBitmap = 0;
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	CannonballInfamyBonus *copy = [[[self class] allocWithZone:zone] init];
	copy.procType = self.procType;
	copy.procMultiplier = self.procMultiplier;
	copy.procAddition = self.procAddition;
	
	copy.ricochetBonus = self.ricochetBonus;
	copy.ricochetAddition = self.ricochetAddition;
	copy.ricochetMultiplier = self.ricochetMultiplier;
    
    copy.miscBitmap = self.miscBitmap;

	return copy;
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		procType = [(NSNumber *)[decoder decodeObjectForKey:@"procType"] unsignedIntValue];
		procMultiplier = [(NSNumber *)[decoder decodeObjectForKey:@"procMultiplier"] intValue];
		procAddition = [(NSNumber *)[decoder decodeObjectForKey:@"procAddition"] intValue];
		
		ricochetBonus = [(NSNumber *)[decoder decodeObjectForKey:@"ricochetBonus"] intValue];
		ricochetAddition = [(NSNumber *)[decoder decodeObjectForKey:@"ricochetAddition"] intValue];
		ricochetMultiplier = [(NSNumber *)[decoder decodeObjectForKey:@"ricochetMultiplier"] floatValue];
        
        miscBitmap = [(NSNumber *)[decoder decodeObjectForKey:@"miscBitmap"] unsignedIntValue];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:[NSNumber numberWithUnsignedInt:procType] forKey:@"procType"];
	[coder encodeObject:[NSNumber numberWithInt:procMultiplier] forKey:@"procMultiplier"];
	[coder encodeObject:[NSNumber numberWithInt:procAddition] forKey:@"procAddition"];
	
	[coder encodeObject:[NSNumber numberWithInt:ricochetBonus] forKey:@"ricochetBonus"];
	[coder encodeObject:[NSNumber numberWithInt:ricochetAddition] forKey:@"ricochetAddition"];
	[coder encodeObject:[NSNumber numberWithFloat:ricochetMultiplier] forKey:@"ricochetMultiplier"];
    
    [coder encodeObject:[NSNumber numberWithUnsignedInt:miscBitmap] forKey:@"miscBitmap"];
}

@end
