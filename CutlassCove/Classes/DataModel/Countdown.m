//
//  Countdown.m
//  Cutlass Cove
//
//  Created by Paul McPhee on 27/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Countdown.h"

@interface Countdown ()

- (void)notifyListenersWithDelta:(int)delta;

@end


@implementation Countdown

@synthesize loop,counter,counterMax,remainder;

- (id)initWithCounter:(int)count counterMax:(int)max {
    if (self = [super init]) {
        loop = YES;
        counter = count;
        counterMax = max;
        remainder = 0;
    }
    return self;
}

- (id)init {
    return [self initWithCounter:10 counterMax:10];
}

- (id)copyWithZone:(NSZone *)zone {
    Countdown *copy = [[[self class] allocWithZone:zone] init];
    copy.loop = self.loop;
    copy.counter = self.counter;
    copy.counterMax = self.counterMax;
    copy.remainder = self.remainder;
    return copy;
}

- (void)decrement {
    if (counter > 0) {
        int oldCounter = counter;
        --counter;
        [self notifyListenersWithDelta:counter - oldCounter];
        
        if (counter == 0 && loop) {
            counter = counterMax;
            [self notifyListenersWithDelta:counter - oldCounter];
        }
    }
}

- (void)reduceBy:(float)value {
    remainder += value;
    
    while (remainder > 1) {
        remainder -= 1;
        [self decrement];
    }
}

- (void)reset {
    int oldCounter = counter;
    counter = counterMax;
    [self notifyListenersWithDelta:counter - oldCounter];
}

- (void)softReset {
    counter = counterMax;
    remainder = 0;
}

- (void)notifyListenersWithDelta:(int)delta {
    [self dispatchEvent:[NumericRatioChangedEvent numericRatioEventWithType:CUST_EVENT_TYPE_MUTINY_COUNTDOWN_CHANGED
                                                                      value:[NSNumber numberWithInt:counter]
                                                                   minValue:[NSNumber numberWithInt:0]
                                                                   maxValue:[NSNumber numberWithInt:counterMax]
                                                                      delta:[NSNumber numberWithInt:delta]
                                                                    bubbles:NO]];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
        loop = [(NSNumber *)[decoder decodeObjectForKey:@"loop"] boolValue];
		counter = [(NSNumber *)[decoder decodeObjectForKey:@"counter"] intValue];
        counterMax = [(NSNumber *)[decoder decodeObjectForKey:@"counterMax"] intValue];
        remainder = [(NSNumber *)[decoder decodeObjectForKey:@"remainder"] floatValue];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:[NSNumber numberWithBool:loop] forKey:@"loop"];
	[coder encodeObject:[NSNumber numberWithInt:counter] forKey:@"counter"];
    [coder encodeObject:[NSNumber numberWithInt:counterMax] forKey:@"counterMax"];
    [coder encodeObject:[NSNumber numberWithFloat:remainder] forKey:@"remainder"];
}

@end
