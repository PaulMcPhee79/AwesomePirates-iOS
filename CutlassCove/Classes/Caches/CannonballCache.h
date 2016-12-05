//
//  CannonballCache.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 24/10/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CacheManager.h"
#import "ResourceServer.h"

#define RESOURCE_KEY_CANNONBALL_CLIP 1UL
#define RESOURCE_KEY_SHADOW_CLIP 2UL

@interface CannonballCache : CacheManager

- (void)fillResourcePoolForScene:(SceneController *)scene shotTypes:(NSArray *)shotTypes;

@end
