//
//  ResourcesLoadedEvent.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 3/06/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	StateNull = 0,
	StatePlayfield
} GameState;

#define CUST_EVENT_TYPE_CACHED_SCENE_RESOURCES_LOADED @"cachedSceneResourcesLoadedEvent"

@interface ResourcesLoadedEvent : SPEvent {
	GameState mState;
}

@property (nonatomic,readonly) GameState state;

+ (ResourcesLoadedEvent *)resourcesLoadedEventWithState:(GameState)state bubbles:(BOOL)bubbles;
- (id)initWithState:(GameState)state bubbles:(BOOL)bubbles;

@end
