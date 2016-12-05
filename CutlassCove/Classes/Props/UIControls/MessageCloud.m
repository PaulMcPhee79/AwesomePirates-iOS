//
//  MessageCloud.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 5/10/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "MessageCloud.h"
#import "Globals.h"

const float kMessageWidth = 150.0f;
const float kMessageHeight = 68.0f;
const float kMessageFontSize = 14.0f;

@interface MessageCloud ()

- (void)onDismissedComplete:(SPEvent *)event;
- (void)onTouch:(SPTouchEvent *)event;

@end


@implementation MessageCloud

@synthesize state = mState;
@synthesize choice = mChoice;

- (id)initWithCategory:(int)category x:(float)x y:(float)y dir:(int)dir {
	if (self = [super initWithCategory:category]) {
		self.touchable = YES;
		mState = kMsgCloudStateNull;
		mChoice = NO;
		self.x = x;
		self.y = y;
		mDir = dir;
		mText = nil;
		mButtonLeft = nil;
		mButtonRight = nil;
		[self setupProp];
	}
	return self;
}

- (id)initWithCategory:(int)category dir:(int)dir {
	return [self initWithCategory:category x:0.0f y:0.0f dir:dir];
}

- (id)initWithCategory:(int)category {
	return [self initWithCategory:category x:0.0f y:0.0f dir:1];
}

- (void)setupProp {
	if (mText != nil)
		return;
	[super setupProp];
	
	SPImage *image = [SPImage imageWithTexture:[mScene.helpAtlas textureByName:@"speech-bubble"]];
	//image.scaleX = 2.0f;
	//image.scaleY = 2.0f;
	[self addChild:image];
	
	mText = [[SPTextField textFieldWithWidth:kMessageWidth
									  height:kMessageHeight 
										text:@""
									fontName:mScene.fontKey
									fontSize:kMessageFontSize
									   color:0]
			 retain];
	mText.hAlign = SPHAlignCenter;
	mText.vAlign = SPVAlignCenter;
	mText.x = 25.0f;
	mText.y = 25.0f;
	[self addChild:mText];
	
	if (mDir == -1) {
		image.scaleX *= -1;
		image.x += image.width;
		mText.x = 27.0f;
	}
	
	[self addEventListener:@selector(onTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
}

- (void)setState:(int)state {
	if (mButtonLeft != nil) {
		[self removeChild:mButtonLeft];
		[mButtonLeft release];
		mButtonLeft = nil;
	}
	
	if (mButtonRight != nil) {
		[self removeChild:mButtonRight];
		[mButtonRight release];
		mButtonRight = nil;
	}
	
	NSString *texLeft = nil, *texRight = nil;
	
	switch (state) {
		case kMsgCloudStateNext:
			texRight = @"msg-next";
			break;
		case kMsgCloudStateAye:
			texRight = @"msg-aye";
			break;
		case kMsgCloudStateChoice:
			texLeft = @"msg-aye";
			texRight = @"msg-nay";
			break;
		case kMsgCloudStateNull:
		case kMsgCloudStateClosing:
		default:
			break;
	}
	
	// Setup buttons for state
	//float buttonX = (mDir == 1) ? 68.0f : 133.0f, buttonY = 96.0f;
    float buttonX = 110.0f, buttonY = 103.0f;
	
	if (texLeft != nil)
		buttonX -= 20.0f;
	
	if (texLeft != nil) {
		if (mButtonLeft == nil)
			mButtonLeft = [[SPButton buttonWithUpState:[mScene.helpAtlas textureByName:texLeft]] retain];
		mButtonLeft.x = buttonX - mButtonLeft.width / 2;
		buttonX += mButtonLeft.width;
		mButtonLeft.y = buttonY - mButtonLeft.height / 2;
		[self addChild:mButtonLeft];
		[mButtonLeft addEventListener:@selector(onCloudButtonTriggered:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
	}
	
	if (texRight != nil) {
		if (mButtonRight == nil)
			mButtonRight = [[SPButton buttonWithUpState:[mScene.helpAtlas textureByName:texRight]] retain];
		mButtonRight.x = buttonX + 5.0f - mButtonRight.width / 2;
		mButtonRight.y = buttonY - mButtonRight.height / 2;
		[self addChild:mButtonRight];
		[mButtonRight addEventListener:@selector(onCloudButtonTriggered:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
	}
	mState = state;
}

- (void)setMessageText:(NSString *)text {
	mText.text = text;
}

- (void)onCloudButtonTriggered:(SPEvent *)event {
	switch (mState) {
		case kMsgCloudStateNext:
			[self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_MSG_CLOUD_NEXT]];
			break;
		case kMsgCloudStateAye:
			mChoice = YES;
			[self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_MSG_CLOUD_CHOICE]];
			break;
		case kMsgCloudStateChoice:
		{
			SPButton *button = (SPButton *)event.currentTarget;
			
			mChoice = (button == mButtonLeft) ? YES : NO;
			[self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_MSG_CLOUD_CHOICE]];
			break;
		}
		default:
			break;
	}
}

- (void)onTouch:(SPTouchEvent *)event {
	SPTouch *touch = [[event touchesWithTarget:self andPhase:SPTouchPhaseEnded] anyObject];
	
	if (touch) {
		if (mState == kMsgCloudStateNext) {
			[self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_MSG_CLOUD_NEXT]];
		} else if (mState == kMsgCloudStateAye) {
			mChoice = YES;
			[self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_MSG_CLOUD_CHOICE]];
		}
	}
}

- (void)dismissOverTime:(float)time; {
	if (mState == kMsgCloudStateClosing)
		return;
	self.state = kMsgCloudStateClosing;
	
	SPTween *tween = [SPTween tweenWithTarget:self time:time transition:SP_TRANSITION_LINEAR];
	[tween animateProperty:@"alpha" targetValue:0.0f];
	[tween addEventListener:@selector(onDismissedComplete:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
	[mScene.juggler addObject:tween];
}

- (void)dismissInstantly {
	[mScene.juggler removeTweensWithTarget:self];
	[mScene removeProp:self];
}

- (void)onDismissedComplete:(SPEvent *)event {
	[self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_MSG_CLOUD_DISMISSED]];
	[self dismissInstantly];
}

- (void)dealloc {
	[mButtonLeft removeEventListener:@selector(onCloudButtonTriggered:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
	[mButtonRight removeEventListener:@selector(onCloudButtonTriggered:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
	
	[mText release]; mText = nil;
	[mButtonLeft release]; mButtonLeft = nil;
	[mButtonRight release]; mButtonRight = nil;
	[super dealloc];
}

@end
