//
//  SilverTrain.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 8/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SilverTrain.h"
#import "PlayerShip.h"
#import "ShipFactory.h"
#import "GameController.h"

@implementation SilverTrain

- (void)creditPlayerSinker {
	[mScene.achievementManager silverTrainSunk:self];
}

- (void)dropLoot {
    [super dropLoot];
    
    /*
    GameController *gc = GCTRL;
    
    if (gc.thisTurn.isGameOver)
        return;
	[super dropLoot];
	
	Booty *booty = [[ShipFactory shipYard] createBootyForType:@"Silver"];
	booty.quantity = (mScene.enhancements.bulginBreeches) ? 12 : 10;
	[gc.playerShip addBooty:booty];
     */
}

@end
