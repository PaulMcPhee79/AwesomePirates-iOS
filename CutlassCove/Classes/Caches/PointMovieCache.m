//
//  PointMovieCache.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 24/10/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "PointMovieCache.h"
#import "PointMovie.h"
#import "Splash.h"
#import "Explosion.h"
#import "CannonFire.h"
#import "SceneController.h"

@implementation PointMovieCache

- (void)fillResourcePoolForScene:(SceneController *)scene {
	if (mDictPool)
		return;
	mDictPool = [[NSMutableDictionary alloc] initWithCapacity:3];
	
	NSArray *splashFrames = [scene texturesStartingWith:@"splash_" atlasName:scene.sceneKey cacheGroup:TM_CACHE_POINT_MOVIES];
	NSArray *explodeFrames = [scene texturesStartingWith:@"explode_" atlasName:scene.sceneKey cacheGroup:TM_CACHE_POINT_MOVIES];
	NSArray *smokeFrames = [scene texturesStartingWith:@"cannon-smoke-small_" atlasName:scene.sceneKey cacheGroup:TM_CACHE_POINT_MOVIES];
	
	NSArray *keys = [NSArray arrayWithObjects:@"Splash",@"Explosion",@"CannonFire",nil];
	NSArray *frames = [NSArray arrayWithObjects:splashFrames,explodeFrames,smokeFrames,nil];
	NSArray *framesPerSec = [NSArray arrayWithObjects:
							 [NSNumber numberWithFloat:[Splash fps]],
							 [NSNumber numberWithFloat:[Explosion fps]],
							 [NSNumber numberWithFloat:[CannonFire fps]],
							 nil];
	assert(keys.count == frames.count && keys.count == framesPerSec.count);
	
	for (int i = 0; i < keys.count; ++i) {
		NSMutableArray *poolArray = [NSMutableArray arrayWithCapacity:15];
		NSString *key = (NSString *)[keys objectAtIndex:i];
		NSArray *clipFrames = (NSArray *)[frames objectAtIndex:i];
		float fps = [(NSNumber *)[framesPerSec objectAtIndex:i] floatValue];
		
		for (int j = 0; j < 25; ++j) {
            ResourceServer *resources = [ResourceServer resourceServer];
            
            SPMovieClip *movie = [SPMovieClip movieWithFrames:clipFrames fps:fps];
            [movie addEventListener:@selector(onMovieCompleted:) atObject:resources forType:SP_EVENT_TYPE_MOVIE_COMPLETED];
            
            [resources addMovie:movie forKey:RESOURCE_KEY_PM_MOVIE];
            [resources addMiscResource:key forKey:RESOURCE_KEY_CHAIN];
			[poolArray addObject:resources];
		}
		
		[mDictPool setObject:poolArray forKey:key];
	}
}

@end
