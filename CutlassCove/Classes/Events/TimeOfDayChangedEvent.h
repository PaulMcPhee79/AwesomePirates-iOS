//
//  TimeOfDayChangedEvent.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 11/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CUST_EVENT_TYPE_TIME_OF_DAY_CHANGED @"timeOfDayChangedEvent"

typedef enum {
	NewGameTransition = 0,
	SunriseTransition,
	Sunrise,
    NoonTransition,
	Noon,
	Afternoon,
	SunsetTransition,
	Sunset,
	DuskTransition,
	Dusk,
	EveningTransition,
    Evening,
	Midnight,
    DawnTransition,
    Dawn
} TimeOfDay;

typedef struct {
	uint day;
	TimeOfDay timeOfDay;
	BOOL transitions;
	float timePassed;
	float periodDuration;
} TimeStruct;

@interface TimeOfDayChangedEvent : SPEvent {
	TimeStruct mTimeState;
}

@property (nonatomic,readonly) uint day;
@property (nonatomic,readonly) TimeOfDay timeOfDay;
@property (nonatomic,readonly) BOOL transitions;
@property (nonatomic,readonly) float periodDuration;
@property (nonatomic,readonly) float timePassed;
@property (nonatomic,readonly) float timeRemaining;
@property (nonatomic,readonly) float proportionPassed;
@property (nonatomic,readonly) float proportionRemaining;

- (id)initWithType:(NSString *)type timeState:(TimeStruct)timeState bubbles:(BOOL)bubbles;

@end
