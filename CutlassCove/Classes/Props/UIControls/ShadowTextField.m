//
//  ShadowTextField.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 27/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ShadowTextField.h"


@implementation ShadowTextField

@dynamic fontColor,shadowColor,text;

- (id)initWithCategory:(int)category width:(float)width height:(float)height fontSize:(float)fontSize {
	if (self = [super initWithCategory:category]) {
		// Textfield
		mTextField = [[SPTextField textFieldWithWidth:width height:height 
						text:@"" fontName:mScene.fontKey fontSize:fontSize color:SP_WHITE] retain];
		mTextField.hAlign = SPHAlignCenter;
		mTextField.vAlign = SPVAlignCenter;
        mTextField.compiled = NO;
		
		// Drop shadow
		mDropShadow = [[SPTextField textFieldWithWidth:width height:height 
						text:@"" fontName:mScene.fontKey fontSize:fontSize color:SP_BLACK] retain];
		mDropShadow.hAlign = SPHAlignCenter;
		mDropShadow.vAlign = SPVAlignCenter;
        mDropShadow.compiled = NO;
		mDropShadow.x = 1.0f;
		mDropShadow.y = 1.0f;
		[self setupProp];
	}
	return self;
}

- (void)setupProp {
	[self addChild:mDropShadow];
	[self addChild:mTextField];
    [mDropShadow preCache];
    [mTextField preCache];
}

- (id)initWithCategory:(int)category {
	return [self initWithCategory:category width:128.0f height:16.0f fontSize:14];
}

- (uint)fontColor {
	return mTextField.color;
}

- (void)setFontColor:(uint)value {
	mTextField.color = value;
}

- (uint)shadowColor {
	return mDropShadow.color;
}

- (void)setShadowColor:(uint)value {
	mDropShadow.color = value;
}

- (NSString *)text {
	return mTextField.text;
}

- (void)setText:(NSString *)text {
	mTextField.text = text;
	mDropShadow.text = text;
}

- (void)dropShadowOffsetX:(float)x y:(float)y {
	mDropShadow.x = x;
	mDropShadow.y = y;
}

- (void)dealloc {
	[mTextField release]; mTextField = nil;
	[mDropShadow release]; mDropShadow = nil;
	[super dealloc];
}

@end
