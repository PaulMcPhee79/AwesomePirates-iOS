//
//  NumericValueChangedEvent.h
//  Pirates
//
//  Created by Paul McPhee on 26/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPEvent.h"

#define CUST_EVENT_TYPE_NUMERIC_VALUE_CHANGED @"numericValueChangedEvent"
#define CUST_EVENT_TYPE_INFAMY_VALUE_CHANGED @"infamyValueChangedEvent"
// Doubloons
#define CUST_EVENT_TYPE_DOUBLOONS_VALUE_CHANGED @"doubloonsValueChangedEvent"
#define CUST_EVENT_TYPE_DOUBLOONS_LOOTED @"doubloonsLootedEvent"
#define CUST_EVENT_TYPE_DOUBLOONS_EXTORTED @"doubloonsExtortedEvent"
#define CUST_EVENT_TYPE_DOUBLOONS_BOUGHT @"doubloonsBoughtEvent"
#define CUST_EVENT_TYPE_DOUBLOONS_SPENT @"doubloonsSpentEvent"
#define CUST_EVENT_TYPE_DOUBLOONS_SWINDLERS_SIGNET @"doubloonsSwindlersSignet"
#define CUST_EVENT_TYPE_DOUBLOONS_SCOUNDRELS_SHARE @"doubloonsScoundrelsShare"
#define CUST_EVENT_TYPE_DOUBLOONS_EXPERT_EXTORTIONIST @"doubloonsExpertExtortionist"

#define CUST_EVENT_TYPE_RANSOMS_VALUE_CHANGED @"ransomsValueChangedEvent"
#define CUST_EVENT_TYPE_PRISONERS_VALUE_CHANGED @"prisonersValueChangedEvent"
#define CUST_EVENT_TYPE_SPRITE_CAROUSEL_INDEX_CHANGED @"carouselIndexChangedEvent"
#define CUST_EVENT_TYPE_AI_KNOB_VALUE_CHANGED @"aiKnobValueChangedEvent"
#define CUST_EVENT_TYPE_AI_STATE_VALUE_CHANGED @"aiStateValueChangedEvent"
#define CUST_EVENT_TYPE_COMBO_MULTIPLIER_CHANGED @"comboMultiplierChangedEvent"
#define CUST_EVENT_TYPE_CREW_OVERBOARD @"crewOverboardEvent"
#define CUST_EVENT_TYPE_ASH_PICKUP_LOOTED @"ashPickupLootedEvent"

@interface NumericValueChangedEvent : SPEvent {
	NSNumber *mValue;
	NSNumber *mOldValue;
}

@property (nonatomic,readonly) NSNumber *value;
@property (nonatomic,readonly) NSNumber *oldValue;

- (id)initWithType:(NSString *)type value:(NSNumber *)value bubbles:(BOOL)bubbles;
- (id)initWithType:(NSString *)type value:(NSNumber *)value oldValue:(NSNumber *)oldValue bubbles:(BOOL)bubbles;
+ (void)dispatchEventWithDispatcher:(SPEventDispatcher *)dispatcher type:(NSString *)type value:(NSNumber *)value bubbles:(BOOL)bubbles;
+ (void)dispatchEventWithDispatcher:(SPEventDispatcher *)dispatcher type:(NSString *)type value:(NSNumber *)value oldValue:(NSNumber *)oldValue bubbles:(BOOL)bubbles;

@end
