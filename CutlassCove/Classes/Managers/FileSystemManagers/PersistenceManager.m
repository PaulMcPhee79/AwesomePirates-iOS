//
//  PersistenceManager.m
//  CutlassCove
//
//  Created by Paul McPhee on 17/07/13.
//  Copyright (c) 2013 Cheeky Mammoth. All rights reserved.
//

#import "PersistenceManager.h"
#import "FileManager.h"
#import "GameStats.h"
#import "NSMutableData_Extension.h"
#import "Globals.h"

// Define this if there is a need to separate multiple iCloud account progress. This complicated
// logic was implemented before I realized how difficult and annoying it is for users to switch iCloud
// accounts on a device. Once I knew that, I decided it was best to use simple logic that favors
// giving a potential new iCloud account free progress so that no-one loses progress (even if
// they junk their old iCloud account and make a new one).
//#define USE_COMPLICATED_CLOUD_LOGIC

// Local
#define LOCAL_KEY_UBIQ_ID_TOKENS @"UbiquityIdTokens"
#define LOCAL_KEY_UBIQ_ID_TOKEN_PREFIX @"UbiquityIdToken_"
#define LOCAL_KEY_LAST_KNOWN_UBIQ @"LastKnownUbiq"
#define LOCAL_KEY_SAVE_GAME @"LocalAwesomePiratesSaveKey"

// Cloud
#define CLOUD_KEY_SAVE_GAME @"iCloudAwesomePiratesSaveKey"
#define CLOUD_KEY_SETTINGS @"iCloudAwesomePiratesSettingsKey"

@interface PersistenceManager ()

@property (nonatomic, copy) id<NSObject, NSCopying, NSCoding> ubiquityIdToken;
@property (nonatomic, copy) id<NSObject, NSCopying, NSCoding> prevUbiquityIdToken;
@property (nonatomic, readonly) id<NSObject, NSCopying, NSCoding> localUbiquityIdToken;

- (void)registerForNotifications;
- (void)unregisterForNotifications;
- (void)cloudInitSucceeded;
- (void)cloudInitFailed;

- (GameStats *)createProfileWithAlias:(NSString *)alias;
- (GameStats *)loadLocalInternal;
- (GameStats *)loadLastKnownUbiqInternal;
- (GameStats *)loadCloudInternal;
- (void)saveInternal:(GameStats *)stats forLocalKey:(NSString *)localKey;

- (NSString *)getUnusedUbiquityIdTokenKey;
- (id<NSObject, NSCopying, NSCoding>)getUbiquityIdTokenForKey:(NSString *)key;
- (NSString *)getUbiquityIdTokenKey:(id<NSObject, NSCopying, NSCoding>)token;
- (id<NSObject, NSCopying, NSCoding>)pollActiveUbiquityIdToken;
- (void)addUbiquityIdToken:(id<NSObject, NSCopying, NSCoding>)ubiqIdToken;

- (NSData *)getDataForKey:(NSString *)key;
- (void)setData:(NSData *)data forKey:(NSString *)key;

- (NSData *)getCloudDataForKey:(NSString *)key;
- (void)setCloudData:(NSData *)data forKey:(NSString *)key;
- (void)iCloudDataDidChangeExternally:(NSNotification *)notification;
- (void)iCloudAccountDidChange:(NSNotification *)notification;

@end


@implementation PersistenceManager

const unsigned char kMaskOffset = 0x10; // If this changes, we lose compatibility with pre-2.0 versions.

static PersistenceManager *PM = nil;

+ (PersistenceManager *)PM {
	@synchronized(self) {
		if (PM == nil) {
			PM = [[self alloc] init];
		}
	}
	return PM;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (PM == nil) {
			PM = [super allocWithZone:zone];
			return PM;
		}
	}
	
	return nil;
}

- (id)copyWithZone:(NSZone *)zone {
	return self;
}

- (id)retain {
	return self;
}

- (NSUInteger)retainCount {
	return NSUIntegerMax;
}

