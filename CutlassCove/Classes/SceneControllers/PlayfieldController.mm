//
//  PlayfieldController.m
//  Pirates
//
//  Created by Paul McPhee on 3/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "PlayfieldController.h"
#import "PlayfieldView.h"
#import "MenuController.h"
#import "FastMath.h"
#import "MenuButton.h"
#import "FloatingText.h"
#import "Actor.h"
#import "Prop.h"
#import "ActorAi.h"
#import "TownAi.h"
#import "ShipActor.h"
#import "PlayerShip.h"
#import "AshProc.h"
#import "Ash.h"
#import "Ignitable.h"
#import "PlayerDetails.h"
#import "CannonDetails.h"
#import "ShipDetails.h"
#import "NpcShip.h"
#import "Wake.h"
#import "Sea.h"
#import "LootProp.h"
#import "PointMovie.h"
#import "Cannonball.h"
#import "ActorFactory.h"
#import "ShipFactory.h"
#import "CannonFactory.h"
#import "StaticFactory.h"
#import "VoodooManager.h"
#import "TempestActor.h"
#import "WhirlpoolActor.h"
#import "DeathFromDeep.h"
#import "PowderKegActor.h"
#import "NetActor.h"
#import "BrandySlickActor.h"
#import "PoolActor.h"
#import "AcidPoolActor.h"
#import "RaceTrackActor.h"
#import "ActorContactListener.h"
#import "NumericValueChangedEvent.h"
#import "NumericRatioChangedEvent.h"
#import "CannonballCache.h"
#import "LootPropCache.h"
#import "NpcShipCache.h"
#import "PointMovieCache.h"
#import "SharkCache.h"
#import "WakeCache.h"
#import "PoolActorCache.h"
#import "TempestCache.h"
#import "BlastCache.h"
#import "AchievementManager.h"
#import "CombatText.h"
#import "GameSettings.h"
#import "FirstMate.h"
#import "GuiHelper.h"
#import "BinaryEvent.h"
#import "MultiPurposeEvent.h"
#import "CCMiscConstants.h"
#import "ProfileManager.h"
#import "PersistenceManager.h"
#import "GameController.h"
#import "CutlassCoveAppDelegate.h"
#import "Globals.h"

#define MIN_FRAME_RATE 15.0f
#define MAX_PHYSICS_STEP (1.0f / MIN_FRAME_RATE)

const int kFirstMateMutinied = 1;
const int kEtherealPotionNotice = 2;
const int kOverheatedCannonsNotice = 3;

const uint kCloudEvLoggedIn = 0x1UL;
const uint kCloudEvLoggedOut = 0x2UL;
const uint kCloudEvDataChanged = 0x4UL;
const uint kCloudEvSettingsChanged = 0x8UL;

const uint kFriendsRangeLower = 1;
const uint kFriendsRangeUpper = 25;

@interface PlayfieldController ()

@property (nonatomic,copy) NSString* enqueuedRankNotice;
@property (nonatomic,assign) BOOL isGameSummaryShowing;
@property (nonatomic,assign) BOOL isTravellingThroughTime;

- (void)setState:(PfState)state;
- (void)uiViewDidTakeFocus:(SPEvent *)event;
- (void)spViewDidTakeFocus:(SPEvent *)event;
- (void)setupVoodooManagerListeners;
- (void)enableSuspendedSceneMode:(BOOL)enable;
- (void)enableSuspendedPlayerMode:(BOOL)enable;
- (void)setGameOver:(BOOL)value;
- (void)displayEnqueuedNotice;
- (void)onGCScoreReported:(SPEvent *)event;
- (void)onGCScoresFetched:(MultiPurposeEvent *)event;
- (void)igniteAllIgnitableActors;
- (void)activateCamouflageForDuration:(float)duration;
- (void)activateFlyingDutchmanForDuration:(float)duration;
- (void)summonWhirlpoolWithDuration:(float)duration;
- (void)onPlayPressed:(SPEvent *)event;
- (void)onPrisonersChanged:(NumericValueChangedEvent *)event;
- (void)onPowderKegDropping:(SPEvent *)event;
- (void)onNetDeployed:(SPEvent *)event;
- (void)onBrandySlickDeployed:(SPEvent *)event;
- (void)onDeathFromDeepSummoned:(SPEvent *)event;
- (void)onCamouflageActivated:(SPEvent *)event;
- (void)onFlyingDutchmanActivated:(SPEvent *)event;
- (void)onSeaOfLavaSummoned:(SPEvent *)event;
- (void)onSeaOfLavaPeaked:(SPEvent *)event;
- (void)onAshPickupLooted:(NumericValueChangedEvent *)event;
- (void)onCloseButNoCigarStateReached:(SPEvent *)event;
- (void)onGameOverRetryPressed:(SPEvent *)event;
- (void)onGameOverMenuPressed:(SPEvent *)event;
- (void)onGameOverSubmitPressed:(SPEvent *)event;
- (void)onTimeOfDayChangedEvent:(TimeOfDayChangedEvent *)event;
- (void)checkForMontysMutiny;
- (void)beginMontysMutinySequence;
- (void)beginOverheatedCannonsSequence;
- (void)onMontySkippered:(SPEvent *)event;
- (void)onPlayerEaten:(SPEvent *)event;
- (void)prepareForNewGame;
- (void)prepareForGameOver;
- (void)onInfamyChanged:(NumericValueChangedEvent *)event;
- (void)onPlayerShipSinking:(SPEvent *)event;
- (void)onPlayerShipEnteredCove:(SPEvent *)event;
- (void)onMutinyChanged:(SPEvent *)event;
- (void)onChallengeConditionBreached:(SPEvent *)event;
- (void)onChallengeSent:(SPEvent *)event;
- (void)onTutorialCompleted:(SPEvent *)event;
- (void)onObjectivesRankupCompleted:(BinaryEvent *)event;
- (void)onTreasureFleetSpawned:(SPEvent *)event;
- (void)onTreasureFleetAttacked:(SPEvent *)event;
- (void)onSilverTrainSpawned:(SPEvent *)event;
- (void)onSilverTrainAttacked:(SPEvent *)event;
- (void)onDeckVoodooIdolPressed:(SPEvent *)event;
- (void)onVoodooMenuClosing:(SPEvent *)event;
- (void)onDeckTwitterActivated:(SPEvent *)event;
- (TutorialState)intendedTutorialState;
- (NSString *)tutorialKey;
- (NSString *)tutorialSettingKey;
- (void)beginTutorial;
- (void)finishTutorial;
- (void)displayEtherealPotionNoticeWithMsgs:(NSArray *)msgs;
- (void)fadeOutShipLayer;
- (void)continueEndOfTurn;
- (void)continueDelayedRetry;
- (void)continueDelayedQuit;
- (void)transitionToTurnOver;
- (void)resetScene;
- (void)resetSceneComplete;
- (void)setupActorAi;
- (void)setupTownAi;
- (void)destroyActorAi;
- (void)destroyTownAi;

- (void)refreshAfterProgressChanged;
- (void)setCloudEvent:(uint)evCode value:(BOOL)value;
- (void)clearCloudEvents;
- (void)processCloudEvents;
- (void)onCloudAccountLoggedIn:(SPEvent *)event;
- (void)onCloudAccountLoggedOut:(SPEvent *)event;
- (void)onCloudDataChanged:(SPEvent *)event;
- (void)onCloudSettingsChanged:(SPEvent *)event;

@end


@implementation PlayfieldController

@synthesize state = mState;
@synthesize tutorialState = mTutorialState;
@synthesize raceEnabled = mRaceEnabled;
@synthesize isRaceFinished = mIsRaceFinished;
@synthesize isTravellingThroughTime = mIsTravellingThroughTime;
@synthesize timeRatio = mTimeRatio;
@synthesize world = mWorld;
@synthesize gravity = mGravity;
@synthesize velocityIterations = mVelocityIterations;
@synthesize positionIterations = mPositionIterations;
@synthesize actorBrains = mActorBrains;
@synthesize guvnor = mGuvnor;
@synthesize voodooManager = mVoodooManager;
@synthesize enqueuedRankNotice = mEnqueuedRankNotice;
@synthesize isGameSummaryShowing = mIsGameSummaryShowing;
@dynamic assistedAiming;

- (id)init {
	if (self = [super init]) {
		// Box2D init world
        mAmbienceShouldPlay = NO;
        mRetried = NO;
		mRaceEnabled = NO;
        mMontyShouldMutiny = NO;
        mTimeSlowed = NO;
        mSuspendedMode = NO;
		mResettingScene = NO;
        mCannonsDidOverheat = NO;
        mIsRaceFinished = NO;
        mIsTravellingThroughTime = NO;
        mIsGameSummaryShowing = NO;
        mLaunchTimer = 1.125;
        mPrizesBitmap = 0;
        mCloudEvents = 0;
		mSceneKey = [[NSString stringWithFormat:@"Playfield"] copy];
        mEnqueuedRankNotice = nil;
		mVoodooManager = nil;
		mActorBrains = nil;
		mGuvnor = nil;
		mStepping = NO;
		mGravity.Set(0.0f, 0.0f);
		mVelocityIterations = 1; //(RESM.isLowPerformance) ? 1 : 2;
		mPositionIterations = 1;
		mStepDuration = 1.0f / MAX(MIN_FRAME_RATE, GCTRL.fps);
		mStepAccumulator = 0;
		mTimeRatio = 1.0f;
        FastMath::primeAtan2Lut();
		mWorld = new b2World(mGravity);
        mWorld->SetAllowSleeping(true);
		mWorld->SetContinuousPhysics(false);
		mContactListener = new ActorContactListener;
		mWorld->SetContactListener(mContactListener);
        mTutorialState = TutorialStateNull;
        mState = mPreviousState = PfStatePlaying;
    }
    return self;
}

- (void)setupController {
    if (mView)
        return;
	[super setupController];
	
	//[NpcShip fillNpcShipTexturePool:(SPTextureAtlas *)[mAtlases objectAtIndex:0]];
	//[PointMovie fillPointMovieTexturePool:(SPTextureAtlas *)[mAtlases objectAtIndex:0]];
	//[Cannonball fillCannonballTexturePool:(SPTextureAtlas *)[mAtlases objectAtIndex:0]];
	//[Wake fillWakeTexturePool:(SPTextureAtlas *)[mAtlases objectAtIndex:0]];
	
	[self.tm setFlags:TM_FLAG_PERSISTENT_ATLAS forAtlasNamed:mSceneKey inCategory:self.sceneKey];
	[self setupCaches];
	
	GameController *gc = [GameController GC];
	
	[Actor setActorsScene:self];
	// Z-order maintainance
	mSpriteLayerManager = [[SpriteLayerManager alloc] initWithBaseDisplay:mBaseSprite layerCount:17];
    
    int touchableLayers[] = { CAT_PF_SEA, CAT_PF_SURFACE, CAT_PF_BUILDINGS, CAT_PF_DIALOGS, CAT_PF_DECK, CAT_PF_HUD };
    [mSpriteLayerManager setTouchableLayers:touchableLayers count:6];
    
    // Persistence Manager
    [[PersistenceManager PM] addEventListener:@selector(onCloudAccountLoggedIn:) atObject:self forType:CUST_EVENT_TYPE_CLOUD_LOGGED_IN];
    [[PersistenceManager PM] addEventListener:@selector(onCloudAccountLoggedOut:) atObject:self forType:CUST_EVENT_TYPE_CLOUD_LOGGED_OUT];
    [[PersistenceManager PM] addEventListener:@selector(onCloudDataChanged:) atObject:self forType:CUST_EVENT_TYPE_CLOUD_DATA_CHANGED];
    [[PersistenceManager PM] addEventListener:@selector(onCloudSettingsChanged:) atObject:self forType:CUST_EVENT_TYPE_CLOUD_SETTINGS_CHANGED];
    [gc.gameSettings syncWithSettings:[[PersistenceManager PM] loadSettings]];
    [gc.gameSettings saveSettingsLocal];
	
	// Setup Ai
	[self setupTownAi];
	[self setupActorAi];
	
	// View
	mView = [[PlayfieldView alloc] initWithController:self];
    [self.objectivesManager setScene:self];
    
    // Menu
    mMenuController = [[MenuController alloc] initWithScene:self];
    [mMenuController setupController];
    
    // For Testing
    //[(ObjectivesManager *)[self.juggler delayInvocationAtTarget:self.objectivesManager byTime:5.0f] testRankupPanel];

	
    mVoodooManager = [[VoodooManager alloc] initWithCategory:-1 trinkets:gc.gameStats.trinkets gadgets:gc.gameStats.gadgets];
    [self setupVoodooManagerListeners];
    gc.timeKeeper.dayShouldIncrease = YES;
    [self.achievementManager loadCombatTextWithCategory:CAT_PF_COMBAT_TEXT bufferSize:30 owner:mSceneKey];
	
	[self addPauseButton];
    [self setState:PfStateLaunching];
	
	NSLog(@"PROP COUNT AFTER VIEW CREATION: %d", [Prop propCount]);
	NSLog(@"ACTOR COUNT AFTER VIEW CREATION: %d", [Actor actorCount]);
  
    [self flip:[gc.gameSettings settingForKey:GAME_SETTINGS_KEY_FLIPPED_CONTROLS]];
}

