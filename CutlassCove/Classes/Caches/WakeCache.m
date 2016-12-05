//
//  WakeCache.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 24/10/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "WakeCache.h"
#import "Wake.h"
#import "SceneController.h"

@implementation WakeCache

- (void)fillResourcePoolForScene:(SceneController *)scene {
	if (mArrayPool)
		return;
    int wakeCount = 50;
	mArrayPool = [[NSMutableArray alloc] initWithCapacity:wakeCount];
    mWakeIndexer = [[PoolIndexer alloc] initWithCapacity:wakeCount tag:@"WakeCache"];
    [mWakeIndexer setupIndexes:0 increment:1];
	
	SPTexture *rippleTexture = [scene textureByName:@"wake" atlasName:scene.sceneKey cacheGroup:TM_CACHE_SHIP_WAKES];
	float widthCache = rippleTexture.width, heightCache = rippleTexture.height;
	
	for (int i = 0; i < wakeCount; ++i) {
        NSMutableArray *wake = [NSMutableArray arrayWithCapacity:[Wake defaultWakeBufferSize]];
        [mArrayPool addObject:wake];
        
        for (int j = 0; j < [Wake defaultWakeBufferSize]; ++j) {
            SPSprite *rippleSprite = [[SPSprite alloc] init];
            rippleSprite.visible = NO;
            
            SPImage *rippleImage = [[SPImage alloc] initWithTexture:rippleTexture];
            rippleImage.x = -widthCache/2;
            rippleImage.y = -heightCache/2;
            [rippleSprite addChild:rippleImage];
            [wake addObject:rippleSprite];
            
            [rippleImage release]; rippleImage = nil;
            [rippleSprite release]; rippleSprite = nil;
        }
	}
}

- (void)drainResourcePool {
	NSLog(@"WAKE CACHE SIZE: %u", mArrayPool.count);
	[super drainResourcePool];
}

- (NSArray *)checkoutRipples:(int)count index:(int *)index {
    if (!mArrayPool || count != [Wake defaultWakeBufferSize])
    {
        *index = -1;
        return  nil;
    }
    else if ((*index = [mWakeIndexer checkoutNextIndex]) == -1)
        return nil;
    
    NSArray *ripples = [mArrayPool objectAtIndex:*index];
    return ripples;
}

- (void)checkinRipples:(NSArray *)ripples index:(int)index {
    if (mWakeIndexer && ripples)
        [mWakeIndexer checkinIndex:index];
}

- (void)reassignResourceServersToScene:(SceneController *)scene {
    // Do nothing - we don't use ResourceServers
}

- (void)dealloc {
    [mWakeIndexer release]; mWakeIndexer = nil;
    [super dealloc];
}

@end
