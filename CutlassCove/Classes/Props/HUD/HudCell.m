//
//  HudCell.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 4/10/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "HudCell.h"
#import "Globals.h"

const float kIconSize = 16.0f;

@interface HudCell ()

- (void)refreshCellText;

@end


@implementation HudCell

@synthesize value = mValue;
@synthesize maxValue = mMaxValue;
@dynamic textColor,labelColor;

+ (HudCell *)hudCellWithX:(float)x y:(float)y fontSize:(float)fontSize maxChars:(uint)maxChars {
	return [[[HudCell alloc] initWithCategory:-1 x:x y:y fontSize:fontSize maxChars:maxChars] autorelease];
}

- (id)initWithCategory:(int)category x:(float)x y:(float)y fontSize:(float)fontSize maxChars:(uint)maxChars {
	if (self = [super initWithCategory:category]) {
		self.x = x;
		self.y = y;
		mValue = 0;
		mMaxValue = 0;
		mQueuedChange = 0;
        mFontSize = fontSize;
		mMaxChars = maxChars;
		mIcon = nil;
		mText = nil;
		mLabel = nil;
        mCanvas = nil;
        mFlipCanvas = nil;
	}
	return self;
}

- (id)init {
	return [self initWithCategory:-1 x:0.0f y:0.0f fontSize:14.0f maxChars:1];
}

- (void)setupWithLabel:(NSString *)label labelWidth:(float)width color:(uint)color {
    BOOL canvasCreation = NO;
    
    if (mCanvas == nil) {
        mCanvas = [[SPSprite alloc] init];
        canvasCreation = YES;
        
        if (mFlipCanvas == nil) {
            mFlipCanvas = [[SPSprite alloc] init];
            [self addChild:mFlipCanvas];
        }
        
        [mCanvas removeFromParent];
        [mFlipCanvas addChild:mCanvas];
    }
    
	if (mLabel == nil) {
		mLabel = [[SPTextField textFieldWithWidth:width
                                           height:mFontSize+2 
											 text:label
										 fontName:mScene.fontKey
										 fontSize:mFontSize
											color:color]
				  retain];
		mLabel.hAlign = SPHAlignLeft;
		mLabel.vAlign = SPVAlignTop;
		[mCanvas addChild:mLabel];
	} else {
		mLabel.text = label;
		mLabel.color = color;
	}
	
	if (mText == nil) {
		mText = [[SPTextField textFieldWithWidth:(mFontSize * mMaxChars) / 2
										  height:mFontSize + 2 
											text:@""
										fontName:mScene.fontKey
										fontSize:mFontSize
                                           color:color]
				 retain];
		mText.hAlign = SPHAlignLeft;
		mText.vAlign = SPVAlignTop;
        mText.compiled = NO;
		[mCanvas addChild:mText];
	} else {
		mText.color = color;
	}
	
	if (mLabel != nil)
		mText.x = mLabel.width;
    
    if (canvasCreation) {
        float halfWidth = (mText.x + mText.width) / 2;
        mCanvas.x = -halfWidth;
        self.x += halfWidth;
    }
    
	[self refreshCellText];
}

- (void)setupWithIconTexture:(SPTexture *)texture color:(uint)color {
    BOOL canvasCreation = NO;
	float iconSpacer = 0.0f;
	
    if (mCanvas == nil) {
        mCanvas = [[SPSprite alloc] init];
        canvasCreation = YES;
        
        if (mFlipCanvas == nil) {
            mFlipCanvas = [[SPSprite alloc] init];
            [self addChild:mFlipCanvas];
        }
        
        [mCanvas removeFromParent];
        [mFlipCanvas addChild:mCanvas];
    }
    
	if (texture != nil) {
		if (mIcon == nil) {
			mIcon = [[SPImage imageWithTexture:texture] retain];
			[mCanvas addChild:mIcon];
		} else {
			mIcon.scaleX = 1.0f;
			mIcon.scaleY = 1.0f;
			mIcon.texture = texture;
		}
		
		mIcon.scaleX = kIconSize / mIcon.width;
		mIcon.scaleY = kIconSize / mIcon.height;
		iconSpacer = mIcon.width + 4.0f;
	}
	
	if (mText == nil) {
		mText = [[SPTextField textFieldWithWidth:(mFontSize * mMaxChars) / 2
										  height:mFontSize + 2 
											text:@""
										fontName:mScene.fontKey
										fontSize:mFontSize
                                           color:color]
				 retain];
		mText.hAlign = SPHAlignLeft;
		mText.vAlign = SPVAlignTop;
        mText.compiled = NO;
		[mCanvas addChild:mText];
	} else {
		mText.color = color;
	}
	
    mText.x = iconSpacer;
    
    if (canvasCreation) {
        float halfWidth = (mText.x + mText.width) / 2;
        mCanvas.x = -halfWidth;
        self.x += halfWidth;
    }
    
	[self refreshCellText];
}

- (int64_t)value {
	return mQueuedChange + mValue;
}

- (void)setValue:(int64_t)value {
	mQueuedChange = 0;
	mValue = value;
	[self refreshCellText];
}

- (void)setMaxValue:(int64_t)value {
	if (value >= 0) {
		mMaxValue = value;
		[self refreshCellText];
	}
}

- (uint)textColor {
	return mText.color;
}

- (void)setTextColor:(uint)value {
	mText.color = value;
}

- (uint)labelColor {
	return mLabel.color;
}

- (void)setLabelColor:(uint)value {
	mLabel.color = value;
}

- (void)setIconTexture:(SPTexture *)texture {
	if (texture != nil && mIcon != nil)
		mIcon.texture = texture;
}

- (void)setCellText:(NSString *)text {
	mText.text = text;
}

- (void)flip:(BOOL)enable {
    mFlipCanvas.scaleX = (enable) ? -1 : 1;
}

- (void)enqueueValueChange:(int64_t)valueChange {
	mQueuedChange += valueChange - self.value;
}

- (void)refreshCellText {
	NSString *text = nil;
	
	if (mMaxValue != 0)
		text = [NSString stringWithFormat:@"%lld/%lld", mValue, mMaxValue];
	else
		text = [Globals commaSeparatedScore:mValue];
	[self setCellText:text];
}

- (void)tick {
	if (mQueuedChange == 0)
		return;
	
	int delta = mQueuedChange / 10;
	
	if (delta == 0)
		delta = mQueuedChange;
	mQueuedChange -= delta;
	mValue += delta;
	[self refreshCellText];
}

- (void)dealloc {
	[mIcon release]; mIcon = nil;
	[mText release]; mText = nil;
	[mLabel release]; mLabel = nil;
    [mCanvas release]; mCanvas = nil;
    [mFlipCanvas release]; mFlipCanvas = nil;
	[super dealloc];
}

@end
