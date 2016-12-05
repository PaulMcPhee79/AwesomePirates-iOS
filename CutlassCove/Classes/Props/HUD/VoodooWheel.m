//
//  VoodooWheel.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 13/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VoodooWheel.h"
#import "SPButton_Extension.h"
#import "GameStats.h"
#import "GameController.h"
#import "Globals.h"

typedef enum {
	StateVoodooHidden = 0,
	StateVoodooShowing,
	StateVoodooShown,
	StateVoodooHiding
} VoodooWheelState;

const float kShowTime = 0.5f;
const float kHideTime = 0.5f;
const float kButtonSize = 48.0f;
const float kCooldownAlpha = 0.5f;


@interface VoodooWheel ()

@property (nonatomic,retain) VoodooDial *activePulse;

- (void)setState:(VoodooWheelState)state;
- (void)addGadgetWithKey:(uint)key;
- (void)addTrinketWithKey:(uint)key;
- (void)reset;
- (void)onWheelShown:(SPEvent *)event;
- (void)onWheelHidden:(SPEvent *)event;
- (void)onButtonPressed:(SPEvent *)event;

@end


@implementation VoodooWheel

@synthesize trinketSettings = mTrinketSettings;
@synthesize gadgetSettings = mGadgetSettings;
@synthesize activePulse = mActivePulse;

+ (NSString *)keyToString:(uint)key {
	return [NSString stringWithFormat:@"%d", key];
}

- (id)initWithCategory:(int)category trinkets:(NSArray *)trinkets gadgets:(NSArray *)gadgets {
	if (self = [super initWithCategory:category]) {
		//mAdvanceable = YES;
		mTrinketSettings = [trinkets retain];
		mGadgetSettings = [gadgets retain];
		mMaxWidth = 0;
		mMaxHeight = 0;
		mCancelButton = nil;
        mCanvas = nil;
		mActivePulse = nil;
		mGadgets = [[NSMutableDictionary alloc] initWithCapacity:4];
		mTrinkets = [[NSMutableDictionary alloc] initWithCapacity:4];
		mVoodooDialDictionary = [[NSMutableDictionary alloc] initWithCapacity:8];
		mVoodooDialArray = [[NSMutableArray alloc] initWithCapacity:8];
		
		[self setState:StateVoodooHidden];
		[self setupProp];
	}
	return self;
}

- (id)initWithCategory:(int)category {
	return [self initWithCategory:category trinkets:nil gadgets:nil];
}

- (id)init {
	return [self initWithCategory:CAT_PF_PICKUPS];
}

