//
//  HudMutiny.h
//  Cutlass Cove
//
//  Created by Paul McPhee on 27/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

@interface HudMutiny : Prop {
    BOOL mReductionDisplayEnabled;
    int64_t mNextReduction;
    
    int mMutinyLevel;
    int mMutinyLevelMax;
    
    float mFillRatio;
    
    NSArray *mEmptyCrosses;
    NSArray *mFullCrosses;
    NSArray *mCrossSprites;
    
    NSArray *mExpandTweens;
    NSArray *mShrinkTweens;
    
    SPTexture *mEmptyTexture;
    SPTexture *mFullTexture;
}

@property (nonatomic,assign) int mutinyLevel;
@property (nonatomic,assign) int64_t nextReduction;
@property (nonatomic,assign) BOOL reductionDisplayEnabled;
@property (nonatomic,assign) float fillRatio;

- (id)initWithCategory:(int)category maxMutinyLevel:(int)maxMutinyLevel;

@end
