//
//  PrimeShip.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 23/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NpcShip.h"
#import <Box2D/Box2D.h>

@class EscortShip;

@interface PrimeShip : NpcShip {
    BOOL mLaunching;
    uint mFleetID;
    float mCurrentSailForce;
	EscortShip *mLeftEscort;
	EscortShip *mRightEscort;

    int mTrailInit;
    int mTrailIndex;
    int mTrailIndexCount;
    b2Vec2 mTrailLeft[30];  // Because 60 is max possible fps and we buffer FPS / 2
    b2Vec2 mTrailRight[30];
}

@property (nonatomic,assign) uint fleetID;
@property (nonatomic,retain) EscortShip *leftEscort;
@property (nonatomic,retain) EscortShip *rightEscort;
@property (nonatomic,readonly) float currentSailForce;

- (b2Vec2)flankPosition:(EscortShip *)ship;

@end
