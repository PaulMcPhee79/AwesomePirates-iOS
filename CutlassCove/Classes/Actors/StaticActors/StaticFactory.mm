//
//  StaticFactory.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 7/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "StaticFactory.h"
#import "ShipFactory.h" // TODO: find common file for createShapeForType
#import "BeachActor.h"
#import "TownActor.h"
#import "ActorDef.h"
#import "GameController.h"
#import "PlayfieldController.h"
#import "CCValidator.h"
#import "Globals.h"

@interface StaticFactory ()

- (ActorDef *)createActorDefWithKey:(NSString *)key;

@end

@implementation StaticFactory

static StaticFactory *staticFactory = nil;

+ (StaticFactory *)staticFactory {
	@synchronized(self) {
		if (staticFactory == nil) {
			staticFactory = [[self alloc] init];
		}
	}
	return staticFactory;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (staticFactory == nil) {
			staticFactory = [super allocWithZone:zone];
			return staticFactory;
		}
	}
	
	return nil;
}

- (id)copyWithZone:(NSZone *)zone {
	return self;
}

- (id)retain {
	return self;
}

- (NSUInteger)retainCount {
	return NSUIntegerMax;
}

- (oneway void)release {

}

- (id)autorelease {
	return self;
}

// ------------ End singleton junk -------------

- (ActorDef *)createBeachActorDef {
	return [self createActorDefWithKey:@"Beach"];
}

- (ActorDef *)createTownActorDef {
	return [self createActorDefWithKey:@"Town"];
}

- (ActorDef *)createActorDefWithKey:(NSString *)key {
	ActorDef *actorDef = new ActorDef;
	NSDictionary *dictionary = [Globals loadPlist:@"StaticActors"];
    
    BOOL isValid = [CCValidator isDataValidForDictionary:dictionary validators:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                [NSNumber numberWithInt:65295], @"Town",
                                                                                [NSNumber numberWithInt:209463], @"Beach",
                                                                                nil]];
#if 0    
    [CCValidator printValidatorsForDictionary:dictionary categoryName:@"StaticActors"];
#endif
    
    if (isValid == NO)
        [CCValidator reportInvalidData];
    
	dictionary = [dictionary objectForKey:key];
	NSDictionary *dict = [dictionary objectForKey:@"B2BodyDef"];
	float32 x = (float32)[(NSNumber *)[dict objectForKey:@"x"] floatValue];
	float32 y = (float32)[(NSNumber *)[dict objectForKey:@"y"] floatValue];
	float32 angle = (float32)[(NSNumber *)[dict objectForKey:@"rotation"] floatValue];
	
	x = RITMFX(x); y = RITMFY(y);
	
	actorDef->bd.position.Set(x,y);
	actorDef->bd.angle = angle;
	
	NSArray *array = [dictionary objectForKey:@"B2Fixtures"];
	
	delete [] actorDef->fds;
	actorDef->fixtureDefCount = array.count;
	actorDef->fds = new b2FixtureDef[actorDef->fixtureDefCount];
	
	int index = 0;
	
	for (dict in array) {
		NSDictionary *iter = [dict objectForKey:@"B2FixtureDef"];

		actorDef->fds[index].density = 0.0f;
		actorDef->fds[index].friction = (float32)[(NSNumber *)[iter objectForKey:@"friction"] floatValue];
		actorDef->fds[index].restitution = (float32)[(NSNumber *)[iter objectForKey:@"restitution"] floatValue];
		actorDef->fds[index].isSensor = ([(NSNumber *)[iter objectForKey:@"isSensor"] boolValue] == YES);
		
		iter = [dict objectForKey:@"B2Shape"];
		int shapeType = [(NSNumber *)[iter objectForKey:@"type"] intValue];
		actorDef->fds[index].shape = [[ShipFactory shipYard] createShapeForType:shapeType fromDictionary:iter];
		++index;
	}
	return actorDef;
}

- (void)dealloc {
	staticFactory = nil;
	[super dealloc];
}

@end
