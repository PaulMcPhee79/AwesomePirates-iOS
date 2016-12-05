//
//  SelButton.m
//  Pirates
//
//  Created by Paul McPhee on 24/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "SelButton.h"


@implementation SelButton

@synthesize toggledOn = mToggledOn;
@synthesize toggledOff = mToggledOff;
@synthesize actionSelector = mActionSelector;
@synthesize sfxKey = mSfxKey;
@synthesize sfxVolume = mSfxVolume;
@dynamic isSwitch;

+ (SelButton *)selButtonWithSelector:(NSString *)selectorName upState:(SPTexture*)upState downState:(SPTexture*)downState {
    return [[[SelButton alloc] initWithSelectorName:selectorName upState:upState downState:downState] autorelease];
}

- (id)initWithSelectorName:(NSString *)selectorName upState:(SPTexture*)upState downState:(SPTexture*)downState {
    if (self = [super initWithUpState:upState downState:downState]) {
		mSfxKey = nil;
		mSfxVolume = 1;
		mToggledOn = nil;
		mToggledOff = nil;
		mActionSelector = NSSelectorFromString(selectorName);
    }
    return self;
}

- (id)init {
	SPTexture *texture = [[[SPGLTexture alloc] init] autorelease];
	return [self initWithSelectorName:@"default" upState:texture downState:texture];
}

- (BOOL)isSwitch {
	return (mToggledOn != nil && mToggledOff != nil);
}

- (void)toggleOn {
	self.upState = mToggledOn;
	self.downState = mToggledOn;
}

- (void)toggleOff {
	self.upState = mToggledOff;
	self.downState = mToggledOff;
}

- (void)dealloc {
	[mSfxKey release]; mSfxKey = nil;
	[mToggledOn release]; mToggledOn = nil;
	[mToggledOff release]; mToggledOff = nil;
    [super dealloc];
}

@end

