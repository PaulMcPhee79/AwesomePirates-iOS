//
//  ElementExpiredEvent.m
//  Pirates
//
//  Created by Paul McPhee on 19/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "ElementExpiredEvent.h"

@implementation ElementExpiredEvent

@synthesize element = mElement;

- (id)initWithType:(NSString *)type element:(id)element bubbles:(BOOL)bubbles {
	if (self = [super initWithType:type bubbles:bubbles]) {
		mElement = element;
	}
	return self;
}

@end
