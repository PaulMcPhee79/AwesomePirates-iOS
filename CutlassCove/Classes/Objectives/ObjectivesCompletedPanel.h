//
//  ObjectivesCompletedPanel.h
//  Cutlass Cove
//
//  Created by Paul McPhee on 6/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

#define CUST_EVENT_TYPE_OBJECTIVES_COMPLETED_PANEL_HIDDEN @"objectivesCompletedPanelHiddenEvent"

@class ObjectivesRank;

@interface ObjectivesCompletedPanel : Prop {
    BOOL mBusy;
    BOOL mIsSilent;
    float mShowTargetY;
    SPImage *mScrollImage;
    SPSprite *mCanvas;
    SPSprite *mFlipCanvas;
    SPTextField *mTextField;
    NSMutableArray *mCachedTextFields;
}

@property (nonatomic,readonly) BOOL isBusy;
@property (nonatomic,assign) BOOL isSilent;
@property (nonatomic,assign) float showTargetY;

- (void)shrinkToSingleLine;
- (void)fillCacheWithRank:(ObjectivesRank *)objRank;
- (void)setText:(NSString *)text;
- (void)displayForDuration:(float)duration;
- (void)hide;
- (void)hideOverTime:(float)duration;

@end
