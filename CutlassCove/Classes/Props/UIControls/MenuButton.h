//
//  MenuButton.h
//  Pirates
//
//  Created by Paul McPhee on 24/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MenuButton : SPButton {
	BOOL mSelected;
	BOOL mHighlighted;
	SEL mActionSelector;
	NSString *mSfxKey;
	float mSfxVolume;
	
	SPTexture *mToggleOnTexture;
	SPTexture *mToggleOffTexture;
	SPTexture *mHighlightTexture;
	SPImage *mHighlightImage;
	
	uint mVertCount;
	float *mVertsX;
	float *mVertsY;
}

@property (nonatomic,assign) BOOL selected;
@property (nonatomic,readonly) SEL actionSelector;
@property (nonatomic,copy) NSString *sfxKey;
@property (nonatomic,assign) float sfxVolume;
@property (nonatomic,retain) SPTexture *toggleOnTexture;
@property (nonatomic,retain) SPTexture *toggleOffTexture;
@property (nonatomic,retain) SPTexture *highlightTexture;
@property (nonatomic,readonly) BOOL isSwitch;
@property (nonatomic,assign) BOOL highlighted;

+ (MenuButton*)menuButtonWithSelector:(NSString *)selectorName upState:(SPTexture*)upState;
+ (MenuButton*)menuButtonWithSelector:(NSString *)selectorName upState:(SPTexture*)upState downState:(SPTexture*)downState;
- (id)initWithSelectorName:(NSString *)selectorName upState:(SPTexture*)upState downState:(SPTexture*)downState;
- (void)populateTouchBoundsWithVerts:(NSArray *)verts;
- (void)toggleOn;
- (void)toggleOff;

@end
