//
//  ShipHitGlow.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 11/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

@interface ShipHitGlow : Prop {
	int mState;
	float mDuration[4];
	float mTargets[4];
}

@property (nonatomic,readonly) BOOL isCompleted;

- (id)initWithX:(float)x y:(float)y;
- (void)rerun;

@end
