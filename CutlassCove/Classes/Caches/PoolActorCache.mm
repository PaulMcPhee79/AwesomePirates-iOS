//
//  PoolActorCache.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 25/10/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "PoolActorCache.h"
#import "PoolActor.h"

@implementation PoolActorCache

- (void)fillResourcePoolForScene:(SceneController *)scene {
	if (mDictPool)
		return;
	mDictPool = [[NSMutableDictionary alloc] initWithCapacity:1];
	
    BOOL isLowPerformance = RESM.isLowPerformance;
    float spawnDuration = [PoolActor spawnDuration];
    float despawnDuration = [PoolActor despawnDuration];
    float spawnedAlpha = [PoolActor spawnedAlpha];
    float spawnedScale = [PoolActor spawnedScale];
    int numRipples = [PoolActor numPoolRipples];
    
	// Acid
	[mDictPool setObject:[NSMutableArray arrayWithCapacity:50] forKey:@"AcidPool"];
    [mDictPool setObject:[NSMutableArray arrayWithCapacity:25] forKey:@"MagmaPool"];
    
    NSArray *poolTextures = [NSArray arrayWithObjects:
                             [scene textureByName:@"pool-of-acid" atlasName:scene.sceneKey cacheGroup:TM_CACHE_VOODOO],
                             [scene textureByName:@"pool-of-magma" atlasName:scene.sceneKey cacheGroup:TM_CACHE_VOODOO],
                             nil];
    NSArray *keys = [NSArray arrayWithObjects:
                     @"AcidPool",
                     @"MagmaPool",
                     nil];
    NSDictionary *counts = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithInt:50], @"AcidPool",
                            [NSNumber numberWithInt:25], @"MagmaPool",
                            nil];
    int keyIndex = 0;
    
    for (NSString *key in keys) {
        SPTexture *poolTexture = (SPTexture *)[poolTextures objectAtIndex:keyIndex];
        NSMutableArray *poolArray = (NSMutableArray *)[mDictPool objectForKey:key];
        
        int count = [(NSNumber *)[counts objectForKey:key] intValue];
        
        for (int i = 0; i < count; ++i) {
            ResourceServer *resources = [ResourceServer resourceServer];
            NSMutableArray *ripples = [NSMutableArray arrayWithCapacity:numRipples];
            float delay = 0;
            
            // Ripples
            for (int j = 0; j < numRipples; ++j) {
                SPImage *image = [SPImage imageWithTexture:poolTexture];
                image.x = -image.width / 2;
                image.y = -image.height / 2;
                
                SPSprite *sprite = [SPSprite sprite];
                sprite.scaleX = sprite.scaleY = 0;
                sprite.alpha = 1;
                [sprite addChild:image];
                [ripples addObject:sprite];
                
                if (isLowPerformance) {
                    SPTween *tween = [SPTween tweenWithTarget:sprite time:2.4f];
                    [tween animateProperty:@"scaleX" targetValue:0.75f];
                    [tween animateProperty:@"scaleY" targetValue:0.75f];
                    [resources addTween:tween forKey:RESOURCE_KEY_POOL_RIPPLE_TWEEN_SCALE];
                } else {
                    SPTween *tween = [SPTween tweenWithTarget:sprite time:0.8f*numRipples];
                    [tween animateProperty:@"scaleX" targetValue:1.2f];
                    [tween animateProperty:@"scaleY" targetValue:1.2f];
                    tween.delay = delay;
                    tween.loop = SPLoopTypeRepeat;
                    [resources addTween:tween forKey:RESOURCE_KEY_POOL_RIPPLE_TWEEN_SCALE+j];
                    
                    tween = [SPTween tweenWithTarget:sprite time:0.8f*numRipples transition:SP_TRANSITION_EASE_IN_LINEAR];
                    [tween animateProperty:@"alpha" targetValue:0];
                    tween.delay = delay;
                    tween.loop = SPLoopTypeRepeat;
                    [resources addTween:tween forKey:RESOURCE_KEY_POOL_RIPPLE_TWEEN_ALPHA+j];
                    
                    delay += tween.time / numRipples;
                }
            }
            
            [resources addMiscResource:(NSObject *)ripples forKey:RESOURCE_KEY_POOL_RIPPLES];
            
            // Costume
            SPSprite *costume = [SPSprite sprite];
            [resources addDisplayObject:costume forKey:RESOURCE_KEY_POOL_COSTUME];
            
            SPTween *tween = [SPTween tweenWithTarget:costume time:spawnDuration];
            [tween animateProperty:@"alpha" targetValue:spawnedAlpha];
            [tween animateProperty:@"scaleX" targetValue:spawnedScale];
            [tween animateProperty:@"scaleY" targetValue:spawnedScale];
            [tween addEventListener:@selector(onTweenCompleted:) atObject:resources forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
            [resources addTween:tween forKey:RESOURCE_KEY_POOL_SPAWN_TWEEN];
            
            tween = [SPTween tweenWithTarget:costume time:despawnDuration];
            [tween animateProperty:@"alpha" targetValue:0.01f];
            [tween addEventListener:@selector(onTweenCompleted:) atObject:resources forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
            [resources addTween:tween forKey:RESOURCE_KEY_POOL_DESPAWN_TWEEN];
            
            [resources addMiscResource:key forKey:RESOURCE_KEY_CHAIN];
            [poolArray addObject:resources];
        }
        
        ++keyIndex;
    }
}

@end
