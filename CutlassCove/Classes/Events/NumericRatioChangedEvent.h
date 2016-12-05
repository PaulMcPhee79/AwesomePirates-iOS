//
//  NumericRatioChangedEvent.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 21/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPEvent.h"

#define CUST_EVENT_TYPE_NUMERIC_RATIO_CHANGED @"numericRatioChangedEvent"
#define CUST_EVENT_TYPE_MUTINY_VALUE_CHANGED @"mutinyValueChangedEvent"
#define CUST_EVENT_TYPE_GROG_VALUE_CHANGED @"grogValueChangedEvent"
#define CUST_EVENT_TYPE_CARGO_VALUE_CHANGED @"cargoValueChangedEvent"
#define CUST_EVENT_TYPE_CONDITION_VALUE_CHANGED @"conditionValueChangedEvent"
#define CUST_EVENT_TYPE_MUTINY_COUNTDOWN_CHANGED @"mutinyCountdownChangedEvent"

@interface NumericRatioChangedEvent : SPEvent {
	NSNumber *mDelta;
	NSNumber *mValue;
	NSNumber *mMinValue;
	NSNumber *mMaxValue;
}

@property (nonatomic,readonly) NSNumber *value;
@property (nonatomic,readonly) NSNumber *minValue;
@property (nonatomic,readonly) NSNumber *maxValue;
@property (nonatomic,readonly) NSNumber *delta;
@property (nonatomic,readonly) float ratio;
@property (nonatomic,readonly) float absRatio;

- (id)initWithType:(NSString *)type value:(NSNumber *)value minValue:(NSNumber *)minValue maxValue:(NSNumber *)maxValue delta:(NSNumber *)delta bubbles:(BOOL)bubbles;
+ (NumericRatioChangedEvent *)numericRatioEventWithType:(NSString *)type value:(NSNumber *)value minValue:(NSNumber *)minValue maxValue:(NSNumber *)maxValue delta:(NSNumber *)delta bubbles:(BOOL)bubbles;

@end
