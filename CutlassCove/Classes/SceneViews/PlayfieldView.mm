//
//  PlayfieldView.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 5/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "PlayfieldView.h"
#import "Sea.h"
#import "Wave.h"
#import "ShipDeck.h"
#import "ShipDetails.h"
#import "PlayerShip.h"
#import "AshProc.h"
#import "NpcShip.h"
#import "ShipFactory.h"
#import "CannonFactory.h"
#import "BeachActor.h"
#import "TownActor.h"
#import "Hud.h"
#import "PlayerDetails.h"
#import "StaticFactory.h"
#import "ActorFactory.h"
#import "TownCannon.h"
#import "TownAi.h"
#import "TownDock.h"
#import "ActorAi.h"
#import "Plank.h"
#import "Helm.h"
#import "Weather.h"
#import "VoodooManager.h"
#import "GameSummary.h"
#import "SpeedboatSummary.h"
#import "AchievementManager.h"
#import "RaceTrackActor.h"
#import "Racer.h"
#import "FirstMate.h"
#import "TutorialBooklet.h"
#import "HintHelper.h"
#import "GuiHelper.h"
#import "CCMiscConstants.h"
#import "GameSettings.h"
#import "GameController.h"
#import "Globals.h"

#import "PlayfieldController.h"
#import "NumericValueChangedEvent.h"
#import "NumericRatioChangedEvent.h"
#import "ActorDef.h"

#import "Actor.h"
#import "Prop.h"
#import "FutureManager.h"


@interface PlayfieldView ()


- (void)onPlankedVictimsIncreased:(SPEvent *)event;


- (void)createTestBody;
- (void)createSea;
- (TutorialBooklet *)loadTutorialBookletForKey:(NSString *)key fromIndex:(int)fromIndex toPageIndex:(int)toIndex;
- (void)showFps:(double)time;
- (void)destroyHints;
- (void)displayHelpAlert:(NSArray *)msgs textureName:(NSString *)textureName userData:(int)userData dir:(int)dir afterDelay:(float)delay;
- (void)applyTutorialFlipConstraints:(BOOL)isFlipped;
- (void)onBookletPageTurned:(SPEvent *)event;
- (void)onTutorialCompleted:(SPEvent *)event;
- (void)onOFChallengeHintFaded:(SPEvent *)event;
- (void)destroyDayIntroOverTime:(float)duration;
- (void)onDayIntroHidden:(SPEvent *)event;
- (void)fadeInRaceTrack:(RaceTrackActor *)raceTrack overTime:(float)duration delay:(float)delay;
- (void)fadeOutRaceTrack:(RaceTrackActor *)raceTrack overTime:(float)duration delay:(float)delay juggler:(SPJuggler *)juggler;
- (void)onRaceTrackFadedOut:(SPEvent *)event;
- (void)destroyRaceTrack;

@end


@implementation PlayfieldView

@synthesize isPerformanceSavingModeEnabled = mPerformanceSavingMode;
@synthesize sea = mSea;
@synthesize stageDebugToggle = mStageDebugToggle;
@synthesize playerShip = mPlayerShip;
@dynamic beachState;


- (void)onPlankedVictimsIncreased:(SPEvent *)event {
/*
    GameController *gc = GCTRL;
    
    if (gc.timeOfDay < DuskTransition) {
        ++gc.thisTurn.numPlankedVictimsToday;
        [mHud setMiscValue:(int)gc.thisTurn.numPlankedVictimsToday];
    }
*/
}

- (id)initWithController:(PlayfieldController *)controller {
	if (self = [super init]) {
		//[Prop printProps];
		mController = controller;
        mPerformanceSavingMode = NO;
        mInFuture = NO;
        mDayIntro = nil;
        mGameSummary = nil;
        mHints = nil;
        mTutorialBooklet = nil;
		mStageDebugToggle = nil;
		mFpsView = nil;
		mFpsText = nil;
        mFutureManager = nil;
        mTimeTravelJuggler = nil;
        mHintsGarbage = [[NSMutableArray alloc] init];
		
        if ([SPTextField bitmapFontForKey:mController.fontKey] == nil) {
            [SPTextField registerBitmapFontFromFile:@"CheekyMammoth.fnt" texture:[mController textureByName:BITMAP_FONT_NAME atlasName:@"Font"]]; //atlasName:mController.sceneKey]];
            [SPTextField alterRegisteredFontKeyFrom:BITMAP_FONT_NAME toKey:mController.fontKey];
        }
		
		[self createSea];
        
        // Ship Deck
        GameController *gc = GCTRL;
        ShipDetails *shipDetails = gc.playerDetails.shipDetails;
        mShipDeck = [[ShipDeck alloc] initWithCategory:CAT_PF_DECK shipDetails:shipDetails];
        NSDictionary *dictionary = [Globals loadPlist:@"Decks"];
        NSString *shipKey = shipDetails.type;
        
        //NSLog(@"------>>>>>ShipKey: %@", shipKey);
        
        NSArray *keys = [NSArray arrayWithObjects:shipKey, shipKey, shipKey, @"RightCannon", @"LeftCannon", shipKey, nil];
        
        // Deck
        [mShipDeck loadFromDictionary:dictionary withKeys:keys];
        [mController addProp:mShipDeck];
        
        // Events
        [mShipDeck addEventListener:@selector(onDeckVoodooIdolPressed:) atObject:mController forType:CUST_EVENT_TYPE_DECK_VOODOO_IDOL_PRESSED];
        [mShipDeck addEventListener:@selector(onDeckTwitterActivated:) atObject:mController forType:CUST_EVENT_TYPE_DECK_TWITTER_BUTTON_PRESSED];
        [gc.achievementManager addEventListener:@selector(onComboMultiplierChanged:) atObject:mShipDeck.comboDisplay forType:CUST_EVENT_TYPE_COMBO_MULTIPLIER_CHANGED];
		
		// Achievement View
		mAchievementPanel = [[AchievementPanel alloc] initWithCategory:CAT_PF_BUILDINGS];
		mController.achievementManager.view = mAchievementPanel;
		//[mController addProp:mAchievementPanel];
		
		// Beach (needs to be added before PlayerCannons so that aiming reticles appear above cove)
		StaticFactory *staticFactory = [StaticFactory staticFactory];
		ActorDef *actorDef = [staticFactory createBeachActorDef];
		mBeach = [[BeachActor alloc] initWithActorDef:actorDef];
		delete actorDef;
		actorDef = 0;
		mBeach.category = CAT_PF_LAND;
		[mBeach setupBeach];
		[mController addActor:mBeach];
		mBeach.coveEnabled = YES;
		
        // Town (needs to be added before PlayerCannons so that aiming reticles appear above town house and cannon fixtures)
		actorDef = [staticFactory createTownActorDef];
		mTown = [[TownActor alloc] initWithActorDef:actorDef];
		delete actorDef;
		actorDef = 0;
		[mTown setupTown];
		[mController addActor:mTown];
		
		// Town Dock
		actorDef = [[ActorFactory juilliard] createTownDockDefinitionAtX:P2MX(-104.f) y:P2MY(-104.0f) angle:0];
		mTownDock = [[TownDock alloc] initWithActorDef:actorDef];
		delete actorDef;
		actorDef = 0;
		[mController addActor:mTownDock];
		
		// Town Ai
		TownAi *townAi = mController.guvnor;
		[townAi addCannon:mTown.leftCannon];
		[townAi addCannon:mTown.rightCannon];
		
		// Weather
        if (RESM.isLowPerformance == NO) {
            mWeather = [[Weather alloc] initWithCategory:CAT_PF_CLOUDS cloudCount:4];
            mWeather.cloudAlpha = 0.6f;
        }
		

		// Debug stuff
        
//		mFpsView = [[Prop alloc] initWithCategory:CAT_PF_HUD];
//		mFpsText = [[SPTextField alloc] initWithWidth:32 height:22.0f 
//						text:@"" fontName:mController.fontKey fontSize:20.0f color:0xfcff1b];
//		mFpsText.x = 10.0f;
//		mFpsText.y = 5.0f;
//		mFpsText.hAlign = SPHAlignLeft;
//		mFpsText.vAlign = SPVAlignCenter;
//        mFpsText.compiled = NO;
//		[mFpsView addChild:mFpsText];
//		[mController addProp:mFpsView];
        
        
#ifdef CHEEKY_DEBUG
		/*
		mStageDebugToggle = [[Prop alloc] initWithCategory:CAT_PF_HUD];
		mStageDebugToggle.touchable = YES;
		SPQuad *quad = [SPQuad quadWithWidth:50.0f height:50.0f];
		//quad.color = SP_WHITE;
		quad.alpha = 0.0f;
		[mStageDebugToggle addChild:quad];
		[mController addProp:mStageDebugToggle];
		[mStageDebugToggle addEventListener:@selector(onStageDebugTouched:) atObject:mController forType:SP_EVENT_TYPE_TOUCH];
         */
		 
#endif
#ifdef DEBUG_AUTOMATOR		
		[[mController.juggler delayInvocationAtTarget:mPlayerShip byTime:1] automatorFireCannons];
		[[mController.juggler delayInvocationAtTarget:mPlayerShip byTime:3] automatorFireCannons];
		[[mController.juggler delayInvocationAtTarget:mPlayerShip byTime:5] automatorFireCannons];
		[[mController.juggler delayInvocationAtTarget:mPlayerShip byTime:7] automatorFireCannons];
		[[mController.juggler delayInvocationAtTarget:mPlayerShip byTime:9] automatorFireCannons];
		[[mController.juggler delayInvocationAtTarget:mPlayerShip byTime:11] automatorFireCannons];
		[[mController.juggler delayInvocationAtTarget:[GameController GC] byTime:12] setState:StateCove];
#endif
	}
	return self;
}

