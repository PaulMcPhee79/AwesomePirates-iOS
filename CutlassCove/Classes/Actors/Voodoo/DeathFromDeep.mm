//
//  DeathFromDeep.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 17/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DeathFromDeep.h"
#import "NpcShip.h"
#import "TreasureFleet.h"
#import "PlayerDetails.h"
#import "AchievementManager.h"
#import "Globals.h"

#define CUST_EVENT_TYPE_TARGET_SUNK @"targetSunkEvent"

typedef enum {
	DeathFromDeepStateIdle = 0,
	DeathFromDeepStateEmerging,
	DeathFromDeepStateSubmerging,
	DeathFromDeepStateDying,
	DeathFromDeepStateDead
} DeathFromDeepState;

@interface DeathFromDeep ()

- (void)setState:(int)state;
- (void)grabTarget;
- (void)submergeTarget;
- (void)onTargetGrabbed:(SPEvent *)event;
- (void)onTargetSubmerged:(SPEvent *)event;

@end


@implementation DeathFromDeep

@synthesize target = mTarget;

- (id)initWithCategory:(int)category duration:(float)duration {
	if (self = [super initWithCategory:CAT_PF_POINT_MOVIES]) {
		mAdvanceable = YES;
		mDuration = (double)duration;
		mSubmergedDelay = -1;
		[self setupProp];
		[self setState:DeathFromDeepStateIdle];
	}
	return self;
}

- (void)setupProp {
    SPSprite *clipScaler = [SPSprite sprite];
    clipScaler.scaleX = clipScaler.scaleY = 1.35f;
    [self addChild:clipScaler];
    
	mEmergeClip = [[SPMovieClip alloc] initWithFrames:[mScene texturesStartingWith:@"death-grip-emerge_"] fps:8];
	[mEmergeClip setDuration:0.25f atIndex:mEmergeClip.numFrames-1];
	mEmergeClip.x = -mEmergeClip.width / 2;
	mEmergeClip.y = -mEmergeClip.height / 2;
	mEmergeClip.loop = NO;
	[mEmergeClip pause];
	[mScene.juggler addObject:mEmergeClip];
	[clipScaler addChild:mEmergeClip];
	
	mSubmergeClip = [[SPMovieClip alloc] initWithFrames:[mScene texturesStartingWith:@"death-grip-submerge_"] fps:8];
	[mSubmergeClip setDuration:0.25f atIndex:0];
	[mSubmergeClip setDuration:0.5f atIndex:mSubmergeClip.numFrames-1];
	mSubmergeClip.x = -mSubmergeClip.width / 2;
	mSubmergeClip.y = -mSubmergeClip.height / 2;
	mSubmergeClip.loop = NO;
	[mSubmergeClip pause];
	[mScene.juggler addObject:mSubmergeClip];
	[clipScaler addChild:mSubmergeClip];
	
	[mEmergeClip addEventListener:@selector(onTargetGrabbed:) atObject:self forType:SP_EVENT_TYPE_MOVIE_COMPLETED];
	[mSubmergeClip addEventListener:@selector(onTargetSubmerged:) atObject:self forType:SP_EVENT_TYPE_MOVIE_COMPLETED];
    
    if (mScene.flipped)
        self.scaleX = -1;
}

- (void)setState:(int)state {
	switch (state) {
		case DeathFromDeepStateIdle:
			self.visible = NO;
			self.target = nil;
			break;
		case DeathFromDeepStateEmerging:
			self.visible = YES;
			[mSubmergeClip pause];
			mSubmergeClip.visible = NO;
			
			mEmergeClip.currentFrame = 0;
			[mEmergeClip play];
			mEmergeClip.visible = YES;
			break;
		case DeathFromDeepStateSubmerging:
			self.visible = YES;
			[mEmergeClip pause];
			mEmergeClip.visible = NO;
			
			mSubmergeClip.alpha = 1;
			mSubmergeClip.currentFrame = 0;
			[mSubmergeClip play];
			mSubmergeClip.visible = YES;
			break;
		case DeathFromDeepStateDying:
			break;
		case DeathFromDeepStateDead:
			self.visible = NO;
			self.target = nil;
            
            if (self.turnID == GCTRL.thisTurn.turnID)
                [mScene.objectivesManager progressObjectiveWithEventType:OBJ_TYPE_VOODOO_GADGET_EXPIRED tag:VOODOO_SPELL_DEATH_FROM_DEEP];
			[[self retain] autorelease];
			[self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_DEATH_FROM_DEEP_DISMISSED]];
			break;
	}
	mState = state;
}

