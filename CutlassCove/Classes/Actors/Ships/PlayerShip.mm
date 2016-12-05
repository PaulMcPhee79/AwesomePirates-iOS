//
//  PlayerShip.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 6/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "PlayerShip.h"
#import "PlayerDetails.h"
#import "ShipDetails.h"
#import	"NpcShip.h"
#import "CannonDetails.h"
#import "Cannonball.h"
#import "CannonFactory.h"
#import "ShipDeck.h"
#import "Ash.h"
#import "OffscreenArrow.h"
#import "Wake.h"
#import "RayCastClosest.h"
#import "CannonFire.h"
#import "PowderKegActor.h"
#import "NetActor.h"
#import "BrandySlickActor.h"
#import "RaceEvent.h"
#import "Box2DUtils.h"
#import "GameController.h"
#import "Globals.h"


#import "SPEventDispatcher_Extension.h"

const double kCannonSpamInterval = 0.58;
const double kCannonSpamCapacity = 8;

@interface PlayerShip ()

- (NSString *)normalShotType;
- (void)activateCannonProc;
- (void)deactivateCannonProc;
- (void)playCannonProcSound;
- (void)updateCannonInfamyBonus;
- (void)calcSailForces;
- (float)calcCannonRange;
- (float)cannonTrajectoryMaxFromDetails:(CannonDetails *)details;
- (b2Vec2)cannonVectorForSide:(int)side from:(b2Vec2)from;
//- (Cannonball *)fireAssistedCannon:(int)side trajectory:(float)trajectory;
- (float)recentCannonAccuracy;
- (float)requiredCannonAccuracy;
- (void)disableOverheatedCannons:(BOOL)disable;
- (void)dropPowderKeg;
- (void)dropNextPowderKeg;
- (float)montyNavigate;
- (void)positionReticle;
- (void)chanceAshSpecialProc;
- (void)onPlayerCannonFired:(PlayerCannonFiredEvent *)event;
- (void)onEmergedInPresent:(SPEvent *)event;
- (void)onNetDespawned:(SPEvent *)event;
- (void)onBrandySlickDespawned:(SPEvent *)event;
- (void)onCostumeFaded:(SPEvent *)event;

@end


@implementation PlayerShip

@synthesize shipDeck = mShipDeck;
@synthesize ashProc = mAshProc;
@synthesize isCamouflaged = mCamouflaged;
@synthesize isFlyingDutchman = mFlyingDutchman;
@synthesize motorBoating = mMotorBoatingSob;
@synthesize suspendedMode = mSuspendedMode;
@synthesize sinking = mSinking;
@synthesize monty = mMonty;
@synthesize kegsRemaining = mKegsRemaining;
@synthesize net = mNet;
@synthesize brandySlick = mBrandySlick;
@synthesize cannonInfamyBonus = mCannonInfamyBonus;
@synthesize speedRatingBonus = mSpeedRatingBonus;
@synthesize controlRatingBonus = mControlRatingBonus;
@synthesize cannonSpamCapacitor = mCannonSpamCapacitor;
@dynamic anchored,assistedAiming,procType,isPlankingEnqueued;


- (id)initWithActorDef:(ActorDef *)def {
    if (self = [super initWithActorDef:def key:@"Player"]) {
		mCamouflaged = NO;
		mFlyingDutchman = NO;
		mSinking = NO;
		mMotorBoatingSob = NO;
		mTimeTravelling = NO;
		mSuspendedMode = NO;
		mDroppingKegs = NO;
        mPlankEnabled = YES;
        mFailedMotorboating = NO;
        mMonty = MSFirstMate;
        mMontyDest = nil;
		mDutchmanCostumeImages = nil;
		mCamoCostumeImages = nil;
		mAshProc = [[AshProc alloc] init];
		mShipDeck = nil;
		mOffscreenArrow = nil;
        mRaceUpdateIndex = -1;
        mDashDialFlashTimer = 0.0;
		//mWakePeriod = 4.0f;
		mCrewAiming = 0;
        mTripCounter = 2;
        mPowderKegTimer = 0.0;
        mAccuracyCooldownTimer = 0.0;
		mCannonRange = sqrtf(mScene.viewWidth * mScene.viewWidth + mScene.viewHeight * mScene.viewHeight) / PPM;
        mGravityFactor = MAX(0.5f, (SP_IS_FLOAT_EQUAL(GCTRL.fpsFactor, 0)) ? 2 : 1.0f / GCTRL.fpsFactor);
		mSpeedNormalizer = 1;
		mKegsRemaining = 0;
		mNet = nil;
		mBrandySlick = nil;
		mResOffset = nil;
		mCannonInfamyBonus = [[CannonballInfamyBonus alloc] init];
        
        mRecentHitCount = 0;
        mRecentShotCount = 0;
        mCannonsOverheated = NO;
        mCannonSpamCapacitor = 0;
		
		mSpeedRatingBonus = 0;
		mControlRatingBonus = 0;
		
		if (mScene.assistedAiming)
			mCrewAiming = new RayCastClosest(mBody);
    }
    return self;
}

- (void)setupShip {
	assert(mCannonDetails);
	
    mCannonDetails.shotType = @"single-shot_";
	mResOffset = [[RESM itemOffsetWithAlignment:RALowerRight] retain];
	
	if (mWakeCount == -1) {
        if (mMotorBoatingSob) {
            mWakeCount = (2.0f * mShipDetails.speedRating + mSpeedRatingBonus + 10) * mSpeedModifier;
            mWakePeriod = [Wake defaultWakePeriod] * GCTRL.fpsFactor / 2.5f;
        }
        //else {
        //    mWakeCount = (1.5f * mShipDetails.speedRating + mSpeedRatingBonus + 7) * mSpeedModifier;
        //}
    }
	[super setupShip];
	
	[self calcSailForces];
    
    if (mMotorBoatingSob)
        mWake.ripplePeriod = [Wake minRipplePeriod];
    else
        mWake.ripplePeriod = MIN([Wake defaultRipplePeriod], [Wake defaultRipplePeriod] * MAX([Wake minRipplePeriod], [ShipActor defaultSailForceMax] / MAX(1, mSailForceMax)));
	
	// Costume
	mCostume = [[SPSprite alloc] init];
	[self addChild:mCostume];
	
	if (mMotorBoatingSob) {
		mCostumeImages = [[self setupCostumeForTexturesStartingWith:@"ship-pf-speedboat_" cacheGroup:nil] retain];
	} else {
		mCostumeImages = [[self setupCostumeForTexturesStartingWith:@"ship-pf-sloop_" cacheGroup:nil] retain];
		mDutchmanCostumeImages = [[self setupCostumeForTexturesStartingWith:@"ship-pf-dutchman_" cacheGroup:nil] retain];
		mCamoCostumeImages = [[self setupCostumeForTexturesStartingWith:@"ship-pf-navy_" cacheGroup:TM_CACHE_PF_SHIPS] retain];
	}
	
	[self enqueueCostumeImages:mCostumeImages];
	
	mOffscreenArrow = [[OffscreenArrow alloc] init];
	[mScene addProp:mOffscreenArrow];
	
	if (mShipDeck != nil) {
		[mShipDeck.leftCannon addEventListener:@selector(onPlayerCannonFired:) atObject:self forType:CUST_EVENT_TYPE_PLAYER_CANNON_FIRED];
		[mShipDeck.rightCannon addEventListener:@selector(onPlayerCannonFired:) atObject:self forType:CUST_EVENT_TYPE_PLAYER_CANNON_FIRED];
		mShipDeck.leftCannon.showReticle = !mScene.assistedAiming;
		mShipDeck.leftCannon.reloadInterval = mCannonDetails.reloadInterval;
        [mShipDeck.leftCannon overheat:NO];
		mShipDeck.leftCannon.elevationFactor = [self cannonTrajectoryMaxFromDetails:mCannonDetails];
		mShipDeck.rightCannon.showReticle = !mScene.assistedAiming;
		mShipDeck.rightCannon.reloadInterval = mCannonDetails.reloadInterval;
        [mShipDeck.rightCannon overheat:NO];
		mShipDeck.rightCannon.elevationFactor = [self cannonTrajectoryMaxFromDetails:mCannonDetails];
	}
	[self updateCannonInfamyBonus];
}