- (id)init {
	return [self initWithController:nil];
}

- (void)flip:(BOOL)enable {
    float flipScaleX = (enable) ? -1 : 1;
    
    mDayIntro.scaleX = flipScaleX;
    
    for (NSString *key in mHints) {
        MenuDetailView *hint = [mHints objectForKey:key];
        [hint flip:enable];
    }
    
    [self applyTutorialFlipConstraints:enable];
}

- (void)enableSlowedTime:(BOOL)enable {
    [mSea enableSlowedTime:enable];
    [mShipDeck enableCombatControls:!enable];
}

- (void)transitionFromMenu {
    GameController *gc = GCTRL;
    
    // Achievement Panel
    [self moveAchievementPanelToCategory:CAT_PF_BUILDINGS];
    
    // Ship Deck
    ShipDetails *shipDetails = gc.playerDetails.shipDetails;
    [shipDetails removeEventListener:@selector(onPrisonersChanged:) atObject:mShipDeck.plank forType:CUST_EVENT_TYPE_PRISONERS_VALUE_CHANGED];
    [shipDetails removeEventListener:@selector(onPrisonersChanged:) atObject:mController forType:CUST_EVENT_TYPE_PRISONERS_VALUE_CHANGED];
    
	[shipDetails addEventListener:@selector(onPrisonersChanged:) atObject:mShipDeck.plank forType:CUST_EVENT_TYPE_PRISONERS_VALUE_CHANGED];
    [shipDetails addEventListener:@selector(onPrisonersChanged:) atObject:mController forType:CUST_EVENT_TYPE_PRISONERS_VALUE_CHANGED];
    
    mShipDeck.plank.shipDetails = shipDetails;
    [mShipDeck.comboDisplay deactivateProc];
    [mShipDeck deactivateFlyingDutchman];
    [mShipDeck setupPotions];
    [mShipDeck.helm resetRotation];
    [mShipDeck extendOverTime:0.5f];
    [self hideTwitter];
    
    if (mInFuture)
        [self travelBackInTime];
    
    // Race Track
    if (mController.raceEnabled) {
        NSDictionary *raceTrackDictionary = [Globals loadPlist:@"RaceTrack"];
        
        if (mRaceTrack == nil) {
            int laps = 5;
            ActorDef *actorDef = [[ActorFactory juilliard] createRaceTrackDefWithDictionary:raceTrackDictionary];
            mRaceTrack = [[RaceTrackActor alloc] initWithActorDef:actorDef laps:laps];
            mRaceTrack.alpha = 0;
            [mRaceTrack setupRaceTrackWithDictionary:raceTrackDictionary];
            [mRaceTrack addEventListener:@selector(onRaceFinished:) atObject:mController forType:CUST_EVENT_TYPE_RACE_FINISHED];
            [mRaceTrack addEventListener:@selector(onRaceTrackConquered:) atObject:mController forType:CUST_EVENT_TYPE_88MPH];
            [mRaceTrack addEventListener:@selector(onSpeedDemonAchieved:) atObject:mController forType:CUST_EVENT_TYPE_SPEED_DEMON];
            [mController addActor:mRaceTrack];
            delete actorDef;
            actorDef = 0;
        }
        
        [mRaceTrack prepareForNewRace];
        [self fadeInRaceTrack:mRaceTrack overTime:2.0f delay:0];
        
        [mShipDeck activateSpeedboatWithDialDefs:(NSArray *)[raceTrackDictionary objectForKey:@"DashDials"]];
    } else {
        if (mRaceTrack) {
            [self fadeOutRaceTrack:mRaceTrack overTime:2.0f delay:0 juggler:mController.juggler];
            [self destroyRaceTrack];
        }
        
        if (mShipDeck.raceEnabled)
            [mShipDeck deactivateSpeedboat];
    }
    
    // Sea
    [mSea prepareForNewGame];
    
    // HUD
    mHud = [[Hud alloc] initWithCategory:CAT_PF_SURFACE textColor:0 x:0.0f y:0.0f];
    [mHud setInfamyValue:gc.thisTurn.infamy];
	[mHud attachEventListeners];
    [mController.achievementManager broadcastComboMultiplier];
    [mHud enableScoredMode:(mController.raceEnabled == NO)];
    [mController addProp:mHud];
    
    // For debugging
    //[mController.actorBrains addEventListener:@selector(onAiChanged:) atObject:mHud forType:CUST_EVENT_TYPE_AI_STATE_VALUE_CHANGED];
	//[mHud setAiValue:gc.aiKnob->state];
    
    // Self
    [self enableCombatInterface:YES];
    
    // Challenges
    mShipDeck.voodooIdol.visible = mShipDeck.raceEnabled == NO;
}

