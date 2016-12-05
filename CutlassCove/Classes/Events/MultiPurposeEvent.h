//
//  MultiPurposeEvent.h
//  CutlassCove
//
//  Created by Paul McPhee on 4/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MultiPurposeEvent : SPEvent {
    NSMutableDictionary *data;
}

@property (nonatomic,readonly) NSMutableDictionary *data;

+ (MultiPurposeEvent *)multiPurposeEventWithType:(NSString *)type bubbles:(BOOL)bubbles;

@end
