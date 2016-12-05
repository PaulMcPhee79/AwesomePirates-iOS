//
//  ShipDeck.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 4/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Helm.h"
#import "Plank.h"
#import "PlayerCannon.h"
#import "ComboDisplay.h"
#import "Prop.h"
#import "Loadable.h"

#define CUST_EVENT_TYPE_DECK_VOODOO_IDOL_PRESSED @"deckVoodooIdolPressed"
#define CUST_EVENT_TYPE_DECK_TWITTER_BUTTON_PRESSED @"twitterButtonPressed"

@class DashDial;

@interface ShipDeck : Prop <Loadable> {
	BOOL mFlyingDutchman;
    BOOL mTwitterEnabled;
	SPImage *mRailing;
    SPImage *mSpeedboatRailing;
    
    SPTexture *mFlyingDutchmanVoodooTexture;
	SPTexture *mFlyingDutchmanRailingTexture;
    
	Helm *mHelm;
	Plank *mPlank;
    SPSprite *mVoodooPlankContainer;
	PlayerCannon *mRightCannon;
	PlayerCannon *mLeftCannon;
    SPSprite *mCannonContainer;
	ComboDisplay *mComboDisplay;
    SPSprite *mPotion;
    
    SPButton *mVoodooIdol;
    SPButton *mTwitterButton;
    
    SPSprite *mVoodooSprite;
    SPSprite *mTwitterSprite;
	
	DashDial *mTimeDial;
	DashDial *mSpeedDial;
	DashDial *mLapDial;
}

@property (nonatomic,readonly) BOOL raceEnabled;
@property (nonatomic,readonly) SPButton *voodooIdol;
@property (nonatomic,retain) Helm *helm;
@property (nonatomic,retain) Plank *plank;
@property (nonatomic,retain) PlayerCannon *rightCannon;
@property (nonatomic,retain) PlayerCannon *leftCannon;
@property (nonatomic,retain) ComboDisplay *comboDisplay;

- (id)initWithCategory:(int)category shipDetails:(ShipDetails *)shipDetails;
- (void)setHidden:(BOOL)hidden;
- (void)extendOverTime:(float)duration;
- (void)retractOverTime:(float)duration;
- (PlayerCannon *)cannonOnSide:(int)side;
- (int)sideForCannon:(PlayerCannon *)cannon;
- (void)activateFlyingDutchman;
- (void)deactivateFlyingDutchman;
- (void)setupPotions;
- (void)destroyPotions;
- (void)enableCombatControls:(BOOL)enable;

- (void)showTwitterOverTime:(float)duration;
- (void)hideTwitterOverTime:(float)duration;

- (void)showFlipControlsButton:(BOOL)show;

- (void)activateSpeedboatWithDialDefs:(NSArray *)dialDefs;
- (void)deactivateSpeedboat;
- (void)setRaceTime:(NSString *)text;
- (void)setLapTime:(NSString *)text;
- (void)setMph:(NSString *)text;
- (void)setLap:(NSString *)text;
- (void)flashFailedMphDial;
- (void)travelForwardInTime;

@end
