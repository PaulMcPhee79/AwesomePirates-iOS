//
//  NpcShipCache.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 24/10/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "NpcShipCache.h"
#import "ShipDetails.h"
#import "ShipFactory.h"
#import "SceneController.h"

const float kDefaultNpcShipClipFps = 8.0f;

@implementation NpcShipCache

- (void)fillResourcePoolForScene:(SceneController *)scene {
	if (mArrayPool)
		return;
	
	mArrayPool = [[NSMutableArray alloc] initWithCapacity:2];
    
    // Generic (these are common to all ships, so we need to store a lot of them)
	NSMutableArray *genericArray = [NSMutableArray arrayWithCapacity:30];
	[mArrayPool addObject:genericArray];
	
	NSArray *sinkingTextures = [scene texturesStartingWith:@"ship-sinking_" atlasName:scene.sceneKey cacheGroup:TM_CACHE_PF_SHIPS];
	NSArray *burningTextures = [scene texturesStartingWith:@"ship-burn_" atlasName:scene.sceneKey cacheGroup:TM_CACHE_PF_SHIPS];

    SPMovieClip *sinkingClip = nil, *burningClip = nil;
    
	// MovieClip Pools
	for (int i = 0; i < 30; ++i) {
		sinkingClip = [SPMovieClip movieWithFrames:sinkingTextures fps:kDefaultNpcShipClipFps];
		burningClip = [SPMovieClip movieWithFrames:burningTextures fps:kDefaultNpcShipClipFps];
		[genericArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								 sinkingClip,@"Sinking",
								 burningClip,@"Burning",
								 nil]];
	}
    
    // Custom
	NSDictionary *npcShipDetailDict = [ShipFactory shipYard].allNpcShipDetails;
	NSMutableDictionary *customDictionary = [NSMutableDictionary dictionaryWithCapacity:npcShipDetailDict.count];
	[mArrayPool addObject:customDictionary];
	
	for (NSString *key in npcShipDetailDict) {
		NSDictionary *details = (NSDictionary *)[npcShipDetailDict objectForKey:key];
		ShipDetails *npcShipDetails = [[ShipFactory shipYard] createNpcShipDetailsForType:key];
		NSString *textureName = (NSString *)[details objectForKey:@"textureName"];
		NSArray *costumeTextures = [scene texturesStartingWith:textureName atlasName:scene.sceneKey cacheGroup:TM_CACHE_PF_SHIPS];
        
        uint cacheSize = [(NSNumber *)[details objectForKey:@"cacheSize"] unsignedIntValue];
        
        if (cacheSize == 0)
            continue;
        
		NSMutableArray *customArray = [NSMutableArray arrayWithCapacity:cacheSize];
		
		// Custom caches
		for (int i = 0; i < cacheSize; ++i) {
            ResourceServer *resources = [ResourceServer resourceServer];
			int costumeIndex = NUM_NPC_COSTUME_IMAGES / 2;
			NSMutableArray *images = [NSMutableArray arrayWithCapacity:NUM_NPC_COSTUME_IMAGES];
			
            // Costume
			for (int j = 0, frameIndex = costumeIndex, frameIncrement = -1; j < NUM_NPC_COSTUME_IMAGES; ++j) {
				SPImage *image = [SPImage imageWithTexture:[costumeTextures objectAtIndex:frameIndex]];
				image.scaleX = (j < costumeIndex) ? -1 : 1;
				image.x = -12 * image.scaleX;
				image.y = -npcShipDetails.rudderOffset;
				image.visible = (j == costumeIndex);
				[images addObject:image];
				
				if (frameIndex == 0)
					frameIncrement = 1;
				frameIndex += frameIncrement;
			}
			
            [resources addMiscResource:(NSObject *)images forKey:RESOURCE_KEY_NPC_COSTUME];
            
            // Wardrobe
            SPSprite *wardrobe = [SPSprite sprite];
            [resources addDisplayObject:wardrobe forKey:RESOURCE_KEY_NPC_WARDROBE];
            
            // Tweens
            SPTween *tween = [SPTween tweenWithTarget:wardrobe time:0.5f transition:SP_TRANSITION_LINEAR];
            [tween animateProperty:@"alpha" targetValue:0.0f];
            [tween addEventListener:@selector(onTweenCompleted:) atObject:resources forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
            [resources addTween:tween forKey:RESOURCE_KEY_NPC_DOCK_TWEEN];
            
            tween = [SPTween tweenWithTarget:wardrobe time:burningClip.duration / 2 transition:SP_TRANSITION_EASE_OUT];
            [tween animateProperty:@"alpha" targetValue:1];
            [tween addEventListener:@selector(onTweenCompleted:) atObject:resources forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
            [resources addTween:tween forKey:RESOURCE_KEY_NPC_BURN_IN_TWEEN];
            
            tween = [SPTween tweenWithTarget:wardrobe time:burningClip.duration / 2 transition:SP_TRANSITION_LINEAR];
            [tween animateProperty:@"alpha" targetValue:0];
            [resources addTween:tween forKey:RESOURCE_KEY_NPC_BURN_OUT_TWEEN];
            
            tween = [SPTween tweenWithTarget:wardrobe time:1 transition:SP_TRANSITION_LINEAR];
            [tween animateProperty:@"scaleX" targetValue:0.01f];
            [tween animateProperty:@"scaleY" targetValue:0.01f];
            [resources addTween:tween forKey:RESOURCE_KEY_NPC_SHRINK_TWEEN];
            
            [resources addMiscResource:key forKey:RESOURCE_KEY_CHAIN];
			[customArray addObject:resources];
		}
		
		[customDictionary setObject:customArray forKey:key];
		
		// For 88MPH achievement mode - just cache the texture with TextureManager
		textureName = (NSString *)[details objectForKey:@"textureFutureName"];
		
		if (textureName)
			[scene texturesStartingWith:textureName atlasName:scene.sceneKey cacheGroup:TM_CACHE_PF_SHIPS];
	}
}

- (ResourceServer *)checkoutPoolResourcesForKey:(NSString *)key {
	if (mArrayPool == nil || key == nil)
		return nil;
	ResourceServer *resources = nil;
    
    NSMutableArray *genericArray = (NSMutableArray *)[mArrayPool objectAtIndex:0];
    NSMutableDictionary *customDict = (NSMutableDictionary *)[mArrayPool objectAtIndex:1];
	NSMutableArray *customArray = (NSMutableArray *)[customDict objectForKey:key];
	
	if (customArray.count && genericArray.count) {
		resources = (ResourceServer *)[[[customArray lastObject] retain] autorelease];
		[customArray removeLastObject];
        
        // Custom
        NSArray *costumeImages = (NSArray *)[resources miscResourceForKey:RESOURCE_KEY_NPC_COSTUME];
        
        for (SPImage *image in costumeImages)
            image.visible = NO;
        
        // Generic
        NSDictionary *genericMovies = (NSDictionary *)[genericArray lastObject];
        [resources addMiscResource:(NSObject *)genericMovies forKey:RESOURCE_KEY_NPC_GENERICS];
        [genericArray removeLastObject];
        
        SPMovieClip *sinkingClip = (SPMovieClip *)[genericMovies objectForKey:@"Sinking"];
        [resources addMovie:sinkingClip forKey:RESOURCE_KEY_NPC_SINKING];
        
        SPMovieClip *burningClip = (SPMovieClip *)[genericMovies objectForKey:@"Burning"];
        [resources addMovie:burningClip forKey:RESOURCE_KEY_NPC_BURNING];
	}
	
	return resources;
}

- (void)checkinPoolResources:(ResourceServer *)resources {
	if (resources == nil)
		return;
    [resources reset];
    
	NSString *key = (NSString *)[resources miscResourceForKey:RESOURCE_KEY_CHAIN];
	assert(key);
    
    NSMutableArray *genericArray = (NSMutableArray *)[mArrayPool objectAtIndex:0];
    NSMutableDictionary *customDict = (NSMutableDictionary *)[mArrayPool objectAtIndex:1];
    NSMutableArray *customArray = (NSMutableArray *)[customDict objectForKey:key];
    
    NSDictionary *genericMovies = (NSDictionary *)[resources removeMiscResourceForKey:RESOURCE_KEY_NPC_GENERICS];
    [genericArray addObject:genericMovies];
    
    [resources removeDisplayObjectForKey:RESOURCE_KEY_NPC_SINKING];
    [resources removeDisplayObjectForKey:RESOURCE_KEY_NPC_BURNING];
    
    [customArray addObject:resources];
}

- (void)reassignResourceServersToScene:(SceneController *)scene {
    NSDictionary *customDict = (NSMutableDictionary *)[mArrayPool objectAtIndex:1];
    
    for (NSString *key in customDict) {
        NSArray *customArray = (NSArray *)[customDict objectForKey:key];
        
        for (ResourceServer *rs in customArray)
            [rs reassignScene:scene];
    }
}

@end
