//
//  ShipFactory.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 6/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "ShipFactory.h"
#import "ShipActor.h"
#import "ShipDetails.h"
#import "Prisoner.h"
#import "ActorDef.h"
#import "PlayfieldController.h"
#import "CCValidator.h"
#import "Globals.h"

typedef enum {
	ShapeCircle = 0,
	ShapeBox,
	ShapeEdge,
	ShapePoly
} ShapeTypes;

@interface ShipFactory ()

- (ShipDetails *)createShipDetailsFromDictionary:(NSDictionary *)dictionary forType:(NSString *)shipType;

@end

@implementation ShipFactory

@synthesize allPrisoners = mPrisoners;
@dynamic allShipTypes,allShipDetails,allNpcShipTypes,allNpcShipDetails,allPrisonerNames;

static ShipFactory *shipYard = nil;

+ (ShipFactory *)shipYard {
	@synchronized(self) {
		if (shipYard == nil) {
			shipYard = [[self alloc] init];
		}
	}
	return shipYard;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (shipYard == nil) {
			shipYard = [super allocWithZone:zone];
			return shipYard;
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
		mShipDetails = [[Globals loadPlist:@"ShipDetails"] retain];
		mNpcShipDetails = [[Globals loadPlist:@"NpcShipDetails"] retain];
		mPrisoners = [[Globals loadPlist:@"Prisoners"] retain];
		mBlueprints = [[Globals loadPlist:@"ShipActors"] retain];
		mResourcePool = nil;
#if 1 
        BOOL isValid = [CCValidator isDataValidForDictionary:mShipDetails validators:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                      [NSNumber numberWithInt:349043], @"FlyingDutchman",
                                                                                      [NSNumber numberWithInt:40327071], @"Man o' War",
                                                                                      [NSNumber numberWithInt:88409037], @"Speedboat",
                                                                                      nil]];
        
        isValid = isValid && [CCValidator isDataValidForDictionary:mNpcShipDetails validators:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                               [NSNumber numberWithInt:1400033], @"Pirate",
                                                                                               [NSNumber numberWithInt:1259030], @"Navy",
                                                                                               [NSNumber numberWithInt:21161029], @"Escort",
                                                                                               [NSNumber numberWithInt:5527055], @"MerchantCaravel",
                                                                                               [NSNumber numberWithInt:17036039], @"SilverTrain",
                                                                                               [NSNumber numberWithInt:5571057], @"MerchantGalleon",
                                                                                               [NSNumber numberWithInt:17036043], @"TreasureFleet",
                                                                                               [NSNumber numberWithInt:5616057], @"MerchantFrigate",
                                                                                               nil]];
        
        isValid = isValid && [CCValidator isDataValidForDictionary:mPrisoners validators:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                          [NSNumber numberWithInt:251009], @"Prisoner5",
                                                                                          [NSNumber numberWithInt:251009], @"Prisoner2",
                                                                                          [NSNumber numberWithInt:251009], @"Prisoner3",
                                                                                          [NSNumber numberWithInt:250009], @"Prisoner0",
                                                                                          [NSNumber numberWithInt:251009], @"Prisoner4",
                                                                                          [NSNumber numberWithInt:250009], @"Prisoner1",
                                                                                          nil]];
        
        isValid = isValid && [CCValidator isDataValidForDictionary:mBlueprints validators:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                           [NSNumber numberWithInt:37224], @"Pirate",
                                                                                           [NSNumber numberWithInt:17312], @"PlayerShip",
                                                                                           [NSNumber numberWithInt:37224], @"Escort",
                                                                                           [NSNumber numberWithInt:37224], @"Navy",
                                                                                           [NSNumber numberWithInt:37224], @"SilverTrain",
                                                                                           [NSNumber numberWithInt:11000], @"Speedboat",
                                                                                           [NSNumber numberWithInt:37224], @"Merchant",
                                                                                           [NSNumber numberWithInt:37224], @"TreasureFleet",
                                                                                           nil]];
        
#if 0        
        [CCValidator printValidatorsForDictionary:mShipDetails categoryName:@"ShipDetails"];
        [CCValidator printValidatorsForDictionary:mNpcShipDetails categoryName:@"NpcShipDetails"];
        [CCValidator printValidatorsForDictionary:mPrisoners categoryName:@"Prisoners"];
        [CCValidator printValidatorsForDictionary:mBlueprints categoryName:@"ShipActors"];
#endif        
        
        if (isValid == NO)
            [CCValidator reportInvalidData];
#endif
	}
	return self;
}

