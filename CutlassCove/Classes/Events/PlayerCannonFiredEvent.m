//
//  PlayerCannonFiredEvent.m
//  Pirates
//
//  Created by Paul McPhee on 19/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "PlayerCannonFiredEvent.h"
#import "PlayerCannon.h"

@implementation PlayerCannonFiredEvent

@synthesize cannon = mCannon;

- (id)initWithType:(NSString *)type cannon:(PlayerCannon *)cannon bubbles:(BOOL)bubbles {
	if (self = [super initWithType:type bubbles:bubbles]) {
		mCannon = [cannon retain];
	}
	return self;
}

- (void)dealloc {
	[mCannon release]; mCannon = nil;
	[super dealloc];
}

@end
