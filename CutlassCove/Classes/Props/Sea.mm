//
//  Sea.m
//  Pirates
//
//  Created by Paul McPhee on 16/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "Sea.h"
#import "Wave.h"
#import "WhirlpoolActor.h"
#import "SPQuad_Extension.h"
#import "SHAnimatableColor.h"
#import "GameController.h"
#import "Globals.h"

typedef enum {
	SeaStateNormal = 0,
	SeaStateTransitionToWhirlpool,
	SeaStateWhirlpool,
	SeaStateTransitionFromWhirlpool
} SeaState;

typedef enum {
	LavaStateInactive = 0,
	LavaStateTransitionTo,
	LavaStateActive,
	LavaStateTransitionFrom
} LavaState;

const float kLavaWavesAlpha = 0.5f;
const float kWhirlpoolWavesAlpha = 0.5f;

const float kShoreBreakAlphaMin = 0.4f;
const float kShoreBreakAlphaMax = 0.65f;
const float kShoreBreakAlphaMid = 0.525f;
const float kShoreBreakAlphaRange = 0.25f;

const float kShoreBreakScaleMin = 0.2f;
const float kShoreBreakScaleMax = 1.0f;
const float kShoreBreakScaleMid = 0.6f;
const float kShoreBreakScaleRange = 0.8f;

const float kLavaTransitionDuration = 2.5f; // Must not be zero to prevent possible DBZ

@interface Sea ()

- (void)setState:(int)state;
- (void)setLavaState:(int)state;
- (void)setLavaWaveAlpha:(float)value;
- (void)setWhirlpoolWaveAlpha:(float)value;
- (void)setWaterAlpha:(float)value;
- (NSString *)stringForTimeOfDay:(TimeOfDay)timeOfDay;
- (void)addWaves;
- (void)setTimeGradient:(SPQuad *)quad;
- (void)transitionTimeGradients:(float)transitionDuration proportionRemaining:(float)proportionRemaining;
- (void)animateShoreBreak:(SPImage *)whiteWater scaleTarget:(float)scaleTarget alphaTarget:(float)alphaTarget receding:(BOOL)receding;
- (void)onShoreBreakCompleted:(SPEvent *)event;
- (void)onTransitionedToLava:(SPEvent *)event;
- (void)onTransitionedFromLava:(SPEvent *)event;
- (void)onWhirlpoolDespawned:(SPEvent *)event;
- (void)onTransitionedToWhirlpool:(SPEvent *)event;
- (void)onTransitionedFromWhirlpool:(SPEvent *)event;

- (void)onShorebreakApproached:(SPEvent *)event;
- (void)onShorebreakReceded:(SPEvent *)event;

@end

@implementation Sea

@dynamic lavaAlpha;

+ (float)lavaTransitionDuration {
	return kLavaTransitionDuration;
}

+ (float)whirlpoolWavesAlpha {
	return kWhirlpoolWavesAlpha;
}

