//
//  SceneController.h
//  Pirates
//
//  Created by Paul McPhee on 3/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SpriteLayerManager.h"
#import "AudioPlayer.h"
#import "AchievementManager.h"
#import "ObjectivesManager.h"
#import "CCOFManager.h"
#import "TextureManager.h"
#import "CacheManager.h"
#import "GameCoder.h"
#import "Idol.h"
#import "Potion.h"

//#define DEBUG_AUTOMATOR 1

// Title
#define RESOURCE_CACHE_SHOP_BUBBLE_GADGETS @"ResCacheShopBubbleGadgets"
#define RESOURCE_CACHE_SHOP_BUBBLE_VOODOO @"ResCacheShopBubbleVoodoo"
#define RESOURCE_CACHE_SHOP_BUBBLE_POTIONS @"ResCacheShopBubblePotions"
#define RESOURCE_CACHE_SHOP_BUBBLE_SHIPS @"ResCacheShopBubbleShips"
#define RESOURCE_CACHE_SHOP_BUBBLE_CANNONS @"ResCacheShopBubbleCannons"
#define RESOURCE_CACHE_LOGBOOK_GADGETS @"ResCacheLogbookGadgets"
#define RESOURCE_CACHE_LOGBOOK_VOODOO @"ResCacheLogbookVoodoo"

// Playfield
#define RESOURCE_CACHE_COMBAT_TEXT @"ResCacheCombatText"
#define RESOURCE_CACHE_MANAGERS @"ResCacheManagers"

@class Actor,Prop,VoodooManager,NumericValueChangedEvent,CodeProfiler,Prisoner,ShipActor;

@interface SceneController : NSObject {
	BOOL mHasPauseMenu;
	BOOL mScenePaused;
    BOOL mAmbienceShouldPlay;
    BOOL mTimeSlowed;
    BOOL mFlipped;
	BOOL mLocked;
	BOOL mDestructLock;
	NSString *mSceneKey;
	
	float mViewWidth;
	float mViewHeight;
	
	// Pause menu
	SPButton *mPauseButton;
	SPButton *mQuitButton;
	SPButton *mResumeButton;
	SPButton *mRetryButton;
    SPButton *mFlipControlsButton;
	Prop *mPauseProp;
	Prop *mPauseMenu;
	SPSprite *mPauseFrame;
	SPJuggler *mPauseJuggler;
    SPJuggler *mSpecialJuggler;
	
	// Help (Montgomery)
	SPTextureAtlas *mHelpAtlas;
	
	SPSprite *mBaseSprite;
    UIImage *mScreenshotCache;
	
	// These should be NSMutableSets. I doubt the efficiency of arrays is worth the danger.
	NSMutableArray *mActors;
	NSMutableArray *mAdvActors;
	NSMutableArray *mActorsAddQueue;
	NSMutableArray *mActorsRemoveQueue;
	
	NSMutableArray *mProps;
	NSMutableArray *mAdvProps;
	NSMutableArray *mPropsAddQueue;
	NSMutableArray *mPropsRemoveQueue;
	NSMutableSet *mOrientedProps;
	
    NSMutableDictionary *mRandomMessages;
    
	SPJuggler *mJuggler;
	SPJuggler *mSpamJuggler;
    SPJuggler *mHudJuggler;
	SpriteLayerManager *mSpriteLayerManager;
	NSMutableDictionary *mCacheManagers;
    CodeProfiler *mProfiler;
}


@property (nonatomic,readonly) int topCategory;
@property (nonatomic,readonly) int helpCategory;
@property (nonatomic,readonly) int pauseCategory;
@property (nonatomic,readonly) uint allPrizesBitmap;
@property (nonatomic,readonly) BOOL scenePaused;
@property (nonatomic,readonly) BOOL touchableDefault;
@property (nonatomic,readonly) BOOL flipped;
@property (nonatomic,readonly) BOOL isTimeSlowed;
@property (nonatomic,readonly) float viewWidth;
@property (nonatomic,readonly) float viewHeight;
@property (nonatomic,readonly) double timeSlowedFactor;
@property (nonatomic,readonly) NSString *sceneKey;
@property (nonatomic,readonly) NSString *fontKey;
@property (nonatomic,readonly) NSString *pauseTextureName;
@property (nonatomic,readonly) SPTextureAtlas *helpAtlas;
@property (nonatomic,readonly) SPTextureAtlas *achievementAtlas;
@property (nonatomic,readonly) NSMutableArray *actors;
@property (nonatomic,readonly) NSMutableArray *props;
@property (nonatomic,readonly) SPJuggler *juggler;
@property (nonatomic,readonly) SPJuggler *spamJuggler;
@property (nonatomic,readonly) SPJuggler *hudJuggler;
@property (nonatomic,readonly) SPJuggler *specialJuggler;
@property (nonatomic,retain) SpriteLayerManager *spriteLayerManager;
@property (nonatomic,readonly) AudioPlayer *audioPlayer;
@property (nonatomic,readonly) AchievementManager *achievementManager;
@property (nonatomic,readonly) ObjectivesManager *objectivesManager;
@property (nonatomic,readonly) CCOFManager *ofManager;
@property (nonatomic,readonly) TextureManager *tm;
@property (nonatomic,readonly) float lootModifier;
@property (nonatomic,readonly) float fps;
@property (nonatomic,readonly) CodeProfiler *profiler;

