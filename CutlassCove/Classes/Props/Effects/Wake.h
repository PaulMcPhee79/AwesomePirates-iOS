//
//  Wake.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 13/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

typedef enum {
	WakeStateIdle = 0,
	WakeStateActive,
	WakeStateDying,
	WakeStateDead
} WakeState;

@class RingBuffer,SceneController;

@interface Wake : Prop {
	WakeState mState;
    int mResourcePoolIndex;
	int mNumRipples;
	double mRipplePeriod;
	
	RingBuffer *mRipples;
	NSMutableArray *mVisibleRipples;
}

@property (nonatomic,assign) double ripplePeriod;

- (id)initWithCategory:(int)category numRipples:(int)count;
- (void)nextRippleAtX:(float)x y:(float)y rotation:(float)rotation;
- (void)safeDestroy;
+ (int)defaultWakeBufferSize;
+ (int)maxWakeBufferSize;
+ (double)defaultWakePeriod;
+ (double)defaultRipplePeriod;
+ (double)minRipplePeriod;
+ (double)maxRipplePeriod;

@end
