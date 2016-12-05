//
//  PoolIndexer.m
//  CutlassCove
//
//  Created by Paul McPhee on 14/11/12.
//  Copyright (c) 2012 Cheeky Mammoth. All rights reserved.
//

#import <malloc/malloc.h>
#import "PoolIndexer.h"

@implementation PoolIndexer

@synthesize capacity = mCapacity;
@synthesize tag = mTag;

- (id)initWithCapacity:(int)capacity tag:(NSString *)tag {
    if (self = [super init]) {
        mCapacity = MAX(1, capacity);
        mIndices = (int *)malloc(mCapacity * sizeof(int));
        mIndicesIndex = 0;
        mTag = tag;
    }
    
    return self;
}

- (void)setupIndexes:(int)startIndex increment:(int)increment {
    for (int i = 0; i < mCapacity; ++i)
        mIndices[i] = startIndex + i * increment;
}

- (int)checkoutNextIndex {
    if (mIndicesIndex < mCapacity)
        return mIndices[mIndicesIndex++];
    else
        return -1;
}

- (void)checkinIndex:(int)index {
    assert(index >= 0 && mIndicesIndex > 0 && mIndicesIndex <= mCapacity);
    
    if (index >= 0 && mIndicesIndex > 0 && mIndicesIndex <= mCapacity) {
        --mIndicesIndex;
        mIndices[mIndicesIndex] = index;
    }
}

- (void)insertPoolIndex:(int)index poolIndex:(int)poolIndex {
    if (index >= 0 && index < mCapacity)
        mIndices[index] = poolIndex;
}

- (void)dealloc {
    if (mIndices) {
		free(mIndices);
		mIndices = 0;
        mCapacity = 0;
	}
    
    [super dealloc];
}

@end
