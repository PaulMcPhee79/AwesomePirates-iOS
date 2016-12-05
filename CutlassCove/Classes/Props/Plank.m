//
//  Plank.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 18/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "Plank.h"
#import "Prisoner.h"
#import "PlayerDetails.h"
#import "ShipDetails.h"
#import "NumericValueChangedEvent.h"
#import "GameController.h"

@interface Plank ()

@property (nonatomic,retain) SPImage *victimImage;

- (BOOL)pushVictim;
- (void)nextVictim;
- (void)onVictimSummoned:(SPEvent *)event;
- (void)onVictimPushed:(SPEvent *)event;
- (void)onTouch:(SPTouchEvent *)event;

@end

@implementation Plank

@synthesize state = mState;
@synthesize victim = mVictim;
@synthesize victimImage = mVictimImage;
@synthesize shipDetails = mShipDetails;

- (id)initWithShipDetails:(ShipDetails *)shipDetails {
    if (self = [super initWithCategory:-1]) {
		mStateLocked = NO;
		self.touchable = YES;
		mFlyingDutchman = NO;
		mPlankImage = nil;
		mShipDetails = [shipDetails retain];
        mVictim = nil;
		mVictimImage = nil;
		mVictimSprite = [[SPSprite alloc] init];
		mVictimSprite.x = 16.0f;
		mVictimSprite.y = -36.0f;
		mVictimSprite.visible = NO;
		mVictimSprite.touchable = NO;
		mFlyingDutchmanTexture = [[mScene textureByName:@"ghost-plank"] retain];
		self.state = PlankStateInactive;
        [self nextVictim];
    }
    return self;
}

