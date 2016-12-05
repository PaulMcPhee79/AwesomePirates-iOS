//
//  GCVoodoo.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 31/01/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "GCVoodoo.h"


@implementation GCVoodoo

@synthesize bitmapID,bitmapSettings,x,y,rotation,durationRemaining,collidableRadiusFactor;

- (id)init {
	if (self = [super init]) {
		bitmapID = 0;
		bitmapSettings = 0;
		x = 0;
		y = 0;
		rotation = 0;
		durationRemaining = 0.1f;
		collidableRadiusFactor = 1.0f;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		bitmapID = [(NSNumber *)[decoder decodeObjectForKey:@"bitmapID"] unsignedIntValue];
		bitmapSettings = [(NSNumber *)[decoder decodeObjectForKey:@"bitmapSettings"] unsignedIntValue];
		x = [(NSNumber *)[decoder decodeObjectForKey:@"x"] floatValue];
		y = [(NSNumber *)[decoder decodeObjectForKey:@"y"] floatValue];
		rotation = [(NSNumber *)[decoder decodeObjectForKey:@"rotation"] floatValue];
		durationRemaining = [(NSNumber *)[decoder decodeObjectForKey:@"durationRemaining"] floatValue];
		collidableRadiusFactor = [(NSNumber *)[decoder decodeObjectForKey:@"collidableRadiusFactor"] floatValue];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:[NSNumber numberWithUnsignedInt:bitmapID] forKey:@"bitmapID"];
	[coder encodeObject:[NSNumber numberWithUnsignedInt:bitmapSettings] forKey:@"bitmapSettings"];
	[coder encodeObject:[NSNumber numberWithFloat:x] forKey:@"x"];
	[coder encodeObject:[NSNumber numberWithFloat:y] forKey:@"y"];
	[coder encodeObject:[NSNumber numberWithFloat:rotation] forKey:@"rotation"];
	[coder encodeObject:[NSNumber numberWithFloat:durationRemaining] forKey:@"durationRemaining"];
	[coder encodeObject:[NSNumber numberWithFloat:collidableRadiusFactor] forKey:@"collidableRadiusFactor"];
}

@end
