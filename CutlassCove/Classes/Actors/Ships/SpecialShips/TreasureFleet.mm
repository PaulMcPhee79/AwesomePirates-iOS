//
//  TreasureFleet.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 8/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TreasureFleet.h"


@implementation TreasureFleet

- (void)creditPlayerSinker {
	[mScene.achievementManager treasureFleetSunk:self];
}

- (void)sailWithForce:(float32)force {
    // Slow down when entering the town so that we can enter more orderly
    if (self.destination.finishIsDest && mDestination.finish == kPlaneIdTown)
        [super sailWithForce:0.75f * force];
    else
        [super sailWithForce:force];
}

@end
