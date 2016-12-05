//
//  ObjectivesCurrentPanel.h
//  Cutlass Cove
//
//  Created by Paul McPhee on 6/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

#define CUST_EVENT_TYPE_OBJECTIVES_CURRENT_PANEL_CONTINUED @"objectivesCurrentPanelContinuedEvent"

typedef enum {
    ObjCurrentStateObjectives = 0,
    ObjCurrentStateChallenge
} ObjCurrentState;

@class ObjectivesHat,ObjectivesRank;

@interface ObjectivesCurrentPanel : Prop {
    ObjCurrentState mState;
    
    SPTexture *mTickTexture;
    SPTexture *mCrossTexture;
    
    SPSprite *mChallengeSprite;
    SPSprite *mMaxRankSprite;
    SPSprite *mScrollSprite;
    SPSprite *mCanvasContent;
    SPSprite *mObjectivesContent;
    SPSprite *mCanvas;
    SPButton *mContinueButton;
    ObjectivesHat *mHat;
    
    NSArray *mIcons;
    NSArray *mDescriptions;
    NSArray *mQuotas;
    NSArray *mFails;
}

- (void)setState:(ObjCurrentState)state;
- (void)enableButtons:(BOOL)enable;
- (void)populateWithObjectivesRank:(ObjectivesRank *)objRank;
- (SPSprite *)maxRankSprite;

@end
