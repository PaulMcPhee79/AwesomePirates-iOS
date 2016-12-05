//
//  SwitchControl.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 30/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SwitchControl.h"
#import "GuiHelper.h"
#import "Globals.h"

const float kSwitchFontSize = 18.0f;

@interface SwitchControl ()

- (void)snapToPosition:(BOOL)snapState animated:(BOOL)animated;

@end


@implementation SwitchControl

@synthesize state = mState;
@synthesize locked = mLocked;

+ (uint)onColor {
	return 0x0000ff;
}

+ (uint)offColor {
	return 0;
}

- (id)initWithCategory:(int)category state:(BOOL)state size:(SwitchSize)size {
	if (self = [super initWithCategory:category]) {
        self.touchable = YES;
		mState = state;
		mSize = size;
		mLocked = NO;
		mLock = nil;
		mSliderImage = nil;
		mSlider = nil;
		mOnTextfield = nil;
		mOffTextfield = nil;
		
		if (size == SwitchSizeSmall) {
			mSliderMin = 6;
			mSliderMax = 45;
			mSwitchWidth = 90;
			mSwitchHeight = 27;
		} else {
            assert(0); // Not currently supported by graphics resources
			mSliderMin = 10;
			mSliderMax = 86;
			mSwitchWidth = 172;
			mSwitchHeight = 27;
		}
		
		[self setupProp];
	}
	return self;
}

- (id)initWithCategory:(int)category state:(BOOL)state {
	return [self initWithCategory:category state:state size:SwitchSizeSmall];
}

- (id)initWithCategory:(int)category {
	return [self initWithCategory:category state:NO];
}

