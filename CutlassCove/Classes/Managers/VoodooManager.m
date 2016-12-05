//
//  VoodooManager.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 13/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VoodooManager.h"
#import "GameStats.h"
#import "GameController.h"

#define GLOBAL_VOODOO_TIMEOUT 5.0f

typedef enum {
	VoodooStateCalm	= 0,
	VoodooStateBrandySlick,
	VoodooStatePowderKegs,
	VoodooStateNet,
	VoodooStateCamouflage,
	VoodooStateWhirlpool,
	VoodooStateTempest,
	VooodooStateDeathFromDeep,
	VoodooStateFlyingDutchman,
    VoodooStateSeaOfLava
} VoodooState;

@interface VoodooManager ()

- (void)createNewMenuWithTrinkets:(NSArray *)trinkets gadgets:(NSArray *)gadgets;
- (int)indexForKey:(uint)key;
- (uint)keyForIndex:(int)index;
- (void)activateVoodooIdolWithKey:(uint)key;
- (void)activateGadgetWithKey:(uint)key;
- (void)activateItemWithKey:(uint)key;
- (void)resetVoodooDurations;
- (void)onMenuClosePressed:(SPEvent *)event;
- (void)onPowderKegsActivated:(SPEvent *)event;
- (void)onNetActivated:(SPEvent *)event;
- (void)onBrandySlickActivated:(SPEvent *)event;
- (void)onTempestActivated:(SPEvent *)event;
- (void)onWhirlpoolActivated:(SPEvent *)event;
- (void)onDeathFromDeepActivated:(SPEvent *)event;
- (void)onCamouflageActivated:(SPEvent *)event;
- (void)onFlyingDutchmanActivated:(SPEvent *)event;
- (void)onSeaOfLavaActivated:(SPEvent *)event;
- (void)hookMenuButtons;
- (void)unhookMenuButtons;

@end


@implementation VoodooManager

@synthesize cooldownFactor = mCooldownFactor;

- (id)initWithCategory:(int)category trinkets:(NSArray *)trinkets gadgets:(NSArray *)gadgets {
	if (self = [super initWithCategory:category]) {
		mAdvanceable = YES;
		mHibernating = NO;
		mSuspendedMode = NO;
		mCooldownFactor = 1;
		mTrinkets = [trinkets retain];
		mGadgets = [gadgets retain];
		[self setupProp];
	}
	return self;
}

- (id)initWithCategory:(int)category {
	return [self initWithCategory:category trinkets:nil gadgets:nil];
}

- (void)setupProp {
	[self createNewMenuWithTrinkets:mTrinkets gadgets:mGadgets];
	[mScene addProp:mMenu];
}

- (void)createNewMenuWithTrinkets:(NSArray *)trinkets gadgets:(NSArray *)gadgets {
	if (mMenu != nil) {
		[self unhookMenuButtons];
		[mScene removeProp:mMenu];
        [mMenu removeEventListener:@selector(onMenuClosePressed:) atObject:self forType:CUST_EVENT_TYPE_VOODOO_MENU_CLOSING];
		[mMenu destroyWheel];
		[mMenu autorelease];
		mMenu = nil;
	}
	mMenu = [[VoodooWheel alloc] initWithCategory:CAT_PF_DECK trinkets:trinkets gadgets:gadgets];
    [mMenu addEventListener:@selector(onMenuClosePressed:) atObject:self forType:CUST_EVENT_TYPE_VOODOO_MENU_CLOSING];
	[self hookMenuButtons];
    
    if (mScene.flipped)
        [mMenu flip:YES];
}

- (void)enableSuspendedMode:(BOOL)enable {
	if (enable == YES) {
		[self unhookMenuButtons];
		[self hideMenu];
	} else {
		[self hookMenuButtons];
	}
	mSuspendedMode = enable;
}

- (void)flip:(BOOL)enable {
    [mMenu flip:enable];
}

- (void)onMenuClosePressed:(SPEvent *)event {
    [self hideMenu];
}

- (void)activatePowderKegs {
	[self activateGadgetWithKey:GADGET_SPELL_TNT_BARRELS];
}

- (void)onPowderKegsActivated:(SPEvent *)event {
	[self activatePowderKegs];
}

- (void)activateNet {
	[self activateGadgetWithKey:GADGET_SPELL_NET];
}

- (void)onNetActivated:(SPEvent *)event {
	[self activateNet];
}

- (void)activateBrandySlick {
	[self activateGadgetWithKey:GADGET_SPELL_BRANDY_SLICK];
}

