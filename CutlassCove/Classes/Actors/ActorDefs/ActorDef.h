/*
 *  ActorDef.h
 *  PiratesOfCutlassCove
 *
 *  Created by Paul McPhee on 8/09/10.
 *  Copyright 2010 Cheeky Mammoth. All rights reserved.
 *
 */


#ifndef ACTOR_DEF_H
#define ACTOR_DEF_H

#include <Box2D/Box2D.h>

class ActorDef {
public:
	ActorDef() {
		fixtureDefCount = 0;
		fds = 0;
		fixtures = 0;
	}
	
	~ActorDef() {
		for (int i = 0; i < fixtureDefCount; ++i)
			delete fds[i].shape;
		delete [] fds;
		delete [] fixtures; // Individual fixtures destroyed by b2World
	}
	
	int fixtureDefCount;
	b2BodyDef bd;
	b2FixtureDef *fds;
	b2Fixture **fixtures;
};

#endif
