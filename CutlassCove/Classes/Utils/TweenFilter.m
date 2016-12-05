//
//  TweenFilter.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 25/08/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "TweenFilter.h"


@implementation TweenFilter

@synthesize x = mX;
@synthesize y = mY;
@synthesize rotation = mRotation;
@synthesize target = mTarget;

- (id)initWithTarget:(SPDisplayObject *)target {
	if (self = [super init]) {
		mX = 0;
		mY = 0;
		mRotation = 0;
		mScaleFactor = MAX(1, [SPStage contentScaleFactor]);
		mTarget = [target retain];
	}
	return self;
}

- (id)init {
	assert(0);
	return nil;
}

- (void)setX:(float)value {
	int scaledValue = (int)(value * mScaleFactor);
	int scaledX = (int)(mX * mScaleFactor);
	
	if (scaledValue != scaledX)
		mTarget.x = scaledValue / mScaleFactor;
	mX = value;
}

- (void)setY:(float)value {
	int scaledValue = (int)(value * mScaleFactor);
	int scaledY = (int)(mY * mScaleFactor);
	
	if (scaledValue != scaledY)
		mTarget.y = scaledValue / mScaleFactor;
	mY = value;
}

- (void)setRotation:(float)value {
	int scaledValue = (int)(value * mScaleFactor);
	int scaledRotation = (int)(mRotation * mScaleFactor);
	
	if (scaledValue != scaledRotation)
		mTarget.rotation = scaledValue / mScaleFactor;
	mRotation = value;
}

- (void)dealloc {
	[mTarget release]; mTarget = nil;
	[super dealloc];
}

@end