- (id)shipAttribute:(NSArray *)keyPath {
	NSDictionary *dict = mBlueprints;
	
	for (int i = 0; i < keyPath.count-1; ++i)
		dict = [dict objectForKey:[keyPath objectAtIndex:i]];
	return [dict objectForKey:[keyPath objectAtIndex:keyPath.count-1]];
}

- (NSArray *)allShipTypes {
	return [mShipDetails allKeys];
}

- (NSDictionary *)allShipDetails {
	return mShipDetails;
}

- (NSArray *)allNpcShipTypes {
	return [mNpcShipDetails allKeys];
}

- (NSDictionary *)allNpcShipDetails {
	return mNpcShipDetails;
}

- (NSArray *)allPrisonerNames {
	return [mPrisoners allKeys];
}

- (NSArray *)sortShipNamesAscending:(NSArray *)shipNames {
	NSMutableArray *sortedList = [NSMutableArray arrayWithCapacity:shipNames.count];
	NSMutableArray *prices = [NSMutableArray arrayWithCapacity:shipNames.count];
	
	for (NSString *name in shipNames) {
		NSDictionary *dict = (NSDictionary *)[mShipDetails objectForKey:name];
		
		if (dict == nil)
			continue;
		int priceIndex = 0;
		int shipPrice = [(NSNumber *)[dict objectForKey:@"price"] intValue];
		
		for (NSNumber *price in prices) {
			if (shipPrice < [price intValue])
				break;
			++priceIndex;
		}
		
		if (priceIndex < prices.count) {
			[prices insertObject:[NSNumber numberWithInt:shipPrice] atIndex:priceIndex];
			[sortedList insertObject:name atIndex:priceIndex];
		} else {
			[prices addObject:[NSNumber numberWithInt:shipPrice]];
			[sortedList addObject:name];
		}
	}
	
	return [NSArray arrayWithArray:sortedList];
}

- (Prisoner *)createPrisonerForName:(NSString *)name {
	Prisoner *prisoner = [Prisoner prisonerWithName:name];
	NSDictionary *dict = [mPrisoners objectForKey:name];
	prisoner.gender = [(NSNumber *)[dict objectForKey:@"gender"] intValue];
	prisoner.textureName = [dict objectForKey:@"textureName"];
	prisoner.infamyBonus = [(NSNumber *)[dict objectForKey:@"infamyBonus"] intValue];
	return prisoner;
}

- (ShipDetails *)createShipDetailsFromDictionary:(NSDictionary *)dictionary forType:(NSString *)shipType {
	ShipDetails *shipDetails = [[[ShipDetails alloc] initWithType:shipType] autorelease];
	NSDictionary *dict = [dictionary objectForKey:shipType];
	shipDetails.speedRating = [(NSNumber *)[dict objectForKey:@"speedRating"] intValue];
	shipDetails.controlRating = [(NSNumber *)[dict objectForKey:@"controlRating"] intValue];
	shipDetails.rudderOffset = [(NSNumber *)[dict objectForKey:@"rudderOffset"] floatValue];
	shipDetails.reloadInterval = [(NSNumber *)[dict objectForKey:@"reloadInterval"] floatValue];
	shipDetails.infamyBonus = [(NSNumber *)[dict objectForKey:@"infamyBonus"] intValue];
    shipDetails.mutinyPenalty = [(NSNumber *)[dict objectForKey:@"mutinyPenalty"] intValue];
	shipDetails.textureName = (NSString *)[dict objectForKey:@"textureName"];
	shipDetails.textureFutureName = (NSString *)[dict objectForKey:@"textureFutureName"];
	shipDetails.bitmap = [(NSNumber *)[dict objectForKey:@"bitmap"] unsignedIntValue];
	return shipDetails;
}

- (ShipDetails *)createShipDetailsForType:(NSString *)shipType {
	return [self createShipDetailsFromDictionary:mShipDetails forType:shipType];
}

- (ShipDetails *)createNpcShipDetailsForType:(NSString *)shipType {
	return [self createShipDetailsFromDictionary:mNpcShipDetails forType:shipType];
}

