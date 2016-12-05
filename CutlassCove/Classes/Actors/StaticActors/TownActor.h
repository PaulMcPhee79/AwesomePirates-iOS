//
//  TownActor.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 7/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StaticActor.h"

@class TownCannon,NightShade;

@interface TownActor : StaticActor {
	SPSprite *mTownSprite;
	SPSprite *mTownFutureSprite;
	Prop *mTownLights;
    Prop *mTownHouseAndCannon;
	Prop *mTownFutureLights;
	TownCannon *mLeftCannon;
	TownCannon *mRightCannon;
	NightShade *mNightShade;
}

@property (nonatomic,retain) TownCannon *leftCannon;
@property (nonatomic,retain) TownCannon *rightCannon;

- (void)setupTown;
- (void)setHidden:(BOOL)hidden;
- (void)travelBackInTime:(float)duration;
- (void)travelForwardInTime:(float)duration;

@end
