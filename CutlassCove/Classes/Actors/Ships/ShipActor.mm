//
//  ShipActor.m
//  Pirates
//
//  Created by Paul McPhee on 3/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "ShipActor.h"
#import "PlayerDetails.h"
#import "ShipDetails.h"
#import "Prisoner.h"
#import "CannonFactory.h"
#import "CannonDetails.h"
#import "Cannonball.h"
#import "ShipHitGlow.h"
#import "CannonFire.h"
#import "Wake.h"
#import "ActorFactory.h"
#import "Pursuer.h"
#import "GameController.h"
#import "Globals.h"
#import "Box2DUtils.h"


const float kShipActorWakeFactor = 137.5f; //275.0f;


@interface ShipActor ()

- (void)displayExplosionGlow;
- (void)timeOfDayChanged:(TimeOfDayChangedEvent *)event;

@end


@implementation ShipActor

@synthesize bow = mBow;
@synthesize hull = mHull;
@synthesize stern = mStern;
@synthesize port = mPort;
@synthesize starboard = mStarboard;
@synthesize shipDetails = mShipDetails;
@synthesize cannonDetails = mCannonDetails;
@synthesize sailForce = mSailForce;
@synthesize drag = mDrag;
@synthesize speedModifier = mSpeedModifier;
@synthesize controlModifier = mControlModifier;
@synthesize wakeFactor = mWakeFactor;
@synthesize ashBitmap = mAshBitmap;
@synthesize deathBitmap = mDeathBitmap;
@synthesize miscBitmap = mMiscBitmap;
@synthesize ricochetHop = mRicochetHop;
@synthesize ricochetBonus = mRicochetBonus;
@synthesize sunkByPlayerCannonInfamyBonus = mPlayerCannonInfamyBonus;
@synthesize mutinyReduction = mMutinyReduction;
@dynamic centerX,centerY,overboardLocation,sinkingClipFps,burningClipFps;

+ (float)defaultSailForceMax {
	return 150.0f;
}

- (id)initWithActorDef:(ActorDef *)def key:(NSString *)key {
    if (self = [super initWithActorDef:def actorId:[Actor nextActorId]]) {
		mCategory = CAT_PF_SHIPS;
		mAdvanceable = YES;
		mKey = [key copy];
		mCannonSoundEnabled = YES;
		mOdometer = 0;
		mWakePeriod = [Wake defaultWakePeriod];
		mWakeCount = -1;
		mDrag = 1;
		mSpeedModifier = 1;
		mControlModifier = 1;
        mAshBitmap = ASH_DEFAULT;
		mDeathBitmap = DEATH_BITMAP_ALIVE;
        mMiscBitmap = 0;
		mBow = 0;
		mHull = 0;
		mStern = 0;
		mPort = 0;
		mStarboard = 0;
		mOverboard = 0;
		mShipDetails = nil;
		mCannonDetails = nil;
		mWake = nil;
		//mLantern = nil;
		mShipHitGlows = nil;
		mSinkingClip = nil;
		mBurningClip = nil;
        mRicochetHop = 0;
		mRicochetBonus = 0;
		mPlayerCannonInfamyBonus = 0;
        mMutinyReduction = 1;
		
		mAngVelUpright = 0.5f;
		mNumCostumeImages = NUM_NPC_COSTUME_IMAGES;
		mCostumeUprightIndex = mNumCostumeImages / 2;
		mCostumeIndex = mCostumeUprightIndex;
		mCostume = nil;
        mDeathCostume = nil;
        mWardrobe = nil;
		mCostumeImages = nil;
		mCurrentCostumeImages = nil;
		mCostumeStack = [[NSMutableArray alloc] init];
		
		// Save fixtures
		b2Fixture **fixtures = def->fixtures;
		
		for (int i = 0; i < def->fixtureDefCount; ++i) {
			[self saveFixture:*fixtures atIndex:i];
			++fixtures;
		}
		
        self.wakeFactor = kShipActorWakeFactor;
		self.x = self.px;
		self.y = self.py;
    }
    return self;
}