- (NSArray *)setupCostumeForTexturesStartingWith:(NSString *)texturePrefix cacheGroup:(NSString *)cacheGroup {
	if (mMotorBoatingSob == NO)
		return [super setupCostumeForTexturesStartingWith:texturePrefix cacheGroup:cacheGroup];
	mNumCostumeImages = 11;
	mCostumeUprightIndex = mNumCostumeImages / 2;
	
	NSArray *costumeTextures = [mScene texturesStartingWith:texturePrefix cacheGroup:cacheGroup];
	NSMutableArray *images = [NSMutableArray arrayWithCapacity:mNumCostumeImages];
	mCostumeIndex = mCostumeUprightIndex;
	
	for (int i = 0, frameIndex = mCostumeIndex, frameIncrement = -1; i < mNumCostumeImages; ++i) {
		SPImage *image = [SPImage imageWithTexture:[costumeTextures objectAtIndex:frameIndex]];
		image.scaleX = (i < mCostumeIndex) ? -1 : 1;
		image.x = (self.motorBoating ? -10 : -12) * image.scaleX;
		image.y = -mShipDetails.rudderOffset;
		image.visible = (i == mCostumeIndex);
		[images addObject:image];
		
		if (frameIndex == 0)
			frameIncrement = 1;
		frameIndex += frameIncrement;
	}
	
	return images;
}

- (void)enableSuspendedMode:(BOOL)enable {
    mSuspendedMode = enable;
}

- (void)fpsFactorChanged:(float)value {
    [super fpsFactorChanged:value];
    
    if (mMotorBoatingSob)
        mWakePeriod = 2.0f * value;
    mGravityFactor = MAX(0.5f, (SP_IS_FLOAT_EQUAL(value, 0)) ? 2 : 1.0f / value);
    [mShipDeck.helm fpsFactorChanged:value];
}

- (void)flip:(BOOL)enable {
    [mOffscreenArrow flip:enable];
}

- (void)updateCostumeWithAngularVelocity:(float)angVel {
	if (mMotorBoatingSob == NO) {
		[super updateCostumeWithAngularVelocity:angVel];
		return;
	}

	int index = mCostumeIndex;
	float fabsAngVel = fabsf(angVel);
	
	// -3.55 -> 3.55
	//if (fabsAngVel > (mAngVelUpright + 5.0f)) index = 0; // Unreachable with current forces.
	
	if (fabsAngVel < mAngVelUpright) index = mCostumeUprightIndex;
	else if (fabsAngVel > (mAngVelUpright + 2.7f)) index = 0;
	else if (fabsAngVel > (mAngVelUpright + 2.1f) && fabsAngVel < (mAngVelUpright + 2.5f)) index = 1;
	else if (fabsAngVel > (mAngVelUpright + 1.5f) && fabsAngVel < (mAngVelUpright + 1.9f)) index = 2;
	else if (fabsAngVel > (mAngVelUpright + 0.9f) && fabsAngVel < (mAngVelUpright + 1.3f)) index = 3;
	else if (fabsAngVel > (mAngVelUpright + 0.3f) && fabsAngVel < (mAngVelUpright + 0.7f)) index = 4;
	else return;
	
	SPImage *image = (SPImage *)[mCurrentCostumeImages objectAtIndex:mCostumeIndex];
	image.visible = NO;
	
	if (index != mCostumeUprightIndex && angVel < 0)
		index = mNumCostumeImages - (index+1);
	
	image = (SPImage *)[mCurrentCostumeImages objectAtIndex:index];
	image.visible = YES;
	mCostumeIndex = index;
}

- (CannonballInfamyBonus *)cannonInfamyBonus {
	return [[mCannonInfamyBonus copy] autorelease];
}

- (BOOL)anchored {
	return NO; //(mShipDeck != nil) ? mShipDeck.anchor.deployed : NO;
}

- (BOOL)assistedAiming {
	return mScene.assistedAiming;
}

- (void)assistedAimingChanged:(BOOL)value {
	if (value == NO && mCrewAiming != 0) {
		delete mCrewAiming;
		mCrewAiming = 0;
	} else if (value == YES && mCrewAiming == 0) {
		mCrewAiming = new RayCastClosest(mBody);
	}
	mShipDeck.leftCannon.showReticle = !value;
	mShipDeck.rightCannon.showReticle = !value;
}

- (void)setMotorBoating:(BOOL)value {
	if (value == YES && mMotorBoatingSob == NO) {
        self.wakeFactor /= 2;
		mShipDeck.leftCannon.activated = NO;
		mShipDeck.rightCannon.activated = NO;
	} else if (value == NO && mMotorBoatingSob == YES) {
        self.wakeFactor *= 2;
		mShipDeck.leftCannon.activated = !mSinking;
		mShipDeck.rightCannon.activated = !mSinking;
	}
	mMotorBoatingSob = value;
}

- (void)setMonty:(MontyState)monty {
    if (monty == mMonty)
        return;
    
    switch (monty) {
        case MSFirstMate:
            mOffscreenArrow.enabled = YES;
            [mShipDeck enableCombatControls:YES];
            break;
        case MSSkipper:
            if (mMontyDest == nil)
                mMontyDest = [[Destination alloc] init];
            [mMontyDest setDest:b2Vec2(P2MX(mScene.viewWidth / 2), P2MY(mScene.viewHeight / 2))];
            mOffscreenArrow.enabled = NO;
            [mShipDeck enableCombatControls:NO];
            break;
        case MSTripper:
            mTripCounter = 2;
            mOffscreenArrow.enabled = NO;
            [mShipDeck enableCombatControls:NO];
            [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_MONTY_SKIPPERED]];
            break;
        case MSConsipirator:
            mOffscreenArrow.enabled = NO;
            [mShipDeck enableCombatControls:NO];
            break;
        case MSMutineer:
            mOffscreenArrow.enabled = NO;
            [mShipDeck enableCombatControls:NO];
            
            if (mMontyDest == nil)
                mMontyDest = [[Destination alloc] init];
            [mMontyDest setDest:b2Vec2(P2MX(mScene.viewWidth / 2), P2MY(-5 * mScene.viewHeight))];
            break;
        default:
            assert(0);
            break;
    }
    
    mMonty = monty;
}

- (Prisoner *)addRandomPrisoner {
    ++mScene.achievementManager.hostages;
    return [super addRandomPrisoner];
}

- (uint)procType {
	uint value = 0;
	
	if ([mAshProc isActive])
		value = mAshProc.proc;
	return value;
}

