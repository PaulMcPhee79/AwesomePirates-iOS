//
//  PotionView.h
//  CutlassCove
//
//  Created by Paul McPhee on 2/05/12.
//  Copyright (c) 2012 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

@class SpriteCarousel;

@interface PotionView : Prop {
    BOOL mPotionWasSelected;
    NSDictionary *mPotionLabels;
    
    SPImage *mSelectedPotionTick;
    SPSprite *mAnimatedPotionSprite;
    SPSprite *mSelectedPotionSprite;
    SPSprite *mPotionTips;
    SpriteCarousel *mPotionCarousel;
    SPSprite *mCostume;
    
    SPJuggler *mJuggler;
}

@property (nonatomic,readonly) BOOL potionWasSelected;

- (void)updateWithIndex:(int)index;
- (void)selectCurrentPotion;
- (void)destroyView;

@end
