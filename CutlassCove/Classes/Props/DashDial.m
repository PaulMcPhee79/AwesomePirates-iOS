//
//  DashDial.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 19/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DashDial.h"

const float kTopFontSize = 14.0f;
const float kMidFontSize = 12.0f;
const float kBtmFontSize = 8.0f;
const float kTextfieldWidth = 60.0f;
const uint kFontColor = 0xbeecff;

@interface DashDial ()

- (void)addDialSectionWithTexture:(SPTexture *)texture scaleX:(float)scaleX scaleY:(float)scaleY;

@end


@implementation DashDial

+ (uint)fontColor {
    return kFontColor;
}

- (id)init {
    if (self = [super initWithCategory:-1]) {
        mCanvas = nil;
        mFlipCanvas = nil;
		[self setupProp];
    }
    return self;
}

- (void)setupProp {
    if (mFlipCanvas)
        return;
    
    mFlipCanvas = [[SPSprite alloc] init];
    [self addChild:mFlipCanvas];
    
    mCanvas = [[SPSprite alloc] init];
    [mFlipCanvas addChild:mCanvas];
    
	// Build dial from quarters
	float scaleX = 1.0f, scaleY = 1.0f;
	SPTexture *dialTexture = [mScene textureByName:@"speedometer"];
	
	for (int i = 0; i < 4; ++i) {
		[self addDialSectionWithTexture:dialTexture scaleX:scaleX scaleY:scaleY];
		
		switch (i) {
			case 0: scaleX = -1.0f; break;
			case 1: scaleY = -1.0f; break;
			case 2: scaleX = 1.0f; break;
			default: break;
		}
	}
	
	// Top Textfield
	mTopText = [[SPTextField textFieldWithWidth:kTextfieldWidth height:kTopFontSize + 1 
                                           text:@"" fontName:mScene.fontKey fontSize:kTopFontSize color:kFontColor] retain];
	mTopText.x = 12.0f;
	mTopText.y = 10.0f;
	mTopText.hAlign = SPHAlignCenter;
	mTopText.vAlign = SPVAlignCenter;
    mTopText.compiled = NO;
	[mCanvas addChild:mTopText];
	
	// Mid Textfield
	mMidText = [[SPTextField textFieldWithWidth:kTextfieldWidth height:kMidFontSize + 1 
                                           text:@"" fontName:mScene.fontKey fontSize:kMidFontSize color:kFontColor] retain];
	mMidText.x = 12.0f;
	mMidText.y = 26.0f;
	mMidText.hAlign = SPHAlignCenter;
	mMidText.vAlign = SPVAlignCenter;
    mMidText.compiled = NO;
	[mCanvas addChild:mMidText];
	
	// Btm Textfield
	mBtmText = [[SPTextField textFieldWithWidth:kTextfieldWidth height:kBtmFontSize + 1 
                                           text:@"" fontName:mScene.fontKey fontSize:kBtmFontSize color:kFontColor] retain];
	mBtmText.x = 12.0f;
	mBtmText.y = 41.0f;
	mBtmText.hAlign = SPHAlignCenter;
	mBtmText.vAlign = SPVAlignCenter;
    mBtmText.compiled = NO;
	[mCanvas addChild:mBtmText];
    
    mCanvas.x = -mCanvas.width / 2;
    self.x += mCanvas.width / 2;
}

- (void)addDialSectionWithTexture:(SPTexture *)texture scaleX:(float)scaleX scaleY:(float)scaleY {
	SPImage *image = [[SPImage alloc] initWithTexture:texture];
	image.scaleX = scaleX;
	image.scaleY = scaleY;
	
	if (scaleX < 0)
		image.x = 2 * image.width;
	if (scaleY < 0)
		image.y = 2 * image.height;
	[mCanvas addChild:image];
	[image release];
}

- (void)loadFromDictionary:(NSDictionary *)dictionary withKeys:(NSArray *)keys {
    [RESM pushItemOffsetWithAlignment:RALowerLeft];
	self.rx = [(NSNumber *)[dictionary objectForKey:@"x"] floatValue];
	self.ry = [(NSNumber *)[dictionary objectForKey:@"y"] floatValue];
    [RESM popOffset];
    
    self.x += mCanvas.width / 2;
    
	dictionary = [dictionary objectForKey:@"Textfields"];
	mTopText.text = [dictionary objectForKey:@"topText"];
	mTopText.visible = mTopText.text != nil;
	mMidText.text = [dictionary objectForKey:@"midText"];
	mMidText.visible = mMidText.text != nil;
	mBtmText.text = [dictionary objectForKey:@"btmText"];
	mBtmText.visible = mBtmText.text != nil;
}

- (void)setTopText:(NSString *)text {
	mTopText.text = text;
}

- (void)setMidText:(NSString *)text {
	mMidText.text = text;
}

- (void)setBtmText:(NSString *)text {
	mBtmText.text = text;
}

- (uint)topTextColor {
    return mTopText.color;
}

- (uint)midTextColor {
    return mMidText.color;
}

- (uint)btmTextColor {
    return mBtmText.color;
}

- (void)setTopTextColor:(uint)color {
    mTopText.color = color;
}

- (void)setMidTextColor:(uint)color {
    mMidText.color = color;
}

- (void)setBtmTextColor:(uint)color {
    mBtmText.color = color;
}

- (void)flip:(BOOL)enable {
    mFlipCanvas.scaleX = (enable) ? -1 : 1;
}

- (void)dealloc {
	[mTopText release]; mTopText = nil;
	[mMidText release]; mMidText = nil;
	[mBtmText release]; mBtmText = nil;
    [mCanvas release]; mCanvas = nil;
    [mFlipCanvas release]; mFlipCanvas = nil;
	[super dealloc];
}

@end