- (void)setupShip {
	if (mWakeCount == -1)
		mWakeCount = [Wake defaultWakeBufferSize];
    
    if (RESM.isLowPerformance == NO) {
        mWake = [[Wake alloc] initWithCategory:CAT_PF_WAKES numRipples:mWakeCount];
        [mScene addProp:mWake];
    }
}

- (NSArray *)setupCostumeForTexturesStartingWith:(NSString *)texturePrefix cacheGroup:(NSString *)cacheGroup {
	NSArray *costumeTextures = [mScene texturesStartingWith:texturePrefix cacheGroup:cacheGroup];
    
    if (costumeTextures.count == 1)
        mNumCostumeImages = costumeTextures.count;
    mCostumeUprightIndex = mNumCostumeImages / 2;
    mCostumeIndex = mCostumeUprightIndex;
    
	NSMutableArray *images = [NSMutableArray arrayWithCapacity:mNumCostumeImages];
	
	for (int i = 0, frameIndex = mCostumeIndex, frameIncrement = -1; i < mNumCostumeImages; ++i) {
		SPImage *image = [SPImage imageWithTexture:[costumeTextures objectAtIndex:frameIndex]];
		image.scaleX = (i < mCostumeIndex) ? -1 : 1;
		image.x = -12 * image.scaleX;
		image.y = -mShipDetails.rudderOffset;
		image.visible = (i == mCostumeIndex);
		[images addObject:image];
		
		if (frameIndex == 0)
			frameIncrement = 1;
		frameIndex += frameIncrement;
	}
	
	return images;
}

- (void)setImages:(NSArray *)images forCostume:(SPSprite *)costume {
	[costume removeAllChildren];
	
	for (SPImage *image in images) {
        image.visible = NO;
		[costume addChild:image];
    }
    
	mCurrentCostumeImages = images;
    
    if (mCostumeIndex >= 0 && mCostumeIndex < mCurrentCostumeImages.count) {
        SPImage *image = (SPImage *)[mCurrentCostumeImages objectAtIndex:mCostumeIndex];
        image.visible = YES;
    }
    
    [self updateCostumeWithAngularVelocity:((mBody) ? mBody->GetAngularVelocity() : 0)];
}

- (void)enqueueCostumeImages:(NSArray *)images {
	assert(images.count == mNumCostumeImages);
	[[images retain] autorelease];
	
	if ([mCostumeStack containsObject:images])
		[mCostumeStack removeObject:images];
	[mCostumeStack addObject:images];
	[self setImages:images forCostume:mCostume];
}

- (void)dequeueCostumeImages:(NSArray *)images {
	[[images retain] autorelease];
	[mCostumeStack removeObject:images];
	
	if (mCurrentCostumeImages == images) {
		NSArray *nextImages = (NSArray *)[mCostumeStack lastObject];
		[self setImages:nextImages forCostume:mCostume];
	}
}

- (void)saveFixture:(b2Fixture *)fixture atIndex:(int)index {
	switch (index) {
		case 0: mBow = fixture; break;
		case 1: mHull = fixture; break;
		case 2: mStern = fixture; mOverboard = fixture; break;
		case 3: mPort = fixture; break;
		case 4: mStarboard = fixture; break;
		default: break;
	}
}

- (b2Vec2)closestPositionTo:(b2Vec2)pos {
	b2Vec2 bowCenter = mBow->GetAABB(0).GetCenter();
	b2Vec2 hullCenter = mHull->GetAABB(0).GetCenter();
	b2Vec2 sternCenter = mStern->GetAABB(0).GetCenter();
	
	float32 bowLenSq = b2DistanceSquared(bowCenter, pos);
	float32 hullLenSq = b2DistanceSquared(hullCenter, pos);
	float32 sternLenSq = b2DistanceSquared(sternCenter, pos);
	
	if (bowLenSq < hullLenSq && bowLenSq < sternLenSq)
		return bowCenter;
	else if (hullLenSq < bowLenSq && hullLenSq < sternLenSq)
		return hullCenter;
	else
		return sternCenter;
}

- (void)fpsFactorChanged:(float)value {
    self.wakeFactor = kShipActorWakeFactor;
}

- (void)setWakeFactor:(float)wakeFactor {
    mWakeFactor = wakeFactor / GCTRL.fpsFactor;
}

