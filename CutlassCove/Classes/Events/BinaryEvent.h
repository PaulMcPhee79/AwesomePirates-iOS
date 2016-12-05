//
//  BinaryEvent.h
//  CutlassCove
//
//  Created by Paul McPhee on 4/05/12.
//  Copyright (c) 2012 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPEvent.h"

#define CUST_EVENT_TYPE_BINARY @"binaryEvent"

@interface BinaryEvent : SPEvent {
    BOOL mValue;
}

@property (nonatomic,assign) BOOL value;

+ (BinaryEvent *)binaryEventWithType:(NSString *)type value:(BOOL)value bubbles:(BOOL)bubbles;
- (id)initWithType:(NSString *)type value:(BOOL)value bubbles:(BOOL)bubbles;

@end
