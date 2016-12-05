//
//  CannonFactory.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 7/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "CannonFactory.h"
#import "ShipFactory.h"
#import "CannonDetails.h"
#import "ShipActor.h"
#import "PlayerShip.h"
#import "TownCannon.h"
#import "ActorDef.h"
#import "PlayfieldController.h"
#import "CCValidator.h"
#import "Globals.h"
#import "Box2DUtils.h"


@interface CannonFactory ()

- (CannonDetails *)createCannonDetailsForType:(NSString *)cannonType dictionary:(NSDictionary *)dict;
- (ActorDef *)createCannonballDefForShotType:(NSString *)shotType bore:(float)bore x:(float32)x y:(float32)y ricochets:(BOOL)ricochets;

@end

@implementation CannonFactory

@dynamic allCannonTypes,allCannonDetails;

const float kCannonballImpulse = 10.0f; // 1.3f * 7.5f * distance between left and right cannon fixture on ShipActor.
const float kNpcCannonballImpulse = 7.5f;
static CannonFactory *munitions = nil;

+ (CannonFactory *)munitions {
	@synchronized(self) {
		if (munitions == nil) {
			munitions = [[self alloc] init];
		}
	}
	return munitions;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (munitions == nil) {
			munitions = [super allocWithZone:zone];
			return munitions;
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

+ (float)cannonballImpulse {
	return 1.3f * kCannonballImpulse;
}

- (id)init {
	if (self = [super init]) {
		mBlueprints = [[Globals loadPlist:@"CannonballActors"] retain];
		mCannonDetails = [[Globals loadPlist:@"CannonDetails"] retain];
		mSpecialCannonDetails = [[Globals loadPlist:@"SpecialCannonDetails"] retain];
        
        
        BOOL isValid = [CCValidator isDataValidForDictionary:mBlueprints validators:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                     [NSNumber numberWithInt:34250], @"crimson-shot_",
                                                                                     [NSNumber numberWithInt:34250], @"dutchman-shot_",
                                                                                     [NSNumber numberWithInt:34250], @"magma-shot_",
                                                                                     [NSNumber numberWithInt:34250], @"venom-shot_",
                                                                                     [NSNumber numberWithInt:34250], @"single-shot_",
                                                                                     [NSNumber numberWithInt:34250], @"abyssal-shot_",
                                                                                     nil]];
        
        isValid = isValid && [CCValidator isDataValidForDictionary:mCannonDetails validators:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                              [NSNumber numberWithInt:51844083], @"Perisher",
                                                                                              [NSNumber numberWithInt:12652538], @"Long Nine",
                                                                                              [NSNumber numberWithInt:303933], @"Culverin",
                                                                                              [NSNumber numberWithInt:29021733], @"Ballista",
                                                                                              [NSNumber numberWithInt:6110468], @"Saker",
                                                                                              [NSNumber numberWithInt:2821888], @"Carronade",
                                                                                              nil]];
        
        isValid = isValid && [CCValidator isDataValidForDictionary:mSpecialCannonDetails validators:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                                     [NSNumber numberWithInt:19598582], @"FlyingDutchman",
                                                                                                     nil]];
#if 0        
        [CCValidator printValidatorsForDictionary:mBlueprints categoryName:@"CannonballActors"];
        [CCValidator printValidatorsForDictionary:mCannonDetails categoryName:@"CannonDetails"];
        [CCValidator printValidatorsForDictionary:mSpecialCannonDetails categoryName:@"SpecialCannonDetails"];
#endif
        
        if (isValid == NO)
            [CCValidator reportInvalidData];
	}
	return self;
}

- (NSArray *)allCannonTypes {
	return [mCannonDetails allKeys];
}

- (NSDictionary *)allCannonDetails {
	return mCannonDetails;
}

- (NSArray *)sortCannonNamesAscending:(NSArray *)cannonNames {
	NSMutableArray *sortedList = [NSMutableArray arrayWithCapacity:cannonNames.count];
	NSMutableArray *prices = [NSMutableArray arrayWithCapacity:cannonNames.count];
	
	for (NSString *name in cannonNames) {
		NSDictionary *dict = (NSDictionary *)[mCannonDetails objectForKey:name];
		
		if (dict == nil)
			continue;
		int priceIndex = 0;
		int cannonPrice = [(NSNumber *)[dict objectForKey:@"sort"] intValue];
		
		for (NSNumber *price in prices) {
			if (cannonPrice < [price intValue])
				break;
			++priceIndex;
		}
		
		if (priceIndex < prices.count) {
			[prices insertObject:[NSNumber numberWithInt:cannonPrice] atIndex:priceIndex];
			[sortedList insertObject:name atIndex:priceIndex];
		} else {
			[prices addObject:[NSNumber numberWithInt:cannonPrice]];
			[sortedList addObject:name];
		}
	}
	
	return [NSArray arrayWithArray:sortedList];
}

