//
//  PirateShip.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 20/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "PirateShip.h"
#import "Prisoner.h"
#import "TargetTracer.h"
#import "PrisonerProp.h"
#import "PlayerShip.h"
#import "GameController.h"
#import "Globals.h"

const float kPirateLeashClearance = 110.0f; //35.0f;
const float kPirateDeckClearance = 25.0f;

@interface PirateShip ()

- (BOOL)shouldBeginPirating;
- (BOOL)isOutOfCombatBounds;

@end


@implementation PirateShip

- (id)initWithActorDef:(ActorDef *)def key:(NSString *)key {
    if (self = [super initWithActorDef:def key:key]) {
		mBootyGoneWanting = NO;
        mLeash = kPirateLeashClearance;
    }
    return self;
}

- (void)setupShip {
    [super setupShip];
    
    // Shorten leash and reload interval as game gets harder
    mLeash = MAX(50.0f, kPirateLeashClearance / MAX(1.0f,mAiModifier));
    mReloadInterval = MAX(5.0f, mReloadInterval / MAX(1.0f,mAiModifier));
}

- (void)dropLoot {
    GameController *gc = GCTRL;
    
	if (gc.thisTurn.isGameOver || [gc.playerShip isFullOnPrisoners] || self.turnID != gc.thisTurn.turnID || mPreparingForNewGame)
		return;
	
	PrisonerProp *prisoner = [[PrisonerProp alloc] initWithCategory:CAT_PF_DECK];
	prisoner.visible = NO;
	[prisoner positionAtX:self.x y:self.y];
	[mScene addProp:prisoner];
	[prisoner release];
}

- (void)creditPlayerSinker {
	[mScene.achievementManager pirateShipSunk:self];
}

- (float)navigate {	
	float sailForce = [super navigate];
	
	if (mDuelState == PursuitStateFerrying || mDuelState == PursuitStateOutOfBounds) {
		if ([self shouldBeginPirating])
			[self didReachDestination];
	}
	
	return sailForce;
}

- (void)advanceTime:(double)time {
	[super advanceTime:time];
	
	if (mRemoveMe || mDocking)
		return;
	
	if ([self isOutOfCombatBounds])
		[self setDuelState:PursuitStateOutOfBounds];
}

- (BOOL)shouldBeginPirating {
	BOOL unleashed = NO, visibleToPlayer = NO;
	
	visibleToPlayer = (self.x > mLeash && self.x < (mScene.viewWidth - mLeash));
	visibleToPlayer = visibleToPlayer && (self.y > mLeash && self.y < (mScene.viewHeight - (kPirateDeckClearance + mLeash)));
	
	if (visibleToPlayer && mBody) {
		b2Vec2 bodyPos = mBody->GetPosition();
		b2Vec2 spawnPoint = mDestination.loc;
		b2Vec2 dist = bodyPos - spawnPoint;
	
		if (dist.LengthSquared() > (P2M(150) * P2M(150)))
			unleashed = YES;
	}
	
	return unleashed;
}

- (BOOL)isOutOfCombatBounds {
	BOOL result = (mDuelState == PursuitStateChasing || mDuelState == PursuitStateAiming);
	return (result && (self.x < 0.0f || self.x > mScene.viewWidth || self.y < 0.0f || self.y > mScene.viewHeight));
}

- (void)dealloc {
	[super dealloc];
}

@end
