//
//  EventfulButton.m
//  Cutlass Cove
//
//  Created by Paul McPhee on 22/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EventfulButton.h"
#import "SPButton_Extension.h"

@implementation EventfulButton

+ (EventfulButton *)eventfulButtonWithUpState:(SPTexture*)upState {
    return [[[EventfulButton alloc] initWithUpState:upState] autorelease];
}

- (id)initWithUpState:(SPTexture*)upState {
    if (self = [super initWithUpState:upState]) {
        
    }
    
    return self;
}

- (void)onTouch:(SPTouchEvent*)touchEvent
{
    BOOL oldIsDown = self.isDown;
    
    [super onTouch:touchEvent];
    
    if (oldIsDown != self.isDown) {
        if (self.isDown)
            [self dispatchEvent:[SPEvent eventWithType:SPX_EVENT_TYPE_BUTTON_DOWN]];
        else
            [self dispatchEvent:[SPEvent eventWithType:SPX_EVENT_TYPE_BUTTON_UP]];
    }
}

@end