- (void)onBrandySlickActivated:(SPEvent *)event {
	[self activateBrandySlick];
}

- (void)activateTempest {
	[self activateVoodooIdolWithKey:VOODOO_SPELL_TEMPEST];
}

- (void)onTempestActivated:(SPEvent *)event {
	[self activateTempest];
}

- (void)activateWhirlpool {
	[self activateVoodooIdolWithKey:VOODOO_SPELL_WHIRLPOOL];
}

- (void)onWhirlpoolActivated:(SPEvent *)event {
	[self activateWhirlpool];
}

- (void)activateDeathFromDeep {
	[self activateVoodooIdolWithKey:VOODOO_SPELL_DEATH_FROM_DEEP];
}

- (void)onDeathFromDeepActivated:(SPEvent *)event {
	[self activateDeathFromDeep];
}

- (void)activateCamouflage {
	[self activateGadgetWithKey:GADGET_SPELL_CAMOUFLAGE];
}

- (void)onCamouflageActivated:(SPEvent *)event {
	[self activateCamouflage];
}

- (void)activateFlyingDutchman {
	[self activateVoodooIdolWithKey:VOODOO_SPELL_FLYING_DUTCHMAN];
}

- (void)onFlyingDutchmanActivated:(SPEvent *)event {
	[self activateFlyingDutchman];
}

- (void)activateSeaOfLava {
	[self activateVoodooIdolWithKey:VOODOO_SPELL_SEA_OF_LAVA];
}

- (void)onSeaOfLavaActivated:(SPEvent *)event {
    [self activateSeaOfLava];
}

- (BOOL)voodooActive:(uint)voodooID {
	BOOL active = NO;
	
	switch (voodooID) {
		case GADGET_SPELL_BRANDY_SLICK: active = mDurations[0].active; break;
		case GADGET_SPELL_TNT_BARRELS: active = mDurations[1].active; break;
		case GADGET_SPELL_NET: active = mDurations[2].active; break;
		case GADGET_SPELL_CAMOUFLAGE: active = mDurations[3].active; break;
		case VOODOO_SPELL_WHIRLPOOL: active = mDurations[4].active; break;
		case VOODOO_SPELL_TEMPEST: active = mDurations[5].active; break;
		case VOODOO_SPELL_DEATH_FROM_DEEP: active = mDurations[6].active; break;
		case VOODOO_SPELL_FLYING_DUTCHMAN: active = mDurations[7].active; break;
        case VOODOO_SPELL_SEA_OF_LAVA: active = mDurations[8].active; break;
		default: assert(0); break;
	}
	
	return active;
}

- (void)setVoodooActive:(uint)voodooID duration:(float)duration {
	int index = -1;
	
	switch (voodooID) {
		case GADGET_SPELL_BRANDY_SLICK: index = 0; break;
		case GADGET_SPELL_TNT_BARRELS: index = 1; break;
		case GADGET_SPELL_NET: index = 2; break;
		case GADGET_SPELL_CAMOUFLAGE: index = 3; break;
		case VOODOO_SPELL_WHIRLPOOL: index = 4; break;
		case VOODOO_SPELL_TEMPEST: index = 5; break;
		case VOODOO_SPELL_DEATH_FROM_DEEP: index = 6; break;
		case VOODOO_SPELL_FLYING_DUTCHMAN: index = 7; break;
        case VOODOO_SPELL_SEA_OF_LAVA: index = 8; break;
		default: assert(0); break;
	}
	
	assert(index >= 0 && index < IDOL_KEY_COUNT);
	mDurations[index].active = YES;
	mDurations[index].durationRemaining = duration;
}

- (double)durationRemainingForID:(uint)voodooID {
	double durationRemaining = 0;
	
	switch (voodooID) {
		case GADGET_SPELL_BRANDY_SLICK: durationRemaining = mDurations[0].durationRemaining; break;
		case GADGET_SPELL_TNT_BARRELS: durationRemaining = mDurations[1].durationRemaining; break;
		case GADGET_SPELL_NET: durationRemaining = mDurations[2].durationRemaining; break;
		case GADGET_SPELL_CAMOUFLAGE: durationRemaining = mDurations[3].durationRemaining; break;
		case VOODOO_SPELL_WHIRLPOOL: durationRemaining = mDurations[4].durationRemaining; break;
		case VOODOO_SPELL_TEMPEST: durationRemaining = mDurations[5].durationRemaining; break;
		case VOODOO_SPELL_DEATH_FROM_DEEP: durationRemaining = mDurations[6].durationRemaining; break;
		case VOODOO_SPELL_FLYING_DUTCHMAN: durationRemaining = mDurations[7].durationRemaining; break;
        case VOODOO_SPELL_SEA_OF_LAVA: durationRemaining = mDurations[8].durationRemaining; break;
		default: assert(0); break;
	}
	
	return durationRemaining;
}

