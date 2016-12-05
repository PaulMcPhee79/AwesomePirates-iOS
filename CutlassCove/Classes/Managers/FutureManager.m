//
//  FutureManager.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 21/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FutureManager.h"
#import "Globals.h"

const float kElectricityDuration = 1.0f;
const float kFlamePathDuration = 5.0f;
const float kExtinguishDuration = 2.0f;
const int kFlamePathLength = 10;

@interface FutureManager ()

- (void)sparkElectricity;
- (void)hideElectricity;
- (void)orientElectricCharge:(float)scaleX scaleY:(float)scaleY;
- (void)playElectricitySound;
- (void)playFlamePathSound;
- (void)stopFlamePathSound;
- (void)onFlamePathExtinguishing:(SPEvent *)event;
- (void)onFlamePathExtinguished:(SPEvent *)event;

@end


@implementation FutureManager

@dynamic electricityDuration,flamePathDuration,flamePathExtinguishDuration;

- (id)init {
    if (self = [super initWithCategory:-1]) {
        mSparkTarget = nil;
		mFlamePathsClips = [[NSMutableArray	alloc] initWithCapacity:kFlamePathLength * 2];
		[self setupProp];
    }
    return self;
}

- (void)setupProp {
	// Electricity
	mElectricityProp = [[Prop alloc] initWithCategory:CAT_PF_EXPLOSIONS];
	SPImage *image = [[SPImage alloc] initWithTexture:[mScene textureByName:@"energy-ball"]];
	image.x = -image.width / 2;
	image.y = -image.height / 2;
	[mElectricityProp addChild:image];
	[image release];
	
	// Flame Paths
	mFlamePathsProp = [[Prop alloc] initWithCategory:CAT_PF_WAVES];

	SPMovieClip *baseClip = [[SPMovieClip alloc] initWithFrames:[mScene texturesStartingWith:@"brandy-flame_"] fps:8];
	float yOffset = -baseClip.height;
	baseClip.x = -baseClip.width - 5.0f;
	baseClip.y = yOffset;
	[mScene.juggler addObject:baseClip];
	[mFlamePathsClips addObject:baseClip];
	[mFlamePathsProp addChild:baseClip];
	
	for (int i = 1; i < kFlamePathLength * 2; ++i) {
		SPMovieClip *clip = [[SPMovieClip alloc] initWithFrame:[baseClip frameAtIndex:0] fps:8];
		clip.x = (i & 1) ? 5.0f : -clip.width - 5.0f;
		clip.y = yOffset;
		
		for (int j = 1; j < baseClip.numFrames; ++j)
			[clip addFrame:[baseClip frameAtIndex:j]];
		[mScene.juggler addObject:clip];
		[mFlamePathsClips addObject:clip];
		[mFlamePathsProp addChild:clip atIndex:0];
		[clip release];
		
		if (i & 1)
			yOffset -= 8.0f;
	}
	[baseClip release];
}

- (float)electricityDuration {
	return kElectricityDuration;
}

- (float)flamePathDuration {
	return kFlamePathDuration;
}

- (float)flamePathExtinguishDuration {
	return kExtinguishDuration;
}

- (void)sparkElectricity {
	mElectricityProp.scaleX = 1.0f;
	mElectricityProp.scaleY = 1.0f;
	mElectricityProp.scaleX = 1.0f;
	mElectricityProp.scaleY = 1.0f;
	[[mScene.juggler delayInvocationAtTarget:self byTime:0.25f] orientElectricCharge:-1.0f scaleY:1.0f];
	[[mScene.juggler delayInvocationAtTarget:self byTime:0.5f] orientElectricCharge:-1.0f scaleY:-1.0f];
	[[mScene.juggler delayInvocationAtTarget:self byTime:0.75f] orientElectricCharge:1.0f scaleY:-1.0f];
	[self playElectricitySound];
}