- (BOOL)isPlankingEnqueued {
    return (mShipDeck.plank.state == PlankStateDeadManWalking);
}

- (void)setAshProc:(AshProc *)ashProc {
	if (ashProc != mAshProc) {
		[self deactivateCannonProc];
		[mAshProc autorelease];
		mAshProc = [ashProc retain];
		
		if (ashProc) {
            if (ashProc.chargesRemaining == ashProc.totalCharges)
                [mScene.objectivesManager progressObjectiveWithEventType:OBJ_TYPE_ASH_PICKED_UP tag:ashProc.proc];
			[mShipDeck.comboDisplay setupProcWithTexturePrefix:ashProc.texturePrefix];
			
			if ([ashProc isActive])
				[self activateCannonProc];
		}
	}
}

- (void)activateCannonProc {
	[mShipDeck.comboDisplay activateProc];
	mCannonDetails.shotType = mAshProc.texturePrefix;
	[self updateCannonInfamyBonus];
}

- (void)deactivateCannonProc {
	[mShipDeck.comboDisplay deactivateProc];
	mCannonDetails.shotType = [self normalShotType];
	[self updateCannonInfamyBonus];
}

- (void)playCannonProcSound {
	//[mScene.audioPlayer playSoundWithKey:@"CannonProc"];
}

- (void)updateCannonInfamyBonus {
	mCannonInfamyBonus.ricochetBonus = mCannonDetails.ricochetBonus;
	
	if (mAshProc && [mAshProc isActive]) {
		mCannonInfamyBonus.procType = mAshProc.proc;
		mCannonInfamyBonus.procMultiplier = mAshProc.multiplier;
		mCannonInfamyBonus.procAddition = mAshProc.addition;
		mCannonInfamyBonus.ricochetAddition = mAshProc.ricochetAddition;
		mCannonInfamyBonus.ricochetMultiplier = mAshProc.ricochetMultiplier;
        mCannonInfamyBonus.miscBitmap = (self.isFlyingDutchman) ? ASH_DUTCHMAN_SHOT : 0;
	} else {
		mCannonInfamyBonus.procType = 0;
		mCannonInfamyBonus.procMultiplier = 1;
		mCannonInfamyBonus.procAddition = 0;
		mCannonInfamyBonus.ricochetAddition = 0;
		mCannonInfamyBonus.ricochetMultiplier = 1;
        mCannonInfamyBonus.miscBitmap = (self.isFlyingDutchman) ? ASH_DUTCHMAN_SHOT : 0;
	}
}

- (NSString *)normalShotType {
	return ((mFlyingDutchman) ? @"dutchman-shot_" : @"single-shot_");
}

- (void)calcSailForces {
	if (mBody == 0)
		return;
	float speedRating = (mShipDetails.speedRating + mSpeedRatingBonus) * mSpeedModifier;
	float controlRating = (mShipDetails.controlRating + mControlRatingBonus) * mControlModifier;

	mSpeedNormalizer = (mMotorBoatingSob ? [Potion swiftnessFactorForPotion:[mScene potionForKey:POTION_SWIFTNESS]] * 2.0f : 2.4f) * ((16 + speedRating) / 20.0f) + (2.0f / 10.0f);
	mSailForceMax = 10 * mBody->GetMass() * mSpeedNormalizer;
	mSailForce = mSailForceMax;
	mTurnForceMax = 1.65f * mBody->GetMass() * ((21 + controlRating) / 20.0f);
    mTurnForceMax = mTurnForceMax * (mMotorBoatingSob ? 1.15f : 1.5f); // 1.5f because ships are 50% larger since v2.0.
}

- (float)calcCannonRange {
    return mCannonRange;
    
    
    
	Cannonball *cannonball = [[CannonFactory munitions] createCannonballForShip:self atSide:PortSide withTrajectory:SP_D2R(22.5f)];
	b2Vec2 linearVelocity = cannonball.body->GetLinearVelocity();
	[cannonball destroyActorBody];
	
	float maxFrames = SP_D2R(22.5f * [self cannonTrajectoryMaxFromDetails:mCannonDetails]) / kGravity;
	float maxTime = (maxFrames / kGravity) / GCTRL.fps; // In seconds
	float speed = (float)linearVelocity.Length();
	mCannonRange = PPM * maxTime * speed; // PPM to convert from m/s to pixels/s
	return mCannonRange;
}

- (float)cannonTrajectoryMaxFromDetails:(CannonDetails *)details {
    return 1.0f; 
    
	//return (9 + details.rangeRating) / 16.0f; // Max details.rangeRating will be 7 which would return a unity scaling factor.
}

- (void)setCannonDetails:(CannonDetails *)details {
	[super setCannonDetails:details];
	[self calcCannonRange];
    
    if (details) {
        mShipDeck.leftCannon.bitmap = details.bitmap;
        mShipDeck.rightCannon.bitmap = details.bitmap;
    }
}

- (void)playFireCannonSound {
    // Moved to PlayerCannon class
	//if (mCannonSoundEnabled == YES)
	//	[mScene.audioPlayer playSoundWithKey:@"PlayerCannon" volume:1.0f];
}

- (void)onPlayerCannonFired:(PlayerCannonFiredEvent *)event {
	if (mShipDeck == nil || mSinking == YES)
		return;
    
    PlayerCannon *leftCannon = mShipDeck.leftCannon, *rightCannon = mShipDeck.rightCannon;
    
    int cannonFireMap = [self fireAssistedCannons];
    BOOL manual = cannonFireMap == 0, silentCannon = false;
    
    if ((cannonFireMap & (1 << (int)PortSide)) == (1 << (int)PortSide)) {
        [leftCannon fire:silentCannon dispatch:false];
        silentCannon = true;
    }
    
    if ((cannonFireMap & (1 << (int)StarboardSide)) == (1 << (int)StarboardSide))
        [rightCannon fire:silentCannon dispatch:false];
    
    if (manual) {
        int numShots = 1;
        BOOL hasProcced = [mAshProc isActive];
        Cannonball *cannonball = nil;
        CannonballGroup *grp = [CannonballGroup cannonballGroupWithHitQuota:1];
        [mScene addProp:grp];
        
        if (hasProcced && mAshProc.proc == ASH_MOLTEN)
            numShots += 2;
        
        for (ShipSides side = PortSide; side <= StarboardSide; ++side) {
            PlayerCannon *playerCannon = [mShipDeck cannonOnSide:side];
            if (!playerCannon || playerCannon.reloading || playerCannon.overheated)
                continue;
            
            cannonFireMap |= 1 << side;
         
            if (numShots > 1) {
                float perpForce = 0;
                Cannonball *cannonball = nil;
                CannonballGroup *grp = [CannonballGroup cannonballGroupWithHitQuota:1];
                [mScene addProp:grp];
                
                for (int i = 0; i < numShots; ++i) {
                    if (i == 0) perpForce = 0;
                    else if (i == 1) perpForce = 3.5f;
                    else if (i == 2) perpForce = -3.5f;
                    else if (i == 3) perpForce = 5.0f;
                    else if (i == 4) perpForce = -5.0f;
                    else if (i == 5) perpForce = 6.5f;
                    else if (i == 6) perpForce = -6.5f;
                    else perpForce = 0;
                    
                    cannonball = [self fireCannon:side trajectory:event.cannon.elevation/3.0f];
                    
                    if (i != 0)
                        [self applyPerpendicularImpulse:perpForce toCannonball:cannonball];
                    cannonball.hasProcced = hasProcced;
                    [grp addCannonball:cannonball];
                    mCannonSoundEnabled = NO;
                }
                mCannonSoundEnabled = YES;
            } else {
                cannonball = [self fireCannon:side trajectory:event.cannon.elevation/3.0f];
                [grp addCannonball:cannonball];
            }
        }
        
        if ((cannonFireMap & (1 << (int)PortSide)) == (1 << (int)PortSide)) {
            [leftCannon fire:silentCannon dispatch:false];
            silentCannon = true;
        }
        
        if ((cannonFireMap & (1 << (int)StarboardSide)) == (1 << (int)StarboardSide))
            [rightCannon fire:silentCannon dispatch:false];
    }
    
	if ([mAshProc isActive] && [mAshProc consumeCharge] == 0) {
		[self deactivateCannonProc];
		[mAshProc deactivate];
	}
    
    mCannonSpamCapacitor += event.cannon.reloadInterval + kCannonSpamInterval;
    
    if (self.isFlyingDutchman == NO && mCannonSpamCapacitor > kCannonSpamCapacity && [self recentCannonAccuracy] < [self requiredCannonAccuracy])
        [self disableOverheatedCannons:YES];
    //NSLog(@"Cannon Accuracy: %f", [self recentCannonAccuracy]);
}

