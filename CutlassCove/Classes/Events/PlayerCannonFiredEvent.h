//
//  PlayerCannonFiredEvent.h
//  Pirates
//
//  Created by Paul McPhee on 19/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPEvent.h"

#define CUST_EVENT_TYPE_PLAYER_CANNON_FIRED @"cannonFired"

@class PlayerCannon;

@interface PlayerCannonFiredEvent : SPEvent {
	PlayerCannon *mCannon;
}

- (id)initWithType:(NSString *)type cannon:(PlayerCannon *)cannon bubbles:(BOOL)bubbles;

@property (nonatomic,readonly) PlayerCannon *cannon;

@end
