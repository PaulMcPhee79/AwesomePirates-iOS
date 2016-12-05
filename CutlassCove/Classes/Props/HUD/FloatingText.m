//
//  FloatingText.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 21/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "FloatingText.h"
#import "RingBuffer.h"
#import "Globals.h"

const float kDefaultFontSize = 20.0f;

@interface FloatingText ()

- (void)onTextFaded:(SPEvent *)event;

@end


@implementation FloatingText

@synthesize juggler = mJuggler;
@synthesize floatDistance = mFloatDistance;
@synthesize floatDirection = mFloatDirection;
@synthesize floatDuration = mFloatDuration;
@synthesize alphaTransition = mAlphaTransition;

- (id)initWithCategory:(int)category width:(float)width height:(float)height fontSize:(float)fontSize capacity:(int)capacity {
	if (self = [super initWithCategory:category]) {
		mAdvanceable = YES;
		self.touchable = NO;
		
		if (capacity > 0)
			mTextfields = [[RingBuffer alloc] initWithCapacity:capacity];
		else
			mTextfields = nil;
		mFloatDistance = 0;
		mFloatDirection = -1;
		mFloatDuration = 2.0f;
		mFontSize = fontSize;
		mAlphaTransition = [[NSString stringWithFormat:@"%@", SP_TRANSITION_LINEAR] copy];
		
		NSString *fontName = mScene.fontKey;
		SPTextField *textfield = nil;
		
		for (int i = 0; i < capacity; ++i) {
			textfield = [SPTextField textFieldWithWidth:width height:height text:@""];
			textfield.touchable = NO;
			textfield.visible = NO;
			textfield.x = 0.0f;
			textfield.y = 0.0f;
			textfield.fontName = fontName;
			textfield.fontSize = mFontSize;
			textfield.color = SP_WHITE;
			textfield.hAlign = SPHAlignLeft;
			textfield.vAlign = SPVAlignCenter;
            textfield.compiled = NO;
			[mTextfields addItem:textfield];
		}
		
		mJuggler = [[SPJuggler alloc] init];
    }
    return self;
}

- (id)initWithCategory:(int)category {
	return [self initWithCategory:category width:6 * kDefaultFontSize height:kDefaultFontSize + 4 fontSize:kDefaultFontSize capacity:5];
}

- (void)launchTextWithText:(NSString *)text x:(float)x y:(float)y color:(uint)color {
	SPSprite *sprite = [SPSprite sprite];
	sprite.x = x;
	sprite.y = y;
	[self addChild:sprite];
	
	SPTextField *textfield = mTextfields.nextItem;
	
	if (textfield == nil) { // Will be null if we were initiated with 0 capacity for ad hoc, non-buffered use.
		float textWidth = mFontSize * [text length] / 1.75f;
		float textHeight = 1.2f * mFontSize;
		textfield = [SPTextField textFieldWithWidth:textWidth
											 height:textHeight
											   text:text
										   fontName:mScene.fontKey
										   fontSize:mFontSize
											  color:color];
		textfield.hAlign = SPHAlignLeft;
		textfield.vAlign = SPVAlignCenter;
        textfield.compiled = NO;
	} else {
		textfield.text = text;
		textfield.color = color;
	}
	
	textfield.x = 0;
	textfield.y = 0;
	textfield.alpha = 1.0f;
	textfield.visible = YES;
	[sprite addChild:textfield];
	
	float dist = (mFloatDistance == 0) ? sprite.height : mFloatDistance;
	SPTween *tween = [SPTween tweenWithTarget:sprite time:mFloatDuration transition:SP_TRANSITION_LINEAR];
	[tween animateProperty:@"y" targetValue:y + mFloatDirection * dist];
	[mJuggler addObject:tween];
	
	tween = [SPTween tweenWithTarget:sprite time:tween.time transition:mAlphaTransition];
	[tween animateProperty:@"alpha" targetValue:0.0f];
	[tween addEventListener:@selector(onTextFaded:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
	[mJuggler addObject:tween];
}

- (void)onTextFaded:(SPEvent *)event {
	SPTween *tween = (SPTween *)event.currentTarget;
	SPSprite *sprite = (SPSprite *)tween.target;
	
	// Set textfield invisible
	if (sprite.numChildren > 0) {
		SPDisplayObject *displayObject = [sprite childAtIndex:0];
		displayObject.visible = NO;
		[self removeChild:sprite];
	}
}

- (void)advanceTime:(double)time {
	[mJuggler advanceTime:time];
}

- (void)destroyFloatingText {
	[mJuggler removeAllObjects];
}

- (void)dealloc {
	[mAlphaTransition release]; mAlphaTransition = nil;
	[mTextfields release]; mTextfields = nil;
	[mJuggler release]; mJuggler = nil;
    [super dealloc];
}

@end

