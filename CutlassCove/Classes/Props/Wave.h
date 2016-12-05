//
//  Wave.h
//  Pirates
//
//  Created by Paul McPhee on 16/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

typedef enum {
    WSSNormal = 0,
    WSSTransitionToNight,
    WSSTransitionToDay
} WaveSurfaceState;

@interface Wave : Prop {
    WaveSurfaceState mState;
    
	float mAlphaMin;
    float mAlphaMid;
	float mAlphaMax;
	float mAlphaRate;
    
    float mFlowX;
    float mFlowY;
    
    float mXRepeat;
    float mYRepeat;
    
    SPImage *mSurface;
    SPSprite *mSurfaceContainer;
}

@property (nonatomic,readonly) float alphaMin;
@property (nonatomic,readonly) float alphaMax;
@property (nonatomic,readonly) float alphaRate;
@property (nonatomic,assign) float flowX;
@property (nonatomic,assign) float flowY;
@property (nonatomic,readonly) SPImage *surface;

- (id)initWithTexture:(SPTexture *)texture initAlpha:(float)initAlpha target:(float)target rate:(float)rate;
- (void)setOrientation:(float)angle;
- (void)flowXOverTime:(float)duration;
- (void)flowYOverTime:(float)duration;
- (void)timeOfDayChanged:(TimeOfDayChangedEvent *)event;

@end
