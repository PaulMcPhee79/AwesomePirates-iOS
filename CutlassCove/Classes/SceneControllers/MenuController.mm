//
//  MenuController.m
//  CutlassCove
//
//  Created by Paul McPhee on 21/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MenuController.h"
#import "MenuView.h"
#import "MenuButton.h"
#import "BookletSubview.h"
#import "SwitchFlippedEvent.h"
#import "MultiPurposeEvent.h"
#import "AchievementsViewController.h"
#import "CaptainProfileViewController.h"
#import "PlayfieldController.h"
#import <Twitter/Twitter.h>
#import <Social/Social.h>
#import <GameKit/GameKit.h>
#import "ProfileManager.h"
#import "GameSettings.h"
#import "PlayerDetails.h"
#import "CCiTunesManager.h"
#import "PersistenceManager.h"
#import "GameController.h"
#import "Globals.h"

const float kMenuTransitionDuration = 0.5f;

#define MENU_AMBIENCE @"MenuAmbience"
#define MENU_AMBIENCE_VOLUME 1.0f

// Alert States
#define kAlertStateNull 0x0
#define kAlertStateLoginUnavailable 0x1
#define kAlertStateLoginIncomplete 0x2
#define kAlertStateLoginUnsuccessful 0x3
#define kAlertStateOffline 0x4
#define kAlertStateDataIntegrity 0x5

// Query States
#define kQueryStateNull 0x0
#define kQueryStateResetTutorialPrompts 0x1
#define kQueryStateResetProgress 0x2
#define kQueryStateRestoreProgress 0x3
#define kQueryStateLaunchTwitter 0x4
#define kQueryStateLaunchFacebook 0x5
#define kQueryStateSyncAchievements 0x6
#define kQueryStateGetTheFullVersion 0x7

// UIAlertView tags for delegate switching
#define kCCUIAlertViewTagGCSignIn 0x1000
#define kCCUIAlertViewTagOFChallenge 0x1001
#define kCCUIAlertViewTagOFCloudBackup 0x1002
#define kCCUIAlertViewTagOFCloudRestore 0x1003
#define kCCUIAlertViewTagRateTheGame 0x1004
#define kCCUIAlertViewTagSyncAchievements 0x1005
#define kCCUIAlertViewTagApproveCloud 0x1006

// UIActivityIndicator tags
#define kCCUIActivityIndicatorViewTagOFChallenge 0x2000
#define kCCUIActivityIndicatorViewTagOFCloud 0x2001
#define kCCUIActivityIndicatorViewTagSyncAchievements 0x2002

@interface MenuController ()

@property (nonatomic,retain) UIAlertView *CCOFCloudAlertView;
@property (nonatomic,retain) UIAlertView *CCOFChallengeAlertView;
@property (nonatomic,retain) UIAlertView *CCSyncAchievementsAlertView;
@property (nonatomic,retain) UIAlertView *CCCloudApprovalView;


- (float)ambienceVolume;
- (void)playAmbientSounds;
- (void)stopAmbientSoundsOverTime:(float)duration;

- (void)viewDidTransitionIn:(SPEvent *)event;
- (void)viewDidTransitionOut:(SPEvent *)event;
- (void)viewWasTouchedToPlay:(SPEvent *)event;

- (void)notifyUiViewHasFocus;
- (void)notifySPViewHasFocus;

- (void)onButtonTriggered:(SPEvent *)event;

- (void)objectives:(MenuButton *)sender;
- (void)achievements:(MenuButton *)sender;
- (void)info:(MenuButton *)sender;
- (void)options:(MenuButton *)sender;
- (void)credits:(MenuButton *)sender;
- (void)potions:(MenuButton *)sender;
- (void)onSfxSwitchFlipped:(SwitchFlippedEvent *)event;
- (void)onMusicSwitchFlipped:(SwitchFlippedEvent *)event;
- (void)prevBookletPage:(MenuButton *)sender;
- (void)nextBookletPage:(MenuButton *)sender;
- (void)resetTutorialPrompts:(MenuButton *)sender;
- (void)resetGameProgress:(MenuButton *)sender;
- (void)restoreProgress:(MenuButton *)sender;
- (void)statsLogInfo:(MenuButton *)sender;
- (void)gameConceptsInfo:(MenuButton *)sender;
- (void)spellsMunitionsInfo:(MenuButton *)sender;
- (void)followUsTwitter:(MenuButton *)sender;
- (void)likeUsFacebook:(MenuButton *)sender;
- (void)syncAchievements:(MenuButton *)sender;
- (void)liteGetTheFullVersion:(MenuButton *)sender;
- (void)liteBuyNow:(MenuButton *)sender;
- (void)onFlipControlsPressed:(MenuButton *)sender;
- (void)selectPotion:(MenuButton *)sender;
- (void)yesRateGame:(MenuButton *)sender;
- (void)noRateGame:(MenuButton *)sender;

- (void)openReviewURL;

- (void)achievementsSyncSucceeded;
- (void)achievementsSyncFailed;
- (void)onAchievementSyncStepComplete:(MultiPurposeEvent *)event;
- (void)queryCloudApproval;

- (void)closeSubview:(MenuButton *)sender;
- (void)closeObjectives:(MenuButton *)sender;
- (void)closeAchievements:(MenuButton *)sender;
- (void)closeInfo:(MenuButton *)sender;
- (void)closeStats:(MenuButton *)sender;
- (void)closeGameConcepts:(MenuButton *)sender;
- (void)closeSpellsAndMunitions:(MenuButton *)sender;
- (void)closeOptions:(MenuButton *)sender;
- (void)closePotions:(MenuButton *)sender;
- (void)closeCredits:(MenuButton *)sender;
- (void)closeLite:(MenuButton *)sender;

- (void)resetTutorialPrompts;
- (void)resetObjectives;
- (void)resetAchievements;

- (void)launchTwitterAppWithUsername:(NSString *)username;
- (void)launchFacebookWithPagename:(NSString *)pagename;
- (void)launchGameCenter:(MenuButton *)sender;
- (void)playerAuthenticationWillChange:(SPEvent *)event;
- (void)gameCenterLoginChanged:(MultiPurposeEvent *)event;

- (void)setAlertState:(int)state;
- (void)setQueryState:(int)state;
- (void)okAlert:(MenuButton *)sender;
- (void)yesQuery:(MenuButton *)sender;
- (void)noQuery:(MenuButton *)sender;
- (void)dismissOFCloudAlertViewAnimated:(BOOL)animated;
- (void)dismissOFChallengeAlertView;
- (void)dismissSyncAchievementsAlertViewAnimated:(BOOL)animated;
- (void)promptUserForRating;