- (void)setupProp {
	SPTexture *texture = [GuiHelper cachedScrollTextureByName:@"scroll-quarter-small" scene:mScene];
	SPImage *bgImage = [[SPImage alloc] initWithTexture:texture];
	bgImage.x = -bgImage.width / 2;
	bgImage.y = -bgImage.height / 2;
	
	SPSprite *sprite = [SPSprite sprite];
	sprite.touchable = NO;
	sprite.x = mSwitchWidth / 2;
	sprite.y = mSwitchHeight / 2;
	sprite.scaleX = mSwitchWidth / bgImage.width;
	sprite.scaleY = 0.15f;
	[sprite addChild:bgImage];
	[self addChild:sprite];
	
	[bgImage release];
	bgImage = nil;
	
	// On text
	mOnTextfield = [[SPTextField alloc] initWithWidth:mSwitchWidth / 2
											   height:kSwitchFontSize
												 text:@"On"
											 fontName:mScene.fontKey
											 fontSize:kSwitchFontSize
												color:[SwitchControl onColor]];
	mOnTextfield.touchable = NO;
	mOnTextfield.x = 4 + sprite.width / 4 - mOnTextfield.width / 2;
	mOnTextfield.y = sprite.height / 2 - mOnTextfield.height / 2;
	mOnTextfield.hAlign = SPHAlignCenter;
	mOnTextfield.vAlign = SPVAlignCenter;
	[self addChild:mOnTextfield];
	
	// Off text
	mOffTextfield = [[SPTextField alloc] initWithWidth:mSwitchWidth / 2
												height:kSwitchFontSize
												  text:@"Off"
											  fontName:mScene.fontKey
											  fontSize:kSwitchFontSize
												 color:[SwitchControl offColor]];
	mOffTextfield.touchable = NO;
	mOffTextfield.x = -4 + 3 * sprite.width / 4 - mOffTextfield.width / 2;
	mOffTextfield.y = sprite.height / 2 - mOffTextfield.height / 2;
	mOffTextfield.hAlign = SPHAlignCenter;
	mOffTextfield.vAlign = SPVAlignCenter;
	[self addChild:mOffTextfield];
	
	// Slider
	mSlider = [[SPSprite alloc] init];
	mSlider.y = 1;
	[mSlider addEventListener:@selector(onTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
	[self addChild:mSlider];
	
	NSString *sliderTextureName = (mSize == SwitchSizeSmall) ? @"switch-button" : @"switch-button-large";
	mSliderImage = [[SPImage alloc] initWithTexture:[mScene textureByName:sliderTextureName]];
	[mSlider addChild:mSliderImage];
	
	// Move to initial position
	[self snapToPosition:mState animated:NO];
}

- (void)setState:(BOOL)state {
	if (state != mState) {
		[self snapToPosition:state animated:YES];
		mState = state;
		[self dispatchEvent:[SwitchFlippedEvent switchFlippedEventWithState:mState bubbles:NO]];
	}
}

- (void)setLocked:(BOOL)value {
	mLocked = value;
	
	if (mLocked) {
		if (mLock == nil) {
			SPSprite *sprite = [SPSprite sprite];
			sprite.x = mSlider.width / 2;
			sprite.y = mSlider.height / 2;
			sprite.scaleX = sprite.scaleY = 0.75f;
			sprite.touchable = NO;
			[mSlider addChild:sprite];
			
			mLock = [[SPImage alloc] initWithTexture:[mScene textureByName:@"locked"]];
			mLock.x = -mLock.width / 2;
			mLock.y = -mLock.height / 2;
			[sprite addChild:mLock];
		}
		mLock.visible = YES;
	} else {
		mLock.visible = NO;
	}
}

- (void)setOnColor:(uint)color {
	mOnTextfield.color = color;
}

- (void)setOffColor:(uint)color {
	mOffTextfield.color = color;
}

- (void)setOnText:(NSString *)text {
	mOnTextfield.text = text;
}

- (void)setOffText:(NSString *)text {
	mOffTextfield.text = text;
}

- (void)snapToPosition:(BOOL)snapState animated:(BOOL)animated {
	float dest = (snapState == YES) ? mSliderMax : mSliderMin;
	
	if (animated == NO) {
		mSlider.x = dest;
	} else {
		SPTween *tween = [SPTween tweenWithTarget:mSlider time:0.25f * (fabsf(dest - mSlider.x) / mSlider.width)];
		[tween animateProperty:@"x" targetValue:dest];
		[mScene.juggler addObject:tween];
	}
}

- (void)onTouch:(SPTouchEvent *)event {
	if (mLocked)
		return;
	[mScene.juggler removeTweensWithTarget:mSlider];
	
	SPTouch *touch = [[event touchesWithTarget:mSlider andPhase:SPTouchPhaseBegan] anyObject];
	
	if (touch)
		mMoved = NO;
	
	touch = [[event touchesWithTarget:mSlider andPhase:SPTouchPhaseMoved] anyObject];
	
	if (touch) {
		SPPoint *current = [touch locationInSpace:self];
		SPPoint *previous = [touch previousLocationInSpace:self];
		
		mSlider.x += current.x - previous.x;
		mSlider.x = MAX(mSliderMin, MIN(mSliderMax, mSlider.x));
		mMoved = YES;
	}
	
	touch = [[event touchesWithTarget:mSlider andPhase:SPTouchPhaseEnded] anyObject];
	
	if (touch == nil)
		touch = [[event touchesWithTarget:mSlider andPhase:SPTouchPhaseCancelled] anyObject];
		
	if (touch) {
		BOOL mOldState = self.state;
		
		if (mMoved == NO) {
			[self setState:!self.state];
		} else if (mState == NO && mSlider.x > mSliderMin)
			[self setState:YES];
		else if (mState == YES && mSlider.x < mSliderMax)
			[self setState:NO];
		
		if (self.state != mOldState)
			[mScene.audioPlayer playSoundWithKey:@"GuiSwitch"];
	}
}

- (void)dealloc {
	[mScene.juggler removeTweensWithTarget:mSlider];
	[mSlider removeEventListener:@selector(onTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
	[mSlider release]; mSlider = nil;
	[mSliderImage release]; mSliderImage = nil;
	[mLock release]; mLock = nil;
	[mOnTextfield release]; mOnTextfield = nil;
	[mOffTextfield release]; mOffTextfield = nil;
	[super dealloc];
}

@end
