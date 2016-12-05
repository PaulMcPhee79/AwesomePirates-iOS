//
//  TempestCache.h
//  CutlassCove
//
//  Created by Paul McPhee on 4/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResourceServer.h"
#import "CacheManager.h"

#define RESOURCE_KEY_TEMPEST_DEBRIS 1UL
#define RESOURCE_KEY_TEMPEST_DEBRIS_TWEEN_IN 2UL
#define RESOURCE_KEY_TEMPEST_DEBRIS_TWEEN_OUT 102UL // Can't overlap with in tween indexes (ripple count < 100)

@interface TempestCache : CacheManager

@end
