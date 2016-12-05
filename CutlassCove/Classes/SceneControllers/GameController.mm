//
//  GameController.m
//  Pirates
//
//  Created by Paul McPhee on 3/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "GameController.h"
#import "SceneController.h"
#import "ControllerFactory.h"
#import "GameSettings.h"
#import "PlayerDetails.h"
#import "PlayerShip.h"
#import "ShipDetails.h"[gc.viewController presentViewController:tweetSheet animated:YES completion:nil];
#import "CannonDetails.h"
#import "ShipFactory.h"
#import "CannonFactory.h"
#import "ActorAi.h"
#import "AudioPlayer.h"
#import "AchievementManager.h"
#import "ObjectivesManager.h"
#import "CCOFManager.h"
#import "ProfileManager.h"
#import "SPEventDispatcher_Extension.h"
#import "NumericValueChangedEvent.h"
#import "CCMiscConstants.h"
#import "GameCoder.h"
#import "TextureManager.h"
#import "CCiTunesManager.h"
#import "ThreadSafetyManager.h"
#import "Globals.h"


@interface GameController ()

// For fading out splash imageview
- (void)fadeSplashViewOverTime:(float)duration;
- (void)animationDidStart:(NSString *)animationID context:(void *)context;
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
 
- (void)setFramerate:(float)framerate;
- (void)handleScreenConnectNotification:(NSNotification *)aNotification;
- (void)handleScreenDisconnectNotification:(NSNotification *)aNotification;

- (void)commitQueuedState:(GameState)state;

- (void)didReceiveWindowFocus:(NSNotification *)notification;
- (void)setupScene;

- (void)loadScene:(GameState)state;
- (void)loadSceneAsync:(GameState)state;
- (void)unloadScene:(SceneController *)scene;
- (void)onSceneLoaded:(NSString *)sceneName error:(NSString *)error;

- (AudioPlayer *)audioPlayerForState:(GameState)state;
- (void)destroyAudioPlayer:(AudioPlayer *)audioPlayer;
- (void)destroyAudioPlayerByName:(NSString *)key;
- (void)destroyAllAudioPlayers;

- (void)applyGameState;
- (void)loadGameState;
- (void)saveGameState;

@end


@implementation GameController

static GameController *GC = nil;

