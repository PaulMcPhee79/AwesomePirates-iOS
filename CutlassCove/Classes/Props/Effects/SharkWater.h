//
//  SharkWater.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 18/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"
#import "ResourceClient.h"

@interface SharkWater : Prop <ResourceClient> {
    BOOL mHasPlayedEffect;
	SPSprite *mWaterRing;
	NSArray *mRipples;
	ResourceServer *mResources;
}

- (id)initWithX:(float)x y:(float)y;
- (void)playEffect;

+ (int)numRipples;
+ (float)waterRingDuration;

@end