- (void)setupCaches {
    if (mCacheManagers)
        return;
    
    GameController *gc = GCTRL;
    
    mCacheManagers = [(NSMutableDictionary *)[gc cachedResourceForKey:RESOURCE_CACHE_MANAGERS] retain];
    
    if (mCacheManagers) {
        for (NSString *key in mCacheManagers) {
            CacheManager *cm = (CacheManager *)[mCacheManagers objectForKey:key];
            [cm reassignResourceServersToScene:self];
        }
        
        return;
    }
	
	mCacheManagers = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
					  [[[CannonballCache alloc] init] autorelease],CACHE_CANNONBALL,
					  [[[LootPropCache alloc] init] autorelease],CACHE_LOOT_PROP,
					  [[[NpcShipCache alloc] init] autorelease],CACHE_NPC_SHIP,
					  [[[PointMovieCache alloc] init] autorelease],CACHE_POINT_MOVIE,
					  [[[SharkCache alloc] init] autorelease],CACHE_SHARK,
                      [[[PoolActorCache alloc] init] autorelease],CACHE_POOL_ACTOR,
                      [[[BlastCache alloc] init] autorelease], CACHE_BLAST_PROP,
					  nil];
    
    if (RESM.isLowPerformance == NO)
        [mCacheManagers setObject:[[[WakeCache alloc] init] autorelease] forKey:CACHE_WAKE];
    [mCacheManagers setObject:[[[TempestCache alloc] init] autorelease] forKey:CACHE_TEMPEST];
    
	for (NSString *key in mCacheManagers) {
		CacheManager *cm = (CacheManager *)[mCacheManagers objectForKey:key];
		
		if ([cm isKindOfClass:[CannonballCache class]]) {
			CannonballCache *cannonballCm = (CannonballCache *)cm;
            NSArray *array = [Ash allTexturePrefixes];
			[cannonballCm fillResourcePoolForScene:self shotTypes:array];
		} else {
			[cm fillResourcePoolForScene:self];
		}
	}
    
    [gc cacheResource:mCacheManagers forKey:RESOURCE_CACHE_MANAGERS];
}

- (void)setupSaveOptions {
	[self.achievementManager processDelayedSaves];
	self.achievementManager.delaySavingAchievements = YES;
}

- (void)setState:(PfState)state {
    if (state == mState)
        return;
    mPreviousState = mState;
    
    [self enableSlowedTime:NO];
    [mView enableCombatInterface:NO];
    
    GameController *gc = GCTRL;
    
    // Clean up previous state
    switch (mPreviousState) {
        case PfStateLaunching:
            break;
        case PfStateHibernating:
            break;
        case PfStateMenu:
            break;
        case PfStatePlaying:
            [self showPauseButton:NO];
            [self enableSuspendedSceneMode:NO];
            [self enableSuspendedPlayerMode:NO];
            
            mTutorialState = TutorialStateNull;
            [mView dismissTutorial];
            [mView enableWeather:YES];
            [self destroyHelpAtlas];
            
            gc.thisTurn.isGameOver = YES;
            gc.timeKeeper.dayShouldIncrease = NO;
            
            [mVoodooManager prepareForGameOver];
            [mGuvnor prepareForGameOver];
            [mActorBrains prepareForGameOver];
            [ActorAi setupAiKnob:gc.aiKnob];
            
            if (gc.gameSettings.delayedSaveRequired)
                [gc.gameSettings saveSettings];
            break;
        case PfStateEndOfTurn:
            mIsRaceFinished = NO;
            self.isGameSummaryShowing = NO;
            self.isTravellingThroughTime = NO;
            self.enqueuedRankNotice = nil;
            break;
        case PfStateDelayedRetry:
            break;
        case PfStateDelayedQuit:
            break;
        default:
            break;
    }
    
    mState = state;
    
    // Apply new state
    switch (mState) {
        case PfStateLaunching:
            break;
        case PfStateHibernating:
            break;
        case PfStateMenu:
            [gc.view setMultipleTouchEnabled:NO];
            [self stopAmbientSounds];
            [mMenuController setState:MenuStateTransitionIn];
            [mView transitionToMenu];
            mActorBrains.shipsPaused = NO;
            [self processCloudEvents];
            break;
        case PfStatePlaying:
            [gc.view setMultipleTouchEnabled:YES];
            [self showPauseButton:YES];
            [self prepareForNewGame];
            break;
        case PfStateEndOfTurn:
            break;
        case PfStateDelayedRetry:
            [mView destroyPlayerShip];
            [mView enableCombatInterface:NO];
            break;
        case PfStateDelayedQuit:
            [mView destroyPlayerShip];
            [mView enableCombatInterface:NO];
            break;
        default:
            break;
    }
}

- (void)prepareForNewGame {
    [self clearScreenshotCache];
    
    GameController *gc = GCTRL;
    
    for (Actor *actor in mActors)
        [actor prepareForNewGame];
    
    [gc prepareForNewGame];
    gc.timeKeeper.dayShouldIncrease = !mRaceEnabled;
    [self setupActorAi];
    [self setupTownAi];
    [self enablePerformanceSavingMode:NO];
    [mView transitionFromMenu];
    [mVoodooManager prepareForNewGame];
    [mMenuController setState:MenuStateTransitionOut];
    [self.objectivesManager hideNoticesPanel];
    mPrizesBitmap = 0;
    mStepAccumulator = 0;
    mRetried = NO;
    mCannonsDidOverheat = NO;
    mIsRaceFinished = NO;
    self.isGameSummaryShowing = NO;
    self.isTravellingThroughTime = NO;
    self.enqueuedRankNotice = nil;
    [self enableSlowedTime:NO];
    mAmbienceShouldPlay = YES;
    
    // Tutorial
    mTutorialState = [self intendedTutorialState];
    
	if (mTutorialState != TutorialStateNull) {
		[self enableSuspendedSceneMode:YES];
        [[mJuggler delayInvocationAtTarget:self byTime:1.0f] beginTutorial];
		//[[mJuggler delayInvocationAtTarget:self byTime:0.25f * MAX(8.0f, (16.0f - gc.playerShip.shipDetails.speedRating))] beginTutorial];
	} else {
        [mView createPlayerShip];
    }
}

- (void)uiViewDidTakeFocus:(SPEvent *)event {
    [self setState:PfStateHibernating];
}

- (void)spViewDidTakeFocus:(SPEvent *)event {
    [self setState:mPreviousState];
}

- (void)willGainSceneFocus {
	[super willGainSceneFocus];
	[self attachEventListeners];
	GCTRL.timeKeeper.timerActive = (mSuspendedMode == NO);
}

- (void)willLoseSceneFocus {
	[super willLoseSceneFocus];
	[self detachEventListeners];
	[mView detachEventListeners];
	GCTRL.timeKeeper.timerActive = NO;
}

- (void)attachEventListeners {
	[super attachEventListeners];
	
	GameController *gc = [GameController GC];
    [gc.thisTurn addEventListener:@selector(onInfamyChanged:) atObject:self forType:CUST_EVENT_TYPE_INFAMY_VALUE_CHANGED];
    [gc.thisTurn addEventListener:@selector(onInfamyChanged:) atObject:self.achievementManager forType:CUST_EVENT_TYPE_INFAMY_VALUE_CHANGED];
	[gc.thisTurn addEventListener:@selector(onMutinyChanged:) atObject:self forType:CUST_EVENT_TYPE_MUTINY_VALUE_CHANGED];
	[gc.timeKeeper addEventListener:@selector(onTimeOfDayChangedEvent:) atObject:self forType:CUST_EVENT_TYPE_TIME_OF_DAY_CHANGED];
    
    [gc.ofManager addEventListener:@selector(onGCScoreReported:) atObject:self forType:CUST_EVENT_TYPE_GC_SCORE_SUBMITTED];
    [gc.ofManager addEventListener:@selector(onGCScoresFetched:) atObject:self forType:CUST_EVENT_TYPE_GC_SCORES_FETCHED];
    
    [self.voodooManager addEventListener:@selector(onVoodooMenuClosing:) atObject:self forType:CUST_EVENT_TYPE_VOODOO_MENU_CLOSING];
    [self.achievementManager addEventListener:@selector(onPlayerEaten:) atObject:self forType:CUST_EVENT_TYPE_PLAYER_EATEN];
    [self.objectivesManager addEventListener:@selector(onObjectivesRankupCompleted:) atObject:self forType:CUST_EVENT_TYPE_OBJECTIVES_RANKUP_COMPLETED];
    [mMenuController addEventListener:@selector(onPlayPressed:) atObject:self forType:CUST_EVENT_TYPE_MENU_PLAY_SHOULD_BEGIN];
    [mMenuController addEventListener:@selector(uiViewDidTakeFocus:) atObject:self forType:CUST_EVENT_TYPE_MENU_UIVIEW_HAS_FOCUS];
    [mMenuController addEventListener:@selector(spViewDidTakeFocus:) atObject:self forType:CUST_EVENT_TYPE_MENU_SPVIEW_HAS_FOCUS];
	[mView attachEventListeners];
    [mMenuController attachEventListeners];
    
    //[gc.playerShip addRandomPrisoner];
    //[gc.playerShip addRandomPrisoner];
    //[gc.playerShip addRandomPrisoner];
    //[gc.playerShip addRandomPrisoner];
    //[gc.playerShip addRandomPrisoner];
}

- (void)detachEventListeners {
	[super detachEventListeners];
	
	GameController *gc = GCTRL;
    [gc.thisTurn removeEventListener:@selector(onInfamyChanged:) atObject:self forType:CUST_EVENT_TYPE_INFAMY_VALUE_CHANGED];
    [gc.thisTurn removeEventListener:@selector(onInfamyChanged:) atObject:self.achievementManager forType:CUST_EVENT_TYPE_INFAMY_VALUE_CHANGED];
	[gc.thisTurn removeEventListener:@selector(onMutinyChanged:) atObject:self forType:CUST_EVENT_TYPE_MUTINY_VALUE_CHANGED];
	[gc.timeKeeper removeEventListener:@selector(onTimeOfDayChangedEvent:) atObject:self forType:CUST_EVENT_TYPE_TIME_OF_DAY_CHANGED];
    
    [gc.ofManager removeEventListener:@selector(onGCScoreReported:) atObject:self forType:CUST_EVENT_TYPE_GC_SCORE_SUBMITTED];
    [gc.ofManager removeEventListener:@selector(onGCScoresFetched:) atObject:self forType:CUST_EVENT_TYPE_GC_SCORES_FETCHED];
    
    [self.voodooManager removeEventListener:@selector(onVoodooMenuClosing:) atObject:self forType:CUST_EVENT_TYPE_VOODOO_MENU_CLOSING];
    [self.achievementManager removeEventListener:@selector(onPlayerEaten:) atObject:self forType:CUST_EVENT_TYPE_PLAYER_EATEN];
    [self.objectivesManager removeEventListener:@selector(onObjectivesRankupCompleted:) atObject:self forType:CUST_EVENT_TYPE_OBJECTIVES_RANKUP_COMPLETED];
    [mView removeEventListener:@selector(onTutorialCompleted:) atObject:self forType:CUST_EVENT_TYPE_PLAYFIELD_TUTORIAL_COMPLETED];
    [mMenuController removeEventListener:@selector(onPlayPressed:) atObject:self forType:CUST_EVENT_TYPE_MENU_PLAY_SHOULD_BEGIN];
    [mMenuController removeEventListener:@selector(uiViewDidTakeFocus:) atObject:self forType:CUST_EVENT_TYPE_MENU_UIVIEW_HAS_FOCUS];
    [mMenuController removeEventListener:@selector(spViewDidTakeFocus:) atObject:self forType:CUST_EVENT_TYPE_MENU_SPVIEW_HAS_FOCUS];
	[mView detachEventListeners];
    [mMenuController detachEventListeners];
}

