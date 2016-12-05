//
//  ResourcesLoadedEvent.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 3/06/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "ResourcesLoadedEvent.h"


@implementation ResourcesLoadedEvent

@synthesize state = mState;

+ (ResourcesLoadedEvent *)resourcesLoadedEventWithState:(GameState)state bubbles:(BOOL)bubbles {
	return [[[ResourcesLoadedEvent alloc] initWithState:state bubbles:bubbles] autorelease];
}

- (id)initWithState:(GameState)state bubbles:(BOOL)bubbles {
	if (self = [super initWithType:CUST_EVENT_TYPE_CACHED_SCENE_RESOURCES_LOADED]) {
		mState = state;
	}
	return self;
}

@end