+ (GameController *)GC {
	@synchronized(self) {
		if (GC == nil) {
			GC = [[self alloc] init];
		}
	}
	return GC;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (GC == nil) {
			GC = [super allocWithZone:zone];
			return GC;
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

@synthesize isGameDataValid = mIsGameDataValid;
@synthesize paused = mPaused;
@synthesize gameSaved = mGameSaved;
@synthesize orientationLocked = mOrientationLocked;
@synthesize isViewLandscape = mIsViewLandscape;
@synthesize gameWindowDidLoseFocus = mGameWindowDidLoseFocus;
@synthesize isTwitterActive = mIsTwitterActive;
@synthesize isSKStoreActive = mIsSKStoreActive;
@synthesize isAppActive = mIsAppActive;
@synthesize fps = mFps;
@synthesize deviceOrientation = mDeviceOrientation;
@synthesize thisTurn = mThisTurn;
@synthesize gameSettings = mGameSettings;
@synthesize state = mState;
@synthesize stage = mStage;
@synthesize playerDetails = mPlayerDetails;
@synthesize playerShip = mPlayerShip;
@synthesize timeKeeper = mTimeKeeper;
@synthesize queuedAudioPlayer = mQueuedAudioPlayer;
@synthesize achievementManager = mAchievementManager;
@synthesize objectivesManager = mObjectivesManager;
@synthesize ofManager = mOFManager;
@synthesize textureManager = mTextureManager;
@synthesize iTunesManager = miTunesManager;
@synthesize viewController = mViewController;
@synthesize gameCoder = mGameCoder;
@dynamic audioPlayer,timeOfDay,aiKnob,gameStats,achievementAtlas,profileManager,assistedAiming,fpsFactor;

- (void)setupWithStage:(SPStage *)stage viewController:(CutlassCoveViewController *)viewController ofDelegate:(CCOFManager *)ofDelegate {
    mIsGameDataValid = YES;
	mPaused = NO;
	mGameSaved = YES;
	mOrientationLocked = NO;
    mGameWindowDidLoseFocus = NO;
    mIsTwitterActive = NO;
    mIsSKStoreActive = NO;
    mIsAppActive = YES;
    mFps = [RESM recommendedFps];
	mThisTurn = [[ThisTurn alloc] init];
	mViewController = viewController;
    mOFManager = [ofDelegate retain];
	mGameCoder = nil;
    mCachedResources = nil;
	mDeviceOrientation = [UIDevice currentDevice].orientation;
    
    CGRect viewBounds = self.view.bounds;
    mIsViewLandscape = (viewBounds.size.width > viewBounds.size.height);
	
	if (mDeviceOrientation != UIDeviceOrientationLandscapeLeft && mDeviceOrientation != UIDeviceOrientationLandscapeRight)
		mDeviceOrientation = UIDeviceOrientationLandscapeRight;
	
	mGameSettings = [[GameSettings alloc] init];
	[mGameSettings loadSettings];
	mQueuedState = StateNull;
	mState = StateNull;
	mStage = [stage retain];
	mCurrentScene = nil;
    mObjectivesManager = [[ObjectivesManager alloc] initWithRanks:nil scene:nil];
	mAchievementManager = [[AchievementManager alloc] init];
	mTextureManager = [[TextureManager alloc] initWithView:self.view memoryMode:TMMemModeConservative]; //TMMemModeLiberal
    miTunesManager = [[CCiTunesManager alloc] init];
	mAudioPlayerDump = [[NSMutableArray alloc] init];
	mAudioPlayers = [[NSMutableDictionary alloc] init];
	mQueuedAudioPlayer = nil;
	mControllerFactory = [[ControllerFactory alloc] init];

	[self setGameMode:mThisTurn.gameMode];
    self.assistedAiming = YES;
	
	[ActorAi setupAiKnob:&mAiKnob];
	mPlayerShip = nil;
	mPlayerDetails = [[PlayerDetails alloc] initWithGameStats:mAchievementManager.stats];
	[mAchievementManager.profileManager addEventListener:@selector(onPlayerChanged:) atObject:mPlayerDetails forType:CUST_EVENT_TYPE_PLAYER_CHANGED];
    
	[self loadGameState];
	
	mTimeKeeper = [[TimeKeeper alloc] initWithTimeOfDay:Dawn timePassed:0];
	mAchievementManager.timeOfDay = mTimeKeeper.timeOfDay;
	[mTimeKeeper addEventListener:@selector(onTimeOfDayChanged:) atObject:mAchievementManager forType:CUST_EVENT_TYPE_TIME_OF_DAY_CHANGED];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didResignWindowFocus:) name:UIWindowDidResignKeyNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveWindowFocus:)
                                                 name:UIWindowDidBecomeKeyNotification
                                               object:nil];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDetected:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    if ([ResManager isOSFeatureSupported:@"3.2"]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleScreenConnectNotification:)
                                                     name:UIScreenDidConnectNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleScreenDisconnectNotification:)
                                                     name:UIScreenDidDisconnectNotification
                                                   object:nil];
        
        if ([[UIScreen screens] count] > 1 && self.fps > 31.0f)
            [self setFramerate:30.0f];
    }
        
    mQueuedState = StatePlayfield;
    [self transitionToNewState:mQueuedState];
}

- (void)startSparrow {
    if (self.view && self.isAppActive && !self.isTwitterActive && !self.isSKStoreActive && self.viewController && !self.viewController.isShowingGCLeaderboard)
        [self.view start];
}

- (void)stopSparrow {
    if (self.view)
        [self.view stop];
}

- (void)invalidGameDataWasFound {
    mIsGameDataValid = NO;
}

- (void)setFramerate:(float)framerate {
    self.view.frameRate = framerate;
    mFps = self.view.frameRate;
}

- (void)handleScreenConnectNotification:(NSNotification *)aNotification {
    if (self.fps > 31.0f)
        [self setFramerate:30.0f];
    [mCurrentScene screenConnected];
}

- (void)handleScreenDisconnectNotification:(NSNotification *)aNotification {
    [self setFramerate:[RESM recommendedFps]];
    [mCurrentScene screenDisconnected];
}

