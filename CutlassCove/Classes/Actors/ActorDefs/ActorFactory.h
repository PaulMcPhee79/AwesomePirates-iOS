//
//  ActorFactory.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 8/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Box2D/Box2D.h>

class ActorDef;

@interface ActorFactory : NSObject {
    NSDictionary *mRaceTrack;
}

+ (ActorFactory *)juilliard;
- (ActorDef *)createLootDefinitionAtX:(float32)x y:(float32)y radius:(float32)radius;
- (ActorDef *)createPoolDefinitionAtX:(float32)x y:(float32)y;
- (ActorDef *)createTreasureDefinitionAtX:(float32)x y:(float32)y;
- (ActorDef *)createTownDockDefinitionAtX:(float32)x y:(float32)y angle:(float32)angle;
- (ActorDef *)createTreasureDockDefAtX:(float32)x y:(float32)y angle:(float32)angle;
- (ActorDef *)createCoveDockDefAtX:(float32)x y:(float32)y angle:(float32)angle;
- (ActorDef *)createSharkDefAtX:(float32)x y:(float32)y angle:(float32)angle;
- (ActorDef *)createPersonOverboardDefAtX:(float32)x y:(float32)y angle:(float32)angle;
- (ActorDef *)createPowderKegDefAtX:(float32)x y:(float32)y angle:(float32)angle;
- (ActorDef *)createNetDefAtX:(float32)x y:(float32)y angle:(float32)angle scale:(float)scale;
- (ActorDef *)createBrandySlickDefAtX:(float32)x y:(float32)y angle:(float32)angle scale:(float)scale;
- (ActorDef *)createTempestDefAtX:(float32)x y:(float32)y angle:(float32)angle;
- (ActorDef *)createWhirlpoolDefAtX:(float32)x y:(float32)y angle:(float32)angle;
- (ActorDef *)createRaceTrackDefWithDictionary:(NSDictionary *)dictionary;

@end