- (ActorDef *)createPlayerShipDefForShipType:(NSString *)shipType x:(float32)x y:(float32)y angle:(float32)angle {
	NSDictionary *dict = [mBlueprints objectForKey:shipType];
	NSDictionary *prev = dict;
	ActorDef *actorDef = new ActorDef;
	int filterGroup = [(NSNumber *)[dict objectForKey:@"filterGroup"] intValue];
	
	dict = [dict objectForKey:@"B2BodyDef"];
	
	actorDef->bd.type = b2_dynamicBody;
	actorDef->bd.linearDamping = (float32)[(NSNumber *)[dict objectForKey:@"linearDamping"] floatValue];
	actorDef->bd.angularDamping = (float32)[(NSNumber *)[dict objectForKey:@"angularDamping"] floatValue];
	actorDef->bd.position.Set(x,y);
	actorDef->bd.angle = angle;
	
	dict = prev;
	int index = 0;
	NSArray *array = [dict objectForKey:@"B2Fixtures"];
	
	delete [] actorDef->fds;
	actorDef->fixtureDefCount = array.count;
	actorDef->fds = new b2FixtureDef[actorDef->fixtureDefCount];
	
	for (NSDictionary *iter in array) {
		dict = [iter objectForKey:@"B2FixtureDef"];
		actorDef->fds[index].density = (float32)[(NSNumber *)[dict objectForKey:@"density"] floatValue];
		actorDef->fds[index].friction = (float32)[(NSNumber *)[dict objectForKey:@"friction"] floatValue];
		actorDef->fds[index].isSensor = ([(NSNumber *)[dict objectForKey:@"isSensor"] boolValue] == YES);
		actorDef->fds[index].filter.groupIndex = filterGroup;
        
        switch (index) {
            case 0: // Bow
            case 1: // Middle
            case 2: // Stern
                actorDef->fds[index].filter.categoryBits = (COL_BIT_DEFAULT | COL_BIT_PLAYER_SHIP_HULL);
                actorDef->fds[index].filter.maskBits = (COL_BIT_DEFAULT | COL_BIT_PLAYER_BUFF | COL_BIT_NPC_SHIP_DEFENDER | COL_BIT_NPC_SHIP_HULL);
                break;
            case 3: // Left Cannon
            case 4: // Right Cannon
                actorDef->fds[index].filter.categoryBits = 0;
                break;
            default:
                break;
        }
		
		dict = [iter objectForKey:@"B2Shape"];
		int shapeType = [(NSNumber *)[dict objectForKey:@"type"] intValue];
		actorDef->fds[index].shape = [self createShapeForType:shapeType fromDictionary:dict];
		++index;
	}
	return actorDef;
}

- (ActorDef *)createShipDefForShipType:(NSString *)shipType x:(float32)x y:(float32)y angle:(float32)angle {
	NSDictionary *dict = [mBlueprints objectForKey:shipType];
	NSDictionary *prev = dict;
	ActorDef *actorDef = new ActorDef;
	int filterGroup = [(NSNumber *)[dict objectForKey:@"filterGroup"] intValue];
	
	dict = [dict objectForKey:@"B2BodyDef"];
	
	actorDef->bd.type = b2_dynamicBody;
	actorDef->bd.linearDamping = (float32)[(NSNumber *)[dict objectForKey:@"linearDamping"] floatValue];
	actorDef->bd.angularDamping = (float32)[(NSNumber *)[dict objectForKey:@"angularDamping"] floatValue];
	actorDef->bd.position.Set(x,y);
	actorDef->bd.angle = angle;
	
	dict = prev;
	int index = 0;
	NSArray *array = [dict objectForKey:@"B2Fixtures"];
	
	delete [] actorDef->fds;
	actorDef->fixtureDefCount = array.count;
	actorDef->fds = new b2FixtureDef[actorDef->fixtureDefCount];
	
	for (NSDictionary *iter in array) {
		dict = [iter objectForKey:@"B2FixtureDef"];
		actorDef->fds[index].density = (float32)[(NSNumber *)[dict objectForKey:@"density"] floatValue];
		actorDef->fds[index].friction = (float32)[(NSNumber *)[dict objectForKey:@"friction"] floatValue];
		actorDef->fds[index].isSensor = ([(NSNumber *)[dict objectForKey:@"isSensor"] boolValue] == YES);
		actorDef->fds[index].filter.groupIndex = filterGroup;
        
        switch (index) {
            case 0: // Bow
            case 1: // Middle
                actorDef->fds[index].filter.categoryBits = (COL_BIT_DEFAULT | COL_BIT_NPC_SHIP_HULL);
                actorDef->fds[index].filter.maskBits = 0xffff;
                break;
            case 2: // Stern
                actorDef->fds[index].filter.categoryBits = (COL_BIT_DEFAULT | COL_BIT_NPC_SHIP_HULL | COL_BIT_NPC_SHIP_STERN);
                actorDef->fds[index].filter.maskBits = 0xffff;
                break;
            case 3: // Left Cannon
            case 4: // Right Cannon
                actorDef->fds[index].filter.categoryBits = 0;
                break;
            case 5: // Feeler
                actorDef->fds[index].filter.categoryBits = COL_BIT_NPC_SHIP_FEELER;
                actorDef->fds[index].filter.maskBits = (COL_BIT_NPC_SHIP_HULL | COL_BIT_NPC_SHIP_FEELER);
                break;
            case 6: // Hit Box
                actorDef->fds[index].filter.categoryBits = 0;
                break;
//            case 7: // Defender
//                actorDef->fds[index].filter.categoryBits = COL_BIT_NPC_SHIP_DEFENDER;
//                actorDef->fds[index].filter.maskBits = (COL_BIT_PLAYER_SHIP_HULL);
//                break;
            default:
                break;
        }
		
		dict = [iter objectForKey:@"B2Shape"];
		int shapeType = [(NSNumber *)[dict objectForKey:@"type"] intValue];
		actorDef->fds[index].shape = [self createShapeForType:shapeType fromDictionary:dict];
		++index;
	}
	return actorDef;
}

