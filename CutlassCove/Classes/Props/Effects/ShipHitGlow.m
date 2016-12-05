//
//  ShipHitGlow.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 11/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "ShipHitGlow.h"
#import "GameController.h"
#import "Globals.h"

const float kGlowAlphaMin = 0.0f;
const float kGlowAlphaMax = 0.15; //   0.85f;
const float kGlowScale = 1.5f;

const float kGlowLongDuration = 0.175f;
const float kGlowShortDuration = 0.075f;

@interface ShipHitGlow ()

- (void)nextGlowCycle:(float)duration target:(float)target;
- (void)onTweenCompleted:(SPEvent *)event;

@end

@implementation ShipHitGlow

@dynamic isCompleted;

- (id)initWithX:(float)x y:(float)y {
	if (self = [super initWithCategory:CAT_PF_SHOREBREAK]) {
		self.x = x;
		self.y = y;
		[self setupProp];
	}
	return self;
}

- (void)setupProp {
	GameController *gc = GCTRL;
	
	float glowAlphaMax = 0.0f;
	float glowAlphaPulse = 0.0f;
	float proportionRemaining = gc.timeKeeper.proportionRemaining;
	
	switch (gc.timeOfDay) {
		case DawnTransition:
			glowAlphaMax = MAX(0.1f, 0.4f * proportionRemaining);
			glowAlphaPulse = MAX(0.1f, 0.25f * proportionRemaining);
			break;
		case Dawn:
			glowAlphaMax = 0.1f;
			glowAlphaPulse = 0.1f;
			break;
		case Dusk:
			glowAlphaMax = 0.1f;
			glowAlphaPulse = 0.1f;
			break;
		case EveningTransition:
			glowAlphaMax = MAX(0.1f, 0.4f * (1.0f - proportionRemaining));
			glowAlphaPulse = MAX(0.1f, 0.25f * (1.0f - proportionRemaining));
			break;
        case Evening:
		case Midnight:
			glowAlphaMax = 0.4f;
			glowAlphaPulse = 0.25f;
			break;
		default:
			glowAlphaMax = 0.0f;
			glowAlphaPulse = 0.075f;
			break;
	}
	
	mDuration[0] = kGlowLongDuration;
	mDuration[1] = kGlowShortDuration;
	mDuration[2] = kGlowShortDuration;
	mDuration[3] = kGlowLongDuration;
	mTargets[0] = kGlowAlphaMax + glowAlphaMax;
	mTargets[1] = kGlowAlphaMax + glowAlphaMax - glowAlphaPulse;
	mTargets[2] = kGlowAlphaMax + glowAlphaMax;
	mTargets[3] = kGlowAlphaMin;
	
	SPImage *glowImage = [SPImage imageWithTexture:[mScene textureByName:@"explosion-glow"]];
	glowImage.x = -glowImage.width / 2;
	glowImage.y = -glowImage.height / 2;
	[self addChild:glowImage];
	self.alpha = kGlowAlphaMin;
	self.scaleX = kGlowScale;
	self.scaleY = kGlowScale;
	mState = 0;
	[mScene addProp:self];
	[self nextGlowCycle:mDuration[mState] target:mTargets[mState]];
}

- (BOOL)isCompleted {
    return (mState >= 4);
}

- (void)nextGlowCycle:(float)duration target:(float)target {	
	SPTween *tween = [SPTween tweenWithTarget:self time:duration transition:SP_TRANSITION_LINEAR];
	[tween animateProperty:@"alpha" targetValue:target];
	[tween addEventListener:@selector(onTweenCompleted:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
	[mScene.juggler addObject:tween];
}

- (void)rerun {
    if (self.isCompleted == NO)
        return;
    mState = 0;
    self.visible = YES;
    [self nextGlowCycle:mDuration[mState] target:mTargets[mState]];
}

- (void)onTweenCompleted:(SPEvent *)event {
	if (++mState < 4) {
		[self nextGlowCycle:mDuration[mState] target:mTargets[mState]];
	} else {
		self.visible = NO;
	}
}

@end
