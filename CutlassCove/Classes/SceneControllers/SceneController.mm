//
//  SceneController.m
//  Pirates
//
//  Created by Paul McPhee on 3/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "SceneController.h"
#import "Actor.h"
#import "Prop.h"
#import "FloatingText.h"
#import "PlayerDetails.h"
#import "ShipDetails.h"
#import "NumericValueChangedEvent.h"
#import "ShadowTextField.h"
#import "SPTween_Extension.h"
#import "SPButton_Extension.h"
#import "CodeProfiler.h"
#import "SPRenderTexture_Extension.h"
#import "CCMiscConstants.h"
#import "GameController.h"
#import "Globals.h"

@interface SceneController ()

- (void)playPauseMenuButtonSound;
- (void)positionFlipControlsButton;
- (void)onPauseButtonPressed:(SPEvent *)event;
- (void)onGameResumed:(SPEvent *)event;
- (void)onGameRetry:(SPEvent *)event;
- (void)onGameQuit:(SPEvent *)event;
- (void)onFlipControls:(SPEvent *)event;

@end


@implementation SceneController

@synthesize flipped = mFlipped;
@synthesize isTimeSlowed = mTimeSlowed;
@synthesize scenePaused = mScenePaused;
@synthesize sceneKey = mSceneKey;
@synthesize actors = mActors;
@synthesize props = mProps;
@synthesize juggler = mJuggler;
@synthesize spamJuggler = mSpamJuggler;
@synthesize specialJuggler = mSpecialJuggler;
@synthesize hudJuggler = mHudJuggler;
@synthesize spriteLayerManager = mSpriteLayerManager;
@synthesize viewWidth = mViewWidth;
@synthesize viewHeight = mViewHeight;
@synthesize profiler = mProfiler;
@dynamic touchableDefault,pauseTextureName,audioPlayer,topCategory,helpCategory,pauseCategory,allPrizesBitmap;
@dynamic achievementManager,objectivesManager,ofManager,achievementAtlas,tm,fontKey,helpAtlas,lootModifier,timeSlowedFactor;

- (id)init {
	if (self = [super init]) {
		mHasPauseMenu = NO;
		mScenePaused = NO;
        mFlipped = NO;
        mAmbienceShouldPlay = YES;
        mTimeSlowed = NO;
		mLocked = NO;
		mDestructLock = NO;
		//mName = [NSStringFromClass([self class]) copy];
		mPauseMenu = nil;
		mPauseFrame = nil;
        mFlipControlsButton = nil;
		mPauseJuggler = nil;
		mSpriteLayerManager = nil;
		mHelpAtlas = nil;
		mCacheManagers = nil;
        mScreenshotCache = nil;
		
        mViewWidth = GCTRL.stage.width;
        mViewHeight = GCTRL.stage.height;
	
		// Actors
		mActors = [[NSMutableArray alloc] initWithCapacity:20];
		mAdvActors = [[NSMutableArray alloc] initWithCapacity:10];
		mActorsAddQueue = [[NSMutableArray alloc] initWithCapacity:5];
		mActorsRemoveQueue = [[NSMutableArray alloc] initWithCapacity:5];
		
		// Props
		mProps = [[NSMutableArray alloc] initWithCapacity:40];
		mAdvProps = [[NSMutableArray alloc] initWithCapacity:10];
		mPropsAddQueue = [[NSMutableArray alloc] initWithCapacity:5];
		mPropsRemoveQueue = [[NSMutableArray alloc] initWithCapacity:5];
		mOrientedProps = nil;
        
        // Random Messages
        mRandomMessages = [[NSMutableDictionary alloc] init];
		
		// Jugglers
		mJuggler = [[SPJuggler alloc] init];
		mSpamJuggler = [[SPJuggler alloc] init];
        mHudJuggler = [[SPJuggler alloc] init];
		mSpecialJuggler = [[SPJuggler alloc] init];
        
		// Base Sprite
		mBaseSprite = [[SPSprite alloc] init];
        
#if 0
        // Code Profiler
        NSArray *codeSectionKeys = [NSArray arrayWithObjects:
                                    @"Juggler",
                                    @"Remove",
                                    nil];
        mProfiler = [[CodeProfiler alloc] init];
        
        for (NSString *key in codeSectionKeys)
            [mProfiler addCodeSectionForKey:key ceiling:0.015];
#endif
    }
    return self;
}