- (id)init {
	if (self = [super initWithCategory:CAT_PF_SEA]) {
		self.touchable = YES;
        mAdvanceable = YES;
		
		GameController *gc = [GameController GC];
        mLavaID = gc.thisTurn.turnID;
		mTweening = NO;
        mWhirlpoolTimer = 0.0;
        
        if (RESM.isLowPerformance)
            mTimeGradients = [[Globals loadPlistArray:@"TimeGradients-no-waves"] retain];
        else
            mTimeGradients = [[Globals loadPlistArray:@"TimeGradients"] retain];
		
		// Water
		mWaterSprite = [[SPSprite alloc] init];
		mWater = [[SPQuad alloc] initWithWidth:mScene.viewWidth height:mScene.viewHeight];
		[mWaterSprite addChild:mWater];
		[self addChild:mWaterSprite];
		
		// Voodoo Quads
		mLava = [[SPQuad alloc] initWithWidth:mScene.viewWidth height:mScene.viewHeight];
		[mLava setColor:0xff0000 ofVertex:0];
		[mLava setColor:0xfd6200 ofVertex:1];
		[mLava setColor:0xfe2b00 ofVertex:2];
		[mLava setColor:0xfb8e00 ofVertex:3];
		[self addChild:mLava];
		
		// Waves
		mWaveProp = [[Prop alloc] initWithCategory:CAT_PF_WAVES];
        mLavaWaveProp = [[Prop alloc] initWithCategory:CAT_PF_WAVES];
		mWaves = [[NSMutableArray alloc] init];
		[self addWaves];
		[mScene addProp:mWaveProp];
		
		// Current time gradiemt
		mTimeOfDay = gc.timeOfDay;
		
		// Initialize this for first call to transitionTimeGradients
		[self setTimeGradient:mWater];
        
        mGradientTweens = [[NSMutableDictionary alloc] initWithCapacity:6];
        
        for (TimeOfDay timeOfDay = NewGameTransition; timeOfDay <= Dawn; ++timeOfDay) {
            if ([TimeKeeper doesTimePeriodTransition:timeOfDay]) {
                NSArray *gradient = [mTimeGradients objectAtIndex:(int)timeOfDay];
                
                SPTween *tween = [SPTween tweenWithTarget:mWater time:[TimeKeeper durationForPeriod:timeOfDay] transition:SP_TRANSITION_LINEAR];
                [tween animateTopLeftColorWithTargetValue:[(NSNumber *)[gradient objectAtIndex:0] unsignedIntValue]];
                [tween animateTopRightColorWithTargetValue:[(NSNumber *)[gradient objectAtIndex:1] unsignedIntValue]];
                [tween animateBottomLeftColorWithTargetValue:[(NSNumber *)[gradient objectAtIndex:2] unsignedIntValue]];
                [tween animateBottomRightColorWithTargetValue:[(NSNumber *)[gradient objectAtIndex:3] unsignedIntValue]];
                [mGradientTweens setObject:tween forKey:[self stringForTimeOfDay:timeOfDay]];
            }
        }
		
		if (gc.timeKeeper.transitions)
			[self transitionTimeGradients:gc.timeKeeper.timeRemaining proportionRemaining:gc.timeKeeper.proportionRemaining];
        
		// Shore break
[RESM pushItemOffsetWithAlignment:RALowerRight];
		mShoreBreak = [[SPSprite alloc] init];
		mShoreBreak.rx = 397.0f;
		mShoreBreak.ry = 252.0f;
		mShoreBreak.rotation = -PI / 4.6f;
		[mScene.spriteLayerManager addChild:mShoreBreak withCategory:CAT_PF_SHOREBREAK];
[RESM popOffset];
        
        mShorebreakApproachTweens = nil;
        mShorebreakRecedeTweens = nil;
		
		SPImage *whiteWater = nil;
		float scaleStart = 0.9f, scaleTarget = 0.0f, alphaTarget = 0.0f; 
		
		for (int i = 0; i < 3; ++i, scaleStart -= 0.3333f) {
			whiteWater = [SPImage imageWithTexture:[mScene textureByName:[NSString stringWithFormat:@"shorebreak_%02d", i]]];
			whiteWater.x = -whiteWater.width / 2;
			whiteWater.y = -whiteWater.height / 2;
			whiteWater.scaleY = scaleStart;
			[mShoreBreak addChild:whiteWater];
			
			BOOL receding = (whiteWater.scaleY > kShoreBreakScaleMid);
			
			scaleTarget = (receding) ? kShoreBreakScaleMin : kShoreBreakScaleMax;
			//whiteWater.alpha = kShoreBreakAlphaMax - kShoreBreakAlphaRange * (fabsf(kShoreBreakScaleMid - whiteWater.scaleY) / (kShoreBreakScaleMid - kShoreBreakScaleMin));
			//alphaTarget = (receding) ? kShoreBreakAlphaMin : kShoreBreakAlphaMax;
            
            alphaTarget = kShoreBreakAlphaMin;
            whiteWater.alpha = (receding) ? kShoreBreakAlphaMin : kShoreBreakAlphaMax - kShoreBreakAlphaRange * (fabsf(scaleTarget - scaleStart) / kShoreBreakScaleRange);
            
			[self animateShoreBreak:whiteWater scaleTarget:scaleTarget alphaTarget:alphaTarget receding:receding];
		}
        
		[self setState:SeaStateNormal];
		[self setLavaState:LavaStateInactive];
		
		// Whirlpool
		mWhirlpool = nil;
	}
	return self;
}

