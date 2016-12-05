//
//  SharkCache.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 24/10/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CacheManager.h"
#import "ResourceServer.h"

#define RESOURCE_KEY_SHARK_SWIM 1UL
#define RESOURCE_KEY_SHARK_ATTACK 2UL

#define RESOURCE_KEY_SHARK_RIPPLES 1UL
#define RESOURCE_KEY_SHARK_RIPPLES_TWEEN 2UL

#define RESOURCE_KEY_SHARK_PERSON 1UL
#define RESOURCE_KEY_SHARK_BLOOD 2UL
#define RESOURCE_KEY_SHARK_PERSON_TWEEN 3UL
#define RESOURCE_KEY_SHARK_BLOOD_TWEEN 4UL

@interface SharkCache : CacheManager

@end