- (b2Vec2)cannonVectorForSide:(int)side from:(b2Vec2)from {
    // Allow crew-assisted cannons to shoot 1.5 times further, because there is no visual cue as to their range.
	//b2Vec2 to(0.0f, (1.5f * mCannonRange) / PPM); // PPM to convert from pixels to meters
    
    b2Vec2 to(0.0f, mCannonRange); // Roughly the diagonal length of the playfield
	float32 angle = ((mBody) ? mBody->GetAngle() : 0) + ((side == PortSide) ? PI_HALF : -PI_HALF);
	Box2DUtils::rotateVector(to, angle);
	to.x += from.x;
	to.y += from.y;
	return to;
}

//- (Cannonball *)fireAssistedCannon:(int)side trajectory:(float)trajectory {
//    if (!mBody)
//        return nil;
//
//    b2CircleShape *bowShape = (b2CircleShape *)mBow->GetShape();
//	b2CircleShape *sternShape = (b2CircleShape *)mStern->GetShape();
//    b2CircleShape *cannonShape = (b2CircleShape *)[self portOrStarboard:side]->GetShape();
//    
//	mCrewAiming->ResetFixture();
//    b2Vec2 cannonPos = mBody->GetWorldPoint(cannonShape->m_p);
//	b2Vec2 from = cannonPos;
//	b2Vec2 to = [self cannonVectorForSide:side from:from];
//	mScene.world->RayCast(mCrewAiming, from, to);
//    
//    b2Vec2 bowPos = mBody->GetWorldPoint(bowShape->m_p), sternPos = mBody->GetWorldPoint(sternShape->m_p);
//    b2Vec2 shipVector = bowPos - sternPos; // Points from stern to bow (ie in the direction of the ship's forward movement)
//	
//    // If the shot is not aimed perfectly, allow for a cone of leniency left and right of the real target.
//	if (mCrewAiming->mFixture == 0) {
//        b2Vec2 shipVectorAdjust = shipVector;
//        shipVectorAdjust *= 2.5f;
//        
//        b2Vec2 toAdjust = to;
//        toAdjust += shipVectorAdjust;
//		mScene.world->RayCast(mCrewAiming, from, toAdjust);
//        
//        if (mCrewAiming->mFixture == 0) {
//            toAdjust = to;
//            toAdjust -= shipVectorAdjust;
//            mScene.world->RayCast(mCrewAiming, from, toAdjust);
//#if 1
//        }
//    }
//#else
//            if (mCrewAiming->mFixture == 0)
//                NSLog(@"XXXXXXXXX MISS");
//            else
//                NSLog(@"$$$$$$$ STERN ADJUSTED HIT");
//        } else {
//            NSLog(@"$$$$$$$ BOW ADJUSTED HIT");
//        }
//	} else {
//        NSLog(@"$$$$$$$ DIRECT HIT");
//    }
//#endif
//	
//	Cannonball *cannonball = nil;
//	
//	if (mCrewAiming->mFixture) {
//		b2Body *body = mCrewAiming->mFixture->GetBody();
//		
//		if (body) {
//			BOOL hasProcced = [mAshProc isActive];
//			float perpForce = 0;
//			CannonballGroup *grp = nil;
//			int numShots = 1;
//			
//			//if (mFlyingDutchman)
//			//	numShots += [Idol countForIdol:[mScene idolForKey:VOODOO_SPELL_FLYING_DUTCHMAN]];
//			if ([mAshProc isActive] && mAshProc.proc == ASH_MOLTEN) numShots += 2;
//			
//            //Potion *potion = [GCTRL.gameStats potionForKey:POTION_INTENSITY];
//            //numShots += [Potion intensityCountForPotion:potion];
//            
//			if (numShots > 1) {
//				grp = [CannonballGroup cannonballGroupWithHitQuota:1];
//				[mScene addProp:grp];
//			}
//			
//			for (int i = 0; i < numShots; ++i) {
//                if (i == 0) perpForce = 0;
//				else if (i == 1) perpForce = 1.75f;
//				else if (i == 2) perpForce = -1.75f;
//				else if (i == 3) perpForce = 3.5f;
//				else if (i == 4) perpForce = -3.5f;
//                else if (i == 5) perpForce = 4.75f;
//				else if (i == 6) perpForce = -4.75f;
//				else perpForce = 0;
//
//				b2Vec2 target = body->GetPosition();
//				//cannonball = [[CannonFactory munitions] createCannonballForShip:self atSide:side withTrajectory:1.0f];
//                cannonball = [[CannonFactory munitions] createCannonballForShip:self shipVector:shipVector atSide:side withTrajectory:1.0f forTarget:target];
//				[cannonball calculateTrajectoryFromTargetX:M2PX(target.x) targetY:M2PY(target.y)];
//				
//				// Add target's linear velocity to ensure we hit it
//				b2Vec2 linearVelocity = body->GetLinearVelocity();
//				cannonball.body->SetLinearVelocity(cannonball.body->GetLinearVelocity() + linearVelocity);
//				
//				[mScene addActor:cannonball];
//				[cannonball setupCannonball];
//				
//				[self animateCannonSmokeWithX:cannonball.px y:cannonball.py rotation:(self.rotation + ((side == PortSide) ? -PI_HALF : PI_HALF))];
//				
//				if (i != 0)
//					[self applyPerpendicularImpulse:perpForce toCannonball:cannonball];
//				cannonball.hasProcced = hasProcced;
//				[grp addCannonball:cannonball];
//				mCannonSoundEnabled = NO;
//			}
//			mCannonSoundEnabled = YES;
//			//NSLog(@"CREW-ASSISTED SHOT TAKEN.");
//		}
//	}
//	return cannonball;
//}

