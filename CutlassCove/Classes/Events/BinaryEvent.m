//
//  BinaryEvent.m
//  CutlassCove
//
//  Created by Paul McPhee on 4/05/12.
//  Copyright (c) 2012 Cheeky Mammoth. All rights reserved.
//

#import "BinaryEvent.h"

@implementation BinaryEvent

@synthesize value = mValue;

+ (BinaryEvent *)binaryEventWithType:(NSString *)type value:(BOOL)value bubbles:(BOOL)bubbles {
    return [[[BinaryEvent alloc] initWithType:type value:value bubbles:bubbles] autorelease];
}

- (id)initWithType:(NSString *)type value:(BOOL)value bubbles:(BOOL)bubbles {
    if (self = [super initWithType:type bubbles:bubbles]) {
		mValue = value;
	}
	return self;
}

@end