- (CannonDetails *)createCannonDetailsForType:(NSString *)cannonType {
	NSDictionary *dict = [mCannonDetails objectForKey:cannonType];
	return [self createCannonDetailsForType:cannonType dictionary:dict];
}

- (CannonDetails *)createSpecialCannonDetailsForType:(NSString *)cannonType {
	NSDictionary *dict = [mSpecialCannonDetails objectForKey:cannonType];
	
	CannonDetails *cannonDetails = [self createCannonDetailsForType:cannonType dictionary:dict];
	cannonDetails.textureNameFlash = @"ghost-cannon-flash";
	return cannonDetails;
}

- (CannonDetails *)createCannonDetailsForType:(NSString *)cannonType dictionary:(NSDictionary *)dict {
	CannonDetails *cannonDetails = [[[CannonDetails alloc] initWithType:cannonType] autorelease];
	cannonDetails.price = [(NSNumber *)[dict objectForKey:@"price"] intValue];
	cannonDetails.rangeRating = [(NSNumber *)[dict objectForKey:@"rangeRating"] intValue];
	cannonDetails.damageRating = [(NSNumber *)[dict objectForKey:@"damageRating"] intValue];
	cannonDetails.shotType = [dict objectForKey:@"shotType"];
	cannonDetails.textureNameBase = [dict objectForKey:@"textureNameBase"];
	cannonDetails.textureNameBarrel = [dict objectForKey:@"textureNameBarrel"];
	cannonDetails.textureNameWheel = [dict objectForKey:@"textureNameWheel"];
	cannonDetails.textureNameMenu = [dict objectForKey:@"textureNameMenu"];
	cannonDetails.textureNameFlash = @"cannon-flash";
	cannonDetails.deckSettings = [dict objectForKey:@"Deck"];
	cannonDetails.bitmap = [(NSNumber *)[dict objectForKey:@"bitmap"] unsignedIntValue];
	cannonDetails.reloadInterval = [(NSNumber *)[dict objectForKey:@"reload"] floatValue];
	cannonDetails.comboMax = [(NSNumber *)[dict objectForKey:@"combo"] intValue];
	cannonDetails.ricochetBonus = [(NSNumber *)[dict objectForKey:@"ricochet"] intValue];
	cannonDetails.imbues = [(NSNumber *)[dict objectForKey:@"imbues"] unsignedIntValue];
	return cannonDetails;
}

- (ActorDef *)createCannonballDefForShotType:(NSString *)shotType bore:(float)bore x:(float32)x y:(float32)y ricochets:(BOOL)ricochets {
	NSDictionary *dict = [mBlueprints objectForKey:shotType];
	ActorDef *actorDef = new ActorDef;
	actorDef->bd.type = b2_dynamicBody;
	actorDef->bd.position.Set(x,y);
	
	b2CircleShape *coreShape = new b2CircleShape;
	coreShape->m_radius = (float32)[(NSNumber *)[dict objectForKey:@"radius"] floatValue];
	coreShape->m_radius *= bore;
	
	delete [] actorDef->fds;
	actorDef->fixtureDefCount = (ricochets) ? 2 : 1;
	actorDef->fds = new b2FixtureDef[actorDef->fixtureDefCount];
	actorDef->fds[0].shape = coreShape;
	
	float32 density = (float32)[(NSNumber *)[dict objectForKey:@"density"] floatValue];
	float massNormalizer = coreShape->m_radius * coreShape->m_radius;
	actorDef->fds[0].density = (massNormalizer > 0) ? density * (1 / massNormalizer) : density;
	actorDef->fds[0].isSensor = true;
    actorDef->fds[0].filter.groupIndex = CGI_CANNONBALLS;
    actorDef->fds[0].filter.categoryBits = (COL_BIT_DEFAULT | COL_BIT_CANNONBALL_CORE);
    actorDef->fds[0].filter.maskBits = (COL_BIT_DEFAULT | COL_BIT_VOODOO | COL_BIT_NPC_SHIP_HULL | COL_BIT_PLAYER_SHIP_HULL | COL_BIT_OVERBOARD);
	
	if (ricochets) {
		NSDictionary *coneDict = (NSDictionary *)[dict objectForKey:@"Cone"];
		int shapeType = [(NSNumber *)[coneDict objectForKey:@"type"] intValue];
		b2PolygonShape *coneShape = (b2PolygonShape *)[[ShipFactory shipYard] createShapeForType:shapeType fromDictionary:coneDict];
	
		actorDef->fds[1].shape = coneShape;
		actorDef->fds[1].density = 0;
		actorDef->fds[1].isSensor = true;
        actorDef->fds[1].filter.groupIndex = CGI_CANNONBALLS;
        actorDef->fds[1].filter.categoryBits = COL_BIT_CANNONBALL_CONE;
        actorDef->fds[1].filter.maskBits = COL_BIT_NPC_SHIP_HULL;
	}
	
	// Test - if using, change fixtureDefCount to 3 and making appropriate changes in Cannonball class.
	/*
	b2CircleShape *testShape = new b2CircleShape;
	testShape->m_radius = (float32)[(NSNumber *)[dict objectForKey:@"radius"] floatValue];
	testShape->m_p.Set(0.0f, 6.0f);
	actorDef->fds[2].shape = testShape;
	actorDef->fds[2].density = 0;
	actorDef->fds[2].isSensor = true;
	*/
	
	return actorDef;
}

