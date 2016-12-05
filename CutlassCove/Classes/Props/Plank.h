//
//  Plank.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 18/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"
#import "Loadable.h"

typedef enum {
    PlankStateInactive = 0,
    PlankStateActive,
    PlankStateDeadManWalking
} PlankState;

@class NumericValueChangedEvent,Prisoner,ShipDetails;

@interface Plank : Prop <Loadable> {
	BOOL mStateLocked;
	PlankState mState;
	
	BOOL mFlyingDutchman;
	SPTexture *mFlyingDutchmanTexture;
	
	Prisoner *mVictim;
	ShipDetails *mShipDetails;
	
	SPImage *mPlankImage;
	SPImage *mVictimImage;
	SPSprite *mVictimSprite;
	SPQuad *mTouchQuad;
}

@property (nonatomic,assign) PlankState state;
@property (nonatomic,readonly) Prisoner *victim;
@property (nonatomic,retain) ShipDetails *shipDetails;

- (id)initWithShipDetails:(ShipDetails *)shipDetails;
- (void)playVictimPushedSound;
- (void)onPrisonersChanged:(NumericValueChangedEvent *)event;
- (void)activateFlyingDutchman;
- (void)deactivateFlyingDutchman;

@end
