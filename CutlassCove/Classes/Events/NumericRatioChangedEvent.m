//
//  NumericRatioChangedEvent.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 21/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "NumericRatioChangedEvent.h"

@implementation NumericRatioChangedEvent

@synthesize value = mValue;
@synthesize minValue = mMinValue;
@synthesize maxValue = mMaxValue;
@synthesize delta = mDelta;
@dynamic ratio,absRatio;

+ (NumericRatioChangedEvent *)numericRatioEventWithType:(NSString *)type
												  value:(NSNumber *)value
											   minValue:(NSNumber *)minValue
											   maxValue:(NSNumber *)maxValue
												  delta:(NSNumber *)delta
												bubbles:(BOOL)bubbles {
	return [[[NumericRatioChangedEvent alloc] initWithType:type value:value minValue:minValue maxValue:maxValue delta:delta bubbles:bubbles] autorelease];
}

- (id)initWithType:(NSString *)type value:(NSNumber *)value minValue:(NSNumber *)minValue maxValue:(NSNumber *)maxValue delta:(NSNumber *)delta bubbles:(BOOL)bubbles {
	if (self = [super initWithType:type bubbles:bubbles]) {
		mValue = [value retain];
		mMinValue = [minValue retain];
		mMaxValue = [maxValue retain];
		mDelta = [delta retain];
	}
	return self;
}

- (float)ratio {
	float result = 1, range = [mMaxValue floatValue] - [mMinValue floatValue];
	
	if (SP_IS_FLOAT_EQUAL(range, 0) == NO)
		result = ([mValue floatValue] - [mMinValue floatValue]) / range;
	return result;
}

- (float)absRatio {
	float result = 1;
	
	if (SP_IS_FLOAT_EQUAL([mMaxValue floatValue], 0) == NO)
		result = [mValue floatValue] / [mMaxValue floatValue];
	return result;
}

- (void)dealloc {
	[mValue release]; mValue = nil;
	[mMinValue release]; mMinValue = nil;
	[mMaxValue release]; mMaxValue = nil;
	[mDelta release]; mDelta = nil;
	[super dealloc];
}

@end