- (void)orientationDetected:(UIEvent *)event {
	UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
	
	if (mOrientationLocked == NO && (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)) {
		mDeviceOrientation = orientation;
		[mCurrentScene updateOrientation:orientation];
		
		if (orientation == UIDeviceOrientationLandscapeLeft)
			[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
		else if (orientation == UIDeviceOrientationLandscapeRight)
			[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:NO];
	}
	//NSLog(@"Device Orientation: %i", orientation);
}

- (void)advanceTime:(double)time {
#ifdef CC_THREADED_MEMORY_POOLING
	[[ThreadSafetyManager threadSafetyManager] performDuties];
#endif
	
	// Audio
	mAudioLock = YES;
	
	for (int i = mAudioPlayerDump.count - 1; i >= 0; --i) {
		assert(i < 6);
		AudioPlayer *audioPlayer = [mAudioPlayerDump objectAtIndex:i];
		
		if (audioPlayer.markedForDestruction) {
			[self destroyAudioPlayer:audioPlayer];
			[mAudioPlayerDump removeObjectAtIndex:i];
		} else {
			[audioPlayer advanceTime:time];
		}
	}
	
	for (NSString *key in mAudioPlayers) {
		AudioPlayer *audioPlayer = [mAudioPlayers objectForKey:key];
		[audioPlayer advanceTime:time];
	}
	
	mAudioLock = NO;
    
    if (mQueuedState != StateNull)
        [self transitionToNewState:mQueuedState];
    [mCurrentScene advanceTime:time];
}

- (void)setGameMode:(NSString *)mode {
	NSString *gameMode = mode;
	
	if (gameMode == nil)
		gameMode = CC_GAME_MODE_DEFAULT;
	self.thisTurn.gameMode = gameMode;
}

- (void)fadeSplashViewOverTime:(float)duration {
    UIView *splashView = [self.view viewWithTag:SPLASH_VIEW_TAG];
    
    if (splashView == nil)
        return;
    
    NSString *reqSysVer = @"4.0";
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    if (osVersionSupported) {
        [UIView animateWithDuration:duration
                         animations:^{splashView.alpha = 0;}
                         completion:^(BOOL finished){ [splashView removeFromSuperview]; }];
    } else {
        [UIView beginAnimations:@"FadeSplash" context:nil];
        [UIView setAnimationDuration:duration];
        [UIView setAnimationDelegate:self];
        [splashView setAlpha:0];
        [UIView commitAnimations];
    }
}

- (void)animationDidStart:(NSString *)animationID context:(void *)context {
    // Do nothing
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    UIView *splashView = [self.view viewWithTag:SPLASH_VIEW_TAG];
    [splashView removeFromSuperview];
}

// Usually called for when Game Center modal dialogs steal/lose focus
- (void)didReceiveWindowFocus:(NSNotification *)notification {
    UIWindow *gameWindow = [[[UIApplication sharedApplication] delegate] window];
    self.gameWindowDidLoseFocus = (gameWindow != (UIWindow *)notification.object);
}

- (void)setState:(GameState)state {
	mQueuedState = state;
}

- (void)commitQueuedState:(GameState)state {
    if (mState == StateNull && mQueuedState == StatePlayfield)
        [self fadeSplashViewOverTime:2.0f];
	mState = mQueuedState;
	mQueuedState = StateNull;
}

- (AudioPlayer *)audioPlayerByName:(NSString *)key {
	return [mAudioPlayers objectForKey:key];
}

- (void)addAudioPlayer:(AudioPlayer *)audioPlayer byName:(NSString *)key {
	assert(mAudioLock == NO && key && [self audioPlayerByName:key] == nil);
	[mAudioPlayers setObject:audioPlayer forKey:key];
}

- (void)removeAudioPlayerByName:(NSString *)key {
	assert(mAudioLock == NO && key);
	[mAudioPlayers removeObjectForKey:key];
}

- (void)destroyAudioPlayer:(AudioPlayer *)audioPlayer {
	[audioPlayer removeAllSounds];
	[audioPlayer destroyAudioPlayer];
}

- (void)destroyAudioPlayerByName:(NSString *)key {
	AudioPlayer *audioPlayer = [self audioPlayerByName:key];
	[self destroyAudioPlayer:audioPlayer];
	[self removeAudioPlayerByName:key];
}

- (void)destroyAllAudioPlayers {
	assert(mAudioLock == NO);
	NSArray *keys = [mAudioPlayers allKeys];
	
	for (NSString *key in keys)
		[self destroyAudioPlayerByName:key];
	for (AudioPlayer *audioPlayer in mAudioPlayerDump)
		[self destroyAudioPlayer:audioPlayer];
	[mAudioPlayerDump removeAllObjects];
}

- (void)markAudioPlayerForDestructionByName:(NSString *)key {
	assert(mAudioLock == NO);
	AudioPlayer *audioPlayer = [self audioPlayerByName:key];
	
	if (audioPlayer) {
		[mAudioPlayerDump addObject:audioPlayer];
		[mAudioPlayers removeObjectForKey:key];
		[audioPlayer fadeAndMarkForDestruction];
	}
}

- (void)unloadScene:(SceneController *)scene {
	[scene destroyScene];
	[scene checkinAtlases];
	[scene release];
	
	[mTextureManager purgeUnusedAtlases];
}

- (void)loadScene:(GameState)state {
    assert(mQueuedAudioPlayer == nil);
    mQueuedAudioPlayer = [[self audioPlayerForState:state] retain];
	mControllerFactory.voodooKeys = mPlayerDetails.abilities;
    [mControllerFactory loadSceneReqsByName:[self sceneKeyForState:state]
                                     caller:self
                             loadedCallback:@selector(onSceneLoaded:error:)];
}

- (void)loadSceneAsync:(GameState)state {
	assert(mQueuedAudioPlayer == nil);
	mQueuedAudioPlayer = [[self audioPlayerForState:state] retain];
	mControllerFactory.voodooKeys = mPlayerDetails.abilities;
	[mControllerFactory loadSceneReqsAsyncByName:[self sceneKeyForState:state]
                                          caller:self
                                progressCallback:@selector(onSceneLoadProgressed:progress:)
                                  loadedCallback:@selector(onSceneLoaded:error:)];
}

- (void)onSceneLoaded:(NSString *)sceneName error:(NSString *)error {
	assert([NSThread isMainThread] && error == nil);
	SceneController *scene = [mControllerFactory createSceneByName:sceneName];
    
	if (mQueuedAudioPlayer != nil) {
		[self addAudioPlayer:mQueuedAudioPlayer byName:sceneName];
		[mQueuedAudioPlayer release];
		mQueuedAudioPlayer = nil;
	}
    
    assert(mCurrentScene == nil);
    mCurrentScene = [scene retain];
    [self setupScene];
}

- (void)setupScene {
    switch (mQueuedState) {
		case StatePlayfield:
            [self prepareForNewGame];
            self.gameSaved = YES; // Prevent initial save when starting first turn.
			break;
		default:
			assert(0);
			break;
	}
    
    [self.ofManager setScene:mCurrentScene];
	[mCurrentScene setupController];
	[mCurrentScene willGainSceneFocus];
	
	self.view.multipleTouchEnabled = (mQueuedState == StatePlayfield);
	[mCurrentScene addToStageAtIndex:0];
	[self commitQueuedState:mQueuedState];
}

- (GameState)sceneStateForKey:(NSString *)key {
	GameState state = StateNull;
	
	if ([key isEqualToString:@"Playfield"])
		state = StatePlayfield;
	return state;
}
	 
- (NSString *)sceneKeyForState:(GameState)state {
	NSString *key = nil;
	
	switch (state) {
		case StatePlayfield: key = @"Playfield"; break;
		default:
			assert(0);
			break;
	}
	return key;
}

- (AudioPlayer *)audioPlayerForState:(GameState)state {
	AudioPlayer *audioPlayer = nil;
	
	switch (state) {
		case StatePlayfield:
			audioPlayer = [[[AudioPlayer alloc] init] autorelease];
			audioPlayer.musicOn = [mGameSettings settingForKey:GAME_SETTINGS_KEY_MUSIC_ON];
			audioPlayer.sfxOn = [mGameSettings settingForKey:GAME_SETTINGS_KEY_SFX_ON];
			break;
		default:
			break;
	}
	return audioPlayer;
}

- (void)transitionToNewState:(GameState)state {
    assert(mState == StateNull && state == StatePlayfield);
    [self loadScene:state];
}

- (BOOL)processEndOfTurn {
    BOOL didSaveProgress = NO;
    
	if (self.gameSaved == YES)
		return didSaveProgress;
    
	self.gameSaved = YES;
    if ([mThisTurn.gameMode isEqualToString:CC_GAME_MODE_DEFAULT])
        [mAchievementManager saveScore:mThisTurn.infamy];
    else if ([mThisTurn.gameMode isEqualToString:CC_GAME_MODE_SPEED_DEMONS])
        [mAchievementManager saveSpeed:mThisTurn.speed];
	
    if (mThisTurn.wasGameProgressMade) {
        mThisTurn.wasGameProgressMade = NO;
        [self saveProgress];
        didSaveProgress = YES;
    }
    
    return didSaveProgress;
}

// Pass nil to remove key from cache. Pass nil,nil to empty cache.
- (void)cacheResource:(NSObject *)resource forKey:(NSString *)key {
    if (resource == nil && key == nil) {
        [mCachedResources removeAllObjects];
        return;
    }
    
    if (resource == nil)
        [mCachedResources removeObjectForKey:key];
    else {
        if (mCachedResources == nil)
            mCachedResources = [[NSMutableDictionary alloc] init];
        [mCachedResources setObject:resource forKey:key];
    }
}

- (NSObject *)cachedResourceForKey:(NSString *)key {
    return [mCachedResources objectForKey:key];
}

- (void)setPaused:(BOOL)value {
	static NSNumber *savedTimerActivity = nil; // Gives me a third state that BOOL wouldn't: YES, NO, UNSET.
	
	if (mPaused == value)
		return;
	
	if (value == YES) {
		[self.audioPlayer pause];
		[savedTimerActivity release];
		savedTimerActivity = [[NSNumber numberWithBool:mTimeKeeper.timerActive] retain];
		mTimeKeeper.timerActive = NO;
		[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
		
		//if (mState == StatePlayfield || mState == StateCove)
		//	[self saveGameState];
	} else {
		if (savedTimerActivity != nil) {
			mTimeKeeper.timerActive = [savedTimerActivity boolValue];
			[savedTimerActivity release];
			savedTimerActivity = nil;
		}
		
		[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
		[self.audioPlayer resume];
	}
	mPaused = value;
}

- (SPView *)view {
    return mViewController.sparrowView;
}

- (AudioPlayer *)audioPlayer {
	return mCurrentScene.audioPlayer;
}

- (TimeOfDay)timeOfDay {
	return mTimeKeeper.timeOfDay;
}

- (void)setTimeOfDay:(TimeOfDay)timeOfDay {
	mTimeKeeper.timeOfDay = timeOfDay;
}

- (float)fpsFactor {
	return 30.0f / mFps;
}

- (AiKnob *)aiKnob {
	return &mAiKnob;
}

- (GameStats *)gameStats {
	return mAchievementManager.stats;
}

- (SPTextureAtlas *)achievementAtlas {
	return mAchievementManager.atlas;
}

- (void)overridingPause {
    [mCurrentScene overridingPause];
}

- (ProfileManager *)profileManager {
	return mAchievementManager.profileManager;
}

- (BOOL)assistedAiming {
	return mThisTurn.assistedAiming;
}

- (void)setAssistedAiming:(BOOL)value {
	mThisTurn.assistedAiming = value;
	[mPlayerShip assistedAimingChanged:value];
}

- (void)prepareForNewGame {
	[self processEndOfTurn];
	self.gameSaved = NO;
	
    [self.timeKeeper reset];
	[self.achievementManager prepareForNewGame];
    [self.objectivesManager prepareForNewGame];
    [self.playerDetails reset];
    [self.thisTurn prepareForNewTurn];
    self.thisTurn.infamyMultiplier = mObjectivesManager.scoreMultiplier;
}

- (void)saveProgress {
	[self.achievementManager saveProgress];
}

- (GameCoder *)gameCoder {
	if (mGameCoder == nil)
		mGameCoder = [[GameCoder alloc] init];
	return mGameCoder;
}

- (void)applyGameState {
	// Misc
	GCMisc *misc = (GCMisc *)[mGameCoder objectForKey:GAME_CODER_KEY_MISC];
	mThisTurn.infamy = misc.infamy;
	mThisTurn.mutiny = misc.mutiny;
	self.thisTurn = misc.thisTurn;
	
	// ShipDetails
	ShipDetails *shipDetails = mPlayerDetails.shipDetails;
	GCShipDetails *gcShipDetails = (GCShipDetails *)[mGameCoder objectForKey:GAME_CODER_KEY_SHIP_DETAILS];
	[shipDetails addPrisonersFromDictionary:gcShipDetails.prisoners];
	
	// AchievementManager
	[mAchievementManager loadGameState:mGameCoder];
	
	// AiKnob
	GCAiKnob *gcAiKnob = (GCAiKnob *)[mGameCoder objectForKey:GAME_CODER_KEY_AI_KNOB];
	mAiKnob = gcAiKnob.aiKnob;
	
	// TimeKeeper
	[mTimeKeeper setTimeOfDay:(TimeOfDay)misc.timeOfDay timePassed:misc.timePassed];
	mTimeKeeper.day = misc.day;
	
	// Not needed anymore
	//[mGameCoder release];
	//mGameCoder = nil;
}

- (void)loadGameState {
	GameCoder *coder = self.gameCoder;
	
	if ([coder loadGameState] == NO) {
		[mGameCoder release];
		mGameCoder = nil;
	} else {
		GCMisc *misc = (GCMisc *)[coder objectForKey:GAME_CODER_KEY_MISC];
		
		if ([misc.alias isEqualToString:mPlayerDetails.name] == NO) {
			// Don't continue game if the player has changed (through Game Center login)
			[mGameCoder release];
			mGameCoder = nil;
		} else if (misc.thisTurn.adventureState != AdvStateNormal) {
            [mGameCoder release];
			mGameCoder = nil;
        }
	}
}

- (void)saveGameState {
	// Don't save the game state when doing so is unnecessary/unsafe.
	if (mThisTurn.tutorialMode || mThisTurn.isGameOver || mThisTurn.adventureState != AdvStateNormal)
		return;
	
	GameCoder *coder = self.gameCoder;
	[coder beginNewStateCache];
	
	[mCurrentScene saveSceneState:coder];
	
	// Misc
	GCMisc *misc = (GCMisc *)[coder objectForKey:GAME_CODER_KEY_MISC];
	misc.alias = mPlayerDetails.name;
	misc.gameState = mState;
	misc.queuedState = mQueuedState;
	misc.thisTurn = self.thisTurn;
	misc.infamy = mThisTurn.infamy;
	misc.mutiny = mThisTurn.mutiny;
	misc.day = mTimeKeeper.day;
	misc.timeOfDay = mTimeKeeper.timeOfDay;
	misc.timePassed = mTimeKeeper.timePassed;
	
	// ShipDetails
	ShipDetails *shipDetails = mPlayerDetails.shipDetails;
	GCShipDetails *gcShipDetails = (GCShipDetails *)[coder objectForKey:GAME_CODER_KEY_SHIP_DETAILS];
	[gcShipDetails setPrisoners:shipDetails.prisoners];
	
	// AchievementManager
	[mAchievementManager saveGameState:mGameCoder];
	
	// AiKnob
	GCAiKnob *gcAiKnob = (GCAiKnob *)[coder objectForKey:GAME_CODER_KEY_AI_KNOB];
	gcAiKnob.aiKnob = mAiKnob;

	// Save to permanent store
	[coder saveGameState];
	[coder beginNewStateCache]; // Clear cache
}

- (void)didReceiveMemoryWarning {
	[SPPoint purgePool];
    [SPRectangle purgePool];
    [SPMatrix purgePool];
	[mTextureManager purgePersistentAtlases];
}

- (void)applicationWillTerminate {
	//[self saveGameState]; // TODO: Uncomment
    [self.achievementManager processDelayedSaves];
}

- (void)dealloc {
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:UIWindowDidResignKeyNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIWindowDidBecomeKeyNotification object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    if ([ResManager isOSFeatureSupported:@"3.2"]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIScreenDidConnectNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIScreenDidDisconnectNotification object:nil];
    }
    
	[mAchievementManager.profileManager removeEventListener:@selector(onPlayerChanged:) atObject:mPlayerDetails forType:CUST_EVENT_TYPE_PLAYER_CHANGED];
	[mTimeKeeper removeEventListener:@selector(onTimeOfDayChanged:) atObject:mAchievementManager forType:CUST_EVENT_TYPE_TIME_OF_DAY_CHANGED];
	
	[mThisTurn release]; mThisTurn = nil;
	[mGameSettings release]; mGameSettings = nil;
	[mCurrentScene release]; mCurrentScene = nil;
    [mCachedResources release]; mCachedResources = nil;
	[mPlayerDetails cleanup];
	[mPlayerDetails release]; mPlayerDetails = nil;
	[mPlayerShip release]; mPlayerShip = nil;
	[mStage release]; mStage = nil;
	[mTimeKeeper release]; mTimeKeeper = nil;
	[self destroyAllAudioPlayers];
	[mAudioPlayerDump release]; mAudioPlayerDump = nil;
	[mAudioPlayers release]; mAudioPlayers = nil;
	[mAchievementManager release]; mAchievementManager = nil;
    [mObjectivesManager release]; mObjectivesManager = nil;
    [mOFManager release]; mOFManager = nil;
	[mTextureManager release]; mTextureManager = nil;
    [miTunesManager release]; miTunesManager = nil;
	[mControllerFactory release]; mControllerFactory = nil;
	[mGameCoder release]; mGameCoder = nil;
    mViewController = nil;
	[super dealloc];
}

@end




