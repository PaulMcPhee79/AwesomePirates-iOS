//
//  StringValueEvent.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 30/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CUST_EVENT_TYPE_STRING_VALUE @"stringValueEvent"
#define CUST_EVENT_TYPE_GK_DATA_CHANGED @"GKViewChangedEvent"

@interface StringValueEvent : SPEvent {
	NSString *mStringValue;
}

@property (nonatomic,readonly) NSString *stringValue;

+ (StringValueEvent *)stringValueEventWithType:(NSString *)type stringValue:(NSString *)stringValue bubbles:(BOOL)bubbles;
- (id)initWithType:(NSString *)type stringValue:(NSString *)stringValue bubbles:(BOOL)bubbles;


@end
