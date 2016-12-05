//
//  Hud.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 8/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

@class HudCell,HudMutiny,FloatingText,NumericValueChangedEvent,NumericRatioChangedEvent;

@interface Hud : Prop {
	BOOL mListenersAttached;
	BOOL mTweenedUpdates;
	uint mColor;
    
    float mOriginX;
    
    int64_t mTarget;
    
	HudCell *mInfamyCell;
	HudCell *mAiCell;
    HudCell *mMiscCell;
	NSArray *mHudCells;
    
    HudMutiny *mHudMutiny;
	FloatingText *mFloatingText;
	ResOffset *mFloatingOffset;
}

@property (nonatomic,assign) BOOL tweenedUpdates;
@property (nonatomic,assign) int64_t target;

- (id)initWithCategory:(int)category textColor:(uint)textColor x:(float)x y:(float)y;
- (void)attachEventListeners;
- (void)detachEventListeners;

- (void)setInfamyValue:(uint)value;
- (void)floatingMutiny:(int)value;

- (void)onInfamyChanged:(NumericValueChangedEvent *)event;
- (void)onMutinyChanged:(NumericRatioChangedEvent *)event;

- (void)setAiValue:(int)value;
- (void)setMiscValue:(int)value;
- (void)onAiChanged:(NumericValueChangedEvent *)event;

- (void)enableScoredMode:(BOOL)enable;

@end
