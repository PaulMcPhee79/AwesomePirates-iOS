//
//  PointMovie.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 8/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "PointMovie.h"
#import "PointMovieCache.h"
#import "Splash.h"
#import "Explosion.h"
#import "CannonFire.h"
#import "Globals.h"


@interface PointMovie ()

- (void)movieCompleted;
- (void)onMovieCompleted:(SPEvent *)event;

@end


@implementation PointMovie

@dynamic loop;

+ (NSString *)resourceKeyForType:(int)movieType {
	NSString *key = nil;
	
	switch (movieType) {
		case MovieTypeSplash: key = @"Splash"; break;
		case MovieTypeExplosion: key = @"Explosion";break;
		case MovieTypeCannonFire: key = @"CannonFire"; break;
		default: assert(0); break;
	}
	return key;
}

+ (PointMovie *)pointMovieWithType:(int)movieType x:(float)x y:(float)y {
	PointMovie *pointMovie = nil;
	
	switch (movieType) {
		case MovieTypeSplash: pointMovie = [[Splash alloc] initWithX:x y:y]; break;
		case MovieTypeExplosion: pointMovie = [[Explosion alloc] initWithX:x y:y]; break;
		case MovieTypeCannonFire: pointMovie = [[CannonFire alloc] initWithX:x y:y]; break;
		default: assert(0); break;
	}
	return [pointMovie autorelease];
}

- (id)initWithCategory:(int)category type:(PointMovieType)movieType x:(float)x y:(float)y {
    if (self = [super initWithCategory:category]) {
		mResourceKey = [[PointMovie resourceKeyForType:movieType] copy];
		mResources = nil;
		mMovie = nil;
		self.x = x;
		self.y = y;
		[self checkoutPooledResources];
    }
    return self;
}

- (id)init {
	return [self initWithCategory:CAT_PF_POINT_MOVIES type:MovieTypeSplash x:0 y:0];
}

- (void)setupMovie {
	assert(mMovie);
    [mMovie play];
	[self addChild:mMovie];
	[mScene addProp:self];
	[mScene.juggler addObject:mMovie];
    
    if (![mResources displayObjectForKey:RESOURCE_KEY_PM_MOVIE])
        [mMovie addEventListener:@selector(onMovieCompleted:) atObject:self forType:SP_EVENT_TYPE_MOVIE_COMPLETED];
}

- (BOOL)loop {
	return mMovie.loop;
}

- (void)setLoop:(BOOL)loop {
	mMovie.loop = loop;
}

- (void)movieCompleted {
    [mScene.juggler removeObject:mMovie];
	[mScene removeProp:self];
}

- (void)onMovieCompleted:(SPEvent *)event {
	[self movieCompleted];
}

- (void)resourceEventFiredWithKey:(uint)key type:(NSString *)type target:(NSObject *)target {
    switch (key) {
        case RESOURCE_KEY_PM_MOVIE:
            [self movieCompleted];
            break;
        default:
            break;
    }
}

- (void)checkoutPooledResources {
	if (mResources == nil)
		mResources = [[[mScene cacheManagerByName:CACHE_POINT_MOVIE] checkoutPoolResourcesForKey:mResourceKey] retain];
	if (mResources == nil)
		NSLog(@"_+_+_+_+_+_+_+_+_ MISSED POINT MOVIE CACHE _+_++_+_+_+_+_+_+");
    else {
        mResources.client = self;
        
        if (mMovie == nil)
            mMovie = [(SPMovieClip *)[mResources displayObjectForKey:RESOURCE_KEY_PM_MOVIE] retain];
    }
}

- (void)checkinPooledResources {
    if (mResources) {
        [[mScene cacheManagerByName:CACHE_POINT_MOVIE] checkinPoolResources:mResources];
        [mResources release]; mResources = nil;
    }
}

- (void)dealloc {
	if (mMovie) {
		[mScene.juggler removeObject:mMovie];
		[mMovie removeEventListener:@selector(onMovieCompleted:) atObject:self forType:SP_EVENT_TYPE_MOVIE_COMPLETED];
	}
	
	[self checkinPooledResources];
	[mResourceKey release]; mResourceKey = nil;
	[mMovie release]; mMovie = nil;
    [super dealloc];
}

@end

