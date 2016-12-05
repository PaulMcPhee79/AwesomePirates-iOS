//
//  GameController.h
//  Pirates
//
//  Created by Paul McPhee on 3/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CutlassCoveViewController.h"
#import "TimeKeeper.h"
#import "ResourcesLoadedEvent.h"
#import "ThisTurn.h"

#define GC_CHALLENGE_CREW_MAX 100000
#define GCTRL [GameController GC]

typedef struct {
	int merchantShipsMin;
	// Max concurrently active
	int merchantShipsMax;
	int pirateShipsMax;
	int navyShipsMax;
	
	// Spawn chance per think interval
	int merchantShipsChance;
	int pirateShipsChance;
	int navyShipsChance;
	int specialShipsChance;
	
	// Fleet timer
	BOOL fleetShouldSpawn;
	double fleetTimer;
	
	// Game level attributes and factors
	int difficulty;				// Difficulty level: gives finer granularity to state changes. Currently increased via TimeOfDay changes in PlayfieldController.
	int difficultyIncrement;	// Baseline increase for difficulty changes.
	float difficultyFactor;		// Scales difficulty changes;
	float aiModifier;			// Multiplier / Divider for actor speed, control, cannon accuracy. 
	int stateCeiling;			// Once difficulty surpasses this value, we advance to the next state.
	int state;					// Initiates stepped variable transitions.
} AiKnob;

@class CutlassCoveViewController,SPView,SceneController,PlayerDetails,PlayerShip,AudioPlayer,AchievementManager,GameStats,ObjectivesManager,
GameSettings,ProfileManager,GameCoder,TextureManager,ControllerFactory,CCOFManager,CCiTunesManager;

@interface GameController : SPEventDispatcher {
    BOOL mIsGameDataValid;
	BOOL mPaused;
	BOOL mGameSaved;
	BOOL mOrientationLocked;
	BOOL mAudioLock;
    BOOL mIsViewLandscape;
    BOOL mGameWindowDidLoseFocus;
    BOOL mIsTwitterActive;
    BOOL mIsSKStoreActive;
    BOOL mIsAppActive;
    
    float mFps;
    
	ThisTurn *mThisTurn;
	UIDeviceOrientation mDeviceOrientation;
	GameSettings *mGameSettings;
	
	GameState mState;
	GameState mQueuedState;
	
	SceneController *mCurrentScene;
    NSMutableDictionary *mCachedResources;
	
	GameCoder *mGameCoder;
	
	SPStage *mStage;
	PlayerDetails *mPlayerDetails;
	PlayerShip *mPlayerShip;
	TimeKeeper *mTimeKeeper;
	AiKnob mAiKnob;
	NSMutableArray *mAudioPlayerDump;
	NSMutableDictionary *mAudioPlayers;
	AudioPlayer *mQueuedAudioPlayer;
	AchievementManager *mAchievementManager;
    ObjectivesManager *mObjectivesManager;
    CCOFManager *mOFManager;
	TextureManager *mTextureManager;
    CCiTunesManager *miTunesManager;
	ControllerFactory *mControllerFactory;
	CutlassCoveViewController *mViewController; // Weak reference
}

+ (GameController *)GC;

@property (nonatomic,readonly) BOOL isGameDataValid;
@property (nonatomic,assign) BOOL paused;
@property (nonatomic,assign) BOOL gameSaved;
@property (nonatomic,assign) BOOL orientationLocked;
@property (nonatomic,assign) BOOL assistedAiming;
@property (nonatomic,assign) BOOL isViewLandscape;
@property (nonatomic,assign) BOOL gameWindowDidLoseFocus;
@property (nonatomic,assign) BOOL isTwitterActive;
@property (nonatomic,assign) BOOL isSKStoreActive;
@property (nonatomic,assign) BOOL isAppActive;
@property (nonatomic,copy) ThisTurn *thisTurn;
@property (nonatomic,readonly) UIDeviceOrientation deviceOrientation;
@property (nonatomic,readonly) GameSettings *gameSettings;
@property (nonatomic,assign) GameState state;
@property (nonatomic,retain) SPStage *stage;
@property (nonatomic,readonly) PlayerDetails *playerDetails;
@property (nonatomic,retain) PlayerShip *playerShip;
@property (nonatomic,readonly) TimeKeeper *timeKeeper;
@property (nonatomic,assign) TimeOfDay timeOfDay;
@property (nonatomic,readonly) float fps;
@property (nonatomic,readonly) float fpsFactor;
@property (nonatomic,readonly) AiKnob *aiKnob;
@property (nonatomic,readonly) AudioPlayer *audioPlayer;
@property (nonatomic,readonly) AudioPlayer *queuedAudioPlayer;
@property (nonatomic,readonly) AchievementManager *achievementManager;
@property (nonatomic,readonly) ObjectivesManager *objectivesManager;
@property (nonatomic,readonly) CCOFManager *ofManager;
@property (nonatomic,readonly) TextureManager *textureManager;
@property (nonatomic,readonly) CCiTunesManager *iTunesManager;
@property (nonatomic,readonly) SPTextureAtlas *achievementAtlas;
@property (nonatomic,readonly) GameStats *gameStats;
@property (nonatomic,readonly) ProfileManager *profileManager;
@property (nonatomic,readonly) SPView *view;
@property (nonatomic,readonly) CutlassCoveViewController *viewController;
@property (nonatomic,readonly) GameCoder *gameCoder;

- (void)setupWithStage:(SPStage *)stage viewController:(CutlassCoveViewController *)viewController ofDelegate:(CCOFManager *)ofDelegate;
- (void)invalidGameDataWasFound;
- (void)startSparrow;
- (void)stopSparrow;
- (void)advanceTime:(double)time;
- (void)setGameMode:(NSString *)mode;
- (void)prepareForNewGame;
- (void)saveProgress;
- (AudioPlayer *)audioPlayerByName:(NSString *)key;
- (void)addAudioPlayer:(AudioPlayer *)audioPlayer byName:(NSString *)key;
- (void)removeAudioPlayerByName:(NSString *)key;
- (void)markAudioPlayerForDestructionByName:(NSString *)key;
- (GameState)sceneStateForKey:(NSString *)key;
- (NSString *)sceneKeyForState:(GameState)state;
- (void)transitionToNewState:(GameState)state;
- (void)orientationDetected:(UIEvent *)event;
- (void)overridingPause;
- (BOOL)processEndOfTurn;
- (void)cacheResource:(NSObject *)resource forKey:(NSString *)key; // Pass nil to remove key from cache. Pass nil,nil to empty cache.
- (NSObject *)cachedResourceForKey:(NSString *)key;
- (void)didReceiveMemoryWarning;
- (void)applicationWillTerminate;

@end
