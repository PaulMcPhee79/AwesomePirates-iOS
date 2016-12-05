//
//  GameSettings.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 31/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameSettings.h"
#import "PersistenceManager.h"


@interface GameSettings ()

@property (nonatomic,copy) NSString *softwareVersion;

- (BOOL)preferredSettingForKey:(NSString *)key newValue:(BOOL)newValue;
- (double)timestampForKey:(NSString *)key;
- (void)setSettingForKey:(NSString *)key value:(BOOL)value timestamp:(double)timestamp;
- (void)setBoolSettings:(NSDictionary *)dictionary timestamps:(NSDictionary *)timestamps;
- (void)setIntSettings:(NSDictionary *)dictionary;
- (void)setTimeSettings:(NSDictionary *)dictionary;
- (void)setAnnoyingTipsCompleted;
- (void)logSettings;

@end


@implementation GameSettings

@synthesize softwareVersion = mSoftwareVersion;
@synthesize delayedSaveRequired = mDelayedSaveRequired;
@dynamic isInitialVersion,isNewVersion;

const int kInitialRatingDelayInSeconds = 15 * 60;

- (id)init {
	if (self = [super init]) {
        mDelayedSaveRequired = NO;
        mSoftwareVersion = nil;
        mPreferredBoolSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  [NSNumber numberWithBool:NO], GAME_SETTINGS_KEY_WILL_RATE_GAME,
                                  [NSNumber numberWithBool:YES], GAME_SETTINGS_KEY_DID_RATE_GAME,
                                  [NSNumber numberWithBool:NO], GAME_SETTINGS_KEY_FORCE_ACHIEVEMENT_UPDATE,
                                  [NSNumber numberWithBool:YES], GAME_SETTINGS_KEY_SYNCED_ACHIEVEMENTS,
                                  [NSNumber numberWithBool:YES], GAME_SETTINGS_KEY_CLOUD_QUERIED,
                                  [NSNumber numberWithBool:YES], GAME_SETTINGS_KEY_CLOUD_APPROVED,
                                  nil];
		mBoolSettings = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
						 [NSNumber numberWithBool:YES], GAME_SETTINGS_KEY_PLAYED_BEFORE,
                         [NSNumber numberWithBool:YES], GAME_SETTINGS_KEY_GAME_CENTER_ENABLED,
                         [NSNumber numberWithBool:NO], GAME_SETTINGS_KEY_MONTY_INTRODUCED,  
						 [NSNumber numberWithBool:NO], GAME_SETTINGS_KEY_DONE_TUTORIAL,
                         [NSNumber numberWithBool:NO], GAME_SETTINGS_KEY_DONE_TUTORIAL_1,
                         [NSNumber numberWithBool:NO], GAME_SETTINGS_KEY_DONE_TUTORIAL2,
                         [NSNumber numberWithBool:NO], GAME_SETTINGS_KEY_DONE_TUTORIAL3,
                         [NSNumber numberWithBool:NO], GAME_SETTINGS_KEY_DONE_TUTORIAL4,
						 [NSNumber numberWithBool:YES], GAME_SETTINGS_KEY_MUSIC_ON,
						 [NSNumber numberWithBool:YES], GAME_SETTINGS_KEY_SFX_ON,
                         [NSNumber numberWithBool:NO], GAME_SETTINGS_KEY_PLANKING_TIPS,
                         [NSNumber numberWithBool:NO], GAME_SETTINGS_KEY_VOODOO_TIPS,
                         [NSNumber numberWithBool:NO], GAME_SETTINGS_KEY_PICKUP_MOLTEN_TIPS,
                         [NSNumber numberWithBool:NO], GAME_SETTINGS_KEY_PICKUP_CRIMSON_TIPS,
                         [NSNumber numberWithBool:NO], GAME_SETTINGS_KEY_PICKUP_VENOM_TIPS,
                         [NSNumber numberWithBool:NO], GAME_SETTINGS_KEY_PICKUP_ABYSSAL_TIPS,
                         [NSNumber numberWithBool:NO], GAME_SETTINGS_KEY_BRANDY_SLICK_TIPS,
                         [NSNumber numberWithBool:NO], GAME_SETTINGS_KEY_PLAYER_SHIP_TIPS,
                         [NSNumber numberWithBool:NO], GAME_SETTINGS_KEY_TREASURE_FLEET_TIPS,
                         [NSNumber numberWithBool:NO], GAME_SETTINGS_KEY_SILVER_TRAIN_TIPS,
                         [NSNumber numberWithBool:NO], GAME_SETTINGS_KEY_CANNON_OVERHEATED_TIPS,
                         [NSNumber numberWithBool:YES], GAME_SETTINGS_KEY_WILL_RATE_GAME,
                         [NSNumber numberWithBool:NO], GAME_SETTINGS_KEY_DID_RATE_GAME,
                         [NSNumber numberWithBool:NO], GAME_SETTINGS_KEY_FORCE_ACHIEVEMENT_UPDATE,
                         [NSNumber numberWithBool:YES], GAME_SETTINGS_KEY_SYNCED_ACHIEVEMENTS,
                         [NSNumber numberWithBool:YES], GAME_SETTINGS_KEY_FLIPPED_CONTROLS,
                         [NSNumber numberWithBool:NO], GAME_SETTINGS_KEY_CLOUD_QUERIED,
                         [NSNumber numberWithBool:NO], GAME_SETTINGS_KEY_CLOUD_APPROVED,
						 nil];
        mIntSettings = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                        [NSNumber numberWithInt:0], GAME_SETTINGS_KEY_NUM_RUNS_THIS_VERSION,
                        [NSNumber numberWithInt:0], GAME_SETTINGS_KEY_NUM_RATING_PROMPTS_THIS_VERSION,
                        [NSNumber numberWithInt:0], GAME_SETTINGS_KEY_POTION_TIPS_INTRO,
                        nil];
        mTimeSettings = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                         [NSNumber numberWithDouble:(double)CFAbsoluteTimeGetCurrent() + kInitialRatingDelayInSeconds], GAME_SETTINGS_KEY_RATING_PROMPT_ALARM,
                         [NSNumber numberWithDouble:(double)CFAbsoluteTimeGetCurrent()], GAME_SETTINGS_KEY_GC_ACHIEVEMENTS_ALARM,
                         nil];
        
        mBoolTimestamps = [[NSMutableDictionary alloc] initWithCapacity:mBoolSettings.count];
        for (NSString *key in mBoolSettings)
            [mBoolTimestamps setObject:[NSNumber numberWithDouble:(double)CFAbsoluteTimeGetCurrent() - (double)kCFAbsoluteTimeIntervalSince1970] forKey:key];
	}
	return self;
}

