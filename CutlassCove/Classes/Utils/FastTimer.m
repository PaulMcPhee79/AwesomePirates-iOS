//
//  FastTimer.m
//  Cutlass Cove
//
//  Created by Paul McPhee on 1/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FastTimer.h"

typedef float (*FnPtrCallback) (id, SEL, SPEvent*);

@implementation FastTimer

- (id)initWithInterval:(double)interval {
    if (self = [super init]) {
        mInterval = interval;
        mCounter = 0.0;
        mCBNodes = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id)init {
    return [self initWithInterval:10.0];
}

- (void)dealloc {
    [mCBNodes release]; mCBNodes = nil;
    [super dealloc];
}

- (void)addEventListener:(SEL)listener atObject:(NSObject *)object forType:(NSString *)eventType {
    NSMutableArray *array = (NSMutableArray *)[mCBNodes objectForKey:eventType];
    
    if (array == nil) {
        array = [NSMutableArray array];
        [mCBNodes setObject:array forKey:eventType];
    }
    
    [array addObject:[CBNode cbNodeWithTarget:object selector:listener]];
}

- (void)removeEventListener:(SEL)listener atObject:(NSObject *)object forType:(NSString *)eventType {
    NSMutableArray *array = (NSMutableArray *)[mCBNodes objectForKey:eventType];
    
    if (array)
        [array removeObject:object];
}

- (void)dispatchEvents {
    for (NSString *eventType in mCBNodes) {
        SPEvent *event = [SPEvent eventWithType:eventType];
        NSArray *array = (NSArray *)[mCBNodes objectForKey:eventType];
        
        for (CBNode *node in array)
            [node dispatchEvent:event];
    }
}

- (void)advanceTime:(double)time {
    mCounter += time;
    
    if (mCounter >= mInterval) {
        mCounter = 0.0;
        [self dispatchEvents];
    }
}

@end


@implementation CBNode

+ (CBNode *)cbNodeWithTarget:(NSObject *)target selector:(SEL)selector {
    return [[[CBNode alloc] initWithTarget:target selector:selector] autorelease];
}

- (id)initWithTarget:(NSObject *)target selector:(SEL)selector {
    if (self = [super init]) {
        mTarget = [target retain];
        mSelector = selector;
        
        if ([mTarget respondsToSelector:mSelector] == NO)
            [NSException raise:SP_EXC_INVALID_OPERATION 
                        format:@"%@ does not respond to selector: '%@'", NSStringFromClass([mTarget class]), NSStringFromSelector(mSelector)];
        mCallbackFunc = [mTarget methodForSelector:mSelector]; 
    }
    
    return self;
}

- (void)dealloc {
    [mTarget release]; mTarget = nil;
    [super dealloc];
}

- (void)dispatchEvent:(SPEvent *)event {
    FnPtrCallback cbFunc = (FnPtrCallback)mCallbackFunc;
    cbFunc(mTarget, mSelector, event);
}

@end