- (oneway void)release {
	
}

- (id)autorelease {
	return self;
}

// ------------ End singleton junk -------------

@synthesize isCloudApproved = mCloudApproved;
@synthesize ubiquityIdToken = mUbiqIdToken;
@synthesize prevUbiquityIdToken = mPrevUbiqIdToken;
@synthesize ubiqIdSupported = mUbiqIdSupported;

- (id)init {
    if (self = [super init]) {
        mCloudApproved = mCloudEnabled = mBusyEnabling = mLocalSaveInProgress = NO;
        mUbiqIdSupported = [[NSFileManager defaultManager] respondsToSelector:@selector(ubiquityIdentityToken)];
        mUbiqIdToken = nil;
        mPrevUbiqIdToken = nil;
    }
    return self;
}

- (void)dealloc {
    [self unregisterForNotifications];
    [super dealloc];
}

- (BOOL)isCloudSupported {
    return NSClassFromString(@"NSUbiquitousKeyValueStore") != nil;
}

- (BOOL)hasActiveCloudAccount {
    return (mCloudEnabled && (!mUbiqIdSupported || self.ubiquityIdToken != nil));
}

- (id<NSObject, NSCopying, NSCoding>)localUbiquityIdToken {
    return self.ubiquityIdToken ? self.ubiquityIdToken : self.prevUbiquityIdToken;
}

- (void)enableCloud {
    if (!self.isCloudApproved || mCloudEnabled || mBusyEnabling)
        return;
    
    if (NSClassFromString(@"NSUbiquitousKeyValueStore")) { // is iOS 5?
        if ([NSUbiquitousKeyValueStore defaultStore]) { // is iCloud enabled
            mBusyEnabling = YES;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                if ([[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil] != nil) {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        [self cloudInitSucceeded];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        [self cloudInitFailed];
                    });
                }
            });
        }    
    } else {
        NSLog(@"iCloud not supported.");
    }
}

- (void)cloudInitSucceeded {
    mBusyEnabling = NO;
    
    [self registerForNotifications];
    self.ubiquityIdToken = [self pollActiveUbiquityIdToken];
    [self addUbiquityIdToken:self.ubiquityIdToken];
    mCloudEnabled = YES;
    
    if (self.hasActiveCloudAccount) {
        NSLog(@"iCloud initialized successfully.");
        if ([[NSUbiquitousKeyValueStore defaultStore] synchronize])
            NSLog(@"iCloud initial synchronize succeeded.");
        else
            NSLog(@"iCloud initial synchronize failed.");
        [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_CLOUD_LOGGED_IN]];
    }
}

- (void)cloudInitFailed {
    mBusyEnabling = NO;
    NSLog(@"iCloud failed to initialize.");
}

- (void)disableCloud {
    mCloudEnabled = NO;
    [self unregisterForNotifications];
}

