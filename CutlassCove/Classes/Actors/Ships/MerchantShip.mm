//
//  MerchantShip.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 21/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "MerchantShip.h"
#import "PlayerShip.h"
#import "PirateShip.h"
#import "Cannonball.h"
#import "Box2DUtils.h"
#import "Globals.h"

@interface MerchantShip ()

- (void)flash;
- (BOOL)isCloseToDocking;

@end


@implementation MerchantShip

@synthesize defender = mDefender;

- (id)initWithActorDef:(ActorDef *)def key:(NSString *)key {
    if (self = [super initWithActorDef:def key:key]) {
		mTargetAcquired = NO;
		mGoods = YES;
        mIsDimming = YES;
        mFlashColor = 0xffffff;
        mDefender = 0;
    }
    return self;
}

- (void)negotiateTarget:(ShipActor *)target {
	if (YES || mTargetAcquired == YES || mInWhirlpoolVortex == YES || mDocking == YES || mBody == 0) // Disabled since v2.0
		return;
	b2Vec2 bodyPos = mBody->GetPosition();
	b2Vec2 enemyPos = target.body->GetPosition();
	b2Vec2 dest = bodyPos - enemyPos;
	
	b2Vec2 linearVel = mBody->GetLinearVelocity();
	float angleToTarget = Box2DUtils::signedAngle(dest, linearVel);
	int angleInDegrees = (int)SP_R2D(angleToTarget);
	
	mTargetSide = (angleInDegrees > 0) ? PortSide : StarboardSide;
	b2Vec2 closest = [target closestPositionTo:mBody->GetPosition()];
	mTargetX = M2PX(closest.x);
	mTargetY = M2PY(closest.y);
	mTargetAcquired = YES;
}

- (void)advanceTime:(double)time {
	[super advanceTime:time];
	
	if (mRemoveMe || mDocking)
		return;
	if (mTargetAcquired == YES) {
		Cannonball *cannonball = [self fireCannon:mTargetSide trajectory:1.0f];
		[cannonball calculateTrajectoryFromTargetX:mTargetX targetY:mTargetY];
		mTargetAcquired = NO;
	}
    
    if ([self isCloseToDocking])
        [self flash];
    else
        [(SPImage *)[mCurrentCostumeImages objectAtIndex:mCostumeIndex] setColor:0xffffff];
}

- (void)saveFixture:(b2Fixture *)fixture atIndex:(int)index {
	[super saveFixture:fixture atIndex:index];
	
	switch (index) {
		case 7:
			mDefender = fixture;
			break;
		default: break;
	}
}

//- (bool)preSolve:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
//	if (fixtureSelf == mDefender) {
//		if (NO && mReloading == NO && [other isKindOfClass:[PlayerShip class]]) { // Disabled since v2.0
//			PlayerShip *ship = (PlayerShip *)other;
//			
//			if (ship.isCamouflaged == NO && ship.motorBoating == NO)
//				[self negotiateTarget:ship];
//		}
//		return false;
//	} else {
//		return [super preSolve:other fixtureSelf:fixtureSelf fixtureOther:fixtureOther contact:contact];
//	}
//}

- (void)flash {
    if (mScene.raceEnabled)
        return;
    
    if (mIsDimming) {
        uint flashIncrement = 0x060606;
        mFlashColor = mFlashColor - flashIncrement;
        
        if (mFlashColor < 0x888888)
            mIsDimming = NO;
    } else {
        uint flashIncrement = 0x060606;
        mFlashColor = mFlashColor + flashIncrement;
        
        if (mFlashColor > 0xf8f8f8)
            mIsDimming = YES;
    }
    
    [(SPImage *)[mCurrentCostumeImages objectAtIndex:mCostumeIndex] setColor:mFlashColor];
}

- (BOOL)isCloseToDocking {
    BOOL result = NO;
    
    if (GCTRL.thisTurn.isGameOver == NO && mInWhirlpoolVortex == NO) {
        switch (mDestination.finish) {
            case kPlaneIdNorth:
                if (self.x > (mScene.viewWidth - 60))
                    result = YES;
                break;
            case kPlaneIdEast:
                if (self.y > (mScene.viewHeight - 95))
                    result = YES;
                break;
            case kPlaneIdSouth:
                if (self.x < 60)
                    result = YES;
                break;
            case kPlaneIdWest:
                if (self.y < 60)
                    result = YES;
                break;
            case kPlaneIdTown:
                if (self.x < 70 && self.y < 70)
                    result = YES;
                break;
            default:
                result = NO;
                break;
        }
    }
    
    return result;
}

- (BOOL)hasBootyGoneWanting:(SPSprite *)shooter {
	return [shooter isKindOfClass:[PirateShip class]];
}

- (void)creditPlayerSinker {
	[mScene.achievementManager merchantShipSunk:self];
}

- (void)zeroOutFixtures {
	[super zeroOutFixtures];
	
	mDefender = 0;
}

@end