- (void)resetVoodooDurations {
	for (int i = 0; i < IDOL_KEY_COUNT; ++i) {
		mDurations[i].active = NO;
		mDurations[i].durationRemaining = 0;
	}
}

- (void)prepareForNewGame {
	[mScene removeProp:mMenu];
	[self createNewMenuWithTrinkets:mTrinkets gadgets:mGadgets];
	[mScene addProp:mMenu];
	[self resetVoodooDurations];
	mHibernating = NO;
}

- (void)prepareForGameOver {
	if (mHibernating == YES)
		return;
	[mScene removeProp:mMenu];
	mMenu.visible = NO;
	mHibernating = YES;
}

- (int)indexForKey:(uint)key {
	int index = -1;
	
	switch (key) {
		case GADGET_SPELL_BRANDY_SLICK: index = 0; break;
		case GADGET_SPELL_TNT_BARRELS: index = 1; break;
		case GADGET_SPELL_NET: index = 2; break;
		case GADGET_SPELL_CAMOUFLAGE: index = 3; break;
		case VOODOO_SPELL_WHIRLPOOL: index = 4; break;
		case VOODOO_SPELL_TEMPEST: index = 5; break;
		case VOODOO_SPELL_DEATH_FROM_DEEP: index = 6; break;
		case VOODOO_SPELL_FLYING_DUTCHMAN: index = 7; break;
        case VOODOO_SPELL_SEA_OF_LAVA: index = 8; break;
	}
	return index;
}

- (uint)keyForIndex:(int)index {
    uint key = 0;
	
	switch (index) {
        case 0: key = GADGET_SPELL_BRANDY_SLICK; break;
        case 1: key = GADGET_SPELL_TNT_BARRELS; break;
        case 2: key = GADGET_SPELL_NET; break;
        case 3: key = GADGET_SPELL_CAMOUFLAGE; break;
        case 4: key = VOODOO_SPELL_WHIRLPOOL; break;
        case 5: key = VOODOO_SPELL_TEMPEST; break;
        case 6: key = VOODOO_SPELL_DEATH_FROM_DEEP; break;
        case 7: key = VOODOO_SPELL_FLYING_DUTCHMAN; break;
        case 8: key = VOODOO_SPELL_SEA_OF_LAVA; break;
	}
	return key;
}

- (void)activateVoodooIdolWithKey:(uint)key {
	int index = [self indexForKey:key];
	
	if (index != -1 && mDurations[index].active == NO)
		[self activateItemWithKey:key];
}

- (void)activateGadgetWithKey:(uint)key {
	[self activateItemWithKey:key];
}

