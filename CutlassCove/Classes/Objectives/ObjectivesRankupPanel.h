//
//  ObjectivesRankupPanel.h
//  Cutlass Cove
//
//  Created by Paul McPhee on 6/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

#define CUST_EVENT_TYPE_OBJECTIVES_RANKUP_PANEL_CONTINUED @"objectivesRankupPanelContinuedEvent"

@class ObjectivesHat,ShadowTextField;

@interface ObjectivesRankupPanel : Prop {
    uint mRank;
    
    SPSprite *mCanvas;
    SPSprite *mMainSprite;
    SPSprite *mMultiplierSprite;
    
    ObjectivesHat *mHat;
    SPButton *mContinueButton;
    ShadowTextField *mRankText;
    SPQuad *mTouchBarrier;
    
    NSArray *mTicks;
}

- (id)initWithCategory:(int)category rank:(uint)rank;
- (void)enableTouchBarrier:(BOOL)enable;

@end