- (Cannonball *)createCannonballForShip:(ShipActor *)ship shipVector:(b2Vec2)shipVector atSide:(int)side withTrajectory:(float)trajectory forTarget:(b2Vec2)target {
    NSString *shotType = ship.cannonDetails.shotType;
	float bore = ship.cannonDetails.bore;
	b2Vec2 pos = [ship portOrStarboard:side]->GetAABB(0).GetCenter();
	ActorDef *actorDef = [self createCannonballDefForShotType:shotType bore:bore x:pos.x y:pos.y ricochets:[ship isKindOfClass:[PlayerShip class]]];
	Cannonball *cannonball = [[[Cannonball alloc] initWithActorDef:actorDef shotType:shotType shooter:ship bore:bore trajectory:trajectory] autorelease];
    
    delete actorDef;
	actorDef = 0;
    
    b2Vec2 impulse = target - pos;
    impulse.Normalize();
    //impulse *= 1.3f * 7.5f; // 1.3 equals distance between left and right cannon. This maintains impulse calc from createCannonballForShip: atSide: withTrajectory:
    
    if ([ship isKindOfClass:[PlayerShip class]]) {
        PlayerShip *playerShip = (PlayerShip *)ship;
		cannonball.infamyBonus = playerShip.cannonInfamyBonus;
        //cannonball.gravity = 0.075f;
        impulse *= 1.3f * kCannonballImpulse;
    } else {
        impulse *= 1.3f * kNpcCannonballImpulse;
    }
    
    // Calculate angle for shot
    b2Vec2 shotVector = target - pos;
    float shotAngle = Box2DUtils::signedAngle(shipVector, shotVector);
    
    cannonball.body->SetTransform(pos, ship.body->GetAngle() + shotAngle);
	cannonball.body->ApplyLinearImpulse(impulse, cannonball.body->GetPosition());
    
    return cannonball;
}

