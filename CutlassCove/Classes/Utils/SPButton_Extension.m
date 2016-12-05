//
//  SPButton_Extension.m
//  Pirates
//
//  Created by Paul McPhee on 24/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "SPButton_Extension.h"


@implementation SPButton (Extension)

- (SPImage *)backgroundImage {
	return mBackground;
}

- (SPSprite *)contents {
	return mContents;
}

- (BOOL)isDown {
	return mIsDown;
}

- (void)addTouchQuadWithWidth:(float)width height:(float)height {
	SPQuad *touchQuad = [SPQuad quadWithWidth:width height:height];
	touchQuad.x = (self.width - touchQuad.width) / 2;
	touchQuad.y = (self.height - touchQuad.height) / 2;
	touchQuad.alpha = 0;
	[self addChild:touchQuad];
}

@end