- (void)transitionToMenu {
    // Race Track
    if (mRaceTrack) {
        [self fadeOutRaceTrack:mRaceTrack overTime:2.0f delay:0 juggler:mController.juggler];
        [self destroyRaceTrack];
    }
    
    // Time Travel
    [mTimeTravelJuggler removeAllObjects];
    [mFutureManager destroy];
    [mFutureManager release]; mFutureManager = nil;
    
    for (RaceTrackActor *raceTrack in mJunkedRaceTrackActors)
        [self fadeOutRaceTrack:raceTrack overTime:2.0f delay:0 juggler:mController.juggler];
    [mJunkedRaceTrackActors removeAllObjects];
    
    // Ship Deck
    [mShipDeck retractOverTime:0.5f];
    
    // HUD
    [mController removeProp:mHud];
    [mHud release]; mHud = nil;
    
    // Player Ship
    [self destroyPlayerShip];
    
    // Self
    [self enableCombatInterface:NO];
    [self destroyDayIntroOverTime:0.5f];
    [self dismissTutorial];
    [self hideAllHints];
    [self destroyGameSummary];
}

- (void)createPlayerShip {
    if (self.playerShip)
        [self destroyPlayerShip];
    
    GameController *gc = GCTRL;
    ResOffset *offset = [RESM itemOffsetWithAlignment:RALowerRight];
    NSString *shipActorType = (mController.raceEnabled) ? @"Speedboat" : @"PlayerShip";
    ActorDef *actorDef = [[ShipFactory shipYard] createPlayerShipDefForShipType:shipActorType x:P2MX(460 + offset.x) y:P2MY(196 + offset.y) angle:SP_D2R(45)];
    self.playerShip = [[[PlayerShip alloc] initWithActorDef:actorDef] autorelease];
    
    delete actorDef;
    actorDef = 0;
    
    // ---- Keep in this order
    ShipDetails *shipDetails = gc.playerDetails.shipDetails;
    mPlayerShip.shipDetails = shipDetails;
    mPlayerShip.shipDeck = mShipDeck;
    mPlayerShip.cannonDetails = gc.playerDetails.cannonDetails;
    // ----
    
    if (mController.raceEnabled)
        mPlayerShip.motorBoating = YES;
    [mPlayerShip setupShip];
    
    mBeach.state = BeachStateDeparting;
    [mController addActor:mPlayerShip];
    [mController.actorBrains addActor:mPlayerShip];
    
    if (mController.raceEnabled)
        [mRaceTrack addRacer:mPlayerShip];
    else
        [mController.guvnor addTarget:mPlayerShip];
}

- (void)destroyPlayerShip {
    if (self.playerShip == nil)
        return;
    [mController removeActor:mPlayerShip];
    [mController.guvnor removeTarget:mPlayerShip];
    self.playerShip = nil;
}

- (void)enablePerformanceSavingMode:(BOOL)enable {
    [mShipDeck setHidden:enable];
    
    if (enable) {
        if (mController.flipped) {
            [mTown setHidden:enable];
        } else {
            [mBeach setHidden:enable];
            [mSea setShorebreakHidden:enable];
        }
    } else {
        [mTown setHidden:enable];
        [mBeach setHidden:enable];
        [mSea setShorebreakHidden:enable];
    }
    
    mPerformanceSavingMode = enable;
}

- (void)setPaused:(BOOL)isPaused {
    if (mController.isTimeSlowed == NO && mController.raceEnabled == NO) {
        mShipDeck.leftCannon.activated = !isPaused;
        mShipDeck.rightCannon.activated = !isPaused;
    }
    
    [mShipDeck showFlipControlsButton:isPaused];
}

- (void)attachEventListeners {
	[super attachEventListeners];
    
	mController.achievementManager.view = mAchievementPanel;
	
	GameController *gc = [GameController GC];
    
	[gc.timeKeeper addEventListener:@selector(timeOfDayChanged:) atObject:mSea forType:CUST_EVENT_TYPE_TIME_OF_DAY_CHANGED];
	[gc.timeKeeper addEventListener:@selector(timeOfDayChanged:) atObject:mBeach forType:CUST_EVENT_TYPE_TIME_OF_DAY_CHANGED];
	[gc.timeKeeper addEventListener:@selector(timeOfDayChanged:) atObject:mTown forType:CUST_EVENT_TYPE_TIME_OF_DAY_CHANGED];
}

- (void)detachEventListeners {
	[super detachEventListeners];
	[mHud detachEventListeners];
	
	GameController *gc = [GameController GC];
	ShipDetails *shipDetails = gc.playerDetails.shipDetails;
	[shipDetails removeEventListener:@selector(onPrisonersChanged:) atObject:mShipDeck.plank forType:CUST_EVENT_TYPE_PRISONERS_VALUE_CHANGED];
    [shipDetails removeEventListener:@selector(onPrisonersChanged:) atObject:mController forType:CUST_EVENT_TYPE_PRISONERS_VALUE_CHANGED];
    
	[gc.timeKeeper removeEventListener:@selector(timeOfDayChanged:) atObject:mSea forType:CUST_EVENT_TYPE_TIME_OF_DAY_CHANGED];
	[gc.timeKeeper removeEventListener:@selector(timeOfDayChanged:) atObject:mBeach forType:CUST_EVENT_TYPE_TIME_OF_DAY_CHANGED];
	[gc.timeKeeper removeEventListener:@selector(timeOfDayChanged:) atObject:mTown forType:CUST_EVENT_TYPE_TIME_OF_DAY_CHANGED];
}

- (void)setPlayerShip:(PlayerShip *)ship {
	if (ship != mPlayerShip) {
		if (mPlayerShip != nil) {
            if (mRaceTrack)
                [mRaceTrack removeRacer:mPlayerShip];
            [mPlayerShip removeEventListener:@selector(onPlayerShipSinking:) atObject:mController forType:CUST_EVENT_TYPE_PLAYER_SHIP_SINKING];
            [mPlayerShip removeEventListener:@selector(onMontySkippered:) atObject:mController forType:CUST_EVENT_TYPE_MONTY_SKIPPERED];
            [mTimeTravelJuggler removeTweensWithTarget:mPlayerShip];
            [mController.juggler removeTweensWithTarget:mPlayerShip];
            [mPlayerShip cleanup];
			[mPlayerShip release]; mPlayerShip = nil;
		}
        
		mPlayerShip = [ship retain];
        GCTRL.playerShip = mPlayerShip;
        [mPlayerShip addEventListener:@selector(onPlayerShipSinking:) atObject:mController forType:CUST_EVENT_TYPE_PLAYER_SHIP_SINKING];
        [mPlayerShip addEventListener:@selector(onMontySkippered:) atObject:mController forType:CUST_EVENT_TYPE_MONTY_SKIPPERED];
	}
}

- (void)setComboDisplay:(uint)value {
	[mShipDeck.comboDisplay setComboMultiplierAnimated:value];
}

