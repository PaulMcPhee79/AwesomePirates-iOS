//
//  PrisonerProp.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 28/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PrisonerProp.h"
#import "Prisoner.h"
#import "ShipFactory.h"
#import "PlayerShip.h"
#import "PlayerDetails.h"
#import "GameController.h"
#import "Globals.h"

@implementation PrisonerProp

- (id)initWithCategory:(int)category {
    if (self = [super initWithCategory:category resourceKey:@"Prisoner"]) {
		[mLootSfxKey release];
		mLootSfxKey = nil;
		[self setupProp];
    }
    return self;
}

- (void)setupProp {
	if (mCostume == nil) {
		mCostume = [[SPImage alloc] initWithTexture:[mScene textureByName:@"pirate-hat" cacheGroup:TM_CACHE_LOOT_PROPS]];
		mCostume.x = -mCostume.width / 2;
		mCostume.y = -mCostume.height / 2;
	}
	
	[super setupProp];
}

- (void)loot {
    GameController *gc = GCTRL;
    
	if (mLooted == YES || gc.thisTurn.isGameOver || self.turnID != gc.thisTurn.turnID || [gc.playerShip isFullOnPrisoners])
		return;
	Prisoner *prisoner = [gc.playerShip addRandomPrisoner];
	
	if (prisoner != nil)
		[super loot];
	else
		[self destroyLoot];
}

- (void)dealloc {
	[super dealloc];
}

@end