- (void)loadFromDictionary:(NSDictionary *)dictionary withKeys:(NSArray *)keys {
	NSDictionary *dict = [dictionary objectForKey:@"Plank"];
	float x = [(NSNumber *)[dict objectForKey:@"x"] floatValue];
	float y = [(NSNumber *)[dict objectForKey:@"y"] floatValue];
	dict = [dictionary objectForKey:@"Types"];
	
	int i = 0;
	NSString *key = [keys objectAtIndex:i++];
	dict = [dict objectForKey:key];
	dict = [dict objectForKey:@"Textures"];
	NSString *plank = [dict objectForKey:@"plankTexture"];
	
	SPTexture *texture = [mScene textureByName:plank];
	
	if (mPlankImage == nil) {
		mPlankImage = [[SPImage imageWithTexture:texture] retain];
		mPlankImage.touchable = NO;
		[self addChild:mPlankImage];
	} else {
		mPlankImage.texture = texture;
	}
	
	if (mTouchQuad == nil) {
		mTouchQuad = [[SPQuad quadWithWidth:40.0f height:72.0f] retain];
		mTouchQuad.x = mPlankImage.x + (mPlankImage.width - mTouchQuad.width) / 2;
		mTouchQuad.y = mPlankImage.y + (mPlankImage.height - mTouchQuad.height) / 2;
		mTouchQuad.alpha = 0;
		[self addChild:mTouchQuad];
		[mTouchQuad addEventListener:@selector(onTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
	}
	
	self.x = x;
	self.y = y;
}

- (void)setShipDetails:(ShipDetails *)shipDetails {
    if (shipDetails != mShipDetails) {
        [shipDetails retain];
        [mShipDetails autorelease];
        mShipDetails = shipDetails;
    }
    
    [mScene.juggler removeTweensWithTarget:mVictimSprite];
    mVictimSprite.visible = NO;
    mStateLocked = NO;
    [self nextVictim];
}

- (void)nextVictim {
    if (mStateLocked == NO) {
		[mVictim autorelease]; mVictim = nil;
		mVictim = [self.shipDetails.plankVictim retain];
		[self setState:((self.victim == nil) ? PlankStateInactive : PlankStateActive)];
	}
}

- (void)setState:(PlankState)state {
	if (mStateLocked)
		return;
	
	switch (state) {
		case PlankStateInactive:
			self.alpha = 0.5f;
			break;
		case PlankStateActive:
			self.alpha = 1.0f;
			break;
		case PlankStateDeadManWalking:
			if (![self pushVictim])
				return;
			break;
		default:
			assert(0);
	}
	mState = state;
}

- (void)activateFlyingDutchman {
	if (mFlyingDutchman == NO) {
		mFlyingDutchman = YES;
		SPTexture *swap = [mPlankImage.texture retain];
		mPlankImage.texture = mFlyingDutchmanTexture;
		[mFlyingDutchmanTexture release];
		mFlyingDutchmanTexture = swap;
	}
}

- (void)deactivateFlyingDutchman {
	if (mFlyingDutchman == YES) {
		mFlyingDutchman = NO;
		SPTexture *swap = [mPlankImage.texture retain];
		mPlankImage.texture = mFlyingDutchmanTexture;
		[mFlyingDutchmanTexture release];
		mFlyingDutchmanTexture = swap;
	}
}

- (BOOL)pushVictim {
	if (mVictim == nil || self.touchable == NO)
		return NO;
	mStateLocked = YES;
	[self playVictimPushedSound];

	SPTexture *texture = [mScene textureByName:mVictim.textureName cacheGroup:TM_CACHE_SHARK];
	
	if (self.victimImage == nil) {
		self.victimImage = [SPImage imageWithTexture:texture];
		mVictimImage.x = -mVictimImage.width / 2;
		mVictimImage.y = -mVictimImage.height / 2;
		[mVictimSprite addChild:mVictimImage];
		[self addChild:mVictimSprite];
	} else {
		mVictimImage.texture = texture;
	}
	mVictimSprite.alpha = 0.0f;
	mVictimSprite.scaleX = 1.0f;
	mVictimSprite.scaleY = 1.0f;
	mVictimSprite.visible = YES;
	
	SPTween *tween = [SPTween tweenWithTarget:mVictimSprite time:0.5f transition:SP_TRANSITION_LINEAR];
	[tween animateProperty:@"alpha" targetValue:1.0f];
	[tween addEventListener:@selector(onVictimSummoned:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
	[mScene.juggler addObject:tween];
	return YES;
}

- (void)onVictimSummoned:(SPEvent *)event {
	SPTween *tween = [SPTween tweenWithTarget:mVictimSprite time:0.75f transition:SP_TRANSITION_LINEAR];
	[tween animateProperty:@"alpha" targetValue:0.0f];
	[tween animateProperty:@"scaleX" targetValue:0.0f];
	[tween animateProperty:@"scaleY" targetValue:0.0f];
	[tween addEventListener:@selector(onVictimPushed:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
	[mScene.juggler addObject:tween];
}

- (void)onVictimPushed:(SPEvent *)event {
	mVictim.planked = YES;
	
	if (GCTRL.thisTurn.isGameOver == NO)
        [mScene prisonerOverboard:mVictim ship:nil];
    mStateLocked = NO;
	mVictimSprite.visible = NO;
    [self nextVictim];
}

-(void)onTouch:(SPTouchEvent *)event {
    [event stopImmediatePropagation];
    
	if (mStateLocked || mState != PlankStateActive || self.touchable == NO)
		return;
	
	SPTouch *touch = [[event touchesWithTarget:mTouchQuad andPhase:SPTouchPhaseEnded] anyObject];
	
	if (touch)
		self.state = PlankStateDeadManWalking;
}

- (void)onPrisonersChanged:(NumericValueChangedEvent *)event {
	[self nextVictim];
}

- (void)playVictimPushedSound {
	//[mScene.audioPlayer playSoundWithKey:@"ScreamMan" volume:1.0f];
}

- (void)dealloc {
	[mTouchQuad removeEventListener:@selector(onTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
	[mScene.juggler removeTweensWithTarget:mVictimSprite];
	self.victimImage = nil;
	[mFlyingDutchmanTexture release]; mFlyingDutchmanTexture = nil;
	[mTouchQuad release]; mTouchQuad = nil;
	[mPlankImage release]; mPlankImage = nil;
	[mVictim release]; mVictim = nil;
	[mShipDetails release]; mShipDetails = nil;
	[mVictimSprite release]; mVictimSprite = nil;
    [super dealloc];
}

@end
