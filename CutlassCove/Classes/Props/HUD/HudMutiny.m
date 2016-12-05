//
//  HudMutiny.m
//  Cutlass Cove
//
//  Created by Paul McPhee on 27/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HudMutiny.h"
#import "SXGauge.h"

@interface HudMutiny ()

@property (nonatomic,readonly) BOOL isReduced;

- (void)updateDisplay;
- (void)updateFillRatioDisplay;
- (void)bulgeCrossAtIndex:(int)index;

@end


@implementation HudMutiny

@synthesize mutinyLevel = mMutinyLevel;
@synthesize nextReduction = mNextReduction;
@synthesize reductionDisplayEnabled = mReductionDisplayEnabled;
@synthesize fillRatio = mFillRatio;

- (id)initWithCategory:(int)category maxMutinyLevel:(int)maxMutinyLevel {
    if (self = [super initWithCategory:category]) {
        mReductionDisplayEnabled = YES;
        mMutinyLevelMax = MAX(1, maxMutinyLevel);
        mNextReduction = 0;
        mMutinyLevel = 0;
        mFillRatio = 1.0f;
        mEmptyCrosses = nil;
        mFullCrosses = nil;
        mCrossSprites = nil;
        mEmptyTexture = [[mScene textureByName:@"mutiny-empty"] retain];
        mFullTexture = [[mScene textureByName:@"mutiny-full"] retain];
        [self setupProp];
    }
    return self;
}

- (void)setupProp {
    if (mEmptyCrosses || mFullCrosses || mCrossSprites)
        return;
    NSMutableArray *emptyCrosses = [NSMutableArray arrayWithCapacity:mMutinyLevelMax];
    NSMutableArray *fullCrosses = [NSMutableArray arrayWithCapacity:mMutinyLevelMax];
    NSMutableArray *sprites = [NSMutableArray arrayWithCapacity:mMutinyLevelMax];
    
    float nextX = 0, nextScale = 0;
    
    for (int i = 0; i < mMutinyLevelMax; ++i) {
        nextScale = (mEmptyTexture.width - 2 * (mMutinyLevelMax - (i + 1))) / mEmptyTexture.width;
        
        SPSprite *sprite = [SPSprite sprite];
        [self addChild:sprite];
        
        SPImage *emptyCross = [SPImage imageWithTexture:mEmptyTexture];
        emptyCross.x = -emptyCross.width / 2;
        [sprite addChild:emptyCross];
        
        SXGauge *fullCross = [SXGauge gaugeWithTexture:mFullTexture orientation:SXGaugeVertical];
        fullCross.ratio = 1;
        fullCross.x = -fullCross.width / 2;
        fullCross.visible = NO;
        [sprite addChild:fullCross];
        
        sprite.scaleX = sprite.scaleY = nextScale;
        sprite.x = nextX;
        
        [emptyCrosses addObject:emptyCross];
        [fullCrosses addObject:fullCross];
        [sprites addObject:sprite];
        
        nextX += sprite.width + 2;
    }
    
    
    mEmptyCrosses = [[NSArray alloc] initWithArray:emptyCrosses];
    mFullCrosses = [[NSArray alloc] initWithArray:fullCrosses];
    mCrossSprites = [[NSArray alloc] initWithArray:sprites];
    
    // Cache bulge tweens
    int crossIndex = 0;
    NSMutableArray *expandTweens = [NSMutableArray arrayWithCapacity:mCrossSprites.count];
    NSMutableArray *shrinkTweens = [NSMutableArray arrayWithCapacity:mCrossSprites.count];
    
    for (SPSprite *cross in mCrossSprites) {
        float targetScale = (mEmptyTexture.width - 2 * (mMutinyLevelMax - (crossIndex + 1))) / mEmptyTexture.width;
        SPTween *expandTween = [SPTween tweenWithTarget:cross time:0.2f transition:SP_TRANSITION_EASE_OUT];
        [expandTween animateProperty:@"scaleX" targetValue:2 * targetScale];
        [expandTween animateProperty:@"scaleY" targetValue:2 * targetScale];
        [expandTweens addObject:expandTween];
        
        SPTween *shrinkTween = [SPTween tweenWithTarget:cross time:0.2f transition:SP_TRANSITION_EASE_IN];
        [shrinkTween animateProperty:@"scaleX" targetValue:targetScale];
        [shrinkTween animateProperty:@"scaleY" targetValue:targetScale];
        shrinkTween.delay = expandTween.time;
        [shrinkTweens addObject:shrinkTween];
        
        ++crossIndex;
    }
    
    mExpandTweens = [[NSArray alloc] initWithArray:expandTweens];
    mShrinkTweens = [[NSArray alloc] initWithArray:shrinkTweens];
}

