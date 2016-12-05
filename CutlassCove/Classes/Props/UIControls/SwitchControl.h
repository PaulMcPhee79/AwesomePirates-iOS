//
//  SwitchControl.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 30/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"
#import "SwitchFlippedEvent.h"

typedef enum {
	SwitchSizeSmall = 0,
	SwitchSizeLarge
} SwitchSize;


@interface SwitchControl : Prop {
	BOOL mState;
	BOOL mLocked;
	BOOL mMoved;
	
	float mSliderMin;
	float mSliderMax;
	float mSwitchWidth;
	float mSwitchHeight;
	
	SwitchSize mSize;
	SPImage *mLock;
	SPImage *mSliderImage;
	SPSprite *mSlider;
	
	SPTextField *mOnTextfield;
	SPTextField *mOffTextfield;
}

@property (nonatomic,assign) BOOL state;
@property (nonatomic,assign) BOOL locked;

// Valid sizes are 0: Small; 1: Large
- (id)initWithCategory:(int)category state:(BOOL)state;
- (id)initWithCategory:(int)category state:(BOOL)state size:(SwitchSize)size;
- (void)setOnColor:(uint)color;
- (void)setOffColor:(uint)color;
- (void)setOnText:(NSString *)text;
- (void)setOffText:(NSString *)text;
+ (uint)onColor;
+ (uint)offColor;

@end