- (void)setupController {
	GameController *gc = [GameController GC];
	[self updateOrientation:gc.deviceOrientation];
	[Prop setPropsScene:self];
	[self setupSaveOptions];
}

- (void)setupCaches { }

- (void)setupSaveOptions {
	[self.achievementManager processDelayedSaves];
	self.achievementManager.delaySavingAchievements = NO;
}

- (void)willGainSceneFocus {
	[Prop setPropsScene:self];
}

- (void)willLoseSceneFocus { }

- (void)attachEventListeners {
	// Make sure we're not adding listeners more than once
	[self detachEventListeners];
}

- (void)detachEventListeners { }

- (void)preloadComplete {
	// Signifies that the preloaded scene that succeeds this one has finished loading.
}

- (void)playAmbientSounds { }

- (void)loadSceneState:(GameCoder *)coder { }

- (void)saveSceneState:(GameCoder *)coder { }

- (void)screenConnected { }

- (void)screenDisconnected { }

- (void)flip:(BOOL)enable {
    mFlipped = enable;
    [self positionFlipControlsButton];
}

- (void)addToStageAtIndex:(int)index {
	[GCTRL.stage addChild:mBaseSprite atIndex:index];
}

- (BOOL)touchableDefault {
	return YES;
}

- (float)fps {
	return GCTRL.fps;
}

- (SPJuggler *)juggler {
	return (mDestructLock == YES) ? nil : mJuggler;
}

- (SPJuggler *)spamJuggler {
	return (mDestructLock == YES) ? nil : mSpamJuggler;
}

- (SPJuggler *)hudJuggler {
    return (mDestructLock == YES) ? nil : mHudJuggler;
}

- (double)timeSlowedFactor {
    return 0.2;
}

- (SpriteLayerManager *)spriteLayerManager {
	return (mDestructLock == YES) ? nil : mSpriteLayerManager;
}

- (AudioPlayer *)audioPlayer {
	return [GCTRL audioPlayerByName:mSceneKey];
}

- (NSString *)pauseTextureName {
	return @"pause";
}

- (NSString *)fontKey {
	return [NSString stringWithFormat:@"%@%@", BITMAP_FONT_NAME, mSceneKey];
}

- (NSString *)fontKeyForPrefix:(NSString *)prefix {
	return [NSString stringWithFormat:@"%@%@", prefix, mSceneKey];
}

- (BOOL)isInVisibleBounds:(float)x y:(float)y {
    SPRectangle *bounds = [SPRectangle rectangleWithX:0 y:0 width:self.viewWidth height:self.viewHeight - 35];
    return [bounds containsX:x y:y];
}

- (int)objectivesCategoryForViewType:(ObjectivesViewType)type {
    return 0;
}

- (Idol *)idolForKey:(uint)key {
	return [GCTRL.gameStats idolForKey:key];
}

- (Idol *)equippedIdolForKey:(uint)key {
	return [GCTRL.gameStats equippedIdolForKey:key];
}

- (BOOL)isEquippedIdolMaxedForKey:(uint)key {
	Idol *idol = [self equippedIdolForKey:key];
	return (idol && idol.isMaxRank);
}

- (Potion *)potionForKey:(uint)key {
    return [GCTRL.gameStats potionForKey:key];
}

- (BOOL)isPotionActiveForKey:(uint)key {
    Potion *potion = [self potionForKey:key];
    return (potion && potion.isActive);
}

- (NSArray *)activePotions {
    return [GameStats activatedPotionsFromPotions:GCTRL.gameStats.potions];
}

