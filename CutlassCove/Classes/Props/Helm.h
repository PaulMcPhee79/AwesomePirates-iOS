//
//  Helm.h
//  Pirates
//
//  Created by Paul McPhee on 17/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"
#import "Loadable.h"

@interface Helm : Prop <Loadable> {
	BOOL mFlyingDutchman;
    BOOL mSpeedboat;
	SPTexture *mFlyingDutchmanTexture;
    SPTexture *mSpeedboatTexture;
	
	SPSprite *mWheel;
	SPImage *mWheelImage;
	SPPoint *mCenterPoint;
	SPQuad *mTouchQuad;
	float mRecoilRate;
    float mRotationIncrement;
	float mPreviousRotation;
	float mHelmRotation;
}

@property (nonatomic) float recoilRate;
@property (nonatomic, retain) SPPoint *centerPoint;
@property (nonatomic, readonly) float turnAngle;
@property (nonatomic, retain) SPSprite *wheel;
@property (nonatomic, retain) SPImage *wheelImage;

- (id)initWithRotationIncrement:(float)rotationIncrement;
- (void)fpsFactorChanged:(float)value;
- (float)addRotation:(float)angle;
- (void)resetRotation;
- (void)activateSpeedboat;
- (void)deactivateSpeedboat;
- (void)activateFlyingDutchman;
- (void)deactivateFlyingDutchman;

@end