- (void)setShorebreakHidden:(BOOL)hidden {
    mShoreBreak.visible = !hidden;
}

- (void)setState:(int)state {
	switch (state) {
		case SeaStateNormal:
			mWaveProp.alpha = 1;
			break;
		case SeaStateTransitionToWhirlpool:
			break;
		case SeaStateWhirlpool:
            mWaveProp.alpha = kWhirlpoolWavesAlpha;
			break;
		case SeaStateTransitionFromWhirlpool:
			break;
	}
	mState = state;
}

- (void)setLavaState:(int)state {
	switch (state) {
		case LavaStateInactive:
			mLava.alpha = 0;
            mLava.visible = NO;
            mLavaWaveProp.alpha = 1;
			[mWhirlpool setWaterColor:0xffffff];
            [mScene.audioPlayer stopEaseOutSoundWithKey:@"SeaOfLava"];
			break;
		case LavaStateTransitionTo:
            mLavaID = self.turnID;
			mLava.visible = YES;
            
            if (mLavaState == LavaStateInactive)
                [mScene.audioPlayer playSoundWithKey:@"SeaOfLava" volume:1.0f easeInDuration:1.0f];
			break;
		case LavaStateActive:
			mLava.alpha = 1;
			mLava.visible = YES;
            mLavaWaveProp.alpha = kLavaWavesAlpha;
			[mWhirlpool setWaterColor:0xff0000];
            [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_SEA_OF_LAVA_PEAKED]];
			break;
		case LavaStateTransitionFrom:
			//mLava.alpha = 1;
			mLava.visible = YES;
			break;
		default:
			assert(0);
			break;
	}
	mLavaState = state;
}

- (NSString *)stringForTimeOfDay:(TimeOfDay)timeOfDay {
    return [NSString stringWithFormat:@"%d", (int)timeOfDay];
}

- (void)addWaves {
    if (RESM.isLowPerformance || mWaves.count != 0)
        return;
     NSString *atlasName = [NSString stringWithFormat:@"Waves%d", 0];
     NSString *atlasPath = [NSString stringWithFormat:@"waves%d-atlas.xml", 0];
     SPTextureAtlas *atlas = [mScene.tm atlasByName:atlasName category:mScene.sceneKey];
     
     if (atlas == nil)
         [mScene.tm checkoutAtlasByName:atlasName path:atlasPath category:mScene.sceneKey];
    
    SPTexture *texture = [mScene textureByName:[NSString stringWithFormat:@"waves%d", 0]];
    texture = [Globals repeatedTexture:texture width:texture.width height:texture.height boldness:3];
    texture.repeat = YES;
    [mScene checkinAtlasByName:atlasName];
	
    Wave *wave = [[Wave alloc] initWithTexture:texture initAlpha:0.7f target:0.35f rate:1.5f];
    [wave flowXOverTime:120.0f];
    [wave flowYOverTime:60.0f];
    [mWaves addObject:wave];
    [mLavaWaveProp addChild:wave];
	[mWaveProp addChild:mLavaWaveProp];
	[wave release];
}

- (void)advanceTime:(double)time {
    if (mWhirlpool && mWhirlpoolTimer > 0.0) {
        mWhirlpoolTimer -= time;
        
        if (mWhirlpoolTimer <= 0.0)
            [self transitionFromWhirlpoolOverTime:VOODOO_DESPAWN_DURATION];
    }
}

- (void)setTimeGradient:(SPQuad *)quad {
	NSArray *gradient = [mTimeGradients objectAtIndex:mTimeOfDay];
	
	for (int i = 0; i < 4; ++i)
		[quad setColor:[(NSNumber *)[gradient objectAtIndex:i] unsignedIntValue] ofVertex:i];
}

