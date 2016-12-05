//
//  TempestCache.m
//  CutlassCove
//
//  Created by Paul McPhee on 4/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TempestCache.h"
#import "TempestActor.h"
#import "SceneController.h"


@implementation TempestCache

- (void)fillResourcePoolForScene:(SceneController *)scene {
	if (mArrayPool)
		return;
	
	mArrayPool = [[NSMutableArray alloc] initWithCapacity:1];
    
    int debrisBufferSize = [TempestActor debrisBufferSize];
    SPTexture *debrisTexture = [scene textureByName:@"tempest-debris"];
    
    for (int i = 0; i < 4; ++i) {
        ResourceServer *resources = [ResourceServer resourceServer];
        NSMutableArray *debris = [NSMutableArray arrayWithCapacity:debrisBufferSize];
        
        for (int j = 0; j < debrisBufferSize; ++j) {
            SPSprite *sprite = [SPSprite sprite];
            SPImage *image = [SPImage imageWithTexture:debrisTexture];
            image.x = -image.width / 2;
            image.y = -image.height / 2;
            sprite.x = image.width / 2;
            sprite.y = image.height / 2;
            [sprite addChild:image];
            [debris addObject:sprite];
            
            SPTween *fadeIn = [SPTween tweenWithTarget:sprite time:1.0f];
            [fadeIn animateProperty:@"alpha" targetValue:1];
            [resources addTween:fadeIn forKey:RESOURCE_KEY_TEMPEST_DEBRIS_TWEEN_IN+j];
            
            SPTween *fadeOut = [SPTween tweenWithTarget:sprite time:1.0f];
            [fadeOut animateProperty:@"alpha" targetValue:0];
            fadeOut.delay = fadeIn.time;
            [fadeOut addEventListener:@selector(onTweenCompleted:) atObject:resources forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
            [resources addTween:fadeOut forKey:RESOURCE_KEY_TEMPEST_DEBRIS_TWEEN_OUT+j];
        }
        
        [resources addMiscResource:(NSObject *)[NSArray arrayWithArray:debris] forKey:RESOURCE_KEY_TEMPEST_DEBRIS];
        [mArrayPool addObject:resources];
    }
}

@end
