//
//  ObjectivesView.h
//  Cutlass Cove
//
//  Created by Paul McPhee on 6/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

#define CUST_EVENT_TYPE_OBJECTIVES_CURRENT_PANEL_DISMISSED @"objectivesCurrentPanelDismissedEvent"
#define CUST_EVENT_TYPE_OBJECTIVES_RANKUP_PANEL_DISMISSED @"objectivesRankupPanelDismissedEvent"

@class ObjectivesCompletedPanel,ObjectivesCurrentPanel,ObjectivesRankupPanel,ObjectivesDescription,ObjectivesRank;

@interface ObjectivesView : Prop {
    BOOL mTouchBarrierEnabled;
    
    // Subviews
    ObjectivesCompletedPanel *mCompletedPanel;
    ObjectivesCurrentPanel *mCurrentPanel;
    ObjectivesRankupPanel *mRankupPanel;
    ObjectivesCompletedPanel *mNoticesPanel;
    
    NSMutableArray *mCompletedQueue;
    NSMutableArray *mNoticeQueue;
}

- (void)prepareForNewGame;
- (void)beginChallenge;
- (void)finishChallenge;

// Current Panel
- (void)populateWithObjectivesRank:(ObjectivesRank *)objRank;
- (void)showCurrentPanel;
- (void)hideCurrentPanel;
- (void)enableCurrentPanelButtons:(BOOL)enable;
- (void)enableTouchBarrier:(BOOL)enable;
- (SPSprite *)maxRankSprite;

// Completed Panel
- (void)fillCompletedCacheWithRank:(ObjectivesRank *)objRank;
- (void)enqueueCompletedObjectivesDescription:(ObjectivesDescription *)objDesc;

// Rankup Panel
- (void)showRankupPanelWithRank:(uint)rank;
- (void)hideRankupPanel;

// Misc messages
- (void)enqueueNotice:(NSString *)msg;
- (void)hideNoticesPanel;

@end
