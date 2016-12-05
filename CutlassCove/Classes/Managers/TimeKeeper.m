//
//  TimeKeeper.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 10/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "TimeKeeper.h"
#import "CCValidator.h"
#import "Globals.h"

const double kTickInterval = 0.1;
const NSString *kDurationKey = @"duration";
const NSString *kTransitionsKey = @"transitions";
const uint kWaterColors[14] = {
    4946120, 4946120, 6413567, 6413567, 1029351, 1029351, 1029351,
    2718681, 2718681, 4946120, 4946120, 3486351, 3486351, 3486351
};

static NSArray *timeSettings = nil;

@interface TimeKeeper ()

- (void)applyTimeOfDayChangeWithTimePassed:(float)seconds;
- (void)broadcastTimeOfDayChange;
- (void)updateShadowOffset;

@end


@implementation TimeKeeper

@synthesize timerActive = mTimerActive;
@synthesize transitions = mTransitions;
@synthesize dayShouldIncrease = mDayShouldIncrease;
@synthesize day = mDay;
@synthesize timeOfDay = mTimeOfDay;
@synthesize periodDuration = mPeriodDuration;
@synthesize periodModifier = mPeriodModifier;
@synthesize timePassed = mTimePassed;
@synthesize timePassedToday = mTimePassedToday;
@synthesize shadowOffsetX = mShadowOffsetX;
@synthesize shadowOffsetY = mShadowOffsetY;
@dynamic timeRemaining,proportionPassed,proportionRemaining,waterColor;

+ (NSArray *)loadTimeSettings {
	if (timeSettings == nil)
		timeSettings = [[Globals loadPlistArray:@"TimeSettings"] retain];
	return timeSettings;
}

+ (float)timePerDay {
    return DAY_CYCLE_IN_SEC;
}

+ (float)durationForPeriod:(TimeOfDay)period {
	if (timeSettings == nil)
		[TimeKeeper loadTimeSettings];
	
	float time = 0.0f;
	
	if (period >= NewGameTransition && period <= Dawn) {
		NSDictionary *settings = [TimeKeeper settingsForPeriod:period];
		time = [(NSNumber *)[settings objectForKey:kDurationKey] floatValue];
	}
	return time;
}

+ (BOOL)doesTimePeriodTransition:(TimeOfDay)period {
    if (timeSettings == nil)
		[TimeKeeper loadTimeSettings];
    
    BOOL transitions = NO;
    
    if (period >= NewGameTransition && period <= Dawn) {
        NSDictionary *settings = [TimeKeeper settingsForPeriod:period];
        transitions = [(NSNumber *)[settings objectForKey:kTransitionsKey] boolValue];
    }
    return transitions;
}

+ (NSDictionary *)settingsForPeriod:(TimeOfDay)period {
	if (timeSettings == nil)
		[TimeKeeper loadTimeSettings];
	return (NSDictionary *)[timeSettings objectAtIndex:period % (Dawn + 1)];
}

+ (uint)maxDay {
    return 7;
}

- (id)initWithTimeOfDay:(TimeOfDay)timeOfDay timePassed:(float)seconds {
	if (self = [super init]) {
		if (timeSettings == nil)
			[TimeKeeper loadTimeSettings];
        
        BOOL isValid = [CCValidator isDataValidForArray:timeSettings validators:[NSArray arrayWithObjects:
                                                                                 [NSNumber numberWithInt:4000],
                                                                                 [NSNumber numberWithInt:10000],
                                                                                 [NSNumber numberWithInt:9000],
                                                                                 [NSNumber numberWithInt:10000],
                                                                                 [NSNumber numberWithInt:15000],
                                                                                 [NSNumber numberWithInt:15000],
                                                                                 [NSNumber numberWithInt:10000],
                                                                                 [NSNumber numberWithInt:9000],
                                                                                 [NSNumber numberWithInt:10000],
                                                                                 [NSNumber numberWithInt:9000],
                                                                                 [NSNumber numberWithInt:10000],
                                                                                 [NSNumber numberWithInt:15000],
                                                                                 [NSNumber numberWithInt:15000],
                                                                                 [NSNumber numberWithInt:10000],
                                                                                 [NSNumber numberWithInt:9000],
                                                                                 nil]];
        
        if (isValid == NO)
            [CCValidator reportInvalidData];
        
        mDayIntros = [[NSArray alloc] initWithObjects:
                      @"Calm Waters",
                      @"Contested Seas",
                      @"All Hands on Deck",
                      @"Ricochet or Die",
                      @"Dire Straits",
                      @"Shiver Me Timbers!",
                      @"Montgomery's Mutiny",
                      nil];

		mTimerActive = NO;
		mTransitions = NO;
        mDayShouldIncrease = YES;
		mDay = 0;
		mTimeOfDay = timeOfDay;
		mPeriodModifier = 1;
        
        // Initialise to sameshadow offset as Dawn (the first state)
        mPrevShadowOffsetX = -0.5f;
        mPrevShadowOffsetY = 0.5f;
        
		[self applyTimeOfDayChangeWithTimePassed:seconds];
		[self updateShadowOffset];
		[self broadcastTimeOfDayChange];
	}
	return self;
}

