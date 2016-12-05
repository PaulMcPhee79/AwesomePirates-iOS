//
//  PlayfieldController.h
//  Pirates
//
//  Created by Paul McPhee on 3/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SceneController.h"
//#import "TwitterDelegate.h"
#import <Box2D/Box2D.h>

@class PlayfieldView,ActorAi,TownAi,VoodooManager,DeathFromDeep,MenuButton,ShipActor,MenuController,MultiPurposeEvent;
class ActorContactListener;

typedef enum {
    PfStateLaunching = 0,
    PfStateHibernating,
    PfStateMenu,
    PfStatePlaying,
    PfStateEndOfTurn,
    PfStateDelayedRetry,
    PfStateDelayedQuit
} PfState;

typedef enum {
    TutorialStateNull = 0,
    TutorialStatePrimary,
    TutorialStatePrimary_1,
    TutorialStateSecondary,
    TutorialStateTertiary,
    TutorialStateQuaternary // Quinary, Senary, Septenary, Octonary, Nonary, Denary
} TutorialState;

@interface PlayfieldController : SceneController {
    BOOL mRetried;
	BOOL mRaceEnabled;
    BOOL mMontyShouldMutiny;
    BOOL mCannonsDidOverheat;
    
    double mLaunchTimer; // Delays user interaction until we have fully launched
    
    PfState mState;
    PfState mPreviousState;
    TutorialState mTutorialState;
    
    // Award flags (so we don't reward the player more than once per turn)
    uint mPrizesBitmap;
    
    // iCloud events bitmap
    uint mCloudEvents;
    
	b2World *mWorld;
	float32 mStepDuration;
	float32 mStepAccumulator;
	float32 mTimeRatio;
	b2Vec2 mGravity;
	int mVelocityIterations;
	int mPositionIterations;

	PlayfieldView *mView;
	
	ActorAi *mActorBrains;
	TownAi *mGuvnor;
	
	VoodooManager *mVoodooManager;
    
    MenuController *mMenuController;
	
	@private
	BOOL mResettingScene;
	BOOL mStepping;
    BOOL mSuspendedMode;
    BOOL mIsRaceFinished;
    BOOL mIsTravellingThroughTime;
    BOOL mIsGameSummaryShowing;
    NSString *mEnqueuedRankNotice;
	ActorContactListener *mContactListener;
}

@property (nonatomic,readonly) PfState state;
@property (nonatomic,readonly) TutorialState tutorialState;
@property (nonatomic,readonly) BOOL assistedAiming;
@property (nonatomic,assign) BOOL raceEnabled;
@property (nonatomic,readonly) BOOL isRaceFinished;
@property (nonatomic,assign) float32 timeRatio;
@property (nonatomic,readonly) b2World *world;
@property (nonatomic,readonly) b2Vec2 gravity;
@property (nonatomic,readonly) int velocityIterations;
@property (nonatomic,readonly) int positionIterations;
@property (nonatomic,readonly) ActorAi *actorBrains;
@property (nonatomic,readonly) TownAi *guvnor;
@property (nonatomic,readonly) VoodooManager *voodooManager;

- (void)actorArrivedAtDestination:(Actor *)actor;
- (void)actorDepartedPort:(Actor *)actor;
- (void)cannonsOverheated;

- (void)onButtonTriggered:(SPEvent *)event;
- (NSMutableArray *)liveCannonballs;
- (void)enablePerformanceSavingMode:(BOOL)enable;
- (void)playAmbientSounds;
- (void)stopAmbientSounds;
- (void)timeTravelSequenceDidComplete;
- (void)gameOverSequenceDidComplete;
- (void)onStageDebugTouched:(SPTouchEvent *)event;
- (void)onRaceFinished:(MultiPurposeEvent *)event;
- (void)onRaceTrackConquered:(SPEvent *)event;
- (void)onSpeedDemonAchieved:(SPEvent *)event;

@end
