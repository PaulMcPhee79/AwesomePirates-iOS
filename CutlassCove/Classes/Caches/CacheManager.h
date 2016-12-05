//
//  CacheManager.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 24/10/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RESOURCE_KEY_CHAIN UINT32_MAX

#define CACHE_CANNONBALL @"Cannonball"
#define CACHE_LOOT_PROP @"LootProp"
#define CACHE_NPC_SHIP @"NpcShip"
#define CACHE_POINT_MOVIE @"PointMovie"
#define CACHE_WAKE @"Wake"
#define CACHE_SHARK @"Shark"
#define CACHE_POOL_ACTOR @"PoolActor"
#define CACHE_TEMPEST @"Tempest"
#define CACHE_BLAST_PROP @"BlastProp"

@class SceneController,ResourceServer;

@interface CacheManager : NSObject {
	NSMutableArray *mArrayPool;
	NSMutableDictionary *mDictPool;
}

- (void)fillResourcePoolForScene:(SceneController *)scene;
- (void)drainResourcePool;
- (ResourceServer *)checkoutPoolResources;
- (ResourceServer *)checkoutPoolResourcesForKey:(NSString *)key;
- (void)checkinPoolResources:(ResourceServer *)resources;
- (void)reassignResourceServersToScene:(SceneController *)scene;

@end
