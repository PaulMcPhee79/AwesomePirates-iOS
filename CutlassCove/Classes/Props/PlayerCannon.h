//
//  PlayerCannon.h
//  Pirates
//
//  Created by Paul McPhee on 19/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"
#import "PlayerCannonFiredEvent.h"
#import "Loadable.h"

@class RingBuffer,PlayerCannonFiredEvent;

@interface PlayerCannon : Prop <Loadable> {
	BOOL mActivated;
	BOOL mShowReticle;
	BOOL mBeginTouch;
    BOOL mOverheated;
	float mElevationFactor;
    float mFireVolume;
	
	// Normal textures
	SPTexture *mBarrelTexture;
    SPTexture *mOverheatedBarrelTexture;
	SPTexture *mBracketTexture;
	SPTexture *mWheelTexture;
	SPTexture *mFlashTexture;
	
	// Flying Dutchman textures
	SPTexture *mBarrelDutchmanTexture;
	SPTexture *mBracketDutchmanTexture;
	SPTexture *mWheelDutchmanTexture;
	SPTexture *mFlashDutchmanTexture;
	
	SPPoint *mOrigin;
	SPSprite *mBarrel;
	SPImage *mBarrelImage;
	SPSprite *mBracket;
	SPImage *mBracketImage;
	SPImage *mFrontWheelImage;
	SPSprite *mFrontWheel;
	SPImage *mRearWheelImage;
	SPSprite *mRearWheel;
	SPSprite *mMuzzleFlashFrame;
	SPMovieClip *mMuzzleFlash;
	SPSprite *mRecoilContainer;
	
	SPPoint *mReticlePosition;
	Prop *mReticle;
	Prop *mTouchProp;
	SPQuad *mTouchQuad;
	
	RingBuffer *mSmokeClouds;
	uint mBitmap; // For CANNON CONNOISSEUR achievement
	double mReloadInterval;
    double mReloadTimer;
	BOOL mReloading;
    
    NSArray *mRecoilTweens;
    PlayerCannonFiredEvent *mFiredEvent;
}

@property (nonatomic,assign) BOOL showReticle;
@property (nonatomic,assign) BOOL activated;
@property (nonatomic,readonly) BOOL reloading;
@property (nonatomic,readonly) BOOL overheated;
@property (nonatomic,assign) double reloadInterval;
@property (nonatomic,assign) float elevation;
@property (nonatomic,assign) float elevationFactor;
@property (nonatomic,assign) uint bitmap;
@property (nonatomic,readonly) int direction;
@property (nonatomic,assign) float reticleRotation;

- (void)fire:(BOOL)silent dispatch:(BOOL)dispatch;
- (void)reload;
- (void)overheat:(BOOL)enable;
- (void)positionReticleFromShipX:(float)x y:(float)y range:(float)range rotation:(float)rotation;
- (void)setupDutchmanTextures;
- (void)activateFlyingDutchman;
- (void)deactivateFlyingDutchman;
- (void)enableTouch:(BOOL)enable;
- (void)destroy;
//- (void)positionReticleFromShipX:(float)x y:(float)y rotation:(float)rotation;

@end
