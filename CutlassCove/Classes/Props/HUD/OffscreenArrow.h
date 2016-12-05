//
//  OffscreenArrow.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 8/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

@interface OffscreenArrow : Prop {
    BOOL mEnabled;
	float mRealX;
	float mRealY;
	float mCachedArrowWidth;
	float mCachedArrowHeight;
	SPSprite *mArrow;
    SPSprite *mCanvas;
}

@property (nonatomic,assign) BOOL enabled;

- (void)updateArrowLocationX:(float)arrowX arrowY:(float)arrowY;
- (void)updateArrowRotation:(float)angle;

@end