- (b2Shape *)createShapeForType:(int)shapeType fromDictionary:(NSDictionary *)dict {
	b2Shape *shape = nil;
	
	switch (shapeType) {
		case ShapeCircle:
		{
			b2CircleShape *circle = new b2CircleShape;
			circle->m_radius = (float32)[(NSNumber *)[dict objectForKey:@"radius"] floatValue];
			float32 x = (float32)[(NSNumber *)[dict objectForKey:@"x"] floatValue];
			float32 y = (float32)[(NSNumber *)[dict objectForKey:@"y"] floatValue];
			circle->m_p.Set(x,y);
			shape = circle;
			break;
		}
		case ShapeBox:
		{
			b2PolygonShape *box = new b2PolygonShape;
			float32 x = (float32)[(NSNumber *)[dict objectForKey:@"x"] floatValue];
			float32 y = (float32)[(NSNumber *)[dict objectForKey:@"y"] floatValue];
			float32 hw = (float32)[(NSNumber *)[dict objectForKey:@"hw"] floatValue];
			float32 hh = (float32)[(NSNumber *)[dict objectForKey:@"hh"] floatValue];
			float32 rotation = (float32)[(NSNumber *)[dict objectForKey:@"rotation"] floatValue];
			box->SetAsBox(hw, hh, b2Vec2(x,y),rotation);
			shape = box;
			break;
		}
		case ShapeEdge:
		{
			b2EdgeShape *edge = new b2EdgeShape;
			float32 v1x = (float32)[(NSNumber *)[dict objectForKey:@"v1x"] floatValue];
			float32 v1y = (float32)[(NSNumber *)[dict objectForKey:@"v1y"] floatValue];
			float32 v2x = (float32)[(NSNumber *)[dict objectForKey:@"v2x"] floatValue];
			float32 v2y = (float32)[(NSNumber *)[dict objectForKey:@"v2y"] floatValue];
            edge->Set(b2Vec2(v1x,v1y),b2Vec2(v2x,v2y));
			shape = edge;
			break;
		}
		case ShapePoly:
		{
			b2PolygonShape *poly = new b2PolygonShape;
			
			NSArray *array = [dict objectForKey:@"vertices"];
			b2Vec2 vertices[8];
			int vertexCount = MIN(8,array.count/2);
			
			for (int i = 0; i < vertexCount; ++i) {
				vertices[i].x = (float32)[(NSNumber *)[array objectAtIndex:i*2] floatValue];
				vertices[i].y = (float32)[(NSNumber *)[array objectAtIndex:i*2+1] floatValue];
			}
			poly->Set(vertices, vertexCount);
			shape = poly;
			break;
		}
		default:
			NSLog(@"Invalid shape type requested in ShipFactory.\n");
			break;
	}
	return shape;
}

/*
- (void)fillShipResourcePoolWithTextureManager:(TextureManager *)tm {
	if (mResourcePool)
		return;
	mResourcePool = [[NSMutableDictionary alloc] initWithCapacity:10];
}

- (void)drainShipResourcePoolWithTextureManager:(TextureManager *)tm {
	[mResourcePool autorelease];
	mResourcePool = nil;
}

- (id)checkoutShipResourceForKey:(NSString *)key {
	id resource = nil;
	NSMutableArray *array = (NSMutableArray *)[mResourcePool objectForKey:key];
	
	if (array)
		resource = [array lastObject];
	return resource;
}

- (void)checkinShipResource:(id)resource forKey:(NSString *)key {
	NSMutableArray *array = (NSMutableArray *)[mResourcePool objectForKey:key];
	
	if (array)
		[array addObject:resource];
}
*/

- (void)dealloc {
	[mShipDetails release]; mShipDetails = nil;
	[mNpcShipDetails release]; mNpcShipDetails = nil;
	[mPrisoners release]; mPrisoners = nil;
	[mBlueprints release]; mBlueprints = nil;
	[mResourcePool release]; mResourcePool = nil;
	shipYard = nil;
	[super dealloc];
}

@end
