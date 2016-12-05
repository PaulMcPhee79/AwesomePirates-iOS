//
//  TownActor.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 7/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "TownActor.h"
#import "TownCannon.h"
#import "NightShade.h"
#import "GameController.h"
#import "Globals.h"

@interface TownActor ()

- (void)onTravelledBackInTime:(SPEvent *)event;
- (void)transitionLightsForTimeOfDay:(int)timeOfDay transitionDuration:(float)transitionDuration proportionRemaining:(float)proportionRemaining;
- (void)timeOfDayChanged:(TimeOfDayChangedEvent *)event;

@end


@implementation TownActor

@synthesize leftCannon = mLeftCannon;
@synthesize rightCannon = mRightCannon;

- (id)initWithActorDef:(ActorDef *)def {
    if (self = [super initWithActorDef:def]) {
		mAdvanceable = YES;
        mCategory = CAT_PF_BUILDINGS;
    }
    return self;
}

- (void)setupTown {
	mTownSprite = [[SPSprite alloc] init];
	[self addChild:mTownSprite];
	
	// Town
	SPImage *townImage = [SPImage imageWithTexture:[mScene textureByName:@"town"]];
	//townImage.x = -12;
	//townImage.y = -9;
	[mTownSprite addChild:townImage];
    
    // Town House and Cannon overlay
    mTownHouseAndCannon = [[Prop alloc] initWithCategory:CAT_PF_EXPLOSIONS];
    
    SPImage *townHouseImage = [SPImage imageWithTexture:[mScene textureByName:@"town-house"]];
    townHouseImage.x = 0;
    townHouseImage.y = 17;
    [mTownHouseAndCannon addChild:townHouseImage];
    
    SPImage *townCannonImage = [SPImage imageWithTexture:[mScene textureByName:@"town-cannon"]];
    townCannonImage.x = 13;
    townCannonImage.y = 38;
    [mTownHouseAndCannon addChild:townCannonImage];
    [mScene addProp:mTownHouseAndCannon];
	
	// Lights
    float townLightCoords[10] = { 6, 72, 11, 67, -1, 35, 4, 30, 62, 10 };
    mTownLights = [[Prop alloc] initWithCategory:CAT_PF_EXPLOSIONS];
    
    for (int i = 0; i < 5; ++i) {
        SPImage *townLightImage = [SPImage imageWithTexture:[mScene textureByName:[NSString stringWithFormat:@"town-light-%d", i]]];
        townLightImage.x = townLightCoords[2*i];
        townLightImage.y = townLightCoords[2*i+1];
        [mTownLights addChild:townLightImage];
    }
    
	mTownLights.alpha = 0;
	[mScene addProp:mTownLights];
	
	// Cannons
	mLeftCannon = [[TownCannon alloc] initWithShotType:@"single-shot_"];
	mLeftCannon.x = 28;
	mLeftCannon.y = 45;
	[mLeftCannon idle];
	
	mRightCannon = [[TownCannon alloc] initWithShotType:@"single-shot_"];
	mRightCannon.x = 89;
	mRightCannon.y = 6;
	[mRightCannon idle];
	
	// Day/Night cycle
	NSArray *shaders = [NSArray arrayWithObjects:townImage,townHouseImage,townCannonImage,nil];
	mNightShade = [[NightShade alloc] initWithShaders:shaders];
	
	GameController *gc = [GameController GC];
	TimeKeeper *tk = gc.timeKeeper;
	[mNightShade transitionTimeOfDay:tk.timeOfDay transitionDuration:tk.timeRemaining proportionRemaining:tk.proportionRemaining];
	[self transitionLightsForTimeOfDay:tk.timeOfDay transitionDuration:tk.timeRemaining proportionRemaining:tk.proportionRemaining];
}

- (void)setHidden:(BOOL)hidden {
    self.visible = !hidden;
    mTownHouseAndCannon.visible = !hidden;
    mTownLights.visible = !hidden;
    mTownFutureLights.visible = !hidden;
}

- (void)advanceTime:(double)time {
	[mNightShade advanceTime:time];
}