- (void)loadSceneState:(GameCoder *)coder {
	GameController *gc = [GameController GC];
	GCMisc *misc = (GCMisc *)[coder objectForKey:GAME_CODER_KEY_MISC];
	[Actor seedActorId:misc.actorIdSeed];
	mView.beachState = misc.beachState;
    
	// We drop after 1.0 seconds because that is half of the usual duration and will on average maintain decent separation of kegs.
	if (misc.kegsRemaining > 0)
		[[mJuggler delayInvocationAtTarget:gc.playerShip byTime:1.0f] dropPowderKegs:misc.kegsRemaining];
	
	if (misc.ashProc)
		gc.playerShip.ashProc = misc.ashProc;
	
	if (gc.playerShip.ashProc) {
		AshProc *ashProc = gc.playerShip.ashProc;
		
		if (ashProc.soundName != nil)
            [self.audioPlayer addSoundWithKey:@"CannonProc" count:1 filename:ashProc.soundName category:AUDIO_CATEGORY_SFX easeOutDuration:0 loop:NO onDemand:YES];
	}
	
	// Actor Ai
	[mActorBrains loadGameState:coder];
	
	// Town Ai
	[mGuvnor loadGameState:coder];
	
	// Active trinkets/gadgets
	for (GCVoodoo *gcVoodoo in misc.activeVoodoos) {
		[mVoodooManager setVoodooActive:gcVoodoo.bitmapID duration:gcVoodoo.durationRemaining];
		
		switch (gcVoodoo.bitmapID) {
			case GADGET_SPELL_BRANDY_SLICK:
			{
				[gc.playerShip deployBrandySlickAtX:gcVoodoo.x
												  y:gcVoodoo.y
										   rotation:gcVoodoo.rotation
											  scale:1
										   duration:gcVoodoo.durationRemaining
											ignited:(gcVoodoo.bitmapSettings & (1<<0))];
				break;
			}
			case GADGET_SPELL_NET:
			{
				float netScale = [Idol scaleForIdol:[self idolForKey:GADGET_SPELL_NET]];
				
				NetActor *net = [gc.playerShip deployNetAtX:gcVoodoo.x
														  y:gcVoodoo.y
												   rotation:gcVoodoo.rotation
													  scale:netScale
												   duration:gcVoodoo.durationRemaining
													ignited:(gcVoodoo.bitmapSettings & (1<<0))];
				net.collidableRadiusFactor = gcVoodoo.collidableRadiusFactor;
				break;
			}
			case GADGET_SPELL_CAMOUFLAGE:
				[self activateCamouflageForDuration:gcVoodoo.durationRemaining];
				[self.audioPlayer setVolume:0 forSoundWithKey:@"Camo"]; // Hack: prevent sound replaying on load.
				break;
			case GADGET_SPELL_TNT_BARRELS:
			{
				PowderKegActor *keg = [[PowderKegActor powderKegActorAtX:gcVoodoo.x y:gcVoodoo.y rotation:gcVoodoo.rotation] retain];
				[self addActor:keg];
				[keg release];
			}
				break;
			case VOODOO_SPELL_FLYING_DUTCHMAN:
				[self activateFlyingDutchmanForDuration:gcVoodoo.durationRemaining];
				[self.audioPlayer setVolume:0 forSoundWithKey:@"FlyingDutchman"]; // Hack: prevent sound replaying on load.
				break;
			case VOODOO_SPELL_TEMPEST:
				[mActorBrains summonTempestAtX:gcVoodoo.x y:gcVoodoo.y duration:gcVoodoo.durationRemaining];
				break;
			case VOODOO_SPELL_DEATH_FROM_DEEP:
				[mActorBrains summonDeathFromDeepWithDuration:gcVoodoo.durationRemaining];
				break;
			case VOODOO_SPELL_WHIRLPOOL:
				[self summonWhirlpoolWithDuration:gcVoodoo.durationRemaining];
				break;
			default:
				assert(0);
				break;
		}
	}
	
	// Active Ashes (usually crowd-control ashes)
	for (GCAsh *gcAsh in misc.activeAshes) {
		switch (gcAsh.bitmapID) {
			case ASH_SPELL_ACID_POOL:
			{
				AcidPoolActor *acidPool = [AcidPoolActor acidPoolActorAtX:gcAsh.x y:gcAsh.y duration:gcAsh.durationRemaining];
				[self addActor:acidPool];
			}
                break;
			default:
				break;
		}
	}
}

- (void)saveSceneState:(GameCoder *)coder {
	GameController *gc = [GameController GC];
	GCMisc *misc = (GCMisc *)[coder objectForKey:GAME_CODER_KEY_MISC];
	misc.actorIdSeed = [Actor nextActorId];
	misc.beachState = mView.beachState;
	misc.kegsRemaining = gc.playerShip.kegsRemaining;
	
	if (gc.playerShip.ashProc)
		misc.ashProc = gc.playerShip.ashProc;
	else
		misc.ashProc = [AshProc ashProc];
	
	// Actor Ai
	[mActorBrains saveGameState:coder];
	// Town Ai
	[mGuvnor saveGameState:coder];
	
	// Active voodoo/gadgets
	// Brandy Slick
	if ([mVoodooManager voodooActive:GADGET_SPELL_BRANDY_SLICK]) {
		BrandySlickActor *actor = gc.playerShip.brandySlick;
		
		if (actor != nil) {
			GCVoodoo *gcVoodoo = [[GCVoodoo alloc] init];
			gcVoodoo.bitmapID = GADGET_SPELL_BRANDY_SLICK;
			gcVoodoo.bitmapSettings |= (actor.ignited) ? (1<<0) : 0;
			
			b2Vec2 loc = actor.body->GetPosition();
			gcVoodoo.x = loc.x;
			gcVoodoo.y = loc.y;
			gcVoodoo.rotation = actor.body->GetAngle();
			gcVoodoo.durationRemaining = [mVoodooManager durationRemainingForID:GADGET_SPELL_BRANDY_SLICK];
			[misc addActiveVoodoo:gcVoodoo];
			[gcVoodoo release];
		}
	}
	
	// Trawling Net
	if ([mVoodooManager voodooActive:GADGET_SPELL_NET]) {
		NetActor *actor = gc.playerShip.net;
		
		if (actor != nil) {
			GCVoodoo *gcVoodoo = [[GCVoodoo alloc] init];
			gcVoodoo.bitmapID = GADGET_SPELL_NET;
			gcVoodoo.bitmapSettings |= (actor.ignited) ? (1<<0) : 0;
			b2Vec2 loc = actor.body->GetPosition();
			gcVoodoo.x = loc.x;
			gcVoodoo.y = loc.y;
			gcVoodoo.rotation = actor.body->GetAngle();
			gcVoodoo.durationRemaining = [mVoodooManager durationRemainingForID:GADGET_SPELL_NET];
			gcVoodoo.collidableRadiusFactor = actor.collidableRadiusFactor;
			[misc addActiveVoodoo:gcVoodoo];
			[gcVoodoo release];
		}
	}
	
	// Camouflage
	if ([mVoodooManager voodooActive:GADGET_SPELL_CAMOUFLAGE]) {
		GCVoodoo *gcVoodoo = [[GCVoodoo alloc] init];
		gcVoodoo.bitmapID = GADGET_SPELL_CAMOUFLAGE;
		gcVoodoo.durationRemaining = [mVoodooManager durationRemainingForID:GADGET_SPELL_CAMOUFLAGE];
		[misc addActiveVoodoo:gcVoodoo];
		[gcVoodoo release];
	}
	
	// Powder Kegs
	for (Actor *actor in mActors) {
		if ([actor isKindOfClass:[PowderKegActor class]]) {
			GCVoodoo *gcVoodoo = [[GCVoodoo alloc] init];
			gcVoodoo.bitmapID = GADGET_SPELL_TNT_BARRELS;
			b2Vec2 loc = actor.body->GetPosition();
			gcVoodoo.x = loc.x;
			gcVoodoo.y = loc.y;
			gcVoodoo.rotation = actor.body->GetAngle();
			[misc addActiveVoodoo:gcVoodoo];
			[gcVoodoo release];
		}
	}
	
	// Flying Dutchman
	if ([mVoodooManager voodooActive:VOODOO_SPELL_FLYING_DUTCHMAN]) {
		GCVoodoo *gcVoodoo = [[GCVoodoo alloc] init];
		gcVoodoo.bitmapID = VOODOO_SPELL_FLYING_DUTCHMAN;
		gcVoodoo.durationRemaining = [mVoodooManager durationRemainingForID:VOODOO_SPELL_FLYING_DUTCHMAN];
		[misc addActiveVoodoo:gcVoodoo];
		[gcVoodoo release];
	}
	
	// Deathly Tempest
	if ([mVoodooManager voodooActive:VOODOO_SPELL_TEMPEST]) {
		NSSet *tempests = mActorBrains.tempests;
		NSEnumerator *enumerator = [tempests objectEnumerator];
		
		while (TempestActor *tempest = (TempestActor *)[enumerator nextObject]) {
			GCVoodoo *gcVoodoo = [[GCVoodoo alloc] init];
			gcVoodoo.bitmapID = VOODOO_SPELL_TEMPEST;
			b2Vec2 loc = tempest.body->GetPosition();
			gcVoodoo.x = loc.x;
			gcVoodoo.y = loc.y;
			gcVoodoo.rotation = tempest.body->GetAngle();
			gcVoodoo.durationRemaining = [mVoodooManager durationRemainingForID:VOODOO_SPELL_TEMPEST];
			[misc addActiveVoodoo:gcVoodoo];
			[gcVoodoo release];
		}
	}
	
	// Death from the Deep
	if ([mVoodooManager voodooActive:VOODOO_SPELL_DEATH_FROM_DEEP]) {
		NSSet *dfds = mActorBrains.deathFromDeeps;
		NSEnumerator *enumerator = [dfds objectEnumerator];
		
		while (DeathFromDeep *dfd = (DeathFromDeep *)[enumerator nextObject]) {
			if (dfd == nil) continue; // Prevent warning about unused variable
			GCVoodoo *gcVoodoo = [[GCVoodoo alloc] init];
			gcVoodoo.bitmapID = VOODOO_SPELL_DEATH_FROM_DEEP;
			gcVoodoo.durationRemaining = [mVoodooManager durationRemainingForID:VOODOO_SPELL_DEATH_FROM_DEEP];
			[misc addActiveVoodoo:gcVoodoo];
			[gcVoodoo release];
		}
	}
	
	// Whirlpool
	if ([mVoodooManager voodooActive:VOODOO_SPELL_WHIRLPOOL]) {
		GCVoodoo *gcVoodoo = [[GCVoodoo alloc] init];
		gcVoodoo.bitmapID = VOODOO_SPELL_WHIRLPOOL;
		gcVoodoo.durationRemaining = [mVoodooManager durationRemainingForID:VOODOO_SPELL_WHIRLPOOL];
		[misc addActiveVoodoo:gcVoodoo];
		[gcVoodoo release];
	}
	
	// Active Ashes (usually crowd-control ashes)
	for (Actor *actor in mActors) {
		if ([actor isKindOfClass:[PoolActor class]]) {
			PoolActor *poolActor = (PoolActor *)actor;
			
			if (poolActor.durationRemaining > 0.25f) {
				GCAsh *gcAsh = [[GCAsh alloc] init];
				gcAsh.bitmapID = poolActor.bitmapID;
				b2Vec2 loc = poolActor.body->GetPosition();
				gcAsh.x = loc.x;
				gcAsh.y = loc.y;
				gcAsh.durationRemaining = poolActor.durationRemaining;
				[misc addActiveAsh:gcAsh];
				[gcAsh release];
			}
		}
	}
}

