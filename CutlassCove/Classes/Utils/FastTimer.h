//
//  FastTimer.h
//  Cutlass Cove
//
//  Created by Paul McPhee on 1/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBNode : NSObject {
    NSObject *mTarget;    
    SEL mSelector;
    IMP mCallbackFunc;
}

+ (CBNode *)cbNodeWithTarget:(NSObject *)target selector:(SEL)selector;
- (id)initWithTarget:(NSObject *)target selector:(SEL)selector;
- (void)dispatchEvent:(SPEvent *)event;

@end


@interface FastTimer : NSObject {
    double mInterval;
    double mCounter;
    NSMutableDictionary *mCBNodes;
}

- (id)initWithInterval:(double)interval;
- (void)addEventListener:(SEL)listener atObject:(NSObject *)object forType:(NSString *)eventType;
- (void)removeEventListener:(SEL)listener atObject:(NSObject *)object forType:(NSString *)eventType;
- (void)dispatchEvents;
- (void)advanceTime:(double)time;

@end
