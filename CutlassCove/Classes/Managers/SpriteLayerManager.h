//
//  SpriteLayerManager.h
//  Pirates
//
//  Created by Paul McPhee on 3/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpriteLayerManager : NSObject {
	SPDisplayObjectContainer *mBase;
}

- (id)initWithBaseDisplay:(SPDisplayObjectContainer *)base layerCount:(uint)count;
- (void)addChild:(SPDisplayObject *)child withCategory:(int)category;
- (void)removeChild:(SPDisplayObject *)child withCategory:(int)category;
- (SPDisplayObject *)childAtCategory:(int)category;
- (void)setTouchableLayers:(int *)layers count:(int)count;
- (void)clearAllLayers;
- (void)clearAll;

- (void)flipChild:(BOOL)enable withCategory:(int)category width:(float)width;

@end
