//
//  CurvedText.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 19/06/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "CurvedText.h"
#import "SPBitmapFont_Extension.h"
#import "Globals.h"

@interface CurvedText ()

- (void)layoutText;

@end


@implementation CurvedText

@synthesize compiled = mCompiled;
@synthesize text = mText;
@synthesize color = mColor;
@synthesize orientation = mOrientation;
@synthesize originX = mOriginX;
@synthesize radius = mRadius;
@synthesize maxTextSeparation = mMaxTextSeparation;

- (id)initWithCategory:(int)category fontSize:(float)fontSize maxLength:(uint)maxLength {
	if (self = [super initWithCategory:category]) {
		assert(SP_IS_FLOAT_EQUAL(fontSize, 0) == NO);
        mCompiled = YES;
		mFontSize = fontSize;
		mNumChars = maxLength;
		mColor = SP_BLACK;
		mOrientation = CurvedTextCW;
		mOriginX = 0;
		mRadius = 0;
		mMaxTextSeparation = 50.0f;
		mText = nil;
	}
	return self;
}

- (void)setupProp {
	if (mChars)
		return;
	mChars = [[NSMutableArray alloc] initWithCapacity:mNumChars];
	
	for (int i = 0; i < mNumChars; ++i) {
		SPTextField *textField = [SPTextField  textFieldWithWidth:mFontSize height:mFontSize text:@""];
		textField.x = i * textField.width;
		textField.fontName = mScene.fontKey;
		textField.fontSize = mFontSize;
		textField.color = mColor;
		textField.hAlign = SPHAlignLeft;
		textField.vAlign = SPVAlignCenter;
        textField.compiled = mCompiled;
        [textField preCache];
		[mChars addObject:textField];
		[self addChild:textField];
	}
}

- (void)setColor:(uint)value {
	for (SPTextField *textField in mChars)
		textField.color = value;
	mColor = value;
}

- (void)setOriginX:(float)value {
	mOriginX = value;
	[self layoutText];
}

- (void)setRadius:(float)value {
	mRadius = value;
	[self layoutText];
}

- (void)setOrientation:(CurvedTextOrientation)orientation {
	mOrientation = orientation;
	[self layoutText];
}

- (void)setText:(NSString *)text {
	assert([text length] <= mNumChars);
	
	if ([text isEqualToString:mText])
		return;
	for (SPTextField *textField in mChars)
		textField.text = @"";
	
	NSRange range = NSMakeRange(0, 1);

	for (int i = 0; i < [text length]; ++i) {
		range.location = i;
		SPTextField *textField = (SPTextField *)[mChars objectAtIndex:i];
		textField.text = [text substringWithRange:range];
	}
	
	[mText autorelease];
	mText = [text copy];
	[self layoutText];
}

- (void)layoutText {
    int textLength = [mText length], previousChar = 0;
	float xAdvance = 0, scale = 1, angleIncrement = mRadius / mMaxTextSeparation, angleAccum = 0;
	SPBitmapFont *bitmapFont = (SPBitmapFont *)[[SPTextField bitmapFonts] objectForKey:mScene.fontKey];
	NSMutableArray *angles = [NSMutableArray arrayWithCapacity:textLength];
	
	for (int i = 0; i < textLength; ++i) {
		SPTextField *textField = (SPTextField *)[mChars objectAtIndex:i];
		previousChar = 0;
		
		if (bitmapFont) {
			scale = textField.fontSize / bitmapFont.size;
			SPBitmapChar *bitmapChar = [bitmapFont charWithID_CHEEKY:(int)[mText characterAtIndex:i]];
			xAdvance = bitmapChar.xAdvance * scale;
			previousChar = bitmapChar.charID;
		} else {
			xAdvance = 0.6f * mFontSize;
		}
		
		float angleTemp = MIN(angleIncrement, 0.5f + angleIncrement * (xAdvance / (scale * 20.0f)));
		
		// To account for our whacky font
		if (previousChar == 'M' || previousChar == 'W')
			angleTemp += 1.0f;
		NSNumber *angle = [NSNumber numberWithFloat:angleTemp];
		angleAccum += [angle floatValue];
		[angles addObject:angle];
	}
	
	int dir = (mOrientation == CurvedTextCW) ? 1 : -1;
	float angle = 180.0f - 0.5f * angleAccum;
	SPPoint *origin = [SPPoint pointWithX:0 y:mRadius * dir];
	
	for (int i = 0; i < textLength; ++i) {
		SPTextField *textField = (SPTextField *)[mChars objectAtIndex:i];
		SPPoint *point = [SPPoint pointWithX:origin.x y:origin.y];
		[Globals rotatePoint:point throughAngle:SP_D2R(angle)];
		textField.x = point.x;
		textField.y = point.y + dir * mRadius;
		textField.rotation = SP_D2R(angle-180);
		angle += [(NSNumber *)[angles objectAtIndex:i] floatValue];
	}
}

- (void)dealloc {
	[mText release]; mText = nil;
	[mChars release]; mChars = nil;
	[super dealloc];
}

@end