- (void)transitionTimeGradients:(float)transitionDuration proportionRemaining:(float)proportionRemaining {
	[mScene.juggler removeTweensWithTarget:mWater];
	
    SPTween *tween = [mGradientTweens objectForKey:[self stringForTimeOfDay:(TimeOfDay)mTimeOfDay]];
    
    if (tween && SP_IS_FLOAT_EQUAL(proportionRemaining, 1)) {
        [tween reset];
        [mScene.juggler addObject:tween];
    } else {
        NSArray *gradient = [mTimeGradients objectAtIndex:mTimeOfDay];
        SPTween *tween = [SPTween tweenWithTarget:mWater time:transitionDuration transition:SP_TRANSITION_LINEAR];
        [tween animateTopLeftColorWithTargetValue:[(NSNumber *)[gradient objectAtIndex:0] unsignedIntValue]];
        [tween animateTopRightColorWithTargetValue:[(NSNumber *)[gradient objectAtIndex:1] unsignedIntValue]];
        [tween animateBottomLeftColorWithTargetValue:[(NSNumber *)[gradient objectAtIndex:2] unsignedIntValue]];
        [tween animateBottomRightColorWithTargetValue:[(NSNumber *)[gradient objectAtIndex:3] unsignedIntValue]];
        [mScene.juggler addObject:tween];
    }
}

- (void)timeOfDayChanged:(TimeOfDayChangedEvent *)event {
	mTimeOfDay = event.timeOfDay;
    
	if (event.transitions) {
		[self transitionTimeGradients:event.timeRemaining proportionRemaining:event.proportionRemaining];
	} else {
		[self setTimeGradient:mWater];
	}
    
    for (Wave *wave in mWaves)
        [wave timeOfDayChanged:event];
}