- (float)centerX {
	float cx = self.x;
	
	if (mBody)
		cx = M2PX(mHull->GetAABB(0).GetCenter().x);
	return cx;
}

- (float)centerY {
	float cy = self.y;
	
	if (mBody)
		cy = M2PY(mHull->GetAABB(0).GetCenter().y);
	return cy;
}

- (b2Vec2)overboardLocation {
	return mOverboard->GetAABB(0).GetCenter();
}

- (float)sinkingClipFps {
	return 16.0f;
}

- (float)burningClipFps {
	return 12.0f;
}

- (void)setDeathBitmap:(uint)bitmap {
	if (mDeathBitmap == DEATH_BITMAP_ALIVE)
		mDeathBitmap = bitmap;
}

- (int)infamyBonus {
	return 0;
}

- (b2Fixture *)portOrStarboard:(int)side {
	return (side == PortSide) ? mPort : mStarboard;
}

- (void)sailWithForce:(float32)force {
	if (mBody == 0)
		return;
	b2Vec2 bowCenter = mBow->GetAABB(0).GetCenter();
	b2Vec2 bodyCenter = mBody->GetWorldCenter();
	b2Vec2 delta = bowCenter - bodyCenter;
	delta.Normalize();
	mBody->ApplyForce(force * delta, bodyCenter);
}

- (void)turnWithForce:(float32)force {
	if (mBody == 0)
		return;
	float32 dir = (force < 0.0f) ? 1 : -1;
	b2Vec2 turnVec = b2Vec2(0.0f,fabsf(force));
	Box2DUtils::rotateVector(turnVec, mBody->GetAngle()+dir*PI_HALF);
	mBody->ApplyForce(turnVec,mBow->GetAABB(0).GetCenter());
}

- (void)sink {
	if (mSinkingClip == nil)
		mSinkingClip = [[SPMovieClip alloc] initWithFrames:[mScene texturesStartingWith:@"ship-sinking_" cacheGroup:TM_CACHE_PF_SHIPS] fps:self.sinkingClipFps];
    if (mDeathCostume == nil)
        mDeathCostume = [[SPSprite alloc] init];
    mSinkingClip.scaleX = mSinkingClip.scaleY = 60.0f / 48.0f;
	mSinkingClip.x = -mSinkingClip.width / 2;
	mSinkingClip.y = -mShipDetails.rudderOffset; // * mSinkingClip.scaleY;
	mSinkingClip.currentFrame = 0;
    mSinkingClip.loop = NO;
	[mSinkingClip play];
	[mDeathCostume addChild:mSinkingClip];
    [mWardrobe addChild:mDeathCostume];
	[mScene.juggler addObject:mSinkingClip];
}

- (void)burn {
	if (mBurningClip == nil)
		mBurningClip = [[SPMovieClip alloc] initWithFrames:[mScene texturesStartingWith:@"ship-burn_" cacheGroup:TM_CACHE_PF_SHIPS] fps:self.burningClipFps];
    if (mDeathCostume == nil)
        mDeathCostume = [[SPSprite alloc] init];
    mBurningClip.scaleX = mBurningClip.scaleY = 60.0f / 48.0f;
	mBurningClip.x = -mBurningClip.width / 2;
	mBurningClip.y = -mShipDetails.rudderOffset; // * mBurningClip.scaleY;
	mBurningClip.currentFrame = 0;
    mBurningClip.loop = NO;
	[mBurningClip play];
	[mDeathCostume addChild:mBurningClip];
    [mWardrobe addChild:mDeathCostume];
	[mScene.juggler addObject:mBurningClip];
	[mScene.audioPlayer playSoundWithKey:@"ShipBurn"];
}

- (void)addPrisoner:(NSString *)name {
	[mShipDetails addPrisoner:name];
}

- (Prisoner *)addRandomPrisoner {
	return [mShipDetails addRandomPrisoner];
}

- (BOOL)isFullOnPrisoners {
	return [self.shipDetails isFullOnPrisoners];
}

- (void)dropLoot { }

