//
//  CCTimer.m
//  Cutlass Cove
//
//  Created by Paul McPhee on 24/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CCTimer.h"
#import "math.h"

@implementation CCTimer

@synthesize countUp = mCountUp;
@synthesize isRunning = mRunning;
@dynamic isPaused,timeAsText;

- (id)initWithCategory:(int)category {
    if (self = [super init]) {
        mRunning = YES;
        mPaused = NO;
        mCountUp = NO;
        mTimer = 0;
    }
    return self;
}

- (BOOL)isPaused {
    return (mRunning && mPaused);
}

- (NSString *)timeAsText {
    NSString *text = nil;
    
    if (mCountUp)
        text = [NSString stringWithFormat:@"%d:%02d",(int)mTimer / 60, (int)mTimer % 60];
    else
        text = [NSString stringWithFormat:@"%d:%02d", (int)ceil(mTimer) / 60, (int)ceil(mTimer) % 60];
    
    return text;
}

- (void)setDuration:(double)duration {
    mDuration = duration;
}

- (void)start {
    if (mRunning && mPaused) {
        mPaused = NO;
    } else {
        mTimer = (mCountUp) ? 0 : mDuration;
        mPaused = NO;
        mRunning = YES;
    }
}

- (void)pause {
    mPaused = YES;
}

- (void)resume {
    mPaused = NO;
}

- (void)stop {
    mPaused = NO;
    mRunning = NO;
}

- (void)advanceTime:(double)time {
    if (mRunning == NO || mPaused == YES)
        return;
    if (mCountUp) {
        mTimer += time;
        
        if (mTimer >= mDuration) {
            [self stop];
            [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_CC_TIMER_EXPIRED]];
        }
    } else {
        mTimer -= time;
        
        if (mTimer <= 0) {
            [self stop];
            [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_CC_TIMER_EXPIRED]];
        }
    }
}

@end
