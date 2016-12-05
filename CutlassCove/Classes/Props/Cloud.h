//
//  Cloud.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 20/10/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

@interface Cloud : Prop {
	float mVelX;
	float mVelY;
	
	float mVapourHalfWidth;
	float mVapourHalfHeight;
	float mShadowHalfWidth;
	float mShadowHalfHeight;
	
	float mShadowOffsetX;
	float mShadowOffsetY;
	Prop *mVapour;
	Prop *mShadow;
}

@property (nonatomic,assign) float shadowOffsetX;
@property (nonatomic,assign) float shadowOffsetY;

- (id)initWithCloudType:(uint)cloudType velX:(float)velX velY:(float)velY alpha:(float)alpha;
- (BOOL)isBlownOffscreen;

+ (Cloud *)cloudWithCloudType:(uint)cloudType velX:(float)velX velY:(float)velY alpha:(float)alpha;
+ (NSRange)cloudRange;
+ (uint)randomCloudType;

@end
