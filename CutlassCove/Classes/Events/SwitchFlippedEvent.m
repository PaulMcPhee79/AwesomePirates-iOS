//
//  SwitchFlippedEvent.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 30/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SwitchFlippedEvent.h"


@implementation SwitchFlippedEvent

@synthesize state = mState;

+ (SwitchFlippedEvent *)switchFlippedEventWithState:(BOOL)state bubbles:(BOOL)bubbles {
	return [[[SwitchFlippedEvent alloc] initWithState:state bubbles:bubbles] autorelease];
}

- (id)initWithState:(BOOL)state bubbles:(BOOL)bubbles {
	if (self = [super initWithType:CUST_EVENT_TYPE_SWITCH_CONTROL_FLIPPED]) {
		mState = state;
	}
	return self;
}

@end
