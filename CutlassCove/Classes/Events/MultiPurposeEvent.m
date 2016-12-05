//
//  MultiPurposeEvent.m
//  CutlassCove
//
//  Created by Paul McPhee on 4/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MultiPurposeEvent.h"

@implementation MultiPurposeEvent

@synthesize data;

+ (MultiPurposeEvent *)multiPurposeEventWithType:(NSString *)type bubbles:(BOOL)bubbles {
    return [[[MultiPurposeEvent alloc] initWithType:type bubbles:bubbles] autorelease];
}

- (id)initWithType:(NSString *)type bubbles:(BOOL)bubbles {
    if (self = [super initWithType:type bubbles:bubbles]) {
        data = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc {
    [data release]; data = nil;
    [super dealloc];
}

@end
