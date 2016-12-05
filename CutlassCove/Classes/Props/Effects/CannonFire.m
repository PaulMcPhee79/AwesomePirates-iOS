//
//  CannonFire.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 12/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "CannonFire.h"
#import "Globals.h"

@implementation CannonFire

@dynamic cannonRotation;

- (id)initWithX:(float)x y:(float)y {
	if (self = [super initWithCategory:CAT_PF_EXPLOSIONS type:MovieTypeCannonFire x:x y:y]) {
		mAdvanceable = YES;
		mVelX = 0.0f;
		mVelY = 0.0f;
		[self setupMovie];
	}
	return self;
}

- (void)setupMovie {
	if (mMovie == nil)
		mMovie = [[SPMovieClip alloc] initWithFrames:[mScene texturesStartingWith:@"cannon-smoke-small_" cacheGroup:TM_CACHE_POINT_MOVIES] fps:[CannonFire fps]];
	mMovie.x = -mMovie.width/2;
	mMovie.y = -mMovie.height;
	mMovie.loop = NO;
    
    [super setupMovie];
}

- (float)cannonRotation {
	return self.rotation;
}

- (void)setCannonRotation:(float)angle {
	 self.rotation = angle;
}

- (void)setLinearVelocityX:(float)x y:(float)y {
	mVelX = x;
	mVelY = y;
}

- (void)advanceTime:(double)time {
	self.x += mVelX;
	self.y += mVelY;
}

+ (float)fps {
	return 10.0f;
}

@end
