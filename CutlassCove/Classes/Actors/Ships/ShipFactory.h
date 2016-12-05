//
//  ShipFactory.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 6/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Box2D/Box2D.h>

@class Prisoner,ShipDetails,ShipActor;
class ActorDef;

@interface ShipFactory : NSObject {
	NSDictionary *mShipDetails;
	NSDictionary *mNpcShipDetails;
	NSDictionary *mPrisoners;
	NSDictionary *mBlueprints;
	NSMutableDictionary *mResourcePool;
}

@property (nonatomic,readonly) NSArray *allShipTypes;
@property (nonatomic,readonly) NSDictionary *allShipDetails;
@property (nonatomic,readonly) NSArray *allNpcShipTypes;
@property (nonatomic,readonly) NSDictionary *allNpcShipDetails;
@property (nonatomic,readonly) NSArray *allPrisonerNames;
@property (nonatomic,readonly) NSDictionary *allPrisoners;

+ (ShipFactory *)shipYard;

- (b2Shape *)createShapeForType:(int)shapeType fromDictionary:(NSDictionary *)dict;

- (id)shipAttribute:(NSArray *)keyPath;
- (NSArray *)sortShipNamesAscending:(NSArray *)shipNames;
- (Prisoner *)createPrisonerForName:(NSString *)name;
- (ShipDetails *)createShipDetailsForType:(NSString *)shipType;
- (ShipDetails *)createNpcShipDetailsForType:(NSString *)shipType;
- (ActorDef *)createPlayerShipDefForShipType:(NSString *)shipType x:(float32)x y:(float32)y angle:(float32)angle;
- (ActorDef *)createShipDefForShipType:(NSString *)shipType x:(float32)x y:(float32)y angle:(float32)angle;

/*
// Resource pool (textures,MovieClips,etc)
- (void)fillShipResourcePoolWithTextureManager:(TextureManager *)tm;
- (void)drainShipResourcePoolWithTextureManager:(TextureManager *)tm;
- (id)checkoutShipResourceForKey:(NSString *)key;
- (void)checkinShipResource:(id)resource forKey:(NSString *)key;
*/
 
@end