- (void)refreshAfterProgressChanged {
    [self.objectivesManager setupWithRanks:GCTRL.gameStats.objectives];
    [self.objectivesManager prepareForNewGame];
    [mMenuController updateObjectivesLogView];
    [self.achievementManager resetCombatTextCache];
    [mMenuController refreshHiScoreView];
}

- (void)applyCloudGameSettings {
    GameController *gc = GCTRL;
    
    if (mMenuController) {
        [mMenuController setSwitch:@"MusicSwitch" value:[gc.gameSettings settingForKey:GAME_SETTINGS_KEY_MUSIC_ON]];
        [mMenuController setSwitch:@"SfxSwitch" value:[gc.gameSettings settingForKey:GAME_SETTINGS_KEY_SFX_ON]];
    }
    
    if ([gc.gameSettings settingForKey:GAME_SETTINGS_KEY_FLIPPED_CONTROLS] != self.flipped) {
        [self flip:[gc.gameSettings settingForKey:GAME_SETTINGS_KEY_FLIPPED_CONTROLS]];
        
        if (mView.isPerformanceSavingModeEnabled) {
            [mView enablePerformanceSavingMode:NO];
            [mView enablePerformanceSavingMode:YES];
        }
    }
}

- (void)setCloudEvent:(uint)evCode value:(BOOL)value {
    if (value)
        mCloudEvents |= evCode;
    else
        mCloudEvents &=~ evCode;
}

- (void)clearCloudEvents {
    mCloudEvents = 0;
}

static int s_CloudDataUpdateCount = 0;
static int s_CloudSettingsUpdateCount = 0;
- (void)processCloudEvents {
    if (mCloudEvents == 0)
        return;
    
    GameController *gc = GCTRL;
    if ((mCloudEvents & kCloudEvLoggedIn) == kCloudEvLoggedIn || (mCloudEvents & kCloudEvDataChanged) == kCloudEvDataChanged) {
        GameStats *stats = [[PersistenceManager PM] loadCloud];
        if (stats && [stats isKindOfClass:[GameStats class]]) {
            // Only re-save to cloud if someone upgraded. Otherwise we will ping-pong updates back and forth continuously.
            int upgradeStatus = [gc.gameStats upgradeToOther:stats];
            
            if ((upgradeStatus & kGSLocalUpgrade) == kGSLocalUpgrade) {
                // Note: Local upgrade will also update cloud, so we can skip the else clause below.
                [self refreshAfterProgressChanged];
                [self.achievementManager saveProgress];
            } else if ((upgradeStatus & kGSCloudUpgrade) == kGSCloudUpgrade)
                [[PersistenceManager PM] saveCloud:gc.gameStats];
        }
        
        if ((mCloudEvents & kCloudEvLoggedIn) == kCloudEvLoggedIn) {
            [gc.gameSettings syncWithSettings:[[PersistenceManager PM] loadSettings]];
            [gc.gameSettings saveSettingsLocal];
            [self applyCloudGameSettings];
        }
        
        NSLog(@"Cloud data update %d.", ++s_CloudDataUpdateCount);
    } else if ((mCloudEvents & kCloudEvLoggedOut) == kCloudEvLoggedOut) {
        // Do nothing
    }
    
    if ((mCloudEvents & kCloudEvSettingsChanged) == kCloudEvSettingsChanged) {
        [gc.gameSettings syncWithSettings:[[PersistenceManager PM] loadSettings]];
        [gc.gameSettings saveSettingsLocal];
        [self applyCloudGameSettings];
        NSLog(@"Cloud settings update %d.", ++s_CloudSettingsUpdateCount);
    }
    
    [self clearCloudEvents];
}

- (void)onCloudAccountLoggedIn:(SPEvent *)event {
    [self setCloudEvent:kCloudEvLoggedIn value:YES];
}

- (void)onCloudAccountLoggedOut:(SPEvent *)event {
    [self setCloudEvent:kCloudEvLoggedOut value:YES];
}

- (void)onCloudDataChanged:(SPEvent *)event {
    [self setCloudEvent:kCloudEvDataChanged value:YES];
}

- (void)onCloudSettingsChanged:(SPEvent *)event {
    [self setCloudEvent:kCloudEvSettingsChanged value:YES];
}

- (void)onStageDebugTouched:(SPTouchEvent *)event {
#ifdef CHEEKY_DEBUG
    /*
	static BOOL shrunk = NO;
	float debugScale = 0.5f;
	
	SPTouch *touch = [[event touchesWithTarget:mView.stageDebugToggle andPhase:SPTouchPhaseEnded] anyObject];
	
	if (touch == nil)
		return;
	if (shrunk == YES) {
		mBaseSprite.x = 0;
		mBaseSprite.y = 0;
		mBaseSprite.scaleX = 1.0f;
		mBaseSprite.scaleY = 1.0f;
	} else {
		mBaseSprite.x = 0.5f * (self.viewWidth - self.viewWidth * debugScale);
        mBaseSprite.y = 0.5f * (self.viewHeight - self.viewHeight * debugScale);
		mBaseSprite.scaleX = debugScale;
		mBaseSprite.scaleY = debugScale;
	}
	shrunk = !shrunk;
    */
#endif
}

- (void)flip:(BOOL)enable {
    [super flip:enable];
    [self.voodooManager flip:enable];
    [self.achievementManager flip:enable];
    [self.objectivesManager flip:enable];
    [mView flip:enable];
    
    for (Prop *prop in mProps)
        [prop flip:enable];
    for (Actor *actor in mActors)
        [actor flip:enable];
    for (int category = CAT_PF_SEA; category < CAT_PF_HUD; ++category) {
        if (category == CAT_PF_DIALOGS || category == CAT_PF_COMBAT_TEXT)
            continue;
        [self.spriteLayerManager flipChild:enable withCategory:category width:self.viewWidth];
    }
    
    [GCTRL.gameSettings setSettingForKey:GAME_SETTINGS_KEY_FLIPPED_CONTROLS value:enable];
}

- (void)screenConnected {
    mStepDuration = 1.0f / MAX(MIN_FRAME_RATE, GCTRL.fps);
    
    float fpsFactor = GCTRL.fpsFactor;
    
    // PlayerShip fixes its helm's rotation increment
    for (Actor *actor in self.actors)
        [actor fpsFactorChanged:fpsFactor];
}

- (void)screenDisconnected {
    mStepDuration = 1.0f / MAX(MIN_FRAME_RATE, GCTRL.fps);
    
    float fpsFactor = GCTRL.fpsFactor;
    
    // PlayerShip fixes its helm's rotation increment
    for (Actor *actor in self.actors)
        [actor fpsFactorChanged:fpsFactor];
}

- (void)overridingPause {
    if (mState == PfStatePlaying)
        [self displayPauseMenu];
}

- (void)displayPauseMenu {
    if (mState == PfStatePlaying) {
        [mView setPaused:YES];
        [GCTRL.view setMultipleTouchEnabled:NO];
        [super displayPauseMenu];
    }
}

- (void)dismissPauseMenu {
    [mView setPaused:NO];
    
    if (mState == PfStatePlaying)
        [GCTRL.view setMultipleTouchEnabled:YES];
    [super dismissPauseMenu];
}

- (BOOL)touchableDefault {
	return NO;
}

- (int)topCategory {
	return CAT_PF_HUD;
}

- (int)doubloonNotificationCategory {
	return CAT_PF_SEA;
}

- (int)helpCategory {
	return CAT_PF_HUD;
}

- (int)pauseCategory {
	return CAT_PF_SEA;
}

- (uint)allPrizesBitmap {
    return PRIZE_STATS;
}

- (NSString *)pauseTextureName {
	return @"pause-driftwood";
}

- (BOOL)assistedAiming {
	return GCTRL.assistedAiming;
}

- (void)setRaceEnabled:(BOOL)raceEnabled {
    mRaceEnabled = (raceEnabled) ? (mState != PfStatePlaying) : NO;
    
    if (mRaceEnabled) {
        GCTRL.gameStats.shipName = @"Speedboat";
        GCTRL.thisTurn.gameMode = CC_GAME_MODE_SPEED_DEMONS;
        [self setState:PfStatePlaying];
    } else {
        GCTRL.gameStats.shipName = @"Man o' War";
        GCTRL.thisTurn.gameMode = CC_GAME_MODE_DEFAULT;
    }
}

- (void)requestTargetForPursuer:(NSObject *)pursuer {
    [mActorBrains requestTargetForPursuer:pursuer];
}

- (void)actorArrivedAtDestination:(Actor *)actor {
    [mActorBrains actorArrivedAtDestination:actor];
}

- (void)actorDepartedPort:(Actor *)actor {
    [mActorBrains actorDepartedPort:actor];
}

- (void)onButtonTriggered:(SPEvent *)event {
    [mMenuController onButtonTriggered:event];
}

- (void)prisonerOverboard:(Prisoner *)prisoner ship:(ShipActor *)ship {
    GameController *gc = GCTRL;
    
    [mActorBrains prisonerOverboard:prisoner ship:ship];
    
    if (prisoner && ship == nil) {
        [self.achievementManager prisonerPushedOverboard];
        [gc.playerShip.shipDetails prisonerPushedOverboard:prisoner];
    }
    
    if (prisoner && ship == nil && [gc.gameSettings settingForKey:GAME_SETTINGS_KEY_PLANKING_TIPS] == NO)
        [gc.gameSettings setSettingForKey:GAME_SETTINGS_KEY_PLANKING_TIPS value:YES];
    
    if (prisoner && ship == nil)
        [mView hideHintByName:GAME_SETTINGS_KEY_PLANKING_TIPS];
}

- (NSMutableArray *)liveCannonballs {
	NSMutableArray *cannonballs = [[[NSMutableArray alloc] init] autorelease];
	
	for (Actor *actor in mActors) {
		if ([actor isKindOfClass:[Cannonball class]] && actor.markedForRemoval == NO)
			[cannonballs addObject:actor];
	}
	
	return cannonballs;
}

- (void)enablePerformanceSavingMode:(BOOL)enable {
    [mView enablePerformanceSavingMode:enable];
}

- (int)objectivesCategoryForViewType:(ObjectivesViewType)type {
    int category = 0;
    
    switch (type) {
        case ObjViewTypeView: category = CAT_PF_DIALOGS; break;
        case ObjViewTypeCompleted: category = CAT_PF_SURFACE; break;
        case ObjViewTypeCurrent: category = CAT_PF_HUD; break;
        case ObjViewTypeNotices: category = CAT_PF_DECK; break;
        default: break;
    }
    
    return category;
}

- (void)playAmbientSounds {
    if (mState != PfStatePlaying)
        return;
    float volume = 1.0f;
	NSString *key = nil;
	
	if (mRaceEnabled)
		key = @"Engine";
	else {
		key = @"Ambience";
        
        UIDevicePlatform platformType = [RESM platformType];
        if (platformType == UIDevice4iPhone)
            volume *= 0.55f;
        else if (platformType == UIDevice4GiPod)
            volume *= 0.35f;
    }
    
	[self.audioPlayer playSoundWithKey:key volume:volume easeInDuration:2.0f];
    
   // NSLog(@"Playing Ambient Sound: %@", key);
}

- (void)stopAmbientSounds {
	NSString *key = nil;
	
	if (mRaceEnabled)
		key = @"Engine";
	else
		key = @"Ambience";
    
    if (mRetried)
        [self.audioPlayer stopSoundWithKey:key];
    else
        [self.audioPlayer stopEaseOutSoundWithKey:key];
    
    //NSLog(@"Stopping Ambient Sound: %@", key);
}

- (void)onDeckTwitterActivated:(SPEvent *)event {
    if ([ResManager isOSFeatureSupported:@"5.0"] == NO)
        return;
    
    [mMenuController showTwitterViewControllerInitialText:[NSString stringWithFormat:@"Try to beat my score of %@ in #AwesomePirates",
                                                           [Globals commaSeparatedScore:GCTRL.thisTurn.infamy]]
                                               attachment:[self screenshot]];
}