- (void)onSpeedboatLaunchRequested:(SPEvent *)event;
- (void)showAchievementsView;
- (void)destroyAchievementsViewController;
- (void)showCaptainProfileView;
- (void)destroyCaptainProfileViewController;

@end

@implementation MenuController

@synthesize CCOFChallengeAlertView = mCCOFChallengeAlertView;
@synthesize CCOFCloudAlertView = mCCOFCloudAlertView;
@synthesize CCSyncAchievementsAlertView = mCCSyncAchievementsAlertView;
@synthesize CCCloudApprovalView = mCCCloudApprovalView;

- (id)initWithScene:(PlayfieldController *)scene {
    if (self = [super init]) {
        mScene = scene;
        
        mDataIntegrityChecked = NO;
        mShouldSaveProgress = NO;
        mOfflineSavedRequired = NO;
        mAchievementsSyncInProgress = 0;
        mState = MenuStateIn;
        
        mDidInitiateGameCenterAuthentication = NO;
        mAlertState = kAlertStateNull;
        mQueryState = kQueryStateNull;
    }
    return self;
}

- (void)destroy {
	[self detachEventListeners];
	[self destroyAchievementsViewController];
	[self destroyCaptainProfileViewController];
	[mScene.juggler removeTweensWithTarget:mView];
	[mView release]; mView = nil;
    [self dismissOFCloudAlertViewAnimated:NO];
    [self dismissOFChallengeAlertView];
    [self dismissSyncAchievementsAlertViewAnimated:NO];
}

- (void)dealloc {
    [self destroy];
    mScene = nil;
	[super dealloc];
	NSLog(@"MenuController dealloc'ed");
}

- (void)setupController {
    if (mView)
        return;
    mView = [[MenuView alloc] initWithCategory:CAT_PF_HUD controller:self];
    [mView pushSubviewForKey:@"Menu"];
    [self refreshHiScoreView];
    [mScene addProp:mView];
}

- (void)attachEventListeners {
    [mScene.ofManager addEventListener:@selector(gameCenterLoginChanged:) atObject:self forType:CUST_EVENT_TYPE_GC_USER_LOGIN_CHANGED];
    [mScene.ofManager addEventListener:@selector(playerAuthenticationWillChange:) atObject:self forType:CUST_EVENT_TYPE_GC_PLAYER_AUTH_WILL_CHANGE];
    
    [mScene.achievementManager addEventListener:@selector(onAchievementSyncStepComplete:) atObject:self forType:CUST_EVENT_TYPE_ACH_SYNC_COMPLETE];
    
    [mView addEventListener:@selector(viewDidTransitionIn:) atObject:self forType:CUST_EVENT_TYPE_MENU_VIEW_DID_TRANSITION_IN];
    [mView addEventListener:@selector(viewDidTransitionOut:) atObject:self forType:CUST_EVENT_TYPE_MENU_VIEW_DID_TRANSITION_OUT];
    [mView addEventListener:@selector(viewWasTouchedToPlay:) atObject:self forType:CUST_EVENT_TYPE_MENU_VIEW_WAS_TOUCHED_TO_PLAY];
    
	[mView attachEventListeners];
}

- (void)detachEventListeners {
    [mScene.ofManager removeEventListener:@selector(gameCenterLoginChanged:) atObject:self forType:CUST_EVENT_TYPE_GC_USER_LOGIN_CHANGED];
    [mScene.ofManager removeEventListener:@selector(playerAuthenticationWillChange:) atObject:self forType:CUST_EVENT_TYPE_GC_PLAYER_AUTH_WILL_CHANGE];
    
    [mScene.achievementManager removeEventListener:@selector(onAchievementSyncStepComplete:) atObject:self forType:CUST_EVENT_TYPE_ACH_SYNC_COMPLETE];
    
    [mView removeEventListener:@selector(viewDidTransitionIn:) atObject:self forType:CUST_EVENT_TYPE_MENU_VIEW_DID_TRANSITION_IN];
    [mView removeEventListener:@selector(viewDidTransitionOut:) atObject:self forType:CUST_EVENT_TYPE_MENU_VIEW_DID_TRANSITION_OUT];
    [mView removeEventListener:@selector(viewWasTouchedToPlay:) atObject:self forType:CUST_EVENT_TYPE_MENU_VIEW_WAS_TOUCHED_TO_PLAY];
    
	[mView detachEventListeners];
}

- (BOOL)reassignScene:(PlayfieldController *)scene {
    BOOL reassignmentSuccessful = (mView == nil);

    if (reassignmentSuccessful)
        mScene = scene;
    else
        NSLog(@"MenuController: Cannot reassign scene after setup is complete.");
    return reassignmentSuccessful;
}

- (void)setState:(MenuState)state {
    if (state == mState)
        return;
    
    MenuState previousState = mState;
    
    // Clean up previous state
    switch (previousState) {
        case MenuStateLaunching:
//#ifndef CHEEKY_LITE_VERSION
//        {
//            GameController *gc = GCTRL;
//            
//            if (gc.gameSettings.isNewVersion && [gc.gameSettings settingForKey:GAME_SETTINGS_KEY_PLAYED_BEFORE] == YES) {
//                if ([mView bookletSubviewForKey:@"UpdatePreview"] != nil)
//                    [mView pushSubviewForKey:@"UpdatePreview"];
//            }
//        }
//#endif
//            {
//                GameController *gc = GCTRL;
//                if ([gc.gameSettings settingForKey:GAME_SETTINGS_KEY_GAME_CENTER_ENABLED]) {
//                    if ([mScene.ofManager isUserLoggedIntoGameCenter] == NO)
//                        [mScene.ofManager loginToGameCenter];
//                }
//            }
            break;
        case MenuStateTransitionIn:
            break;
        case MenuStateIn:
            break;
        case MenuStateTransitionOut:
            break;
        case MenuStateOut:
            break;
        default:
            break;
    }
    
    mState = state;
    
    // Apply new state
    switch (mState) {
        case MenuStateLaunching:
            [self playAmbientSounds];
            break;
        case MenuStateTransitionIn:
        {
            GameController *gc = GCTRL;
            Score *hiScore = [gc.gameStats hiScore];
            
            if (gc.thisTurn.infamy > hiScore.score) {
                [gc.gameStats setHiScore:gc.thisTurn.infamy];
                [self refreshHiScoreView];
            }
            
            mView.visible = YES;
            mView.touchable = NO;
            [self refreshHiScoreView];
            [self updateObjectivesLogView];
#ifdef CHEEKY_LITE_VERSION
            [mView hidePotionsButton:YES]; //(mScene.objectivesManager.rank < [Potion minPotionRank])
#endif
            [mView transitionInOverTime:kMenuTransitionDuration];
                
            if (previousState != MenuStateLaunching && previousState != MenuStateIn)
                [self playAmbientSounds];
        }
            break;
        case MenuStateIn:
        {
            GameController *gc = GCTRL;
            
            if (mDataIntegrityChecked == NO) {
                mDataIntegrityChecked = YES;
                
                if (gc.isGameDataValid == NO)
                    [self setAlertState:kAlertStateDataIntegrity];
            }
            
            mShouldSaveProgress = YES;
            mView.touchable = YES;
            [mScene enablePerformanceSavingMode:YES];
         
            if ([PersistenceManager PM].isCloudSupported && ![gc.gameSettings settingForKey:GAME_SETTINGS_KEY_CLOUD_QUERIED])
                [self queryCloudApproval];
            else if ([gc.gameSettings settingForKey:GAME_SETTINGS_KEY_GAME_CENTER_ENABLED] && [mScene.ofManager isUserLoggedIntoGameCenter] == NO)
                    [mScene.ofManager loginToGameCenter];
            else if (gc.iTunesManager.shouldPromptForRating)
                [self promptUserForRating];
        }
            break;
        case MenuStateTransitionOut:
        {
            mView.touchable = NO;
            [mView popAllSubviews];
            [mView transitionOutOverTime:kMenuTransitionDuration];
            [self stopAmbientSoundsOverTime:2.0f];
        }
            break;
        case MenuStateOut:
            mView.visible = NO;
            break;
        default:
            break;
    }
}