- (BOOL)isReduced {
    return (SP_IS_FLOAT_EQUAL(1.0f, mFillRatio) == NO);
}

- (void)setFillRatio:(float)fillRatio {
    mFillRatio = fillRatio;
    
    if (mMutinyLevel != 0)
        [self updateFillRatioDisplay];
    if (mMutinyLevel == mMutinyLevelMax && self.isReduced == NO)
        [self bulgeCrossAtIndex:mMutinyLevel-1];
}

- (void)setMutinyLevel:(int)mutinyLevel {
    int oldLevel = mMutinyLevel;
    mMutinyLevel = MIN(mMutinyLevelMax,MAX(0, mutinyLevel));
    
    [self updateDisplay];
    
    // Bulge red crosses
    for (int i = oldLevel; i < mMutinyLevel; ++i)
        [self bulgeCrossAtIndex:((self.isReduced) ? i-1 : i)];
    // Bulge blue crosses
    for (int i = oldLevel; i > mMutinyLevel; --i)
        [self bulgeCrossAtIndex:i-1];
}

- (void)updateDisplay {
    int i = 0;
    
    for (SPImage *emptyCross in mEmptyCrosses) {
        emptyCross.visible = (i >= (mMutinyLevel-1));
        ++i;
    }
    
    i = 0;
    
    for (SXGauge *fullCross in mFullCrosses) {
        fullCross.ratio = 1.0f;
        fullCross.visible = (i < mMutinyLevel);
        ++i;
    }
    
    [self updateFillRatioDisplay];
}

- (void)updateFillRatioDisplay {
    if (mMutinyLevel > 0 && mMutinyLevel <= mFullCrosses.count) {
        SXGauge *fullCross = (SXGauge *)[mFullCrosses objectAtIndex:mMutinyLevel-1];
        fullCross.ratio = mFillRatio;
    }
}

- (void)bulgeCrossAtIndex:(int)index {
    if (index < 0 || index >= mCrossSprites.count)
        return;
    SPSprite *cross = [mCrossSprites objectAtIndex:index];
    [mScene.hudJuggler removeTweensWithTarget:cross];
    
    // Maximize cross' z-order
	[self addChild:cross];
    
    SPTween *expandTween = (SPTween *)[mExpandTweens objectAtIndex:index];
    [expandTween reset];
    [mScene.hudJuggler addObject:expandTween];
    
    SPTween *shrinkTween = (SPTween *)[mShrinkTweens objectAtIndex:index];
    [shrinkTween reset];
    [mScene.hudJuggler addObject:shrinkTween];
}

- (void)dealloc {
    [mEmptyCrosses release]; mEmptyCrosses = nil;
    [mFullCrosses release]; mFullCrosses = nil;
    [mCrossSprites release]; mCrossSprites = nil;
    [mExpandTweens release]; mExpandTweens = nil;
    [mShrinkTweens release]; mShrinkTweens = nil;
    [mEmptyTexture release]; mEmptyTexture = nil;
    [mFullTexture release]; mFullTexture = nil;
    [super dealloc];
}

@end
