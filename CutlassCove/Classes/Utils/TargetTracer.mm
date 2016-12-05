//
//  TargetTracer.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 12/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TargetTracer.h"
#import "ShipActor.h"


@implementation TargetTracer

@synthesize target = mTarget;
@dynamic targetVel;

- (id)init {
	if (self = [super init]) {
		mTarget = nil;
	}
	return self;
}

- (b2Vec2)targetVel {
	int index = mTargetVelocityIter + 1;
	
	if (index >= kTargetVelBufferSize)
		index -= kTargetVelBufferSize;
	return mTargetVelocity[index];
}

- (void)setTarget:(ShipActor *)target {
	if (target != mTarget) {
		mTargetVelocityIter = 0;
		[mTarget release];
		mTarget = nil;
		mTarget = [target retain];
	}
}

- (void)advanceTime:(double)time {
	if (mTarget != nil && mTarget.body != 0) {
		mTargetVelocity[mTargetVelocityIter] = mTarget.body->GetLinearVelocity();
		
		if (++mTargetVelocityIter == kTargetVelBufferSize)
			mTargetVelocityIter = 0;
	}
}

- (void)dealloc {
	[mTarget release]; mTarget = nil;
	[super dealloc];
}

@end
