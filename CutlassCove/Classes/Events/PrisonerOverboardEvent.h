//
//  PrisonerOverboardEvent.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 19/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPEvent.h"
#import "Prisoner.h"

#define CUST_EVENT_TYPE_PRISONER_OVERBOARD @"prisonerOverboardEvent"


@interface PrisonerOverboardEvent : SPEvent {
	Prisoner *mPrisoner;
}

@property (nonatomic,readonly) NSString *prisonerName;
@property (nonatomic,readonly) Prisoner *prisoner;

- (id)initWithType:(NSString *)type prisoner:(Prisoner *)prisoner bubbles:(BOOL)bubbles;
+ (void)dispatchEventWithDispatcher:(SPEventDispatcher *)dispatcher prisoner:(Prisoner *)prisoner bubbles:(BOOL)bubbles;

@end
