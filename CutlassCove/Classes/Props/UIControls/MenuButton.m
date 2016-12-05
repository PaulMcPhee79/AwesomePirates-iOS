//
//  MenuButton.m
//  Pirates
//
//  Created by Paul McPhee on 24/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "MenuButton.h"
#import "SPButton_Extension.h"
#import "Poly.h"

@implementation MenuButton

@synthesize selected = mSelected;
@synthesize actionSelector = mActionSelector;
@synthesize sfxKey = mSfxKey;
@synthesize sfxVolume = mSfxVolume;
@synthesize toggleOnTexture = mToggleOnTexture;
@synthesize toggleOffTexture = mToggleOffTexture;
@synthesize highlightTexture = mHighlightTexture;
@synthesize highlighted = mHighlighted;
@dynamic isSwitch;

- (id)initWithSelectorName:(NSString *)selectorName upState:(SPTexture*)upState downState:(SPTexture*)downState {
    if (self = [super initWithUpState:upState downState:downState]) {
		mSelected = NO;
		mHighlighted = NO;
		mActionSelector = NSSelectorFromString(selectorName);
		mSfxKey = nil;
		mSfxVolume = 1;
		mToggleOnTexture = nil;
		mToggleOffTexture = nil;
		mHighlightTexture = nil;
		mHighlightImage = nil;
		mVertCount = 0;
		mVertsX = 0;
		mVertsY = 0;
        self.scaleWhenDown = 0.9f;
    }
    return self;
}

- (id)init {
	SPTexture *texture = [[[SPGLTexture alloc] init] autorelease];
	return [self initWithSelectorName:@"default" upState:texture downState:texture];
}

+ (MenuButton*)menuButtonWithSelector:(NSString *)selectorName upState:(SPTexture*)upState downState:(SPTexture*)downState {
    return [[[MenuButton alloc] initWithSelectorName:selectorName upState:upState downState:downState] autorelease];
}

+ (MenuButton*)menuButtonWithSelector:(NSString *)selectorName upState:(SPTexture*)upState {
    return [MenuButton menuButtonWithSelector:selectorName upState:upState downState:upState];
}

- (BOOL)selected {
	return mSelected;
}

- (void)setSelected:(BOOL)value {
	if (value == YES)
		self.backgroundImage.texture = self.downState;
	else
		self.backgroundImage.texture = self.upState;
	mSelected = value;
}

- (void)setHighlighted:(BOOL)value {
	mHighlighted = value;
	
	if (mHighlightTexture == nil)
		return;
	if (value ) {
		if (mHighlightImage == nil) {
			mHighlightImage = [[SPImage alloc] initWithTexture:mHighlightTexture];
			mHighlightImage.x = (self.width - mHighlightImage.width) / 2;
			mHighlightImage.y = (self.height - mHighlightImage.height) / 2;
		}
		[self.contents addChild:mHighlightImage atIndex:0];
	} else {
		if (mHighlightImage)
			[self.contents removeChild:mHighlightImage];
	}
}

- (BOOL)isSwitch {
	return (mToggleOnTexture && mToggleOffTexture);
}

- (void)toggleOn {
	self.upState = mToggleOnTexture;
	self.downState = mToggleOnTexture;
}

- (void)toggleOff {
	self.upState = mToggleOffTexture;
	self.downState = mToggleOffTexture;
}

- (void)populateTouchBoundsWithVerts:(NSArray *)verts {
	if (mVertCount) {
		mVertCount = 0;
		free(mVertsX);
		free(mVertsY);
	}
	
	// Must be a multiple of 2
	if (verts == nil || verts.count == 0 || (verts.count & 1) != 0)
		return;
	
	mVertCount = verts.count / 2;
	mVertsX = (float *)malloc(mVertCount * sizeof(float));
	mVertsY = (float *)malloc(mVertCount * sizeof(float));
	
	for (int i = 0; i < mVertCount; ++i) {
		mVertsX[i] = [(NSNumber *)[verts objectAtIndex:2*i] floatValue];
		mVertsY[i] = [(NSNumber *)[verts objectAtIndex:2*i+1] floatValue];
	}
}

- (void)onTouch:(SPTouchEvent*)touchEvent {
	if (self.enabled == NO)
		return;
	
	if (mVertCount && self.isDown == NO) {
		SPTouch *touch = [[touchEvent touchesWithTarget:self] anyObject];
		SPPoint *pt = [touch locationInSpace:self];
		
		if (!pointInPoly(mVertCount, mVertsX, mVertsY, pt.x, pt.y))
			return;
	}

	[super onTouch:touchEvent];
}

- (void)dealloc {
	[mSfxKey release]; mSfxKey = nil;
	[mToggleOnTexture release]; mToggleOnTexture = nil;
	[mToggleOffTexture release]; mToggleOffTexture = nil;
	[mHighlightTexture release]; mHighlightTexture = nil;
	[mHighlightImage release]; mHighlightImage = nil;
	
	if (mVertCount) {
		mVertCount = 0;
		free(mVertsX);
		free(mVertsY);
	}
	
    [super dealloc];
}

@end

