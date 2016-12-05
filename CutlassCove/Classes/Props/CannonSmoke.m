//
//  CannonSmoke.m
//  Pirates
//
//  Created by Paul McPhee on 19/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "CannonSmoke.h"
#import "Globals.h"


@interface CannonSmoke ()

- (void)onBurstClipCompleted:(SPEvent *)event;
- (void)onSmokeClipCompleted:(SPEvent *)event;

@end


@implementation CannonSmoke

- (id)initWithX:(float)x y:(float)y {
	if (self = [super initWithCategory:-1]) {
		self.x = x;
		self.y = y;
        [self setupProp];        
    }
    return self;
}

- (id)init {
    return [self initWithX:0.0f y:0.0f];
}

- (void)setupProp {
	mBurst = [[SPMovieClip alloc] initWithFrames:[mScene texturesStartingWith:@"cannon-burst-smoke_"] fps:12];
	mBurst.x = -mBurst.width / 2;
	mBurst.y = -mBurst.height / 2;
	mBurst.loop = NO;
	
	mBurstFrame = [[SPSprite alloc] init];
	mBurstFrame.x = mBurst.width / 2;
	[mBurstFrame addChild:mBurst];
	[self addChild:mBurstFrame];
	[mBurst addEventListener:@selector(onBurstClipCompleted:) atObject:self forType:SP_EVENT_TYPE_MOVIE_COMPLETED];
	
	mSmoke = [[SPMovieClip alloc] initWithFrames:[mScene texturesStartingWith:@"cannon-smoke_"] fps:12];
	mSmoke.x = -mSmoke.width / 2;
	mSmoke.y = -mSmoke.height / 2;
	mSmoke.loop = NO;
	
	mSmokeFrame = [[SPSprite alloc] init];
	mSmokeFrame.x = mSmoke.width / 2;
	[mSmokeFrame addChild:mSmoke];
	[self addChild:mSmokeFrame];
	[mSmoke addEventListener:@selector(onSmokeClipCompleted:) atObject:self forType:SP_EVENT_TYPE_MOVIE_COMPLETED];
	
	mBurstFrame.visible = NO;
	mSmokeFrame.visible = NO;
}

- (void)startWithAngle:(float)angle {
	mSmokeFrame.rotation = -angle; // Keep smoke floating skyward
	mSmokeFrame.visible = NO;
	mBurstFrame.visible = YES;
	mBurst.currentFrame = 0;
	[mBurst play];
	[mScene.juggler addObject:mBurst];
}

- (void)onBurstClipCompleted:(SPEvent *)event {
	[mScene.juggler removeObject:mBurst];
	
	mBurstFrame.visible = NO;
	mSmokeFrame.visible = YES;
	mSmoke.y = -mSmoke.height / 2;
	mSmoke.alpha = 1;
	mSmoke.currentFrame = 0;
	[mSmoke play];
	[mScene.juggler addObject:mSmoke];
	
	SPTween *tween = [SPTween tweenWithTarget:mSmoke time:mSmoke.duration];
	[tween animateProperty:@"alpha" targetValue:0];
	[tween animateProperty:@"y" targetValue:mSmoke.y-mSmoke.height / 2];
	[mScene.juggler addObject:tween];
}

- (void)onSmokeClipCompleted:(SPEvent *)event {
	[mScene.juggler removeObject:mSmoke];
	mBurstFrame.visible = NO;
	mSmokeFrame.visible = NO;
	
	//ElementExpiredEvent *expiredEvent = [[ElementExpiredEvent alloc] initWithType:CUST_EVENT_TYPE_ELEMENT_EXPIRED element:self bubbles:NO];
	//[self dispatchEvent:expiredEvent];
	//[expiredEvent release];
}

- (void)dealloc {
	[mBurst removeEventListener:@selector(onBurstClipCompleted:) atObject:self forType:SP_EVENT_TYPE_MOVIE_COMPLETED];
	[mSmoke removeEventListener:@selector(onSmokeClipCompleted:) atObject:self forType:SP_EVENT_TYPE_MOVIE_COMPLETED];
	[mScene.juggler removeTweensWithTarget:mSmoke];
	[mScene.juggler removeObject:mBurst];
	[mScene.juggler removeObject:mSmoke];
	[mBurst release]; mBurst = nil;
	[mBurstFrame release]; mBurstFrame = nil;
	[mSmoke release]; mSmoke = nil;
	[mSmokeFrame release]; mSmokeFrame = nil;
    [super dealloc];
}

@end

