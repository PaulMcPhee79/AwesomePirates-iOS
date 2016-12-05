//
//  NumericTextfield.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 23/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NumericTextfield.h"
#import "SPBitmapFont_Extension.h"

@interface NumericTextfield ()

- (SPTexture *)textureWithID:(int)charID;

@end


@implementation NumericTextfield

- (id)initWithCategory:(int)category maxChars:(uint)maxChars {
	if (self = [super initWithCategory:category]) {
		mMaxChars = maxChars;
		mChars = [[NSMutableArray alloc] initWithCapacity:maxChars];
		[self setupProp];
	}
	return self;
}

- (void)setupProp {
	//SPTexture *texture = [self textureWithID:' '];
	
	//for (int i = 0; i < mMaxChars; ++i) {
	//	SPImage *image = [[SPImage alloc] initWithTexture:texture];
	//}
}

- (SPTexture *)textureWithID:(int)charID {
	SPTexture *texture = nil;
	/*
	SPBitmapFont *bitmapFont = (SPBitmapFont *)[[SPTextField bitmapFonts] objectForKey:mScene.fontKey];
	
	if (bitmapFont != nil) {
		SPBitmapChar *bitmapChar = [bitmapFont charWithID_CHEEKY:charID];
		
		if (bitmapChar != nil)
			texture = bitmapChar.texture;
	}
	 */
	return texture;
}

- (void)positionAtX:(float)x y:(float)y {
	self.x = x;
	self.y = y;
}

- (void)centerOnX:(float)x y:(float)y {
	self.x = x - self.width / 2;
	self.y = y - self.height / 2;
}

- (void)dealloc {
	[mChars release]; mChars = nil;
	[super dealloc];
}

@end