- (void)activatePotion:(BOOL)activate forKey:(uint)key {
    [GCTRL.gameStats activatePotion:activate forKey:key];
}

- (SPTexture *)textureByName:(NSString *)name {
	return [self textureByName:name cacheGroup:nil];
}

- (SPTexture *)textureByName:(NSString *)name cacheGroup:(NSString *)cacheGroup {
	return [self.tm textureByName:name cacheGroup:cacheGroup category:self.sceneKey];
}

- (SPTexture *)textureByName:(NSString *)name atlasName:(NSString *)atlasName {
	return [self textureByName:name atlasName:atlasName cacheGroup:nil];
}

- (SPTexture *)textureByName:(NSString *)name atlasName:(NSString *)atlasName cacheGroup:(NSString *)cacheGroup {
	return [self.tm textureByName:name atlasName:atlasName cacheGroup:cacheGroup category:self.sceneKey];
}

- (SPTexture *)cachedTextureByName:(NSString *)name {
	return [self.tm cachedTextureByName:name];
}

- (NSArray *)texturesStartingWith:(NSString *)name {
	return [self texturesStartingWith:name cacheGroup:nil];
}

- (NSArray *)texturesStartingWith:(NSString *)name cacheGroup:(NSString *)cacheGroup {
	return [self.tm texturesStartingWith:name cacheGroup:cacheGroup category:self.sceneKey];
}

- (NSArray *)texturesStartingWith:(NSString *)name atlasName:(NSString *)atlasName cacheGroup:(NSString *)cacheGroup {
	return [self.tm texturesStartingWith:name atlasName:atlasName cacheGroup:cacheGroup category:self.sceneKey];
}

- (void)checkinAtlasByName:(NSString *)name {
	[self.tm checkinAtlasByName:name category:self.sceneKey];
}

- (CacheManager *)cacheManagerByName:(NSString *)name {
	return [mCacheManagers objectForKey:name];
}

- (AchievementManager *)achievementManager {
	return GCTRL.achievementManager;
}

- (ObjectivesManager *)objectivesManager {
	return GCTRL.objectivesManager;
}

- (CCOFManager *)ofManager {
    return GCTRL.ofManager;
}

- (TextureManager *)tm {
	return GCTRL.textureManager;
}

- (int)topCategory {
	return 0;
}

- (int)helpCategory {
	return 0;
}

- (int)pauseCategory {
	return self.topCategory;
}

- (uint)allPrizesBitmap {
    return 0;
}

- (float)lootModifier {
	int64_t infamy = GCTRL.thisTurn.infamy;
	double infamyThreshold = 500000.0;
	float modifier = 1 + infamy / (infamyThreshold + infamy / 3.0f);
	//NSLog(@"Loot modifier: %f", modifier);
	return modifier;
}

- (SPTextureAtlas *)achievementAtlas {
	return GCTRL.achievementManager.atlas;
}

- (SPTextureAtlas *)helpAtlas {
	if (mHelpAtlas == nil) {
		[self.tm checkoutAtlasByName:@"Help" path:@"help-atlas.xml" category:self.sceneKey];
		mHelpAtlas = [[self.tm atlasByName:@"Help" category:self.sceneKey] retain];
	}
	return mHelpAtlas;
}

- (void)destroyHelpAtlas {
	if (mHelpAtlas != nil) {
		[mHelpAtlas release];
		mHelpAtlas = nil;
		[self checkinAtlasByName:@"Help"];
	}
}

