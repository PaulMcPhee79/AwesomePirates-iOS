//
//  BlastCache.m
//  CutlassCove
//
//  Created by Paul McPhee on 28/04/12.
//  Copyright (c) 2012 Cheeky Mammoth. All rights reserved.
//

#import "BlastCache.h"
#import "BlastProp.h"
#import "SceneController.h"

@implementation BlastCache

- (void)fillResourcePoolForScene:(SceneController *)scene {
	if (mDictPool)
		return;
	mDictPool = [[NSMutableDictionary alloc] initWithCapacity:3];
	
	SPTexture *abyssalTexture = [scene textureByName:@"abyssal-surge" atlasName:scene.sceneKey cacheGroup:TM_CACHE_BLAST_PROPS];
	
    float blastAnimationDuration = [BlastProp blastAnimationDuration];
    float blastTweenAlphaTo = 1;
    
    float aftermathAnimationDuration = [BlastProp aftermathAnimationDuration];
    float aftermathTweenAlphaTo = 0;
    
	NSArray *keys = [NSArray arrayWithObjects:@"Abyssal",nil];
	NSArray *textures = [NSArray arrayWithObjects:abyssalTexture,nil];
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
            
            SPImage *blastImage = [SPImage imageWithTexture:texture];
            blastImage.x = -blastImage.width / 2;
            blastImage.y = -blastImage.height / 2;
            
            SPSprite *costume = [SPSprite sprite];
            [costume addChild:blastImage];
            [resources addDisplayObject:costume forKey:RESOURCE_KEY_BP_COSTUME];
            
            SPTween *blastTween = [SPTween tweenWithTarget:costume time:blastAnimationDuration];
            [blastTween animateProperty:@"alpha" targetValue:blastTweenAlphaTo];
            [blastTween addEventListener:@selector(onTweenCompleted:) atObject:resources forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
            [resources addTween:blastTween forKey:RESOURCE_KEY_BP_BLAST_TWEEN];
            
            SPTween *aftermathTween = [SPTween tweenWithTarget:costume time:aftermathAnimationDuration];
            [aftermathTween animateProperty:@"alpha" targetValue:aftermathTweenAlphaTo];
            aftermathTween.delay = blastTween.delay + blastTween.time;
            [aftermathTween addEventListener:@selector(onTweenCompleted:) atObject:resources forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
            [resources addTween:aftermathTween forKey:RESOURCE_KEY_BP_AFTERMATH_TWEEN];
            
            [resources addMiscResource:key forKey:RESOURCE_KEY_CHAIN];
            [poolArray addObject:resources];
		}
		
		[mDictPool setObject:poolArray forKey:key];
	}
}

@end
