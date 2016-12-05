//
//  DashDial.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 19/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"
#import "Loadable.h"

@interface DashDial : Prop <Loadable> {
	SPTextField *mTopText;
	SPTextField *mMidText;
	SPTextField *mBtmText;
    SPSprite *mCanvas;
    SPSprite *mFlipCanvas;
}

- (void)setTopText:(NSString *)text;
- (void)setMidText:(NSString *)text;
- (void)setBtmText:(NSString *)text;

- (uint)topTextColor;
- (uint)midTextColor;
- (uint)btmTextColor;

- (void)setTopTextColor:(uint)color;
- (void)setMidTextColor:(uint)color;
- (void)setBtmTextColor:(uint)color;

+ (uint)fontColor;

@end
