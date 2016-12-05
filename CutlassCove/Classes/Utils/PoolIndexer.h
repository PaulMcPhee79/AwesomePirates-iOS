//
//  PoolIndexer.h
//  CutlassCove
//
//  Created by Paul McPhee on 14/11/12.
//  Copyright (c) 2012 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PoolIndexer : NSObject {
    int mCapacity;
    int mIndicesIndex;
    int *mIndices;
    NSString *mTag;
}

@property (nonatomic,readonly) int capacity;
@property (nonatomic,readonly) NSString *tag;

- (id)initWithCapacity:(int)capacity tag:(NSString *)tag;
- (void)setupIndexes:(int)startIndex increment:(int)increment;
- (int)checkoutNextIndex;
- (void)checkinIndex:(int)index;
- (void)insertPoolIndex:(int)index poolIndex:(int)poolIndex;

@end