- (void)setTarget:(NpcShip *)ship {
	if (mTarget == ship)
		return;
	if (mTarget != nil) {
		[mTarget removePursuer:self];
		[mTarget release]; mTarget = nil;
	}
	
	if (ship != nil) {
		mTarget = [ship retain];
		[mTarget addPursuer:self];
	}
}

- (void)flip:(BOOL)enable {
    self.scaleX = (enable) ? -1 : 1;
}

- (void)pursueeDestroyed:(ShipActor *)pursuee {
    assert(pursuee == self.target);
    self.target = nil;
}

- (void)advanceTime:(double)time {
    if (mDuration > 0.0) {
        mDuration -= time;
        
        if (mDuration <= 0.0)
            [self despawn];
    }
    
	if (mState != DeathFromDeepStateIdle)
		return;
	if (mSubmergedDelay >= 0)
		mSubmergedDelay -= time;
	if (mSubmergedDelay < 0) {
		if (mTarget == nil)
            [mScene requestTargetForPursuer:(NSObject *)self];
		if (mTarget != nil)
			[self grabTarget];
	}
}

- (void)despawn {
	if (mState == DeathFromDeepStateDead)
		return;
	else if (mState == DeathFromDeepStateIdle)
		[self setState:DeathFromDeepStateDead];
	else
		[self setState:DeathFromDeepStateDying];
}

- (void)grabTarget {
	assert(mTarget != nil);
	
	if (mState != DeathFromDeepStateIdle)
		return;
	mTarget.inDeathsHands = YES;
	self.x = mTarget.x;
	self.y = mTarget.y;
	[mScene.audioPlayer playSoundWithKey:@"DeathFromTheDeep" volume:0.425f];
	[self setState:DeathFromDeepStateEmerging];
}

- (void)submergeTarget {
	int oldState = mState;
	[self setState:DeathFromDeepStateSubmerging];
	
	float duration = [mSubmergeClip durationAtIndex:mSubmergeClip.numFrames-1];
	SPTween *tween = [SPTween tweenWithTarget:mSubmergeClip time:duration];
	[tween animateProperty:@"alpha" targetValue:0.01f];
	tween.delay = mSubmergeClip.duration - duration;
	[mScene.juggler addObject:tween];
	
	if (oldState != DeathFromDeepStateEmerging)
		[self setState:oldState];
}

- (void)onTargetGrabbed:(SPEvent *)event {
	mTarget.deathBitmap = DEATH_BITMAP_DEATH_FROM_THE_DEEP;
	mTarget.visible = NO;
    [mTarget sink]; // Will destroy our pursuee, making mTarget nil
	[self submergeTarget];
}

- (void)onTargetSubmerged:(SPEvent *)event {
    //if (mScene.enhancements.depthsOfDespair && RANDOM_INT(0, 1))
    //    [GCTRL.playerDetails addMutiny:-1];
    
	if (mState == DeathFromDeepStateSubmerging)
		[self setState:DeathFromDeepStateIdle];
	else if (mState == DeathFromDeepStateDying)
		[self setState:DeathFromDeepStateDead];
	mSubmergedDelay = 2.7f - (mEmergeClip.duration + mSubmergeClip.duration); // 2.7f is the duration of the sound effect.
}

- (void)dealloc {
	[mEmergeClip removeEventListener:@selector(onTargetGrabbed:) atObject:self forType:SP_EVENT_TYPE_MOVIE_COMPLETED];
	[mSubmergeClip removeEventListener:@selector(onTargetSubmerged:) atObject:self forType:SP_EVENT_TYPE_MOVIE_COMPLETED];
	
	[mScene.juggler removeObject:mEmergeClip];
	[mScene.juggler removeObject:mSubmergeClip];
	[mScene.juggler removeTweensWithTarget:mSubmergeClip];
	
	[mEmergeClip release]; mEmergeClip = nil;
	[mSubmergeClip release]; mSubmergeClip = nil;
	[super dealloc];
}

@end
