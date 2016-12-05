//
//  Hint.m
//  Cutlass Cove
//
//  Created by Paul McPhee on 26/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Hint.h"

@implementation Hint

@synthesize target = mTarget;

+ (Hint *)hintWithCategory:(int)category location:(SPPoint *)location target:(SPDisplayObject *)target {
    return [[[Hint alloc] initWithCategory:category location:location target:target] autorelease];
}

+ (Hint *)hintWithCategory:(int)category location:(SPPoint *)location {
    return [Hint hintWithCategory:category location:location target:nil];
}

- (id)initWithCategory:(int)category location:(SPPoint *)location target:(SPDisplayObject *)target {
    if (self = [super initWithCategory:category]) {
        mAdvanceable = YES;
        mTarget = [target retain];
        
        if (target)
            mPrevPos = [[SPPoint alloc] initWithX:target.x y:target.y];
        else
            mPrevPos = [[SPPoint alloc] initWithX:0 y:0];
    }
    
    return  self;
}

- (id)initWithCategory:(int)category location:(SPPoint *)location {
    return [self initWithCategory:category location:location target:nil];
}

- (id)initWithCategory:(int)category {
    return [self initWithCategory:category location:[SPPoint pointWithX:0 y:0]];
}

- (void)dealloc {
    [mPrevPos release]; mPrevPos = nil;
    [mTarget release]; mTarget = nil;
    [super dealloc];
}

- (void)setTarget:(SPDisplayObject *)target {
    if (mTarget != target) {
        [mTarget autorelease];
        mTarget = [target retain];
        mPrevPos.x = mTarget.x; mPrevPos.y = mTarget.y;
    }
}

- (void)advanceTime:(double)time {
    if (mTarget == nil)
        return;
    
    // Maintain our initial distance from the target
    float deltaX = mTarget.x - mPrevPos.x, deltaY = mTarget.y - mPrevPos.y;
    
    self.x += deltaX;
    self.y += deltaY;
    mPrevPos.x = mTarget.x; mPrevPos.y = mTarget.y;
}

@end
