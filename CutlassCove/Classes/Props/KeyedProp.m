//
//  KeyedProp.m
//  Cutlass Cove
//
//  Created by Paul McPhee on 22/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "KeyedProp.h"

@implementation KeyedProp

@dynamic allChildKeys;

- (id)initWithCategory:(int)category {
    if (self = [super initWithCategory:category]) {
        mChildDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc {
    for (NSString *key in mChildDictionary) {
        SPDisplayObject *child = (SPDisplayObject *)[mChildDictionary objectForKey:key];
        [mScene.juggler removeTweensWithTarget:child];
    }
    
    [mChildDictionary release]; mChildDictionary = nil;
    [super dealloc];
}

- (NSArray *)allChildKeys {
    return mChildDictionary.allKeys;
}

- (SPDisplayObject *)childForKey:(NSString *)key {
    return [mChildDictionary objectForKey:key];
}

- (void)addChild:(SPDisplayObject *)child forKey:(NSString *)key {
    SPDisplayObject *oldChild = (SPDisplayObject *)[mChildDictionary objectForKey:key];
    
    if (oldChild == child)
        return;
    
    if (oldChild) {
        [[oldChild retain] autorelease];
        [mScene.juggler removeTweensWithTarget:oldChild];
        [mChildDictionary removeObjectForKey:key];
    }
    
    [mChildDictionary setObject:child forKey:key];
    [super addChild:child];
}

- (void)removeChild:(SPDisplayObject *)child forKey:(NSString *)key {
    [[child retain] autorelease];
    [mChildDictionary removeObjectForKey:key];
    [super removeChild:child];
}

@end