- (void)updateOrientation:(UIDeviceOrientation)orientation {
    return;
    
#if 0
    GameController *gc = GCTRL;
    
    if (gc.isViewLandscape) {
        // Landscape
        mBaseSprite.rotation = 0;
        mBaseSprite.x = 0;
        mBaseSprite.y = 0;
        
        /*
        if (orientation == UIDeviceOrientationLandscapeLeft) {
            mBaseSprite.rotation = 0;
            mBaseSprite.x = 0;
            mBaseSprite.y = 0;
        } else if (orientation == UIDeviceOrientationLandscapeRight) {
            mBaseSprite.rotation = SP_D2R(180);
            mBaseSprite.x = self.viewWidth;
            mBaseSprite.y = self.viewHeight;
        }
         */
    } else {
        // Portrait
        mBaseSprite.rotation = 0;
        mBaseSprite.x = 0;
        mBaseSprite.y = 0;
        
        /*
        if (orientation == UIDeviceOrientationLandscapeLeft) {
            mBaseSprite.rotation = SP_D2R(90);
            mBaseSprite.x = self.viewHeight;
            mBaseSprite.y = 0;
        } else if (orientation == UIDeviceOrientationLandscapeRight) {
            mBaseSprite.rotation = SP_D2R(-90);
            mBaseSprite.x = 0;
            mBaseSprite.y = self.viewHeight;
        }
         */
    }
    
    for (Prop *prop in mOrientedProps)
		[prop updateOrientation:orientation];
#endif
}

- (void)registerOrientationUpdatesForProp:(Prop *)prop {
	if (mOrientedProps == nil)
		mOrientedProps = [[NSMutableSet alloc] init];
	[mOrientedProps addObject:prop];
	[prop updateOrientation:GCTRL.deviceOrientation];
}

- (void)unregisterOrientationUpdatesForProp:(Prop *)prop {
	[mOrientedProps removeObject:prop];
}

- (void)removeCachedResources { }

- (void)awardPrizes:(uint)prizes { }

- (void)printProfilerReport {
    if (mProfiler.numFrames == 900) {
        NSArray *profileReports = [mProfiler reportAll];
        
        for (NSString *report in profileReports) {
            NSLog(@"\n+++++++++++++++++++++++++\n");
            NSLog(@"%@", report);
            NSLog(@"\n=========================\n");
        }
        
        [mProfiler resetProfilers];
        [mProfiler resetFrameCount];
    }
}

- (void)hideHintByName:(NSString *)name { }

- (void)enableSlowedTime:(BOOL)enable {
    mTimeSlowed = enable;
}

- (void)requestTargetForPursuer:(NSObject *)pursuer { }

- (void)prisonerOverboard:(Prisoner *)prisoner ship:(ShipActor *)ship { }

- (void)advanceTime:(double)time {
    double slowedTime = (mTimeSlowed) ? time * self.timeSlowedFactor : time;
    
	if (mScenePaused == YES) {
		[mPauseJuggler advanceTime:time];
        [mSpecialJuggler advanceTime:time];
	} else {
		mLocked = YES; // LOCKED
        
        if (mAmbienceShouldPlay) {
            mAmbienceShouldPlay = NO;
            [self playAmbientSounds];
        }
        
		for (Actor *actor in mAdvActors) {
			if (actor.markedForRemoval == NO)
				[actor advanceTime:slowedTime];
		}
		
		for (Prop *prop in mAdvProps) {
			if (prop.markedForRemoval == NO) {
                if (prop.slowable)
                    [prop advanceTime:slowedTime];
                else 
                    [prop advanceTime:time];
            }
		}
        
//[mProfiler startProfilerForKey:@"Juggler"];
		[mJuggler advanceTime:slowedTime];
//[mProfiler stopProfilerForKey:@"Juggler"];
/*        
        if ([mProfiler didProfilerBreachForKey:@"Juggler"]) {
            NSLog(@"########### Juggler Log ##############");
            [mJuggler logContents];
        }
*/        
		[mSpamJuggler advanceTime:slowedTime];
        [mHudJuggler advanceTime:time];
        [mSpecialJuggler advanceTime:time];
        
		mLocked = NO; // UNLOCKED
		
		[self removeQueuedActors];
		[self addQueuedActors];
		[self removeQueuedProps];
		[self addQueuedProps];
        
        //[mProfiler markEndOfFrame];
        //[self printProfilerReport];
	}
}

