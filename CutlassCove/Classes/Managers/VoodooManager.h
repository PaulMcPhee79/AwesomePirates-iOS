//
//  VoodooManager.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 13/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"
#import "VoodooWheel.h"
#import "Globals.h"

#define CUST_EVENT_TYPE_POWDER_KEG_DROPPING @"powderKegDroppingEvent"
#define CUST_EVENT_TYPE_NET_DEPLOYED @"netDeployedEvent"
#define CUST_EVENT_TYPE_BRANDY_SLICK_DEPLOYED @"brandySlickDeployedEvent"
#define CUST_EVENT_TYPE_TEMPEST_SUMMONED @"tempestSummonedEvent"
#define CUST_EVENT_TYPE_WHIRLPOOL_SUMMONED @"whirlpoolSummonedEvent"
#define CUST_EVENT_TYPE_DEATH_FROM_DEEP_SUMMONED @"deathFromDeepSummonedEvent"
#define CUST_EVENT_TYPE_CAMOUFLAGE_ACTIVATED @"camouflageActivatedEvent"
#define CUST_EVENT_TYPE_FLYING_DUTCHMAN_ACTIVATED @"flyingDutchmanActivatedEvent"
#define CUST_EVENT_TYPE_SEA_OF_LAVA_SUMMONED @"seaOfLavaSummonedEvent"

typedef struct {
	BOOL active;
	double durationRemaining;
} VoodooDuration;


@class VoodooWheel;

@interface VoodooManager : Prop {
	BOOL mHibernating;
	BOOL mSuspendedMode;
	float mCooldownFactor;
	VoodooDuration mDurations[IDOL_KEY_COUNT];
	
	VoodooWheel *mMenu;
	NSArray *mTrinkets;
	NSArray *mGadgets;
}

@property (nonatomic,assign) float cooldownFactor;

- (id)initWithCategory:(int)category trinkets:(NSArray *)trinkets gadgets:(NSArray *)gadgets;
- (void)bubbleMenuToTop;
- (void)showMenu;
- (void)showMenuAtX:(float)x y:(float)y;
- (void)hideMenu;
- (void)enableSuspendedMode:(BOOL)enable;
- (void)prepareForNewGame;
- (void)prepareForGameOver;
- (BOOL)voodooActive:(uint)voodooID;
- (void)setVoodooActive:(uint)voodooID duration:(float)duration;
- (double)durationRemainingForID:(uint)voodooID;

- (void)activatePowderKegs;
- (void)activateNet;
- (void)activateBrandySlick;
- (void)activateTempest;
- (void)activateWhirlpool;
- (void)activateDeathFromDeep;
- (void)activateCamouflage;
- (void)activateFlyingDutchman;
- (void)activateSeaOfLava;

@end
