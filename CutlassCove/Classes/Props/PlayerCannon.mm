//
//  PlayerCannon.m
//  Pirates
//
//  Created by Paul McPhee on 19/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "PlayerCannon.h"
#import "PlayerDetails.h"
#import "CannonDetails.h"
#import "RingBuffer.h"
#import "CannonSmoke.h"
#import "Cannonball.h"
#import "CannonFactory.h"
#import "GameController.h"
#import "Globals.h"

const int kSmokeBufferSize = 6;
const double kDefaultReloadDelay = 0.5;
const float kElevationThrottle = 0.65f;


@interface PlayerCannon ()

- (void)setupNormalTextures;
- (void)decorateWithCannonDetails:(CannonDetails *)cannonDetails textures:(NSDictionary *)texDict;
- (SPPoint *)pointFromDictionary:(NSDictionary *)dict;
- (void)onTouch:(SPTouchEvent *)event;
- (void)onFlashClipCompleted:(SPEvent *)event;
- (void)reloaded;
- (void)recoil;
- (SPTween *)rollWheel:(SPSprite *)wheel targetValue:(float)targetValue duration:(float)duration delay:(float)delay transition:(NSString *)transition;

@end


@implementation PlayerCannon

@synthesize showReticle = mShowReticle;
@synthesize activated = mActivated;
@synthesize reloading = mReloading;
@synthesize overheated = mOverheated;
@synthesize reloadInterval = mReloadInterval;
@synthesize bitmap = mBitmap;
@synthesize elevationFactor = mElevationFactor;
@dynamic elevation,direction,reticleRotation;

- (id)init {
    if (self = [super initWithCategory:-1]) {
		mReloadInterval = kDefaultReloadDelay;
		self.touchable = YES;
		mActivated = YES;
		mShowReticle = NO;
		mReloading = NO;
		mBeginTouch = NO;
        mOverheated = NO;
		mElevationFactor = 1;
		mBitmap = 0;
		mTouchQuad = nil;
		mBarrelDutchmanTexture = nil;
		mBracketDutchmanTexture = nil;
		mWheelDutchmanTexture = nil;
		mFlashDutchmanTexture = nil;
		mOrigin = [[SPPoint alloc] init];
		mReticlePosition = [[SPPoint alloc] init];
        mRecoilTweens = nil;
        mFiredEvent = [[PlayerCannonFiredEvent alloc] initWithType:CUST_EVENT_TYPE_PLAYER_CANNON_FIRED cannon:self bubbles:NO];
		[self setupNormalTextures];
        
        UIDevicePlatform platformType = [RESM platformType];
        mFireVolume = 0.9f;
        
        if (platformType == UIDevice4GiPod)
            mFireVolume = 1.0f;
        else if (platformType == UIDevice4iPhone)
            mFireVolume = 0.7f;
    }
    return self;
}

- (void)setupNormalTextures {
	GameController *gc = [GameController GC];
	CannonDetails *cannonDetails = gc.playerDetails.cannonDetails;
	
	mBarrelTexture = [[mScene textureByName:cannonDetails.textureNameBarrel] retain];
    mOverheatedBarrelTexture = [[mScene textureByName:@"overheated-barrel"] retain];
	mBracketTexture = [[mScene textureByName:cannonDetails.textureNameBase] retain];
	mWheelTexture = [[mScene textureByName:cannonDetails.textureNameWheel] retain];
	mFlashTexture = [[mScene textureByName:cannonDetails.textureNameFlash] retain];
}

- (void)setupDutchmanTextures {
	CannonDetails *cannonDetails = [[CannonFactory munitions] createSpecialCannonDetailsForType:@"FlyingDutchman"];
	
	mBarrelDutchmanTexture = [[mScene textureByName:cannonDetails.textureNameBarrel] retain];
	mBracketDutchmanTexture = [[mScene textureByName:cannonDetails.textureNameBase] retain];
	mWheelDutchmanTexture = [[mScene textureByName:cannonDetails.textureNameWheel] retain];
	mFlashDutchmanTexture = [[mScene textureByName:cannonDetails.textureNameFlash] retain];
}

