//
//  SharkCache.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 24/10/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "SharkCache.h"
#import "SceneController.h"
#import "Shark.h"
#import "SharkWater.h"
#import "OverboardActor.h"
#import "ShipFactory.h"

@implementation SharkCache

- (void)fillResourcePoolForScene:(SceneController *)scene {
	if (mDictPool)
		return;
	mDictPool = [[NSMutableDictionary alloc] initWithCapacity:3];
	
	// Shark
	NSArray *swimFrames = [scene texturesStartingWith:@"shark_" atlasName:scene.sceneKey cacheGroup:TM_CACHE_SHARK];
	NSArray *attackFrames = [scene texturesStartingWith:@"shark-attack_" atlasName:scene.sceneKey cacheGroup:TM_CACHE_SHARK];
	
	NSString *key = @"Shark";
	NSMutableArray *poolArray = [NSMutableArray arrayWithCapacity:15];
	[mDictPool setObject:poolArray forKey:key];
	
	for (int i = 0; i < 15; ++i) {
        ResourceServer *resources = [ResourceServer resourceServer];
		SPMovieClip *swimClip = [SPMovieClip movieWithFrames:swimFrames fps:[Shark swimFps]];
		swimClip.loop = YES;
		swimClip.x = -swimClip.width / 2;
		swimClip.y = -swimClip.height / 2;
        [resources addMovie:swimClip forKey:RESOURCE_KEY_SHARK_SWIM];
		
		SPMovieClip *attackClip = [SPMovieClip movieWithFrames:attackFrames fps:[Shark attackFps]];
		attackClip.loop = NO;
		attackClip.x = -attackClip.width / 2;
		attackClip.y = -attackClip.height / 2;
        [attackClip addEventListener:@selector(onMovieCompleted:) atObject:resources forType:SP_EVENT_TYPE_MOVIE_COMPLETED];
        [resources addMovie:attackClip forKey:RESOURCE_KEY_SHARK_ATTACK];
		
		[resources addMiscResource:key forKey:RESOURCE_KEY_CHAIN];
		[poolArray addObject:resources];
	}
	
	// Shark Water
	SPTexture *waterRingTexture = [scene textureByName:@"shark-white-water" atlasName:scene.sceneKey cacheGroup:TM_CACHE_SHARK];
	
	key = @"SharkWater";
	poolArray = [NSMutableArray arrayWithCapacity:15];
	[mDictPool setObject:poolArray forKey:key];
	
	int numRipples = [SharkWater numRipples];
    float waterRingDuration = [SharkWater waterRingDuration];
	
	for (int i = 0; i < 15; ++i) {
        ResourceServer *resources = [ResourceServer resourceServer];
		NSMutableArray *ripples = [NSMutableArray arrayWithCapacity:numRipples];
		float delay = 0.0;
        
		for (int j = 0; j < numRipples; ++j) {
			SPSprite *sprite = [SPSprite sprite];
			SPImage *image = [SPImage imageWithTexture:waterRingTexture];
			image.x = -image.width / 2;
			image.y = -image.height / 2;
			sprite.scaleX = 0.01f;
			sprite.scaleY = 0.01f;
			[sprite addChild:image];
			[ripples addObject:sprite];
            
            SPTween *tween = [SPTween tweenWithTarget:sprite time:waterRingDuration transition:SP_TRANSITION_LINEAR];
            [tween animateProperty:@"alpha" targetValue:0.0f];
            [tween animateProperty:@"scaleX" targetValue:1.0f];
            [tween animateProperty:@"scaleY" targetValue:1.0f];
            tween.delay = delay;
            
            if (j == numRipples-1)
                [tween addEventListener:@selector(onTweenCompleted:) atObject:resources forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
            [resources addTween:tween forKey:RESOURCE_KEY_SHARK_RIPPLES_TWEEN+j];
            delay += 0.5;
		}
		
        [resources addMiscResource:(NSObject *)ripples forKey:RESOURCE_KEY_SHARK_RIPPLES];
        [resources addMiscResource:key forKey:RESOURCE_KEY_CHAIN];
		[poolArray addObject:resources];
	}

	
	// Person Overboard
	NSArray *overboardFrames = [scene texturesStartingWith:@"overboard_" atlasName:scene.sceneKey cacheGroup:TM_CACHE_SHARK];
	SPTexture *bloodTexture = [scene textureByName:@"blood" atlasName:scene.sceneKey cacheGroup:TM_CACHE_SHARK];
	
	key = @"Overboard";
	poolArray = [NSMutableArray arrayWithCapacity:35];
	[mDictPool setObject:poolArray forKey:key];
	
	for (int i = 0; i < 35; ++i) {
        ResourceServer *resources = [ResourceServer resourceServer];
        
        // Person
		SPMovieClip *personClip = [SPMovieClip movieWithFrames:overboardFrames fps:[OverboardActor fps]];
		personClip.x = -personClip.width / 2;
		personClip.y = -personClip.height / 2;
		personClip.loop = YES;
        [resources addMovie:personClip forKey:RESOURCE_KEY_SHARK_PERSON];
		
        SPTween *tween = [SPTween tweenWithTarget:personClip time:0.5f transition:SP_TRANSITION_LINEAR];
        [tween animateProperty:@"alpha" targetValue:0.0f];
        [tween animateProperty:@"scaleX" targetValue:0.7f];
        [tween animateProperty:@"scaleY" targetValue:0.7f];
        [tween addEventListener:@selector(onTweenCompleted:) atObject:resources forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
        [resources addTween:tween forKey:RESOURCE_KEY_SHARK_PERSON_TWEEN];
        
        // Blood
		SPImage *bloodImage = [SPImage imageWithTexture:bloodTexture];
		bloodImage.x = -bloodImage.width / 2;
		bloodImage.y = -bloodImage.height / 2;
		
		SPSprite *bloodSprite = [SPSprite sprite];
		[bloodSprite addChild:bloodImage];
        [resources addDisplayObject:bloodSprite forKey:RESOURCE_KEY_SHARK_BLOOD];
        
        tween = [SPTween tweenWithTarget:bloodSprite time:5.0f transition:SP_TRANSITION_LINEAR];
        [tween animateProperty:@"alpha" targetValue:0.0f];
        [tween animateProperty:@"scaleX" targetValue:2.0f];
        [tween animateProperty:@"scaleY" targetValue:2.0f];
        [tween addEventListener:@selector(onTweenCompleted:) atObject:resources forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
        [resources addTween:tween forKey:RESOURCE_KEY_SHARK_BLOOD_TWEEN];
        
        [resources addMiscResource:key forKey:RESOURCE_KEY_CHAIN];
		[poolArray addObject:resources];
	}
	
	// Cache plank textures in TextureManager
	NSDictionary *prisoners = [[ShipFactory shipYard] allPrisoners];
	
	for (NSString *prisonerName in prisoners) {
		NSDictionary *prisonerDetails = (NSDictionary *)[prisoners objectForKey:prisonerName];
		NSString *textureName = (NSString *)[prisonerDetails objectForKey:@"textureName"];
		[scene textureByName:textureName atlasName:scene.sceneKey cacheGroup:TM_CACHE_SHARK];
	}
}

@end
