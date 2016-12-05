//
//  Sea.h
//  Pirates
//
//  Created by Paul McPhee on 16/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

@class WhirlpoolActor;

#define CUST_EVENT_TYPE_SEA_OF_LAVA_PEAKED @"seaOfLavaPeakedEvent"

@interface Sea : Prop {
	@private
	int mState;
	int mLavaState;
	int mTimeOfDay;
    uint mLavaID;
	BOOL mTweening;
    double mWhirlpoolTimer;
	
	SPQuad *mWater;
	SPQuad *mLava;
	SPSprite *mWaterSprite;
	SPSprite *mShoreBreak;
	NSArray *mTimeGradients;
	Prop *mWaveProp;
    Prop *mLavaWaveProp;
	NSMutableArray *mWaves;
    
    NSMutableDictionary *mGradientTweens;
    NSMutableArray *mShorebreakApproachTweens;
    NSMutableArray *mShorebreakRecedeTweens;
	
	WhirlpoolActor *mWhirlpool;
}

@property (nonatomic,assign) float lavaAlpha;

+ (float)lavaTransitionDuration;
+ (float)whirlpoolWavesAlpha;
- (void)setShorebreakHidden:(BOOL)hidden;
- (void)timeOfDayChanged:(TimeOfDayChangedEvent *)event;
- (void)transitionToLavaOverTime:(float)duration;
- (void)transitionFromLavaOverTime:(float)duration;
- (void)transitionFromLavaOverTime:(float)duration delay:(float)delay;
- (void)transitionToWhirlpoolOverTime:(float)duration;
- (void)transitionFromWhirlpoolOverTime:(float)duration;
- (void)summonWhirlpoolWithDuration:(float)duration;
- (void)enableSlowedTime:(BOOL)enable;
- (void)prepareForNewGame;

@end
