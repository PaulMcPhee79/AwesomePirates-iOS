//
//  Weather.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 20/10/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

typedef enum {
	WeatherStateNull = 0,
	WeatherStateClear,
	WeatherStateClearing,
	WeatherStateCloudy,
	WeatherStateOvercast
} WeatherState;

@interface Weather : Prop {
    BOOL mWeatherEnabled;
	BOOL mCycleComplete;
	WeatherState mState;
    double mCycleTimer;
	double mCloudSpawnTimer;
	double mWeatherStateTimer;
	uint mMaxClouds;
	uint mCloudDensity;
	float mWindVelX;
	float mWindVelY;
	float mCloudAlpha;
	NSMutableArray *mClouds;
}

@property (nonatomic,assign) BOOL enabled;
@property (nonatomic,assign) float cloudAlpha;

+ (Weather *)weatherWithCategory:(int)category cloudCount:(uint)cloudCount;
- (id)initWithCategory:(int)category cloudCount:(uint)cloudCount;
- (void)beginCycle:(double)duration;
- (void)advanceTime:(double)time;
- (void)clearUpSky;

@end
