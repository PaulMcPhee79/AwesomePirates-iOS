//
//  PoolActorCache.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 25/10/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CacheManager.h"
#import "ResourceServer.h"

#define RESOURCE_KEY_POOL_COSTUME 1UL
#define RESOURCE_KEY_POOL_RIPPLES 2UL
#define RESOURCE_KEY_POOL_SPAWN_TWEEN 3UL
#define RESOURCE_KEY_POOL_DESPAWN_TWEEN 4UL
#define RESOURCE_KEY_POOL_RIPPLE_TWEEN_SCALE 5UL
#define RESOURCE_KEY_POOL_RIPPLE_TWEEN_ALPHA 105UL // Can't overlap with scale tween indexes (ripple count < 100)

@interface PoolActorCache : CacheManager {

}

@end
