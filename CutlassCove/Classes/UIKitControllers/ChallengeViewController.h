//
//  ChallengeViewController.h
//  CutlassCove
//
//  Created by Paul McPhee on 3/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TableViewController.h"

#define CUST_EVENT_TYPE_OF_CHALLENGE_CREATE_REQUEST @"ofChallengeCreateRequest"

@interface ChallengeViewController : TableViewController <UITableViewDelegate,UITableViewDataSource> {
    uint mLockBitmap;
    NSArray *mData;
}

@property (nonatomic,readonly) SPEventDispatcher *eventProxy;

- (id)initWithEventProxy:(SPEventDispatcher *)eventProxy;
- (void)enableLock:(BOOL)enable atIndex:(NSInteger)index;

@end