- (void)updateObjectivesLogView {
    [mView updateObjectivesLog];
}

- (void)setSwitch:(NSString *)name value:(BOOL)value {
    [mView setSwitch:name value:value];
}

- (void)advanceTime:(double)time {
    if (mShouldSaveProgress) {
        GameController *gc = GCTRL;
        
        if ([gc processEndOfTurn] == NO && mOfflineSavedRequired)
            [gc saveProgress];
        [mScene.ofManager reportOfflineAchievements];
        
        if (gc.gameSettings.delayedSaveRequired)
            [gc.gameSettings saveSettings];
        
        mOfflineSavedRequired = NO;
        mShouldSaveProgress = NO;
    }
    
    [mView advanceTime:time];
}

- (float)ambienceVolume {
    float volume = MIN(1.0f, ((RESM.isLowSoundOutput) ? 1.5f * MENU_AMBIENCE_VOLUME : MENU_AMBIENCE_VOLUME));
    
    UIDevicePlatform platformType = [RESM platformType];
    if (platformType == UIDevice4GiPod)
        volume *= 0.85f;
    
    return volume;
}

- (void)playAmbientSounds {
	[mScene.audioPlayer playSoundWithKey:MENU_AMBIENCE volume:[self ambienceVolume] easeInDuration:2.0f];
}

- (void)stopAmbientSoundsOverTime:(float)duration {
    [mScene.audioPlayer stopSoundWithKey:MENU_AMBIENCE easeOutDuration:duration];
}

- (void)refreshHiScoreView {
    NSString *hiScoreText = nil;
    int64_t hiScore = GCTRL.playerDetails.hiScore.score;
    
    if (hiScore > 0)
        hiScoreText = [Globals commaSeparatedScore:hiScore];
    [mView updateHiScoreText:hiScoreText];
}

- (void)viewDidTransitionIn:(SPEvent *)event {
    [self setState:MenuStateIn];
}

- (void)viewDidTransitionOut:(SPEvent *)event {
    [self setState:MenuStateOut];
}

- (void)viewWasTouchedToPlay:(SPEvent *)event {
    [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_MENU_PLAY_SHOULD_BEGIN]];
}

- (void)notifyUiViewHasFocus {
    [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_MENU_UIVIEW_HAS_FOCUS]];
}

- (void)notifySPViewHasFocus {
    [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_MENU_SPVIEW_HAS_FOCUS]];
}

- (void)onButtonTriggered:(SPEvent *)event {
	MenuButton *button = (MenuButton *)event.currentTarget;
	
	if (button != nil && [self respondsToSelector:button.actionSelector]) {
        if (button.sfxKey)
            [mScene.audioPlayer playSoundWithKey:button.sfxKey volume:button.sfxVolume];
        [self performSelector:button.actionSelector withObject:button];
	}
}

- (void)objectives:(MenuButton *)sender {
    [self updateObjectivesLogView];
    [mView pushSubviewForKey:@"Objectives"];
}

- (void)achievements:(MenuButton *)sender {
    [self showAchievementsView];
}

- (void)info:(MenuButton *)sender {
    [mView pushSubviewForKey:@"Info"];
}

- (void)options:(MenuButton *)sender {
    [mView pushSubviewForKey:@"Options"];
}

- (void)credits:(MenuButton *)sender {
	if ([mView bookletSubviewForKey:@"Credits"] != nil)
		[mView pushSubviewForKey:@"Credits"];
}

- (void)potions:(MenuButton *)sender {
    [mView pushSubviewForKey:@"Potions"];
    [mView populatePotionView];
}

- (void)onSfxSwitchFlipped:(SwitchFlippedEvent *)event {
	BOOL sfxState = event.state;
	
	mScene.audioPlayer.sfxOn = sfxState;
    [GCTRL.gameSettings setSettingForKey:GAME_SETTINGS_KEY_SFX_ON value:sfxState];
}

- (void)onMusicSwitchFlipped:(SwitchFlippedEvent *)event {
    BOOL musicState = event.state;
	
	mScene.audioPlayer.musicOn = musicState;
    [GCTRL.gameSettings setSettingForKey:GAME_SETTINGS_KEY_MUSIC_ON value:musicState];
	
	if (musicState == YES)
		[self playAmbientSounds];
}

- (void)prevBookletPage:(MenuButton *)sender {
	TitleSubview *subview = [mView currentSubview];
	
	if ([subview isKindOfClass:[BookletSubview class]])
		[(BookletSubview *)subview prevPage];
}

- (void)nextBookletPage:(MenuButton *)sender {
	TitleSubview *subview = [mView currentSubview];
	
	if ([subview isKindOfClass:[BookletSubview class]])
		[(BookletSubview *)subview nextPage];
}

- (void)resetTutorialPrompts:(MenuButton *)sender {
	[self setQueryState:kQueryStateResetTutorialPrompts];
}

- (void)resetGameProgress:(MenuButton *)sender {
    [self setQueryState:kQueryStateResetProgress];
}

- (void)restoreProgress:(MenuButton *)sender {
    [self setQueryState:kQueryStateRestoreProgress];
}