- (TutorialState)intendedTutorialState {
    if (self.raceEnabled)
        return TutorialStateNull;
    
    GameController *gc = GCTRL;
    TutorialState state = TutorialStateNull;
    
    if ([gc.gameSettings settingForKey:GAME_SETTINGS_KEY_DONE_TUTORIAL] == NO)
        state = TutorialStatePrimary;
    else if ([gc.gameSettings settingForKey:GAME_SETTINGS_KEY_DONE_TUTORIAL2] == NO)
    {
        if ([gc.gameSettings settingForKey:GAME_SETTINGS_KEY_DONE_TUTORIAL_1] == NO)
            state = TutorialStatePrimary_1;
        else
            state = TutorialStateSecondary;
    }
    else if (self.objectivesManager.rank >= 3 && [gc.gameSettings settingForKey:GAME_SETTINGS_KEY_DONE_TUTORIAL3] == NO)
        state = TutorialStateTertiary;
#ifndef CHEEKY_LITE_VERSION
    else if (self.objectivesManager.rank >= 10 && [gc.gameSettings settingForKey:GAME_SETTINGS_KEY_DONE_TUTORIAL4] == NO)
        state = TutorialStateQuaternary;
#endif
    return state;
}

- (NSString *)tutorialKey {
    NSString *key = nil;
    
    switch (mTutorialState) {
        case TutorialStatePrimary: key = @"Primary"; break;
#ifndef CHEEKY_LITE_VERSION
        case TutorialStatePrimary_1: key = @"Primary_1"; break;
        case TutorialStateSecondary: key = @"Secondary"; break;
#else
        case TutorialStateSecondary: key = @"SecondaryLite"; break;
#endif
        case TutorialStateTertiary: key = @"Tertiary"; break;
        case TutorialStateQuaternary: key = @"Quaternary"; break;
        case TutorialStateNull:
        default:
            break;
    }
    
    return key;
}

- (NSString *)tutorialSettingKey {
    NSString *key = nil;
    
    switch (mTutorialState) {
        case TutorialStatePrimary: key = GAME_SETTINGS_KEY_DONE_TUTORIAL; break;
        case TutorialStatePrimary_1: key = GAME_SETTINGS_KEY_DONE_TUTORIAL_1; break;
        case TutorialStateSecondary: key = GAME_SETTINGS_KEY_DONE_TUTORIAL2; break;
        case TutorialStateTertiary: key = GAME_SETTINGS_KEY_DONE_TUTORIAL3; break;
        case TutorialStateQuaternary: key = GAME_SETTINGS_KEY_DONE_TUTORIAL4; break;
        case TutorialStateNull:
        default:
            break;
    }
    
    return key;
}

- (void)beginTutorial {
    if (mTutorialState == TutorialStateNull)
        return;
    //mTutorialWinRun = NO;
    [mView displayTutorialForKey:[self tutorialKey] fromPageIndex:0 toPageIndex:-1];
    [self enableSuspendedPlayerMode:YES];
    [mVoodooManager bubbleMenuToTop];
}

- (void)finishTutorial {
    [mView dismissTutorial];
    [self destroyHelpAtlas];
	
	GameController *gc = GCTRL;
    NSString *settingKey = [self tutorialSettingKey];
    
    if (settingKey)
        [gc.gameSettings setSettingForKey:settingKey value:YES];
	
    [self enableSuspendedSceneMode:NO];
    [self enableSuspendedPlayerMode:NO];
    [mView createPlayerShip];
    
    if (mTutorialState == TutorialStatePrimary && [gc.gameSettings settingForKey:GAME_SETTINGS_KEY_PLAYER_SHIP_TIPS] == NO) {
        [gc.gameSettings setSettingForKey:GAME_SETTINGS_KEY_PLAYER_SHIP_TIPS value:YES];
        
        PlayerShip *playerShip = gc.playerShip;
        
        if (playerShip) {
            [mView displayHintByName:GAME_SETTINGS_KEY_PLAYER_SHIP_TIPS x:playerShip.x y:playerShip.y radius:0.75f * playerShip.height target:playerShip exclusive:NO];
            [(PlayfieldView *)[self.juggler delayInvocationAtTarget:mView byTime:10.0f] hideHintByName:GAME_SETTINGS_KEY_PLAYER_SHIP_TIPS];
        }
    }
    
    [gc.gameSettings saveSettings];
    mTutorialState = TutorialStateNull;
}

- (void)hideHintByName:(NSString *)name {
    [mView hideHintByName:name];
}

- (void)advanceTime:(double)time {
	//float stepTime = 0.0f, stepIncrement = 0.0f;
    GameController *gc = GCTRL;
    
    if (self.state == PfStateMenu)
        [self processCloudEvents];
	
	if (mResettingScene == YES) {
		[self resetSceneComplete];
    } else if (mState == PfStateHibernating) {
        return;
	} else if (mScenePaused == NO) {
        mLocked = YES; // LOCKED
        
        [self.achievementManager fillCombatTextCache];
        //[mView advanceFpsCounter:time];
        
        // A constant, single step seems to be fine. Uncomment where appropriate to force Box2D to accumulate lag and "catch the Box2D world up" (performace hit on old devices).
        //BOOL lowPerformce = RESM.isLowPerformance;
        double cappedTime = MIN(time, 1.25 / (double)gc.fps); //(lowPerformce) ? mStepDuration : MIN(time, 1.25 / (double)gc.fps);
        double unSlowedTime = cappedTime;
     
#if 1
        if (mTimeSlowed) {
            cappedTime *= self.timeSlowedFactor;
            mWorld->Step(mStepDuration * self.timeSlowedFactor, mVelocityIterations, mPositionIterations);
        } else {
            mWorld->Step(mStepDuration, mVelocityIterations, mPositionIterations);
        }
     
        //[mProfiler startProfilerForKey:@"Box2D"];
#else
		mStepAccumulator += cappedTime;
		
        while (mStepAccumulator > mStepDuration)
        {
            mWorld->Step(mStepDuration, mVelocityIterations, mPositionIterations);
            mStepAccumulator -= mStepDuration;
            // Probably should process Actors here, but we currently don't.
        }
#endif
        mWorld->ClearForces();
		//mStepAccumulator = MAX(0, mStepAccumulator);
        
		mLocked = NO; // UNLOCKED
        
        [mMenuController advanceTime:MIN(time, 2.0 / (double)gc.fps)]; // Don't advance any more than 2 standard frames (in case of large delay)
        [gc.timeKeeper advanceTime:cappedTime];
        
//[mProfiler stopProfilerForKey:@"Box2D"];
		
//[mProfiler startProfilerForKey:@"Voodoo"];
		//[mVoodooManager advanceTime:unSlowedTime];
//[mProfiler stopProfilerForKey:@"Voodoo"];
        
//[mProfiler startProfilerForKey:@"Super"];
		[super advanceTime:unSlowedTime];
//[mProfiler stopProfilerForKey:@"Super"];

//[mProfiler startProfilerForKey:@"ActorAi"];
		[mActorBrains advanceTime:cappedTime];
//[mProfiler stopProfilerForKey:@"ActorAi"];
        
//[mProfiler startProfilerForKey:@"TownAi"];
		[mGuvnor advanceTime:cappedTime];
//[mProfiler stopProfilerForKey:@"TownAi"];
       
//[mProfiler startProfilerForKey:@"View"];
		[mView advanceTime:cappedTime];
//[mProfiler stopProfilerForKey:@"View"];
     
        [self checkForMontysMutiny];
        
        if (gc.gameWindowDidLoseFocus && mState == PfStatePlaying)
            [self displayPauseMenu];
        
        // Disable interface until we're launched
        if (mState == PfStateLaunching) {
            [mMenuController setState:MenuStateLaunching];
            
            if (mLaunchTimer > 0)
                mLaunchTimer -= time;
            if (mLaunchTimer <= 0)
                [self setState:PfStateMenu];
        }
		
		//if (++logMod == 60) {
		//	logMod = 0;
		//	NSLog(@"BODY COUNT: %d", mWorld->GetBodyCount());
		//}
	} else {
		[super advanceTime:time];
	}
}

- (void)checkForMontysMutiny {
    GameController *gc = GCTRL;
    
    if (gc.thisTurn.adventureState == AdvStateStopShips && gc.playerShip.monty == MSFirstMate) {
        if (mActorBrains.isPlayfieldClearOfNpcShips) {
            if (gc.playerShip.isPlankingEnqueued == NO) {
                [gc.playerShip enablePlank:NO];
            
                if (mActorBrains.isPlayfieldClear) {
                    [mVoodooManager prepareForGameOver];
                    gc.playerShip.monty = MSSkipper;
                }
            }
        }
    }
    
    if (mMontyShouldMutiny)
        [self beginMontysMutinySequence];
}

- (void)beginMontysMutinySequence {
    GameController *gc = [GameController GC];
    
    [mActorBrains enactMontysMutiny];
    
    int dir = (gc.playerShip.x < self.viewWidth / 2) ? 1 : -1;
    [mView displayFirstMateAlert:[NSArray arrayWithObjects:
                                  @"Man overboard!",
                                  @"That's a most unfortunate accident you've had there, Cap'n!",
                                  @"As First Mate, I've always warned that the deck can get slippery at this time of day.",
                                  @"Hold on while I bring her around to pick you up.",
                                  @"On second thought, I think Captain Montgomery has a nice ring to it, wouldn't you say?",
                                  @"What goes around comes around...so long, swabby!",
                                  nil]
                        userData:kFirstMateMutinied
                             dir:dir
                      afterDelay:2.0f];
    
    gc.thisTurn.adventureState = AdvStateOverboard;
    mMontyShouldMutiny = NO;
}

- (void)cannonsOverheated {
    if ([GCTRL.gameSettings settingForKey:GAME_SETTINGS_KEY_CANNON_OVERHEATED_TIPS] == NO)
        mCannonsDidOverheat = YES;
}

- (void)beginOverheatedCannonsSequence {
    [mView displayFirstMateAlert:[NSArray arrayWithObjects:
                                  @"First mate Montgomery here, Cap'n.",
                                  @"You'll need to maintain a high accuracy or reduce your rate of fire to prevent the cannons overheating.",
                                  nil]
                        userData:kOverheatedCannonsNotice
                             dir:1
                      afterDelay:0.0f];
}

- (void)addActor:(Actor *)actor {
	[super addActor:actor];
	
    // For testing
	/*
	int worldActorCount = 0;
	b2Body *bodyList = mWorld->GetBodyList();
	
	while ((bodyList = bodyList->GetNext()))
		++worldActorCount;
	NSLog(@"Actor count: %d World count: %d", mActors.count, worldActorCount);
	 */
}

- (void)removeActor:(Actor *)actor {
	[super removeActor:actor];
	
	if (mActorBrains != nil)
		[mActorBrains removeActor:actor];
}

- (void)enableSuspendedSceneMode:(BOOL)enable {
    if (mSuspendedMode == enable)
        return;
    GCTRL.timeKeeper.timerActive = !enable;
    [mActorBrains enableSuspendedMode:enable];
    [mGuvnor enableSuspendedMode:enable];
    [mVoodooManager enableSuspendedMode:enable];
    [self.achievementManager enableSuspendedMode:enable];
    mSuspendedMode = enable;
}

- (void)enableSuspendedPlayerMode:(BOOL)enable {
    [GCTRL.playerShip enableSuspendedMode:enable];
}

- (void)onPlayPressed:(SPEvent *)event {
    if (mState == PfStatePlaying)
        return;
    
    self.raceEnabled = NO;
    [self setState:PfStatePlaying];
}

- (void)setGameOver:(BOOL)value {
	if (value)
        [self setState:PfStateEndOfTurn];
	GCTRL.thisTurn.isGameOver = value;
}

- (void)displayEnqueuedNotice {
    if (self.enqueuedRankNotice) {
        [self.objectivesManager enqueueNotice:self.enqueuedRankNotice];
        self.enqueuedRankNotice = nil;
    }
}

