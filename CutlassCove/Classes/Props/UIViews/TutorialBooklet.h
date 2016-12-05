//
//  TutorialBooklet.h
//  Cutlass Cove
//
//  Created by Paul McPhee on 1/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookletSubview.h"

#define CUST_EVENT_TYPE_TUTORIAL_DONE_PRESSED @"tutorialDonePressedEvent"

@interface TutorialBooklet : BookletSubview {
    uint mMinIndex;
    uint mMaxIndex;
    SPButton *mPrevButton;
    SPButton *mNextButton;
    SPButton *mDoneButton;
    SPButton *mContinueButton;
}

@property (nonatomic,assign) uint minIndex;
@property (nonatomic,assign) uint maxIndex;

- (id)initWithCategory:(int)category key:(NSString *)key minIndex:(uint)minIndex maxIndex:(uint)maxIndex;

@end
