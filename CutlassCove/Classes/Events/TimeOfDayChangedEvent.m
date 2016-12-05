//
//  TimeOfDayChangedEvent.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 11/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "TimeOfDayChangedEvent.h"
#import "TimeKeeper.h"

@implementation TimeOfDayChangedEvent

@dynamic day,timeOfDay,transitions,periodDuration,timePassed,timeRemaining,proportionPassed,proportionRemaining;

- (id)initWithType:(NSString *)type timeState:(TimeStruct)timeState bubbles:(BOOL)bubbles {
	if (self = [super initWithType:type bubbles:bubbles]) {
		mTimeState = timeState;
	}
	return self;
}

- (uint)day {
	return mTimeState.day;
}

- (TimeOfDay)timeOfDay {
	return mTimeState.timeOfDay;
}

- (BOOL)transitions {
	return mTimeState.transitions;
}

- (float)periodDuration {
	return mTimeState.periodDuration;
}

- (float)timePassed {
	return mTimeState.timePassed;
}

- (float)timeRemaining {
	return MAX(0.0f,mTimeState.periodDuration - mTimeState.timePassed);
}

- (float)proportionPassed {
	assert(mTimeState.periodDuration);
	return mTimeState.timePassed / mTimeState.periodDuration;
}

- (float)proportionRemaining {
	assert(mTimeState.periodDuration);
	return self.timeRemaining / mTimeState.periodDuration;
}

@end