- (BOOL)isInitialVersion {
    return ([SOFTWARE_SETTINGS_VERSION_STRING isEqualToString:@"Version_1.0"]);
}

- (BOOL)isNewVersion {
    return (mSoftwareVersion && [mSoftwareVersion isEqualToString:SOFTWARE_SETTINGS_VERSION_STRING] == NO);
}

- (NSDictionary *)settingsDict {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSDictionary dictionaryWithDictionary:mBoolSettings], @"BoolSettings",
            [NSDictionary dictionaryWithDictionary:mBoolTimestamps], @"BoolTimestamps",
            [NSDictionary dictionaryWithDictionary:mIntSettings], @"IntSettings",
            [NSDictionary dictionaryWithDictionary:mTimeSettings], @"TimeSettings",
            nil];
}

- (BOOL)preferredSettingForKey:(NSString *)key newValue:(BOOL)newValue {
    NSNumber *setting = (NSNumber *)[mPreferredBoolSettings objectForKey:key];
    if (setting)
        return [setting boolValue];
    else
        return newValue;
}

- (double)timestampForKey:(NSString *)key {
    NSNumber *timestamp = [mBoolTimestamps objectForKey:key];
    if (timestamp)
        return [timestamp doubleValue];
    else
        return 0;
}

- (void)setBoolSettings:(NSDictionary *)dictionary timestamps:(NSDictionary *)timestamps {
	if (dictionary != mBoolSettings) {
        for (NSString *key in dictionary)
            [mBoolSettings setObject:[dictionary objectForKey:key] forKey:key];
        if (timestamps && timestamps != mBoolTimestamps) {
            for (NSString *key in timestamps)
                [mBoolTimestamps setObject:[timestamps objectForKey:key] forKey:key];
        }
	}
}