- (Cannonball *)createCannonballForShip:(ShipActor *)ship atSide:(int)side withTrajectory:(float)trajectory {
	NSString *shotType = ship.cannonDetails.shotType;
	float bore = ship.cannonDetails.bore;
	b2Vec2 pos = [ship portOrStarboard:side]->GetAABB(0).GetCenter();
	ActorDef *actorDef = [self createCannonballDefForShotType:shotType bore:bore x:pos.x y:pos.y ricochets:[ship isKindOfClass:[PlayerShip class]]];
	Cannonball *cannonball = [[[Cannonball alloc] initWithActorDef:actorDef shotType:shotType shooter:ship bore:bore trajectory:trajectory] autorelease];
	
	delete actorDef;
	actorDef = 0;
	
	//cannonball.body->SetBullet(true);
	
    float impulseFactor = kNpcCannonballImpulse;
	// Npc ships don't need the hassle of compensating for their own velocity.
	if ([ship isKindOfClass:[PlayerShip class]]) {
		PlayerShip *playerShip = (PlayerShip *)ship;
		cannonball.infamyBonus = playerShip.cannonInfamyBonus;
		
		if (playerShip.assistedAiming == NO) {
			b2Vec2 linearVelocity = ship.body->GetLinearVelocity();
			
			// It looks better if we shave off some of the initial velocity
			// to compensate for our lack of wind resistance in flight.
			linearVelocity.x /= 2.0f;
			linearVelocity.y /= 2.0f;
			cannonball.body->SetLinearVelocity(linearVelocity);
		}
        
        impulseFactor = kCannonballImpulse;
	}
	
	b2Vec2 impulse;
	b2CircleShape *portShape = (b2CircleShape *)ship.port->GetShape();
	b2CircleShape *starboardShape = (b2CircleShape *)ship.starboard->GetShape();
	//BOOL applyPerpForce = SP_IS_FLOAT_EQUAL(perpForce, 0) == NO;
	
	if (side == PortSide)
		impulse = ship.body->GetWorldPoint(portShape->m_p) - ship.body->GetWorldPoint(starboardShape->m_p);
	else
		impulse = ship.body->GetWorldPoint(starboardShape->m_p) - ship.body->GetWorldPoint(portShape->m_p);
	//impulse *= ship.cannonDetails.rangeRating*1.5f;
	//impulse *= 6.5f + ((applyPerpForce)?0:0.5f); // * ((7 + ship.cannonDetails.rangeRating) / 10.0f);
	impulse *= impulseFactor;
	cannonball.body->SetTransform(pos, ship.body->GetAngle() + ((side == PortSide) ? PI_HALF : -PI_HALF));
	cannonball.body->ApplyLinearImpulse(impulse, cannonball.body->GetPosition());
	
	/*
	// Apply perpendicular force, if requested.
	if (applyPerpForce) {
		b2CircleShape *bowShape = (b2CircleShape *)ship.bow->GetShape();
		b2CircleShape *sternShape = (b2CircleShape *)ship.stern->GetShape();
		
		if (perpForce < 0)
			impulse = ship.body->GetWorldPoint(bowShape->m_p) - ship.body->GetWorldPoint(sternShape->m_p);
		else
			impulse = ship.body->GetWorldPoint(sternShape->m_p) - ship.body->GetWorldPoint(bowShape->m_p);
		impulse.Normalize();
		impulse *= fabsf(perpForce);
		cannonball.body->ApplyLinearImpulse(impulse, cannonball.body->GetPosition());
	}
	*/
	
	/* // Deemed to be slower than the above due to atanf...TODO: check out GetWorldPoint transform.
	 float32 angle = ship.body->GetAngle() + ((side == PortSide) ? PI_HALF : -PI_HALF);
	 b2Vec2 impulse(0.0f,ship.cannonDetails.rangeRating*1.5f);
	 Box2DUtils::rotateVector(impulse,angle);
	 cannonball.body->ApplyLinearImpulse(impulse, cannonball.body->GetPosition());
	 */
	return cannonball;
}

- (Cannonball *)createCannonballForShooter:(SPSprite *)shooter shotType:(NSString *)shotType bore:(float)bore
							 ricochetCount:(uint)ricochetCount infamyBonus:(CannonballInfamyBonus *)infamyBonus loc:(b2Vec2)loc
									   vel:(b2Vec2)vel trajectory:(float)trajectory distRemaining:(float)distRemaining {
	ActorDef *actorDef = [self createCannonballDefForShotType:shotType bore:bore x:loc.x y:loc.y ricochets:[shooter isKindOfClass:[PlayerShip class]]];
	Cannonball *cannonball = [[[Cannonball alloc] initWithActorDef:actorDef shotType:shotType shooter:shooter bore:bore trajectory:trajectory] autorelease];
	delete actorDef;
	actorDef = 0;
	
	if (infamyBonus)
		cannonball.infamyBonus = infamyBonus;
	cannonball.ricochetCount = ricochetCount;
	cannonball.distanceRemaining = distRemaining;
	//cannonball.body->SetBullet(true);
	cannonball.body->SetLinearVelocity(vel);
	return cannonball;
}

- (Cannonball *)createCannonballForTownCannon:(TownCannon *)cannon bore:(float)bore {
	SPPoint *nozzle = cannon.nozzle;
	ActorDef *actorDef = [self createCannonballDefForShotType:cannon.shotType bore:bore x:P2MX(nozzle.x) y:P2MY(nozzle.y) ricochets:NO];
	Cannonball *cannonball = [[[Cannonball alloc] initWithActorDef:actorDef shotType:cannon.shotType shooter:cannon bore:bore] autorelease];
	delete actorDef;
	actorDef = 0;
	
	//cannonball.body->SetBullet(true);
    b2Vec2 loc = b2Vec2(P2MX(nozzle.x), P2MY(nozzle.y));
	b2Vec2 impulse(0.0f,10.0f);
    cannonball.body->SetTransform(loc, -cannon.rotation);
    
	Box2DUtils::rotateVector(impulse, -cannon.rotation);
	cannonball.body->ApplyLinearImpulse(impulse, cannonball.body->GetPosition());
	
	return cannonball;
}

- (void)dealloc {
	[mBlueprints release]; mBlueprints = nil;
	[mCannonDetails release]; mCannonDetails = nil;
	[mSpecialCannonDetails release]; mSpecialCannonDetails = nil;
	munitions = nil;
	[super dealloc];
}

@end