- (void)statsLogInfo:(MenuButton *)sender {
    [self showCaptainProfileView];
}

- (void)gameConceptsInfo:(MenuButton *)sender {
    if ([mView bookletSubviewForKey:@"GameConcepts"] != nil)
        [mView pushSubviewForKey:@"GameConcepts"];
}

- (void)spellsMunitionsInfo:(MenuButton *)sender {
    if ([mView bookletSubviewForKey:@"SpellsAndMunitions"] != nil)
        [mView pushSubviewForKey:@"SpellsAndMunitions"];
}

- (void)followUsTwitter:(MenuButton *)sender {
    UIDevice *device = [UIDevice currentDevice];
    
    if (device && [device respondsToSelector:@selector(isMultitaskingSupported)] && [device isMultitaskingSupported])
        [self launchTwitterAppWithUsername:@"CheekyMammoth"];
    else
        [self setQueryState:kQueryStateLaunchTwitter];
}

- (void)likeUsFacebook:(MenuButton *)sender {
    UIDevice *device = [UIDevice currentDevice];
    
    if (device && [device respondsToSelector:@selector(isMultitaskingSupported)] && [device isMultitaskingSupported])
        [self launchFacebookWithPagename:@"CheekyMammoth"];
    else
        [self setQueryState:kQueryStateLaunchFacebook];
}

- (void)syncAchievements:(MenuButton *)sender {
    //GameController *gc = GCTRL;
    
    //if ([gc.gameSettings settingForKey:GAME_SETTINGS_KEY_SYNCED_ACHIEVEMENTS])
    //    [self achievementsSyncSucceeded];
    //else
        [self setQueryState:kQueryStateSyncAchievements];
}

- (void)achievementsSyncSucceeded {
    mAchievementsSyncInProgress = 0;
    [self dismissSyncAchievementsAlertViewAnimated:NO];
    //[GCTRL.gameSettings setSettingForKey:GAME_SETTINGS_KEY_SYNCED_ACHIEVEMENTS value:YES];
    [mScene.achievementManager saveProgress];
    [mScene.achievementManager fetchAchievements];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sync Successful"
                                                        message:@"Local achievements synchronized with Game Center."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

- (void)achievementsSyncFailed {
    mAchievementsSyncInProgress = 0;
    [mScene.achievementManager cancelOnlineSync];
    [self dismissSyncAchievementsAlertViewAnimated:NO];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sync Failed"
                                                        message:@"Please ensure you're logged in and online and try again."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

- (void)onAchievementSyncStepComplete:(MultiPurposeEvent *)event {
    if (mAchievementsSyncInProgress == 0)
        return;
    
    if ([event.data objectForKey:@"Error"]) {
        [self achievementsSyncFailed];
        return;
    }
    
    NSNumber *stepBit = (NSNumber *)[event.data objectForKey:event.type];
    
    if (stepBit) {
        uint bit = [stepBit unsignedIntValue];
        mAchievementsSyncInProgress &= ~bit;
        
        if (mAchievementsSyncInProgress == 0)
            [self achievementsSyncSucceeded];
    } else {
        [self achievementsSyncFailed];
    }
}

- (void)liteGetTheFullVersion:(MenuButton *)sender {
    [mView pushSubviewForKey:@"Lite"];
}

- (void)liteBuyNow:(MenuButton *)sender {
    [self setQueryState:kQueryStateGetTheFullVersion];
}

- (void)onFlipControlsPressed:(MenuButton *)sender {
    [mScene flip:!mScene.flipped];
}

- (void)selectPotion:(MenuButton *)sender {
    [mView selectCurrentPotion];
}

- (void)yesRateGame:(MenuButton *)sender {
    [mView popSubview];
    [GCTRL.iTunesManager userRespondedToPrompt:UPRAccepted];
    [self openReviewURL];
}

- (void)noRateGame:(MenuButton *)sender {
    [GCTRL.iTunesManager userRespondedToPrompt:UPRPostponed];
    [mView popSubview];
}

- (void)openReviewURL {
    GameController *gc = GCTRL;
#if 1
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:gc.iTunesManager.reviewURL]];
#else
    if ([SKStoreProductViewController class]) {
        if (gc.isSKStoreActive)
            return;
        
        [gc stopSparrow];
        gc.isSKStoreActive = YES;
        SKStoreProductViewController *storeViewController = [[[SKStoreProductViewController alloc] init] autorelease];
        storeViewController.delegate = self;
        NSNumber *appId = [NSNumber numberWithInteger:gc.iTunesManager.appId];
        [storeViewController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier: appId} completionBlock:nil];
        [gc.viewController presentViewController:storeViewController animated:YES completion:nil];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:gc.iTunesManager.reviewURL]];
    }
#endif
}

//- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
//    [viewController dismissViewControllerAnimated:YES completion:nil];
//    GCTRL.isSKStoreActive = NO;
//    [GCTRL startSparrow];
//}

- (void)closeSubview:(MenuButton *)sender {
	TitleSubview *subview = mView.currentSubview;
	NSString *selectorName = subview.closeSelectorName;
	
	if (selectorName != nil) {
		SEL s = NSSelectorFromString(selectorName);
		
		if ([self respondsToSelector:s])
			[self performSelector:s];
	}
}

- (void)closeObjectives:(MenuButton *)sender {
    [mView popSubview];
}

- (void)closeAchievements:(MenuButton *)sender {
	[mView popSubview];
	[self destroyAchievementsViewController];
    [self notifySPViewHasFocus];
}

- (void)closeInfo:(MenuButton *)sender {
    [mView popSubview];
}

- (void)closeStats:(MenuButton *)sender {
	[mView popSubview];
	[self destroyCaptainProfileViewController];
    [self notifySPViewHasFocus];
}

- (void)closeGameConcepts:(MenuButton *)sender {
    [mView popSubview];
    [mView destroySubviewForKey:@"GameConcepts"];
}

- (void)closeSpellsAndMunitions:(MenuButton *)sender {
    [mView popSubview];
    [mView destroySubviewForKey:@"SpellsAndMunitions"];
}

- (void)closeOptions:(MenuButton *)sender {
	[mView popSubview];
    
    if (GCTRL.gameSettings.delayedSaveRequired)
        [GCTRL.gameSettings saveSettings];
}

- (void)closePotions:(MenuButton *)sender {
    if (mView.potionWasSelected) {
        [mScene.achievementManager resetCombatTextCache];
        [mScene.achievementManager.profileManager saveProgress];
    }
    
    if (GCTRL.gameSettings.delayedSaveRequired)
        [GCTRL.gameSettings saveSettings];
    
    [mView popSubview];
    [mView unpopulatePotionView];
}

