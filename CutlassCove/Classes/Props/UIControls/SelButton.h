//
//  SelButton.h
//  Pirates
//
//  Created by Paul McPhee on 24/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SelButton : SPButton {
	NSString *mSfxKey;
	float mSfxVolume;
	SPTexture *mToggledOn;
	SPTexture *mToggledOff;
	SEL mActionSelector;
}

@property (nonatomic,readonly) SEL actionSelector;
@property (nonatomic,retain) SPTexture *toggledOn;
@property (nonatomic,retain) SPTexture *toggledOff;
@property (nonatomic,readonly) BOOL isSwitch;
@property (nonatomic,copy) NSString *sfxKey;
@property (nonatomic,assign) float sfxVolume;

+ (SelButton *)selButtonWithSelector:(NSString *)selectorName upState:(SPTexture*)upState downState:(SPTexture*)downState;
- (id)initWithSelectorName:(NSString *)selectorName upState:(SPTexture*)upState downState:(SPTexture*)downState;
- (void)toggleOn;
- (void)toggleOff;

@end
