//
//  MenuController.h
//  CutlassCove
//
//  Created by Paul McPhee on 21/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <StoreKit/StoreKit.h>

#define CUST_EVENT_TYPE_MENU_PLAY_SHOULD_BEGIN @"menuPlayShouldBegin"
#define CUST_EVENT_TYPE_MENU_UIVIEW_HAS_FOCUS @"menuUIViewHasFocus"
#define CUST_EVENT_TYPE_MENU_SPVIEW_HAS_FOCUS @"menuSPViewHasFocus"

@class MenuView,PlayfieldController;
@class AchievementsViewController,ChallengeViewController,CaptainProfileViewController;

typedef enum {
    MenuStateLaunching = 0,
    MenuStateTransitionIn,
    MenuStateIn,
    MenuStateTransitionOut,
    MenuStateOut
} MenuState;

@interface MenuController : SPEventDispatcher <UIAlertViewDelegate> { //,SKStoreProductViewControllerDelegate> {
    BOOL mDataIntegrityChecked;
    BOOL mShouldSaveProgress;
    BOOL mOfflineSavedRequired;
    uint mAchievementsSyncInProgress; // 0x0: Not in progress, 0x1: GC bit, 0x2 OF bit, 0x3: No progress
    MenuState mState;
    MenuView *mView;
    
    UIAlertView *mCCOFChallengeAlertView;
    UIAlertView *mCCOFCloudAlertView;
    UIAlertView *mCCSyncAchievementsAlertView;
    UIAlertView *mCCCloudApprovalView;

    PlayfieldController *mScene; // Weak reference
    
    int mAlertState;
    int mQueryState;
    BOOL mDidInitiateGameCenterAuthentication;
    double mPopulateChallengeFriendsTimer;
    
    // UIViewControllers
    AchievementsViewController *mAchievementsViewController;
    ChallengeViewController *mChallengeViewController;
	CaptainProfileViewController *mCaptainProfileViewController;
}

- (id)initWithScene:(PlayfieldController *)scene;
- (BOOL)reassignScene:(PlayfieldController *)scene;
- (void)destroy;
- (void)setupController;
- (void)attachEventListeners;
- (void)detachEventListeners;
- (void)setState:(MenuState)state;
- (void)refreshHiScoreView;
- (void)updateObjectivesLogView;
- (void)setSwitch:(NSString *)name value:(BOOL)value;

- (void)onButtonTriggered:(SPEvent *)event;
- (void)showChallengeAlertViewWithTitle:(NSString *)title duration:(NSTimeInterval)duration;
- (void)showTwitterViewControllerInitialText:(NSString *)initialText attachment:(UIImage *)image;
- (void)advanceTime:(double)time;

@end
