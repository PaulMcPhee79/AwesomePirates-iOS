//
//  TownDock.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 13/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "TownDock.h"
#import "NpcShip.h"
#import "PlayerShip.h"
#import "ActorDef.h"

@interface TownDock ()

- (void)dockShip:(NpcShip *)ship;

@end

@implementation TownDock

- (void)respondToPhysicalInputs {
	for (Actor *actor in mContacts) {
		if ([actor isKindOfClass:[NpcShip class]])
			[self dockShip:(NpcShip *)actor];
	}
}

- (void)dockShip:(NpcShip *)ship {	
	[ship dock];
}

- (void)prepareForNewGame {
    // Do nothing
}

@end
