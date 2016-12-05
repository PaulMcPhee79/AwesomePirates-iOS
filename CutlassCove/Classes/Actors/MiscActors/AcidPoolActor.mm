//
//  AcidPoolActor.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 12/07/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "AcidPoolActor.h"
#import "ActorFactory.h"
#import "ShipActor.h"
#import "PlayerShip.h"
#import "GameController.h"
#import "Globals.h"

@implementation AcidPoolActor

+ (AcidPoolActor *)acidPoolActorAtX:(float)x y:(float)y duration:(float)duration {
	ActorFactory *juilliard = [ActorFactory juilliard];
	ActorDef *actorDef = [juilliard createPoolDefinitionAtX:x y:y];
	AcidPoolActor *acidPool = [[[AcidPoolActor alloc] initWithActorDef:actorDef duration:duration] autorelease];
	delete actorDef;
	actorDef = 0;
	return acidPool;
}

- (double)fullDuration {
	return ASH_DURATION_ACID_POOL;
}

- (uint)bitmapID {
	return ASH_SPELL_ACID_POOL;
}

- (uint)deathBitmap {
	return DEATH_BITMAP_ACID_POOL;
}

- (NSString *)poolTextureName {
	return @"pool-of-acid";
}

- (NSString *)resourcesKey {
	return @"AcidPool";
}

- (void)sinkNpcShip:(NpcShip *)ship {
    [super sinkNpcShip:ship];
    
    if (GCTRL.playerShip.isFlyingDutchman)
        ++mScene.achievementManager.slimerCount;
}

@end