- (uint)beachState {
	return (uint)mBeach.state;
}

- (void)setBeachState:(uint)state {
	mBeach.state = (BeachState)state;
}

- (void)createTestBody {
	b2BodyDef bd;
	bd.position.Set(59.5f,0.5f);
	b2Body *ground = mController.world->CreateBody(&bd);
	b2PolygonShape shape;
	b2FixtureDef fd;
	fd.shape = &shape;
	fd.density = 0.0f;
	shape.SetAsBox(13.0f, 13.0f, b2Vec2(0.0f,0.0f), PI_HALF / 2.2f);
	ground->CreateFixture(&fd);
	
	SPSprite *sprite = [SPSprite sprite];
	sprite.x = M2PX(ground->GetPosition().x);
	sprite.y = M2PY(ground->GetPosition().y);
	sprite.rotation = -PI_HALF / 2.2f;
	SPQuad *quad = [SPQuad quadWithWidth:208.0f height:208.0f];
	quad.color = 0x00ff00;
	quad.x = -quad.width / 2;
	quad.y = -quad.height / 2;
	[sprite addChild:quad];
	[mSea addChild:sprite];
}

- (void)createSea {
    if (mSea)
        return;
	mSea = [[Sea alloc] init];
    [mSea addEventListener:@selector(onSeaOfLavaPeaked:) atObject:mController forType:CUST_EVENT_TYPE_SEA_OF_LAVA_PEAKED];
	[mController addProp:mSea];
}

- (void)displayHintByName:(NSString *)name x:(float)x y:(float)y radius:(float)radius target:(SPDisplayObject *)target exclusive:(BOOL)exclusive {
    if (mHints == nil)
        mHints = [[NSMutableDictionary alloc] init];
    if (name == nil || [mHints objectForKey:name] || (mHints.count > 0 && exclusive))
        return;
    int hintCategory = CAT_PF_SURFACE;
    HintPackage *package = nil;
    
    if ([name isEqualToString:GAME_SETTINGS_KEY_DONE_TUTORIAL2]) {
        hintCategory = CAT_PF_DECK;
        package = [HintHelper pointerHintWithScene:mController target:[SPPoint pointWithX:x y:y] radius:radius text:@"" animated:YES];
    } else if ([name isEqualToString:GAME_SETTINGS_KEY_PLANKING_TIPS]) {
        package = [HintHelper pointerHintWithScene:mController target:[SPPoint pointWithX:x y:y] radius:radius text:@"Touch the plank!" animated:YES];
    } else if ([name isEqualToString:GAME_SETTINGS_KEY_VOODOO_TIPS]) {
        package = [HintHelper pointerHintWithScene:mController target:[SPPoint pointWithX:x y:y] radius:radius text:@"Touch the idol!" animated:YES];
    } else if ([name isEqualToString:GAME_SETTINGS_KEY_BRANDY_SLICK_TIPS]) {
        package = [HintHelper pointerHintWithScene:mController target:[SPPoint pointWithX:x y:y] radius:radius text:@"Shoot to ignite!" animated:YES];
    } else if ([name isEqualToString:GAME_SETTINGS_KEY_PLAYER_SHIP_TIPS]) {
        package = [HintHelper pointerHintWithScene:mController target:[SPPoint pointWithX:x y:y] movingTarget:target radius:radius text:@"This is your ship" animated:NO];
    } else if ([name isEqualToString:GAME_SETTINGS_KEY_TREASURE_FLEET_TIPS]) {
        package = [HintHelper pointerHintWithScene:mController target:[SPPoint pointWithX:x y:y] movingTarget:target radius:radius text:@"Treasure Fleet" animated:NO];
    } else if ([name isEqualToString:GAME_SETTINGS_KEY_SILVER_TRAIN_TIPS]) {
        package = [HintHelper pointerHintWithScene:mController target:[SPPoint pointWithX:x y:y] movingTarget:target radius:radius text:@"Silver Train" animated:NO];
    } else {
        package = [HintHelper pointerHintWithScene:mController target:[SPPoint pointWithX:x y:y] radius:radius text:@"Testing" animated:YES];
    }
    
    MenuDetailView *hint = [[[MenuDetailView alloc] initWithCategory:hintCategory] autorelease];
    [mHints setObject:hint forKey:name];
    
    for (Prop *prop in package.props) {
        [hint addMiscProp:prop];
        [hint addChild:prop];
    }
    
    for (SPTween *tween in package.loopingTweens) {
        [mController.juggler addObject:tween];
        [hint addLoopingTween:tween];
    }
    
    for (Prop *prop in package.flipProps)
        [hint addFlipProp:prop];
    
    [mController addProp:hint];
}

- (void)hideHintByName:(NSString *)name {
    if (name == nil || [mHints objectForKey:name] == nil)
        return;
    MenuDetailView *hint = [mHints objectForKey:name];
    
    if (hint) {
        [mHintsGarbage addObject:hint];
        [mController.juggler removeTweensWithTarget:hint];
        [mController removeProp:hint];
        [mHints removeObjectForKey:name];
    }
}

- (void)hideAllHints {
    NSArray *hintKeys = [mHints allKeys];
    
    for (NSString *key in hintKeys)
        [self hideHintByName:key];
}

- (void)destroyHints {
    for (NSString *key in mHints) {
        MenuDetailView *hint = [mHints objectForKey:key];
        [mController.juggler removeTweensWithTarget:hint];
        [mController removeProp:hint];
    }
    
    [mHints release]; mHints = nil;
    [mHintsGarbage release]; mHintsGarbage = nil;
}

- (void)onOFChallengeHintFaded:(SPEvent *)event {
    [self hideHintByName:@"OFChallengeHint"];
}

- (void)displayTutorialForKey:(NSString *)key fromPageIndex:(int)fromIndex toPageIndex:(int)toIndex {
    if (mTutorialBooklet)
        [self dismissTutorial];
    mTutorialBooklet = [(TutorialBooklet *)[self loadTutorialBookletForKey:key fromIndex:fromIndex toPageIndex:toIndex] retain];
    mTutorialBooklet.alpha = 0;
	[self addEventListener:@selector(onTutorialCompleted:) atObject:mController forType:CUST_EVENT_TYPE_PLAYFIELD_TUTORIAL_COMPLETED];
    [mTutorialBooklet turnToPage:fromIndex];
    [mController addProp:mTutorialBooklet];
    
    SPTween *tween = [SPTween tweenWithTarget:mTutorialBooklet time:1.0f];
    [tween animateProperty:@"alpha" targetValue:1];
    [mController.juggler addObject:tween];
}

- (void)dismissTutorial {
    if (mTutorialBooklet == nil)
        return;
    [mTutorialBooklet removeEventListener:@selector(onBookletPageTurned:) atObject:self forType:CUST_EVENT_TYPE_BOOKLET_PAGE_TURNED];
    [mTutorialBooklet removeEventListener:@selector(onTutorialCompleted:) atObject:self forType:CUST_EVENT_TYPE_TUTORIAL_DONE_PRESSED];
	[self removeEventListener:@selector(onTutorialCompleted:) atObject:mController forType:CUST_EVENT_TYPE_PLAYFIELD_TUTORIAL_COMPLETED];
    [mController.juggler removeTweensWithTarget:mTutorialBooklet];
    [mController removeProp:mTutorialBooklet];
    [mTutorialBooklet release]; mTutorialBooklet = nil;
}

