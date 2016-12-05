//
//  RingBuffer.m
//  flightcontrol
//
//  Created by Paul McPhee on 24/07/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "RingBuffer.h"


@implementation RingBuffer

@synthesize capacity = mCapacity;
@synthesize allItems = mBuffer;
@dynamic nextItem,indexOfNextItem,atEnd,count;

- (id)initWithCapacity:(NSUInteger)capacity {
	if (self = [super init]) {
		mNext = 0;
		mCapacity = capacity;
		mBuffer = nil;
		mBuffer = [[NSMutableArray alloc] initWithCapacity:capacity];
	}
	return self;
}

- (uint)count {
	return mBuffer.count;
}

- (void)addItems:(NSArray *)items {
	if (items && items.count)
		[mBuffer addObjectsFromArray:items];
}

- (id)addItem:(id)item {
	[mBuffer addObject:item];
	return item;
}

- (id)nextItem {
	if (mBuffer.count) {
		if (mNext == mCapacity)
			mNext = 0;
		return [mBuffer objectAtIndex:mNext++];
	} else {
		return nil;
	}
}

- (uint)indexOfNextItem {
    return ((mNext == mCapacity) ? 0 : mNext);
}

- (void)resetIterator {
	mNext = 0;
}

- (BOOL)atEnd {
	return mNext == mCapacity;
}

- (void)dealloc {
	[mBuffer release]; mBuffer = nil;
	[super dealloc];
}

@end
