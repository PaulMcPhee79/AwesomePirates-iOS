//
//  ElementExpiredEvent.h
//  Pirates
//
//  Created by Paul McPhee on 19/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPEvent.h"

#define CUST_EVENT_TYPE_ELEMENT_EXPIRED @"elementExpiredEvent"

@interface ElementExpiredEvent : SPEvent {
	id mElement;
}

@property (nonatomic,readonly) id element;

- (id)initWithType:(NSString *)type element:(id)element bubbles:(BOOL)bubbles;

@end
