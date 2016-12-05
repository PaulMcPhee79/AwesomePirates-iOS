//
//  SwitchFlippedEvent.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 30/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CUST_EVENT_TYPE_SWITCH_CONTROL_FLIPPED @"switchControlFlippedEvent"

@interface SwitchFlippedEvent : SPEvent {
	BOOL mState;
}

@property (nonatomic,readonly) BOOL state;

+ (SwitchFlippedEvent *)switchFlippedEventWithState:(BOOL)state bubbles:(BOOL)bubbles;
- (id)initWithState:(BOOL)state bubbles:(BOOL)bubbles;

@end