- (void)onShorebreakApproached:(SPEvent *)event {
    NSArray *recedeTweens = nil;
    SPTween *approachTween = (SPTween *)event.currentTarget;
    SPImage *whiteWater = approachTween.target;
    
    whiteWater.alpha = kShoreBreakAlphaMin;
    [mScene.juggler removeTweensWithTarget:whiteWater]; // Remove looping alpha tween
    
    if (mShorebreakRecedeTweens == nil)
        mShorebreakRecedeTweens = [[NSMutableArray alloc] initWithCapacity:3];
    else if (mShorebreakRecedeTweens.count >= 3) {
        recedeTweens = [[(NSArray *)[mShorebreakRecedeTweens lastObject] retain] autorelease];
        [mShorebreakRecedeTweens removeLastObject];
        [mShorebreakRecedeTweens insertObject:recedeTweens atIndex:0];
    }
    
    if (recedeTweens == nil) {
        // Receding from shore
        float scaleTarget = kShoreBreakScaleMin, alphaTarget = kShoreBreakAlphaMin;
        float duration = 4 * fabsf(whiteWater.scaleY - scaleTarget);
        
        SPTween *alphaTween = [SPTween tweenWithTarget:whiteWater time:duration transition:SP_TRANSITION_LINEAR];
        [alphaTween animateProperty:@"alpha" targetValue:alphaTarget];
        
        SPTween *scaleTween = [SPTween tweenWithTarget:whiteWater time:duration transition:SP_TRANSITION_EASE_IN_OUT];
        [scaleTween animateProperty:@"scaleY" targetValue:scaleTarget];
        [scaleTween addEventListener:@selector(onShorebreakReceded:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
        
        recedeTweens = [NSArray arrayWithObjects:alphaTween, scaleTween, nil];
        [mShorebreakRecedeTweens insertObject:recedeTweens atIndex:0];
    }
    
    for (SPTween *tween in recedeTweens) {
        [tween reset];
        [mScene.juggler addObject:tween];
    }
}

- (void)onShorebreakReceded:(SPEvent *)event {
    NSArray *approachTweens = nil;
    SPTween *recedeTween = (SPTween *)event.currentTarget;
    SPImage *whiteWater = recedeTween.target;
    
    whiteWater.alpha = kShoreBreakAlphaMin;
    
    if (mShorebreakApproachTweens == nil)
        mShorebreakApproachTweens = [[NSMutableArray alloc] initWithCapacity:3];
    else if (mShorebreakApproachTweens.count >= 3) {
        approachTweens = [[(NSArray *)[mShorebreakApproachTweens lastObject] retain] autorelease];
        [mShorebreakApproachTweens removeLastObject];
        [mShorebreakApproachTweens insertObject:approachTweens atIndex:0];
    }
    
    if (approachTweens == nil) {
        // Approaching shore
        float scaleTarget = kShoreBreakScaleMax, alphaTarget = kShoreBreakAlphaMax;
        float duration = 4 * fabsf(whiteWater.scaleY - scaleTarget);
        
        SPTween *alphaTween = [SPTween tweenWithTarget:whiteWater time:duration / 2 transition:SP_TRANSITION_LINEAR];
        [alphaTween animateProperty:@"alpha" targetValue:alphaTarget];
        alphaTween.loop = SPLoopTypeReverse;
        
        SPTween *scaleTween = [SPTween tweenWithTarget:whiteWater time:duration transition:SP_TRANSITION_EASE_IN_OUT];
        [scaleTween animateProperty:@"scaleY" targetValue:scaleTarget];
        [scaleTween addEventListener:@selector(onShorebreakApproached:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
        
        approachTweens = [NSArray arrayWithObjects:alphaTween, scaleTween, nil];
        [mShorebreakApproachTweens insertObject:approachTweens atIndex:0];
    }
    
    for (SPTween *tween in approachTweens) {
        [tween reset];
        [mScene.juggler addObject:tween];
    }
}

- (void)animateShoreBreak:(SPImage *)whiteWater scaleTarget:(float)scaleTarget alphaTarget:(float)alphaTarget receding:(BOOL)receding {
	float duration = 4 * fabsf(whiteWater.scaleY - scaleTarget);
	
	SPTween *tween = [SPTween tweenWithTarget:whiteWater time:duration transition:SP_TRANSITION_LINEAR];
	[tween animateProperty:@"alpha" targetValue:alphaTarget];
	[mScene.juggler addObject:tween];
	
	tween = [SPTween tweenWithTarget:whiteWater time:duration transition:SP_TRANSITION_EASE_IN_OUT];
	[tween animateProperty:@"scaleY" targetValue:scaleTarget];
    //[tween addEventListener:@selector(onShoreBreakCompleted:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
    
    if (receding)
        [tween addEventListener:@selector(onShorebreakReceded:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
    else
        [tween addEventListener:@selector(onShorebreakApproached:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
	[mScene.juggler addObject:tween];
}

- (void)onShoreBreakCompleted:(SPEvent *)event {
    /*
	BOOL receding = NO;
	float scaleTarget, alphaTarget;
	SPImage *whiteWater = ((SPTween *)event.currentTarget).target;
	
    [mScene.juggler removeTweensWithTarget:whiteWater]; // Remove looping alpha tween
    
	whiteWater.alpha = kShoreBreakAlphaMin;
	
	if (whiteWater.scaleY > kShoreBreakScaleMid) {	// Receding from shore
		scaleTarget = kShoreBreakScaleMin;
		alphaTarget = kShoreBreakAlphaMin;
		receding = YES;
	} else {										// Approaching shore
		scaleTarget = kShoreBreakScaleMax;
		alphaTarget = kShoreBreakAlphaMax;
	}
	
	[self animateShoreBreak:whiteWater scaleTarget:scaleTarget alphaTarget:alphaTarget receding:receding];
     */
}

- (void)setWaterAlpha:(float)value {
	mWaterSprite.alpha = value;
}

- (float)lavaAlpha {
	return mLava.alpha;
}

- (void)setLavaAlpha:(float)value {
	mLava.alpha = value;
	
	if (mWhirlpool && mLavaState != LavaStateInactive)
		[mWhirlpool setWaterColor:0xff0000 + (uint)(255 * (1 - value)) * 0x101];
}

- (void)setLavaWaveAlpha:(float)value {
	mLavaWaveProp.alpha = value;
}

- (void)transitionToLavaOverTime:(float)duration {
    if (mLavaState == LavaStateActive || mLavaState == LavaStateTransitionTo)
        return;
    [mScene.juggler removeTweensWithTarget:mLavaWaveProp];
	[mScene.juggler removeTweensWithTarget:self];
	
	if (SP_IS_FLOAT_EQUAL(duration,0)) {
		[self setLavaState:LavaStateActive];
	} else {
		[self setLavaState:LavaStateTransitionTo];
		
        SPTween *tween = [SPTween tweenWithTarget:mLavaWaveProp time:duration transition:SP_TRANSITION_LINEAR];
		[tween animateProperty:@"alpha" targetValue:kLavaWavesAlpha];
		[mScene.juggler addObject:tween];
        
		tween = [SPTween tweenWithTarget:self time:duration transition:SP_TRANSITION_LINEAR];
		[tween animateProperty:@"lavaAlpha" targetValue:1.0f];
		[tween addEventListener:@selector(onTransitionedToLava:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
		[mScene.juggler addObject:tween];
	}
}

- (void)transitionFromLavaOverTime:(float)duration {
    [self transitionFromLavaOverTime:duration delay:0];
}

- (void)transitionFromLavaOverTime:(float)duration delay:(float)delay {
    if (mLavaState == LavaStateInactive || mLavaState == LavaStateTransitionFrom)
        return;
    [mScene.juggler removeTweensWithTarget:mLavaWaveProp];
    [mScene.juggler removeTweensWithTarget:self];
    
	if (SP_IS_FLOAT_EQUAL(duration,0)) {
		[self setLavaState:LavaStateInactive];
	} else {
		[self setLavaState:LavaStateTransitionFrom];
        
        SPTween *tween = [SPTween tweenWithTarget:mLavaWaveProp time:duration transition:SP_TRANSITION_LINEAR];
		[tween animateProperty:@"alpha" targetValue:1.0f];
		[mScene.juggler addObject:tween];
		
		tween = [SPTween tweenWithTarget:self time:duration transition:SP_TRANSITION_LINEAR];
		[tween animateProperty:@"lavaAlpha" targetValue:0.0f];
        tween.delay = delay;
		[tween addEventListener:@selector(onTransitionedFromLava:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
		[mScene.juggler addObject:tween];
	}
}

- (void)onTransitionedToLava:(SPEvent *)event {
	[self setLavaState:LavaStateActive];
}

- (void)onTransitionedFromLava:(SPEvent *)event {
	[self setLavaState:LavaStateInactive];
    
    if (mLavaID == self.turnID)
        [mScene.objectivesManager progressObjectiveWithEventType:OBJ_TYPE_VOODOO_GADGET_EXPIRED tag:VOODOO_SPELL_SEA_OF_LAVA];
}

- (void)setWhirlpoolWaveAlpha:(float)value {
	mWaveProp.alpha = value;
}

- (void)summonWhirlpoolWithDuration:(float)duration {
	if (mWhirlpool) {
        [mWhirlpool removeEventListener:@selector(onWhirlpoolDespawned:) atObject:self forType:CUST_EVENT_TYPE_WHIRLPOOL_DESPAWNED];
        [mWhirlpool release]; mWhirlpool = nil;
    }
    
	float spawnDuration = [WhirlpoolActor spawnDuration];
	double idolDuration = [Idol durationForIdol:[mScene idolForKey:VOODOO_SPELL_WHIRLPOOL]];
	
	if (SP_IS_FLOAT_EQUAL(duration,idolDuration)) {
		[self transitionToWhirlpoolOverTime:spawnDuration];
	} else if (duration > (idolDuration - spawnDuration)) {
		[self setWhirlpoolWaveAlpha:[Sea whirlpoolWavesAlpha] * ((idolDuration-duration) / spawnDuration)]; // Won't DBZ
		[self transitionToWhirlpoolOverTime:spawnDuration-(idolDuration-duration)];
	} else {
		[self transitionToWhirlpoolOverTime:0];
	}
	
	mWhirlpool = [[WhirlpoolActor whirlpoolActorAtX:P2MX(RESW / 2) y:P2MY(RESH / 2) rotation:0.0f duration:duration] retain];
	[mWhirlpool addEventListener:@selector(onWhirlpoolDespawned:) atObject:self forType:CUST_EVENT_TYPE_WHIRLPOOL_DESPAWNED];
	//[whirlpool setWaterColor:[GameController GC].timeKeeper.waterColor];
	[mScene addActor:mWhirlpool];
	
	if (duration <= VOODOO_DESPAWN_DURATION) {
		[self setWhirlpoolWaveAlpha:1 - [Sea whirlpoolWavesAlpha] * (duration / VOODOO_DESPAWN_DURATION)];
		[self transitionFromWhirlpoolOverTime:duration];
	} else {
        mWhirlpoolTimer = duration - VOODOO_DESPAWN_DURATION;
	}
}

- (void)onWhirlpoolDespawned:(SPEvent *)event {
	[mWhirlpool removeEventListener:@selector(onWhirlpoolDespawned:) atObject:self forType:CUST_EVENT_TYPE_WHIRLPOOL_DESPAWNED];
	[mWhirlpool release]; mWhirlpool = nil;
}

- (void)transitionToWhirlpoolOverTime:(float)duration {
	if (mState != SeaStateNormal)
		return;
    
    [mScene.juggler removeTweensWithTarget:mWaveProp];
	
	if (SP_IS_FLOAT_EQUAL(duration,0)) {
		[self setState:SeaStateWhirlpool];
	} else {
		[self setState:SeaStateTransitionToWhirlpool];
		
		SPTween *tween = [SPTween tweenWithTarget:mWaveProp time:duration transition:SP_TRANSITION_LINEAR];
		[tween animateProperty:@"alpha" targetValue:kWhirlpoolWavesAlpha];
		[tween addEventListener:@selector(onTransitionedToWhirlpool:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
		[mScene.juggler addObject:tween];
	}
}

- (void)transitionFromWhirlpoolOverTime:(float)duration {
	if (mState != SeaStateWhirlpool)
		return;
	mWaveProp.visible = YES;
    [mScene.juggler removeTweensWithTarget:mWaveProp];
	
	if (SP_IS_FLOAT_EQUAL(duration,0)) {
		[self setState:SeaStateNormal];
	} else {		
		SPTween *tween = [SPTween tweenWithTarget:mWaveProp time:duration transition:SP_TRANSITION_LINEAR];
		[tween animateProperty:@"alpha" targetValue:1.0f];
		[tween addEventListener:@selector(onTransitionedFromWhirlpool:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
		[mScene.juggler addObject:tween];
	}
}

- (void)onTransitionedToWhirlpool:(SPEvent *)event {
	[self setState:SeaStateWhirlpool];
}

- (void)onTransitionedFromWhirlpool:(SPEvent *)event {
	[self setState:SeaStateNormal];
}

- (void)enableSlowedTime:(BOOL)enable {
    if (mWhirlpool)
        mWhirlpool.suckFactor = (enable) ? 4.0f : 1.0f;
}

- (void)prepareForNewGame {
    mTurnID = GCTRL.thisTurn.turnID;
    [self transitionFromLavaOverTime:2.0f];
}

- (void)dealloc {
	[mWhirlpool removeEventListener:@selector(onWhirlpoolDespawned:) atObject:self forType:CUST_EVENT_TYPE_WHIRLPOOL_DESPAWNED];
	[mScene.spriteLayerManager removeChild:mShoreBreak withCategory:CAT_PF_SHOREBREAK];
	[mScene removeProp:mWaveProp];
	[mScene.juggler removeTweensWithTarget:mLava];
	[mScene.juggler removeTweensWithTarget:mWaveProp];
    [mScene.juggler removeTweensWithTarget:mLavaWaveProp];
	[mScene.juggler removeTweensWithTarget:mWater];
	
    for (int i = 0; i < mShoreBreak.numChildren; ++i) {
        SPDisplayObject *whiteWater = [mShoreBreak childAtIndex:i];
        [mScene.juggler removeTweensWithTarget:whiteWater];
    }
    
    [mScene.juggler removeTweensWithTarget:mShoreBreak];
	
    [mShorebreakApproachTweens release]; mShorebreakApproachTweens = nil;
    [mShorebreakRecedeTweens release]; mShorebreakRecedeTweens = nil;
    
    for (Wave *wave in mWaves)
        [mScene.juggler removeTweensWithTarget:wave];
    
	[mWaves release]; mWaves = nil;
	[mWaveProp release]; mWaveProp = nil;
    [mLavaWaveProp release]; mLavaWaveProp = nil;
	[mWater release]; mWater = nil;
	[mWaterSprite release]; mWaterSprite = nil;
	[mLava release]; mLava = nil;
	[mShoreBreak release]; mShoreBreak = nil;
	[mTimeGradients release]; mTimeGradients = nil;
    [mGradientTweens release]; mGradientTweens = nil;
	[mWhirlpool release]; mWhirlpool = nil;
	[super dealloc];
}

@end
