//
//  LootActor.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 8/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "LootActor.h"
#import "ActorDef.h"
#import "PlayerShip.h"
#import "Globals.h"

@interface LootActor ()

- (void)expireOverTime:(float)duration;

@end

@implementation LootActor

@synthesize doubloons = mDoubloons;
@synthesize infamyBonus = mInfamyBonus;

- (id)initWithActorDef:(ActorDef *)def category:(int)category duration:(float)duration {
	if (self = [super initWithActorDef:def]) {
        mCategory = category;
        mAdvanceable = YES;
		mLooted = NO;
		mDoubloons = 0;
		mInfamyBonus = 0;
		self.x = self.px;
		self.y = self.py;
        mDuration = (double)duration;
    }
    return self;
}

- (id)initWithActorDef:(ActorDef *)def {
	return [self initWithActorDef:def category:CAT_PF_PICKUPS duration:20];
}

- (id)init {
	return [self initWithActorDef:nil];
}

- (void)setupActorCostume {

}

- (void)respondToPhysicalInputs {
    if (self.isPreparingForNewGame)
        return;
	for (Actor *actor in mContacts) {
		if ([actor isKindOfClass:[PlayerShip class]]) {
			[self loot:(PlayerShip *)actor];
			break;
		}
	}
}

- (void)advanceTime:(double)time {
    if (mDuration > 0.0) {
        mDuration -= time;
        
        if (mDuration <= 0.0 && mPreparingForNewGame == NO)
            [self expireOverTime:10];
    }
}

- (void)expireOverTime:(float)duration {
	if (mLooted)
		return;
	[mScene.juggler removeTweensWithTarget:self]; // Remove delayed invocation
	
	SPTween *tween = [SPTween tweenWithTarget:self time:duration transition:SP_TRANSITION_LINEAR];
	[tween animateProperty:@"alpha" targetValue:0.0f];
	[tween addEventListener:@selector(onExpired:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
	[mScene.juggler addObject:tween];
}

- (void)playLootSound {
	//[mScene.audioPlayer playSoundWithKey:@"Booty"];
}

- (void)loot:(PlayerShip *)ship {
	if (mLooted)
		return;
	mLooted = YES;
	[mScene.juggler removeTweensWithTarget:self]; // Remove delayed invocation
	[self playLootSound];
	
	[mScene.spriteLayerManager removeChild:self withCategory:mCategory]; // Scene retains us
	mCategory = CAT_PF_HUD;
	[mScene.spriteLayerManager addChild:self withCategory:mCategory];
	self.alpha = 1.0f;
	
	SPTween *tween = [SPTween tweenWithTarget:self time:1.0f transition:SP_TRANSITION_LINEAR];
	[tween animateProperty:@"alpha" targetValue:0.0f];
	[tween animateProperty:@"scaleX" targetValue:3.0f];
	[tween animateProperty:@"scaleY" targetValue:3.0f];
	[tween addEventListener:@selector(onLooted:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
	[mScene.juggler addObject:tween];
}

- (void)onExpired:(SPEvent *)event {
	[mScene removeActor:self];
}

- (void)onLooted:(SPEvent *)event {
	[mScene removeActor:self];
}

- (void)prepareForNewGame {
    if (mPreparingForNewGame)
        return;
    mPreparingForNewGame = YES;
    [self expireOverTime:mNewGamePreparationDuration];
}

@end