- (TutorialBooklet *)loadTutorialBookletForKey:(NSString *)key fromIndex:(int)fromIndex toPageIndex:(int)toIndex {
	NSString *plistPath = @"Tutorial";
	
	if (mViewParser == nil) {
		mViewParser = [[ViewParser alloc] initWithScene:mController eventListener:mController plistPath:plistPath];
		mViewParser.category = CAT_PF_DECK;
		mViewParser.fontKey = mController.fontKey;
	}
	
	NSDictionary *dict = [Globals loadPlist:plistPath];
	dict = [dict objectForKey:key];
	
	NSArray *pages = [dict objectForKey:@"Pages"];
    
    if (fromIndex == -1) fromIndex = 0;
    if (toIndex == -1) toIndex = pages.count-1;
    toIndex = MIN(toIndex, pages.count-1);
	
	TutorialBooklet *booklet = [[[TutorialBooklet alloc] initWithCategory:CAT_PF_DECK key:key minIndex:fromIndex maxIndex:toIndex] autorelease];
	//subview.cover = [mViewParser parseTitleSubviewByName:@"Cover" forViewName:key];
	//booklet.currentPage = [mViewParser parseSubviewByName:@"Pages" forViewName:key index:0];
	booklet.numPages = pages.count;
	//[subview refreshPageNo];
	[booklet addEventListener:@selector(onBookletPageTurned:) atObject:self forType:CUST_EVENT_TYPE_BOOKLET_PAGE_TURNED];
    [booklet addEventListener:@selector(onTutorialCompleted:) atObject:self forType:CUST_EVENT_TYPE_TUTORIAL_DONE_PRESSED];
	
	return booklet;
}

- (BOOL)isValidTutorialBookletPageIndex:(uint)pageIndex {
    GameController *gc = GCTRL;
    BOOL isValid = ([gc.gameSettings settingForKey:GAME_SETTINGS_KEY_DONE_TUTORIAL] == NO);
    return isValid;
}

