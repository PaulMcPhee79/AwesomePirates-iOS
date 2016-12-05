//
//  CCTimer.h
//  Cutlass Cove
//
//  Created by Paul McPhee on 24/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CUST_EVENT_TYPE_CC_TIMER_EXPIRED @"ccTimerExpiredEvent"

@interface CCTimer : SPEventDispatcher {
    BOOL mRunning;
    BOOL mPaused;
    BOOL mCountUp;
    double mTimer;
    double mDuration;
}

@property (nonatomic,assign) BOOL countUp;
@property (nonatomic,readonly) BOOL isPaused;
@property (nonatomic,readonly) BOOL isRunning;
@property (nonatomic,readonly) NSString *timeAsText;

- (void)setDuration:(double)duration;
- (void)start;
- (void)pause;
- (void)resume;
- (void)stop;
- (void)advanceTime:(double)time;

@end
