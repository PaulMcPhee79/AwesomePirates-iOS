//
//  ActorFactory.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 8/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "ActorFactory.h"
#import "ActorDef.h"
#import "CCValidator.h"
#import "Globals.h"

const int kSharkHead = 0;
const int kSharkNose = 1;

const int kPool = 0;
const int kEye = 1;

@implementation ActorFactory

static ActorFactory *juilliard = nil;

+ (ActorFactory *)juilliard {
	@synchronized(self) {
		if (juilliard == nil) {
			juilliard = [[self alloc] init];
		}
	}
	return juilliard;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (juilliard == nil) {
			juilliard = [super allocWithZone:zone];
			return juilliard;
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

- (id)init {
	if (self = [super init]) {
#if 1 
        NSDictionary *raceTrackDict = [Globals loadPlist:@"RaceTrack"];

        BOOL isValid = [CCValidator isDataValidForDictionary:raceTrackDict validators:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                       [NSNumber numberWithInt:32568000], @"Buoys",
                                                                                       [NSNumber numberWithInt:6432000], @"Checkpoints",
                                                                                       [NSNumber numberWithInt:372000], @"FinishLine",
                                                                                       [NSNumber numberWithInt:1149034], @"DashDials",
                                                                                       nil]];
        
#if 0        
        [CCValidator printValidatorsForDictionary:raceTrackDict categoryName:@"RaceTrack"];
#endif
        
        if (isValid == NO)
            [CCValidator reportInvalidData];
#endif
	}
	return self;
}

- (ActorDef *)createLootDefinitionAtX:(float32)x y:(float32)y radius:(float32)radius {
	ActorDef *actorDef = new ActorDef;
	actorDef->bd.type = b2_dynamicBody;
	actorDef->bd.position.Set(x,y);
	
	b2CircleShape *shape = new b2CircleShape;
	shape->m_radius = radius;
	shape->m_p.Set(0.0f, 0.0f);
	
	delete [] actorDef->fds;
	actorDef->fixtureDefCount = 1;
	actorDef->fds = new b2FixtureDef[actorDef->fixtureDefCount];
	actorDef->fds->shape = shape;
	actorDef->fds->density = 1.0f;
	actorDef->fds->isSensor = true;
	actorDef->fds->filter.groupIndex = CGI_ENEMY_EXCLUDED;
    actorDef->fds->filter.categoryBits = COL_BIT_PLAYER_BUFF;
    actorDef->fds->filter.maskBits = COL_BIT_PLAYER_SHIP_HULL;
	
	return actorDef;
}

- (ActorDef *)createPoolDefinitionAtX:(float32)x y:(float32)y {
	ActorDef *actorDef = new ActorDef;
	actorDef->bd.type = b2_dynamicBody;
	actorDef->bd.position.Set(x,y);
	
	b2CircleShape *shape = new b2CircleShape;
	shape->m_radius = P2M(18.0f);
	shape->m_p.Set(0.0f, 0.0f);
	
	delete [] actorDef->fds;
	actorDef->fixtureDefCount = 1;
	actorDef->fds = new b2FixtureDef[actorDef->fixtureDefCount];
	actorDef->fds->shape = shape;
	actorDef->fds->density = 1.0f;
	actorDef->fds->isSensor = true;
	actorDef->fds->filter.groupIndex = CGI_PLAYER_EXCLUDED;
    actorDef->fds->filter.categoryBits = COL_BIT_VOODOO;
    actorDef->fds->filter.maskBits = (COL_BIT_VOODOO | COL_BIT_NPC_SHIP_STERN | COL_BIT_OVERBOARD);
	
	return actorDef;
}

- (ActorDef *)createTreasureDefinitionAtX:(float32)x y:(float32)y {
	ActorDef *actorDef = new ActorDef;
	actorDef->bd.type = b2_dynamicBody;
	actorDef->bd.position.Set(x,y);
	
	b2PolygonShape *shape = new b2PolygonShape;
	shape->SetAsBox(3,2,b2Vec2(0,0),0);
	
	delete [] actorDef->fds;
	actorDef->fixtureDefCount = 1;
	actorDef->fds = new b2FixtureDef[actorDef->fixtureDefCount];
	actorDef->fds->shape = shape;
	actorDef->fds->density = 1.0f;
	actorDef->fds->isSensor = true;
	actorDef->fds->filter.groupIndex = CGI_ENEMY_EXCLUDED;
	
	return actorDef;
}

- (ActorDef *)createTownDockDefinitionAtX:(float32)x y:(float32)y angle:(float32)angle {
	ActorDef *actorDef = new ActorDef;
	actorDef->bd.type = b2_staticBody;
	actorDef->bd.position.Set(x,y);
	actorDef->bd.angle = angle;
	
	b2CircleShape *shape = new b2CircleShape;
	shape->m_radius = P2M(28.0f);
	shape->m_p.Set(0.0f, 0.0f);
	
	delete [] actorDef->fds;
	actorDef->fixtureDefCount = 1;
	actorDef->fds = new b2FixtureDef[actorDef->fixtureDefCount];
	actorDef->fds->shape = shape;
	actorDef->fds->density = 0.0f;
	actorDef->fds->isSensor = true;
	//actorDef->fds->filter.groupIndex = CGI_PLAYER_EXCLUDED;
	
	return actorDef;
}

- (ActorDef *)createTreasureDockDefAtX:(float32)x y:(float32)y angle:(float32)angle {
	ActorDef *actorDef = new ActorDef;
	actorDef->bd.type = b2_staticBody;
	actorDef->bd.position.Set(x,y);
	
	b2PolygonShape *shape = new b2PolygonShape;
	shape->SetAsBox(8.0f,2.0f,b2Vec2(0.0f,0.0f),angle);
	
	delete [] actorDef->fds;
	actorDef->fixtureDefCount = 1;
	actorDef->fds = new b2FixtureDef[actorDef->fixtureDefCount];
	actorDef->fds->shape = shape;
	actorDef->fds->density = 0.0f;
	actorDef->fds->isSensor = true;
	actorDef->fds->filter.groupIndex = CGI_ENEMY_EXCLUDED;
	
	return actorDef;
}

- (ActorDef *)createCoveDockDefAtX:(float32)x y:(float32)y angle:(float32)angle {
	ActorDef *actorDef = new ActorDef;
	actorDef->bd.type = b2_staticBody;
	actorDef->bd.position.Set(x,y);
	
	b2PolygonShape *shape = new b2PolygonShape;
	shape->SetAsBox(4.0f,2.0f,b2Vec2(0.0f,0.0f),angle);
	
	delete [] actorDef->fds;
	actorDef->fixtureDefCount = 1;
	actorDef->fds = new b2FixtureDef[actorDef->fixtureDefCount];
	actorDef->fds->shape = shape;
	actorDef->fds->density = 0.0f;
	actorDef->fds->isSensor = true;
	actorDef->fds->filter.groupIndex = CGI_ENEMY_EXCLUDED;
	
	return actorDef;
}

- (ActorDef *)createSharkDefAtX:(float32)x y:(float32)y angle:(float32)angle {
	ActorDef *actorDef = new ActorDef;
	
	actorDef->bd.type = b2_dynamicBody;
	
	actorDef->bd.linearDamping = 5.0f;
	actorDef->bd.angularDamping = 3.0f;
	actorDef->bd.position.Set(x,y);
	actorDef->bd.angle = angle;
	
	delete [] actorDef->fds;
	actorDef->fixtureDefCount = 2;
	actorDef->fds = new b2FixtureDef[actorDef->fixtureDefCount];
	
	b2CircleShape *shape = new b2CircleShape;
	shape->m_radius = 2.0f;
	shape->m_p.Set(0.0f,0.0f);
	actorDef->fds[kSharkHead].density = 0.25f;
	actorDef->fds[kSharkHead].shape = shape;
	actorDef->fds[kSharkHead].isSensor = true;
    actorDef->fds[kSharkHead].filter.categoryBits = 0;
	
	shape = new b2CircleShape;
	shape->m_radius = P2M(4.0f);
	shape->m_p.Set(0.0f,2.0f);
	actorDef->fds[kSharkNose].density = 0.25f;
	actorDef->fds[kSharkNose].shape = shape;
	actorDef->fds[kSharkNose].isSensor = true;
	actorDef->fds[kSharkNose].filter.categoryBits = COL_BIT_SHARK;
    actorDef->fds[kSharkNose].filter.maskBits = COL_BIT_OVERBOARD;
    
	return actorDef;
}

- (ActorDef *)createPersonOverboardDefAtX:(float32)x y:(float32)y angle:(float32)angle {
	ActorDef *actorDef = new ActorDef;
	
	actorDef->bd.type = b2_dynamicBody;
	actorDef->bd.position.Set(x,y);
	actorDef->bd.angle = angle;
	actorDef->bd.linearDamping = 5.0f;
	actorDef->bd.angularDamping = 3.0f;
	
	delete [] actorDef->fds;
	actorDef->fixtureDefCount = 1;
	actorDef->fds = new b2FixtureDef[actorDef->fixtureDefCount];
	
	b2CircleShape *shape = new b2CircleShape;
	shape->m_radius = P2M(4.0f);
	shape->m_p.Set(0.0f,0.0f);
	actorDef->fds[0].density = 1.0f;
	actorDef->fds[0].shape = shape;
	actorDef->fds[0].isSensor = true;
	actorDef->fds[0].filter.categoryBits = COL_BIT_OVERBOARD;
    actorDef->fds[0].filter.maskBits = (COL_BIT_VOODOO | COL_BIT_CANNONBALL_CORE | COL_BIT_SHARK);
    
	return actorDef;
}

- (ActorDef *)createPowderKegDefAtX:(float32)x y:(float32)y angle:(float32)angle {
	ActorDef *actorDef = new ActorDef;
	
	actorDef->bd.type = b2_dynamicBody;
	actorDef->bd.position.Set(x,y);
	actorDef->bd.angle = angle;
	actorDef->bd.linearDamping = 5.0f;
	actorDef->bd.angularDamping = 3.0f;
	
	delete [] actorDef->fds;
	actorDef->fixtureDefCount = 1;
	actorDef->fds = new b2FixtureDef[actorDef->fixtureDefCount];
	
	b2CircleShape *shape = new b2CircleShape;
	shape->m_radius = P2M(4.0f);
	shape->m_p.Set(0.0f,0.0f);
	actorDef->fds[0].density = 1.0f;
	actorDef->fds[0].shape = shape;
	actorDef->fds[0].isSensor = true;
    actorDef->fds[0].filter.categoryBits = COL_BIT_VOODOO;
    actorDef->fds[0].filter.maskBits = (COL_BIT_VOODOO | COL_BIT_NPC_SHIP_HULL | COL_BIT_CANNONBALL_CORE | COL_BIT_OVERBOARD);
    
	// Need this to interact with itself
	//actorDef->fds[0].filter.groupIndex = CGI_PLAYER_EXCLUDED;
	return actorDef;
}

- (ActorDef *)createNetDefAtX:(float32)x y:(float32)y angle:(float32)angle scale:(float)scale {
	ActorDef *actorDef = new ActorDef;
	
	actorDef->bd.type = b2_dynamicBody;
	actorDef->bd.position.Set(x,y);
	actorDef->bd.angle = angle;
	actorDef->bd.linearDamping = 2;
	actorDef->bd.angularDamping = 1;
	
	delete [] actorDef->fds;
	actorDef->fixtureDefCount = 2;
	actorDef->fds = new b2FixtureDef[actorDef->fixtureDefCount];
	
	// Shrunk Fixture
	b2CircleShape *shape = new b2CircleShape;
	shape->m_radius = P2M(65.0f * 0.15f);
	shape->m_p.Set(0.0f,0.0f);
	actorDef->fds[0].density = 0.1f;
	actorDef->fds[0].shape = shape;
	actorDef->fds[0].isSensor = true;
	actorDef->fds[0].filter.groupIndex = CGI_PLAYER_EXCLUDED; 
	actorDef->fds[0].filter.categoryBits = COL_BIT_VOODOO;
    actorDef->fds[0].filter.maskBits = (COL_BIT_VOODOO | COL_BIT_NPC_SHIP_HULL);
    
	// Full-size fixture
	shape = new b2CircleShape;
	shape->m_radius = P2M(65.0f * scale);
	shape->m_p.Set(0.0f,0.0f);
	actorDef->fds[1].density = 0.1f;
	actorDef->fds[1].shape = shape;
	actorDef->fds[1].isSensor = true;
	actorDef->fds[1].filter.groupIndex = CGI_PLAYER_EXCLUDED;
    actorDef->fds[1].filter.categoryBits = COL_BIT_VOODOO;
    actorDef->fds[1].filter.maskBits = (COL_BIT_VOODOO | COL_BIT_NPC_SHIP_HULL);
	return actorDef;
}

- (ActorDef *)createBrandySlickDefAtX:(float32)x y:(float32)y angle:(float32)angle scale:(float)scale {
	ActorDef *actorDef = new ActorDef;
	
	actorDef->bd.type = b2_dynamicBody;
	actorDef->bd.position.Set(x,y);
	actorDef->bd.angle = angle;
	
	delete [] actorDef->fds;
	actorDef->fixtureDefCount = 1;
	actorDef->fds = new b2FixtureDef[actorDef->fixtureDefCount];
	
	b2PolygonShape *shape = new b2PolygonShape;
	shape->SetAsBox(0.75f,7.25f,b2Vec2(0.0f,0.0f),0);
	actorDef->fds[0].density = 1.0f;
	actorDef->fds[0].shape = shape;
	actorDef->fds[0].isSensor = true;
    actorDef->fds[0].filter.categoryBits = COL_BIT_VOODOO;
    actorDef->fds[0].filter.maskBits = (COL_BIT_VOODOO | COL_BIT_NPC_SHIP_STERN | COL_BIT_CANNONBALL_CORE | COL_BIT_OVERBOARD);
    
	// Need this to interact with powder kegs, so can't put in same exclusion group. Need to use collision bitmaps...
	//actorDef->fds[0].filter.groupIndex = CGI_PLAYER_EXCLUDED;
	return actorDef;
}

- (ActorDef *)createTempestDefAtX:(float32)x y:(float32)y angle:(float32)angle {
	ActorDef *actorDef = new ActorDef;
	
	actorDef->bd.type = b2_dynamicBody;
	actorDef->bd.position.Set(x,y);
	actorDef->bd.angle = angle;
	
	delete [] actorDef->fds;
	actorDef->fixtureDefCount = 1;
	actorDef->fds = new b2FixtureDef[actorDef->fixtureDefCount];
	
	b2CircleShape *shape = new b2CircleShape;
	shape->m_radius = P2M(8.0f);
	shape->m_p.Set(0.0f,0.0f);
	actorDef->fds[0].density = 1.0f;
	actorDef->fds[0].shape = shape;
	actorDef->fds[0].isSensor = true;
    actorDef->fds[0].filter.categoryBits = COL_BIT_VOODOO;
    actorDef->fds[0].filter.maskBits = (COL_BIT_NPC_SHIP_HULL | COL_BIT_VOODOO | COL_BIT_OVERBOARD);
	return actorDef;
}

- (ActorDef *)createWhirlpoolDefAtX:(float32)x y:(float32)y angle:(float32)angle {
	ActorDef *actorDef = new ActorDef;
	actorDef->bd.position.Set(x,y);
	
	delete [] actorDef->fds;
	actorDef->fixtureDefCount = 2;
	actorDef->fds = new b2FixtureDef[actorDef->fixtureDefCount];
	
	b2CircleShape *shape = new b2CircleShape;
	shape->m_radius = P2M(160.0f);
	shape->m_p.Set(0.0f,0.0f);
	actorDef->fds[kPool].density = 1.0f;
	actorDef->fds[kPool].shape = shape;
	actorDef->fds[kPool].isSensor = true;
    actorDef->fds[kPool].filter.categoryBits = COL_BIT_VOODOO;
    actorDef->fds[kPool].filter.maskBits = (COL_BIT_NPC_SHIP_HULL | COL_BIT_VOODOO | COL_BIT_OVERBOARD);
	
	shape = new b2CircleShape;
	shape->m_radius = 0.75f;
	shape->m_p.Set(0.0f,0.0f);
	actorDef->fds[kEye].density = 1.0f;
	actorDef->fds[kEye].shape = shape;
	actorDef->fds[kEye].isSensor = true;
	actorDef->fds[kEye].filter.categoryBits = COL_BIT_VOODOO;
    actorDef->fds[kEye].filter.maskBits = (COL_BIT_NPC_SHIP_HULL | COL_BIT_VOODOO | COL_BIT_OVERBOARD);
    
	return actorDef;
}

- (ActorDef *)createRaceTrackDefWithDictionary:(NSDictionary *)dictionary {
	NSArray *checkpoints = (NSArray *)[dictionary objectForKey:@"Checkpoints"];
	assert(checkpoints != nil);
	
	int i = 0;
	ActorDef *actorDef = new ActorDef;
	actorDef->bd.position.Set(0,0);
	
	delete [] actorDef->fds;
	actorDef->fixtureDefCount = checkpoints.count + 1; // +1 for finishLine
	actorDef->fds = new b2FixtureDef[actorDef->fixtureDefCount];
	
	ResOffset *offset = [RESM itemOffsetWithAlignment:RACenter];
	
	for (i = 0; i < actorDef->fixtureDefCount - 1; ++i) {
		NSDictionary *checkpoint = (NSDictionary *)[checkpoints objectAtIndex:i];
		float x = [(NSNumber *)[checkpoint objectForKey:@"x"] floatValue];
		float y = [(NSNumber *)[checkpoint objectForKey:@"y"] floatValue];
		
		x += offset.x; y += offset.y;
		
		b2CircleShape *shape = new b2CircleShape;
		shape->m_radius = P2M(20.0f);
		shape->m_p.Set(P2MX(x),P2MY(y));
		actorDef->fds[i].density = 0.0f;
		actorDef->fds[i].shape = shape;
		actorDef->fds[i].isSensor = true;
        actorDef->fds[i].filter.categoryBits = COL_BIT_PLAYER_BUFF;
        actorDef->fds[i].filter.maskBits = COL_BIT_PLAYER_SHIP_HULL;
	}
	
	NSDictionary *finishLine = (NSDictionary *)[dictionary objectForKey:@"FinishLine"];
	float x = [(NSNumber *)[finishLine objectForKey:@"x"] floatValue];
	float y = [(NSNumber *)[finishLine objectForKey:@"y"] floatValue];
	float angle = [(NSNumber *)[finishLine objectForKey:@"rotation"] floatValue];
	
	x += offset.x; y += offset.y;
	
	b2PolygonShape *shape = new b2PolygonShape;
	shape->SetAsBox(P2M(20.0f),P2M(8.0f),b2Vec2(P2MX(x),P2MY(y)),angle);
	actorDef->fds[i].density = 0.0f;
	actorDef->fds[i].shape = shape;
	actorDef->fds[i].isSensor = true;
    actorDef->fds[i].filter.categoryBits = COL_BIT_PLAYER_BUFF;
    actorDef->fds[i].filter.maskBits = COL_BIT_PLAYER_SHIP_HULL;

	return actorDef;
}

- (void)dealloc {
	juilliard = nil;
	[super dealloc];
}

@end