- (void)onGCScoreReported:(SPEvent *)event {
    /* Ignore for now */
}

- (void)onGCScoresFetched:(MultiPurposeEvent *)event {
    if (event == nil || event.data == nil)
        return;
    if ([event.data objectForKey:@"Error"])
        return;
    if ([event.data objectForKey:@"Scores"] == nil)
        return;
    
    GameController *gc = GCTRL;
    GKLeaderboard *lb = (GKLeaderboard *)[event.data objectForKey:@"Scores"];
    NSArray *scores = lb.scores;
    
    // If no friends scores, still signal them as 1st to encourage them to invite their friends to compete.
    if (scores == nil)
        scores = [NSArray array];
    
    switch (lb.playerScope) {
        case GKLeaderboardPlayerScopeFriendsOnly:
        {
            int localRank = -1;
            if ([lb.category isEqualToString:CC_GAME_MODE_SPEED_DEMONS]) {
                if (self.raceEnabled && self.isRaceFinished) {
                    int64_t localSpeed = (int64_t)(gc.thisTurn.speed * 1000.0);
                    if (scores != nil) {
                        for (int i = 0; i < scores.count; ++i) {
                            GKScore *score = (GKScore *)[scores objectAtIndex:i];
                            if (score) {
                                if (localSpeed >= score.value) {
                                    localRank = i + 1;
                                    break;
                                }
                            }
                        }
                    }
                    else
                        localRank = 1;
                    
                    if (localRank == -1 && scores.count < kFriendsRangeUpper)
                        localRank = scores.count + 1;
                    
                    if (localRank == -1)
                        self.enqueuedRankNotice = [NSString stringWithFormat:@"Friends Rank: %d%@%@", scores.count + 1, [GuiHelper suffixForRank:scores.count + 1], @"+"];
                    else
                        self.enqueuedRankNotice = [NSString stringWithFormat:@"Friends Rank: %d%@", localRank, [GuiHelper suffixForRank:localRank]];
                    
                    if (self.isTravellingThroughTime == NO)
                        [self displayEnqueuedNotice];
                }
            } else if ([lb.category isEqualToString:CC_GAME_MODE_DEFAULT]) {
                if (self.state == PfStateEndOfTurn) {
                    int64_t localSscore = gc.thisTurn.infamy;
                    if (scores != nil) {
                        for (int i = 0; i < scores.count; ++i) {
                            GKScore *score = (GKScore *)[scores objectAtIndex:i];
                            if (score) {
                                int64_t infamy = score.value;
                                if (localSscore >= infamy) {
                                    localRank = i + 1;
                                    break;
                                }
                            }
                        }
                    }
                    else
                        localRank = 1;
                    
                    if (localRank == -1 && scores.count < kFriendsRangeUpper)
                        localRank = scores.count + 1;
                    
                    if (localRank == -1)
                        self.enqueuedRankNotice = [NSString stringWithFormat:@"Friends Rank: %d%@%@", scores.count + 1, [GuiHelper suffixForRank:scores.count + 1], @"+"];
                    else
                        self.enqueuedRankNotice = [NSString stringWithFormat:@"Friends Rank: %d%@", localRank, [GuiHelper suffixForRank:localRank]];
                    if (self.isGameSummaryShowing)
                        [self displayEnqueuedNotice];
                }
            }
        }
            break;
        default:
            break;;
    }
}

- (void)setupVoodooManagerListeners {
	[mVoodooManager addEventListener:@selector(onPowderKegDropping:) atObject:self forType:CUST_EVENT_TYPE_POWDER_KEG_DROPPING];
	[mVoodooManager addEventListener:@selector(onNetDeployed:) atObject:self forType:CUST_EVENT_TYPE_NET_DEPLOYED];
	[mVoodooManager addEventListener:@selector(onBrandySlickDeployed:) atObject:self forType:CUST_EVENT_TYPE_BRANDY_SLICK_DEPLOYED];
	[mVoodooManager addEventListener:@selector(onTempestSummoned:) atObject:self forType:CUST_EVENT_TYPE_TEMPEST_SUMMONED];
	[mVoodooManager addEventListener:@selector(onWhirlpoolSummoned:) atObject:self forType:CUST_EVENT_TYPE_WHIRLPOOL_SUMMONED];
	[mVoodooManager addEventListener:@selector(onDeathFromDeepSummoned:) atObject:self forType:CUST_EVENT_TYPE_DEATH_FROM_DEEP_SUMMONED];
	[mVoodooManager addEventListener:@selector(onCamouflageActivated:) atObject:self forType:CUST_EVENT_TYPE_CAMOUFLAGE_ACTIVATED];
	[mVoodooManager addEventListener:@selector(onFlyingDutchmanActivated:) atObject:self forType:CUST_EVENT_TYPE_FLYING_DUTCHMAN_ACTIVATED];
    [mVoodooManager addEventListener:@selector(onSeaOfLavaSummoned:) atObject:self forType:CUST_EVENT_TYPE_SEA_OF_LAVA_SUMMONED];
}

- (void)removeVoodooManagerListeners {
	[mVoodooManager removeEventListener:@selector(onPowderKegDropping:) atObject:self forType:CUST_EVENT_TYPE_POWDER_KEG_DROPPING];
	[mVoodooManager removeEventListener:@selector(onNetDeployed:) atObject:self forType:CUST_EVENT_TYPE_NET_DEPLOYED];
	[mVoodooManager removeEventListener:@selector(onBrandySlickDeployed:) atObject:self forType:CUST_EVENT_TYPE_BRANDY_SLICK_DEPLOYED];
	[mVoodooManager removeEventListener:@selector(onTempestSummoned:) atObject:self forType:CUST_EVENT_TYPE_TEMPEST_SUMMONED];
	[mVoodooManager removeEventListener:@selector(onWhirlpoolSummoned:) atObject:self forType:CUST_EVENT_TYPE_WHIRLPOOL_SUMMONED];
	[mVoodooManager removeEventListener:@selector(onDeathFromDeepSummoned:) atObject:self forType:CUST_EVENT_TYPE_DEATH_FROM_DEEP_SUMMONED];
	[mVoodooManager removeEventListener:@selector(onCamouflageActivated:) atObject:self forType:CUST_EVENT_TYPE_CAMOUFLAGE_ACTIVATED];
	[mVoodooManager removeEventListener:@selector(onFlyingDutchmanActivated:) atObject:self forType:CUST_EVENT_TYPE_FLYING_DUTCHMAN_ACTIVATED];
    [mVoodooManager removeEventListener:@selector(onSeaOfLavaSummoned:) atObject:self forType:CUST_EVENT_TYPE_SEA_OF_LAVA_SUMMONED];
}

- (void)awardPrizes:(uint)prizes {
    GameController *gc = GCTRL;
    
    if ((prizes & PRIZE_STATS) && !(mPrizesBitmap & PRIZE_STATS)) {
        gc.thisTurn.daysAtSea = MAX(0,((int)gc.timeKeeper.day)-1) + gc.timeKeeper.timePassedToday / [TimeKeeper timePerDay];
        [gc.thisTurn commitStats];
    }
    mPrizesBitmap |= prizes;
}

- (void)removeCachedResources {
    GameController *gc = GCTRL;
    
    [gc cacheResource:nil forKey:RESOURCE_CACHE_COMBAT_TEXT];
    [gc cacheResource:nil forKey:RESOURCE_CACHE_MANAGERS];
}

- (void)igniteAllIgnitableActors {
	for (Actor *actor in mActors) {
		if ([actor conformsToProtocol:@protocol(Ignitable)]) {
			id<Ignitable> ignitableActor = (id<Ignitable>)actor;
			[ignitableActor ignite];
		}
	}
}

- (void)activateCamouflageForDuration:(float)duration {
    GameController *gc = GCTRL;

    if (gc.playerShip.isFlyingDutchman)
        [gc.playerShip deactivateFlyingDutchman];
	[mActorBrains activateCamouflageForDuration:duration];
}

- (void)activateFlyingDutchmanForDuration:(float)duration {
	GameController *gc = GCTRL;
    
    if (gc.playerShip.isCamouflaged)
        [mActorBrains deactivateCamouflage];
	[gc.playerShip activateFlyingDutchman];
	[[mJuggler delayInvocationAtTarget:gc.playerShip byTime:duration] deactivateFlyingDutchman];
}

- (void)summonWhirlpoolWithDuration:(float)duration {
	[mView.sea summonWhirlpoolWithDuration:duration];
}

- (void)onPrisonersChanged:(NumericValueChangedEvent *)event {
    if ([event.value unsignedIntValue] > 0 && [GCTRL.gameSettings settingForKey:GAME_SETTINGS_KEY_PLANKING_TIPS] == NO) {
        ResOffset *offset = [RESM itemOffsetWithAlignment:RALowerCenter];
        [mView displayHintByName:GAME_SETTINGS_KEY_PLANKING_TIPS x:320 + offset.x y:260 + offset.y radius:0 target:nil exclusive:YES];
    }
}

- (void)onPowderKegDropping:(SPEvent *)event {
	GameController *gc = [GameController GC];
	PlayerShip *ship = [GameController GC].playerShip;
	uint kegsCount = [Idol countForIdol:[self idolForKey:GADGET_SPELL_TNT_BARRELS]];
	
	[ship dropPowderKegs:kegsCount];
	gc.achievementManager.kabooms = 0;
}

- (void)onNetDeployed:(SPEvent *)event {
    float duration = [Idol durationForIdol:[self idolForKey:GADGET_SPELL_NET]];
	float netScale = 1.25f * [Idol scaleForIdol:[self idolForKey:GADGET_SPELL_NET]];
	//netScale *= [self.enhancements functionalFactorForEnhancement:ENHANCE_DEN_TRAWLIN byCategory:ENHANCE_CAT_DEN];
	[[GameController GC].playerShip deployNetWithScale:netScale duration:duration];
}

- (void)onBrandySlickDeployed:(SPEvent *)event {
    GameController *gc = GCTRL;
	float duration = [Idol durationForIdol:[self idolForKey:GADGET_SPELL_BRANDY_SLICK]];
	BrandySlickActor *brandySlick = [gc.playerShip deployBrandySlickWithDuration:duration];
    
    if (brandySlick && [gc.gameSettings settingForKey:GAME_SETTINGS_KEY_BRANDY_SLICK_TIPS] == NO)
        [mView displayHintByName:GAME_SETTINGS_KEY_BRANDY_SLICK_TIPS x:brandySlick.x y:brandySlick.y radius:10 target:brandySlick exclusive:NO];
}

- (void)onTempestSummoned:(SPEvent *)event {
	[mActorBrains summonTempest];
	[mActorBrains summonTempest];
}

- (void)onWhirlpoolSummoned:(SPEvent *)event {
	float duration = [Idol durationForIdol:[self idolForKey:VOODOO_SPELL_WHIRLPOOL]];
	[self summonWhirlpoolWithDuration:duration];
}

- (void)onDeathFromDeepSummoned:(SPEvent *)event {
	float duration = [Idol durationForIdol:[self idolForKey:VOODOO_SPELL_DEATH_FROM_DEEP]];

	[mActorBrains summonDeathFromDeepWithDuration:duration];
	[mActorBrains summonDeathFromDeepWithDuration:duration];
}

- (void)onCamouflageActivated:(SPEvent *)event {
	[self activateCamouflageForDuration:[Idol durationForIdol:[self idolForKey:GADGET_SPELL_CAMOUFLAGE]]];
}

- (void)onFlyingDutchmanActivated:(SPEvent *)event {
	float duration = [Idol durationForIdol:[self idolForKey:VOODOO_SPELL_FLYING_DUTCHMAN]];
	[self activateFlyingDutchmanForDuration:duration];
}

- (void)onSeaOfLavaSummoned:(SPEvent *)event {
    float duration = [Idol durationForIdol:[self idolForKey:VOODOO_SPELL_SEA_OF_LAVA]] / 2.0f;
    [mView.sea transitionToLavaOverTime:duration];
}