- (int)fireAssistedCannons {
    if (!mBody || !mShipDeck)
        return nil;
    
    int cannonFiredMap = 0;
    CannonballGroup *grp = nil;
    
    b2CircleShape *bowShape = (b2CircleShape *)mBow->GetShape();
	b2CircleShape *sternShape = (b2CircleShape *)mStern->GetShape();
    
    for (ShipSides side = PortSide; side <= StarboardSide; ++side) {
        PlayerCannon *playerCannon = [mShipDeck cannonOnSide:side];
        if (!playerCannon || playerCannon.reloading || playerCannon.overheated)
            continue;
        
        b2CircleShape *cannonShape = (b2CircleShape *)[self portOrStarboard:side]->GetShape();
        
        mCrewAiming->ResetFixture();
        b2Vec2 cannonPos = mBody->GetWorldPoint(cannonShape->m_p);
        b2Vec2 from = cannonPos;
        b2Vec2 to = [self cannonVectorForSide:side from:from];
        mScene.world->RayCast(mCrewAiming, from, to);
        
        b2Vec2 bowPos = mBody->GetWorldPoint(bowShape->m_p), sternPos = mBody->GetWorldPoint(sternShape->m_p);
        b2Vec2 shipVector = bowPos - sternPos; // Points from stern to bow (ie in the direction of the ship's forward movement)
        
        // If the shot is not aimed perfectly, allow for a cone of leniency left and right of the real target.
        if (mCrewAiming->mFixture == 0) {
            for (int retry = 0; retry < 2 && mCrewAiming == 0; ++retry) {
                b2Vec2 shipVectorAdjust = shipVector;
                shipVectorAdjust *= retry + 1;
                b2Vec2 toAdjust = to;
                toAdjust += shipVectorAdjust;
                mScene.world->RayCast(mCrewAiming, from, toAdjust);
                
                if (mCrewAiming->mFixture == 0) {
                    toAdjust = to;
                    toAdjust -= shipVectorAdjust;
                    mScene.world->RayCast(mCrewAiming, from, toAdjust);
                }
            }
        }

        Cannonball *cannonball = nil, *prevCannonball = nil;
        
        if (mCrewAiming->mFixture == nil)
            mCrewAiming->mFixture = mCrewAiming->mGlancingFixture;

        if (mCrewAiming->mFixture) {
            b2Body *body = mCrewAiming->mFixture->GetBody();
            
            if (body) {
                BOOL hasProcced = [mAshProc isActive];
                float perpForce = 0;
                int numShots = 1;
                
                cannonFiredMap |= 1 << side;
                
                //if (mFlyingDutchman)
                //	numShots += [Idol countForIdol:[mScene idolForKey:VOODOO_SPELL_FLYING_DUTCHMAN]];
                if (hasProcced && mAshProc.proc == ASH_MOLTEN) numShots += 2;
                
                //Potion *potion = [GCTRL.gameStats potionForKey:POTION_INTENSITY];
                //numShots += [Potion intensityCountForPotion:potion];
                
                if (grp == nil) {
                    grp = [CannonballGroup cannonballGroupWithHitQuota:1];
                    [mScene addProp:grp];
                }
                else
                    grp.hitQuota += 1;
                
                for (int i = 0; i < numShots; ++i) {
                    if (i == 0) perpForce = 0;
                    else if (i == 1) perpForce = 3.5f;
                    else if (i == 2) perpForce = -3.5f;
                    else if (i == 3) perpForce = 5.0f;
                    else if (i == 4) perpForce = -5.0f;
                    else if (i == 5) perpForce = 6.5f;
                    else if (i == 6) perpForce = -6.5f;
                    else perpForce = 0;
                    
                    if (!prevCannonball && cannonball)
                        prevCannonball = cannonball;
                    
                    b2Vec2 target = body->GetPosition();
                    //cannonball = [[CannonFactory munitions] createCannonballForShip:self atSide:side withTrajectory:1.0f];
                    cannonball = [[CannonFactory munitions] createCannonballForShip:self shipVector:shipVector atSide:side withTrajectory:1.0f forTarget:target];
                    
                    if (!prevCannonball)
                        [cannonball calculateTrajectoryFromTarget:body];
                    else {
                        [cannonball copyTrajectoryFrom:prevCannonball];
                        cannonball.body->SetLinearVelocity(prevCannonball.body->GetLinearVelocity());
                    }
                    
                    [mScene addActor:cannonball];
                    [cannonball setupCannonball];
                    
                    [self animateCannonSmokeWithX:cannonball.px y:cannonball.py rotation:(self.rotation + ((side == PortSide) ? -PI_HALF : PI_HALF))];
                    
                    if (i != 0)
                        [self applyPerpendicularImpulse:perpForce toCannonball:cannonball];
                    cannonball.hasProcced = hasProcced;
                    [grp addCannonball:cannonball];
                    mCannonSoundEnabled = NO;
                }
                mCannonSoundEnabled = YES;
                //NSLog(@"CREW-ASSISTED SHOT TAKEN.");
            }
        }
    }

    return cannonFiredMap;
}

- (float)recentCannonAccuracy {
    if (mRecentShotCount == 0)
        return 0;
    else
        return (mRecentHitCount / (float)mRecentShotCount);
}

- (float)requiredCannonAccuracy {
    uint day = GCTRL.timeKeeper.day;
    return day < 3 ? 0.65f : (day < 5 ? 0.7f : 0.75f);
}

- (void)disableOverheatedCannons:(BOOL)disable {
    if (disable == mCannonsOverheated)
        return;
    
    if (disable)
    {
        NSLog(@"ACCURACY: %f", [self recentCannonAccuracy]);
        
        mCannonSpamCapacitor = 1.25f * kCannonSpamCapacity; // MIN(mCannonSpamCapacitor, kCannonSpamCapacity);
        [mScene cannonsOverheated];
        [mScene.audioPlayer playSoundWithKey:@"CannonOverheat"];
    }
    [mShipDeck.leftCannon overheat:disable];
    [mShipDeck.rightCannon overheat:disable];
    mCannonsOverheated = disable;
}

- (Cannonball *)fireCannon:(int)side trajectory:(float)trajectory {
	Cannonball *cannonball = [super fireCannon:side trajectory:trajectory * [self cannonTrajectoryMaxFromDetails:mCannonDetails] * (2.0f / mGravityFactor)];
	cannonball.hasProcced = [mAshProc isActive];
	return cannonball;
}

- (bool)preSolve:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
    if (self.monty != MSFirstMate)
        return false;
	if ([other isKindOfClass:[NpcShip class]])
		return (mFlyingDutchman == NO);
	return [super preSolve:other fixtureSelf:fixtureSelf fixtureOther:fixtureOther contact:contact];
}

- (void)tickWakeOdometer:(float)sailForce {
    if (!mMotorBoatingSob)
    {
        [super tickWakeOdometer:sailForce];
        return;
    }
    
    if (mWake == nil)
        return;
    assert(SP_IS_FLOAT_EQUAL(0.0f, mWakeFactor) == NO);
    if (mWakeFactor == 0)
        return;
    
    mOdometer += sailForce / mWakeFactor;
    
    if (mBody && mOdometer >= mWakePeriod) {
        mOdometer = 0.0f;
        
        b2CircleShape *sternShape = (b2CircleShape *)mStern->GetShape();
        b2Vec2 sternPos = mBody->GetWorldPoint(sternShape->m_p);
        [mWake nextRippleAtX:M2PX(sternPos.x) y:M2PY(sternPos.y) rotation:self.rotation];
    }
    
}