- (void)setupProp {
	for (Idol *gadget in mGadgetSettings)
		[self addGadgetWithKey:gadget.key];
	
	for (Idol *trinket in mTrinketSettings)
		[self addTrinketWithKey:trinket.key];
	
    // Canvas
    mCanvas = [[SPSprite alloc] init];
    [self addChild:mCanvas];
    
	// Cancel
	mCancelButton = [[SPButton alloc] initWithUpState:[mScene textureByName:@"voodoo-cancel-icon"]];
	mCancelButton.scaleWhenDown = 1.4f;
	mCancelButton.x = -mCancelButton.width / 2;
	mCancelButton.y = -mCancelButton.height / 2;
	[mCancelButton addEventListener:@selector(onButtonPressed:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
	[mCanvas addChild:mCancelButton];
	
	mMaxWidth = mCancelButton.height;
	mMaxHeight = mCancelButton.width;
	
	// Position elements
	if (mVoodooDialArray.count > 0) { // Protect against DBZ
#ifndef CHEEKY_LITE_VERSION
		SPPoint *point = [SPPoint pointWithX:0.0f y:-1.6f * kButtonSize];
#else
        SPPoint *point = [SPPoint pointWithX:0.0f y:-1.4f * kButtonSize];
#endif
		float angularSpacing = TWO_PI / mVoodooDialArray.count;
		
		[Globals rotatePoint:point throughAngle:-1.5f * angularSpacing];
		
		for (VoodooDial *dial in mVoodooDialArray) {
			dial.x = point.x - dial.width / 2;
			dial.y = point.y - dial.height / 2;
			[mCanvas addChild:dial];
			[Globals rotatePoint:point throughAngle:angularSpacing];
			mMaxWidth = MAX(2 * (fabsf(point.x) + dial.width / 2), mMaxWidth);
			mMaxHeight = MAX(2 * (fabsf(point.y) + dial.height / 2), mMaxHeight);
			[dial addEventListener:@selector(onButtonPressed:) atObject:self forType:CUST_EVENT_TYPE_VOODOO_DIAL_PRESSED];
		}
	}
}

- (void)setState:(VoodooWheelState)state {
	switch (state) {
		case StateVoodooHidden:
			self.visible = NO;
			break;
		case StateVoodooShowing:
			[self reset];
			self.visible = YES;
			break;
		case StateVoodooShown:
			self.touchable = YES;
			break;
		case StateVoodooHiding:
			self.touchable = NO;
			break;
	}
	mState = state;
}

- (void)flip:(BOOL)enable {
    mCanvas.scaleX = (enable) ? -1 : 1;
}

- (void)addGadgetWithKey:(uint)key {
#ifdef CHEEKY_LITE_VERSION
    BOOL validLiteKey = NO; 
    NSArray *liteKeys = [Idol gadgetKeysLite];
    
    for (NSNumber *liteKey in liteKeys) {
        if ([liteKey unsignedIntValue] == key) {
            validLiteKey = YES;
            break;
        }
    }
    
    if (validLiteKey == NO)
        return;
#endif
    
    if (key == 0)
        return;
	VoodooDial *dial = [[[VoodooDial alloc] initWithCategory:self.category key:key] autorelease];
	[mGadgets setObject:dial forKey:dial.stringKey];
	[mVoodooDialDictionary setObject:dial forKey:dial.stringKey];
	[mVoodooDialArray addObject:dial];
}

- (void)addTrinketWithKey:(uint)key {
#ifdef CHEEKY_LITE_VERSION
    BOOL validLiteKey = NO;
    NSArray *liteKeys = [Idol voodooKeysLite];
    
    for (NSNumber *liteKey in liteKeys) {
        if ([liteKey unsignedIntValue] == key) {
            validLiteKey = YES;
            break;
        }
    }
    
    if (validLiteKey == NO)
        return;
#endif
    
    if (key == 0)
        return;
	VoodooDial *dial = [[[VoodooDial alloc] initWithCategory:self.category key:key] autorelease];
	[mTrinkets setObject:dial forKey:dial.stringKey];
	[mVoodooDialDictionary setObject:dial forKey:dial.stringKey];
	[mVoodooDialArray addObject:dial];
}

- (VoodooDial *)dialForKey:(uint)key {
	return (VoodooDial *)[mVoodooDialDictionary objectForKey:[VoodooWheel keyToString:key]];
}

- (void)showAtX:(float)x y:(float)y {
	if (mState == StateVoodooShown || mState == StateVoodooShowing)
		return;
	[mScene.hudJuggler removeTweensWithTarget:self];
	[self setState:StateVoodooShowing];
	self.x = MIN(x, mScene.viewWidth - 0.5f * mMaxWidth);
	self.y = MAX(MIN(y, mScene.viewHeight - (55 + 0.5f * mMaxHeight)), 0.5f * mMaxHeight); // 55 is approx height of deck railing + deck idol
	
	SPTween *tween = [SPTween tweenWithTarget:self time:(1.0f - fabsf(self.scaleX)) * kShowTime];
	[tween animateProperty:@"scaleX" targetValue:1.0f];
	[tween animateProperty:@"scaleY" targetValue:1.0f];
	[tween animateProperty:@"rotation" targetValue:self.rotation + TWO_PI];
	[tween addEventListener:@selector(onWheelShown:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
	[mScene.hudJuggler addObject:tween];
}

- (void)hide {
	if (mState == StateVoodooHidden || mState == StateVoodooHiding)
		return;
	[mScene.hudJuggler removeTweensWithTarget:self];
	[self setState:StateVoodooHiding];
	
	SPTween *tween = [SPTween tweenWithTarget:self time:fabsf(self.scaleX) * kHideTime];
	[tween animateProperty:@"scaleX" targetValue:0.0f];
	[tween animateProperty:@"scaleY" targetValue:0.0f];
	[tween animateProperty:@"rotation" targetValue:self.rotation - TWO_PI];
	[tween addEventListener:@selector(onWheelHidden:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
	[mScene.hudJuggler addObject:tween];
}

- (void)reset {
	self.scaleX = 0.0f;
	self.scaleY = 0.0f;
	self.rotation = 0.0f;
}

- (void)enableItem:(BOOL)enable forKey:(uint)key {
	VoodooDial *dial = (VoodooDial *)[mVoodooDialDictionary objectForKey:[VoodooWheel keyToString:key]];
	dial.enabled = enable;
}

- (void)enableAllItems:(BOOL)enable {
	for (VoodooDial *dial in mVoodooDialArray)
		dial.enabled = enable;
}

- (void)onWheelShown:(SPEvent *)event {
	[self setState:StateVoodooShown];
}

- (void)onWheelHidden:(SPEvent *)event {
	[self setState:StateVoodooHidden];
}

- (void)onButtonPressed:(SPEvent *)event {
	[self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_VOODOO_MENU_CLOSING]];
}

- (void)destroyWheel {
	[mScene.hudJuggler removeTweensWithTarget:self];
}

- (void)dealloc {
	[mCancelButton removeEventListener:@selector(onButtonPressed:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
	
	for (VoodooDial *dial in mVoodooDialArray)
		[dial removeEventListener:@selector(onButtonPressed:) atObject:self forType:CUST_EVENT_TYPE_VOODOO_DIAL_PRESSED];
	
	[mActivePulse release]; mActivePulse = nil;
	[mCancelButton release]; mCancelButton = nil;
    [mCanvas release]; mCanvas = nil;
	[mGadgets release]; mGadgets = nil;
	[mTrinkets release]; mTrinkets = nil;
	[mVoodooDialArray release]; mVoodooDialArray = nil;
	[mVoodooDialDictionary release]; mVoodooDialDictionary = nil;
	[mTrinketSettings release]; mTrinketSettings = nil;
	[mGadgetSettings release]; mGadgetSettings = nil;
	[super dealloc];
}

@end

/////////////////////////////////////////////////////////////////

@interface VoodooDial ()

- (void)onButtonPressed:(SPEvent *)event;

@end


@implementation VoodooDial

@synthesize numericKey = mNumericKey;
@synthesize stringKey = mStringKey;
@synthesize button = mButton;
@dynamic enabled;

- (id)initWithCategory:(int)category key:(uint)key {
	if (self = [super initWithCategory:category]) {
		self.touchable = YES;
		mNumericKey = key;
		mStringKey = [[VoodooWheel keyToString:key] copy];
		mButton = nil;
		[self setupProp];
	}
	return self;
}

- (void)dealloc {
	[mButton removeEventListener:@selector(onButtonPressed:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
	[mButton release]; mButton = nil;
	[mStringKey release]; mStringKey = nil;
	[super dealloc];
}

- (void)setupProp {
	if (mButton)
		return;
	
	assert(self.numericKey != 0);
    SPTexture *iconTexture = [mScene textureByName:[Idol iconTextureNameForKey:self.numericKey]];
	
	// Button
	mButton = [[SPButton alloc] initWithUpState:iconTexture];
	mButton.alphaWhenDisabled = 0.3f;
	mButton.scaleWhenDown = 1.4f;
	[mButton addEventListener:@selector(onButtonPressed:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
	[self addChild:mButton];
	
	if (self.numericKey == 0) {
        self.enabled = NO;
		return;
    }
}

- (BOOL)enabled {
	return mButton.enabled;
}

- (void)setEnabled:(BOOL)value {
	mButton.enabled = (self.numericKey != 0 && value);
}

- (void)onButtonPressed:(SPEvent *)event {
	[self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_VOODOO_DIAL_PRESSED]];
}

@end
