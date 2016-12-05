//
//  FloatingText.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 21/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

@class RingBuffer;

@interface FloatingText : Prop {
	int mFloatDirection;
	int mFloatDistance;
	float mFloatDuration;
	float mFontSize;
	
	NSString *mAlphaTransition;
	RingBuffer *mTextfields;
	SPJuggler *mJuggler;
}

@property (nonatomic,readonly) SPJuggler *juggler;
@property (nonatomic,assign) int floatDistance;
@property (nonatomic,assign) int floatDirection;
@property (nonatomic,assign) float floatDuration;
@property (nonatomic,copy) NSString *alphaTransition;

- (id)initWithCategory:(int)category width:(float)width height:(float)height fontSize:(float)fontSize capacity:(int)capacity;
- (void)launchTextWithText:(NSString *)text x:(float)x y:(float)y color:(uint)color;
- (void)destroyFloatingText;

@end