- (void)setupController;
- (void)setupCaches;
- (void)setupSaveOptions;
- (void)willGainSceneFocus;
- (void)willLoseSceneFocus;
- (void)attachEventListeners;
- (void)detachEventListeners;
- (void)preloadComplete;
- (void)playAmbientSounds;
- (void)loadSceneState:(GameCoder *)coder;
- (void)saveSceneState:(GameCoder *)coder;
- (void)screenConnected;
- (void)screenDisconnected;
- (void)flip:(BOOL)enable;
- (void)addToStageAtIndex:(int)index;
- (void)updateOrientation:(UIDeviceOrientation)orientation;
- (void)registerOrientationUpdatesForProp:(Prop *)prop;
- (void)unregisterOrientationUpdatesForProp:(Prop *)prop;
- (void)removeCachedResources;
- (void)awardPrizes:(uint)prizes;
- (void)printProfilerReport;
- (void)hideHintByName:(NSString *)name;
- (void)enableSlowedTime:(BOOL)enable;
- (void)requestTargetForPursuer:(NSObject *)pursuer;
- (void)prisonerOverboard:(Prisoner *)prisoner ship:(ShipActor *)ship;
- (NSString *)fontKeyForPrefix:(NSString *)prefix;
- (BOOL)isInVisibleBounds:(float)x y:(float)y;
- (int)objectivesCategoryForViewType:(ObjectivesViewType)type;
- (Idol *)idolForKey:(uint)key;
- (Idol *)equippedIdolForKey:(uint)key;
- (BOOL)isEquippedIdolMaxedForKey:(uint)key;
- (Potion *)potionForKey:(uint)key;
- (BOOL)isPotionActiveForKey:(uint)key;
- (NSArray *)activePotions;
- (void)activatePotion:(BOOL)activate forKey:(uint)key;
- (SPTexture *)textureByName:(NSString *)name;
- (SPTexture *)textureByName:(NSString *)name cacheGroup:(NSString *)cacheGroup;
- (SPTexture *)textureByName:(NSString *)name atlasName:(NSString *)atlasName;
- (SPTexture *)textureByName:(NSString *)name atlasName:(NSString *)atlasName cacheGroup:(NSString *)cacheGroup;
- (SPTexture *)cachedTextureByName:(NSString *)name;
- (NSArray *)texturesStartingWith:(NSString *)name;
- (NSArray *)texturesStartingWith:(NSString *)name cacheGroup:(NSString *)cacheGroup;
- (NSArray *)texturesStartingWith:(NSString *)name atlasName:(NSString *)atlasName cacheGroup:(NSString *)cacheGroup;
- (CacheManager *)cacheManagerByName:(NSString *)name;
- (void)checkinAtlasByName:(NSString *)name;
- (void)advanceTime:(double)time;
- (Actor *)actorById:(int)actorId;
- (void)addActor:(Actor *)actor;
- (void)removeActor:(Actor *)actor;
- (void)addQueuedActors;
- (void)removeQueuedActors;
- (void)addProp:(Prop *)prop;
- (void)removeProp:(Prop *)prop;
- (void)addQueuedProps;
- (void)removeQueuedProps;
- (BOOL)doesRandomMessageExistForKey:(NSString *)key;
- (void)addRandomMessageQueue:(NSMutableArray *)queue forKey:(NSString *)key;
- (NSString *)randomMessageForKey:(NSString *)key;
- (void)createPauseMenu;
- (void)addPauseButton;
- (void)removePauseButton;
- (void)showPauseButton:(BOOL)value;
- (void)overridingPause;
- (void)displayPauseMenu;
- (void)dismissPauseMenu;
- (void)sceneWillPause;
- (void)resume;
- (void)retry;
- (void)quit;
- (UIImage *)screenshot;
- (void)clearScreenshotCache;
- (void)checkinAtlases;
- (void)destroyHelpAtlas;
- (void)destroyScene;

@end