- (void)activateItemWithKey:(uint)key {
	NSString *eventKey = nil;
	//double cooldown = 0;
	int index = [self indexForKey:key];
	
	assert(index != -1);
	
	//Enhancements *enhancements = mScene.enhancements;
	Idol *idol = [mScene idolForKey:key];
	double idolDuration = [Idol durationForIdol:idol];
	//cooldown = [Idol cooldownDurationForIdol:idol];
	
	switch (key) {
		case GADGET_SPELL_BRANDY_SLICK:
			mDurations[index].active = YES;
            mDurations[index].durationRemaining = idolDuration;
			//mDurations[index].durationRemaining = idolDuration * [enhancements functionalFactorForEnhancement:ENHANCE_DEN_ONE_FOR_THE_ROAD byCategory:ENHANCE_CAT_DEN];
			eventKey = CUST_EVENT_TYPE_BRANDY_SLICK_DEPLOYED;
			break;
		case GADGET_SPELL_TNT_BARRELS:
			eventKey = CUST_EVENT_TYPE_POWDER_KEG_DROPPING;
			break;
		case GADGET_SPELL_NET:
			mDurations[index].active = YES;
			mDurations[index].durationRemaining = idolDuration;
			eventKey = CUST_EVENT_TYPE_NET_DEPLOYED;
			break;
		case GADGET_SPELL_CAMOUFLAGE:
			mDurations[index].active = YES;
			mDurations[index].durationRemaining = idolDuration;
			eventKey = CUST_EVENT_TYPE_CAMOUFLAGE_ACTIVATED;
			break;
		case VOODOO_SPELL_WHIRLPOOL:
			mDurations[index].active = YES;
            mDurations[index].durationRemaining = idolDuration;
			//mDurations[index].durationRemaining = idolDuration; * [enhancements functionalFactorForEnhancement:ENHANCE_HAUNT_ABYSSAL_MAW byCategory:ENHANCE_CAT_HAUNT];
			eventKey = CUST_EVENT_TYPE_WHIRLPOOL_SUMMONED;
			break;
		case VOODOO_SPELL_TEMPEST:
			mDurations[index].active = YES;
			mDurations[index].durationRemaining = idolDuration;
			eventKey = CUST_EVENT_TYPE_TEMPEST_SUMMONED;
			break;
		case VOODOO_SPELL_DEATH_FROM_DEEP:
			mDurations[index].active = YES;
			mDurations[index].durationRemaining = idolDuration;
			eventKey = CUST_EVENT_TYPE_DEATH_FROM_DEEP_SUMMONED;
			break;
		case VOODOO_SPELL_FLYING_DUTCHMAN:
			mDurations[index].active = YES;
			mDurations[index].durationRemaining = idolDuration;
			eventKey = CUST_EVENT_TYPE_FLYING_DUTCHMAN_ACTIVATED;
			break;
        case VOODOO_SPELL_SEA_OF_LAVA:
            mDurations[index].active = YES;
			mDurations[index].durationRemaining = idolDuration;
			eventKey = CUST_EVENT_TYPE_SEA_OF_LAVA_SUMMONED;
            break;
		default:
			return;
	}
	
	//cooldown *= mCooldownFactor;
	
	//GameController *gc = [GameController GC];
	//[gc.gameStats setVoodooCooldown:cooldown key:key];
	//[gc.gameStats setAllVoodooCooldowns:GLOBAL_VOODOO_TIMEOUT];
    [mMenu enableItem:NO forKey:key];
    
    if ([Idol isMunition:key])
        [mScene.objectivesManager progressObjectiveWithEventType:OBJ_TYPE_MUNITION_USED tag:key];
    else if ([Idol isSpell:key])
        [mScene.objectivesManager progressObjectiveWithEventType:OBJ_TYPE_SPELL_USED tag:key];
    
	//[self refreshCooldowns];
	[self dispatchEvent:[SPEvent eventWithType:eventKey]];
}

- (void)advanceTime:(double)time {
	if (mHibernating == YES)
		return;
	for (int i = 0; i < IDOL_KEY_COUNT; ++i) {
		if (mDurations[i].active == YES) {
			mDurations[i].durationRemaining = MAX(0, mDurations[i].durationRemaining - time);
			
			if (SP_IS_FLOAT_EQUAL(0, mDurations[i].durationRemaining))
				mDurations[i].active = NO;
		}
	}
	
	//[GCTRL.gameStats advanceVoodooCooldowns:time];
}

- (void)bubbleMenuToTop {
    [mScene removeProp:mMenu];
    [mScene addProp:mMenu];
}

- (void)showMenu {
	[self showMenuAtX:mScene.viewWidth / 2 y:mScene.viewHeight / 2];
}

- (void)showMenuAtX:(float)x y:(float)y {
	[mMenu showAtX:x y:y];
}

- (void)hideMenu {
	[mMenu hide];
    [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_VOODOO_MENU_CLOSING]];
}