- (float)montyNavigate {
	float sailForce = mDrag * mSailForce;
	[self sailWithForce:sailForce];
    
    if (mBody == 0)
        return sailForce;
	
	if (mMontyDest) {
		b2Vec2 bodyPos = mBody->GetPosition();
		b2Vec2 dest = mMontyDest.dest;
		dest -= bodyPos;
		
		if (fabsf(dest.x) < 2.0f && fabsf(dest.y) < 2.0f) {	
            if (self.monty == MSSkipper)
                self.monty = MSTripper;
		} else {
			// Turn towards destination
			b2Vec2 linearVel = mBody->GetLinearVelocity();
			float angleToTarget = Box2DUtils::signedAngle(dest, linearVel);
			
			if (angleToTarget != 0.0f) {
				float turnForce = ((angleToTarget > 0.0f) ? 2.0f : -2.0f) * (mTurnForceMax * (sailForce / mSailForceMax));
				[self turnWithForce: turnForce];
                
                if (mCostumeIndex != mCostumeUprightIndex)
                    [mShipDeck.helm addRotation:-1 * ((mCostumeIndex - mCostumeUprightIndex) / 10.0f)];
			}
		}
	}
	return sailForce;
}

- (void)advanceTime:(double)time {
	/*
	static int logDelay = 0;
	
	if ((++logDelay&7) == 0) {
        NSLog(@"LinVel: %f AngVel: %f", mBody->GetLinearVelocity().Length(), mBody->GetAngularVelocity());
        
		NSLog(@"-----------------------------------");
		for (NSString *key in self.eventListeners) {
			NSArray *array = [self.eventListeners objectForKey:key];
			
			for (NSInvocation *listener in array)
				NSLog(@"Listener: %@",NSStringFromClass([[listener target] class]));
		}
		NSLog(@"-----------------------------------");
	}
    */
	
	[super advanceTime:time];
    
    if (mPowderKegTimer > 0.0) {
        mPowderKegTimer -= time;
        
        if (mPowderKegTimer <= 0.0)
            [self dropNextPowderKeg];
    }
	
	// Ship position/orientation
	b2Vec2 rudder = mStern->GetAABB(0).GetCenter();
	self.x = M2PX(rudder.x);
	self.y = M2PY(rudder.y);
	self.rotation = -self.b2rotation;
	
	if (mShipDeck == nil || mSinking == YES || mTimeTravelling == YES) {
		return;
	} else if (mSuspendedMode == YES) {
		[self positionReticle];
		[self updateCostumeWithAngularVelocity:((mBody) ? mBody->GetAngularVelocity() : 0)];
		return;
	}
    
    if (mDragDuration > 0) {
        mDragDuration -= time;
        
        if (mDragDuration <= 0)
            self.drag = 1;
    }

    if (self.monty != MSConsipirator) {
        if (self.monty == MSTripper) {
            mTripCounter -= time;
            
            if (mTripCounter < 0)
                self.monty = MSConsipirator;
        }
        
        float sailForce = 0;
        
        if (self.monty != MSFirstMate) {
            sailForce = [self montyNavigate];
        } else {
            sailForce = mDrag * mSailForce; 
            [self sailWithForce:sailForce];
            
            // Based on helm rotation and ship specs. Also, the faster we travel, the more force on the rudder.
            float turnForce = mDrag * mShipDeck.helm.turnAngle * mTurnForceMax * (sailForce / mSailForceMax);
            [self turnWithForce:turnForce];
        }
        
        [self tickWakeOdometer:sailForce * (time * GCTRL.fps)];
        [self updateCostumeWithAngularVelocity:((mBody) ? mBody->GetAngularVelocity() : 0)];
        [self positionReticle];
    } else {
        [self updateCostumeWithAngularVelocity:((mBody) ? mBody->GetAngularVelocity() : 0)];
    }
    
    // Offscreen arrow
    [mOffscreenArrow updateArrowLocationX:self.px arrowY:self.py];
    [mOffscreenArrow updateArrowRotation:self.rotation];
    
    if (mOffscreenArrow.visible == YES || self.monty != MSFirstMate || mPlankEnabled == NO) {
        // Disable walk-the-plank feature
        mShipDeck.plank.state = PlankStateInactive;
    } else if (mShipDeck.plank.state == PlankStateInactive && mShipDetails.prisoners.count > 0) {
        // Enable walk-the-plank feature
        mShipDeck.plank.state = PlankStateActive;
    }

	// Out of bounds mutiny penalty
	if (self.monty == MSFirstMate && (self.x < -10.0f || self.x > (490.0f + mResOffset.x) || self.y < -10.0f || self.y > (330.0f + mResOffset.y))) {
        // Orientate towards center of playfield
        if (mBody) {
            b2Vec2 pfCenter(P2M(mScene.viewWidth / 2), P2M(mScene.viewHeight / 2));
            b2Vec2 dir = mBody->GetPosition();
            pfCenter -= dir;
            
            // We subtract 90 degrees because Box2D's axes have their angular origin on the positive vertical axis, whereas atan2f uses the positive horizontal axis.
            if (dir.x != 0 || dir.y != 0)
                mBody->SetTransform(mBody->GetPosition(), atan2f(pfCenter.y, pfCenter.x) - PI_HALF);
        }
	}
    
    // Cannon overheat maintenance
    if (mCannonSpamCapacitor <= (kCannonSpamCapacity / 4))
        mAccuracyCooldownTimer += time;
    
    if (mCannonSpamCapacitor > 0) {
        mCannonSpamCapacitor -= time;
        
        if (mCannonSpamCapacitor <= 0) {
            if (mCannonsOverheated)
                [self disableOverheatedCannons:NO];
            mCannonSpamCapacitor = 0;
            mRecentHitCount = mRecentShotCount = 0;
        }
    }
    
    // Failed speedboat achievement
    if (self.motorBoating && mFailedMotorboating) {
        mDashDialFlashTimer += time;
        
        if (mDashDialFlashTimer > 0.5) {
            mDashDialFlashTimer = 0.0;
            [mShipDeck flashFailedMphDial];
        }
    }
}

- (void)positionReticle {
	if (mCrewAiming == 0) {
		// Cannon reticles
		b2Vec2 hullVec = mHull->GetAABB(0).GetCenter();
		float hullX = M2PX(hullVec.x);
		float hullY = M2PY(hullVec.y);
		[mShipDeck.leftCannon positionReticleFromShipX:hullX y:hullY range:mCannonRange rotation:self.rotation + PI_HALF];
		mShipDeck.leftCannon.reticleRotation = -2 * self.rotation;
		[mShipDeck.rightCannon positionReticleFromShipX:hullX y:hullY range:mCannonRange rotation:self.rotation - PI_HALF];
		mShipDeck.rightCannon.reticleRotation = -2 * self.rotation;
	}
}

- (void)damageShip:(int)damage {
	if (mMotorBoatingSob == YES || self.monty != MSFirstMate)
		return;
	/*
    [super damageShip:damage];
    
	if (mShipDetails.condition == 0)
		[self sink];
    */
    
    self.drag = MIN(self.drag,0.7f);
    mDragDuration = 3.0f - [Potion mobilityReductionDurationForPotion:[GCTRL.gameStats potionForKey:POTION_MOBILITY]];
}

