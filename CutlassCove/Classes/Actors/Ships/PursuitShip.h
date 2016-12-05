//
//  NavyShip.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 14/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NpcShip.h"
#import "Pursuer.h"

typedef enum {
	PursuitStateIdle = 0,
	PursuitStateDeparting,
	PursuitStateFerrying,
	PursuitStateOutOfBounds,
	PursuitStateChasing,
	PursuitStateAiming,
	PursuitStateStrafing,
	PursuitStateSearching,
	PursuitStateEscorting,
	PursuitStateSailingToDock,
	PursuitStateSinking
} PursuitState;

@class TargetTracer;

const int kPursuitVelBufferSize = 30;

@interface PursuitShip : NpcShip <Pursuer> {
    BOOL mPursuitEnded;
	PursuitState mDuelState;
	ShipActor *mEnemy;
	
	TargetTracer *mTracer;
	//int mEnemyVelocityIter;
	//b2Vec2 mEnemyVelocity[kPursuitVelBufferSize];
}

@property (nonatomic,assign) PursuitState duelState;
@property (nonatomic,retain) ShipActor *enemy;

- (void)requestNewEnemy;
- (BOOL)isNavigationDisabled;
- (void)playerCamouflageActivated:(BOOL)value;
- (void)endPursuit;

@end
