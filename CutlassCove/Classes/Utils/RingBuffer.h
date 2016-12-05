//
//  RingBuffer.h
//  flightcontrol
//
//  Created by Paul McPhee on 24/07/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RingBuffer : NSObject {
	NSUInteger mCapacity;
	
	@private
	NSUInteger mNext;
	NSMutableArray *mBuffer;
}

@property (nonatomic,readonly) NSUInteger capacity;
@property (nonatomic,readonly) BOOL atEnd;
@property (nonatomic,readonly) id nextItem;
@property (nonatomic,readonly) uint indexOfNextItem;
@property (nonatomic,readonly) NSArray *allItems;
@property (nonatomic,readonly) uint count;

- (id)initWithCapacity:(NSUInteger)capacity;
- (id)addItem:(id)item;
- (void)addItems:(NSArray *)items;
- (void)resetIterator;

@end