- (void)damageShipWithCannonball:(Cannonball *)cannonball {
    [super damageShipWithCannonball:cannonball];
    [mScene.objectivesManager progressObjectiveWithEventType:OBJ_TYPE_PLAYER_HIT];
}

- (void)sink {
	if (mSinking == NO) {
		[super sink];
		mSinking = YES;
		
        [mScene removeProp:mOffscreenArrow];
		[self removeAllChildren];
		mShipDeck.leftCannon.activated = NO;
		mShipDeck.rightCannon.activated = NO;
		
		if (mBody)
			mBody->SetLinearVelocity(b2Vec2(0.0f,0.0f));
		[self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_PLAYER_SHIP_SINKING]];
	}
}

- (void)automatorFireCannons {
	[mShipDeck.leftCannon fire:true dispatch:true];
	[mShipDeck.rightCannon fire:false dispatch:true];
}

- (void)dropPowderKegs:(uint)quantity {
	if (mDroppingKegs == NO && mSinking == NO) {
		mDroppingKegs = YES;
		mKegsRemaining = quantity;
		[self dropPowderKeg];
	}
}

- (void)dropPowderKeg {
	if (mKegsRemaining > 0 && mSinking == NO && mBody) {
		b2Vec2 loc = mBody->GetPosition();
		PowderKegActor *keg = [PowderKegActor powderKegActorAtX:loc.x y:loc.y rotation:0.0f];
		[mScene addActor:keg];
		[mScene.audioPlayer playSoundWithKey:@"KegDrop" volume:((RESM.isLowSoundOutput) ? 0.35f : 0.225f)];
        mPowderKegTimer = MAX(1, 2.0f / MAX(1, mSpeedNormalizer));
		--mKegsRemaining;
	}
}

- (void)dropNextPowderKeg {
	if (mKegsRemaining > 0)
		[self dropPowderKeg];
	else
		mDroppingKegs = NO;
}

- (NetActor *)deployNetWithScale:(float)scale duration:(float)duration {
	if (mBody == 0)
		return nil;
	b2Vec2 loc = mBody->GetPosition();
	return [self deployNetAtX:loc.x y:loc.y rotation:self.b2rotation scale:scale duration:duration ignited:NO];
}

- (NetActor *)deployNetAtX:(float)x y:(float)y rotation:(float)rotation scale:(float)scale duration:(float)duration ignited:(BOOL)ignited {
	assert(mNet == nil);
	
	if (mSinking == NO) {
		mNet = [[NetActor netActorAtX:x y:y rotation:rotation scale:scale duration:duration] retain];
		[mNet addEventListener:@selector(onNetDespawned:) atObject:self forType:CUST_EVENT_TYPE_NET_DESPAWNED];

		if (ignited)
			[mNet ignite];
		[mScene addActor:mNet];
		[mScene.audioPlayer playSoundWithKey:@"NetCast"];
	}
	return mNet;
}

- (void)despawnNetOverTime:(float)duration {
    [mNet despawnOverTime:duration];
}

- (void)onNetDespawned:(SPEvent *)event {
	[mNet release];
	mNet = nil;
}

- (BrandySlickActor *)deployBrandySlickWithDuration:(float)duration {
	if (mBody == 0)
		return nil;
	b2Vec2 loc = mBody->GetPosition();
	return [self deployBrandySlickAtX:loc.x y:loc.y rotation:self.b2rotation scale:1.25f duration:duration ignited:NO];
}

- (BrandySlickActor *)deployBrandySlickAtX:(float)x y:(float)y rotation:(float)rotation scale:(float)scale duration:(float)duration ignited:(BOOL)ignited {
	assert(mBrandySlick == nil);
	
	if (mSinking == NO) {
		mBrandySlick = [[BrandySlickActor brandySlickActorAtX:x y:y rotation:rotation scale:scale duration:duration] retain];
		[mBrandySlick addEventListener:@selector(onBrandySlickDespawned:) atObject:self forType:CUST_EVENT_TYPE_BRANDY_SLICK_DESPAWNED];
		
		if (ignited)
			[mBrandySlick ignite];
		[mScene addActor:mBrandySlick];
		[mScene.audioPlayer playSoundWithKey:@"BrandyPour"];
	}
	return mBrandySlick;
}

- (void)onBrandySlickDespawned:(SPEvent *)event {
	[mBrandySlick release];
	mBrandySlick = nil;
}

- (void)enablePlank:(BOOL)enable {
    mPlankEnabled = enable;
    mShipDeck.plank.state = PlankStateInactive;
}

- (void)activateCamouflage {
	if (mCamouflaged == NO && mSinking == NO) {
		mCamouflaged = YES;
		[self enqueueCostumeImages:mCamoCostumeImages];
		[mScene.audioPlayer playSoundWithKey:@"Camo" volume:1];
	}
}

- (void)deactivateCamouflage {
	if (mCamouflaged == YES) {
		mCamouflaged = NO;
		[self dequeueCostumeImages:mCamoCostumeImages];
        
        if (self.turnID == GCTRL.thisTurn.turnID)
            [mScene.objectivesManager progressObjectiveWithEventType:OBJ_TYPE_VOODOO_GADGET_EXPIRED tag:GADGET_SPELL_CAMOUFLAGE];
	}
}

- (void)activateFlyingDutchman {
	if (mFlyingDutchman == NO && mSinking == NO) {
		mFlyingDutchman = YES;
        [self disableOverheatedCannons:NO];
		[self enqueueCostumeImages:mDutchmanCostumeImages];
		[mScene.audioPlayer playSoundWithKey:@"FlyingDutchman" volume:1];
		[mShipDeck activateFlyingDutchman];
		
		if ([mAshProc isActive] == NO)
			mCannonDetails.shotType = @"dutchman-shot_";
        
        if (mDragDuration > 0) {
            mDragDuration = 0;
            self.drag = 1;
        }
	}
}

- (void)deactivateFlyingDutchman {
	if (mFlyingDutchman == YES) {
		mFlyingDutchman = NO;
		[self dequeueCostumeImages:mDutchmanCostumeImages];
		[mShipDeck deactivateFlyingDutchman];
		
		if ([mAshProc isActive] == NO)
			mCannonDetails.shotType = @"single-shot_";
        
        if (self.turnID == GCTRL.thisTurn.turnID)
            [mScene.objectivesManager progressObjectiveWithEventType:OBJ_TYPE_VOODOO_GADGET_EXPIRED tag:VOODOO_SPELL_FLYING_DUTCHMAN];
        
        // Shave off any extra that has been accumulated while in Flying Dutchman
        mCannonSpamCapacitor = 0;
        mRecentShotCount = mRecentHitCount = 0;
	}
}

- (void)travelThroughTime:(float)duration {
	if (mTimeTravelling == YES)
		return;
	mTimeTravelling = YES;
	
	SPTween *tween = [SPTween tweenWithTarget:self time:duration];
	[tween animateProperty:@"alpha" targetValue:0.0f];
	[mScene.juggler addObject:tween];
}

- (void)onTravelledThroughTime:(SPEvent *)event {
	if (mBody) {
		b2Vec2 loc = b2Vec2(P2MX(-250.0f), P2MY(0.0f));
		mBody->SetTransform(loc, mBody->GetAngle());
	}
}

