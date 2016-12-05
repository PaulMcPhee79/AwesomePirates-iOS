//
//  WaterFire.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 23/10/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

@interface WaterFire : Prop {
	BOOL mIgnited;
    BOOL mExtinguishing;
	SPSprite *mCanvas;
	NSMutableArray *mFlames;
}

@property (nonatomic,readonly) BOOL ignited;

- (id)initWithCategory:(int)category flameCoords:(int *)flameCoords numFlames:(int)numFlames;
- (void)ignite;
- (void)extinguishOverTime:(float)duration;

@end
