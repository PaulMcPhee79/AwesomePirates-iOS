//
//  BeachActor.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 5/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "BeachActor.h"
#import "PlayerShip.h"
#import "NightShade.h"
#import "GameController.h"
#import "Globals.h"

@interface BeachActor ()

- (void)timeOfDayChanged:(TimeOfDayChangedEvent *)event;
- (void)onTravelledBackInTime:(SPEvent *)event;

@end


@implementation BeachActor

@synthesize state = mState;
@synthesize coveEnabled = mCoveEnabled;

- (id)initWithActorDef:(ActorDef *)def {
    if (self = [super initWithActorDef:def]) {
		assert(def && def->fixtureDefCount == 6);
		mAdvanceable = YES;
		mCoveEnabled = YES;
		mCoveGate = def->fixtures[2];
		mDepartSensor = def->fixtures[4];
		mCoveSensor = def->fixtures[5];
		mArrivals = [[NSMutableArray alloc] init];
		mCoveFutureImage = nil;
		mNightShade = nil;
		mState = BeachStateDeparting;
        mTorch = nil;
    }
    return self;
}

- (void)setupBeach {
	SPImage *sandImage = [SPImage imageWithTexture:[mScene textureByName:@"beach"]];
	sandImage.x = mScene.viewWidth - sandImage.width;
	sandImage.y = mScene.viewHeight - sandImage.height;
	[self addChild:sandImage];
	
	// Cove
	mCoveProp = [[Prop alloc] initWithCategory:CAT_PF_EXPLOSIONS];
	mCoveImage = [[SPImage alloc] initWithTexture:[mScene textureByName:@"cove"]];
	mCoveImage.x = mScene.viewWidth - mCoveImage.width;
	mCoveImage.y = mScene.viewHeight - 161.0f;
	[mCoveProp addChild:mCoveImage];
    [mScene addProp:mCoveProp];
    
	// Day/Night cycle
	NSArray *shaders = [NSArray arrayWithObjects:sandImage,mCoveImage,nil]; //torchBaseImage
	mNightShade = [[NightShade alloc] initWithShaders:shaders];
					
	GameController *gc = [GameController GC];
	[mNightShade transitionTimeOfDay:gc.timeOfDay transitionDuration:gc.timeKeeper.timeRemaining proportionRemaining:gc.timeKeeper.proportionRemaining];
}

- (void)setHidden:(BOOL)hidden {
    self.visible = !hidden;
    mCoveProp.visible = !hidden;
}

- (void)setState:(BeachState)state {
	switch (state) {
		case BeachStateClosing:
			break;
		case BeachStateClosed:
			[self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_COVE_CLOSED]];
			assert(mArrivals.count == 0);
			break;
		case BeachStateOpen:
			if (mScene.raceEnabled)
				return;
			[self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_COVE_OPENED]];
			break;
		case BeachStateDeparting:
			break;
		default:
			assert(0);
			break;
	}
	mState = state; //BeachStateOpen;
}

- (void)advanceTime:(double)time {
	[mNightShade advanceTime:time];
}

- (void)debugToggle {
	if (mState == BeachStateClosed)
		self.state = BeachStateOpen;
	else if (mState == BeachStateOpen && mArrivals.count == 0)
		self.state = BeachStateClosed;
}

- (void)openCove {
    self.state = BeachStateOpen;
}

- (void)closeCove {
	if (mState == BeachStateOpen)
		self.state = BeachStateClosing;
}

- (void)timeOfDayChanged:(TimeOfDayChangedEvent *)event {
    /*
	if (mCoveEnabled) {
		if (event.day < 5 && event.timeOfDay == Midnight && mState == BeachStateClosed)
			[self openCove];
		else if (event.timeOfDay == DawnTransition && mState == BeachStateOpen)
			[self closeCove];
	}
     */

	if (event.transitions)
		[mNightShade transitionTimeOfDay:event.timeOfDay transitionDuration:event.timeRemaining proportionRemaining:event.proportionRemaining];
}