- (void)emergeInPresentAtX:(float)x y:(float)y duration:(float)duration {
	if (mTimeTravelling == NO || mBody == 0)
		return;
	b2Vec2 loc = b2Vec2(P2MX(x), P2MY(y));
	mBody->SetTransform(loc, mBody->GetAngle());
	
	b2Vec2 rudder = mStern->GetAABB(0).GetCenter();
	self.x = M2PX(rudder.x);
	self.y = M2PY(rudder.y);
	self.rotation = -self.b2rotation;
	
	SPTween *tween = [SPTween tweenWithTarget:self time:duration];
	[tween animateProperty:@"alpha" targetValue:1.0f];
	[tween addEventListener:@selector(onEmergedInPresent:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
	[mScene.juggler addObject:tween];
}

- (void)onEmergedInPresent:(SPEvent *)event {
	mTimeTravelling = NO;
}

- (void)chanceAshSpecialProc {
	if (mAshProc.specialProcEventKey && RANDOM_INT(1, 1000) <= (int)(1000 * mAshProc.specialChanceToProc))
		[self dispatchEvent:[SPEvent eventWithType:mAshProc.specialProcEventKey]];
}

- (void)cannonballHitTarget:(BOOL)hit ricochet:(BOOL)ricochet proc:(BOOL)proc {
    if (ricochet == YES)
        return;
    
    if (mCannonSpamCapacitor > (kCannonSpamCapacity / 4)) {
        mAccuracyCooldownTimer = 0;
        ++mRecentShotCount;
        
        if (hit) {
            // Compensate Molten Shot for false negatives.
            mRecentHitCount = MIN(mRecentShotCount, self.procType == ASH_MOLTEN ? mRecentHitCount + 2 : mRecentHitCount + 1);
        }
        
        if (mRecentShotCount >= 30) {
            mRecentShotCount /= 2;
            mRecentHitCount /= 2;
        }
        
        //NSLog(@"Shot: %u Hit: %u", mRecentShotCount, mRecentHitCount);
    } else if (mAccuracyCooldownTimer > 8.0) {
        mRecentShotCount = mRecentHitCount = 0;
    }
    
    /*
	if (ricochet == YES) {
		if (hit && proc)
			[self chanceAshSpecialProc];
	} else {
		if (hit == YES) {
			BOOL isAshProcActive = [mAshProc isActive];
			++mAshProc.requirementCount; // This can make isActive return YES
			
			if ([mAshProc isActive] == NO) {
				[mAshProc chanceProc];
				
				if ([mAshProc isActive]) {
					[self activateCannonProc];
					[self playCannonProcSound];
				}
			} else if (isAshProcActive == NO) {	// Requirement ceiling reached
				[self activateCannonProc];
				[self playCannonProcSound];
			}
			
			if (proc)
				[self chanceAshSpecialProc];
		} else {
			if (mAshProc.deactivatesOnMiss) {
				if ([mAshProc isActive])
					[self deactivateCannonProc];
				[mAshProc deactivate];
			}
			mAshProc.requirementCount = 0;
		}
	}
     */
}

- (void)prepareForGameOver {
    if (self.markedForRemoval)
        return;
    [mScene removeProp:mOffscreenArrow];
	mShipDeck.leftCannon.activated = NO;
	mShipDeck.rightCannon.activated = NO;
    
    [mScene.juggler removeTweensWithTarget:mCostume];
    
    SPTween *tween = [SPTween tweenWithTarget:mCostume time:1.0f];
    [tween animateProperty:@"alpha" targetValue:0];
    [tween addEventListener:@selector(onCostumeFaded:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
    [mScene.juggler addObject:tween];
}

- (void)onCostumeFaded:(SPEvent *)event {
    [mScene removeActor:self];
}

- (void)onRaceUpdate:(RaceEvent *)event {
    if (event.raceFinished || mRaceUpdateIndex == -1) {
        [mShipDeck setRaceTime:[Globals formatElapsedTime:event.raceTime]];
        [mShipDeck setLapTime:[Globals formatElapsedTime:event.lapTime]];
        
        double mph = event.mph;
        int64_t gcSpeed = (int64_t)(mph * 1000.0);
        [mShipDeck setMph:[NSString stringWithFormat:@"%7.3f", (float)(gcSpeed / 1000.0)]];
        [mShipDeck setLap:[NSString stringWithFormat:@"%d/%d", event.lap, event.totalLaps]];
        
        if (event.raceFinished) {
            GameController *gc = GCTRL;
            [gc.thisTurn setTime:event.lapTime forLap:event.lap];
            gc.thisTurn.speed = mph;
            mFailedMotorboating = (event.raceTime > [RaceEvent requiredRaceTimeForLapCount:event.totalLaps]);
        }
    } else {
        // Spread the updates out across sequential frames for performance reasons
        switch (mRaceUpdateIndex) {
            case 0:
                [mShipDeck setRaceTime:[Globals formatElapsedTime:event.raceTime]];
                break;
            case 1:
                [mShipDeck setLapTime:[Globals formatElapsedTime:event.lapTime]];
                break;
            case 2:
                [mShipDeck setMph:[NSString stringWithFormat:@"%7.3f", (float)event.mph]];
                break;
            case 3:
                [mShipDeck setLap:[NSString stringWithFormat:@"%d/%d", event.lap, event.totalLaps]];
                break;
            default:
                break;
        }
        
        if (event.crossedFinishLine) {
            if (mRaceUpdateIndex != 1)
                [mShipDeck setLapTime:[Globals formatElapsedTime:event.lapTime]];
            [GCTRL.thisTurn setTime:event.lapTime forLap:event.lap];
        }
    }
    
    if (++mRaceUpdateIndex > 3)
        mRaceUpdateIndex = 0;
}

- (void)cleanup {
	[super cleanup];
	
	if (mShipDeck) {
		[mShipDeck.leftCannon removeEventListener:@selector(onPlayerCannonFired:) atObject:self forType:CUST_EVENT_TYPE_PLAYER_CANNON_FIRED];
		[mShipDeck.rightCannon removeEventListener:@selector(onPlayerCannonFired:) atObject:self forType:CUST_EVENT_TYPE_PLAYER_CANNON_FIRED];
		[mNet removeEventListener:@selector(onNetDespawned:) atObject:self forType:CUST_EVENT_TYPE_NET_DESPAWNED];
		[mBrandySlick removeEventListener:@selector(onBrandySlickDespawned:) atObject:self forType:CUST_EVENT_TYPE_BRANDY_SLICK_DESPAWNED];
		[mShipDeck release]; mShipDeck = nil;
	}
    
    if (mOffscreenArrow) {
		[mScene removeProp:mOffscreenArrow];
		[mOffscreenArrow release]; mOffscreenArrow = nil;
	}
    
	[mScene.juggler removeTweensWithTarget:self];
}

- (void)dealloc {
	[self cleanup];
	[mAshProc release]; mAshProc = nil;
	[mCannonInfamyBonus release]; mCannonInfamyBonus = nil;
	[mDutchmanCostumeImages release]; mDutchmanCostumeImages = nil;
	[mCamoCostumeImages release]; mCamoCostumeImages = nil;
	[mNet release]; mNet = nil;
	[mBrandySlick release]; mBrandySlick = nil;
	
	if (mCrewAiming) {
		delete mCrewAiming;
		mCrewAiming = 0;
	}
	
	[mResOffset release]; mResOffset = nil;
    [mMontyDest release]; mMontyDest = nil;
    [super dealloc];
	
	NSLog(@"PlayerShip dealloc'ed");
}

@end