- (void)closeCredits:(MenuButton *)sender {
    [mView popSubview];
    [mView destroySubviewForKey:@"Credits"];
}

- (void)closeLite:(MenuButton *)sender {
    [mView popSubview];
}

- (void)closeUpdatePreview:(MenuButton *)sender {
    [mView popSubview];
    [mView destroySubviewForKey:@"UpdatePreview"];
}

- (void)resetTutorialPrompts {
    [GCTRL.gameSettings resetTutorialPrompts];
}

- (void)resetObjectives {
    GameController *gc = GCTRL;
    [gc.gameStats resetObjectives];
    [gc.gameStats enforcePotionConstraints];
    [mScene.achievementManager saveProgress];
    [mScene.objectivesManager setupWithRanks:gc.gameStats.objectives];
    [mScene.achievementManager resetCombatTextCache];
    [self updateObjectivesLogView];
    //[mView hidePotionsButton:(mScene.objectivesManager.rank < [Potion minPotionRank])];
}

- (void)resetAchievements {
    [GCTRL.gameStats resetAchievements];
    [mScene.achievementManager saveProgress];
}

- (void)launchTwitterAppWithUsername:(NSString *)username {
    BOOL didOtherAppOpen = NO;
    
    UIDevice *device = [UIDevice currentDevice];
    
    if (device && [device respondsToSelector:@selector(isMultitaskingSupported)] && [device isMultitaskingSupported]) {
        NSString *urlString = [NSString stringWithFormat:@"twitter://user?screen_name=%@", username];
        didOtherAppOpen = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
    
    if (didOtherAppOpen == NO) {
        NSString *urlString = [NSString stringWithFormat:@"https://twitter.com/%@", username];
        didOtherAppOpen = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
}

- (void)launchFacebookWithPagename:(NSString *)pagename {
    NSString *urlString = [NSString stringWithFormat:@"http://facebook.com/%@", pagename];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (void)launchGameCenter:(MenuButton *)sender {
    if ([ResManager isGameCenterAvailable] == NO) {
        [self setAlertState:kAlertStateLoginUnavailable];
        return;
    }
    
    if ([GCTRL.gameSettings settingForKey:GAME_SETTINGS_KEY_GAME_CENTER_ENABLED] == NO) {
        // Player has changed their mind about using Game Center
        [GCTRL.gameSettings setSettingForKey:GAME_SETTINGS_KEY_GAME_CENTER_ENABLED value:YES];
        [GCTRL.gameSettings saveSettings];
    }
    
    if ([mScene.ofManager isUserLoggedIntoGameCenter] == NO) {
        if ([[GKLocalPlayer localPlayer] respondsToSelector:@selector(setAuthenticateHandler:)]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Game Center Login Required"
                                                                message:@"Sign in with the Game Center application to access the Hall of Infamy leaderboard."
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"Sign In", nil];
            alertView.tag = kCCUIAlertViewTagGCSignIn;
            [alertView show];
            [alertView release];
        } else {
            mDidInitiateGameCenterAuthentication = YES;
            [self setAlertState:kAlertStateLoginIncomplete];
            [mScene.ofManager loginToGameCenter];
        }
        return;
    } else {
        [self showGameCenterLeaderboardView];
    }
}

- (void)playerAuthenticationWillChange:(SPEvent *)event {
    if (GCTRL.viewController.isShowingGCLeaderboard && ![[GKLocalPlayer localPlayer] respondsToSelector:@selector(setAuthenticateHandler:)]) {
        [GCTRL.viewController destroyGameCenterLeaderboard:^(void) {
            [GCTRL startSparrow];
        }];
    }
}

- (void)gameCenterLoginChanged:(MultiPurposeEvent *)event {
    [self setAlertState:kAlertStateNull];
    
    NSError *error = [event.data objectForKey:@"Error"];
    
    NSLog(@"Game Center Login ERROR CODE: %d", error.code);
    
    if (error && mDidInitiateGameCenterAuthentication) {
        switch (error.code) {
            case NSURLErrorNotConnectedToInternet:
            case GKErrorUnknown:
            case GKErrorCancelled:
            case GKErrorCommunicationsFailure:
            case GKErrorNotAuthenticated:
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Game Center Disabled"
                                                                    message:@"Sign in with the Game Center application to access the Hall of Infamy leaderboard."
                                                                   delegate:self
                                                          cancelButtonTitle:@"Cancel"
                                                          otherButtonTitles:@"Sign In", nil];
                alertView.tag = kCCUIAlertViewTagGCSignIn;
                [alertView show];
                [alertView release];

                //[self setAlertState:kAlertStateLoginUnsuccessful];
            }
                break;
            case GKErrorAuthenticationInProgress:
                [self setAlertState:kAlertStateLoginIncomplete];
                break;
            case GKErrorNotSupported:
            case GKErrorParentalControlsBlocked:
                [self setAlertState:kAlertStateLoginUnavailable];
                break;
            // case NSURLErrorNotConnectedToInternet:
            //     [self setAlertState:kAlertStateOffline];
            //     break;
            default:
                break;
        }
    }
    
    NSNumber *didPlayerChange = [event.data objectForKey:@"PlayerDidChange"];
    if (didPlayerChange && [didPlayerChange boolValue] && GCTRL.viewController.isShowingGCLeaderboard) {
        [GCTRL.viewController destroyGameCenterLeaderboard:^(void) {
            [GCTRL startSparrow];
            
            if (![GKLocalPlayer localPlayer].isAuthenticated) {
                UIViewController *viewController = [event.data objectForKey:@"ViewController"];
                
                if (viewController && [viewController isKindOfClass:[UIViewController class]]) {
                    [GCTRL stopSparrow];
                    [GCTRL.viewController presentViewController:viewController animated:YES completion:nil];
                }
            }
        }];
    } else {
        [GCTRL startSparrow];
        
        if (![GKLocalPlayer localPlayer].isAuthenticated) {
            UIViewController *viewController = [event.data objectForKey:@"ViewController"];
            
            if (viewController && [viewController isKindOfClass:[UIViewController class]]) {
                [GCTRL stopSparrow];
                [GCTRL.viewController presentViewController:viewController animated:YES completion:nil];
            }
        }
    }
    
    mDidInitiateGameCenterAuthentication = NO;
}

