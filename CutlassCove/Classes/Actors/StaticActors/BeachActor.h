//
//  BeachActor.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 5/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StaticActor.h"

#define CUST_EVENT_TYPE_PLAYER_ENTERED_COVE @"playerEnteredCoveEvent"
#define CUST_EVENT_TYPE_COVE_OPENED @"coveOpenedEvent"
#define CUST_EVENT_TYPE_COVE_CLOSED @"coveClosedEvent"

typedef enum {
	BeachStateNull = 0,
	BeachStateClosing,
	BeachStateClosed,
	BeachStateOpen,
	BeachStateDeparting
} BeachState;

@class NightShade,Prop;

@interface BeachActor : StaticActor {
	BOOL mCoveEnabled;
	BeachState mState;
	b2Fixture *mCoveGate;
	b2Fixture *mDepartSensor;
	b2Fixture *mCoveSensor;
	SPImage *mCoveImage;
	SPImage *mCoveFutureImage;
	Prop *mCoveProp;
	SPSprite *mTorch;
	NSMutableArray *mArrivals;
	NightShade *mNightShade;
}

@property (nonatomic,assign) BeachState state;
@property (nonatomic,assign) BOOL coveEnabled;

- (void)setupBeach;
- (void)setHidden:(BOOL)hidden;
- (void)openCove;
- (void)closeCove;
- (void)travelBackInTime:(float)duration;
- (void)travelForwardInTime:(float)duration;
- (void)debugToggle;

@end
