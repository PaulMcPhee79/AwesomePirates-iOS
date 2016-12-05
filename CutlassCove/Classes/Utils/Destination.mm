//
//  Destination.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 16/10/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "Destination.h"


@implementation Destination

@synthesize isExclusive = mIsExclusive;
@synthesize finishIsDest = mFinishIsDest;
@synthesize spawnPlaneIndex = mSpawnPlaneIndex;
@synthesize loc = mLoc;
@synthesize dest = mDest;
@synthesize seaLaneA = mSeaLaneA;
@synthesize seaLaneB = mSeaLaneB;
@synthesize seaLaneC = mSeaLaneC;
@synthesize adjustedSeaLaneC = mAdjustedSeaLaneC;
@synthesize start = mStart;
@synthesize finish = mFinish;

- (id)init {
	if (self = [super init]) {
		mIsExclusive = YES;
		mFinishIsDest = NO;
		mSeaLaneA = nil;
		mSeaLaneB = nil;
		mSeaLaneC = nil;
		mAdjustedSeaLaneC = nil;
	}
	return self;
}

- (void)dealloc {
	[mAdjustedSeaLaneC release]; mAdjustedSeaLaneC = nil;
	[super dealloc];
}

- (void)setSeaLaneA:(SPPoint *)point {
	mSeaLaneA = point;
	
	if (point != nil) {
		mLoc.x = point.x;
		mLoc.y = point.y;
	}
}

- (void)setSeaLaneB:(SPPoint *)point {
	mSeaLaneB = point;
	
	if (point != nil) {
		mDest.x = point.x;
		mDest.y = point.y;
	}
}

- (void)setSeaLaneC:(SPPoint *)point {
	mSeaLaneC = point;
	
	if (point != nil) {
		if (mAdjustedSeaLaneC != nil) {
			mDest.x = mAdjustedSeaLaneC.x;
			mDest.y = mAdjustedSeaLaneC.y;
		} else {
			mDest.x = point.x;
			mDest.y = point.y;
		}
	}
}

- (void)setFinishAsDest {
	mDest.x = mSeaLaneB.x;
	mDest.y = mSeaLaneB.y;
	self.seaLaneC = nil; // Mark edge case as handled.
	mFinishIsDest = YES;
}

- (void)setDestX:(float)x { mDest.x = x; }
- (void)setDestY:(float)y { mDest.y = y; }
- (void)setLocX:(float)x { mLoc.x = x; }
- (void)setLocY:(float)y { mLoc.y = y; }

+ (Destination *)destinationWithDestination:(Destination *)destination {
	Destination *dest = [[[Destination alloc] init] autorelease];
	dest.isExclusive = destination.isExclusive;
	dest.spawnPlaneIndex = destination.spawnPlaneIndex;
	
	//b2Vec2 temp = destination.loc;
	//dest.loc = temp;
	//temp = destination.dest;
	//dest.dest = temp;
	dest.adjustedSeaLaneC = destination.adjustedSeaLaneC;
	dest.seaLaneA = destination.seaLaneA;
	dest.seaLaneB = destination.seaLaneB;
	dest.seaLaneC = destination.seaLaneC;
		
	dest.start = destination.start;
	dest.finish = destination.finish;
	return dest;
}

@end
