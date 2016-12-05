//
//  GameSettings.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 31/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

// String keys
#define SOFTWARE_SETTINGS_VERSION_STRING @"Version_2.1" // 1.0, 1.01, 1.1, 2.0, 2.1

// Boolean setting keys
#define GAME_SETTINGS_KEY_PLAYED_BEFORE @"PlayedBefore"
#define GAME_SETTINGS_KEY_GAME_CENTER_ENABLED @"GameCenterEnabled"
#define GAME_SETTINGS_KEY_MONTY_INTRODUCED @"MontyIntroduced"
#define GAME_SETTINGS_KEY_DONE_TUTORIAL @"DoneTutorial"
#define GAME_SETTINGS_KEY_DONE_TUTORIAL_1 @"DoneTutorial_1"
#define GAME_SETTINGS_KEY_DONE_TUTORIAL2 @"DoneTutorial2"
#define GAME_SETTINGS_KEY_DONE_TUTORIAL3 @"DoneTutorial3"
#define GAME_SETTINGS_KEY_DONE_TUTORIAL4 @"DoneTutorial4"
#define GAME_SETTINGS_KEY_MUSIC_ON @"MusicOn"
#define GAME_SETTINGS_KEY_SFX_ON @"SfxOn"
#define GAME_SETTINGS_KEY_PLANKING_TIPS @"PlankingTips"
#define GAME_SETTINGS_KEY_VOODOO_TIPS @"VoodooTips"
#define GAME_SETTINGS_KEY_PICKUP_MOLTEN_TIPS @"PickupMoltenTips"
#define GAME_SETTINGS_KEY_PICKUP_CRIMSON_TIPS @"PickupCrimsonTips"
#define GAME_SETTINGS_KEY_PICKUP_VENOM_TIPS @"PickupVenomTips"
#define GAME_SETTINGS_KEY_PICKUP_ABYSSAL_TIPS @"AbyssalShotTips"
#define GAME_SETTINGS_KEY_BRANDY_SLICK_TIPS @"BrandySlickTips"
#define GAME_SETTINGS_KEY_PLAYER_SHIP_TIPS @"PlayerShipTips"
#define GAME_SETTINGS_KEY_TREASURE_FLEET_TIPS @"TreasureFleetTips"
#define GAME_SETTINGS_KEY_SILVER_TRAIN_TIPS @"SivlerTrainTips"
#define GAME_SETTINGS_KEY_CANNON_OVERHEATED_TIPS @"CannonOverheatedTips"
#define GAME_SETTINGS_KEY_WILL_RATE_GAME @"WillRateGame"
#define GAME_SETTINGS_KEY_DID_RATE_GAME @"DidRateGame"
#define GAME_SETTINGS_KEY_FORCE_ACHIEVEMENT_UPDATE @"ForceAchievementUpdate"
#define GAME_SETTINGS_KEY_SYNCED_ACHIEVEMENTS @"SyncedAchievements" // This value is ignored since v2.0
#define GAME_SETTINGS_KEY_FLIPPED_CONTROLS @"FlippedControls"
#define GAME_SETTINGS_KEY_CLOUD_QUERIED @"CloudQueried"
#define GAME_SETTINGS_KEY_CLOUD_APPROVED @"CloudApproved"

// Int setting keys
#define GAME_SETTINGS_KEY_NUM_RUNS_THIS_VERSION @"NumRunsThisVersion"
#define GAME_SETTINGS_KEY_NUM_RATING_PROMPTS_THIS_VERSION @"NumRatingPromptsThisVersion"
#define GAME_SETTINGS_KEY_POTION_TIPS_INTRO @"PotionTipsIntro"

// Time settings keys
#define GAME_SETTINGS_KEY_RATING_PROMPT_ALARM @"RatingPromptAlarm"
#define GAME_SETTINGS_KEY_GC_ACHIEVEMENTS_ALARM @"GCAchievementsAlarm"

@interface GameSettings : NSObject {
    BOOL mDelayedSaveRequired;
    NSString *mSoftwareVersion;
    
    NSDictionary *mPreferredBoolSettings;
	NSMutableDictionary *mBoolSettings;
    NSMutableDictionary *mBoolTimestamps;
    NSMutableDictionary *mIntSettings;
    NSMutableDictionary *mTimeSettings;
}

@property (nonatomic,readonly) BOOL delayedSaveRequired;
@property (nonatomic,readonly) BOOL isInitialVersion;
@property (nonatomic,readonly) BOOL isNewVersion;
@property (nonatomic,readonly) NSDictionary *settingsDict;


- (BOOL)settingForKey:(NSString *)key;
- (void)setSettingForKey:(NSString *)key value:(BOOL)value;
- (int)valueForKey:(NSString *)key;
- (void)setValue:(int)value forKey:(NSString *)key;
- (double)timeForKey:(NSString *)key;
- (void)setTime:(double)time forKey:(NSString *)key;
- (BOOL)hasAlarmExpiredForKey:(NSString *)key;
- (void)loadSettings;
- (void)saveSettings;
- (void)saveSettingsLocal;
- (void)syncWithSettings:(NSDictionary *)settings;
- (void)resetTutorialPrompts;

@end
