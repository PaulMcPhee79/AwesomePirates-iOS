//
//  NavyShip.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 20/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "NavyShip.h"
#import "ShipDetails.h"
#import "PlayerDetails.h"
#import "GameController.h"
#import "Globals.h"

@implementation NavyShip

- (id)initWithActorDef:(ActorDef *)def key:(NSString *)key {
    if (self = [super initWithActorDef:def key:key]) {
		mBootyGoneWanting = NO;
    }
    return self;
}

- (void)dropLoot {

}

- (void)creditPlayerSinker {
	[mScene.achievementManager navyShipSunk:self];
}

- (void)playerCamouflageActivated:(BOOL)value {
    if (mPursuitEnded)
        return;
    
	if (value == YES) {
		if (self.duelState != PursuitStateFerrying)
			self.duelState = PursuitStateSailingToDock;
	} else {
		if (mEnemy != nil)
			self.duelState = PursuitStateChasing;
		else if (self.duelState != PursuitStateFerrying)
			self.duelState = PursuitStateSearching;
	}
}

@end