- (void)onSeaOfLavaPeaked:(SPEvent *)event {
    [mActorBrains sinkAllShipsWithDeathBitmap:DEATH_BITMAP_SEA_OF_LAVA];
    [self igniteAllIgnitableActors];
    [GCTRL.playerShip despawnNetOverTime:1.0f];
    
    for (Actor *actor in mActors) {
        if ([actor isKindOfClass:[AcidPoolActor class]]) {
            AcidPoolActor *acidPool = (AcidPoolActor *)actor;
            [acidPool despawnOverTime:1.0f];
        }
    }
    
    float duration = [Idol durationForIdol:[self idolForKey:VOODOO_SPELL_SEA_OF_LAVA]] / 2.0f;
    [mView.sea transitionFromLavaOverTime:duration delay:1.0f];
}

- (void)onAshPickupLooted:(NumericValueChangedEvent *)event {
    GameController *gc = GCTRL;
    uint ashKey = [event.value unsignedIntValue];
    
    Ash *ash = [Ash ashWithKey:ashKey];
    AshProc *ashProc = [Ash ashProcForAsh:ash];
    gc.playerShip.ashProc = ashProc;
}

- (void)onRaceFinished:(MultiPurposeEvent *)event {
    mIsRaceFinished = YES;
    
    if (event && event.data) {
        NSNumber *willTravelThroughTime = [event.data objectForKey:CUST_EVENT_TYPE_RACE_FINISHED];
        if (willTravelThroughTime)
            self.isTravellingThroughTime = [willTravelThroughTime boolValue];
    }
    
    [self.ofManager gcFetchScoresForCategory:CC_GAME_MODE_SPEED_DEMONS
                                       range:NSMakeRange(kFriendsRangeLower, kFriendsRangeUpper)
                                 playerScope:GKLeaderboardPlayerScopeFriendsOnly
                                   timeScope:GKLeaderboardTimeScopeAllTime];
    [GCTRL processEndOfTurn];
}

- (void)onRaceTrackConquered:(SPEvent *)event {
	float delay = [mView travelForwardInTime];
	[[mJuggler delayInvocationAtTarget:GCTRL.achievementManager byTime:delay + 1.0f] grant88MphAchievement];
}

- (void)onSpeedDemonAchieved:(SPEvent *)event {
    float delay = [mView travelForwardInTime];
	[[mJuggler delayInvocationAtTarget:GCTRL.achievementManager byTime:delay + 1.0f] grant88MphAchievement];
	[[mJuggler delayInvocationAtTarget:GCTRL.achievementManager byTime:delay + 1.0f] grantSpeedDemonAchievement];
}

- (void)onCloseButNoCigarStateReached:(SPEvent *)event {
	[[GameController GC].achievementManager grantCloseButNoCigarAchievement];
}

- (void)timeTravelSequenceDidComplete {
    if (self.raceEnabled && self.isRaceFinished && mState == PfStatePlaying) {
        self.isTravellingThroughTime = NO;
        [self displayEnqueuedNotice];
    }
}

- (void)gameOverSequenceDidComplete {
    if (mState == PfStateEndOfTurn) {
        self.isGameSummaryShowing = YES;
        [self displayEnqueuedNotice];
        [mView showTwitter];
    }
}

- (void)onGameOverRetryPressed:(SPEvent *)event {
    [GCTRL processEndOfTurn];
	[self setState:PfStateMenu];
    [self setState:PfStatePlaying];
}

- (void)onGameOverMenuPressed:(SPEvent *)event {
	[self setState:PfStateMenu];
}

- (void)onGameOverSubmitPressed:(SPEvent *)event {
    // Do nothing
}

- (void)onChallengeSent:(SPEvent *)event {
    [mView enableSummaryButton:NO forKey:@"Submit"];
}

- (void)onTimeOfDayChangedEvent:(TimeOfDayChangedEvent *)event {
    [mView onTimeOfDayChangedEvent:event];
    
	if (GCTRL.thisTurn.isGameOver)
		return;
	GameController *gc = [GameController GC];
    
    [self.objectivesManager progressObjectiveWithEventType:OBJ_TYPE_TIME_OF_DAY];
    
    switch (event.timeOfDay) {
        case SunriseTransition:
        {
            if (event.day == 3)
                [mView enableWeather:NO];
            
            if (mRaceEnabled == NO && gc.thisTurn.adventureState == AdvStateNormal) {
                float fadeInDuration = 2.0f;
                [mView showDayIntroForDay:event.day overTime:fadeInDuration];
                [mView hideDayIntroOverTime:fadeInDuration delay:5.0f + fadeInDuration];
            }
        }
            break;
        case Dusk:
        {
            if (event.day == [TimeKeeper maxDay] && mRaceEnabled == NO && gc.thisTurn.adventureState == AdvStateNormal) {
                [mGuvnor removeTarget:gc.playerShip];
                [mGuvnor stopThinking];
                [mActorBrains prepareForMontyMutiny];
                gc.thisTurn.adventureState = AdvStateStopShips;
            }
        }
            break;
        default:
            break;
    }
}

- (void)onMontySkippered:(SPEvent *)event {
    [self.audioPlayer playSoundWithKey:@"Splash"];
    mMontyShouldMutiny = YES;
}

- (void)onPlayerEaten:(SPEvent *)event {
    GameController *gc = [GameController GC];
    
    if (gc.thisTurn.adventureState == AdvStateOverboard) {
        gc.thisTurn.adventureState = AdvStateEaten;
        [self prepareForGameOver];
    }
}

- (void)prepareForGameOver {
    GameController *gc = GCTRL;
    
    if (gc.thisTurn.isGameOver == NO) {
        [self setGameOver:YES];
        [self awardPrizes:PRIZE_STATS];
        [mView prepareForGameOver];
        [mGuvnor prepareForGameOver];
        [mActorBrains prepareForGameOver];
        [self.objectivesManager prepareForGameOver];
		[[mJuggler delayInvocationAtTarget:self byTime:0.8f] transitionToTurnOver];
        [[mJuggler delayInvocationAtTarget:mView byTime:1.0f] displayGameOverSequence];
        
        [self.ofManager gcFetchScoresForCategory:CC_GAME_MODE_DEFAULT
                                           range:NSMakeRange(kFriendsRangeLower, kFriendsRangeUpper)
                                     playerScope:GKLeaderboardPlayerScopeFriendsOnly
                                       timeScope:GKLeaderboardTimeScopeAllTime];
	}
}

- (void)onInfamyChanged:(NumericValueChangedEvent *)event {
    [self.objectivesManager progressObjectiveWithEventType:OBJ_TYPE_SCORE];
}

- (void)onPlayerShipSinking:(SPEvent *)event {
	[self prepareForGameOver];
}

- (void)onPlayerShipEnteredCove:(SPEvent *)event {
    //NSLog(@"BAD: PlayerShip should not be entering the Cove!");
    //GCTRL.state = StateTitle;
}

- (void)onMutinyChanged:(NumericRatioChangedEvent *)event {
    GameController *gc = GCTRL;
    
	if (gc.thisTurn.isGameOver == NO) {
        int delta = [event.delta intValue];
        UIDevicePlatform platformType = [RESM platformType];
        
        if (delta < 0) {
            [self.objectivesManager progressObjectiveWithEventType:OBJ_TYPE_BLUE_CROSS];
            [self.audioPlayer playSoundWithKey:@"MutinyFall" volume:((platformType == UIDevice3GiPod) ? 0.85f : 1.0f)];
        } else if (delta > 0 || gc.thisTurn.playerShouldDie) {
            [self.objectivesManager progressObjectiveWithEventType:OBJ_TYPE_RED_CROSS];
            [self.audioPlayer playSoundWithKey:@"MutinyRise" volume:((platformType == UIDevice3GiPod) ? 0.85f : 1.0f)];
            
            if (gc.thisTurn.mutiny == 3 && [GCTRL.gameSettings settingForKey:GAME_SETTINGS_KEY_VOODOO_TIPS] == NO) {
                ResOffset *offset = [RESM itemOffsetWithAlignment:RALowerCenter];
                [mView displayHintByName:GAME_SETTINGS_KEY_VOODOO_TIPS x:240 + offset.x y:260 + offset.y radius:0 target:nil exclusive:YES];
            }
        }
        
        if (gc.thisTurn.isGameOver == NO && gc.thisTurn.playerShouldDie)
            [self prepareForGameOver];
	}
}

- (void)onChallengeConditionBreached:(SPEvent *)event {
    [self prepareForGameOver];
}

- (void)onTutorialCompleted:(SPEvent *)event {
	[self finishTutorial];
}

- (void)onFirstMateDecision:(SPEvent *)event {
	FirstMate *mate = (FirstMate *)event.currentTarget;
	[mate retireToCabin];
	[mate retractTouchBarrier];
}

- (void)onFirstMateRetiredToCabin:(SPEvent *)event {
	FirstMate *mate = (FirstMate *)event.currentTarget;
    
    switch (mate.userData) {
        case kFirstMateMutinied:
        {
            GCTRL.playerShip.monty = MSMutineer;
            [mActorBrains markPlayerAsEdible];
        }
            break;
        case kEtherealPotionNotice:
        {
            [GCTRL.gameStats enforcePotionRequirements];
            
            if (mState == PfStateEndOfTurn || mState == PfStateDelayedRetry || mState == PfStateDelayedQuit) {
                if (mCannonsDidOverheat)
                    [self beginOverheatedCannonsSequence];
                else
                    [self continueEndOfTurn];
            }
        }
            break;
        case kOverheatedCannonsNotice:
        {
            mCannonsDidOverheat = NO;
            [GCTRL.gameSettings setSettingForKey:GAME_SETTINGS_KEY_CANNON_OVERHEATED_TIPS value:YES];
            
            if (mState == PfStateEndOfTurn || mState == PfStateDelayedRetry || mState == PfStateDelayedQuit)
                [self continueEndOfTurn];
        }
            break;
        default:
            break;
    }
    
	[mate removeEventListener:@selector(onFirstMateDecision:) atObject:self forType:CUST_EVENT_TYPE_FIRST_MATE_DECISION];
	[mate removeEventListener:@selector(onFirstMateRetiredToCabin:) atObject:self forType:CUST_EVENT_TYPE_FIRST_MATE_RETIRED];
	[mate retractTouchBarrier];
	[self removeProp:mate];
}

- (void)onTreasureFleetSpawned:(SPEvent *)event {
    GameController *gc = GCTRL;
    
    if ([gc.gameSettings settingForKey:GAME_SETTINGS_KEY_TREASURE_FLEET_TIPS] == NO) {
        SPDisplayObject *target = (SPDisplayObject *)mActorBrains.fleet;
        [mView displayHintByName:GAME_SETTINGS_KEY_TREASURE_FLEET_TIPS x:target.x-15 y:target.y+18 radius:0 target:target exclusive:NO];
        [(PlayfieldView *)[self.juggler delayInvocationAtTarget:mView byTime:25] hideHintByName:GAME_SETTINGS_KEY_TREASURE_FLEET_TIPS];
    }
}

- (void)onTreasureFleetAttacked:(SPEvent *)event {
    GameController *gc = GCTRL;
    
    if ([gc.gameSettings settingForKey:GAME_SETTINGS_KEY_TREASURE_FLEET_TIPS] == NO)
        [gc.gameSettings setSettingForKey:GAME_SETTINGS_KEY_TREASURE_FLEET_TIPS value:YES];
    
    [mView hideHintByName:GAME_SETTINGS_KEY_TREASURE_FLEET_TIPS];
}

- (void)onSilverTrainSpawned:(SPEvent *)event {
    GameController *gc = GCTRL;
    
    if ([gc.gameSettings settingForKey:GAME_SETTINGS_KEY_SILVER_TRAIN_TIPS] == NO) {
        SPDisplayObject *target = (SPDisplayObject *)mActorBrains.fleet;
        [mView displayHintByName:GAME_SETTINGS_KEY_SILVER_TRAIN_TIPS x:target.x+5 y:target.y+28 radius:0 target:target exclusive:NO];
        [(PlayfieldView *)[self.juggler delayInvocationAtTarget:mView byTime:30] hideHintByName:GAME_SETTINGS_KEY_SILVER_TRAIN_TIPS];
    }
}

