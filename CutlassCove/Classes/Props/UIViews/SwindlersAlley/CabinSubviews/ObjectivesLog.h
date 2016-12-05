//
//  ObjectivesLog.h
//  Cutlass Cove
//
//  Created by Paul McPhee on 9/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

@class ObjectivesHat,ShadowTextField;

#define CUST_EVENT_TYPE_LOG_TAB_TOUCHED @"logTabTouchedEvent"

@interface LogTab : Prop {
    int mPageNo;
    SPTextField *mText;
    SPImage *mTab;
}

@property (nonatomic,assign) int pageNo;

@end

@interface ObjectivesLog : Prop {
    BOOL mDirtyFlag;
    uint mRank;
    
    ObjectivesHat *mHat;
    ShadowTextField *mRankTextField;
    SPTextField *mMultiplierTextField;
    SPSprite *mMultiplierSprite;
    SPSprite *mMaxRankSprite;
    NSMutableArray *mIconImages;
    NSMutableArray *mRankDescTextFields;
    
    SPSprite *mLogPage;
	SPSprite *mLogBook;
    LogTab *mPrevTab;
    LogTab *mNextTab;
}

@property (nonatomic,assign) uint rank;

- (id)initWithCategory:(int)category rank:(uint)rank;
- (void)syncWithObjectives;

@end
