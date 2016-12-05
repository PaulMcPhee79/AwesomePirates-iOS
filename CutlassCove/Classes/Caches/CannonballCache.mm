//
//  CannonballCache.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 24/10/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "CannonballCache.h"
#import "Cannonball.h"
#import "SceneController.h"

@implementation CannonballCache

- (void)fillResourcePoolForScene:(SceneController *)scene shotTypes:(NSArray *)shotTypes {
	if (mDictPool)
		return;
	mDictPool = [[NSMutableDictionary alloc] initWithCapacity:shotTypes.count];
    
	for (NSString *shotType in shotTypes) {
		NSMutableArray *poolArray = [NSMutableArray arrayWithCapacity:15];
		
		for (int i = 0; i < 15; ++i) {
            ResourceServer *resources = [ResourceServer resourceServer];
			NSArray *frames = [scene texturesStartingWith:shotType atlasName:scene.sceneKey cacheGroup:TM_CACHE_CANNONBALLS];
			
			SPMovieClip *ballClip = [SPMovieClip movieWithFrames:frames fps:[Cannonball fps]];
			ballClip.x = -ballClip.width/2;
			ballClip.y = -ballClip.height/2;
			ballClip.loop = YES;
            [resources addMovie:ballClip forKey:RESOURCE_KEY_CANNONBALL_CLIP];
			
			SPMovieClip *shadowClip = [SPMovieClip movieWithFrames:frames fps:[Cannonball fps]];
			shadowClip.x = -shadowClip.width/2;
			shadowClip.loop = YES;
            [resources addMovie:shadowClip forKey:RESOURCE_KEY_SHADOW_CLIP];
            
            [resources addMiscResource:shotType forKey:RESOURCE_KEY_CHAIN];
            [poolArray addObject:resources];
		}
		
		[mDictPool setObject:poolArray forKey:shotType];
	}
}

@end
