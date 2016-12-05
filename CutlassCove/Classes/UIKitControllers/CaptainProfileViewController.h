//
//  CaptainProfileViewController.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 19/09/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TableViewController.h"
#import "AchievementManager.h"

@interface CaptainProfileViewController : TableViewController <UITableViewDelegate,UITableViewDataSource> {
	AchievementManager *mData;
}

- (id)initWithDataModel:(AchievementManager *)model;
- (void)onModelDataWillChange:(SPEvent *)event;
- (void)onModelDataChanged:(StringValueEvent *)event;

@end