- (BOOL)settingForKey:(NSString *)key {
    return [(NSNumber *)[mBoolSettings objectForKey:key] boolValue];
}

- (void)setSettingForKey:(NSString *)key value:(BOOL)value {
    [mBoolSettings setObject:[NSNumber numberWithBool:value] forKey:key];
    [mBoolTimestamps setObject:[NSNumber numberWithDouble:(double)CFAbsoluteTimeGetCurrent()] forKey:key];
    mDelayedSaveRequired = YES;
}

- (void)setSettingForKey:(NSString *)key value:(BOOL)value timestamp:(double)timestamp {
    [mBoolSettings setObject:[NSNumber numberWithBool:value] forKey:key];
    [mBoolTimestamps setObject:[NSNumber numberWithDouble:timestamp] forKey:key];
    mDelayedSaveRequired = YES;
}

- (void)setIntSettings:(NSDictionary *)dictionary {
    if (dictionary != mIntSettings) {
        for (NSString *key in dictionary)
            [mIntSettings setObject:[dictionary objectForKey:key] forKey:key];
	}
}

- (int)valueForKey:(NSString *)key {
    return [(NSNumber *)[mIntSettings objectForKey:key] intValue];
}

- (void)setValue:(int)value forKey:(NSString *)key {
    [mIntSettings setObject:[NSNumber numberWithInt:value] forKey:key];
    mDelayedSaveRequired = YES;
}

- (void)setTimeSettings:(NSDictionary *)dictionary {
    if (dictionary != mTimeSettings) {
        for (NSString *key in dictionary)
            [mTimeSettings setObject:[dictionary objectForKey:key] forKey:key];
	}
}

- (double)timeForKey:(NSString *)key {
    NSNumber *timeSetting = (NSNumber *)[mTimeSettings objectForKey:key];
    
    if (timeSetting)
        return [timeSetting doubleValue];
    else
        return ((double)CFAbsoluteTimeGetCurrent() + 1.0);
}

- (void)setTime:(double)time forKey:(NSString *)key {
    [mTimeSettings setObject:[NSNumber numberWithDouble:time] forKey:key];
    mDelayedSaveRequired = YES;
}

// Returns NO for invalid keys
- (BOOL)hasAlarmExpiredForKey:(NSString *)key {
    const double promptAlarmTime = [self timeForKey:key];
    const double currentTime = CFAbsoluteTimeGetCurrent();
    BOOL hasExpired = (promptAlarmTime < currentTime);
    return hasExpired;
}

- (void)setAnnoyingTipsCompleted {
    [self setSettingForKey:GAME_SETTINGS_KEY_MONTY_INTRODUCED value:YES];
    [self setSettingForKey:GAME_SETTINGS_KEY_DONE_TUTORIAL value:YES];
    [self setSettingForKey:GAME_SETTINGS_KEY_DONE_TUTORIAL_1 value:YES];
    [self setSettingForKey:GAME_SETTINGS_KEY_DONE_TUTORIAL2 value:YES];
    [self setSettingForKey:GAME_SETTINGS_KEY_DONE_TUTORIAL3 value:YES];
    [self setSettingForKey:GAME_SETTINGS_KEY_DONE_TUTORIAL4 value:YES];
    [self setSettingForKey:GAME_SETTINGS_KEY_PLANKING_TIPS value:YES];
    [self setSettingForKey:GAME_SETTINGS_KEY_VOODOO_TIPS value:YES];
    [self setSettingForKey:GAME_SETTINGS_KEY_PICKUP_MOLTEN_TIPS value:YES];
    [self setSettingForKey:GAME_SETTINGS_KEY_PICKUP_CRIMSON_TIPS value:YES];
    [self setSettingForKey:GAME_SETTINGS_KEY_PICKUP_VENOM_TIPS value:YES];
    [self setSettingForKey:GAME_SETTINGS_KEY_PICKUP_ABYSSAL_TIPS value:YES];
    [self setSettingForKey:GAME_SETTINGS_KEY_BRANDY_SLICK_TIPS value:YES];
    [self setSettingForKey:GAME_SETTINGS_KEY_PLAYER_SHIP_TIPS value:YES];
    [self setSettingForKey:GAME_SETTINGS_KEY_TREASURE_FLEET_TIPS value:YES];
    [self setSettingForKey:GAME_SETTINGS_KEY_SILVER_TRAIN_TIPS value:YES];
    [self setSettingForKey:GAME_SETTINGS_KEY_CANNON_OVERHEATED_TIPS value:YES];
    [self setSettingForKey:GAME_SETTINGS_KEY_WILL_RATE_GAME value:NO];
    [self setSettingForKey:GAME_SETTINGS_KEY_DID_RATE_GAME value:YES];
    [self setSettingForKey:GAME_SETTINGS_KEY_POTION_TIPS_INTRO value:YES];
    [self setSettingForKey:GAME_SETTINGS_KEY_CLOUD_QUERIED value:YES];
    [self setValue:2 forKey:GAME_SETTINGS_KEY_POTION_TIPS_INTRO];
}

