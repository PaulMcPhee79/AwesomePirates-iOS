//
//  Wave.m
//  Pirates
//
//  Created by Paul McPhee on 16/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "Wave.h"
#import "Globals.h"


@interface Wave ()

- (void)setState:(WaveSurfaceState)state;
- (void)adjustFlow;
- (SPTween *)animateProperty:(NSString *)property
          displayObject:(SPDisplayObject *)displayObject
            targetValue:(float)targetValue
               overTime:(float)duration
                   loop:(SPLoopType)loop
              exclusive:(BOOL)exclusive;
- (void)onSurfaceTweenCompleted:(SPEvent *)event;

@end


@implementation Wave

@synthesize alphaMin = mAlphaMin;
@synthesize alphaMax = mAlphaMax;
@synthesize alphaRate = mAlphaRate;
@synthesize flowX = mFlowX;
@synthesize flowY = mFlowY;
@synthesize surface = mSurface;

- (id)initWithTexture:(SPTexture *)texture initAlpha:(float)initAlpha target:(float)target rate:(float)rate {
    if (self = [super initWithCategory:CAT_PF_WAVES]) {
        mSurface = [[SPImage alloc] initWithTexture:texture];
        mSurfaceContainer = [[SPSprite alloc] init];
        [mSurfaceContainer addChild:mSurface];
        [self addChild:mSurfaceContainer];
        
        mSurface.width = mScene.viewWidth;
        mSurface.height = mScene.viewHeight;
        
        mXRepeat = mSurface.width / texture.width;
        mYRepeat = mSurface.height / texture.height;
        [mSurface setTexCoords:[SPPoint pointWithX:mXRepeat y:0] ofVertex:1];
        [mSurface setTexCoords:[SPPoint pointWithX:0 y:mYRepeat] ofVertex:2];
        [mSurface setTexCoords:[SPPoint pointWithX:mXRepeat y:mYRepeat] ofVertex:3];
        mSurface.alpha = initAlpha;
        
		mAlphaMin = MIN(initAlpha,target);
		mAlphaMax = MAX(initAlpha,target);
        mAlphaMid = mAlphaMin + (mAlphaMax - mAlphaMin) / 2;
		mAlphaRate = rate;
        
        mFlowX = 0;
        mFlowY = 0;
		
        SPTween *tween = [self animateProperty:@"alpha" displayObject:mSurface targetValue:target overTime:mAlphaRate loop:SPLoopTypeReverse exclusive:YES];
        [tween addEventListener:@selector(onSurfaceTweenCompleted:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
    }
    return self;
}

- (id)init {
	assert(0);
	return nil;
}

- (void)setOrientation:(float)angle {
	self.rotation = angle;
}

- (void)setFlowX:(float)flowX {
    mFlowX = flowX;
    [self adjustFlow];
}

- (void)setFlowY:(float)flowY {
    mFlowY = flowY;
    [self adjustFlow];
}

- (void)setState:(WaveSurfaceState)state {
    if (mState == state)
        return;
    mState = state;
}

- (void)adjustFlow {
    float nearX = mXRepeat - mFlowX * mXRepeat;
    float farX = nearX + mXRepeat;
    float nearY = mYRepeat - mFlowY * mYRepeat;
    float farY = nearY + mYRepeat;
    
    [mSurface setTexCoords:[SPPoint pointWithX:nearX y:nearY] ofVertex:0];
    [mSurface setTexCoords:[SPPoint pointWithX:farX y:nearY] ofVertex:1];
    [mSurface setTexCoords:[SPPoint pointWithX:nearX y:farY] ofVertex:2];
    [mSurface setTexCoords:[SPPoint pointWithX:farX y:farY] ofVertex:3];
}

- (void)flowXOverTime:(float)duration {
    [self animateProperty:@"flowX" displayObject:self targetValue:mSurface.texture.width / mSurface.width overTime:duration loop:SPLoopTypeRepeat exclusive:NO];
}

- (void)flowYOverTime:(float)duration {
    [self animateProperty:@"flowY" displayObject:self targetValue:mSurface.texture.height / mSurface.height overTime:duration loop:SPLoopTypeRepeat exclusive:NO];
}

- (SPTween *)animateProperty:(NSString *)property
          displayObject:(SPDisplayObject *)displayObject
            targetValue:(float)targetValue
               overTime:(float)duration
                   loop:(SPLoopType)loop
              exclusive:(BOOL)exclusive {
    
    if (exclusive)
        [mScene.juggler removeTweensWithTarget:displayObject];
    
    SPTween *tween = [SPTween tweenWithTarget:displayObject time:duration];
    [tween animateProperty:property targetValue:targetValue];
    tween.loop = loop;
    [mScene.juggler addObject:tween];
    return tween;
}

- (void)timeOfDayChanged:(TimeOfDayChangedEvent *)event {
    if (event.timeOfDay == NewGameTransition) {
        [self setState:WSSTransitionToDay];
    } else if (event.timeOfDay == DawnTransition) {
        [self animateProperty:@"alpha" displayObject:mSurfaceContainer targetValue:1.0f overTime:event.periodDuration loop:SPLoopTypeNone exclusive:YES];
        [self setState:WSSTransitionToDay];
    } else if (event.timeOfDay == SunriseTransition)
        [self animateProperty:@"alpha" displayObject:mSurfaceContainer targetValue:0.6f overTime:event.periodDuration loop:SPLoopTypeNone exclusive:YES];
    else if (event.timeOfDay == NoonTransition)
        [self animateProperty:@"alpha" displayObject:mSurfaceContainer targetValue:1.0f overTime:event.periodDuration loop:SPLoopTypeNone exclusive:YES];
    else if (event.timeOfDay == EveningTransition) {
        [self animateProperty:@"alpha" displayObject:mSurfaceContainer targetValue:0.8f overTime:event.periodDuration loop:SPLoopTypeNone exclusive:YES];
        [self setState:WSSTransitionToNight];
    }
}

- (void)onSurfaceTweenCompleted:(SPEvent *)event {
    switch (mState) {
        case WSSTransitionToNight:
        {
            if (mSurface.alpha < mAlphaMid) {
                // Reduce range between min & max alpha and slow tween rate at night to minimize "flashing".
                float target = 1.1f * mAlphaMid;
                SPTween *tween = [self animateProperty:@"alpha" displayObject:mSurface targetValue:target overTime:2 * mAlphaRate loop:SPLoopTypeReverse exclusive:YES];
                [tween addEventListener:@selector(onSurfaceTweenCompleted:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
                [self setState:WSSNormal];
            }
        }
            break;
        case WSSTransitionToDay:
        {
            // WSSTransitionToNight targets 1.1f * mAlphaMid so that this doesn't pass erroneously.
            if (mSurface.alpha < mAlphaMid) {
                // Restore normal range between min & max and tween rate now that night has passed. 
                float target = mAlphaMax;
                SPTween *tween = [self animateProperty:@"alpha" displayObject:mSurface targetValue:target overTime:mAlphaRate loop:SPLoopTypeReverse exclusive:YES];
                [tween addEventListener:@selector(onSurfaceTweenCompleted:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
                [self setState:WSSNormal];
            }
        }
            break;
        case WSSNormal:
        default:
            break;
    }
}

- (void)dealloc {
    [mScene.juggler removeTweensWithTarget:mSurface];
    [mScene.juggler removeTweensWithTarget:mSurfaceContainer];
	[mSurface release]; mSurface = nil;
    [mSurfaceContainer release]; mSurfaceContainer = nil;
	[super dealloc];
	NSLog(@"Wave dealloc'ed");
}

@end

