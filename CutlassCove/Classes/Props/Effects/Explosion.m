//
//  Explosion.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 8/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "Explosion.h"
#import "Globals.h"

@implementation Explosion

- (id)initWithX:(float)x y:(float)y {
	if (self = [super initWithCategory:CAT_PF_EXPLOSIONS type:MovieTypeExplosion x:x y:y]) {
		[self setupMovie];
	}
	return self;
}

- (void)setupMovie {
	if (mMovie == nil)
		mMovie = [[SPMovieClip alloc] initWithFrames:[mScene texturesStartingWith:@"explode_" cacheGroup:TM_CACHE_POINT_MOVIES] fps:[Explosion fps]];
    mMovie.x = -mMovie.width/2;
	mMovie.y = -mMovie.height/2;
	mMovie.loop = NO;
	[super setupMovie];
}

+ (float)fps {
	return 12.0f;
}

@end

