//
//  EscortShip.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 22/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PursuitShip.h"


@class PrimeShip;

@interface EscortShip : PursuitShip {
	BOOL mWillEnterTown;
    uint mFleetID;
	PrimeShip *mEscortee;
}

@property (nonatomic,assign) BOOL willEnterTown;
@property (nonatomic,assign) uint fleetID;
@property (nonatomic,retain) PrimeShip *escortee;

@end