- (Actor *)actorById:(int)actorId {
	Actor *actor = nil;
	
	if (actorId != 0) {
		for (Actor *a in mActors) {
			if (a.actorId == actorId) {
				actor = a;
				break;
			}
		}
	}
	
	return actor;
}

- (void)addActor:(Actor *)actor {
	if (mDestructLock || actor == nil)
		return;
	if (mLocked == YES) {
		[mActorsAddQueue addObject:actor];
	} else {
		//assert([mActors containsObject:actor] == NO && [mAdvActors containsObject:actor] == NO);
		[mActors addObject:actor];
		
		if (actor.advanceable)
			[mAdvActors addObject:actor];
		[mSpriteLayerManager addChild:actor withCategory:actor.category];
        
        if (self.flipped)
            [actor flip:YES];
		//NSLog(@"Actor count: %d", mActors.count);
	}
}

- (void)removeActor:(Actor *)actor {
	if (mDestructLock || actor == nil)
		return;
	//NSLog(@"Safe removing: %@",NSStringFromClass([actor class]));
	[actor safeRemove];
	//NSLog(@"Done");
}

- (void)addQueuedActors {
	assert(mLocked == NO);
	
	if (mActorsAddQueue.count) {
		for (Actor *actor in mActorsAddQueue)
			[self addActor:actor];
		[mActorsAddQueue removeAllObjects];
	}
}

- (void)removeQueuedActors {
	mLocked = YES; // LOCKED
	
//[mProfiler startProfilerForKey:@"Remove"];
    
    for (Actor *actor in mActors) {
        if (actor.markedForRemoval == NO)
            [actor respondToPhysicalInputs];
        
        // Store for later removal in case a future actor's
        // respondToPhysicalInputs refers to this actor. Do
        // NOT "else if" this conditional with the above as
        // respondToPhysicalInputs can influence this test.
        if (actor.markedForRemoval == YES)
            [mActorsRemoveQueue addObject:actor];
    }

//[mProfiler stopProfilerForKey:@"Remove"];
    
	mLocked = NO; // UNLOCKED
    
	for (Actor *actor in mActorsRemoveQueue) {
        [[actor retain] autorelease];
		//[mJuggler removeTweensWithTarget:actor];
		//[mSpamJuggler removeTweensWithTarget:actor];
		[actor destroyActorBody];
		[mSpriteLayerManager removeChild:actor withCategory:actor.category];
		
		if (actor.advanceable)
			[mAdvActors removeObject:actor];
		[mActors removeObject:actor];
	}
	[mActorsRemoveQueue removeAllObjects];
}

- (void)addProp:(Prop *)prop {
	if (mDestructLock || prop == nil)
		return;
	if (mLocked == YES) {
		[mPropsAddQueue addObject:prop];
	} else {
		[mProps addObject:prop];
		
		if (prop.advanceable)
			[mAdvProps addObject:prop];
		[mSpriteLayerManager addChild:prop withCategory:prop.category];
        
        if (self.flipped)
            [prop flip:YES];
	}
}

- (void)removeProp:(Prop *)prop {
	if (mDestructLock || prop == nil)
		return;
	if (mLocked == YES) {
		[mPropsRemoveQueue addObject:prop];
	} else {
		[[prop retain] autorelease];
		//[mJuggler removeTweensWithTarget:prop];
		//[mSpamJuggler removeTweensWithTarget:prop];
        //[mHudJuggler removeTweensWithTarget:prop];
		[mSpriteLayerManager removeChild:prop withCategory:prop.category];
		
		if (prop.advanceable)
			[mAdvProps removeObject:prop];
		[mProps removeObject:prop];
		//[mPropsAddQueue removeObject:prop];
	}
}

- (void)addQueuedProps {
	assert(mLocked == NO);
	
	if (mPropsAddQueue.count) {
		for (Prop *prop in mPropsAddQueue)
			[self addProp:prop];
		[mPropsAddQueue removeAllObjects];
	}
}

