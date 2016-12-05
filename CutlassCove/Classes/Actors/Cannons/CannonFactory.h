//
//  CannonFactory.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 7/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Box2D/Box2D.h>
#import "Cannonball.h"

@class CannonDetails,ShipActor,TownCannon;

@interface CannonFactory : NSObject {
	NSDictionary *mBlueprints;
	NSDictionary *mCannonDetails;
	NSDictionary *mSpecialCannonDetails;
}

@property (nonatomic,readonly) NSArray *allCannonTypes;
@property (nonatomic,readonly) NSDictionary *allCannonDetails;

+ (CannonFactory *)munitions;
+ (float)cannonballImpulse;
- (NSArray *)sortCannonNamesAscending:(NSArray *)cannonNames;
- (CannonDetails *)createCannonDetailsForType:(NSString *)cannonType;
- (CannonDetails *)createSpecialCannonDetailsForType:(NSString *)cannonType;
- (Cannonball *)createCannonballForShip:(ShipActor *)ship shipVector:(b2Vec2)shipVector atSide:(int)side withTrajectory:(float)trajectory forTarget:(b2Vec2)target;
- (Cannonball *)createCannonballForShip:(ShipActor *)ship atSide:(int)side withTrajectory:(float)trajectory;
- (Cannonball *)createCannonballForShooter:(SPSprite *)shooter shotType:(NSString *)shotType bore:(float)bore
							 ricochetCount:(uint)ricochetCount infamyBonus:(CannonballInfamyBonus *)infamyBonus loc:(b2Vec2)loc
									   vel:(b2Vec2)vel trajectory:(float)trajectory distRemaining:(float)distRemaining;
- (Cannonball *)createCannonballForTownCannon:(TownCannon *)cannon bore:(float)bore;

@end
