//
//  PersistenceManager.h
//  CutlassCove
//
//  Created by Paul McPhee on 17/07/13.
//  Copyright (c) 2013 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CUST_EVENT_TYPE_CLOUD_LOGGED_IN @"cloudLoggedInEvent"
#define CUST_EVENT_TYPE_CLOUD_LOGGED_OUT @"cloudLoggedOutEvent"
#define CUST_EVENT_TYPE_CLOUD_DATA_CHANGED @"cloudDataChangedEvent"
#define CUST_EVENT_TYPE_CLOUD_SETTINGS_CHANGED @"cloudSettingsChangedEvent"

@class GameStats;

@interface PersistenceManager : SPEventDispatcher {
    @private
    BOOL mCloudApproved;
    BOOL mCloudEnabled;
    BOOL mBusyEnabling;
    BOOL mUbiqIdSupported;
    BOOL mLocalSaveInProgress;
    id<NSObject, NSCopying, NSCoding> mUbiqIdToken;
    id<NSObject, NSCopying, NSCoding> mPrevUbiqIdToken;
}

@property (nonatomic, assign) BOOL isCloudApproved;
@property (nonatomic, readonly) BOOL isCloudSupported;
@property (nonatomic, readonly) BOOL ubiqIdSupported;
@property (nonatomic, readonly) BOOL hasActiveCloudAccount;

+ (PersistenceManager *)PM;

- (void)enableCloud;
- (void)disableCloud;

- (GameStats *)load;
- (GameStats *)loadCloud;
- (NSDictionary *)loadSettings;
- (void)save:(GameStats *)stats;
- (void)saveLocal:(GameStats *)stats;
- (void)saveCloud:(GameStats *)stats;
- (void)saveSettings:(NSDictionary *)settings;

- (void)applicationDidBecomeActive;
- (void)applicationWillResignActive;

@end
