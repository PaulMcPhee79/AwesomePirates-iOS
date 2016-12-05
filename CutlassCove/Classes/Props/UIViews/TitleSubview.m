//
//  TitleSubview.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 23/10/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "TitleSubview.h"

@implementation TitleSubview

@synthesize closePosition = mClosePosition;
@synthesize closeSelectorName = mCloseSelectorName;

+ (TitleSubview *)titleSubviewWtihCategory:(int)category {
	return [[[TitleSubview alloc] initWithCategory:category] autorelease];
}

- (id)initWithCategory:(int)category {
	if (self = [super initWithCategory:category]) {
		mClosePosition = nil;
		mCloseSelectorName = nil;
	}
	return self;
}

- (void)dealloc {
	[mClosePosition release]; mClosePosition = nil;
	[mCloseSelectorName release]; mCloseSelectorName = nil;
	[super dealloc];
}

@end
