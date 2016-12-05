//
//  ShipDeck.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 4/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "ShipDeck.h"
#import "NumericRatioChangedEvent.h"
#import "PlayerDetails.h"
#import "ShipDetails.h"
#import "HudCell.h"
#import "DashDial.h"
#import "GuiHelper.h"
#import "GameController.h"
#import "Globals.h"

@interface ShipDeck ()

- (void)swapFlyingDutchmanTextures;
- (void)onDeckVoodooIdolPressed:(SPEvent *)event;
- (void)onTwitterHidden:(SPEvent *)event;
- (void)onTwitterButtonPressed:(SPEvent *)event;

@end


@implementation ShipDeck

@synthesize voodooIdol = mVoodooIdol;
@synthesize helm = mHelm;
@synthesize plank = mPlank;
@synthesize rightCannon = mRightCannon;
@synthesize leftCannon = mLeftCannon;
@synthesize comboDisplay = mComboDisplay;
@dynamic raceEnabled;


- (id)initWithCategory:(int)category shipDetails:(ShipDetails *)shipDetails {
    if (self = [super initWithCategory:category]) {
		mAdvanceable = YES;
		mFlyingDutchman = NO;
        mTwitterEnabled = NO;
		
        mFlyingDutchmanVoodooTexture = [[mScene textureByName:@"ghost-deck-idol"] retain];
        
		SPTextureAtlas *dutchmanAtlas = [[[SPTextureAtlas alloc] initWithContentsOfFile:@"ghost-railing-atlas.xml"] autorelease];
		mFlyingDutchmanRailingTexture = [[dutchmanAtlas textureByName:@"ghost-railing"] retain];
		mFlyingDutchmanRailingTexture.repeat = YES;
        
        mRailing = nil;
        mSpeedboatRailing = nil;
		mHelm = [[Helm alloc] initWithRotationIncrement:0.1f * GCTRL.fpsFactor * PI];
		mPlank = [[Plank alloc] initWithShipDetails:shipDetails];
		mRightCannon = [[PlayerCannon alloc] init];
		mLeftCannon = [[PlayerCannon alloc] init];
        mCannonContainer = [[SPSprite alloc] init];
		mComboDisplay = [[ComboDisplay alloc] init];
        mVoodooPlankContainer = [[SPSprite alloc] init];
        mVoodooSprite = [[SPSprite alloc] init];
        mTwitterSprite = [[SPSprite alloc] init];
        mPotion = nil;
		mTimeDial = nil;
		mSpeedDial = nil;
		mLapDial = nil;
		self.touchable = YES;
    }
    return self;
}

- (id)initWithCategory:(int)category {
	return [self initWithCategory:category shipDetails:[GameController GC].playerDetails.shipDetails];
}

