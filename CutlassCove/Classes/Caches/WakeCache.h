//
//  WakeCache.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 24/10/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CacheManager.h"
#import "ResourceServer.h"
#import "PoolIndexer.h"

@interface WakeCache : CacheManager {
    PoolIndexer *mWakeIndexer;
}

- (NSArray *)checkoutRipples:(int)count index:(int *)index;
- (void)checkinRipples:(NSArray *)ripples index:(int)index;

@end