- (void)removeQueuedProps {	
	assert(mLocked == NO);
	
	if (mPropsRemoveQueue.count) {
		for (Prop *prop in mPropsRemoveQueue)
			[self removeProp:prop];
		[mPropsRemoveQueue removeAllObjects];
	}
}

- (BOOL)doesRandomMessageExistForKey:(NSString *)key {
    return ([mRandomMessages objectForKey:key] != nil);
}

- (void)addRandomMessageQueue:(NSMutableArray *)queue forKey:(NSString *)key {
    if ([queue isKindOfClass:[NSMutableArray class]] == NO)
        return;
    [mRandomMessages setObject:queue forKey:key];
    
    // Randomize
    int count = queue.count;
    
    for (int i = 0; i < count; ++i) {
        int randIndex = RANDOM_INT(0, count-1);
        NSString *str = (NSString *)[[[queue objectAtIndex:randIndex] retain] autorelease];
        [queue removeObjectAtIndex:randIndex];
        [queue insertObject:str atIndex:0];
    }
}

- (NSString *)randomMessageForKey:(NSString *)key {
    if (key == nil)
        return nil;
    NSString *msg = nil;
    NSMutableArray *queue = (NSMutableArray *)[mRandomMessages objectForKey:key];
    
    if (queue && queue.count > 0) {
        msg = (NSString *)[[[queue objectAtIndex:0] retain] autorelease];
        [queue removeObjectAtIndex:0];
        
        [queue insertObject:msg atIndex:queue.count];
        //int lower = MIN(queue.count,2);
        //[queue insertObject:msg atIndex:RANDOM_INT(lower, queue.count)];
    }
    
    return msg;
}