- (void)loadFromDictionary:(NSDictionary *)dictionary withKeys:(NSArray *)keys {
	if (mTouchQuad != nil)
		return;
	
	int i = 0;
	NSString *key = [keys objectAtIndex:i++];
	NSDictionary *dict = [dictionary objectForKey:key];
	mOrigin.x = [(NSNumber *)[dict objectForKey:@"x"] floatValue];
	mOrigin.y = [(NSNumber *)[dict objectForKey:@"y"] floatValue];
	self.scaleX = [(NSNumber *)[dict objectForKey:@"scaleX"] floatValue];
	[self decorateWithCannonDetails:[GameController GC].playerDetails.cannonDetails
						   textures:[NSDictionary dictionaryWithObjectsAndKeys:
									 mBarrelTexture, @"Barrel",
									 mBracketTexture, @"Bracket",
									 mWheelTexture, @"Wheel",
									 mFlashTexture, @"Flash",
									 nil]];
	self.elevation = SP_D2R(-22.5f);
}

- (void)decorateWithCannonDetails:(CannonDetails *)cannonDetails textures:(NSDictionary *)texDict {
	NSDictionary *dictIter = nil;
	NSDictionary *deckSettings = cannonDetails.deckSettings;
	
	SPPoint *offset = [self pointFromDictionary:[deckSettings objectForKey:@"Offset"]];
	SPPoint *pivot = [self pointFromDictionary:[deckSettings objectForKey:@"Pivot"]];
	SPPoint *barrel = [self pointFromDictionary:[deckSettings objectForKey:@"Barrel"]];
	SPPoint *flash = [self pointFromDictionary:[deckSettings objectForKey:@"Flash"]];
	SPPoint *smoke = [self pointFromDictionary:[deckSettings objectForKey:@"Smoke"]];
	
	dictIter = [deckSettings objectForKey:@"Flash"];
	float flashScale = [(NSNumber *)[dictIter objectForKey:@"scale"] floatValue];
	
	dictIter = [deckSettings objectForKey:@"Smoke"];
	float smokeScale = [(NSNumber *)[dictIter objectForKey:@"scale"] floatValue];
	
	dictIter = [deckSettings objectForKey:@"Axles"];
	SPPoint *axleFront = [self pointFromDictionary:[dictIter objectForKey:@"Front"]];
	SPPoint *axleRear = [self pointFromDictionary:[dictIter objectForKey:@"Rear"]];
	
	// Build the cannon
	SPTexture *texture = nil;
	
	if (mRecoilContainer == nil) {
		mRecoilContainer = [[SPSprite alloc] init];
		[self addChild:mRecoilContainer];
	}
	
	// Barrel
	[mBarrelImage removeFromParent];
	[mBarrelImage autorelease];
	mBarrelImage = [[SPImage alloc] initWithTexture:[texDict objectForKey:@"Barrel"]];
	mBarrelImage.x = barrel.x;
	mBarrelImage.y = barrel.y;
	
	if (mBarrel == nil) {
		mBarrel = [[SPSprite alloc] init];
		mBarrel.touchable = NO;
		[mRecoilContainer addChild:mBarrel];
	}
	
	float oldRotation = mBarrel.rotation;
	mBarrel.rotation = 0;
	mBarrel.x = pivot.x;
	mBarrel.y = pivot.y;
	[mBarrel addChild:mBarrelImage];
	mBarrel.rotation = oldRotation;
	
	// Bracket
	[mBracketImage removeFromParent];
	[mBracketImage autorelease];
	mBracketImage = [[SPImage alloc] initWithTexture:[texDict objectForKey:@"Bracket"]];

	if (mBracket == nil) {
		mBracket = [[SPSprite alloc] init];
		mBracket.touchable = NO;
		[mRecoilContainer addChild:mBracket];
	}
	
	[mBracket addChild:mBracketImage];
	
	// Front Wheel
	texture = [texDict objectForKey:@"Wheel"];
	
	[mFrontWheelImage removeFromParent];
	[mFrontWheelImage autorelease];
	mFrontWheelImage = [[SPImage alloc] initWithTexture:texture];
	mFrontWheelImage.x = -mFrontWheelImage.width / 2;
	mFrontWheelImage.y = -mFrontWheelImage.height / 2;
	
	if (mFrontWheel == nil) {
		mFrontWheel = [[SPSprite alloc] init];
		mFrontWheel.touchable = NO;
		[mRecoilContainer addChild:mFrontWheel];
	}
	
	mFrontWheel.x = axleFront.x;
	mFrontWheel.y = axleFront.y;
	[mFrontWheel addChild:mFrontWheelImage];
	
	// Rear Wheel
	[mRearWheelImage removeFromParent];
	[mRearWheelImage autorelease];
	mRearWheelImage = [[SPImage alloc] initWithTexture:texture];
	mRearWheelImage.x = -mRearWheelImage.width / 2;
	mRearWheelImage.y = -mRearWheelImage.height / 2;
	
	if (mRearWheel == nil) {
		mRearWheel = [[SPSprite alloc] init];
		mRearWheel.touchable = NO;
		[mRecoilContainer addChild:mRearWheel];
	}
	
	mRearWheel.x = axleRear.x;
	mRearWheel.y = axleRear.y;
	[mRearWheel addChild:mRearWheelImage];
	
	// Flash
	if (mMuzzleFlash == nil) {
		mMuzzleFlash = [[SPMovieClip alloc] initWithFrame:[mScene textureByName:cannonDetails.textureNameFlash] fps:10];
		[mMuzzleFlash addEventListener:@selector(onFlashClipCompleted:) atObject:self forType:SP_EVENT_TYPE_MOVIE_COMPLETED];
	} else {
		[mMuzzleFlash setFrame:[texDict objectForKey:@"Flash"] atIndex:0];
	}
	
	mMuzzleFlash.y = -mMuzzleFlash.height / 2;
	
	if (mMuzzleFlashFrame == nil) {
		mMuzzleFlashFrame = [[SPSprite alloc] init];
		mMuzzleFlashFrame.touchable = NO;
		[mMuzzleFlashFrame addChild:mMuzzleFlash];
		[mBarrel addChild:mMuzzleFlashFrame atIndex:0];
	}
	
	mMuzzleFlashFrame.x = flash.x;
	mMuzzleFlashFrame.y = flash.y;
	mMuzzleFlashFrame.scaleX = mMuzzleFlashFrame.scaleY = flashScale;
	mMuzzleFlashFrame.visible = NO;
	
	// Smoke
	if (mSmokeClouds == nil) {
		mSmokeClouds = [[RingBuffer alloc] initWithCapacity:kSmokeBufferSize];
	
		for (int i = 0; i < kSmokeBufferSize; ++i) {
			CannonSmoke *cannonSmoke = [[CannonSmoke alloc] initWithX:smoke.x y:smoke.y];
			cannonSmoke.scaleX = cannonSmoke.scaleY = smokeScale;
			[mSmokeClouds addItem:cannonSmoke];
			[mBarrel addChild:cannonSmoke];
			[cannonSmoke release];
		}
	}
	
	// Invisible touch pad
	if (mTouchQuad == nil) {
        BOOL assistedAiming = GCTRL.assistedAiming;
        float touchQuadWidth = 150, touchQuadHeight = (assistedAiming) ? 120 : mScene.viewHeight-40;
		mTouchQuad = [[SPQuad quadWithWidth:touchQuadWidth height:touchQuadHeight] retain];
		mTouchQuad.x = (self.scaleX > 0) ? mTouchQuad.width : 0;
		mTouchQuad.y = mScene.viewHeight - touchQuadHeight;
		mTouchQuad.alpha = 0;
		[mTouchQuad addEventListener:@selector(onTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
	}
	
	if (mTouchProp == nil) {
		mTouchProp = [[Prop alloc] initWithCategory:CAT_PF_HUD];
		mTouchProp.touchable = YES;
		[mTouchProp addChild:mTouchQuad];
		[mScene addProp:mTouchProp];
	}
	
[RESM pushItemOffsetWithAlignment:RALowerLeft];
	self.rx = mOrigin.x + ((self.scaleX > 0) ? offset.x : -offset.x);
	self.ry = mOrigin.y + offset.y;
[RESM popOffset];
	
	if (mReticle == nil) {
		mReticle = [[Prop alloc] initWithCategory:CAT_PF_EXPLOSIONS];
		SPImage *image =[SPImage imageWithTexture:[mScene textureByName:@"reticle"]];
		image.x = -image.width / 2;
		image.y = -image.height / 2;
		//image.color = 0xe10000;
		[mReticle addChild:image];
		[mScene addProp:mReticle];
		mReticle.x = 240.0f;
		mReticle.y = 140.0f;
		mReticle.scaleX = mReticle.scaleY = 0.5f + 0.5f * cannonDetails.bore;
		mReticle.visible = NO;
	}
}

- (SPPoint *)pointFromDictionary:(NSDictionary *)dict {
	float x = [(NSNumber *)[dict objectForKey:@"x"] floatValue];
	float y = [(NSNumber *)[dict objectForKey:@"y"] floatValue];
	return [SPPoint pointWithX:x y:y];
}

- (void)setElevationFactor:(float)value {
	mElevationFactor = MIN(1.0f,MAX(1 / 3.0f, value));
}

- (void)setActivated:(BOOL)value {
	if (value == NO)
		mReticle.visible = NO;
	mActivated = value;
}

- (void)overheat:(BOOL)enable {
    if (enable == mOverheated)
        return;
    
    SPTexture *swapTexture = mBarrelImage.texture;
    mBarrelImage.texture = mOverheatedBarrelTexture;
    mOverheatedBarrelTexture = swapTexture;
    mOverheated = enable;
}

- (void)flip:(BOOL)enable {
    if (enable) {
        mTouchProp.scaleX = -1;
        mTouchProp.x = mScene.viewWidth;
    } else {
        mTouchProp.scaleX = 1;
        mTouchProp.x = 0;
    }
}

- (void)advanceTime:(double)time {
    if (mReloadTimer > 0.0) {
        mReloadTimer -= 1.0 / GCTRL.fps; //time;
        
        if (mReloadTimer <= 0.0)
            [self reloaded];
    }
}

- (void)onTouch:(SPTouchEvent *)event {
	[event stopImmediatePropagation];
	
	if (mActivated == NO)
		return;
	// Cancelled touches
	SPTouch *touch = [[event touchesWithTarget:mTouchQuad andPhase:SPTouchPhaseCancelled] anyObject];
	
	if (touch) {
		mReticle.visible = NO;
		return;
	}
	
	// Shooting touches
	touch = [[event touchesWithTarget:mTouchQuad andPhase:SPTouchPhaseEnded] anyObject];
	
    if (touch) {
		mReticle.visible = NO;
		[self fire:true dispatch:true];
		return; // Ignore other touch events on fire to allow for a steadier aim.
    }
	
	// Crew-assisted cannons don't need to worry about begin/move touches.
	if (mShowReticle == NO)
		return;
	
	// Aiming touches
	touch = [[event touchesWithTarget:mTouchQuad andPhase:SPTouchPhaseBegan] anyObject];
	
	if (touch) {
		if (mShowReticle)
			mReticle.visible = YES;
		mBeginTouch = YES;
	}
	
	touch = [[event touchesWithTarget:mTouchQuad andPhase:SPTouchPhaseMoved] anyObject];
	
	if (touch) {
		SPPoint *touchPos = [touch locationInSpace:mTouchQuad];
		SPPoint *previousTouchPos = [touch previousLocationInSpace:mTouchQuad];
		float yDelta = (touchPos.y-previousTouchPos.y) * (kElevationThrottle / mElevationFactor);
		
		// Dampen initial "jump" from begin phase to move phase
		if (mBeginTouch == YES) {
			if (fabsf(yDelta) > 1.0f)
				yDelta = yDelta / fabsf(yDelta);
			mBeginTouch = NO;
		}
		
		float newRotation = mBarrel.rotation - (yDelta / mTouchQuad.height) * PI;
		self.elevation = MIN(SP_D2R(0.0f), MAX(SP_D2R(-45.0f),newRotation));
	}
}

- (void)positionReticleFromShipX:(float)x y:(float)y range:(float)range rotation:(float)rotation {
	if (mReticle.visible == NO)
		return;
	mReticlePosition.x = 0;
	mReticlePosition.y = range * fabsf((self.elevation / SP_D2R(45.0f)));
	[Globals rotatePoint:mReticlePosition throughAngle:rotation];
	mReticle.x = mReticlePosition.x + x;
	mReticle.y = mReticlePosition.y + y;
}

- (void)activateFlyingDutchman {
	[self decorateWithCannonDetails:[[CannonFactory munitions] createSpecialCannonDetailsForType:@"FlyingDutchman"]
						   textures:[NSDictionary dictionaryWithObjectsAndKeys:
									 mBarrelDutchmanTexture, @"Barrel",
									 mBracketDutchmanTexture, @"Bracket",
									 mWheelDutchmanTexture, @"Wheel",
									 mFlashDutchmanTexture, @"Flash",
									 nil]];
}

- (void)deactivateFlyingDutchman {
	[self decorateWithCannonDetails:[GameController GC].playerDetails.cannonDetails
						   textures:[NSDictionary dictionaryWithObjectsAndKeys:
									 mBarrelTexture, @"Barrel",
									 mBracketTexture, @"Bracket",
									 mWheelTexture, @"Wheel",
									 mFlashTexture, @"Flash",
									 nil]];
}

/*
- (void)positionReticleFromShipX:(float)x y:(float)y rotation:(float)rotation {
	if (mReticle.visible == NO)
		return;
	// 1. Get distance that cannonball would travel
	float dist = fabsf((mBarrel.rotation / 2) / kGravity);
	
	// 2. Create vector from 1. with only a y component
	SPPoint *point = [SPPoint pointWithX:0.0f y:(dist / kGravity) * 2.556f];
	
	// 3. Rotate 2. by PlayerShip's Position +/- 90 degrees, depending on which side we are on.
	[Globals rotatePoint:point throughAngle:rotation];
	
	// 4. Place reticle at the vector resulting from 3.
	point.x += x;
	point.y += y;
	mReticle.x = point.x;
	mReticle.y = point.y;
}
*/
- (void)onFlashClipCompleted:(SPEvent *)event {
	[mScene.juggler removeObject:mMuzzleFlash];
	mMuzzleFlashFrame.visible = NO;
	
	CannonSmoke *cannonSmoke = [mSmokeClouds nextItem];
	[cannonSmoke startWithAngle:mBarrel.rotation];
}

- (void)fire:(BOOL)silent dispatch:(BOOL)dispatch {
	if (mReloading)
		return;
    if (mOverheated) {
        [mScene.audioPlayer playSoundWithKey:@"CannonOverheat"];
        return;
    }
    
    if (!silent)
        [mScene.audioPlayer playSoundWithKey:@"PlayerCannon" volume:mFireVolume];
    mMuzzleFlash.currentFrame = 0;
    mMuzzleFlashFrame.visible = YES;
    [mMuzzleFlash play];
    [mScene.juggler addObject:mMuzzleFlash];
    [self recoil];
	
    if (dispatch)
        [self dispatchEvent:mFiredEvent];
    [self reload];
}

- (void)reload {
	mReloading = YES;
    mReloadTimer = mReloadInterval;
}

- (void)reloaded {
    mReloading = NO;
}

- (void)recoil {
    if (mRecoilTweens == nil) {
        float distance = 20;
        
        SPTween *tweenJolt = [SPTween tweenWithTarget:mRecoilContainer time:0.25f transition:SP_TRANSITION_EASE_OUT];
        [tweenJolt animateProperty:@"x" targetValue:-distance];
        
        float frontTargetValue = mFrontWheel.rotation + TWO_PI * (-distance / (PI * mFrontWheel.width));
        SPTween *tweenFrontJolt = [self rollWheel:mFrontWheel targetValue:frontTargetValue duration:tweenJolt.time delay:0 transition:SP_TRANSITION_EASE_OUT];
        
        float rearTargetValue = mRearWheel.rotation + TWO_PI * (-distance / (PI * mRearWheel.width));
        SPTween *tweenRearJolt = [self rollWheel:mRearWheel targetValue:rearTargetValue duration:tweenJolt.time delay:0 transition:SP_TRANSITION_EASE_OUT];
        
        SPTween *tweenReturn = [SPTween tweenWithTarget:mRecoilContainer time:mReloadInterval-(tweenJolt.time+0.1f)];
        [tweenReturn animateProperty:@"x" targetValue:mRecoilContainer.x];
        tweenReturn.delay = tweenJolt.time;
        
        frontTargetValue = frontTargetValue + TWO_PI * (distance / (PI * mFrontWheel.width));
        SPTween *tweenFrontReturn = [self rollWheel:mFrontWheel targetValue:frontTargetValue duration:tweenReturn.time delay:tweenReturn.delay transition:SP_TRANSITION_LINEAR];
        
        rearTargetValue = rearTargetValue + TWO_PI * (distance / (PI * mRearWheel.width));
        SPTween *tweenRearReturn = [self rollWheel:mRearWheel targetValue:rearTargetValue duration:tweenReturn.time delay:tweenReturn.delay transition:SP_TRANSITION_LINEAR];
        
        mRecoilTweens = [[NSArray alloc] initWithObjects:
                         tweenRearReturn,
                         tweenFrontReturn,
                         tweenReturn,
                         tweenRearJolt,
                         tweenFrontJolt,
                         tweenJolt,
                         nil];
    }
    
    for (SPTween *tween in mRecoilTweens) {
        [tween reset];
        [mScene.juggler addObject:tween];
    }
}

- (SPTween *)rollWheel:(SPSprite *)wheel targetValue:(float)targetValue duration:(float)duration delay:(float)delay transition:(NSString *)transition {
	SPTween *tween = [SPTween tweenWithTarget:wheel time:duration transition:transition];
	[tween animateProperty:@"rotation" targetValue:targetValue];
    tween.delay = delay;
	return tween;
}

- (float)elevation {
	return mBarrel.rotation;
}

- (int)direction {
	return (self.scaleX > 0) ? 1 : -1;
}

- (float)reticleRotation {
	return mReticle.rotation;
}

- (void)setReticleRotation:(float)value {
	mReticle.rotation = value;
}

- (void)setElevation:(float)elevation {
	mBarrel.rotation = elevation;
}

- (void)enableTouch:(BOOL)enable {
    if (mTouchProp)
    {
        [mScene removeProp:mTouchProp];
        if (enable)
            [mScene addProp:mTouchProp];
    }
}

- (void)destroy {
    [mFiredEvent autorelease]; mFiredEvent = nil;
}

- (void)dealloc {
	[mMuzzleFlash removeEventListener:@selector(onFlashClipCompleted:) atObject:self forType:SP_EVENT_TYPE_MOVIE_COMPLETED];
	[mTouchQuad removeEventListener:@selector(onTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
	[mScene.juggler removeTweensWithTarget:mRecoilContainer];
	[mScene.juggler removeObject:mMuzzleFlash];
	[mScene removeProp:mReticle];
	[mScene removeProp:mTouchProp];
	[mOrigin release]; mOrigin = nil;
	[mReticlePosition release]; mReticlePosition = nil;
	[mReticle release]; mReticle = nil;
	[mTouchProp release]; mTouchProp = nil;
	[mTouchQuad release]; mTouchQuad = nil;
	[mMuzzleFlashFrame release]; mMuzzleFlashFrame = nil;
	[mSmokeClouds release]; mSmokeClouds = nil;
	[mBarrel release]; mBarrel = nil;
	[mBracket release]; mBracket = nil;
	[mBarrelImage release]; mBarrelImage = nil;
	[mBracketImage release]; mBracketImage = nil;
	[mFrontWheelImage release]; mFrontWheelImage = nil;
	[mFrontWheel release]; mFrontWheel = nil;
	[mRearWheelImage release]; mRearWheelImage = nil;
	[mRearWheel release]; mRearWheel = nil;
	[mMuzzleFlash release]; mMuzzleFlash = nil;
	[mRecoilContainer release]; mRecoilContainer = nil;
	[mBarrelTexture release]; mBarrelTexture = nil;
    [mOverheatedBarrelTexture release]; mOverheatedBarrelTexture = nil;
	[mBracketTexture release]; mBracketTexture = nil;
	[mWheelTexture release]; mWheelTexture = nil;
	[mFlashTexture release]; mFlashTexture = nil;
	[mBarrelDutchmanTexture release]; mBarrelDutchmanTexture = nil;
	[mBracketDutchmanTexture release]; mBracketDutchmanTexture = nil;
	[mWheelDutchmanTexture release]; mWheelDutchmanTexture = nil;
	[mFlashDutchmanTexture release]; mFlashDutchmanTexture = nil;
    [mRecoilTweens release]; mRecoilTweens = nil;
	[super dealloc];
}

@end

