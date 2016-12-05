//
//  PrisonerOverboardEvent.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 19/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "PrisonerOverboardEvent.h"

@implementation PrisonerOverboardEvent

@synthesize prisoner = mPrisoner;
@dynamic prisonerName;


+ (void)dispatchEventWithDispatcher:(SPEventDispatcher *)dispatcher prisoner:(Prisoner *)prisoner bubbles:(BOOL)bubbles {
	//NSLog(@"Dispatching event with name: %@", prisoner.name);
	PrisonerOverboardEvent *event = [[PrisonerOverboardEvent alloc] initWithType:CUST_EVENT_TYPE_PRISONER_OVERBOARD prisoner:prisoner bubbles:bubbles];
	[dispatcher dispatchEvent:event];
	[event release];
}

- (id)initWithType:(NSString *)type prisoner:(Prisoner *)prisoner bubbles:(BOOL)bubbles {
	if (self = [super initWithType:type bubbles:bubbles]) {
		mPrisoner = [prisoner retain];
	}
	return self;
}

- (NSString *)prisonerName {
	return mPrisoner.name;
}

- (void)dealloc {
	[mPrisoner release]; mPrisoner = nil;
	[super dealloc];
}

@end
