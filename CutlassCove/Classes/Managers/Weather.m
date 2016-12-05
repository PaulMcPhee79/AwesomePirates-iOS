//
//  Weather.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 20/10/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "Weather.h"
#import "Cloud.h"
#import "TimeKeeper.h"
#import "SceneController.h"
#import "GameController.h"
#import "Globals.h"

const int kDefaultCloudCount = 1;
const float kCloudShadowOffsetMax = 40.0f;

@interface Weather ()

- (void)setCycleComplete;
- (void)setState:(WeatherState)state;
- (void)thinkWeather;
- (void)spawnCloud;

@end


@implementation Weather

@synthesize enabled = mWeatherEnabled;
@synthesize cloudAlpha = mCloudAlpha;

+ (Weather *)weatherWithCategory:(int)category cloudCount:(uint)cloudCount {
	return [[[Weather alloc] initWithCategory:category cloudCount:cloudCount] autorelease];
}

- (id)initWithCategory:(int)category cloudCount:(uint)cloudCount {
	if (self = [super initWithCategory:category]) {
        mWeatherEnabled = YES;
		mCloudSpawnTimer = 0;
		mMaxClouds = cloudCount;
		mCloudAlpha = 1.0f;
		mClouds = [[NSMutableArray arrayWithCapacity:mMaxClouds] retain];
		[self setState:WeatherStateClear];
		[self setState:RANDOM_INT((int)WeatherStateCloudy,(int)WeatherStateOvercast)];
	}
	return self;
}

- (void)beginCycle:(double)duration {
	if (mCycleComplete == NO)
		[mScene.juggler removeTweensWithTarget:self];
	mCycleComplete = NO;
    mCycleTimer = duration;
}

- (void)setCycleComplete {
	mCycleComplete = YES;
}

- (void)setState:(WeatherState)state {
	double duration = 0.0;
    GameController *gc = GCTRL;
	
	switch (state) {
		case WeatherStateNull:
			break;
		case WeatherStateClear:
		{
			// The only state in which we can safely change the wind's direction without it looking unnatural
			[mClouds removeAllObjects];	
			
			float randVel = RANDOM_INT(3,5) / (10.0f / gc.fpsFactor);
			mWindVelX = ((RANDOM_INT(0,1)) ? randVel: -randVel) * gc.fps;
			randVel = RANDOM_INT(3,5) / (10.0f / gc.fpsFactor);
			mWindVelY = ((RANDOM_INT(0,1)) ? randVel: -randVel) * gc.fps;
			duration = 40.0;
			break;
		}
		case WeatherStateClearing:
			break;
		case WeatherStateCloudy:
			if (mClouds == nil)
				mClouds = [[NSMutableArray arrayWithCapacity:mMaxClouds] retain];
			mCloudDensity = MAX(1,mMaxClouds / 2);
			duration = 180.0;
			break;
		case WeatherStateOvercast:
			if (mClouds == nil)
				mClouds = [[NSMutableArray arrayWithCapacity:mMaxClouds] retain];
			mCloudDensity = mMaxClouds;
			duration = 180.0;
			break;
		default:
			assert(0);
			break;
	}
	mState = state;
	
	if (state != WeatherStateClearing)
		[self beginCycle:duration + RANDOM_INT(0,60)]; // Add some randomness to cycle durations
	
	//NSLog(@"Weather Changed to State: %d", state);
}

- (void)thinkWeather {
	if (mClouds.count == 0 && mState == WeatherStateClearing) {
		[self setState:WeatherStateClear];
	} else if (mState >= WeatherStateCloudy && mClouds.count < mCloudDensity) {
		[self spawnCloud];
	}
	
	if (mCycleComplete == YES && mState != WeatherStateClearing) {
		int rndState = RANDOM_INT((int)WeatherStateClearing, (int)WeatherStateOvercast);
		
		if (rndState == mState) {
			if (rndState < WeatherStateOvercast)
				++rndState;
			else
				--rndState;
		}
		[self setState:rndState];
	}
}

- (void)spawnCloud {
	if (mClouds.count >= mMaxClouds || mCloudSpawnTimer > 0 || mWeatherEnabled == NO)
		return;
	TimeKeeper *timeKeeper = [GameController GC].timeKeeper;
	Cloud *cloud = [Cloud cloudWithCloudType:[Cloud randomCloudType] velX:mWindVelX velY:mWindVelY alpha:mCloudAlpha];
	cloud.shadowOffsetX = timeKeeper.shadowOffsetX * kCloudShadowOffsetMax;
	cloud.shadowOffsetY = timeKeeper.shadowOffsetY * kCloudShadowOffsetMax;
	[cloud setupProp];
	[mClouds addObject:cloud];
	mCloudSpawnTimer = RANDOM_INT(2, 10); // Distribute clouds between 2 and 8 seconds apart.
}

- (void)clearUpSky {
	if (mState != WeatherStateClearing)
		[self setState:WeatherStateClearing];
}

- (void)advanceTime:(double)time {
	TimeKeeper *timeKeeper = GCTRL.timeKeeper;
    
    if (mCycleTimer > 0.0) {
        mCycleTimer -= time;
        
        if (mCycleTimer <= 0.0)
            [self setCycleComplete];
    }
	
	for (int i = mClouds.count - 1; i >= 0; --i) {
		Cloud *cloud = (Cloud *)[mClouds objectAtIndex:i];
		cloud.shadowOffsetX = timeKeeper.shadowOffsetX * kCloudShadowOffsetMax;
		cloud.shadowOffsetY = timeKeeper.shadowOffsetY * kCloudShadowOffsetMax;
		[cloud advanceTime:time];
		
		if ([cloud isBlownOffscreen])
			[mClouds removeObjectAtIndex:i];
	}
	
	[self thinkWeather];
	
	if (mCloudSpawnTimer > 0)
		mCloudSpawnTimer -= time;
}

- (void)dealloc {
	[mClouds release]; mClouds = nil;
	[super dealloc];
}

@end