- (void)addPauseButton {
	if (mHasPauseMenu == YES)
		return;
	SPTexture *pauseTexture = [self textureByName:self.pauseTextureName];
	mPauseProp = [[Prop alloc] initWithCategory:self.pauseCategory];
	mPauseProp.touchable = YES;
	mPauseButton = [[SPButton buttonWithUpState:pauseTexture] retain];
	[mPauseButton addEventListener:@selector(onPauseButtonPressed:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
	[mPauseProp addChild:mPauseButton];
	[self addProp:mPauseProp];
	mPauseProp.x = self.viewWidth - mPauseButton.width;
	mPauseProp.y = 0.0f;
	mHasPauseMenu = YES;
}

- (void)removePauseButton {
	if (mHasPauseMenu == NO)
		return;
	[self removeProp:mPauseProp];
	[mPauseProp release];
	mPauseProp = nil;
	mHasPauseMenu = NO;
}

- (void)showPauseButton:(BOOL)value {
	if (value) {
		if (mHasPauseMenu == NO)
			[self addPauseButton];
		else
			mPauseProp.visible = YES;
	} else {
		mPauseProp.visible = NO;
	}
}

- (void)createPauseMenu {
	if (mPauseMenu != nil)
		return;
    mPauseMenu = [[Prop alloc] initWithCategory:self.topCategory];
	mPauseMenu.touchable = YES;
	SPQuad *touchAbsorber = [SPQuad quadWithWidth:self.viewWidth height:self.viewHeight];
	touchAbsorber.alpha = 0.0f;
	[mPauseMenu addChild:touchAbsorber];
    
[RESM pushItemOffsetWithAlignment:RACenter];
    mPauseFrame = [[SPSprite alloc] init];
    mPauseFrame.rx = 0; mPauseFrame.ry = 0;
    [mPauseMenu addChild:mPauseFrame];
[RESM popOffset];
    
    mResumeButton = [[SPButton buttonWithUpState:[self textureByName:@"pause-resume-button"]] retain];
    mResumeButton.x = 125;
    mResumeButton.y = 212;
    [mResumeButton addEventListener:@selector(onGameResumed:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    [mPauseFrame addChild:mResumeButton];
    
    mRetryButton = [[SPButton buttonWithUpState:[self textureByName:@"pause-retry-button"]] retain];
	mRetryButton.x = 205;
	mRetryButton.y = 212;
	[mRetryButton addEventListener:@selector(onGameRetry:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    [mPauseFrame addChild:mRetryButton];
    
    mQuitButton = [[SPButton buttonWithUpState:[self textureByName:@"pause-quit-button"]] retain];
	mQuitButton.x = 285;
	mQuitButton.y = 212;
	[mQuitButton addEventListener:@selector(onGameQuit:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    [mPauseFrame addChild:mQuitButton];
    
    mFlipControlsButton = [[SPButton alloc] initWithUpState:[self textureByName:@"flip-controls"]];
    [mFlipControlsButton addEventListener:@selector(onFlipControls:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    [mPauseFrame addChild:mFlipControlsButton];
    [self positionFlipControlsButton];
}

- (void)positionFlipControlsButton {
    if (mFlipControlsButton == nil)
        return;
[RESM pushItemOffsetWithAlignment:RACenterLeft]; // Combines with parent's RACenter to make a RALowerCenter
    if (self.flipped) {
        mFlipControlsButton.rx = 128;
        mFlipControlsButton.ry = 288;
    } else {
        mFlipControlsButton.rx = 184;
        mFlipControlsButton.ry = 288;
    }
[RESM popOffset];
}

- (void)overridingPause {
    [self dismissPauseMenu];
}

- (void)displayPauseMenu {
	if (mScenePaused == YES)
		return;
	mScenePaused = YES;
	GCTRL.paused = YES;
	[self sceneWillPause];
	[self createPauseMenu];
    [self.objectivesManager enableCurrentPanelButtons:NO];
    [self.objectivesManager showCurrentPanel];
    mPauseFrame.touchable = YES;
    [self addProp:mPauseMenu];
}

- (void)dismissPauseMenu {
    [self.objectivesManager hideCurrentPanel];
    [self.objectivesManager enableCurrentPanelButtons:YES];
    [self removeProp:mPauseMenu];
    mPauseFrame.touchable = NO;
	mScenePaused = NO;
	GCTRL.paused = NO;
}

- (void)sceneWillPause { }

- (void)resume {
    if (mScenePaused == NO || mHasPauseMenu == NO)
		return;
    GCTRL.gameWindowDidLoseFocus = NO;  // If this hasn't been unset, then a notification was not sent and we need to unset it here.
	[self playPauseMenuButtonSound];
	[self dismissPauseMenu];
}

- (void)retry {
    if (mScenePaused == NO || mHasPauseMenu == NO)
		return;
    GCTRL.gameWindowDidLoseFocus = NO;  // If this hasn't been unset, then a notification was not sent and we need to unset it here.
	[self playPauseMenuButtonSound];
    [self dismissPauseMenu];
}

- (void)quit {
    if (mScenePaused == NO || mHasPauseMenu == NO)
		return;
    
    GCTRL.gameWindowDidLoseFocus = NO;  // If this hasn't been unset, then a notification was not sent and we need to unset it here.
	[self playPauseMenuButtonSound];
    [self dismissPauseMenu];
}

- (void)playPauseMenuButtonSound {
	[self.audioPlayer playSoundWithKey:@"Button"];
}

- (UIImage *)screenshot {
    if (mScreenshotCache)
        return mScreenshotCache;
    
	float x = mBaseSprite.x, y = mBaseSprite.y, rotation = mBaseSprite.rotation;
	mBaseSprite.x = mBaseSprite.y = mBaseSprite.rotation = 0;
	
	SPRenderTexture *texture = [SPRenderTexture textureWithWidth:self.viewWidth height:self.viewHeight];
	[texture drawObject:mBaseSprite];
	
	mBaseSprite.x = x;
	mBaseSprite.y = y;
	mBaseSprite.rotation = rotation;
	
	mScreenshotCache = [[texture renderToImage] retain];
    return mScreenshotCache;
}

- (void)clearScreenshotCache {
    [mScreenshotCache release]; mScreenshotCache = nil;
}

- (void)onPauseButtonPressed:(SPEvent *)event {
	if (mHasPauseMenu == NO)
		return;
	[self displayPauseMenu];
}

- (void)onGameResumed:(SPEvent *)event {
	[self resume];
}

- (void)onGameRetry:(SPEvent *)event {
	[self retry];
}

- (void)onGameQuit:(SPEvent *)event {
	[self quit];
}

- (void)onFlipControls:(SPEvent *)event {
    [self flip:!self.flipped];
    [self playPauseMenuButtonSound];
}

- (void)checkinAtlases {
	[self checkinAtlasByName:@"Help"];
	[self.tm emptyTextureCache];
}

- (void)destroyScene {
	GameController *gc = [GameController GC];
	
	[mPauseButton removeEventListener:@selector(onPauseButtonPressed:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
	[mResumeButton removeEventListener:@selector(onGameResumed:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
	[mRetryButton removeEventListener:@selector(onGameRetry:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
	[mQuitButton removeEventListener:@selector(onGameQuit:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    [mFlipControlsButton removeEventListener:@selector(onFlipControls:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];

	[mPauseJuggler removeTweensWithTarget:mPauseFrame];
	mDestructLock = YES;
	[gc markAudioPlayerForDestructionByName:mSceneKey];
	[mPauseButton release]; mPauseButton = nil;
	[mResumeButton release]; mResumeButton = nil;
	[mRetryButton release]; mRetryButton = nil;
	[mQuitButton release]; mQuitButton = nil;
    [mFlipControlsButton release]; mFlipControlsButton = nil;
	[mPauseProp release]; mPauseProp = nil;
	[mPauseFrame release]; mPauseFrame = nil;
	[mPauseMenu release]; mPauseMenu = nil;
	
	[mPauseJuggler removeAllObjects];
	[mJuggler removeAllObjects];
	[mSpamJuggler removeAllObjects];
	
	// Actors
	[mActors release]; mActors = nil;
	[mAdvActors release]; mAdvActors = nil;
	[mActorsAddQueue release]; mActorsAddQueue = nil;
	[mActorsRemoveQueue release]; mActorsRemoveQueue = nil;
	
	// Props
	[mProps release]; mProps = nil;
	[mAdvProps release]; mAdvProps = nil;
	[mPropsAddQueue release]; mPropsAddQueue = nil;
	[mPropsRemoveQueue release]; mPropsRemoveQueue = nil;
	[mOrientedProps release]; mOrientedProps = nil;
	
	[mPauseJuggler removeAllObjects];
	[mPauseJuggler release]; mPauseJuggler = nil;
	[mJuggler removeAllObjects];
	[mJuggler release]; mJuggler = nil;
	[mSpamJuggler removeAllObjects];
	[mSpamJuggler release]; mSpamJuggler = nil;
    [mHudJuggler removeAllObjects];
	[mHudJuggler release]; mHudJuggler = nil;
    [mSpecialJuggler removeAllObjects];
	[mSpecialJuggler release]; mSpecialJuggler = nil;
	
	[mBaseSprite removeFromParent];
	[mBaseSprite release]; mBaseSprite = nil;
	[mSpriteLayerManager clearAll];
	[mSpriteLayerManager release]; mSpriteLayerManager = nil;
	[mHelpAtlas release]; mHelpAtlas = nil;
    
    // Messages
    [mRandomMessages release]; mRandomMessages = nil;
	
	// Cache Managers
	//for (NSString *key in mCacheManagers) {
	//	CacheManager *cm = (CacheManager *)[mCacheManagers objectForKey:key];
	//	[cm drainResourcePool];
	//}
	
	[mCacheManagers release]; mCacheManagers = nil;

	//[mName release]; mName = nil;
	[Prop relinquishPropScene:self];
	mDestructLock = NO;
}

- (void)dealloc {
    [self clearScreenshotCache];
    [mProfiler release]; mProfiler = nil;
	[mSceneKey release]; mSceneKey = nil;
	[super dealloc];
	
	NSLog(@"Scene Controller dealloc'ed");
}

@end