- (void)onSilverTrainAttacked:(SPEvent *)event {
    GameController *gc = GCTRL;
    
    if ([gc.gameSettings settingForKey:GAME_SETTINGS_KEY_SILVER_TRAIN_TIPS] == NO)
        [gc.gameSettings setSettingForKey:GAME_SETTINGS_KEY_SILVER_TRAIN_TIPS value:YES];
    
    [mView hideHintByName:GAME_SETTINGS_KEY_SILVER_TRAIN_TIPS];
}

- (void)onDeckVoodooIdolPressed:(SPEvent *)event {
    // VoodooWheel will constrain this to valid coordinates.
    [mVoodooManager showMenuAtX:self.viewWidth / 2 y:self.viewHeight];
    [mView hideHintByName:GAME_SETTINGS_KEY_VOODOO_TIPS];
    [self enableSlowedTime:YES];
    
    GameController *gc = GCTRL;
    
    if ([gc.gameSettings settingForKey:GAME_SETTINGS_KEY_VOODOO_TIPS] == NO)
        [gc.gameSettings setSettingForKey:GAME_SETTINGS_KEY_VOODOO_TIPS value:YES];
}

- (void)onVoodooMenuClosing:(SPEvent *)event {
    [self enableSlowedTime:NO];
}

- (void)enableSlowedTime:(BOOL)enable {
    [super enableSlowedTime:enable];
    [mView enableSlowedTime:enable];
}

- (void)displayEtherealPotionNoticeWithMsgs:(NSArray *)msgs {
    [mView displayEtherealAlert:msgs
                        userData:kEtherealPotionNotice
                             dir:1
                      afterDelay:0.5f];
}

- (void)fadeOutShipLayer {
	SPDisplayObject *shipLayer = [mSpriteLayerManager childAtCategory:CAT_PF_SHIPS];
	SPTween *tween = [SPTween tweenWithTarget:shipLayer time:0.7f];
	[tween animateProperty:@"alpha" targetValue:0.01f];
	[mJuggler addObject:tween];
}

- (void)transitionToTurnOver {
	[mGuvnor removeTarget:mView.playerShip];
}

- (void)onObjectivesRankupCompleted:(BinaryEvent *)event {
#ifndef CHEEKY_LITE_VERSION
    uint rank = self.objectivesManager.rank;
    
    do {
        if (event.value) {
            if (rank == [Potion requiredRankForTwoPotions])
                [self displayEtherealPotionNoticeWithMsgs:[NSArray arrayWithObjects:
                                                           @"Captain, you can now use two potions at once!",
                                                           nil]];
            else if ([Potion isPotionUnlockedAtRank:rank]) {
                uint potionKey = [Potion unlockedPotionKeyForRank:rank];
                NSString *potionName = [Potion nameForKey:potionKey];
                
                if (potionName) {
                    NSString *msg = [NSString stringWithFormat:@"Captain, Vial of %@ is now available!", potionName];
                    [self displayEtherealPotionNoticeWithMsgs:[NSArray arrayWithObjects:
                                                               msg,
                                                               nil]];
                } else {
                    break;
                }
            } else
                break;
            
            return;
        }
    } while (NO);
#endif
    
    if (mCannonsDidOverheat)
        [self beginOverheatedCannonsSequence];
    else
        [self continueEndOfTurn];
}

- (void)continueEndOfTurn {
    if (mState == PfStateDelayedRetry)
        [self continueDelayedRetry];
    else if (mState == PfStateDelayedQuit)
        [self continueDelayedQuit];
    else
        [mView displayGameSummary];
}

- (void)continueDelayedRetry {
    [GCTRL processEndOfTurn];
    [self setState:PfStateMenu];
    [self setState:PfStatePlaying];
}

- (void)continueDelayedQuit {
    [self setState:PfStateMenu];
}

- (void)retry {
    if (mScenePaused == NO || mHasPauseMenu == NO)
		return;
    
    mRetried = YES;
    [self awardPrizes:self.allPrizesBitmap];
    [super retry];
    
    [self setState:PfStateDelayedRetry];
    [self.objectivesManager processEndOfTurn];
}

- (void)quit {
    if (mScenePaused == NO || mHasPauseMenu == NO)
		return;
    
    [self awardPrizes:self.allPrizesBitmap];
    [super quit];
    
    [self setState:PfStateDelayedQuit];
    [self.objectivesManager processEndOfTurn];
}

- (void)resetScene {
	mView.playerShip = nil;
	
	[mJuggler removeAllObjects];
	[mSpamJuggler removeAllObjects];
	
	for (Actor *actor in mActors)
		[actor safeRemove];
	mResettingScene = YES;
}

- (void)resetSceneComplete {
	if (mResettingScene == NO)
		return;
	
    [self destroyTownAi];
	[self destroyActorAi];
	[mView detachEventListeners];
	[self.achievementManager unloadCombatTextWithOwner:mSceneKey];
	[self removePauseButton];
	mLocked = YES;
	for (Prop *prop in mProps)
		[self removeProp:prop];
	mLocked = NO;
	[self removeQueuedProps];
	[mSpriteLayerManager clearAllLayers];
    [mJuggler removeAllObjects];
    [mSpamJuggler removeAllObjects];
	[self.audioPlayer fadeAllSounds];
	
	GameController *gc = GCTRL;
	[gc prepareForNewGame];
    gc.timeKeeper.dayShouldIncrease = !mRaceEnabled;
    mPrizesBitmap = 0;
	
	// Undo fadeOutShipLayer
	SPDisplayObject *shipLayer = [mSpriteLayerManager childAtCategory:CAT_PF_SHIPS];
	shipLayer.alpha = 1.0f;
	
	[self setupTownAi];
	[self setupActorAi];
	[mView release];
    mView = nil;
    [self.objectivesManager setScene:nil];
	mView = [[PlayfieldView alloc] initWithController:self];
	[mView attachEventListeners];
    [self.objectivesManager setScene:self];
	[self.achievementManager loadCombatTextWithCategory:CAT_PF_COMBAT_TEXT bufferSize:30 owner:mSceneKey];
	
	[self addPauseButton];
	[self setGameOver:NO];
    mAmbienceShouldPlay = YES;
	mResettingScene = NO;
	
	NSLog(@"PROP COUNT AFTER VIEW CREATION: %d", [Prop propCount]);
	NSLog(@"ACTOR COUNT AFTER VIEW CREATION: %d", [Actor actorCount]);
}

- (void)setupActorAi {
    if (mActorBrains == nil) {
        mActorBrains = [[ActorAi alloc] initWithController:self];
        mActorBrains.aiKnob = GCTRL.aiKnob;
        [mActorBrains addEventListener:@selector(onAiModifierChanged:) atObject:mGuvnor forType:CUST_EVENT_TYPE_AI_KNOB_VALUE_CHANGED];
        [mActorBrains addEventListener:@selector(onCloseButNoCigarStateReached:) atObject:self forType:CUST_EVENT_TYPE_CLOSE_BUT_NO_CIGAR_STATE_REACHED];
        [mActorBrains addEventListener:@selector(onTreasureFleetSpawned:) atObject:self forType:CUST_EVENT_TYPE_TREASURE_FLEET_SPAWNED];
        [mActorBrains addEventListener:@selector(onTreasureFleetAttacked:) atObject:self forType:CUST_EVENT_TYPE_TREASURE_FLEET_ATTACKED];
        [mActorBrains addEventListener:@selector(onSilverTrainSpawned:) atObject:self forType:CUST_EVENT_TYPE_SILVER_TRAIN_SPAWNED];
        [mActorBrains addEventListener:@selector(onSilverTrainAttacked:) atObject:self forType:CUST_EVENT_TYPE_SILVER_TRAIN_ATTACKED];
    }
    
    [ActorAi setupAiKnob:GCTRL.aiKnob];
    mActorBrains.difficultyFactor = 5.0f;
	[mActorBrains prepareForNewGame];
}

- (void)setupTownAi {
    if (mGuvnor == nil)
        mGuvnor = [[TownAi alloc] initWithController:self];
	mGuvnor.aiModifier = GCTRL.aiKnob->aiModifier;
	[mGuvnor prepareForNewGame];
}

- (void)destroyActorAi {
	if (mActorBrains == nil)
		return;
	[mActorBrains removeEventListener:@selector(onAiModifierChanged:) atObject:mGuvnor forType:CUST_EVENT_TYPE_AI_KNOB_VALUE_CHANGED];
	[mActorBrains removeEventListener:@selector(onCloseButNoCigarStateReached:) atObject:self forType:CUST_EVENT_TYPE_CLOSE_BUT_NO_CIGAR_STATE_REACHED];
	//[mActorBrains removeEventListener:@selector(onAiChanged:) atObject:mView.hud forType:CUST_EVENT_TYPE_AI_STATE_VALUE_CHANGED];
    [mActorBrains removeEventListener:@selector(onTreasureFleetSpawned:) atObject:self forType:CUST_EVENT_TYPE_TREASURE_FLEET_SPAWNED];
    [mActorBrains removeEventListener:@selector(onTreasureFleetAttacked:) atObject:self forType:CUST_EVENT_TYPE_TREASURE_FLEET_ATTACKED];
    [mActorBrains removeEventListener:@selector(onSilverTrainSpawned:) atObject:self forType:CUST_EVENT_TYPE_SILVER_TRAIN_SPAWNED];
    [mActorBrains removeEventListener:@selector(onSilverTrainAttacked:) atObject:self forType:CUST_EVENT_TYPE_SILVER_TRAIN_ATTACKED];
    
	[mActorBrains stopThinking];
	[mActorBrains release];
	mActorBrains = nil;
}

- (void)destroyTownAi {
	if (mGuvnor == nil)
		return;
	[mGuvnor stopThinking];
	[mGuvnor release];
	mGuvnor = nil;
}

- (void)checkinAtlases {
	[super checkinAtlases];
	[self checkinAtlasByName:@"Playfield"];
	[self checkinAtlasByName:@"Gameover"];
}

- (void)destroyScene {
	GameController * gc = GCTRL;
	
	[self detachEventListeners];
	//[Prop printProps];
	
	[mJuggler removeAllObjects];
	[mSpamJuggler removeAllObjects];

	[self destroyActorAi];
	[self destroyTownAi];
	[self detachEventListeners];
	[mView release]; mView = nil;
    [mMenuController destroy];
    [mMenuController release]; mMenuController = nil;
    [self.objectivesManager setScene:nil];
	
	// Ensure all are removed properly
	for (Actor *actor in mActors) {
        [actor checkinPooledResources];
		[actor safeRemove];
    }
    
	[self removeQueuedActors];

    for (Prop *prop in mProps)
        [prop checkinPooledResources];
    
	//for (Actor *actor in mActors)
	//	NSLog(@"Actor remaining: %@", NSStringFromClass([actor class]));
	//for (Prop *prop in mProps)
	//	NSLog(@"Prop remaining: %@", NSStringFromClass([prop class]));
	
	delete mContactListener;
	delete mWorld;
	mWorld = 0;
	
	if ([Actor actorsScene] == self)
		[Actor setActorsScene:nil];
	[self.achievementManager unloadCombatTextWithOwner:mSceneKey];
	[self removeVoodooManagerListeners];
	[mVoodooManager release];
    [self.achievementManager enableSuspendedMode:NO];
	gc.thisTurn.tutorialMode = NO;
    
    [[PersistenceManager PM] removeEventListener:@selector(onCloudAccountLoggedIn:) atObject:self forType:CUST_EVENT_TYPE_CLOUD_LOGGED_IN];
    [[PersistenceManager PM] removeEventListener:@selector(onCloudAccountLoggedOut:) atObject:self forType:CUST_EVENT_TYPE_CLOUD_LOGGED_OUT];
    [[PersistenceManager PM] removeEventListener:@selector(onCloudDataChanged:) atObject:self forType:CUST_EVENT_TYPE_CLOUD_DATA_CHANGED];
    [[PersistenceManager PM] removeEventListener:@selector(onCloudSettingsChanged:) atObject:self forType:CUST_EVENT_TYPE_CLOUD_SETTINGS_CHANGED];
    
	[super destroyScene];
}

- (void)dealloc {
	[super dealloc];
	NSLog(@"Playfield Controller dealloc'ed");
}

@end
