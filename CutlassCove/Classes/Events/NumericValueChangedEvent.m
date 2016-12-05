//
//  NumericValueChangedEvent.m
//  Pirates
//
//  Created by Paul McPhee on 26/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "NumericValueChangedEvent.h"

@implementation NumericValueChangedEvent

@synthesize value = mValue;
@synthesize oldValue = mOldValue;

+ (void)dispatchEventWithDispatcher:(SPEventDispatcher *)dispatcher type:(NSString *)type value:(NSNumber *)value oldValue:(NSNumber *)oldValue bubbles:(BOOL)bubbles {
	NumericValueChangedEvent *event = [[NumericValueChangedEvent alloc] initWithType:type value:value oldValue:oldValue bubbles:bubbles];
	[dispatcher dispatchEvent:event];
	[event release];
}

+ (void)dispatchEventWithDispatcher:(SPEventDispatcher *)dispatcher type:(NSString *)type value:(NSNumber *)value bubbles:(BOOL)bubbles {
	NumericValueChangedEvent *event = [[NumericValueChangedEvent alloc] initWithType:type value:value bubbles:bubbles];
	[dispatcher dispatchEvent:event];
	[event release];
}

- (id)initWithType:(NSString *)type value:(NSNumber *)value oldValue:(NSNumber *)oldValue bubbles:(BOOL)bubbles {
	if (self = [super initWithType:type bubbles:bubbles]) {
		mValue = [value retain];
		mOldValue = [oldValue retain];
	}
	return self;
}

- (id)initWithType:(NSString *)type value:(NSNumber *)value bubbles:(BOOL)bubbles {
	return [self initWithType:type value:value oldValue:value bubbles:bubbles];
}

- (void)dealloc {
	[mValue release]; mValue = nil;
	[mOldValue release]; mOldValue = nil;
	[super dealloc];
}

@end