- (void)queryCloudApproval {
    if (self.CCCloudApprovalView)
        return;
    
    self.CCCloudApprovalView = [[[UIAlertView alloc] initWithTitle:@"Choose Storage Option"
                                                           message:@"Should game progress be stored in iCloud and available on all your devices?"
                                                          delegate:self
                                                 cancelButtonTitle:@"Local Only"
                                                 otherButtonTitles:@"Use iCloud", nil] autorelease];
    self.CCCloudApprovalView.tag = kCCUIAlertViewTagApproveCloud;
    [self.CCCloudApprovalView show];
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
    if ((alertView.tag == kCCUIAlertViewTagOFCloudBackup || alertView.tag == kCCUIAlertViewTagOFCloudRestore) &&
                [alertView viewWithTag:kCCUIActivityIndicatorViewTagOFCloud] == nil)
    {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicator.tag = kCCUIActivityIndicatorViewTagOFCloud;
        activityIndicator.center = CGPointMake(alertView.frame.size.width / 2, alertView.frame.size.height / 2);
        [activityIndicator startAnimating];
        [alertView addSubview:activityIndicator];
        [activityIndicator release];
    } else if (alertView.tag == kCCUIAlertViewTagOFChallenge && [alertView viewWithTag:kCCUIActivityIndicatorViewTagOFChallenge] == nil) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicator.tag = kCCUIActivityIndicatorViewTagOFChallenge;
        activityIndicator.center = CGPointMake(alertView.frame.size.width / 2, alertView.frame.size.height / 2);
        [activityIndicator startAnimating];
        [alertView addSubview:activityIndicator];
        [activityIndicator release];
    } else if (alertView.tag == kCCUIAlertViewTagSyncAchievements && [alertView viewWithTag:kCCUIActivityIndicatorViewTagSyncAchievements] == nil) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicator.tag = kCCUIActivityIndicatorViewTagSyncAchievements;
        activityIndicator.center = CGPointMake(alertView.frame.size.width / 2, alertView.frame.size.height / 2);
        [activityIndicator startAnimating];
        [alertView addSubview:activityIndicator];
        [activityIndicator release];
    }
}

- (void)setAlertState:(int)state {
    // Don't let alerts steal focus from UIViews and don't let more than one alert run at a time.
    if (mScene.state == PfStateHibernating || mState != MenuStateIn || (mAlertState != kAlertStateNull && state != kAlertStateNull))
        return;
    
	switch (state) {
        case kAlertStateNull:
            if (mAlertState != kAlertStateNull)
                [mView popSubview];
            break;
        case kAlertStateLoginUnavailable:
            [mView setAlertTitle:@"Not Available" text:@"Game Center is not available on your device."];
            [mView pushSubviewForKey:@"Alert"];
            break;
		case kAlertStateLoginIncomplete:
			[mView setAlertTitle:@"Authenticating..." text:@"Game Center is still attempting to authenticate. Please try again later."];
            [mView pushSubviewForKey:@"Alert"];
			break;
        case kAlertStateLoginUnsuccessful:
			[mView setAlertTitle:@"Game Center Disabled" text:@"Sign in with the Game Center application to enable."];
            [mView pushSubviewForKey:@"Alert"];
			break;
        case kAlertStateOffline:
            [mView setAlertTitle:@"Failed to Connect" text:@"Please attempt to sign in with the Game Center application."];
            [mView pushSubviewForKey:@"Alert"];
            break;
        case kAlertStateDataIntegrity:
            [mView setAlertTitle:@"Invalid Game Data" text:@"High scores will not be submitted online."];
            [mView pushSubviewForKey:@"Alert"];
            break;
		default:
			break;
	}
    
	mAlertState = state;
}

- (void)setQueryState:(int)state {
    // Don't let queries steal focus from UIViews and don't let more than one query run at a time.
    if (mScene.state == PfStateHibernating || mState != MenuStateIn || (mQueryState != kQueryStateNull && state != kQueryStateNull))
        return;
    
	switch (state) {
        case kQueryStateNull:
            if (mQueryState != kQueryStateNull)
                [mView popSubview];
            break;
		case kQueryStateResetTutorialPrompts:
            [mView setQueryTitle:@"Are You Sure?" text:@"This will reset the tutorial and all helpful hints."];
            [mView pushSubviewForKey:@"Query"];
			break;
        case kQueryStateResetProgress:
            [mView setQueryTitle:@"Are You Sure?" text:@"This will reset your Objectives and Achievements progress."];
            [mView pushSubviewForKey:@"Query"];
            break;
        case kQueryStateRestoreProgress:
            [mView setQueryTitle:@"Are You Sure?" text:@"Restores any progress that has been saved in the OpenFeint cloud."];
            [mView pushSubviewForKey:@"Query"];
            break;
        case kQueryStateLaunchTwitter:
            [mView setQueryTitle:@"Are You Sure?" text:@"Leave this App and view Cheeky Mammoth on Twitter?"];
            [mView pushSubviewForKey:@"Query"];
            break;
        case kQueryStateLaunchFacebook:
            [mView setQueryTitle:@"Are You Sure?" text:@"Leave this App and view Cheeky Mammoth on Facebook?"];
            [mView pushSubviewForKey:@"Query"];
            break;
        case kQueryStateSyncAchievements:
            [mView setQueryTitle:@"Are You Sure?" text:@"Synchronize local and online achievements progress?"];
            [mView pushSubviewForKey:@"Query"];
            break;
        case kQueryStateGetTheFullVersion:
            [mView setQueryTitle:@"Are You Sure?" text:@"Leave this App and view Cutlass Cove on the App Store?"];
            [mView pushSubviewForKey:@"Query"];
            break;
		default:
			break;
	}
	mQueryState = state;
}

- (void)okAlert:(MenuButton *)sender {
    [self setAlertState:kAlertStateNull];
}

- (void)yesQuery:(MenuButton *)sender {
	switch (mQueryState) {
		case kQueryStateResetTutorialPrompts:
			[self resetTutorialPrompts];
			break;
        case kQueryStateResetProgress:
            [self resetObjectives];
            [self resetAchievements];
            break;
        case kQueryStateRestoreProgress:
            break;
        case kQueryStateLaunchTwitter:
            [self launchTwitterAppWithUsername:@"CheekyMammoth"];
            break;
        case kQueryStateLaunchFacebook:
            [self launchFacebookWithPagename:@"CheekyMammoth"];
            break;
        case kQueryStateSyncAchievements:
            break;
        case kQueryStateGetTheFullVersion:
            [GCTRL.iTunesManager openFullVersionURL];
            break;
		default:
			break;
	}
    
    [self setQueryState:kQueryStateNull];
}

- (void)noQuery:(MenuButton *)sender {
	switch (mQueryState) {
		case kQueryStateResetTutorialPrompts:
        case kQueryStateResetProgress:
        case kQueryStateRestoreProgress:
        case kQueryStateLaunchTwitter:
        case kQueryStateLaunchFacebook:
        case kQueryStateSyncAchievements:
        case kQueryStateGetTheFullVersion:
			break;
		default:
			break;
	}
    
    [self setQueryState:kQueryStateNull];
}

