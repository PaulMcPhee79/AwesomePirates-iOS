//
//  GCCannonball.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 2/02/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "GCCannonball.h"
#import "Cannonball.h"


@implementation GCCannonball

@synthesize shotType,groupId,ricochetCount,infamyBonus,bore,x,y,velX,velY,trajectory,distanceRemaining;

- (id)initWithCannonball:(Cannonball *)cannonball {
	if (self = [super init]) {
		shotType = cannonball.shotType;
		groupId = cannonball.cannonballGroupId;
		ricochetCount = cannonball.ricochetCount;
		infamyBonus = [cannonball.infamyBonus retain];
		bore = cannonball.bore;
		
		b2Vec2 loc = cannonball.body->GetPosition();
		x = loc.x;
		y = loc.y;
		
		b2Vec2 vel = cannonball.body->GetLinearVelocity();
		velX = vel.x;
		velY = vel.y;
		
		trajectory = cannonball.trajectory;
		distanceRemaining = cannonball.distanceRemaining;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		shotType = [(NSString *)[decoder decodeObjectForKey:@"shotType"] copy];
		groupId = [(NSNumber *)[decoder decodeObjectForKey:@"groupId"] intValue];
		ricochetCount = [(NSNumber *)[decoder decodeObjectForKey:@"ricochetCount"] unsignedIntValue];
		infamyBonus = [[decoder decodeObjectForKey:@"infamyBonus"] retain];
		bore = [(NSNumber *)[decoder decodeObjectForKey:@"bore"] floatValue];
		x = [(NSNumber *)[decoder decodeObjectForKey:@"x"] floatValue];
		y = [(NSNumber *)[decoder decodeObjectForKey:@"y"] floatValue];
		velX = [(NSNumber *)[decoder decodeObjectForKey:@"velX"] floatValue];
		velY = [(NSNumber *)[decoder decodeObjectForKey:@"velY"] floatValue];
		trajectory = [(NSNumber *)[decoder decodeObjectForKey:@"trajectory"] floatValue];
		distanceRemaining = [(NSNumber *)[decoder decodeObjectForKey:@"distanceRemaining"] floatValue];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:shotType forKey:@"shotType"];
	[coder encodeObject:[NSNumber numberWithInt:groupId] forKey:@"groupId"];
	[coder encodeObject:[NSNumber numberWithUnsignedInt:ricochetCount] forKey:@"ricochetCount"];
	[coder encodeObject:infamyBonus forKey:@"infamyBonus"];
	[coder encodeObject:[NSNumber numberWithFloat:bore] forKey:@"bore"];
	[coder encodeObject:[NSNumber numberWithFloat:x] forKey:@"x"];
	[coder encodeObject:[NSNumber numberWithFloat:y] forKey:@"y"];
	[coder encodeObject:[NSNumber numberWithFloat:velX] forKey:@"velX"];
	[coder encodeObject:[NSNumber numberWithFloat:velY] forKey:@"velY"];
	[coder encodeObject:[NSNumber numberWithFloat:trajectory] forKey:@"trajectory"];
	[coder encodeObject:[NSNumber numberWithFloat:distanceRemaining] forKey:@"distanceRemaining"];
}

- (CannonballInfamyBonus *)infamyBonus {
	return [[infamyBonus copy] autorelease];
}

- (void)dealloc {
	[shotType release]; shotType = nil;
	[infamyBonus release]; infamyBonus = nil;
	[super dealloc];
}

@end
