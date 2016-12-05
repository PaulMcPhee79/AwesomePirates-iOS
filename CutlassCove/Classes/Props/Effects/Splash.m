//
//  Splash.m
//  Pirates
//
//  Created by Paul McPhee on 18/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "Splash.h"
#import "Globals.h"

@implementation Splash

- (id)initWithX:(float)x y:(float)y {
	if (self = [super initWithCategory:CAT_PF_POINT_MOVIES type:MovieTypeSplash x:x y:y]) {
		[self setupMovie];
	}
	return self;
}

- (void)setupMovie {
	if (mMovie == nil)
		mMovie = [[SPMovieClip alloc] initWithFrames:[mScene texturesStartingWith:@"splash_" cacheGroup:TM_CACHE_POINT_MOVIES] fps:[Splash fps]];
	mMovie.x = -mMovie.width/2;
	mMovie.y = -mMovie.height/2;
	mMovie.loop = NO;
	self.alpha = 0.65f;
    [super setupMovie];
}

+ (float)fps {
	return 12.0f;
}

@end