- (void)hookMenuButtons {
	if (mMenu == nil)
		return;

	VoodooDial *dial = [mMenu dialForKey:GADGET_SPELL_TNT_BARRELS];
	[dial addEventListener:@selector(onPowderKegsActivated:) atObject:self forType:CUST_EVENT_TYPE_VOODOO_DIAL_PRESSED];
	
	dial = [mMenu dialForKey:GADGET_SPELL_NET];
	[dial addEventListener:@selector(onNetActivated:) atObject:self forType:CUST_EVENT_TYPE_VOODOO_DIAL_PRESSED];
	
	dial = [mMenu dialForKey:GADGET_SPELL_BRANDY_SLICK];
	[dial addEventListener:@selector(onBrandySlickActivated:) atObject:self forType:CUST_EVENT_TYPE_VOODOO_DIAL_PRESSED];
	
	dial = [mMenu dialForKey:VOODOO_SPELL_TEMPEST];
	[dial addEventListener:@selector(onTempestActivated:) atObject:self forType:CUST_EVENT_TYPE_VOODOO_DIAL_PRESSED];
	
	dial = [mMenu dialForKey:VOODOO_SPELL_WHIRLPOOL];
	[dial addEventListener:@selector(onWhirlpoolActivated:) atObject:self forType:CUST_EVENT_TYPE_VOODOO_DIAL_PRESSED];
	
	dial = [mMenu dialForKey:VOODOO_SPELL_DEATH_FROM_DEEP];
	[dial addEventListener:@selector(onDeathFromDeepActivated:) atObject:self forType:CUST_EVENT_TYPE_VOODOO_DIAL_PRESSED];
	
	dial = [mMenu dialForKey:GADGET_SPELL_CAMOUFLAGE];
	[dial addEventListener:@selector(onCamouflageActivated:) atObject:self forType:CUST_EVENT_TYPE_VOODOO_DIAL_PRESSED];
	
	dial = [mMenu dialForKey:VOODOO_SPELL_FLYING_DUTCHMAN];
	[dial addEventListener:@selector(onFlyingDutchmanActivated:) atObject:self forType:CUST_EVENT_TYPE_VOODOO_DIAL_PRESSED];
    
    dial = [mMenu dialForKey:VOODOO_SPELL_SEA_OF_LAVA];
	[dial addEventListener:@selector(onSeaOfLavaActivated:) atObject:self forType:CUST_EVENT_TYPE_VOODOO_DIAL_PRESSED];
}

- (void)unhookMenuButtons {
	if (mMenu == nil)
		return;

	VoodooDial *dial = [mMenu dialForKey:GADGET_SPELL_TNT_BARRELS];
	[dial removeEventListener:@selector(onPowderKegsActivated:) atObject:self forType:CUST_EVENT_TYPE_VOODOO_DIAL_PRESSED];
	
	dial = [mMenu dialForKey:GADGET_SPELL_NET];
	[dial removeEventListener:@selector(onNetActivated:) atObject:self forType:CUST_EVENT_TYPE_VOODOO_DIAL_PRESSED];
	
	dial = [mMenu dialForKey:GADGET_SPELL_BRANDY_SLICK];
	[dial removeEventListener:@selector(onBrandySlickActivated:) atObject:self forType:CUST_EVENT_TYPE_VOODOO_DIAL_PRESSED];
	
	dial = [mMenu dialForKey:VOODOO_SPELL_TEMPEST];
	[dial removeEventListener:@selector(onTempestActivated:) atObject:self forType:CUST_EVENT_TYPE_VOODOO_DIAL_PRESSED];
	
	dial = [mMenu dialForKey:VOODOO_SPELL_WHIRLPOOL];
	[dial removeEventListener:@selector(onWhirlpoolActivated:) atObject:self forType:CUST_EVENT_TYPE_VOODOO_DIAL_PRESSED];
	
	dial = [mMenu dialForKey:VOODOO_SPELL_DEATH_FROM_DEEP];
	[dial removeEventListener:@selector(onDeathFromDeepActivated:) atObject:self forType:CUST_EVENT_TYPE_VOODOO_DIAL_PRESSED];
	
	dial = [mMenu dialForKey:GADGET_SPELL_CAMOUFLAGE];
	[dial removeEventListener:@selector(onCamouflageActivated:) atObject:self forType:CUST_EVENT_TYPE_VOODOO_DIAL_PRESSED];
	
	dial = [mMenu dialForKey:VOODOO_SPELL_FLYING_DUTCHMAN];
	[dial removeEventListener:@selector(onFlyingDutchmanActivated:) atObject:self forType:CUST_EVENT_TYPE_VOODOO_DIAL_PRESSED];
    
    dial = [mMenu dialForKey:VOODOO_SPELL_SEA_OF_LAVA];
	[dial removeEventListener:@selector(onSeaOfLavaActivated:) atObject:self forType:CUST_EVENT_TYPE_VOODOO_DIAL_PRESSED];
}

- (void)dealloc {
	[mScene removeProp:mMenu];
	
	[self unhookMenuButtons];
    [mMenu removeEventListener:@selector(onMenuClosePressed:) atObject:self forType:CUST_EVENT_TYPE_VOODOO_MENU_CLOSING];
	[mMenu destroyWheel];
	[mMenu release]; mMenu = nil;
	[mTrinkets release]; mTrinkets = nil;
	[mGadgets release]; mGadgets = nil;
	[super dealloc];
}

@end

