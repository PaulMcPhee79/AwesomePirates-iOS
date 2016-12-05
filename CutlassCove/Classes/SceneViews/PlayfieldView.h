//
//  PlayfieldView.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 5/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SceneView.h"

#define CUST_EVENT_TYPE_PLAYFIELD_TUTORIAL_COMPLETED @"playfieldTutorialCompletedEvent"

@class Sea,Wave,ShipDeck,PlayerShip,BeachActor,TownActor,TownDock,Weather,PlayfieldController,RaceTrackActor,FutureManager;
@class Prop,GameOverPanel,GameSummary,CoveTimerDisplay,ViewParser,TutorialBooklet;

@interface PlayfieldView : SceneView {
    BOOL mPerformanceSavingMode;
    BOOL mInFuture;
    
	Sea *mSea;
	ShipDeck *mShipDeck;
	PlayerShip *mPlayerShip;
	BeachActor *mBeach;
	TownActor *mTown;
	TownDock *mTownDock;
	Weather *mWeather;
	RaceTrackActor *mRaceTrack;
    Prop *mDayIntro;
	GameOverPanel *mGameOverPanel;
    GameSummary *mGameSummary;
	PlayfieldController *mController;
    
    // Tutorial
    ViewParser *mViewParser;
	TutorialBooklet *mTutorialBooklet;
    
    // Hints
    NSMutableDictionary *mHints;
    NSMutableArray *mHintsGarbage;
    
    // Time Travel
    FutureManager *mFutureManager;
    SPJuggler *mTimeTravelJuggler;
    NSMutableSet *mJunkedRaceTrackActors;
    
	// Debug
    Prop *mStageDebugToggle;
	Prop *mFpsView;
	SPTextField *mFpsText;
}

@property (nonatomic,readonly) BOOL isPerformanceSavingModeEnabled;
@property (nonatomic,readonly) Sea *sea;
@property (nonatomic,readonly) Prop *stageDebugToggle;
@property (nonatomic,retain) PlayerShip *playerShip;
@property (nonatomic,assign) uint beachState;

- (id)initWithController:(PlayfieldController *)controller;
- (void)enableSlowedTime:(BOOL)enable;
- (void)transitionFromMenu;
- (void)transitionToMenu;
- (void)createPlayerShip;
- (void)destroyPlayerShip;
- (void)enablePerformanceSavingMode:(BOOL)enable;
- (void)setPaused:(BOOL)isPaused;
- (void)displayHintByName:(NSString *)name x:(float)x y:(float)y radius:(float)radius target:(SPDisplayObject *)target exclusive:(BOOL)exclusive;
- (void)hideHintByName:(NSString *)name;
- (void)hideAllHints;
- (void)displayTutorialForKey:(NSString *)key fromPageIndex:(int)fromIndex toPageIndex:(int)toIndex;
- (void)dismissTutorial;
- (void)onTimeOfDayChangedEvent:(TimeOfDayChangedEvent *)event;
- (void)displayFirstMateAlert:(NSArray *)msgs userData:(int)userData dir:(int)dir afterDelay:(float)delay;
- (void)displayEtherealAlert:(NSArray *)msgs userData:(int)userData dir:(int)dir afterDelay:(float)delay;
- (void)enableWeather:(BOOL)enable;
- (void)enableCombatInterface:(BOOL)enable;
- (void)prepareForGameOver;
- (void)displayGameOverSequence;
- (void)displayGameSummary;
- (void)destroyGameSummary;
- (void)enableSummaryButton:(BOOL)enable forKey:(NSString *)key;
- (void)showTwitter;
- (void)hideTwitter;
- (void)travelBackInTime;
- (float)travelForwardInTime;
- (BOOL)isValidTutorialBookletPageIndex:(uint)pageIndex;
- (void)setComboDisplay:(uint)value;
- (void)showDayIntroForDay:(uint)day overTime:(float)duration;
- (void)hideDayIntroOverTime:(float)duration delay:(float)delay;
- (void)advanceFpsCounter:(double)time;

- (BOOL)isCoveOpen;

@end
