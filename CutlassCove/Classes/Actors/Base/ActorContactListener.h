/*
 *  ActorContactListener.h
 *  PiratesOfCutlassCove
 *
 *  Created by Paul McPhee on 8/09/10.
 *  Copyright 2010 Cheeky Mammoth. All rights reserved.
 *
 */

#ifndef ACTOR_CONTACT_LISTENER_H
#define ACTOR_CONTACT_LISTENER_H

#import <Box2D/Box2D.h>
#import "Actor.h"

class ActorContactListener : public b2ContactListener {

public:
	void BeginContact(b2Contact *contact) {
		b2Fixture *fixtureA = contact->GetFixtureA();
		b2Fixture *fixtureB = contact->GetFixtureB();
		
		b2Body *bodyA = fixtureA->GetBody();
		b2Body *bodyB = fixtureB->GetBody();
		
		Actor *actorA = (Actor*)bodyA->GetUserData();
		Actor *actorB = (Actor*)bodyB->GetUserData();
		
		//b2WorldManifold worldManifold;
		//contact->GetWorldManifold(&worldManifold);
		
		//b2Manifold *manifold = contact->GetManifold();
		//int32 pointCount = (manifold) ? manifold->pointCount : 0;
		
		[actorA beginContact:actorB fixtureSelf:fixtureA fixtureOther:fixtureB contact:contact];
		[actorB beginContact:actorA fixtureSelf:fixtureB fixtureOther:fixtureA contact:contact];
	}
	
	void EndContact(b2Contact *contact) {
		b2Fixture *fixtureA = contact->GetFixtureA();
		b2Fixture *fixtureB = contact->GetFixtureB();
		
		b2Body *bodyA = fixtureA->GetBody();
		b2Body *bodyB = fixtureB->GetBody();
		
		Actor *actorA = (Actor*)bodyA->GetUserData();
		Actor *actorB = (Actor*)bodyB->GetUserData();
		
		//b2WorldManifold worldManifold;
		//contact->GetWorldManifold(&worldManifold);
		
		//b2Manifold *manifold = contact->GetManifold();
		//int32 pointCount = (manifold) ? manifold->pointCount : 0;
		
		[actorA endContact:actorB fixtureSelf:fixtureA fixtureOther:fixtureB contact:contact];
		[actorB endContact:actorA fixtureSelf:fixtureB fixtureOther:fixtureA contact:contact];
	}
	
	void PreSolve(b2Contact *contact, const b2Manifold *oldManifold) {
		b2Fixture *fixtureA = contact->GetFixtureA();
		b2Fixture *fixtureB = contact->GetFixtureB();
		
		b2Body *bodyA = fixtureA->GetBody();
		b2Body *bodyB = fixtureB->GetBody();
		
		Actor *actorA = (Actor*)bodyA->GetUserData();
		Actor *actorB = (Actor*)bodyB->GetUserData();
		
		//b2WorldManifold worldManifold;
		//contact->GetWorldManifold(&worldManifold);
		
		//b2Manifold *manifold = contact->GetManifold();
		//int32 pointCount = (manifold) ? manifold->pointCount : 0;
		
		bool enabled = [actorA preSolve:actorB fixtureSelf:fixtureA fixtureOther:fixtureB contact:contact];
		enabled = enabled && [actorB preSolve:actorA fixtureSelf:fixtureB fixtureOther:fixtureA contact:contact];
		contact->SetEnabled(enabled);
	}
	
	void PostSolve(b2Contact *contact, const b2ContactImpulse *impulse) {
		
	}
};

#endif