- (void)loadFromDictionary:(NSDictionary *)dictionary withKeys:(NSArray *)keys {
    if (mRailing)
        return;
    
	GameController *gc = GCTRL;
	int i = 0;
	
	NSDictionary *dict = [dictionary objectForKey:@"Types"];
	NSString *key = [keys objectAtIndex:i++];
	dict = [dict objectForKey:key];
	dict = [dict objectForKey:@"Textures"];
	
    // Railings
	NSString *railingTextureName = [dict objectForKey:@"railingTexture"];
	SPTextureAtlas *railingAtlas = [[[SPTextureAtlas alloc] initWithContentsOfFile:[railingTextureName stringByAppendingFormat:@"-atlas.xml"]] autorelease];
	
	SPTexture *railingTexture = [railingAtlas textureByName:railingTextureName];
	railingTexture.repeat = YES;
	
	mRailing = [[SPImage alloc] initWithTexture:railingTexture];
	mRailing.x = 0;
	mRailing.y = mScene.viewHeight-35;
	mRailing.width = mScene.viewWidth;
	mRailing.touchable = NO;
	
	float xRepeat = mRailing.width / railingTexture.width;
	[mRailing setTexCoords:[SPPoint pointWithX:xRepeat y:0] ofVertex:1];
	[mRailing setTexCoords:[SPPoint pointWithX:0 y:1] ofVertex:2];
	[mRailing setTexCoords:[SPPoint pointWithX:xRepeat y:1] ofVertex:3];
    
    SPTextureAtlas *speedboatAtlas = [[[SPTextureAtlas alloc] initWithContentsOfFile:@"8-Speedboat-railing-atlas.xml"] autorelease];
    SPTexture *speedboatRailingTexture = [speedboatAtlas textureByName:@"8-Speedboat-railing"];
    speedboatRailingTexture.repeat = YES;
    mSpeedboatRailing = [[SPImage alloc] initWithTexture:speedboatRailingTexture];
    mSpeedboatRailing.x = 0;
    mSpeedboatRailing.y = mScene.viewHeight-30;
    mSpeedboatRailing.width = mScene.viewWidth;
    mSpeedboatRailing.touchable = NO;
    
    xRepeat = mSpeedboatRailing.width / speedboatRailingTexture.width;
    [mSpeedboatRailing setTexCoords:[SPPoint pointWithX:xRepeat y:0] ofVertex:1];
    [mSpeedboatRailing setTexCoords:[SPPoint pointWithX:0 y:1] ofVertex:2];
    [mSpeedboatRailing setTexCoords:[SPPoint pointWithX:xRepeat y:1] ofVertex:3];
	
	[self addChild:mRailing];
	[mCannonContainer addChild:mLeftCannon];
    [self addChild:mCannonContainer];
	//[self addChild:mRightCannon];
    
	[mVoodooPlankContainer addChild:mPlank];
    [self addChild:mVoodooPlankContainer];
	[self addChild:mHelm];
	[self addChild:mComboDisplay];
	
[RESM pushItemOffsetWithAlignment:RALowerRight];	
	[mHelm loadFromDictionary:dictionary withKeys:[NSArray arrayWithObjects:[keys objectAtIndex:i++],nil]];
	mHelm.rx = mHelm.x; mHelm.ry = mHelm.y;
[RESM popOffset];
	
[RESM pushItemOffsetWithAlignment:RALowerCenter];
	[mPlank loadFromDictionary:dictionary withKeys:[NSArray arrayWithObjects:[keys objectAtIndex:i++],nil]];
	mPlank.rx = mPlank.x; mPlank.ry = mPlank.y;
    
    mVoodooIdol = [[SPButton alloc] initWithUpState:[mScene textureByName:@"deck-idol"]];
    mVoodooIdol.x = -mVoodooIdol.width / 2;
    [mVoodooIdol addEventListener:@selector(onDeckVoodooIdolPressed:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    
    mVoodooSprite.rx = 220; mVoodooIdol.ry = 272;
    [mVoodooSprite addChild:mVoodooIdol];
    [mVoodooPlankContainer addChild:mVoodooSprite];
[RESM popOffset];
    
    // Move plank and voodoo idol slightly further apart on widescreens.
    if (RESM.width == 568) {
        mPlank.x += 28;
        mVoodooSprite.x -= 8;
    }
	
	[mRightCannon loadFromDictionary:dictionary withKeys:[NSArray arrayWithObjects:[keys objectAtIndex:i++],nil]];
    [mRightCannon enableTouch:NO];
	//mRightCannon.rx = mRightCannon.x; mRightCannon.ry = mRightCannon.y;
	[mLeftCannon loadFromDictionary:dictionary withKeys:[NSArray arrayWithObjects:[keys objectAtIndex:i++],nil]];
	//mLeftCannon.rx = mLeftCannon.x; mLeftCannon.ry = mLeftCannon.y;
    
    mCannonContainer.scaleX = mCannonContainer.scaleY = 1.25f;
    SPRectangle *cannonBounds = [mLeftCannon boundsInSpace:self];
    mCannonContainer.y = mScene.viewHeight - (cannonBounds.y + cannonBounds.height);
    mLeftCannon.elevation = SP_D2R(-11.25f);

    
[RESM pushItemOffsetWithAlignment:RALowerLeft];
	[mComboDisplay loadFromDictionary:dictionary withKeys:[NSArray arrayWithObjects:[keys objectAtIndex:i++],nil]];
	mComboDisplay.rx = mComboDisplay.x; mComboDisplay.ry = mComboDisplay.y;
[RESM popOffset];
	
	if ((gc.playerDetails.abilities & VOODOO_SPELL_FLYING_DUTCHMAN) == VOODOO_SPELL_FLYING_DUTCHMAN) {
		[mRightCannon setupDutchmanTextures];
		[mLeftCannon setupDutchmanTextures];
	}
    
    // Begin retracted
    self.y = mHelm.height;
}

- (BOOL)raceEnabled {
    return (mTimeDial || mSpeedDial || mLapDial);
}

- (void)setHidden:(BOOL)hidden {
    mHelm.visible = !hidden;
	mPlank.visible = !hidden;
    mVoodooIdol.visible = !hidden;
	mRightCannon.visible = !hidden;
	mLeftCannon.visible = !hidden;
	mComboDisplay.visible = !hidden;
    mRailing.visible = !hidden;
}

- (void)flip:(BOOL)enable {
    float flipScaleX = (enable) ? -1 : 1;
    mVoodooSprite.scaleX = flipScaleX;
    mTwitterSprite.scaleX = flipScaleX;
    [mLeftCannon flip:enable];
    [mRightCannon flip:enable];
    
    [mTimeDial flip:enable];
    [mSpeedDial flip:enable];
    [mLapDial flip:enable];
}

- (void)extendOverTime:(float)duration {
    [mScene.juggler removeTweensWithTarget:self];
    
    SPTween *tween = [SPTween tweenWithTarget:self time:duration];
    [tween animateProperty:@"y" targetValue:0];
    [mScene.juggler addObject:tween];
}

- (void)retractOverTime:(float)duration {
    [mScene.juggler removeTweensWithTarget:self];
    
    SPTween *tween = [SPTween tweenWithTarget:self time:duration];
    [tween animateProperty:@"y" targetValue:mHelm.height];
    [mScene.juggler addObject:tween];
}

- (PlayerCannon *)cannonOnSide:(int)side {
	return (side == PortSide) ? mLeftCannon : mRightCannon;
}

- (int)sideForCannon:(PlayerCannon *)cannon {
	return (cannon.direction == 1) ? StarboardSide : PortSide;
}

- (void)activateSpeedboatWithDialDefs:(NSArray *)dialDefs {
    mPlank.visible = NO;
	mRightCannon.visible = NO;
	mLeftCannon.visible = NO;
	mComboDisplay.visible = NO;
    mVoodooIdol.visible = NO;
    mRailing.visible = NO;
    
    [mSpeedboatRailing removeFromParent];
    [self addChild:mSpeedboatRailing atIndex:0];
    [mHelm activateSpeedboat];
    
    if (self.raceEnabled) {
        // Undo possible mph flashing red
        [mSpeedDial setMidTextColor:[DashDial fontColor]];
        return;
    }
    
	if (dialDefs.count < 3 || self.raceEnabled)
		return;
    
	// Time Dial
	mTimeDial = [[DashDial alloc] init];
	[mTimeDial loadFromDictionary:(NSDictionary *)[dialDefs objectAtIndex:0] withKeys:nil];
	[self addChild:mTimeDial];
	
	// Speed Dial
	mSpeedDial = [[DashDial alloc] init];
	[mSpeedDial loadFromDictionary:(NSDictionary *)[dialDefs objectAtIndex:1] withKeys:nil];
	[self addChild:mSpeedDial];
	
	// Lap Dial
	mLapDial = [[DashDial alloc] init];
	[mLapDial loadFromDictionary:(NSDictionary *)[dialDefs objectAtIndex:2] withKeys:nil];
	[self addChild:mLapDial];
    
    if (mScene.flipped) {
        [mTimeDial flip:YES];
        [mSpeedDial flip:YES];
        [mLapDial flip:YES];
    }
}

- (void)deactivateSpeedboat {
    [mTimeDial removeFromParent];
    [mTimeDial release]; mTimeDial = nil;
    
    [mSpeedDial removeFromParent];
    [mSpeedDial release]; mSpeedDial = nil;
    
    [mLapDial removeFromParent];
    [mLapDial release]; mLapDial = nil;
    
    [mSpeedboatRailing removeFromParent];
    [mHelm deactivateSpeedboat];
    
    mPlank.visible = YES;
	mRightCannon.visible = YES;
	mLeftCannon.visible = YES;
	mComboDisplay.visible = YES;
    mVoodooIdol.visible = YES;
    mRailing.visible = YES;
}

- (void)setRaceTime:(NSString *)text {
	[mTimeDial setMidText:text];
}

- (void)setLapTime:(NSString *)text {
	[mTimeDial setBtmText:text];
}

- (void)setMph:(NSString *)text {
	[mSpeedDial setMidText:text];
}

- (void)setLap:(NSString *)text {
	[mLapDial setMidText:text];
}

- (void)flashFailedMphDial {
    if (mSpeedDial) {
        if (mSpeedDial.midTextColor == [DashDial fontColor])
            [mSpeedDial setMidTextColor:0xff0000];
        else
            [mSpeedDial setMidTextColor:[DashDial fontColor]];
    }
}

- (void)travelForwardInTime {
	[mTimeDial setMidText:@"1985"];
	[mTimeDial setBtmText:@"JULY 5TH"];
}

- (void)swapFlyingDutchmanTextures {
	SPTexture *swap = [mRailing.texture retain];
	mRailing.texture = mFlyingDutchmanRailingTexture;
	[mFlyingDutchmanRailingTexture release];
	mFlyingDutchmanRailingTexture = swap; // Inherit swap's retain
    
    swap = [mVoodooIdol.upState retain];
    mVoodooIdol.upState = mFlyingDutchmanVoodooTexture;
    mVoodooIdol.downState = mFlyingDutchmanVoodooTexture;
    [mFlyingDutchmanVoodooTexture release];
    mFlyingDutchmanVoodooTexture = swap; // Inherit swap's retain
}

- (void)activateFlyingDutchman {
	if (mFlyingDutchman == NO) {
		mFlyingDutchman = YES;
		[self swapFlyingDutchmanTextures];
		[mHelm activateFlyingDutchman];
		[mPlank activateFlyingDutchman];
		[mRightCannon activateFlyingDutchman];
		[mLeftCannon activateFlyingDutchman];
		[mComboDisplay activateFlyingDutchman];
	}
}

- (void)deactivateFlyingDutchman {
	if (mFlyingDutchman == YES) {
		mFlyingDutchman = NO;
		[self swapFlyingDutchmanTextures];
		[mHelm deactivateFlyingDutchman];
		[mPlank deactivateFlyingDutchman];
		[mRightCannon deactivateFlyingDutchman];
		[mLeftCannon deactivateFlyingDutchman];
		[mComboDisplay deactivateFlyingDutchman];
	}
}

- (void)setupPotions {
#ifndef CHEEKY_LITE_VERSION
    if (mPotion)
        [self destroyPotions];
    
    NSArray *activePotions = [mScene activePotions];
    
    if (activePotions.count == 0)
        return;

    mPotion = [[SPSprite alloc] init];
    [self addChild:mPotion atIndex:[self childIndex:mRailing]+1];
    
    // Populate with active potions
    int i = 0;
    
    for (Potion *potion in activePotions) {
        SPSprite *potionSprite = [GuiHelper potionSpriteWithPotion:potion size:GuiSizeSml scene:mScene];
        potionSprite.x = potionSprite.width / 2 + 0.9f * i * potionSprite.width;
        [mPotion addChild:potionSprite];
        ++i;
    }
    
    mPotion.x = mScene.viewWidth - mPotion.width;
    mPotion.y = mScene.viewHeight - 0.48f * mPotion.height;
#endif
}

- (void)destroyPotions {
    [mPotion removeFromParent];
    [mPotion release]; mPotion = nil;
}

- (void)enableCombatControls:(BOOL)enable {
    mPlank.touchable = enable;
    mLeftCannon.activated = enable;
    mRightCannon.activated = enable;
    mVoodooIdol.touchable = enable;
}

- (void)showTwitterOverTime:(float)duration {
    if ([ResManager isOSFeatureSupported:@"5.0"] == NO)
        return;
    if (mTwitterButton == nil) {
[RESM pushItemOffsetWithAlignment:RALowerCenter];
        mTwitterButton = [[SPButton alloc] initWithUpState:[mScene textureByName:@"tweet-it"]];
        mTwitterButton.x = -mTwitterButton.width / 2;
        [mTwitterButton addEventListener:@selector(onTwitterButtonPressed:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
        
        mTwitterSprite.rx = 266;
        mTwitterSprite.y = mScene.viewHeight;
        [mTwitterSprite addChild:mTwitterButton];
        [self addChild:mTwitterSprite];
[RESM popOffset];
    }
    
    [mScene.juggler removeTweensWithTarget:mTwitterSprite];
    [mScene.juggler removeTweensWithTarget:mVoodooPlankContainer];
    
    float targetValue = mScene.viewHeight - mTwitterButton.height;
    float tweenDistance = mTwitterSprite.y - targetValue;
    float tweenDuration = duration * (tweenDistance / mTwitterButton.height);
    
    SPTween *tween = [SPTween tweenWithTarget:mTwitterSprite time:tweenDuration];
    [tween animateProperty:@"y" targetValue:targetValue];
    [mScene.juggler addObject:tween];
    
    targetValue = mTwitterButton.height;
    tweenDistance = targetValue - mVoodooPlankContainer.y;
    tweenDuration = duration * (tweenDistance / mTwitterButton.height);
    
    tween = [SPTween tweenWithTarget:mVoodooPlankContainer time:tweenDuration];
    [tween animateProperty:@"y" targetValue:targetValue];
    [mScene.juggler addObject:tween];
    
    mTwitterSprite.visible = YES;
    mTwitterEnabled = YES;
}

- (void)hideTwitterOverTime:(float)duration {
    if ([ResManager isOSFeatureSupported:@"5.0"] == NO || mTwitterButton == nil || mTwitterSprite == nil)
        return;

    [mScene.juggler removeTweensWithTarget:mTwitterSprite];
    [mScene.juggler removeTweensWithTarget:mVoodooPlankContainer];
   
    float targetValue = 0.0f;
    float tweenDistance = mVoodooPlankContainer.y;
    float tweenDuration = duration * (tweenDistance / mTwitterButton.height);
    
    SPTween *tween = [SPTween tweenWithTarget:mVoodooPlankContainer time:tweenDuration];
    [tween animateProperty:@"y" targetValue:targetValue];
    [mScene.juggler addObject:tween];
    
    targetValue = mScene.viewHeight;
    tweenDistance = mScene.viewHeight - mTwitterSprite.y;
    tweenDuration = duration * (tweenDistance / mTwitterButton.height);
    
    tween = [SPTween tweenWithTarget:mTwitterSprite time:tweenDuration];
    [tween animateProperty:@"y" targetValue:targetValue];
    [tween addEventListener:@selector(onTwitterHidden:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
    [mScene.juggler addObject:tween];
    
     mTwitterEnabled = NO;
}

- (void)onTwitterHidden:(SPEvent *)event {
    mTwitterSprite.visible = NO;
}

- (void)onTwitterButtonPressed:(SPEvent *)event {
    if (mTwitterEnabled == NO)
        return;
    [mScene.audioPlayer playSoundWithKey:@"Button"];
    [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_DECK_TWITTER_BUTTON_PRESSED]];
}

- (void)showFlipControlsButton:(BOOL)show {
    if (self.raceEnabled == NO)
        mVoodooPlankContainer.visible = !show;
}

- (void)advanceTime:(double)time {
	[mHelm advanceTime:time];
	[mComboDisplay advanceTime:time];
    [mRightCannon advanceTime:time];
    [mLeftCannon advanceTime:time];
}

- (void)onDeckVoodooIdolPressed:(SPEvent *)event {
    [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_DECK_VOODOO_IDOL_PRESSED]];
}

- (void)dealloc {
    [mVoodooIdol removeEventListener:@selector(onDeckVoodooIdolPressed:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    [mTwitterButton removeEventListener:@selector(onTwitterButtonPressed:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
	[mScene.juggler removeTweensWithTarget:mPlank];
    [mScene.juggler removeTweensWithTarget:mTwitterSprite];
    [mScene.juggler removeTweensWithTarget:mVoodooPlankContainer];
	[mRightCannon destroy];
    [mLeftCannon destroy];
    
	[mRailing release]; mRailing = nil;
    [mSpeedboatRailing release]; mSpeedboatRailing = nil;
    [mFlyingDutchmanVoodooTexture release]; mFlyingDutchmanVoodooTexture = nil;
	[mFlyingDutchmanRailingTexture release]; mFlyingDutchmanRailingTexture = nil;
	[mHelm release]; mHelm = nil;
	[mPlank release]; mPlank = nil;
    [mVoodooIdol release]; mVoodooIdol = nil;
    [mVoodooSprite release]; mVoodooSprite = nil;
    [mVoodooPlankContainer release]; mVoodooPlankContainer = nil;
    [mTwitterButton release]; mTwitterButton = nil;
    [mTwitterSprite release]; mTwitterSprite = nil;
	[mRightCannon release]; mRightCannon = nil;
	[mLeftCannon release]; mLeftCannon = nil;
    [mCannonContainer release]; mCannonContainer = nil;
	[mComboDisplay destroyComboDisplay];
	[mComboDisplay release]; mComboDisplay = nil;
    [mPotion release]; mPotion = nil;
	[mTimeDial release]; mTimeDial = nil;
	[mSpeedDial release]; mSpeedDial = nil;
	[mLapDial release]; mLapDial = nil;
    [super dealloc];
}

@end

