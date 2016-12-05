//
//  Countdown.h
//  Cutlass Cove
//
//  Created by Paul McPhee on 27/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NumericRatioChangedEvent.h"

@interface Countdown : SPEventDispatcher <NSCoding,NSCopying> {
    BOOL loop;
    int counter;
    int counterMax;
    float remainder;
}

@property (nonatomic,assign) BOOL loop;
@property (nonatomic,assign) int counter;
@property (nonatomic,assign) int counterMax;
@property (nonatomic,assign) float remainder;

- (id)initWithCounter:(int)count counterMax:(int)max;
- (void)decrement;
- (void)reduceBy:(float)value;
- (void)reset;
- (void)softReset;

@end