- (void)applyTutorialFlipConstraints:(BOOL)isFlipped {
    if (mTutorialBooklet == nil)
        return;
    
    MenuDetailView *page = mTutorialBooklet.currentPage;
    
    if (page == nil)
        return;
    
    switch (mController.tutorialState) {
        case TutorialStatePrimary:
        {
            switch (mTutorialBooklet.pageIndex) {
                case 3:
                {
                    if (isFlipped) {
                        SPDisplayObject *displayObject = (SPDisplayObject *)[page controlForKey:@"HelmThumb"];
                        displayObject.visible = NO;
                        
                        displayObject = (SPDisplayObject *)[page controlForKey:@"HelmThumbFlipped"];
                        displayObject.visible = YES;
                    } else {
                        SPDisplayObject *displayObject = (SPDisplayObject *)[page controlForKey:@"HelmThumb"];
                        displayObject.visible = YES;
                        
                        displayObject = (SPDisplayObject *)[page controlForKey:@"HelmThumbFlipped"];
                        displayObject.visible = NO;
                    }
                }
                    break;
                case 4:
                {
                    if (isFlipped) {
                        SPDisplayObject *displayObject = (SPDisplayObject *)[page controlForKey:@"CannonThumb"];
                        displayObject.visible = NO;
                        
                        displayObject = (SPDisplayObject *)[page controlForKey:@"CannonThumbFlipped"];
                        displayObject.visible = YES;
                    } else {
                        SPDisplayObject *displayObject = (SPDisplayObject *)[page controlForKey:@"CannonThumb"];
                        displayObject.visible = YES;
                        
                        displayObject = (SPDisplayObject *)[page controlForKey:@"CannonThumbFlipped"];
                        displayObject.visible = NO;
                    }
                }
                    break;
                case 6:
                {
                    page.touchable = YES;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case TutorialStatePrimary_1:
        case TutorialStateSecondary:
        case TutorialStateTertiary:
        case TutorialStateQuaternary:
        case TutorialStateNull:
        default:
            break;
    }
}

- (void)onBookletPageTurned:(SPEvent *)event {
    //GameController *gc = GCTRL;
	BookletSubview *subview = (BookletSubview *)event.currentTarget;
    
    //if ([self isValidTutorialBookletPageIndex:subview.pageIndex] == NO) {
    //    [subview nextPage]; // Will recurse until a valid page is found or until the end of a non-looping booklet is reached.
    //    return;
    //}
    
    MenuDetailView *page = [mViewParser parseSubviewByName:@"Pages" forViewName:subview.bookKey index:subview.pageIndex];
    subview.currentPage = page;
    
    [self applyTutorialFlipConstraints:mController.flipped];
    
    if (mTutorialBooklet == nil)
        return;
    
    switch (mController.tutorialState) {
        case TutorialStateTertiary:
        {
            switch (mTutorialBooklet.pageIndex) {
                case 0:
                {
                    ResOffset *offset = [RESM itemOffsetWithAlignment:RALowerLeft];
                    [self displayHintByName:GAME_SETTINGS_KEY_DONE_TUTORIAL2 x:45 + offset.x y:302 + offset.y radius:10 target:nil exclusive:NO];
                    [mShipDeck.comboDisplay setComboMultiplierAnimated:mController.achievementManager.comboMultiplierMax];
                }
                    break;
                case 1:
                {
                    [self hideHintByName:GAME_SETTINGS_KEY_DONE_TUTORIAL2];
                    [mShipDeck.comboDisplay setComboMultiplierAnimated:0];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case TutorialStateQuaternary:
        {
            switch (mTutorialBooklet.pageIndex) {
                case 0:
                {
                    ResOffset *offset = [RESM itemOffsetWithAlignment:RACenter];
                    
                    // Add potion
                    SPSprite *potionSprite = [GuiHelper potionSpriteWithPotion:[Potion potencyPotion] size:GuiSizeLge scene:mController];
                    potionSprite.x = 68 + offset.x;
                    potionSprite.y = 99 + offset.y;
                    [page addChild:potionSprite];
                    
                    potionSprite = [GuiHelper potionSpriteWithPotion:[Potion longevityPotion] size:GuiSizeLge scene:mController];
                    potionSprite.x = 408 + offset.x;
                    potionSprite.y = 99 + offset.y;
                    [page addChild:potionSprite];
                }
                    break;
            }
        }
            break;
        case TutorialStatePrimary:
        case TutorialStatePrimary_1:
        case TutorialStateSecondary:
        case TutorialStateNull:
        default:
            break;
    }
}

- (void)onTutorialCompleted:(SPEvent *)event {
    [mController.voodooManager hideMenu];
    [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_PLAYFIELD_TUTORIAL_COMPLETED]];
}

- (void)onTimeOfDayChangedEvent:(TimeOfDayChangedEvent *)event {
    // Alter wake alphas
    SPDisplayObject *wakeLayer = [mController.spriteLayerManager childAtCategory:CAT_PF_WAKES];
    if (!event || !wakeLayer)
        return;
    
    [mController.juggler removeTweensWithTarget:wakeLayer];
    
    float alphaTarget = 1, tweenDuration = event.timeRemaining;
    
    switch (event.timeOfDay) {
        case DuskTransition:
            alphaTarget = 0.75f;
            wakeLayer.alpha += fabsf(alphaTarget - wakeLayer.alpha) * (1.0f - event.proportionRemaining);
            break;
        case Dusk:
            alphaTarget = 0.75f;
            tweenDuration = 0;
            break;
        case EveningTransition:
            alphaTarget = 0.5f;
            wakeLayer.alpha += fabsf(alphaTarget - wakeLayer.alpha) * (1.0f - event.proportionRemaining);
            break;
        case Evening:
        case Midnight:
            alphaTarget = 0.5f;
            tweenDuration = 0;
            break;
        case DawnTransition:
            alphaTarget = 1;
            wakeLayer.alpha += fabsf(alphaTarget - wakeLayer.alpha) * (1.0f - event.proportionRemaining);
            break;
        default:
            alphaTarget = 1;
            tweenDuration = 0;
            break;
    }
    
    SPTween *tween = [SPTween tweenWithTarget:wakeLayer time:tweenDuration];
    [tween animateProperty:@"alpha" targetValue:alphaTarget];
    [mController.juggler addObject:tween];
}

- (void)showFps:(double)time {
    if (mFpsText == nil)
        return;
    
	static double elapsedTime = 0.0;
	static int frameCount = 0;
	
	elapsedTime += time;
	++frameCount;
	
	if (elapsedTime >= 2) {
		float fps = frameCount / 2;
		float fraction = fps - (int)fps;
		fps += fraction;
        
        if (mPlayerShip)
            mFpsText.text = [NSString stringWithFormat:@"%d", (int)fps]; //[NSString stringWithFormat:@"%f", mPlayerShip.cannonSpamCapacitor];
		elapsedTime -= 2.0;
		frameCount = 0;
	}
}

- (void)advanceFpsCounter:(double)time {
    [self showFps:time];
}

- (void)advanceTime:(double)time {
	[mWeather advanceTime:time];
    [mTimeTravelJuggler advanceTime:time];
    
    if (mHintsGarbage.count > 0) {
        for (Prop *prop in mHintsGarbage)
            [mController removeProp:prop];
        [mHintsGarbage removeAllObjects];
    }
    
	[super advanceTime:time];
}

- (void)displayFirstMateAlert:(NSArray *)msgs userData:(int)userData dir:(int)dir afterDelay:(float)delay {
	[self displayHelpAlert:msgs textureName:@"first-mate" userData:userData dir:dir afterDelay:delay];
}

- (void)displayEtherealAlert:(NSArray *)msgs userData:(int)userData dir:(int)dir afterDelay:(float)delay {
    [self displayHelpAlert:msgs textureName:@"ethereal-help" userData:userData dir:dir afterDelay:delay];
}

- (void)displayHelpAlert:(NSArray *)msgs textureName:(NSString *)textureName userData:(int)userData dir:(int)dir afterDelay:(float)delay {
	FirstMate *mate = [FirstMate firstMateWithCategory:mController.helpCategory msgs:msgs textureName:textureName dir:dir choice:NO];
    mate.userData = userData;
	[mate addEventListener:@selector(onFirstMateDecision:) atObject:mController forType:CUST_EVENT_TYPE_FIRST_MATE_DECISION];
	[mate addEventListener:@selector(onFirstMateRetiredToCabin:) atObject:mController forType:CUST_EVENT_TYPE_FIRST_MATE_RETIRED];
	[mController addProp:mate];
	[mate deployTouchBarrier];
	[[mController.juggler delayInvocationAtTarget:mate byTime:delay] beginAnnoucements];
}

- (void)travelBackInTime {
    if (mInFuture == NO)
        return;
    [mTimeTravelJuggler removeAllObjects];
    [mController.actorBrains setInFuture:NO];
    [mController.actorBrains setShipsPaused:NO];
    [mTown travelBackInTime:3.0f];
    [mBeach travelBackInTime:3.0f];
    
    mInFuture = NO;
}

- (float)travelForwardInTime {
    if (mFutureManager) {
        [mFutureManager destroy];
        [mFutureManager release]; mFutureManager = nil;
    }
    
    if (mTimeTravelJuggler == nil)
        mTimeTravelJuggler = [[SPJuggler alloc] init];
    [mTimeTravelJuggler removeAllObjects];
    
	float delay = 0.0f;
	mFutureManager = [[FutureManager alloc] init];
	[mFutureManager sparkElectricityOnSprite:mPlayerShip];
	[mController stopAmbientSounds];
	delay += mFutureManager.electricityDuration;

	// Flame Paths + Ship Disappearance
	[[mTimeTravelJuggler delayInvocationAtTarget:mFutureManager byTime:delay] igniteFlamePathsAtSprite:mPlayerShip];
	[[mTimeTravelJuggler delayInvocationAtTarget:mPlayerShip byTime:delay] travelThroughTime:0.25f];
	delay += mFutureManager.flamePathDuration + mFutureManager.flamePathExtinguishDuration;
	
	// Morph into 1985
	[(ActorAi *)[mTimeTravelJuggler delayInvocationAtTarget:mController.actorBrains byTime:delay] dockAllShips];
	[(ActorAi *)[mTimeTravelJuggler delayInvocationAtTarget:mController.actorBrains byTime:delay] setShipsPaused:YES];
    
    if (mJunkedRaceTrackActors == nil)
        mJunkedRaceTrackActors = [[NSMutableSet alloc] init];
    [mJunkedRaceTrackActors addObject:mRaceTrack];
    [self fadeOutRaceTrack:mRaceTrack overTime:2.0f delay:delay juggler:mTimeTravelJuggler];
    [self destroyRaceTrack];
    
	[(TownActor *)[mTimeTravelJuggler delayInvocationAtTarget:mTown byTime:delay] travelForwardInTime:3.0f];
	[(BeachActor *)[mTimeTravelJuggler delayInvocationAtTarget:mBeach byTime:delay] travelForwardInTime:3.0f];
	delay += 3.0f;
	[(ShipDeck *)[mTimeTravelJuggler delayInvocationAtTarget:mShipDeck byTime:delay] travelForwardInTime];
	
	// Sparks as we break into future realm
	for (int i = 0; i < 3; ++i) {
		[(FutureManager *)[mTimeTravelJuggler delayInvocationAtTarget:mFutureManager byTime:delay] sparkElectricityAtX:265.0f y:152.0f];
		
		if (i < 2)
			delay += mFutureManager.electricityDuration * 1.1f;
	}
	
	// Ship reappearance
	[(PlayerShip *)[mTimeTravelJuggler delayInvocationAtTarget:mPlayerShip byTime:delay] emergeInPresentAtX:265.0f y:152.0f duration:0.25f];
	[(PlayfieldController *)[mTimeTravelJuggler delayInvocationAtTarget:mController byTime:delay] playAmbientSounds];
	[(ActorAi *)[mTimeTravelJuggler delayInvocationAtTarget:mController.actorBrains byTime:delay] setInFuture:YES];
	delay += 0.25f;
	[(ActorAi *)[mTimeTravelJuggler delayInvocationAtTarget:mController.actorBrains byTime:delay] setShipsPaused:NO];
    
    [(PlayfieldController *)[mController.juggler delayInvocationAtTarget:mController byTime:delay] timeTravelSequenceDidComplete];
    
    mInFuture = YES;
	return delay;
}

- (void)fadeInRaceTrack:(RaceTrackActor *)raceTrack overTime:(float)duration delay:(float)delay {
	if (raceTrack == nil)
		return;
    if (mTimeTravelJuggler == nil)
        mTimeTravelJuggler = [[SPJuggler alloc] init];
    
	SPTween *tween = [SPTween tweenWithTarget:raceTrack time:duration];
	[tween animateProperty:@"alpha" targetValue:1.0f];
    tween.delay = delay;
	[mTimeTravelJuggler addObject:tween];
}

- (void)fadeOutRaceTrack:(RaceTrackActor *)raceTrack overTime:(float)duration delay:(float)delay juggler:(SPJuggler *)juggler {
	if (raceTrack == nil)
		return;
    
	SPTween *tween = [SPTween tweenWithTarget:raceTrack time:duration];
	[tween animateProperty:@"alpha" targetValue:0.0f];
    tween.delay = delay;
    [tween addEventListener:@selector(onRaceTrackFadedOut:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
	[juggler addObject:tween];
}

- (void)onRaceTrackFadedOut:(SPEvent *)event {
    SPTween *tween = (SPTween *)event.currentTarget;
    Actor *actor = (Actor *)tween.target;
    
    if (actor) {
        [mController removeActor:actor];
        [mJunkedRaceTrackActors removeObject:actor];
    }
}

- (void)destroyRaceTrack {
    if (mPlayerShip)
        [mRaceTrack removeRacer:mPlayerShip];
    [mRaceTrack removeEventListener:@selector(onRaceFinished:) atObject:mController forType:CUST_EVENT_TYPE_RACE_FINISHED];
    [mRaceTrack removeEventListener:@selector(onRaceTrackConquered:) atObject:mController forType:CUST_EVENT_TYPE_88MPH];
    [mRaceTrack removeEventListener:@selector(onSpeedDemonAchieved:) atObject:mController forType:CUST_EVENT_TYPE_SPEED_DEMON];
    [mRaceTrack release]; mRaceTrack = nil;
}

- (void)enableWeather:(BOOL)enable {
    mWeather.enabled = enable;
}

- (void)enableCombatInterface:(BOOL)enable {
    if (enable == NO) {
        [mController.voodooManager hideMenu];
        [mController.achievementManager hideCombatText];
    }
    
    mController.voodooManager.touchable = enable;
    [mShipDeck enableCombatControls:enable];
}

- (void)showDayIntroForDay:(uint)day overTime:(float)duration {
    if (mDayIntro) {
        [mController.juggler removeTweensWithTarget:mDayIntro];
        [mController removeProp:mDayIntro];
        [mDayIntro autorelease]; mDayIntro = nil;
    }
    
    mDayIntro = [[Prop alloc] initWithCategory:CAT_PF_SURFACE];
    mDayIntro.alpha = 0;
    
    SPSprite *dayIntroCanvas = [SPSprite sprite];
    [mDayIntro addChild:dayIntroCanvas];
    
    SPImage *dayImage = [SPImage imageWithTexture:[mController textureByName:@"fancy-day"]];
    [dayIntroCanvas addChild:dayImage];
    
    SPImage *numberImage = [SPImage imageWithTexture:[mController textureByName:[NSString stringWithFormat:@"fancy-%u", day]]];
    numberImage.x = dayImage.width + numberImage.width;
    [dayIntroCanvas addChild:numberImage];
    
    mDayIntro.x = mController.viewWidth / 2;
    mDayIntro.y = (mController.viewHeight - mDayIntro.height) / 2;
    
    dayIntroCanvas.x = -dayIntroCanvas.width / 2;
    [mController addProp:mDayIntro];
    
    NSString *text = [GCTRL.timeKeeper introForDay:day];
    
    if (text) {
        text = [NSString stringWithFormat:@"'%@'", text];
        SPTextField *textField = [SPTextField textFieldWithWidth:256 height:28 text:text fontName:mController.fontKey fontSize:24 color:0xfcc30e];
        textField.x = (mDayIntro.width - textField.width) / 2;
        textField.y = mDayIntro.height + textField.height / 3;
        textField.hAlign = SPHAlignCenter;
        textField.vAlign = SPVAlignTop;
        textField.compiled = NO;
        [dayIntroCanvas addChild:textField];
    }
    
    if (mController.flipped)
        mDayIntro.scaleX = -1;
    
    SPTween *tween = [SPTween tweenWithTarget:mDayIntro time:duration];
    [tween animateProperty:@"alpha" targetValue:1];
    [mController.juggler addObject:tween];
}

- (void)hideDayIntroOverTime:(float)duration delay:(float)delay {
    if (mDayIntro == nil)
        return;
    //[mController.juggler removeTweensWithTarget:mDayIntro]; // This would kill our showDayIntroForDay tween.
    
    SPTween *tween = [SPTween tweenWithTarget:mDayIntro time:duration];
    [tween animateProperty:@"alpha" targetValue:0];
    tween.delay = delay;
    [tween addEventListener:@selector(onDayIntroHidden:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
    [mController.juggler addObject:tween];
}

- (void)destroyDayIntroOverTime:(float)duration {
    if (mDayIntro == nil)
        return;
    [mController.juggler removeTweensWithTarget:mDayIntro];
    
    SPTween *tween = [SPTween tweenWithTarget:mDayIntro time:duration * mDayIntro.alpha];
    [tween animateProperty:@"alpha" targetValue:0];
    [tween addEventListener:@selector(onDayIntroHidden:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
    [mController.juggler addObject:tween];
    [mDayIntro autorelease]; mDayIntro = nil;
}

- (void)onDayIntroHidden:(SPEvent *)event {
    SPTween *tween = (SPTween *)event.currentTarget;
    Prop *prop = (Prop *)tween.target;
    [mController removeProp:prop];
    
    if (prop == mDayIntro) {
        [mDayIntro autorelease];
        mDayIntro = nil;
    }
}

- (void)prepareForGameOver {
    [mPlayerShip prepareForGameOver];
    [self enableCombatInterface:NO];
    [self hideDayIntroOverTime:0.5f delay:0];
    [self dismissTutorial];
    [self hideAllHints];
}

- (void)displayGameOverSequence {
    if (mGameSummary)
        return;
    [self moveAchievementPanelToCategory:CAT_PF_DECK];
    
    if (mController.raceEnabled) {
        mGameSummary = [[SpeedboatSummary alloc] initWithCategory:CAT_PF_DIALOGS];
        [mController stopAmbientSounds];
    } else
        mGameSummary = [[GameSummary alloc] initWithCategory:CAT_PF_DIALOGS];
    
    mGameSummary.y = 4;
    [mGameSummary hideSummaryScroll];
    [mGameSummary addEventListener:@selector(onGameOverRetryPressed:) atObject:mController forType:CUST_EVENT_TYPE_GAME_SUMMARY_RETRY];
    [mGameSummary addEventListener:@selector(onGameOverMenuPressed:) atObject:mController forType:CUST_EVENT_TYPE_GAME_SUMMARY_MENU];
    [mGameSummary addEventListener:@selector(onGameOverSubmitPressed:) atObject:mController forType:CUST_EVENT_TYPE_GAME_SUMMARY_SUBMIT];
    [mController addProp:mGameSummary];
    
    float delay = [mGameSummary displayGameOverSequence];
    [(ObjectivesManager *)[mController.juggler delayInvocationAtTarget:mController.objectivesManager byTime:delay] processEndOfTurn];
}

- (void)displayGameSummary {
    if (mGameSummary == nil)
        return;
    GameController *gc = GCTRL;
    
    float delay = 0.25f;
    [(GameSummary *)[mController.juggler delayInvocationAtTarget:mGameSummary byTime:delay] displaySummaryScroll];
    
    [gc processEndOfTurn];
    
    delay += 0.5f;
    [(GameSummary *)[mController.juggler delayInvocationAtTarget:mGameSummary byTime:delay] displayStamps];
    [(PlayfieldController *)[mController.juggler delayInvocationAtTarget:mController byTime:delay + mGameSummary.stampsDelay] gameOverSequenceDidComplete];
}

- (void)destroyGameSummary {
    if (mGameSummary) {
		[mGameSummary removeEventListener:@selector(onGameOverRetryPressed:) atObject:mController forType:CUST_EVENT_TYPE_GAME_SUMMARY_RETRY];
		[mGameSummary removeEventListener:@selector(onGameOverMenuPressed:) atObject:mController forType:CUST_EVENT_TYPE_GAME_SUMMARY_MENU];
        [mGameSummary removeEventListener:@selector(onGameOverSubmitPressed:) atObject:mController forType:CUST_EVENT_TYPE_GAME_SUMMARY_SUBMIT];
        [mController.juggler removeTweensWithTarget:mGameSummary];
		[mController removeProp:mGameSummary];
        [mGameSummary destroy];
		[mGameSummary autorelease]; mGameSummary = nil;
	}
}

- (void)enableSummaryButton:(BOOL)enable forKey:(NSString *)key {
    if (mGameSummary)
        [mGameSummary enableMenuButton:enable forKey:key];
}

- (void)hideTwitter {
    [mShipDeck hideTwitterOverTime:0.375f];
}

- (void)showTwitter {
    [mShipDeck showTwitterOverTime:0.375f];
}

- (BOOL)isCoveOpen {
	return (mBeach.state == BeachStateOpen);
}

- (void)dealloc {
	GameController *gc = GCTRL;
	
    [self destroyHints];
    [self destroyGameSummary];
	[self detachEventListeners];
	[mController.juggler removeTweensWithTarget:mSea];
	[mController.juggler removeTweensWithTarget:mShipDeck];
	[mController.juggler removeTweensWithTarget:mGameOverPanel];
    [mController.juggler removeTweensWithTarget:mWeather];
    [mController.juggler removeTweensWithTarget:mDayIntro];
    [mController.juggler removeTweensWithTarget:mTutorialBooklet];
    [mController.juggler removeTweensWithTarget:mAchievementPanel];
    
    mController.achievementManager.view = nil;
	
	if (mController.raceEnabled) {
        [mRaceTrack removeEventListener:@selector(onRaceFinished:) atObject:mController forType:CUST_EVENT_TYPE_RACE_FINISHED];
		[mRaceTrack removeEventListener:@selector(onRaceTrackConquered:) atObject:mController forType:CUST_EVENT_TYPE_88MPH];
        [mRaceTrack removeEventListener:@selector(onSpeedDemonAchieved:) atObject:mController forType:CUST_EVENT_TYPE_SPEED_DEMON];
    }
	
	[mController.achievementManager removeEventListener:@selector(onComboMultiplierChanged:) atObject:mShipDeck.comboDisplay forType:CUST_EVENT_TYPE_COMBO_MULTIPLIER_CHANGED];
    [mShipDeck removeEventListener:@selector(onDeckVoodooIdolPressed:) atObject:mController forType:CUST_EVENT_TYPE_DECK_VOODOO_IDOL_PRESSED];
    [mShipDeck removeEventListener:@selector(onDeckTwitterActivated:) atObject:mController forType:CUST_EVENT_TYPE_DECK_TWITTER_BUTTON_PRESSED];
    [mTutorialBooklet removeEventListener:@selector(onBookletPageTurned:) atObject:self forType:CUST_EVENT_TYPE_BOOKLET_PAGE_TURNED];
    [mTutorialBooklet removeEventListener:@selector(onTutorialCompleted:) atObject:self forType:CUST_EVENT_TYPE_TUTORIAL_DONE_PRESSED];
    [mSea removeEventListener:@selector(onSeaOfLavaPeaked:) atObject:mController forType:CUST_EVENT_TYPE_SEA_OF_LAVA_PEAKED];
    
	[mController removeProp:mSea];
	[mController removeProp:mHud];
	[mController removeActor:mPlayerShip];
	[mController removeProp:mShipDeck];
	[mController removeActor:mBeach];
	[mController removeActor:mTown];
	[mController removeActor:mTownDock];
    [mController removeProp:mDayIntro];
    [mController removeProp:mTutorialBooklet];
#ifdef CHEEKY_DEBUG
	[mController removeProp:mFpsView];
	[mFpsView release]; mFpsView = nil;
	[mFpsText release]; mFpsText = nil;
	
	[mStageDebugToggle removeEventListener:@selector(onStageDebugTouched:) atObject:mController forType:SP_EVENT_TYPE_TOUCH];
	[mStageDebugToggle release]; mStageDebugToggle = nil;
#endif
	
    self.playerShip = nil;
	[mSea release]; mSea = nil;
	[mShipDeck release]; mShipDeck = nil;
	[mBeach release]; mBeach = nil;
	[mTown release]; mTown = nil;
	[mTownDock release]; mTownDock = nil;
	[mWeather release]; mWeather = nil;
	[mRaceTrack release]; mRaceTrack = nil;
	[mGameOverPanel release]; mGameOverPanel = nil;
    [mGameSummary release]; mGameSummary = nil;
    [mViewParser release]; mViewParser = nil;
    [mDayIntro release]; mDayIntro = nil;
    [mTutorialBooklet release]; mTutorialBooklet = nil;
    [mFutureManager destroy];
    [mFutureManager release]; mFutureManager = nil;
    [mTimeTravelJuggler release]; mTimeTravelJuggler = nil;
	[mJunkedRaceTrackActors release]; mJunkedRaceTrackActors = nil;
    
    if ([gc cachedResourceForKey:RESOURCE_CACHE_COMBAT_TEXT] == nil)
        [SPTextField unregisterBitmapFont:mController.fontKey];
	mController = nil;
	[super dealloc];
}

@end