- (void)travelBackInTime:(float)duration {
    if (mCoveFutureImage == nil)
        return;
    
    [mScene.juggler removeTweensWithTarget:mCoveFutureImage];
    [mScene.juggler removeTweensWithTarget:mCoveImage];
    
    SPTween *tween = [SPTween tweenWithTarget:mCoveFutureImage time:mCoveFutureImage.alpha * duration];
	[tween animateProperty:@"alpha" targetValue:0.0f];
    [tween addEventListener:@selector(onTravelledBackInTime:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
	[mScene.juggler addObject:tween];
	
	tween = [SPTween tweenWithTarget:mCoveImage time:(1.0f - mCoveImage.alpha) * duration];
	[tween animateProperty:@"alpha" targetValue:1.0f];
	[mScene.juggler addObject:tween];
}

- (void)onTravelledBackInTime:(SPEvent *)event {
    if (mCoveFutureImage) {
        [mNightShade removeShader:mCoveFutureImage];
        [mCoveFutureImage removeFromParent];
        [mCoveFutureImage release]; mCoveFutureImage = nil;
    }
}

- (void)travelForwardInTime:(float)duration {
	if (mCoveFutureImage != nil)
		return;
	mCoveFutureImage = [[SPImage alloc] initWithTexture:[mScene textureByName:@"cove-future"]];
    mCoveFutureImage.x = mScene.viewWidth - 66; //68;
	mCoveFutureImage.y = mScene.viewHeight - 153; // 139;
	mCoveFutureImage.alpha = 0.0f;
	[mCoveProp addChild:mCoveFutureImage];
	[mNightShade addShader:mCoveFutureImage];
	
	SPTween *tween = [SPTween tweenWithTarget:mCoveFutureImage time:duration];
	[tween animateProperty:@"alpha" targetValue:1.0f];
	[mScene.juggler addObject:tween];
	
	tween = [SPTween tweenWithTarget:mCoveImage time:duration];
	[tween animateProperty:@"alpha" targetValue:0.0f];
	[mScene.juggler addObject:tween];
}

- (void)respondToPhysicalInputs {
	for (Actor *actor in mContacts) {
		if ([actor isKindOfClass:[PlayerShip class]]) {
            if (GCTRL.thisTurn.adventureState != AdvStateNormal)
                continue;
			PlayerShip *ship = (PlayerShip *)actor;
			
			if (ship.sinking == NO)
				[self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_PLAYER_ENTERED_COVE]];
		}
	}
	
	if ((mState == BeachStateClosing || mState == BeachStateDeparting) && mArrivals.count == 0)
		self.state = BeachStateClosed;
}

- (bool)preSolve:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
	if (mState != BeachStateClosed && [other isKindOfClass:[PlayerShip class]] && fixtureSelf == mCoveGate)
		return false;
	return [super preSolve:other fixtureSelf:fixtureSelf fixtureOther:fixtureOther contact:contact];
}

- (void)beginContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
	if ([other isKindOfClass:[PlayerShip class]]) {
		if (fixtureSelf == mCoveSensor && mState != BeachStateDeparting)
			[super beginContact:other fixtureSelf:fixtureSelf fixtureOther:fixtureOther contact:contact];
		else if (fixtureSelf == mDepartSensor)
			[mArrivals addObject:other];
	}
	// Don't care about other ships
}

- (void)endContact:(Actor *)other fixtureSelf:(b2Fixture *)fixtureSelf fixtureOther:(b2Fixture *)fixtureOther contact:(b2Contact *)contact {
	if ([other isKindOfClass:[PlayerShip class]]) {
        if (fixtureSelf == mDepartSensor) {
            assert(mArrivals.count > 0);
            [mArrivals removeLastObject];
        } else if (fixtureSelf == mCoveSensor) {
            [super endContact:other fixtureSelf:fixtureSelf fixtureOther:fixtureOther contact:contact];
        }
	}
}

- (void)prepareForNewGame {
    // Do nothing
}

- (void)zeroOutFixtures {
	[super zeroOutFixtures];
	
	mCoveGate = 0;
	mCoveSensor = 0;
	mDepartSensor = 0;
}

- (void)dealloc {
    [mScene.juggler removeTweensWithTarget:mCoveFutureImage];
	[mScene.juggler removeTweensWithTarget:mCoveImage];
    [mScene removeProp:mCoveProp];
	
	mCoveGate = 0;
	mDepartSensor = 0;
	mCoveSensor = 0;
	[mCoveImage release]; mCoveImage = nil;
	[mCoveFutureImage release]; mCoveFutureImage = nil;
	[mCoveProp release]; mCoveProp = nil;
	[mTorch release]; mTorch = nil;
	[mArrivals release]; mArrivals = nil;
	[mNightShade destroyNightShade];
	[mNightShade release]; mNightShade = nil;
	[super dealloc];
	
	NSLog(@"BeachActor dealloc'ed");
}

@end
