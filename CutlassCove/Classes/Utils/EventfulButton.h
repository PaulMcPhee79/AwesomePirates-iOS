//
//  EventfulButton.h
//  Cutlass Cove
//
//  Created by Paul McPhee on 22/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPButton.h"

#define SPX_EVENT_TYPE_BUTTON_UP @"buttonUpEvent"
#define SPX_EVENT_TYPE_BUTTON_DOWN @"buttonDownEvent"

@interface EventfulButton : SPButton

+ (EventfulButton *)eventfulButtonWithUpState:(SPTexture*)upState;

@end