- (void)sparkElectricityAtX:(float)x y:(float)y {
	mElectricityProp.x = x;
	mElectricityProp.y = y;
	[self sparkElectricity];
	[mScene addProp:mElectricityProp];
    [[mScene.juggler delayInvocationAtTarget:self byTime:kElectricityDuration] hideElectricity];
}

- (void)sparkElectricityOnSprite:(SPSprite *)sprite {
    if (mSparkTarget || sprite == nil)
        return;
    mSparkTarget = [sprite retain];
	mElectricityProp.x = 0.0f;
	mElectricityProp.y = 0.0f;
	[self sparkElectricity];
	[sprite addChild:mElectricityProp];
	[[mScene.juggler delayInvocationAtTarget:self byTime:kElectricityDuration] hideElectricity];
}

- (void)hideElectricity {
    if (mElectricityProp) {
        [mSparkTarget removeChild:mElectricityProp];
        [mScene removeProp:mElectricityProp];
        [mSparkTarget release]; mSparkTarget = nil;
    }
}

- (void)igniteFlamePathsAtSprite:(SPSprite *)sprite {
	int i = 0;
	float delay = 0.0f;
	
	for (SPMovieClip *clip in mFlamePathsClips) {
		clip.alpha = 0.0f;
		
		SPTween *tween = [SPTween tweenWithTarget:clip time:0.05f];
		[tween animateProperty:@"alpha" targetValue:1.0f];
		tween.delay = delay;
		[mScene.juggler addObject:tween];
		
		if (i & 1)
			delay += tween.time;
		++i;
	}
	
	mFlamePathsProp.x = sprite.x;
	mFlamePathsProp.y = sprite.y;
	mFlamePathsProp.rotation = sprite.rotation;
	[mScene addProp:mFlamePathsProp];
	[self playFlamePathSound];
	
	SPTween *tween = [SPTween tweenWithTarget:mFlamePathsProp time:kExtinguishDuration];
	[tween animateProperty:@"alpha" targetValue:0.0f];
	tween.delay = kFlamePathDuration;
    [tween addEventListener:@selector(onFlamePathExtinguishing:) atObject:self forType:SP_EVENT_TYPE_TWEEN_STARTED];
	[tween addEventListener:@selector(onFlamePathExtinguished:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
	[mScene.juggler addObject:tween];
}

- (void)onFlamePathExtinguishing:(SPEvent *)event {
    [self stopFlamePathSound];
}

- (void)onFlamePathExtinguished:(SPEvent *)event {
	[mScene removeProp:mFlamePathsProp];
}

- (void)orientElectricCharge:(float)scaleX scaleY:(float)scaleY {
	mElectricityProp.scaleX = scaleX;
	mElectricityProp.scaleY = scaleY;
}

- (void)playElectricitySound {
	[mScene.audioPlayer playSoundWithKey:@"Electricity"];
}

- (void)playFlamePathSound {
	[mScene.audioPlayer playSoundWithKey:@"Fire" volume:1.0f easeInDuration:0.5f];
}

- (void)stopFlamePathSound {
	[mScene.audioPlayer stopSoundWithKey:@"Fire" easeOutDuration:kExtinguishDuration];
}

- (void)destroy {
    [[self retain] autorelease];
    [mScene.juggler removeTweensWithTarget:self];
    [mScene.juggler removeTweensWithTarget:mFlamePathsProp];
    [self hideElectricity];
}

- (void)dealloc {
    [self stopFlamePathSound];
    
	for (SPMovieClip *clip in mFlamePathsClips) {
		[mScene.juggler removeTweensWithTarget:clip];
		[mScene.juggler removeObject:clip];
	}
    
    [mScene.juggler removeTweensWithTarget:mFlamePathsProp];
	[mScene removeProp:mFlamePathsProp];
    [self hideElectricity];
    
    [mSparkTarget release]; mSparkTarget = nil;
    [mElectricityProp release]; mElectricityProp = nil;
	[mFlamePathsProp release]; mFlamePathsProp = nil;
	[mFlamePathsClips release]; mFlamePathsClips = nil;
	[super dealloc];
}

@end
