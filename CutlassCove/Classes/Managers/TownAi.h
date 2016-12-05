//
//  TownAi.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 12/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TownCannon,ShipActor,NumericValueChangedEvent,PlayfieldController,GameCoder;

@interface TownAi : NSObject {
    BOOL mSuspendedMode;
	float mAiModifier;
	uint mShotQueue;
    
    BOOL mThinking;
    double mThinkTimer;
    double mTimeSinceLastShot;
    
	NSMutableArray *mCannons;
	NSMutableArray *mTargets;
	NSMutableArray *mTracers;
	PlayfieldController *mScene;
}

@property (nonatomic,assign) float aiModifier;
@property (nonatomic,assign) double timeSinceLastShot;

- (id)initWithController:(PlayfieldController *)scene;
- (void)enableSuspendedMode:(BOOL)enable;
- (void)think;
- (void)stopThinking;
- (void)prepareForNewGame;
- (void)prepareForGameOver;
- (void)addCannon:(TownCannon *)cannon;
- (void)addTarget:(ShipActor *)target;
- (void)removeTarget:(ShipActor *)target;
- (void)onAiModifierChanged:(NumericValueChangedEvent *)event;
- (void)advanceTime:(double)time;

- (void)loadGameState:(GameCoder *)coder;
- (void)saveGameState:(GameCoder *)coder;

@end