- (void)displayExplosionGlow {
    if (RESM.isLowPerformance)
        return;
    
	GameController *gc = GCTRL;
    
	if (gc.timeOfDay >= Dusk && gc.timeOfDay <= DawnTransition) {
        if (mShipHitGlows == nil)
            mShipHitGlows = [[NSMutableArray alloc] init];
        
        for (ShipHitGlow *glow in mShipHitGlows) {
            if (glow.isCompleted) {
                [glow rerun];
                return;
            }
        }
        
        ShipHitGlow *glow = [[ShipHitGlow alloc] initWithX:self.px y:self.py];
		[mShipHitGlows addObject:glow];
		[glow release];
	}
}

- (void)damageShip:(int)damage {
    // Do nothing
}

- (void)damageShipWithCannonball:(Cannonball *)cannonball {
	//[self damageShip:5 * cannonball.core->GetShape()->m_radius];
	[self damageShip:cannonball.damageFromImpact];
	[self displayExplosionGlow];
}

- (void)applyPerpendicularImpulse:(float)force toCannonball:(Cannonball *)cannonball {
	if (mBody == 0 || cannonball.body == 0)
		return;
	b2Vec2 impulse = cannonball.body->GetLinearVelocity();
	impulse.Normalize();
	
    // Apply a slight backforce to account for angled shots needing to fall shorter.
	float impulseAdjustment = 0.325 * fabsf(force);
	impulseAdjustment *= impulseAdjustment;
	
    b2Vec2 backImpulse = impulse;
    backImpulse *= -impulseAdjustment;
	cannonball.body->ApplyLinearImpulse(backImpulse, cannonball.body->GetPosition());
	
    // Now apply perp force
    impulse *= fabsf(force);
    Box2DUtils::rotateVector(impulse, ((force < 0) ? -PI_HALF : PI_HALF));
	cannonball.body->ApplyLinearImpulse(impulse, cannonball.body->GetPosition());
}

- (Cannonball *)fireCannon:(int)side trajectory:(float)trajectory {
	[self playFireCannonSound];
	
	Cannonball *cannonball = [[CannonFactory munitions] createCannonballForShip:self atSide:side withTrajectory:trajectory];
	[mScene addActor:cannonball];
	[cannonball setupCannonball];
	
	[self animateCannonSmokeWithX:cannonball.px y:cannonball.py rotation:(self.rotation + ((side == PortSide) ? -PI_HALF : PI_HALF))];
	return cannonball;
}

- (void)animateCannonSmokeWithX:(float)x y:(float)y rotation:(float)rotation {
    if (RESM.isLowPerformance)
        return;
	CannonFire *smoke = (CannonFire *)[PointMovie pointMovieWithType:MovieTypeCannonFire x:x y:y];
	smoke.cannonRotation = rotation;
	
	SPPoint *smokeVel = [SPPoint pointWithX:0.0f y:-0.5f];
	[Globals rotatePoint:smokeVel throughAngle:smoke.cannonRotation];
	[smoke setLinearVelocityX:smokeVel.x y:smokeVel.y];
}

- (void)playFireCannonSound { }

- (void)playSunkSound {
	//[mScene.audioPlayer playSoundWithKey:@"Sunk" volume:1.0f];
}

- (void)updateCostumeWithAngularVelocity:(float)angVel {
    if (mNumCostumeImages == 0)
        return;
	int index = mCostumeIndex;
	float fabsAngVel = fabsf(angVel);
	
	// -1.38 -> 1.38
	//if (fabsAngVel > (mAngVelUpright + 5.0f)) index = 0; // Unreachable with current forces.
	
	if (fabsAngVel < mAngVelUpright) index = mCostumeUprightIndex;
	else if (fabsAngVel > (mAngVelUpright + 0.6f)) index = 0;
	else if (fabsAngVel > (mAngVelUpright + 0.35f) && fabsAngVel < (mAngVelUpright + 0.5f)) index = 1;
	else if (fabsAngVel > (mAngVelUpright + 0.2f) && fabsAngVel < (mAngVelUpright + 0.25f)) index = 2;
	else return;
	
	SPImage *image = (SPImage *)[mCurrentCostumeImages objectAtIndex:mCostumeIndex];
	image.visible = NO;
	
	if (index != mCostumeUprightIndex && angVel > 0)
		index = mNumCostumeImages - (index+1);
    index = MAX(0,MIN(mNumCostumeImages-1, index));
    
	image = (SPImage *)[mCurrentCostumeImages objectAtIndex:index];
	image.visible = YES;
	mCostumeIndex = index;
}