- (void)travelBackInTime:(float)duration {
    if (mTownFutureSprite == nil && mTownFutureLights == nil)
		return;
    
    if (mTownFutureLights) {
        [mScene.juggler removeTweensWithTarget:mTownFutureLights];
        [mScene removeProp:mTownFutureLights];
        [mTownFutureLights release]; mTownFutureLights = nil;
    }
    
    [mScene.juggler removeTweensWithTarget:mTownSprite];
	[mScene.juggler removeTweensWithTarget:mTownFutureSprite];
    [mScene.juggler removeTweensWithTarget:mTownHouseAndCannon];
    
    SPTween *tween = [SPTween tweenWithTarget:mTownFutureSprite time:mTownFutureSprite.alpha * duration];
	[tween animateProperty:@"alpha" targetValue:0.0f];
    [tween addEventListener:@selector(onTravelledBackInTime:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
	[mScene.juggler addObject:tween];
	
	tween = [SPTween tweenWithTarget:mTownSprite time:(1.0f - mTownSprite.alpha) * duration];
	[tween animateProperty:@"alpha" targetValue:1.0f];
	[mScene.juggler addObject:tween];
    
    tween = [SPTween tweenWithTarget:mTownHouseAndCannon time:(1.0f - mTownHouseAndCannon.alpha) * duration];
	[tween animateProperty:@"alpha" targetValue:1.0f];
	[mScene.juggler addObject:tween];
}

- (void)onTravelledBackInTime:(SPEvent *)event {
    if (mTownFutureSprite) {
        if (mTownFutureSprite.numChildren > 0) {
            SPImage *townFutureImage = (SPImage *)[mTownFutureSprite childAtIndex:0];
            [mNightShade removeShader:townFutureImage];
        }
        
        [mTownFutureSprite removeFromParent];
        [mTownFutureSprite release]; mTownFutureSprite = nil;
    }
}

- (void)travelForwardInTime:(float)duration {
	if (mTownFutureSprite || mTownFutureLights)
		return;
	mTownFutureSprite = [[SPSprite alloc] init];
	mTownFutureSprite.alpha = 0.0f;
	
	SPImage *image = [SPImage imageWithTexture:[mScene textureByName:@"town-future"]];
	image.x = 0.0f;
	image.y = 0.0f;
	[mTownFutureSprite addChild:image];
	[mNightShade addShader:image];
	[self addChild:mTownFutureSprite];
	
	// Lights
    SPImage *townFutureLightsImage = [SPImage imageWithTexture:[mScene textureByName:@"town-future-lights"]];
    mTownFutureLights = [[Prop alloc] initWithCategory:CAT_PF_EXPLOSIONS];
	[mTownFutureLights addChild:townFutureLightsImage];
	mTownFutureLights.alpha = 0;
	[mScene addProp:mTownFutureLights];
	
	SPTween *tween = [SPTween tweenWithTarget:mTownFutureSprite time:duration];
	[tween animateProperty:@"alpha" targetValue:1.0f];
	[mScene.juggler addObject:tween];
	
	tween = [SPTween tweenWithTarget:mTownSprite time:duration];
	[tween animateProperty:@"alpha" targetValue:0.0f];
	[mScene.juggler addObject:tween];
    
    tween = [SPTween tweenWithTarget:mTownHouseAndCannon time:duration];
	[tween animateProperty:@"alpha" targetValue:0.0f];
	[mScene.juggler addObject:tween];
}

- (void)transitionLightsForTimeOfDay:(int)timeOfDay transitionDuration:(float)transitionDuration proportionRemaining:(float)proportionRemaining {
	SPDisplayObject *lights = mTownLights;
	
	[mScene.juggler removeTweensWithTarget:mTownLights];
	
	if (mTownFutureLights) {
		[mScene.juggler removeTweensWithTarget:mTownFutureLights];
		lights = mTownFutureLights;
	}
	
	BOOL transition = NO;
	float alphaFrom = 0, alphaTo = 0;
	
	switch (timeOfDay) {
		case DuskTransition:
			transition = YES;
			alphaFrom = 0;
			alphaTo = 0.25f;
			break;
		case Dusk:
			alphaFrom = 0.25f;
			alphaTo = 0.25f;
			break;
		case EveningTransition:
			transition = YES;
			alphaFrom = 0.25f;
			alphaTo = 1.0f;
			break;
        case Evening:
		case Midnight:
			alphaFrom = 1;
			alphaTo = 1;
			break;
		case DawnTransition:
			transition = YES;
			alphaFrom = 1.0f;
			alphaTo = 0;
			break;
        case NewGameTransition:
            transition = YES;
			alphaFrom = lights.alpha;
			alphaTo = 0;
			break;
		default:
			return;
	}
	
	if (transition == NO) {
		lights.alpha = alphaTo;
	} else {
		int alphaRange = alphaTo - alphaFrom;
		alphaFrom += (1.0f - proportionRemaining) * alphaRange;
		lights.alpha = alphaFrom;
	
		SPTween *tween = [SPTween tweenWithTarget:lights time:transitionDuration];
		[tween animateProperty:@"alpha" targetValue:alphaTo];
		[mScene.juggler addObject:tween];
	}
}

- (void)timeOfDayChanged:(TimeOfDayChangedEvent *)event {
	if (event.transitions) {
		[mNightShade transitionTimeOfDay:event.timeOfDay transitionDuration:event.timeRemaining proportionRemaining:event.proportionRemaining];
		[self transitionLightsForTimeOfDay:event.timeOfDay transitionDuration:event.timeRemaining proportionRemaining:event.proportionRemaining];
	}
}

- (void)prepareForNewGame {
    // Do nothing
}

- (void)dealloc {
	[mScene.juggler removeTweensWithTarget:mTownLights];
	[mScene.juggler removeTweensWithTarget:mTownFutureLights];
	[mScene.juggler removeTweensWithTarget:mTownSprite];
	[mScene.juggler removeTweensWithTarget:mTownFutureSprite];
    [mScene.juggler removeTweensWithTarget:mTownHouseAndCannon];
    
    [mScene removeProp:mTownLights];
    [mScene removeProp:mTownFutureLights];
    [mScene removeProp:mTownHouseAndCannon];
    
	[mTownLights release]; mTownLights = nil;
	[mTownFutureLights release]; mTownFutureLights = nil;
	[mTownSprite release]; mTownSprite = nil;
	[mTownFutureSprite release]; mTownFutureSprite = nil;
    [mTownHouseAndCannon release]; mTownHouseAndCannon = nil;
	[mLeftCannon release]; mLeftCannon = nil;
	[mRightCannon release]; mRightCannon = nil;
	[mNightShade destroyNightShade];
	[mNightShade release]; mNightShade = nil;
	[super dealloc];
	
	NSLog(@"TownActor dealloc'ed");
}

@end
