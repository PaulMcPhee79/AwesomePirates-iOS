//
//  FutureManager.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 21/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"


@interface FutureManager : Prop {
    SPSprite *mSparkTarget;
	Prop *mElectricityProp;
	Prop *mFlamePathsProp;
	NSMutableArray *mFlamePathsClips;
}

@property (nonatomic,readonly) float electricityDuration;
@property (nonatomic,readonly) float flamePathDuration;
@property (nonatomic,readonly) float flamePathExtinguishDuration;

- (void)sparkElectricityAtX:(float)x y:(float)y;
- (void)sparkElectricityOnSprite:(SPSprite *)sprite;
- (void)igniteFlamePathsAtSprite:(SPSprite *)sprite;
- (void)destroy;

@end
