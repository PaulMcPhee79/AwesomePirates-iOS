//
//  StringValueEvent.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 30/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "StringValueEvent.h"

@implementation StringValueEvent

@synthesize stringValue = mStringValue;

+ (StringValueEvent *)stringValueEventWithType:(NSString *)type stringValue:(NSString *)stringValue bubbles:(BOOL)bubbles {
	return [[[StringValueEvent alloc] initWithType:type stringValue:stringValue bubbles:bubbles] autorelease];
}

- (id)initWithType:(NSString *)type stringValue:(NSString *)stringValue bubbles:(BOOL)bubbles {
	if (self = [super initWithType:type bubbles:bubbles]) {
		mStringValue = [stringValue copy];
	}
	return self;
}

- (void)dealloc {
	[mStringValue release]; mStringValue = nil;
	[super dealloc];
}

@end