- (id)init {
	return [self initWithTimeOfDay:Sunrise timePassed:0.0f];
}

- (void)setDay:(uint)day {
    mDay = MIN([TimeKeeper maxDay],day);
}

- (TimeOfDay)timeOfDay {
	return mTimeOfDay;
}

- (void)setTimeOfDay:(TimeOfDay)timeOfDay {
	mTimeOfDay = timeOfDay;
	[self applyTimeOfDayChangeWithTimePassed:0];
	[self broadcastTimeOfDayChange];
}

- (void)setTimeOfDay:(TimeOfDay)timeOfDay timePassed:(float)seconds {
	mTimeOfDay = timeOfDay;
	[self applyTimeOfDayChangeWithTimePassed:seconds];
	[self broadcastTimeOfDayChange];
}

- (NSString *)introForDay:(uint)day {
    NSString *intro = nil;
    
    if (day > 0 && day <= mDayIntros.count)
        intro = [mDayIntros objectAtIndex:day-1];
    return  intro;
}

- (float)timeRemaining {
	float time = mPeriodDuration - mTimePassed - kTickInterval; // kTickInterval to prevent tween-fighting
	return MAX(0,time);
}

- (float)timeRemainingToday {
    return DAY_CYCLE_IN_SEC - mTimePassedToday;
}

- (float)proportionPassed {
	return MIN(1, mTimePassed / mPeriodDuration);
}

- (float)proportionRemaining {
	return MIN(1, self.timeRemaining / mPeriodDuration);
}

- (void)setPeriodModifier:(float)value {
	if (value < 0.001f)
		return;
	mPeriodDuration *= 1.0f / mPeriodModifier; // Undo previous modifier
	mPeriodDuration *= value; // Apply new modifier 
	mPeriodModifier = value;
}

- (void)applyTimeOfDayChangeWithTimePassed:(float)seconds {
	if (mTimeOfDay > Dawn)
		mTimeOfDay = SunriseTransition;
    if (mTimeOfDay == SunriseTransition && mDayShouldIncrease) {
        ++mDay;
        mTimePassedToday = 0;
    }
    
    mPrevShadowOffsetX = mShadowOffsetX;
    mPrevShadowOffsetY = mShadowOffsetY;
    
	NSDictionary *settings = [TimeKeeper settingsForPeriod:mTimeOfDay];
	mPeriodDuration = mPeriodModifier * [(NSNumber *)[settings objectForKey:kDurationKey] floatValue];
	mTransitions = [(NSNumber *)[settings objectForKey:kTransitionsKey] boolValue];
	mTimePassed = seconds;
	mTimeDelta = 0;
}

- (void)broadcastTimeOfDayChange {
	TimeStruct timeState;
	timeState.day = mDay;
	timeState.timeOfDay = mTimeOfDay;
	timeState.transitions = mTransitions;
	timeState.timePassed = mTimePassed; // + kTickInterval; // kTickInterval to prevent tween-fighting
	timeState.periodDuration = mPeriodDuration;
	
	TimeOfDayChangedEvent *event = [[TimeOfDayChangedEvent alloc] initWithType:CUST_EVENT_TYPE_TIME_OF_DAY_CHANGED timeState:timeState bubbles:NO];
	[self dispatchEvent:event];
	[event release];
	//NSLog(@"*** Time Of Day: %d ***", mTimeOfDay);
}

- (uint)waterColor {
	return kWaterColors[(int)mTimeOfDay];
}

