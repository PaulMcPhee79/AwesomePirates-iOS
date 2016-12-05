//
//  Cloud.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 20/10/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "Cloud.h"
#import "Globals.h"

@interface Cloud ()


@end

const NSRange kCloudTypes = { .location = 0, .length = 3 }; // Indexes 0..2


@implementation Cloud

@synthesize shadowOffsetX = mShadowOffsetX;
@synthesize shadowOffsetY = mShadowOffsetY;

+ (NSRange)cloudRange {
	return kCloudTypes;
}

+ (uint)randomCloudType {
	return RANDOM_INT(kCloudTypes.location, kCloudTypes.length-1);
}

+ (Cloud *)cloudWithCloudType:(uint)cloudType velX:(float)velX velY:(float)velY alpha:(float)alpha {
	return [[[Cloud alloc] initWithCloudType:cloudType velX:velX velY:velY alpha:alpha] autorelease];
}

- (id)initWithCloudType:(uint)cloudType velX:(float)velX velY:(float)velY alpha:(float)alpha {
	if (self = [super initWithCategory:-1]) {
		cloudType = MAX(kCloudTypes.location, MIN(kCloudTypes.length-1, cloudType));
		mVelX = velX;
		mVelY = velY;
		
		// Water Vapour Mist
		mVapour = [[Prop alloc] initWithCategory:CAT_PF_CLOUDS];
		mVapour.alpha = alpha;
		
		SPImage *image = [SPImage imageWithTexture:[mScene textureByName:[NSString stringWithFormat:@"cloud%d", cloudType] cacheGroup:TM_CACHE_ENVIRONMENT]];
		image.x = -image.width / 2;
		image.y = -image.height / 2;
		[mVapour addChild:image];
		
		mVapourHalfWidth = mVapour.width / 2;
		mVapourHalfHeight = mVapour.height / 2;
		
		// Shadow
		mShadow = [[Prop alloc] initWithCategory:CAT_PF_CLOUD_SHADOWS];
		mShadow.alpha = 0.3f;
		
		image = [SPImage imageWithTexture:[mScene textureByName:[NSString stringWithFormat:@"cloud%d", cloudType] cacheGroup:TM_CACHE_ENVIRONMENT]];
		image.x = -image.width / 2;
		image.y = -image.height / 2;
		image.color = 0;
		image.alpha = 0.375f;
		[mShadow addChild:image];
		mShadow.scaleX = 1.2f;
		mShadow.scaleY = 1.2f;
		
		mShadowHalfWidth = mShadow.width / 2;
		mShadowHalfHeight = mShadow.height / 2;
		
		[mScene addProp:mVapour];
		[mScene addProp:mShadow];
	}
	return self;
}

- (id)initWithCategory:(int)category {
	return [self initWithCloudType:0 velX:1.0f velY:1.0f alpha:1.0f];
}

- (id)init {
	return [self initWithCloudType:0 velX:1.0f velY:1.0f alpha:1.0f];
}

- (void)setupProp {
	[super setupProp];
	// First, position vapour and shadow relatively so we get an accurate bounding box.
	mShadow.x = mShadowOffsetX;
	mShadow.y = mShadowOffsetY;
	
	float x, y;
	SPRectangle *bbox = self.bounds;
	
	if (mVelX > 0)
		x = RANDOM_INT((int)-mScene.viewWidth/2, (int)mScene.viewWidth/2);
	else
		x = RANDOM_INT((int)mScene.viewWidth / 2, (int)(1.5f * mScene.viewWidth));
	
	if (mVelY > 0)
		y = -bbox.height / 2;
	else
		y = mScene.viewHeight + bbox.height / 2;
	mVapour.x = x;
	mVapour.y = y;
	mShadow.x = x + mShadowOffsetX;
	mShadow.y = y + mShadowOffsetY;
}

- (SPRectangle *)bounds {
	return [mVapour.bounds uniteWithRectangle:mShadow.bounds];
}

- (BOOL)isBlownOffscreen {
	float leftMost = MIN(mVapour.x - mVapourHalfWidth, mShadow.x - mShadowHalfWidth);
	float rightMost = MAX(mVapour.x + mVapourHalfWidth, mShadow.x + mShadowHalfWidth);
	float topMost =  MIN(mVapour.y - mVapourHalfHeight, mShadow.y - mShadowHalfHeight);
	float bottomMost = MAX(mVapour.y + mVapourHalfHeight, mShadow.y + mShadowHalfHeight);
	
	return ((mVelX > 0 && leftMost > mScene.viewWidth) ||
			(mVelX < 0 && rightMost < 0) ||
			(mVelY > 0 && topMost > mScene.viewHeight) ||
			(mVelY < 0 && bottomMost < 0));
}

- (void)advanceTime:(double)time {
    mVapour.x += mVelX * time;
	mVapour.y += mVelY * time;
	mShadow.x = mVapour.x + mShadowOffsetX;
	mShadow.y = mVapour.y + mShadowOffsetY;
}

- (void)dealloc {
	[mScene removeProp:mVapour];
	[mScene removeProp:mShadow];
	[mVapour release]; mVapour = nil;
	[mShadow release]; mShadow = nil;
	[super dealloc];
}

@end