- (void)advanceTime:(double)time {
	/*
	if (mLantern.isPaused == NO) {
		mLantern.x = self.px;
		mLantern.y = self.py;
		mLantern.rotation = self.rotation;
		[mLantern tweenThisFrame:event.passedTime];
	}
	*/
	for (ShipHitGlow *shipHitGlow in mShipHitGlows) {
		shipHitGlow.x = self.px;
		shipHitGlow.y = self.py;
	}
}

- (void)tickWakeOdometer:(float)sailForce {
	assert(SP_IS_FLOAT_EQUAL(0.0f, mWakeFactor) == NO);
	mOdometer += sailForce / mWakeFactor;
	
    if (mBody && mOdometer >= mWakePeriod) {
        mOdometer = 0.0f;
        
        b2CircleShape *bowShape = (b2CircleShape *)mBow->GetShape();
        b2CircleShape *sternShape = (b2CircleShape *)mStern->GetShape();
        
        b2Vec2 bowPos = mBody->GetWorldPoint(bowShape->m_p);
        b2Vec2 sternPos = mBody->GetWorldPoint(sternShape->m_p);
        b2Vec2 shipVector = bowPos - sternPos;
        shipVector *= 0.15f;
        shipVector = bowPos - shipVector;
        [mWake nextRippleAtX:M2PX(shipVector.x) y:M2PY(shipVector.y) rotation:self.rotation];
    }
}

- (void)timeOfDayChanged:(TimeOfDayChangedEvent *)event {
	/*
	TimeOfDay time = event.timeOfDay;
	
	if (time == Midnight)
		[mLantern beginTweening];
	else if (time == Dawn)
		[mLantern stopTweening];
	 */
}

- (void)onRaceUpdate:(RaceEvent *)event {
	
}

- (void)addPursuer:(NSObject<Pursuer> *)pursuer {
    if (mPursuers == nil)
        mPursuers = [[NSMutableSet alloc] init];
    [mPursuers addObject:pursuer];
}

- (void)removePursuer:(NSObject<Pursuer> *)pursuer {
    [[pursuer retain] autorelease];
    [mPursuers removeObject:pursuer];
}

- (void)removeAllPursuers {
    if (mPursuers == nil)
        return;
    
    NSSet *pursuers = [NSSet setWithSet:mPursuers];
    [mPursuers release]; mPursuers = nil;
    
    for (NSObject<Pursuer> *pursuer in pursuers)
        [pursuer pursueeDestroyed:self];
}

- (void)safeRemove { 
	if (mRemoveMe == YES)
		return;
	[super safeRemove];
    [self removeAllPursuers];
}

- (void)zeroOutFixtures {
	[super zeroOutFixtures];
	
	mBow = 0;
	mHull = 0;
	mStern = 0;
	mPort = 0;
	mStarboard = 0;
	mOverboard = 0;
}

- (void)dealloc {
    [self removeAllPursuers];
    [mPursuers release]; mPursuers = nil;
	
	if (mSinkingClip)
		[mScene.juggler removeObject:mSinkingClip];
	if (mBurningClip)
		[mScene.juggler removeObject:mBurningClip];
    if (mWardrobe)
        [mScene.juggler removeTweensWithTarget:mWardrobe];
    for (ShipHitGlow *glow in mShipHitGlows)
        [mScene removeProp:glow];
    
	[mSinkingClip release]; mSinkingClip = nil;
	[mBurningClip release]; mBurningClip = nil;
	[mWake safeDestroy];
	[mWake release]; mWake = nil;
	[mShipDetails release]; mShipDetails = nil;
	[mCannonDetails release]; mCannonDetails = nil;
	[mShipHitGlows release]; mShipHitGlows = nil;
	
	mCurrentCostumeImages = nil;
	[mCostume release]; mCostume = nil;
    [mDeathCostume release]; mDeathCostume = nil;
    [mWardrobe release]; mWardrobe = nil;
	[mCostumeImages release]; mCostumeImages = nil;
	[mCostumeStack release]; mCostumeStack = nil;
    [super dealloc];
}

@end