- (void)resetTutorialPrompts {
    [self setSettingForKey:GAME_SETTINGS_KEY_DONE_TUTORIAL value:NO];
    [self setSettingForKey:GAME_SETTINGS_KEY_DONE_TUTORIAL_1 value:NO];
    [self setSettingForKey:GAME_SETTINGS_KEY_DONE_TUTORIAL2 value:NO];
    [self setSettingForKey:GAME_SETTINGS_KEY_DONE_TUTORIAL3 value:NO];
    [self setSettingForKey:GAME_SETTINGS_KEY_DONE_TUTORIAL4 value:NO];
    [self setSettingForKey:GAME_SETTINGS_KEY_PLANKING_TIPS value:NO];
    [self setSettingForKey:GAME_SETTINGS_KEY_VOODOO_TIPS value:NO];
    [self setSettingForKey:GAME_SETTINGS_KEY_PICKUP_MOLTEN_TIPS value:NO];
    [self setSettingForKey:GAME_SETTINGS_KEY_PICKUP_CRIMSON_TIPS value:NO];
    [self setSettingForKey:GAME_SETTINGS_KEY_PICKUP_VENOM_TIPS value:NO];
    [self setSettingForKey:GAME_SETTINGS_KEY_PICKUP_ABYSSAL_TIPS value:NO];
    [self setSettingForKey:GAME_SETTINGS_KEY_BRANDY_SLICK_TIPS value:NO];
    [self setSettingForKey:GAME_SETTINGS_KEY_PLAYER_SHIP_TIPS value:NO];
    [self setSettingForKey:GAME_SETTINGS_KEY_TREASURE_FLEET_TIPS value:NO];
    [self setSettingForKey:GAME_SETTINGS_KEY_SILVER_TRAIN_TIPS value:NO];
    [self setSettingForKey:GAME_SETTINGS_KEY_CANNON_OVERHEATED_TIPS value:NO];
    [self setSettingForKey:GAME_SETTINGS_KEY_POTION_TIPS_INTRO value:NO];
    [self setValue:0 forKey:GAME_SETTINGS_KEY_POTION_TIPS_INTRO];
}

- (void)loadSettings {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	if (prefs != nil) {
        self.softwareVersion = (NSString *)[prefs objectForKey:@"SoftwareVersion"];
		NSDictionary *dict = (NSDictionary *)[prefs objectForKey:@"BoolSettings"];
		if (dict) [self setBoolSettings:dict timestamps:(NSDictionary *)[prefs objectForKey:@"BoolTimestamps"]];
        
        dict = (NSDictionary *)[prefs objectForKey:@"IntSettings"];
        if (dict) [self setIntSettings:dict];
        
        dict = (NSDictionary *)[prefs objectForKey:@"TimeSettings"];
        if (dict) [self setTimeSettings:dict];
		
		if ([self settingForKey:GAME_SETTINGS_KEY_PLAYED_BEFORE] == NO)
			[self setSettingForKey:GAME_SETTINGS_KEY_PLAYED_BEFORE value:YES];
	} else {
        // Don't want this error to make us sit through the tutorial, tips & prompts every time we play.
        self.softwareVersion = SOFTWARE_SETTINGS_VERSION_STRING;
		[self setAnnoyingTipsCompleted];
		NSLog(@"Failed to load Game Settings with NSUserDefaults.");
	}
    
    if (self.softwareVersion == nil || self.isNewVersion) {
        [self setValue:1 forKey:GAME_SETTINGS_KEY_NUM_RUNS_THIS_VERSION];
        [self setValue:0 forKey:GAME_SETTINGS_KEY_NUM_RATING_PROMPTS_THIS_VERSION];
        [self setSettingForKey:GAME_SETTINGS_KEY_WILL_RATE_GAME value:YES];
        [self setSettingForKey:GAME_SETTINGS_KEY_DID_RATE_GAME value:NO];
        
        if (self.isNewVersion)
            [self setTime:(double)CFAbsoluteTimeGetCurrent() + kInitialRatingDelayInSeconds forKey:GAME_SETTINGS_KEY_RATING_PROMPT_ALARM];
    } else {
        [self setValue:[self valueForKey:GAME_SETTINGS_KEY_NUM_RUNS_THIS_VERSION]+1 forKey:GAME_SETTINGS_KEY_NUM_RUNS_THIS_VERSION];
    }
    
    [self saveSettings];
}