- (void)dismissOFCloudAlertViewAnimated:(BOOL)animated {
    if (self.CCOFCloudAlertView == nil)
        return;
    
    [self.CCOFCloudAlertView dismissWithClickedButtonIndex:-1 animated:animated];
    self.CCOFCloudAlertView = nil;
}

- (void)dismissOFChallengeAlertView {
    if (self.CCOFChallengeAlertView == nil)
        return;
    
    [self.CCOFChallengeAlertView dismissWithClickedButtonIndex:-1 animated:YES];
    self.CCOFChallengeAlertView = nil;
}

- (void)dismissSyncAchievementsAlertViewAnimated:(BOOL)animated {
    if (self.CCSyncAchievementsAlertView == nil)
        return;
    
    [self.CCSyncAchievementsAlertView dismissWithClickedButtonIndex:-1 animated:animated];
    self.CCSyncAchievementsAlertView = nil;
    [mScene.achievementManager cancelOnlineSync];
}

- (void)promptUserForRating {
    [mView pushSubviewForKey:@"Rate"];
    
//    NSString *title = nil; //;
//    
//    if (GCTRL.gameSettings.isInitialVersion)
//        title = @"If you like our game, please rate it.";
//    else
//        title = @"If you like the update, please rate it.";
//    
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
//                                                        message:nil
//                                                       delegate:self
//                                              cancelButtonTitle:@"Never show this again"
//                                              otherButtonTitles:@"Rate it!", @"Maybe later", nil];
//    
//    alertView.tag = kCCUIAlertViewTagRateTheGame;
//    [alertView show];
//    [alertView release];
}

- (void)showChallengeAlertViewWithTitle:(NSString *)title duration:(NSTimeInterval)duration {
    if (self.CCOFChallengeAlertView)
        return;
    
    self.CCOFChallengeAlertView = [[[UIAlertView alloc] initWithTitle:title
                                                              message:@"\n\n\n"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                                    otherButtonTitles:nil] autorelease];
    self.CCOFChallengeAlertView.tag = kCCUIAlertViewTagOFChallenge;
    [self.CCOFChallengeAlertView show];
    [self performSelector:@selector(dismissOFChallengeAlertView) withObject:nil afterDelay:duration];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case kCCUIAlertViewTagGCSignIn:
        {
            if (buttonIndex == 0) // Cancel
                [self setAlertState:kAlertStateNull];
            else if (buttonIndex == 1 && [ResManager isGameCenterAvailable])
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"gamecenter:"]];
        }
            break;
        case kCCUIAlertViewTagOFChallenge:
        {
            if (buttonIndex == 0) { // Cancel
                [NSObject cancelPreviousPerformRequestsWithTarget:self];
                self.CCOFChallengeAlertView = nil;
            }
        }
            break;
        case kCCUIAlertViewTagOFCloudBackup:
            break;
        case kCCUIAlertViewTagOFCloudRestore:
            break;
        case kCCUIAlertViewTagRateTheGame:
        {
            GameController *gc = GCTRL;
            
            switch (buttonIndex) {
                case 0: // Never show this again
                    [gc.iTunesManager userRespondedToPrompt:UPRRefused];
                    break;
                case 1: // Rate it!
                    [gc.iTunesManager userRespondedToPrompt:UPRAccepted];
                    [self openReviewURL];
                    break;
                case 2: // Maybe later
                    [gc.iTunesManager userRespondedToPrompt:UPRPostponed];
                    break;
                default:
                    break;
            }
        }
            break;
        case kCCUIAlertViewTagSyncAchievements:
        {
            if (buttonIndex == 0) { // Cancel
                mAchievementsSyncInProgress = 0;
                self.CCSyncAchievementsAlertView = nil;
                [mScene.achievementManager cancelOnlineSync];
            }
        }
            break;
        case kCCUIAlertViewTagApproveCloud:
        {
            [GCTRL.gameSettings setSettingForKey:GAME_SETTINGS_KEY_CLOUD_QUERIED value:YES];
            [GCTRL.gameSettings setSettingForKey:GAME_SETTINGS_KEY_CLOUD_APPROVED value:buttonIndex != 0];
            [GCTRL.gameSettings saveSettings];
            
            if (buttonIndex != 0) {
                [PersistenceManager PM].isCloudApproved = YES;
                [[PersistenceManager PM] enableCloud];
            }
            
            if ([GCTRL.gameSettings settingForKey:GAME_SETTINGS_KEY_GAME_CENTER_ENABLED]) {
                if ([mScene.ofManager isUserLoggedIntoGameCenter] == NO)
                    [mScene.ofManager loginToGameCenter];
            }
        }
            break;
        default:
            break;
    }
}

- (void)alertViewCancel:(UIAlertView *)alertView {
    [self setAlertState:kAlertStateNull];
}

- (void)onSpeedboatLaunchRequested:(SPEvent *)event {
    [mView popSubview];
	[self destroyAchievementsViewController];
    [self notifySPViewHasFocus];
    mScene.raceEnabled = YES;
}

- (void)showAchievementsView {
    if (mAchievementsViewController)
        return;
	GameController *gc = GCTRL;
	[mView pushSubviewForKey:@"Achievements"];
	
    SPEventDispatcher *eventProxy = [[[SPEventDispatcher alloc] init] autorelease];
    [eventProxy addEventListener:@selector(onSpeedboatLaunchRequested:) atObject:self forType:CUST_EVENT_TYPE_SPEEDBOAT_LAUNCH_REQUESTED];
    
	mAchievementsViewController = [[AchievementsViewController alloc] initWithDataModel:mScene.achievementManager eventProxy:eventProxy];
	[mScene.achievementManager addEventListener:@selector(onModelDataWillChange:) atObject:mAchievementsViewController forType:CUST_EVENT_TYPE_GK_DATA_WILL_CHANGE];
	[mScene.achievementManager addEventListener:@selector(onModelDataChanged:) atObject:mAchievementsViewController forType:CUST_EVENT_TYPE_GK_DATA_CHANGED];
	[gc.view addSubview:mAchievementsViewController.view];
	[mAchievementsViewController updateOrientation:gc.deviceOrientation];
	[mScene.achievementManager setModelState:StatePlayerAchievements];
	[mScene.achievementManager fetchAchievements];
    [self notifyUiViewHasFocus];
    
    //[GCTRL stopSparrow]; // INSTEAD: stop PlayfieldController from advancing time
}

