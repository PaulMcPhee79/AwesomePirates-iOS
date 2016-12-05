//
//  NpcShipCache.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 24/10/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CacheManager.h"
#import "ResourceServer.h"

#define RESOURCE_KEY_NPC_GENERICS 1UL
#define RESOURCE_KEY_NPC_SINKING 2UL
#define RESOURCE_KEY_NPC_BURNING 3UL
#define RESOURCE_KEY_NPC_COSTUME 4UL
#define RESOURCE_KEY_NPC_WARDROBE 5UL
#define RESOURCE_KEY_NPC_DOCK_TWEEN 6UL
#define RESOURCE_KEY_NPC_BURN_IN_TWEEN 7UL
#define RESOURCE_KEY_NPC_BURN_OUT_TWEEN 8UL
#define RESOURCE_KEY_NPC_SHRINK_TWEEN 9UL

@interface NpcShipCache : CacheManager {

}

@end
