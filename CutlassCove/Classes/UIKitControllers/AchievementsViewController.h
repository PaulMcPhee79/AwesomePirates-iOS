//
//  AchievementsViewController.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 30/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewController.h"
#import "AchievementManager.h"

#define CUST_EVENT_TYPE_SPEEDBOAT_LAUNCH_REQUESTED @"speedboatLaunchRequestedEvent"

@interface AchievementsViewController : TableViewController <UITableViewDelegate,UITableViewDataSource> {
	AchievementManager *mData;
    SPEventDispatcher *mEventProxy;
}

- (id)initWithDataModel:(AchievementManager *)model eventProxy:(SPEventDispatcher *)eventProxy;
- (void)onModelDataWillChange:(SPEvent *)event;
- (void)onModelDataChanged:(StringValueEvent *)event;

@end