- (void)saveSettings {
	[self saveSettingsLocal];
    [[PersistenceManager PM] saveSettings:self.settingsDict];
}

- (void)saveSettingsLocal {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	if (prefs != nil) {
        [prefs setObject:SOFTWARE_SETTINGS_VERSION_STRING forKey:@"SoftwareVersion"];
		[prefs setObject:mBoolSettings forKey:@"BoolSettings"];
        [prefs setObject:mBoolTimestamps forKey:@"BoolTimestamps"];
        [prefs setObject:mIntSettings forKey:@"IntSettings"];
        [prefs setObject:mTimeSettings forKey:@"TimeSettings"];
		[prefs synchronize];
        mDelayedSaveRequired = NO;
	} else {
		NSLog(@"Failed to save Game Settings with NSUserDefaults.");
	}
    
    //[self logSettings];
}

- (void)syncWithSettings:(NSDictionary *)settings {
    if (settings == nil)
        return;
    
    // Special values
    int numRunsThisVersion = [self valueForKey:GAME_SETTINGS_KEY_NUM_RUNS_THIS_VERSION];
    int potionTipsIntro = [self valueForKey:GAME_SETTINGS_KEY_POTION_TIPS_INTRO];
    
    NSDictionary *dict = (NSDictionary *)[settings objectForKey:@"BoolSettings"];
    if (dict) {
        NSDictionary *timestamps = (NSDictionary *)[settings objectForKey:@"BoolTimestamps"];
        for (NSString *key in dict) {
            BOOL newValue = [(NSNumber *)[dict objectForKey:key] boolValue];
            NSNumber *timestamp = timestamps == nil ? nil : (NSNumber *)[timestamps objectForKey:key];
            
            if (timestamp && [timestamp doubleValue] > [self timestampForKey:key] && [self preferredSettingForKey:key newValue:newValue] == newValue)
                [self setSettingForKey:key value:newValue timestamp:[timestamp doubleValue]];
        }
    }
    
    dict = (NSDictionary *)[settings objectForKey:@"IntSettings"];
    if (dict) [self setIntSettings:dict];
    
    //dict = (NSDictionary *)[settings objectForKey:@"TimeSettings"];
    //if (dict) [self setTimeSettings:dict];
    
    if (numRunsThisVersion > [self valueForKey:GAME_SETTINGS_KEY_NUM_RUNS_THIS_VERSION])
        [self setValue:numRunsThisVersion forKey:GAME_SETTINGS_KEY_NUM_RUNS_THIS_VERSION];
    if (potionTipsIntro > [self valueForKey:GAME_SETTINGS_KEY_POTION_TIPS_INTRO])
        [self setValue:potionTipsIntro forKey:GAME_SETTINGS_KEY_POTION_TIPS_INTRO];
}

- (void)logSettings {
	NSLog(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
}

- (void)dealloc {
    self.softwareVersion = nil;
    [mPreferredBoolSettings release]; mPreferredBoolSettings = nil;
	[mBoolSettings release]; mBoolSettings = nil;
    [mBoolTimestamps release]; mBoolTimestamps = nil;
    [mIntSettings release]; mIntSettings = nil;
    [mTimeSettings release]; mTimeSettings = nil;
	[super dealloc];
}

@end