- (void)updateShadowOffset {
	float proportion = self.proportionPassed;
	
    // Calculation method: prevValue + proportion * (targetValue - prevValue);
    
	switch (mTimeOfDay) {
        case NewGameTransition:
			// Tween to Centered
			mShadowOffsetX = mPrevShadowOffsetX + proportion * (0 - mPrevShadowOffsetX);
			mShadowOffsetY = mPrevShadowOffsetY + proportion * (0 - mPrevShadowOffsetY);
			break;
		case SunriseTransition:
            mShadowOffsetX = mPrevShadowOffsetX;
			mShadowOffsetY = mPrevShadowOffsetY + proportion * (-0.5f - mPrevShadowOffsetY);
			break;
		case Sunrise:
			// Tween from Centered to Far N
            mShadowOffsetX = mPrevShadowOffsetX;
			mShadowOffsetY = mPrevShadowOffsetY + proportion * (-1.0f - mPrevShadowOffsetY);
			break;
		case NoonTransition:
            mShadowOffsetX = mPrevShadowOffsetX;
			mShadowOffsetY = mPrevShadowOffsetY + proportion * (-0.25f - mPrevShadowOffsetY);
			break;
		case Noon:
            mShadowOffsetX = mPrevShadowOffsetX;
			mShadowOffsetY = mPrevShadowOffsetY + proportion * (0.1f - mPrevShadowOffsetY);
            break;
        case Afternoon:
            mShadowOffsetX = mPrevShadowOffsetX;
			mShadowOffsetY = mPrevShadowOffsetY + proportion * (0.5f - mPrevShadowOffsetY);
			break;
		case SunsetTransition:
            mShadowOffsetX = mPrevShadowOffsetX;
			mShadowOffsetY = mPrevShadowOffsetY + proportion * (0.75f - mPrevShadowOffsetY);
			break;
		case Sunset:
			// Tween from S to Far S
            mShadowOffsetX = mPrevShadowOffsetX;
			mShadowOffsetY = mPrevShadowOffsetY + proportion * (1.0f - mPrevShadowOffsetY);
			break;
		case DuskTransition:
            mShadowOffsetX = mPrevShadowOffsetX + proportion * (-0.25f - mPrevShadowOffsetX);
			mShadowOffsetY = mPrevShadowOffsetY + proportion * (0.75f - mPrevShadowOffsetY);
			break;
		case Dusk:
			// Tween from Far S to SW
            mShadowOffsetX = mPrevShadowOffsetX + proportion * (-0.5f - mPrevShadowOffsetX);
			mShadowOffsetY = mPrevShadowOffsetY + proportion * (0.5f - mPrevShadowOffsetY);
			break;
		case EveningTransition:
            mShadowOffsetX = mPrevShadowOffsetX + proportion * (-0.75f - mPrevShadowOffsetX);
			mShadowOffsetY = mPrevShadowOffsetY + proportion * (0.75f - mPrevShadowOffsetY);
			break;
        case Evening:
            // Tween from SW to Far SW
            mShadowOffsetX = mPrevShadowOffsetX + proportion * (-0.9f - mPrevShadowOffsetX);
			mShadowOffsetY = mPrevShadowOffsetY + proportion * (0.9f - mPrevShadowOffsetY);
			break;
		case Midnight:
			// Tween from SW to Far SW
            mShadowOffsetX = mPrevShadowOffsetX + proportion * (-1.0f - mPrevShadowOffsetX);
			mShadowOffsetY = mPrevShadowOffsetY + proportion * (1.0f - mPrevShadowOffsetY);
			break;
        case DawnTransition:
            mShadowOffsetX = mPrevShadowOffsetX + proportion * (-0.5f - mPrevShadowOffsetX);
			mShadowOffsetY = mPrevShadowOffsetY + proportion * (0.5f - mPrevShadowOffsetY);
			break;
		case Dawn:
			// Tween from Far SW to Centered
            mShadowOffsetX = mPrevShadowOffsetX + proportion * (0 - mPrevShadowOffsetX);
			mShadowOffsetY = mPrevShadowOffsetY + proportion * (0 - mPrevShadowOffsetY);
			break;
		default:
			break;
	}
}

- (void)setTimerActive:(BOOL)value {
	mTimerActive = value;
    [self updateShadowOffset];
}

- (void)advanceTime:(double)time {
	if (mTimerActive == NO)
		return;
    
    // Don't advance time of day anymore after day 7 is complete
    if (mDay == [TimeKeeper maxDay] && mTimeOfDay == Dusk)
        return;
    
	mTimeDelta += time;
    mTimePassedToday += time;
	
	if (mTimeDelta >= kTickInterval) {
		while (mTimeDelta >= kTickInterval) {
			mTimeDelta -= kTickInterval;
			mTimePassed += (float)kTickInterval;
		}
        
		[self updateShadowOffset];
		
		if (mTimePassed >= mPeriodDuration) {
			++mTimeOfDay;
			[self applyTimeOfDayChangeWithTimePassed:0];
			[self broadcastTimeOfDayChange];
		}
	}
}

- (void)reset {
    mDayShouldIncrease = YES;
	self.periodModifier = 1;
	self.day = 0;
    [self setTimeOfDay:NewGameTransition timePassed:0];
}

- (void)dealloc {
    [mDayIntros release]; mDayIntros = nil;
    [super dealloc];
}

@end
