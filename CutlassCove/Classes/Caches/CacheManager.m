//
//  CacheManager.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 24/10/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "CacheManager.h"
#import "SceneController.h"
#import "ResourceServer.h"

@implementation CacheManager

- (id)init {
	if (self = [super init]) {
		mArrayPool = nil;
		mDictPool = nil;
	}
	return self;
}

- (void)dealloc {
	[mArrayPool release]; mArrayPool = nil;
	[mDictPool release]; mDictPool = nil;
	[super dealloc];
}

- (void)fillResourcePoolForScene:(SceneController *)scene { }

- (void)drainResourcePool {
	[mArrayPool release]; mArrayPool = nil;
	[mDictPool release]; mDictPool = nil;
}

- (ResourceServer *)checkoutPoolResources {
	ResourceServer *resources = nil;
	
	if (mArrayPool && mArrayPool.count) {
		resources = (ResourceServer *)[[[mArrayPool lastObject] retain] autorelease];
		[mArrayPool removeLastObject];
	}
	
	return resources;
}

- (ResourceServer *)checkoutPoolResourcesForKey:(NSString *)key {
	if (mDictPool == nil || key == nil)
		return nil;
	ResourceServer *resources = nil;
	NSMutableArray *array = (NSMutableArray *)[mDictPool objectForKey:key];
	
	if (array.count) {
		resources = (ResourceServer *)[[[array lastObject] retain] autorelease];
		[array removeLastObject];
	}
	
	return resources;
}

- (void)checkinPoolResources:(ResourceServer *)resources {
	if (resources == nil)
		return;
    [resources reset];
    
	NSString *key = (NSString *)[resources miscResourceForKey:RESOURCE_KEY_CHAIN];
	
	if (key) {
		NSMutableArray *array = (NSMutableArray *)[mDictPool objectForKey:key];
		[array addObject:resources];
	} else {
		[mArrayPool addObject:resources];
	}
}

- (void)reassignResourceServersToScene:(SceneController *)scene {
    if (mDictPool) {
        for (NSString *key in mDictPool) {
            NSArray *poolArray = (NSArray *)[mDictPool objectForKey:key];
        
            for (ResourceServer *rs in poolArray)
                [rs reassignScene:scene];
        }
    }
    
    if (mArrayPool) {
        for (ResourceServer *rs in mArrayPool)
            [rs reassignScene:scene];
    }
}

@end