- (GameStats *)loadLocalInternal {
    GameStats *playerStats = nil;
    
    // Since v2.0
    NSMutableData *data = [NSMutableData mutableDataWithData:[self getDataForKey:LOCAL_KEY_SAVE_GAME]];
    if (data == nil)
        data = [NSMutableData mutableDataWithData:[FileManager loadNSDataWithFilename:@"PlayerStatsData"]]; // v1.0 - 1.1 compatibility
    
    if (data) {
        [data unmaskWithOffset:kMaskOffset];
        @try {
            playerStats = (GameStats *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
        } @catch (NSException *e) {
            NSLog(@"Failed to unarchive local game progress. Error: %@", e.description);
        }
    }
    
    return playerStats;
}

- (GameStats *)loadLastKnownUbiqInternal {
    GameStats *playerStats = nil;
    id<NSObject, NSCopying, NSCoding> lastKnownUbiq = (id<NSObject, NSCopying, NSCoding>)[[NSUserDefaults standardUserDefaults] objectForKey:LOCAL_KEY_LAST_KNOWN_UBIQ];
    if (lastKnownUbiq) {
        NSString *tokenKey = [self getUbiquityIdTokenKey:lastKnownUbiq];
        NSMutableData *data = tokenKey ? [NSMutableData mutableDataWithData:[self getDataForKey:tokenKey]] : nil;
        if (data) {
            [data unmaskWithOffset:kMaskOffset];
            @try {
                playerStats = (GameStats *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
            } @catch (NSException *e) {
                NSLog(@"Failed to unarchive lastKnownUbiq game progress. Error: %@", e.description);
            }
        }
    }
    
    return playerStats;
}

- (GameStats *)loadCloudInternal {
    GameStats *playerStats = nil;
    
    NSMutableData *data = [NSMutableData mutableDataWithData:[self getCloudDataForKey:CLOUD_KEY_SAVE_GAME]];
    if (data) {
        [data unmaskWithOffset:kMaskOffset];
        @try {
            playerStats = (GameStats *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
        } @catch (NSException *e) {
            NSLog(@"Failed to unarchive cloud game progress. Error: %@", e.description);
        }
    }
    
    return playerStats;
}

// NOTE: Are we upgrading in here and then PlayfieldController can't update because it is already done???
- (GameStats *)load {
#ifndef USE_COMPLICATED_CLOUD_LOGIC
    GameStats *playerStats = [self loadLocalInternal];
    
    if (playerStats == nil)
        playerStats = [self createProfileWithAlias:CC_ALIAS_DEFAULT];
    
    return playerStats;
#else
    if (self.ubiqIdSupported) { // iOS 6+
        GameStats *playerStats = nil;
        
        if (mCloudEnabled && self.ubiquityIdToken) {
            GameStats *cloudStats = [self loadCloudInternal];
            playerStats = [self loadLastKnownUbiqInternal];
            
            if (playerStats == nil) {
                NSDictionary *tokenDict = (NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:LOCAL_KEY_UBIQ_ID_TOKENS];
                if (tokenDict && tokenDict.count == 0) {
                    playerStats = [self loadLocalInternal];
                    if (cloudStats && playerStats) {
                        if ([playerStats upgradeToOther:cloudStats]) {
                            [self saveInternal:playerStats forLocalKey:[self getUbiquityIdTokenKey:self.ubiquityIdToken]];
                            [[NSUserDefaults standardUserDefaults] setObject:self.ubiquityIdToken forKey:LOCAL_KEY_LAST_KNOWN_UBIQ];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }
                    }
                }
            }
            
            if (playerStats == nil)
                playerStats = cloudStats;
        } else {
            playerStats = [self loadLastKnownUbiqInternal];
            if (playerStats == nil)
                playerStats = [self loadLocalInternal];
        }
        
        if (playerStats == nil)
            playerStats = [self createProfileWithAlias:CC_ALIAS_DEFAULT];
        
        return playerStats;
    } else { // iOS 5
        GameStats *playerStats = [self loadLocalInternal];
        
        if (mCloudEnabled) {
            GameStats *cloudStats = [self loadCloudInternal];
            if (cloudStats && playerStats) {
                if ([playerStats upgradeToOther:cloudStats])
                    [self saveInternal:playerStats forLocalKey:LOCAL_KEY_SAVE_GAME];
            }
        }
        
        if (playerStats == nil)
            playerStats = [self createProfileWithAlias:CC_ALIAS_DEFAULT];
        
        return playerStats;
    }
#endif
}

- (GameStats *)loadCloud {
    if (self.hasActiveCloudAccount)
        return [self loadCloudInternal];
    else
        return nil;
}

- (NSDictionary *)loadSettings {
    NSDictionary *settings = self.hasActiveCloudAccount ? [[NSUbiquitousKeyValueStore defaultStore] dictionaryForKey:CLOUD_KEY_SETTINGS] : nil;
    return settings;
}

- (void)saveInternal:(GameStats *)stats forLocalKey:(NSString *)localKey {
    assert(stats && localKey);
    
    if (stats == nil || localKey == nil)
        return;
    
    NSMutableData *data = [NSMutableData mutableDataWithData:[NSKeyedArchiver archivedDataWithRootObject:stats]];
    if (data) {
        [data maskWithOffset:kMaskOffset];
        [self setData:data forKey:localKey];
        
        if (self.hasActiveCloudAccount)
            [self setCloudData:data forKey:CLOUD_KEY_SAVE_GAME];
    }
}

- (void)save:(GameStats *)stats {
    if (stats == nil)
        return;
    
#ifndef USE_COMPLICATED_CLOUD_LOGIC
    [self saveInternal:stats forLocalKey:LOCAL_KEY_SAVE_GAME];
#else
    NSMutableData *data = [NSMutableData mutableDataWithData:[NSKeyedArchiver archivedDataWithRootObject:stats]];
    if (data)
        [data maskWithOffset:kMaskOffset];
    else {
        NSLog(@"Error: failed to archive save game data.");
        return;
    }
    
    if (self.ubiqIdSupported) { // iOS 6+
        if (mCloudEnabled && self.ubiquityIdToken) {
            [self saveInternal:stats forLocalKey:[self getUbiquityIdTokenKey:self.ubiquityIdToken]];
            [[NSUserDefaults standardUserDefaults] setObject:self.ubiquityIdToken forKey:LOCAL_KEY_LAST_KNOWN_UBIQ];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else {
            if (self.prevUbiquityIdToken) {
                [self saveInternal:stats forLocalKey:[self getUbiquityIdTokenKey:self.prevUbiquityIdToken]]; // Cloud save will abort, but who cares.
                [[NSUserDefaults standardUserDefaults] setObject:self.prevUbiquityIdToken forKey:LOCAL_KEY_LAST_KNOWN_UBIQ];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else {
                id<NSObject, NSCopying, NSCoding> lastKnownUbiq = (id<NSObject, NSCopying, NSCoding>)[[NSUserDefaults standardUserDefaults] objectForKey:LOCAL_KEY_LAST_KNOWN_UBIQ];
                if (lastKnownUbiq) {
                    [self setData:data forKey:[self getUbiquityIdTokenKey:lastKnownUbiq]];
                } else {
                    [self setData:data forKey:LOCAL_KEY_SAVE_GAME];
                }
            }
        }
    } else { // iOS 5
        [self setData:data forKey:LOCAL_KEY_SAVE_GAME];
        if (mCloudEnabled)
            [self setCloudData:data forKey:CLOUD_KEY_SAVE_GAME];
    }
#endif
}

- (void)saveLocal:(GameStats *)stats {
    mLocalSaveInProgress = YES;
    [self save:stats];
    mLocalSaveInProgress = NO;
}

- (void)saveCloud:(GameStats *)stats {
    assert(stats);
    
    if (stats == nil || !self.hasActiveCloudAccount)
        return;
    
    NSMutableData *data = [NSMutableData mutableDataWithData:[NSKeyedArchiver archivedDataWithRootObject:stats]];
    if (data) {
        [data maskWithOffset:kMaskOffset];
        [self setCloudData:data forKey:CLOUD_KEY_SAVE_GAME];
    }
}

- (void)saveSettings:(NSDictionary *)settings {
    if (settings && self.hasActiveCloudAccount)
        [[NSUbiquitousKeyValueStore defaultStore] setDictionary:settings forKey:CLOUD_KEY_SETTINGS];
}

- (void)registerForNotifications {
    [self unregisterForNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(iCloudDataDidChangeExternally:)
                                                 name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                               object:[NSUbiquitousKeyValueStore defaultStore]];
    if (self.ubiqIdSupported)
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(iCloudAccountDidChange:)
                                                     name:NSUbiquityIdentityDidChangeNotification
                                                   object:nil];
}

- (void)unregisterForNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                                  object:[NSUbiquitousKeyValueStore defaultStore]];
    if (self.ubiqIdSupported)
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSUbiquityIdentityDidChangeNotification
                                                      object:nil];
}

- (void)applicationDidBecomeActive {
    if (!self.isCloudApproved)
        return;
    
    [self registerForNotifications];
    
    if (self.ubiqIdSupported) {
        if (self.ubiquityIdToken && self.ubiquityIdToken == [self pollActiveUbiquityIdToken])
            [[NSUbiquitousKeyValueStore defaultStore] synchronize];
        else if (!mBusyEnabling) {
            [self disableCloud];
            [self enableCloud];
        }
    } else if (!mBusyEnabling) {
        [self disableCloud];
        [self enableCloud];
    }
}

- (void)applicationWillResignActive {
    if (mCloudEnabled)
        [self unregisterForNotifications];
}

- (GameStats *)createProfileWithAlias:(NSString *)alias {
	if (alias == nil)
		alias = CC_ALIAS_DEFAULT;
	return [[[GameStats alloc] initWithAlias:alias] autorelease];
}

- (NSString *)getUnusedUbiquityIdTokenKey {
    NSDictionary *tokenDict = (NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:LOCAL_KEY_UBIQ_ID_TOKENS];
    return [NSString stringWithFormat:@"%@%d", LOCAL_KEY_UBIQ_ID_TOKEN_PREFIX, (tokenDict ? (int)tokenDict.count + 1 : 1)];
}

- (id<NSObject, NSCopying, NSCoding>)getUbiquityIdTokenForKey:(NSString *)key {
    if (key == nil)
        return nil;
    
    NSDictionary *tokenDict = (NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:LOCAL_KEY_UBIQ_ID_TOKENS];
    return tokenDict ? [tokenDict objectForKey:key] : nil;
}

- (NSString *)getUbiquityIdTokenKey:(id<NSObject, NSCopying, NSCoding>)token {
    if (token == nil)
        return nil;
    
    NSDictionary *tokenDict = (NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:LOCAL_KEY_UBIQ_ID_TOKENS];
    if (tokenDict) {
        for (NSString *key in tokenDict) {
            id<NSObject, NSCopying, NSCoding> otherToken = (id<NSObject, NSCopying, NSCoding>)[tokenDict objectForKey:key];
            if ([token isEqual:otherToken])
                return key;
        }
    }
    
    return nil;
}

- (id<NSObject, NSCopying, NSCoding>)pollActiveUbiquityIdToken {
    if (self.ubiqIdSupported) {
        id<NSObject, NSCopying, NSCoding> token = [[NSFileManager defaultManager] ubiquityIdentityToken];
        return token;
    } else
        return nil;
}

- (void)addUbiquityIdToken:(id<NSObject, NSCopying, NSCoding>)token {
    if (token) {
        NSDictionary *tokenDict = (NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:LOCAL_KEY_UBIQ_ID_TOKENS];
        if (tokenDict) {
            // Don't add this token twice
            for (NSString *key in tokenDict) {
                id<NSObject, NSCopying, NSCoding> otherToken = (id<NSObject, NSCopying, NSCoding>)[tokenDict objectForKey:key];
                if ([token isEqual:otherToken])
                    return;
            }
        }
        
        NSMutableDictionary *newTokenDict = tokenDict
            ? [NSMutableDictionary dictionaryWithDictionary:tokenDict]
            : [NSMutableDictionary dictionary];
        [newTokenDict setObject:token forKey:[self getUnusedUbiquityIdTokenKey]];

        [[NSUserDefaults standardUserDefaults] setObject:newTokenDict forKey:LOCAL_KEY_UBIQ_ID_TOKENS];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSData *)getDataForKey:(NSString *)key {
    NSData *data = nil;
    if (key)
        data = (NSData *)[[NSUserDefaults standardUserDefaults] objectForKey:key];
    return data;
}

- (void)setData:(NSData *)data forKey:(NSString *)key {
    if (data && key) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSData dataWithData:data] forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSData *)getCloudDataForKey:(NSString *)key {
    NSData *data = nil;
    if (key && self.hasActiveCloudAccount)
        data = (NSData *)[[NSUbiquitousKeyValueStore defaultStore] objectForKey:key];
    return data;
}

- (void)setCloudData:(NSData *)data forKey:(NSString *)key {
    if (data == nil || key == nil || !self.hasActiveCloudAccount || mLocalSaveInProgress)
        return;
    
    [[NSUbiquitousKeyValueStore defaultStore] setObject:[NSData dataWithData:data] forKey:key];
}

- (void)iCloudDataDidChangeExternally:(NSNotification *)notification {
    BOOL initialDownload = NO, storeServerChange = YES;
    NSDictionary *userInfo = notification.userInfo;
    if (userInfo && [userInfo objectForKey:NSUbiquitousKeyValueStoreChangeReasonKey]) {
        storeServerChange = NO;
        
        NSNumber *reason = (NSNumber *)[userInfo objectForKey:NSUbiquitousKeyValueStoreChangeReasonKey];
        switch ([reason integerValue]) {
            case NSUbiquitousKeyValueStoreInitialSyncChange:
                NSLog(@"Initial iCloud download.");
                initialDownload = YES;
                //NSLog(@"Attempt to write to iCloud key-value storage discarded because an initial download from iCloud has not yet happened.");
                break;
            case NSUbiquitousKeyValueStoreQuotaViolationChange:
                NSLog(@"iCloud key-value store has exceeded its space quota on the iCloud server.");
                break;
            case NSUbiquitousKeyValueStoreAccountChange:
                // Ignore: we listen for NSUbiquityIdentityDidChangeNotification for account changes,
                break;
            case NSUbiquitousKeyValueStoreServerChange:
            default:
                storeServerChange = YES;
                break;
        }
    }
    
    // If it's not an error, assume it's a value change. Docs say userInfo 'can' contain
    // change reason. So if it doesn't contain a reason, we'll assume a value change reason.
    if (initialDownload) {
        [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_CLOUD_DATA_CHANGED]];
        [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_CLOUD_SETTINGS_CHANGED]];
    } else if (storeServerChange) {
        NSArray *changedKeys = (NSArray *)[userInfo objectForKey:NSUbiquitousKeyValueStoreChangedKeysKey];
        if (changedKeys && changedKeys.count > 0) {
            BOOL dispatchedData = NO, dispatchedSettings = NO;
            for (NSString *key in changedKeys) {
                if (dispatchedData && dispatchedSettings)
                    break;
                
                if ([key isEqualToString:CLOUD_KEY_SETTINGS]) {
                    if (!dispatchedSettings) {
                        dispatchedSettings = YES;
                        [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_CLOUD_SETTINGS_CHANGED]];
                    }
                } else {
                    if (!dispatchedData) {
                        dispatchedData = YES;
                        [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_CLOUD_DATA_CHANGED]];
                    }
                }
            }
        }
        else {
            [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_CLOUD_DATA_CHANGED]];
            [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_CLOUD_SETTINGS_CHANGED]];
        }
    }
}

- (void)iCloudAccountDidChange:(NSNotification *)notification {
    id<NSObject, NSCopying, NSCoding> polledToken = [self pollActiveUbiquityIdToken];
    if (self.ubiquityIdToken == polledToken)
        return;
    
    if (self.ubiquityIdToken) {
        self.prevUbiquityIdToken = self.ubiquityIdToken;
        self.ubiquityIdToken = nil;
        [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_CLOUD_LOGGED_OUT]];
    }
    
    self.ubiquityIdToken = polledToken;
    [self addUbiquityIdToken:self.ubiquityIdToken];
    
    if (self.ubiquityIdToken && self.ubiquityIdToken != self.prevUbiquityIdToken) {
        [[NSUbiquitousKeyValueStore defaultStore] synchronize];
        [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_CLOUD_LOGGED_IN]];
    }
}

@end
