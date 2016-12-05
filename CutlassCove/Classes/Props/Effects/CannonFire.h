//
//  CannonFire.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 12/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PointMovie.h"

@interface CannonFire : PointMovie {
	float mVelX;
	float mVelY;
}

@property (nonatomic,assign) float cannonRotation;

- (id)initWithX:(float)x y:(float)y;
- (void)setLinearVelocityX:(float)x y:(float)y;
+ (float)fps;

@end
