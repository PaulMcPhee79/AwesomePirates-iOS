//
//  LootPropCache.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 24/10/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "LootPropCache.h"
#import "LootProp.h"
#import "SceneController.h"

@implementation LootPropCache

- (void)fillResourcePoolForScene:(SceneController *)scene {
	if (mDictPool)
		return;
	mDictPool = [[NSMutableDictionary alloc] initWithCapacity:3];
	
	SPTexture *prisonerTexture = [scene textureByName:@"pirate-hat" atlasName:scene.sceneKey cacheGroup:TM_CACHE_LOOT_PROPS];
	
    float lootAnimationDuration = [LootProp lootAnimationDuration];
    float tweenAlphaTo = 0;
    float tweenScaleTo = 1.25f;
    
	NSArray *keys = [NSArray arrayWithObjects:@"Prisoner",nil];
	NSArray *textures = [NSArray arrayWithObjects:prisonerTexture,nil];
	NSArray *counts = [NSArray arrayWithObjects:
					   [NSNumber numberWithInt:15],
					   nil];
	assert(keys.count == textures.count && keys.count == counts.count);
	
	for (int i = 0; i < keys.count; ++i) {
		int count = [(NSNumber *)[counts objectAtIndex:i] intValue];
		NSMutableArray *poolArray = [NSMutableArray arrayWithCapacity:count];
		NSString *key = (NSString *)[keys objectAtIndex:i];
		SPTexture *texture = (SPTexture *)[textures objectAtIndex:i];
		
		for (int j = 0; j < count; ++j) {
            ResourceServer *resources = [ResourceServer resourceServer];
            
			SPImage *costume = [SPImage imageWithTexture:texture];
			costume.x = -costume.width / 2;
			costume.y = -costume.height / 2;
            [resources addDisplayObject:costume forKey:RESOURCE_KEY_LP_COSTUME];
            
            SPSprite *wardrobe = [SPSprite sprite];
            [resources addDisplayObject:wardrobe forKey:RESOURCE_KEY_LP_WARDROBE];
            
            SPTween *tween = [SPTween tweenWithTarget:wardrobe time:lootAnimationDuration * 0.9f transition:SP_TRANSITION_EASE_IN];
            [tween animateProperty:@"alpha" targetValue:tweenAlphaTo];
            [resources addTween:tween forKey:RESOURCE_KEY_LP_ALPHA_TWEEN];
            
            tween = [SPTween tweenWithTarget:wardrobe time:lootAnimationDuration transition:SP_TRANSITION_LINEAR];
            [tween animateProperty:@"scaleX" targetValue:tweenScaleTo];
            [tween animateProperty:@"scaleY" targetValue:tweenScaleTo];
            [tween addEventListener:@selector(onTweenCompleted:) atObject:resources forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
            [resources addTween:tween forKey:RESOURCE_KEY_LP_SCALE_TWEEN];

            [resources addMiscResource:key forKey:RESOURCE_KEY_CHAIN];
            [poolArray addObject:resources];
		}
		
		[mDictPool setObject:poolArray forKey:key];
	}
}

@end