- (void)destroyAchievementsViewController {
	[mScene.achievementManager removeEventListener:@selector(onModelDataWillChange:) atObject:mAchievementsViewController forType:CUST_EVENT_TYPE_GK_DATA_WILL_CHANGE];
	[mScene.achievementManager removeEventListener:@selector(onModelDataChanged:) atObject:mAchievementsViewController forType:CUST_EVENT_TYPE_GK_DATA_CHANGED];
	[mAchievementsViewController.view removeFromSuperview];
	[mAchievementsViewController release];
	mAchievementsViewController = nil;
    
    //[GCTRL startSparrow]; // INSTEAD: start PlayfieldController advancing time again
}

- (void)showGameCenterLeaderboardView {
    GameController *gc = GCTRL;
    if (gc.viewController.isShowingGCLeaderboard) {
        [gc.viewController destroyGameCenterLeaderboard:^(void) {
            [GCTRL startSparrow];
            [gc.viewController showGameCenterLeaderboardForCategory:nil]; //gc.thisTurn.gameMode];
        }];
    } else {
        [gc.viewController showGameCenterLeaderboardForCategory:nil]; //]gc.thisTurn.gameMode];
    }
}

- (void)showCaptainProfileView {
    if (mCaptainProfileViewController)
        return;
	GameController *gc = GCTRL;
	[mView pushSubviewForKey:@"StatsLog"];
	
	mCaptainProfileViewController = [[CaptainProfileViewController alloc] initWithDataModel:mScene.achievementManager];
	[mScene.achievementManager addEventListener:@selector(onModelDataWillChange:) atObject:mCaptainProfileViewController forType:CUST_EVENT_TYPE_GK_DATA_WILL_CHANGE];
	[mScene.achievementManager addEventListener:@selector(onModelDataChanged:) atObject:mCaptainProfileViewController forType:CUST_EVENT_TYPE_GK_DATA_CHANGED];
	[gc.view addSubview:mCaptainProfileViewController.view];
	[mCaptainProfileViewController updateOrientation:gc.deviceOrientation];
	[mScene.achievementManager setModelState:StatePlayerStats];
    [self notifyUiViewHasFocus];
    //[GCTRL stopSparrow]; // INSTEAD: stop PlayfieldController from advancing time
}

- (void)destroyCaptainProfileViewController {
	[mScene.achievementManager removeEventListener:@selector(onModelDataWillChange:) atObject:mCaptainProfileViewController forType:CUST_EVENT_TYPE_GK_DATA_WILL_CHANGE];
	[mScene.achievementManager removeEventListener:@selector(onModelDataChanged:) atObject:mCaptainProfileViewController forType:CUST_EVENT_TYPE_GK_DATA_CHANGED];
	[mCaptainProfileViewController.view removeFromSuperview];
	[mCaptainProfileViewController release];
	mCaptainProfileViewController = nil;
    
    //[GCTRL startSparrow]; // INSTEAD: start PlayfieldController advancing time again
}

- (void)showTwitterViewControllerInitialText:(NSString *)initialText attachment:(UIImage *)image {
    BOOL tweetSent = NO;
    
    if (NSClassFromString(@"SLComposeViewController")) { // [ResManager isOSFeatureSupported:@"6.0"]) {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            GameController *gc = GCTRL;
            SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            
            if (tweetSheet) {
                tweetSent = YES;
                
                if (image)
                    [tweetSheet addImage:image];
                [tweetSheet addURL:[NSURL URLWithString:@"http://www.cheekymammoth.com/awesomepirates.html"]];
                [tweetSheet setInitialText:initialText];
                
                [GCTRL stopSparrow];
                GCTRL.isTwitterActive = YES;
                tweetSheet.completionHandler = ^(SLComposeViewControllerResult result) {
                    // Not guaranteed to be on the main thread, so dispatch on main.
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        [tweetSheet dismissViewControllerAnimated:YES completion:nil];
                        GCTRL.isTwitterActive = NO;
                        [GCTRL startSparrow];
                        
                        
                        
//                        NSArray *childVCs = GCTRL.viewController.childViewControllers;
//                        if (childVCs && childVCs.count > 0 && [childVCs containsObject:tweetSheet]) {
//                            [tweetSheet dismissViewControllerAnimated:YES completion:^(void) {
//                                GCTRL.isTwitterActive = NO;
//                                [GCTRL startSparrow];
//                            }];
//                        } else {
//                            GCTRL.isTwitterActive = NO;
//                            [GCTRL startSparrow];
//                        }
                        
                        
                        //GCTRL.isTwitterActive = NO;
                        //[GCTRL startSparrow];
                        
                        //NSArray *childVCs = GCTRL.viewController.childViewControllers;
                        //if (childVCs.count > 0)
                        //    [GCTRL.viewController dismissViewControllerAnimated:YES completion:nil];
                    });
                };
                [gc.viewController presentViewController:tweetSheet animated:YES completion:nil];
            }
        }
    } else if (NSClassFromString(@"TWTweetComposeViewController")) { //[ResManager isOSFeatureSupported:@"5.0"]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        GameController *gc = GCTRL;
        TWTweetComposeViewController *twitterVC = [[[TWTweetComposeViewController alloc] init] autorelease];
        
        if (twitterVC) {
            tweetSent = YES;
            
            if (image)
                [twitterVC addImage:image];
            [twitterVC addURL:[NSURL URLWithString:@"http://www.cheekymammoth.com/awesomepirates.html"]];
            [twitterVC setInitialText:initialText];
            
            [GCTRL stopSparrow];
            GCTRL.isTwitterActive = YES;
            twitterVC.completionHandler = ^(TWTweetComposeViewControllerResult result) {
                [twitterVC dismissViewControllerAnimated:YES completion:nil];
                GCTRL.isTwitterActive = NO;
                [GCTRL startSparrow];
                
                
                
//                [twitterVC dismissViewControllerAnimated:YES completion:^(void) {
//                    GCTRL.isTwitterActive = NO;
//                    [GCTRL startSparrow];
//                }];
                
                
                
                //                GCTRL.isTwitterActive = NO;
                //                [GCTRL startSparrow];
                //                NSArray *childVCs = GCTRL.viewController.childViewControllers;
                //                if (childVCs.count > 0)
                //                    [GCTRL.viewController dismissViewControllerAnimated:YES completion:nil];
            };
            [gc.viewController presentViewController:twitterVC animated:YES completion:nil];
        }
#pragma clang diagnostic pop
    }
    
    if (!tweetSent) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Tweet Not Sent"
                                                            message:@"You can't send a tweet right now. Please make sure your device has internet access and you are signed into a Twitter account."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
}

@end
