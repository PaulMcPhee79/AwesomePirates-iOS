//
//  LootProp.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 28/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"
#import "LootPropCache.h"
#import "ResourceClient.h"

@interface LootProp : Prop <ResourceClient> {
	BOOL mLooted;
    
	float mAlphaFrom;
	float mAlphaTo;
	float mScaleFrom;
	float mScaleTo;
	double mDuration;
	
	SPImage *mCostume;
    SPSprite *mWardrobe;
	NSString *mLootSfxKey;
	NSString *mResourceKey;
	ResourceServer *mResources;
}

- (id)initWithCategory:(int)category resourceKey:(NSString *)resourceKey;
- (void)positionAtX:(float)x y:(float)y;
- (void)loot;
- (void)playLootSound;
- (void)destroyLoot;

+ (float)lootAnimationDuration;

@end
