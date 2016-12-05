//
//  TimeKeeper.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 10/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TimeOfDayChangedEvent.h"

#define DAY_CYCLE_IN_SEC 150
#define DAY_CYCLE_IN_MIN 2.5

@interface TimeKeeper : SPEventDispatcher {
	BOOL mTimerActive;
	BOOL mTransitions;
    BOOL mDayShouldIncrease;
	uint mDay;
	TimeOfDay mTimeOfDay;
	float mPeriodDuration;
	float mPeriodModifier;
	float mTimePassed;
    float mTimePassedToday;
	float mTransitionDuration;
    
	float mShadowOffsetX;
	float mShadowOffsetY;
    float mPrevShadowOffsetX;
	float mPrevShadowOffsetY;
    
	double mTimeDelta;
    
    @private
    NSArray *mDayIntros;
}

@property (nonatomic,assign) BOOL timerActive;
@property (nonatomic,assign) BOOL transitions;
@property (nonatomic,assign) BOOL dayShouldIncrease;
@property (nonatomic,assign) uint day;
@property (nonatomic,assign) TimeOfDay timeOfDay;
@property (nonatomic,readonly) float periodDuration;
@property (nonatomic,assign) float periodModifier;
@property (nonatomic,readonly) float timePassed;
@property (nonatomic,readonly) float timeRemaining;
@property (nonatomic,readonly) float proportionPassed;
@property (nonatomic,readonly) float proportionRemaining;
@property (nonatomic,readonly) float shadowOffsetX;
@property (nonatomic,readonly) float shadowOffsetY;
@property (nonatomic,readonly) uint waterColor;
@property (nonatomic,readonly) float timePassedToday;
@property (nonatomic,readonly) float timeRemainingToday;

- (id)initWithTimeOfDay:(TimeOfDay)timeOfDay timePassed:(float)seconds;
- (void)setTimeOfDay:(TimeOfDay)timeOfDay timePassed:(float)seconds;
- (NSString *)introForDay:(uint)day;
- (void)advanceTime:(double)time;
- (void)reset;
+ (float)timePerDay;
+ (float)durationForPeriod:(TimeOfDay)period;
+ (BOOL)doesTimePeriodTransition:(TimeOfDay)period;
+ (NSDictionary *)settingsForPeriod:(TimeOfDay)period;
+ (uint)maxDay;

@end
