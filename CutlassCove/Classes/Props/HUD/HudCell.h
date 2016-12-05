//
//  HudCell.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 4/10/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

@interface HudCell : Prop {
	int64_t mValue;
	int64_t	mMaxValue;
	int64_t mQueuedChange;
	uint mMaxChars;
    float mFontSize;
	SPImage *mIcon;
	SPTextField *mText;
	SPTextField *mLabel;
    SPSprite *mCanvas;
    SPSprite *mFlipCanvas;
}

@property (nonatomic,assign) int64_t value;
@property (nonatomic,assign) int64_t maxValue;
@property (nonatomic,assign) uint textColor;
@property (nonatomic,assign) uint labelColor;

- (id)initWithCategory:(int)category x:(float)x y:(float)y fontSize:(float)fontSize maxChars:(uint)maxChars;
- (void)setupWithIconTexture:(SPTexture *)texture color:(uint)color;
- (void)setupWithLabel:(NSString *)label labelWidth:(float)width color:(uint)color;
- (void)setIconTexture:(SPTexture *)texture;
- (void)setCellText:(NSString *)text;
- (void)enqueueValueChange:(int64_t)valueChange;
- (void)tick;
+ (HudCell *)hudCellWithX:(float)x y:(float)y fontSize:(float)fontSize maxChars:(uint)maxChars;

@end
