//
//  SpriteLayerManager.m
//  Pirates
//
//  Created by Paul McPhee on 3/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "SpriteLayerManager.h"

@implementation SpriteLayerManager

- (id)initWithBaseDisplay:(SPDisplayObjectContainer *)base layerCount:(uint)count {
	if (self = [super init]) {
		mBase = [base retain];
		count = MAX(1,count);
		
		for (uint i = 0; i < count; ++i) {
			SPSprite *sprite = [[SPSprite alloc] init];
			[mBase addChild:sprite];
			[sprite release];
		}
	}
	return self;
}

- (id)init {
	return [self initWithBaseDisplay:[[[SPSprite alloc] init] autorelease] layerCount:1];
}

- (void)addChild:(SPDisplayObject *)child withCategory:(int)category {
	if (category < mBase.numChildren)
		[(SPSprite *)[mBase childAtIndex:category] addChild:child];
}

- (void)removeChild:(SPDisplayObject *)child withCategory:(int)category {
	if (category < mBase.numChildren)
		[(SPSprite *)[mBase childAtIndex:category] removeChild:child];
}

- (SPDisplayObject *)childAtCategory:(int)category {
	SPDisplayObject *child = nil;
	
	if (category < mBase.numChildren)
		child = [mBase childAtIndex:category];
	return child;
}

- (void)setTouchableLayers:(int *)layers count:(int)count {
    int numChildren = mBase.numChildren;
    
    for (int i = 0; i < numChildren; ++i) {
		SPSprite *layer = (SPSprite *)[mBase childAtIndex:i];
        layer.touchable = NO;
    }

    for (int i = 0; i < count; ++i) {
        int childIndex = layers[i];
        
        if (childIndex < numChildren) {
            SPSprite *sprite = (SPSprite *)[mBase childAtIndex:childIndex];
            sprite.touchable = YES;
        }
    }
    
}

- (void)clearAllLayers {
	for (int i = 0; i < mBase.numChildren; ++i) {
		SPSprite *layer = (SPSprite *)[mBase childAtIndex:i];
		[layer removeAllChildren];
	}
}

- (void)clearAll {
	[mBase removeAllChildren];
}

- (void)flipChild:(BOOL)enable withCategory:(int)category width:(float)width {
    if (category < mBase.numChildren) {
        SPSprite *child = (SPSprite *)[mBase childAtIndex:category];
        
        if (enable) {
            child.scaleX = -1;
            child.x = width;
        } else {
            child.scaleX = 1;
            child.x = 0;
        }
    }
}

- (void)dealloc {
	[mBase release]; mBase = nil;
	[super dealloc];
	
	NSLog(@"SpriteLayerManager dealloc'ed");
}

@end
