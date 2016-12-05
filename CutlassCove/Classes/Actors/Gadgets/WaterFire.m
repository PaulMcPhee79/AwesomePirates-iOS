//
//  WaterFire.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 23/10/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "WaterFire.h"

@interface WaterFire ()

- (void)setupPropWithCoords:(int *)flameCoords numFlames:(int)numFlames;
- (void)onFlamesExtinguished:(SPEvent *)event;

@end


@implementation WaterFire

@synthesize ignited = mIgnited;

- (id)initWithCategory:(int)category flameCoords:(int *)flameCoords numFlames:(int)numFlames {
	if (self = [super initWithCategory:category]) {
		mIgnited = NO;
        mExtinguishing = NO;
		mCanvas = nil;
		mFlames = [[NSMutableArray alloc] initWithCapacity:numFlames];
		[self setupPropWithCoords:flameCoords numFlames:numFlames];
	}
	return self;
}

- (void)setupPropWithCoords:(int *)flameCoords numFlames:(int)numFlames {
	if (mCanvas)
		return;
	
	NSArray *frames = [mScene texturesStartingWith:@"brandy-flame_"];
	mCanvas = [[SPSprite alloc] init];
	
	for (int i = 0; i < numFlames; ++i) {
		SPMovieClip *clip = [[SPMovieClip alloc] initWithFrames:frames fps:12];
		clip.x = flameCoords[2*i];
		clip.y = flameCoords[2*i+1];
		[clip pause];
		[mCanvas addChild:clip];
		[mFlames addObject:clip];
		[mScene.juggler addObject:clip];
		[clip release];
	}
	
	SPImage *edgePeg = [SPImage imageWithTexture:[mScene textureByName:@"clear-texture"]];
	[mCanvas addChild:edgePeg];
	
	mCanvas.visible = NO;
	mCanvas.x = -mCanvas.width / 2;
	mCanvas.y = -mCanvas.height / 2;
	[self addChild:mCanvas];
}

- (void)ignite {
	if (mIgnited || mExtinguishing)
		return;
	mIgnited = YES;
	mCanvas.visible = YES;
	
	for (SPMovieClip *clip in mFlames)
		[clip play];
	[mScene.audioPlayer playSoundWithKey:@"Fire"];
}

- (void)extinguishOverTime:(float)duration {
	[mScene.juggler removeTweensWithTarget:mCanvas];
	
	SPTween *tween = [SPTween tweenWithTarget:mCanvas time:duration];
	[tween animateProperty:@"alpha" targetValue:0];
	[tween addEventListener:@selector(onFlamesExtinguished:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
	[mScene.juggler addObject:tween];
    
    if (mIgnited == YES && mExtinguishing == NO)
        [mScene.audioPlayer stopSoundWithKey:@"Fire" easeOutDuration:duration];
    mExtinguishing = YES;
}

- (void)onFlamesExtinguished:(SPEvent *)event {
	mCanvas.visible = NO;
	
	for (SPMovieClip *clip in mFlames)
		[clip pause];
}

- (void)dealloc {
	if (mIgnited == YES && mExtinguishing == NO)
		[mScene.audioPlayer stopEaseOutSoundWithKey:@"Fire"];
	for (SPMovieClip *clip in mFlames)
		[mScene.juggler removeObject:clip];
	[mScene.juggler removeTweensWithTarget:mCanvas];
	[mCanvas release]; mCanvas = nil;
	[mFlames release]; mFlames = nil;
	[super dealloc];
}

@end
