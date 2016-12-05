//
//  DockActor.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 13/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "DockActor.h"
#import "ActorDef.h"
#import "SPQuad_Extension.h"
#import "GameController.h"
#import "PlayfieldController.h"
#import "NpcShip.h"
#import "Globals.h"

#define DOCK_ACTORS_DEBUG_ENABLED 0

@interface DockActor ()

- (void)setupActorCostume;
- (BOOL)ignoresContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact;

@end

@implementation DockActor

- (id)initWithActorDef:(ActorDef *)def {
	if (self = [super initWithActorDef:def]) {
		mCategory = CAT_PF_PICKUPS;
		self.x = self.px;
		self.y = self.py;
#if DOCK_ACTORS_DEBUG_ENABLED
		[self setupActorCostume]; // TODO: For testing visualisation. Remove for release.
#endif
    }
    return self;
}

- (id)init {
	ActorDef actorDef;
	return [self initWithActorDef:&actorDef];
}

- (void)setupActorCostume {
	b2Fixture *fixtures = mBody->GetFixtureList();
	b2PolygonShape *shape = (b2PolygonShape *)fixtures->GetShape();
	
	
	if (shape->GetVertexCount() == 4) {
		SPQuad *quad = [SPQuad quadWithWidth:32.0f height:32.0f];
		b2Vec2 *vertices = shape->m_vertices;
		float *quadCoords = quad.vertexCoords;
		
		// Map Box2D b2Polygon to Sparrow SPQuad
		quadCoords[0] = vertices[1].x * 8.0f;
		quadCoords[1] = -vertices[1].y * 8.0f;
		quadCoords[2] = vertices[0].x * 8.0f;
		quadCoords[3] = -vertices[0].y * 8.0f;
		quadCoords[4] = vertices[2].x * 8.0f;
		quadCoords[5] = -vertices[2].y * 8.0f;
		quadCoords[6] = vertices[3].x * 8.0f;
		quadCoords[7] = -vertices[3].y * 8.0f;
		quad.color = 0x00ff00;
		quad.alpha = 0.5f;
		[self addChild:quad];
	}
}

- (BOOL)ignoresContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
    BOOL ignores = NO;
    
    if ([other isKindOfClass:[NpcShip class]]) {
		NpcShip *ship = (NpcShip *)other;
		
		if (ship.feeler == fixtureOther)
			ignores = YES;
	}
    
    return ignores;
}

- (void)beginContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
	if ([self ignoresContact:other fixtureSelf:fixtureSelf fixtureOther:fixtureOther contact:contact])
        return;
    
	[super beginContact:other fixtureSelf:fixtureSelf fixtureOther:fixtureOther contact:contact];
	//NSLog(@"Town Dock Garbage Collector Collision!");
}

- (void)endContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
    if ([self ignoresContact:other fixtureSelf:fixtureSelf fixtureOther:fixtureOther contact:contact])
        return;
    [super endContact:other fixtureSelf:fixtureSelf fixtureOther:fixtureOther contact:contact];
}

- (void)prepareForNewGame {
    // Do nothing
}

@end
