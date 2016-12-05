//
//  PotionView.m
//  CutlassCove
//
//  Created by Paul McPhee on 2/05/12.
//  Copyright (c) 2012 Cheeky Mammoth. All rights reserved.
//

#import "PotionView.h"
#import "SpriteCarousel.h"
#import "NumericValueChangedEvent.h"
#import "GuiHelper.h"
#import "GameSettings.h"
#import "GameController.h"

@interface PotionView ()

- (void)updateSelectedPotionSprite;
- (void)updateSelectedPotionSpriteOverTime:(float)duration;
- (void)onUpdatedSelectedPotionSprite:(SPEvent *)event;
- (void)onPotionCarouselIndexChanged:(NumericValueChangedEvent *)event;

@end


@implementation PotionView

@synthesize potionWasSelected = mPotionWasSelected;

- (id)initWithCategory:(int)category {
    if (self = [super initWithCategory:category]) {
        self.touchable = YES;
        mPotionWasSelected = NO;
        mAnimatedPotionSprite = nil;
        mCostume = nil;
        mJuggler = [[SPJuggler alloc] init];
        [self setupProp];
    }
    return self;
}

- (void)dealloc {
    for (int i = 0; i < mSelectedPotionSprite.numChildren; ++i) {
        SPDisplayObject *child = [mSelectedPotionSprite childAtIndex:i];
        [mJuggler removeTweensWithTarget:child];
    }
    
    [mJuggler removeTweensWithTarget:mAnimatedPotionSprite];
    [mJuggler removeTweensWithTarget:mPotionTips];
    [mPotionCarousel removeEventListener:@selector(onPotionCarouselIndexChanged:) atObject:self forType:CUST_EVENT_TYPE_SPRITE_CAROUSEL_INDEX_CHANGED];
    [mPotionCarousel release]; mPotionCarousel = nil;
    [mPotionLabels release]; mPotionLabels = nil;
    [mSelectedPotionTick release]; mSelectedPotionTick = nil;
    [mAnimatedPotionSprite release]; mAnimatedPotionSprite = nil;
    [mSelectedPotionSprite release]; mSelectedPotionSprite = nil;
    [mPotionTips release]; mPotionTips = nil;
    [mCostume release]; mCostume = nil;
    [mJuggler release]; mJuggler = nil;
    [super dealloc];
}

- (void)setupProp {
    if (mCostume)
        return;
    
    mCostume = [[SPSprite alloc] init];
    [self addChild:mCostume];
    
    // Labels
    NSArray *potions = [Potion potionList];
    NSMutableArray *potionTitles = [NSMutableArray arrayWithCapacity:potions.count];
    NSMutableArray *potionRanks = [NSMutableArray arrayWithCapacity:potions.count];
    NSMutableArray *potionDescs = [NSMutableArray arrayWithCapacity:potions.count];
    
    for (Potion *potion in potions) {
        SPTextField *title = [SPTextField textFieldWithWidth:160
                                                      height:28
                                                        text:[NSString stringWithFormat:@"Vial of %@", [Potion nameForKey:potion.key]]
                                                    fontName:mScene.fontKey
                                                    fontSize:24
                                                       color:0];
        title.x = 70;
        title.y = 157;
        title.hAlign = SPHAlignCenter;
        title.vAlign = SPVAlignTop;
        title.compiled = NO;
        [potionTitles addObject:title];
        [mCostume addChild:title];
        [title preCache];
        
        SPTextField *reqRank = [SPTextField textFieldWithWidth:116
                                                        height:20
                                                          text:[Potion requiredRankStringForPotion:potion]
                                                      fontName:mScene.fontKey
                                                      fontSize:16
                                                         color:(([Potion requiredRankForPotion:potion] > mScene.objectivesManager.rank) ? 0xff0000 : 0)];
        reqRank.x = 92;
        reqRank.y = 184;
        reqRank.hAlign = SPHAlignCenter;
        reqRank.vAlign = SPVAlignTop;
        reqRank.compiled = NO;
        [potionRanks addObject:reqRank];
        [mCostume addChild:reqRank];
        [reqRank preCache];
        
        SPTextField *desc = [SPTextField textFieldWithWidth:225
                                                     height:42
                                                       text:[Potion descForPotion:potion]
                                                   fontName:mScene.fontKey
                                                   fontSize:18
                                                      color:0];
        desc.x = 41;
        desc.y = 205;
        desc.hAlign = SPHAlignCenter;
        desc.vAlign = SPVAlignTop;
        desc.compiled = NO;
        [potionDescs addObject:desc];
        [mCostume addChild:desc];
        [desc preCache];
    }
    
        
    mPotionLabels = [[NSDictionary alloc] initWithObjectsAndKeys:
                     potionTitles, @"PotionTitle",
                     potionRanks, @"PotionRank",
                     potionDescs, @"PotionDesc",
                     nil];
    
    // Carousel
    mPotionCarousel = [[SpriteCarousel alloc] initWithCategory:0 x:148.0f y:102.0f width:RITMFX(125.0f) height:RITMFY(96.0f)];
    mPotionCarousel.touchable = YES;
    [mPotionCarousel addEventListener:@selector(onPotionCarouselIndexChanged:) atObject:self forType:CUST_EVENT_TYPE_SPRITE_CAROUSEL_INDEX_CHANGED];
    [mCostume addChild:mPotionCarousel];
    
    SPTexture *lockedTexture = [mScene textureByName:@"locked"];
    
    for (Potion *potion in potions) {
        SPSprite *potionSprite = [GuiHelper potionSpriteWithPotion:potion size:GuiSizeLge scene:mScene];
        SPImage *lockedImage = [SPImage imageWithTexture:lockedTexture];
        lockedImage.x = -lockedImage.width / 2;
        lockedImage.y = potionSprite.height / 2 - lockedImage.height;
        lockedImage.visible = ([Potion requiredRankForPotion:potion] > mScene.objectivesManager.rank);
        [potionSprite addChild:lockedImage];
        [mPotionCarousel batchAddSprite:potionSprite];
    }
    
    [mPotionCarousel batchAddCompleted];
    mPotionCarousel.scaleX = 1.0f;
    mPotionCarousel.scaleY = 1.0f;
    
    // Selected Potion Tick
    mSelectedPotionTick = [[SPImage alloc] initWithTexture:[mScene textureByName:@"good-point"]];
    mSelectedPotionTick.x = 228;
    mSelectedPotionTick.y = 157;
    mSelectedPotionTick.visible = NO;
    [mCostume addChild:mSelectedPotionTick];
    
    // Tips
    GameController *gc = GCTRL;
    int tipCount = [gc.gameSettings valueForKey:GAME_SETTINGS_KEY_POTION_TIPS_INTRO];
    
    if (tipCount < 2) {
        [gc.gameSettings setValue:tipCount+1 forKey:GAME_SETTINGS_KEY_POTION_TIPS_INTRO];
        
        mPotionTips = [[SPSprite alloc] init];
        [mCostume addChild:mPotionTips];
        
        SPImage *bubble = [SPImage imageWithTexture:[mScene.helpAtlas textureByName:@"speech-bubble"]];
        bubble.y = bubble.height;
        bubble.scaleY = -1;
        mPotionTips.x = 235;
        mPotionTips.y = 154;
        mPotionTips.alpha = 0;
        [mPotionTips addChild:bubble];
        
        SPTextField *text = [SPTextField textFieldWithWidth:170
                                                     height:88
                                                       text:@"Potions provide passive benefits. You cannot change potions while at sea."
                                                   fontName:mScene.fontKey
                                                   fontSize:18
                                                      color:0];
        text.x = 15;
        text.y = 25;
        text.hAlign = SPHAlignCenter;
        text.vAlign = SPVAlignTop;
        text.compiled = NO;
        [mPotionTips addChild:text];
        [text preCache];
        
        SPTween *fadeInTween = [SPTween tweenWithTarget:mPotionTips time:1.0f];
        [fadeInTween animateProperty:@"alpha" targetValue:1.0f];
        fadeInTween.delay = 0.5f;
        [mJuggler addObject:fadeInTween];
        
        SPTween *fadeOutTween = [SPTween tweenWithTarget:mPotionTips time:1.0f];
        [fadeOutTween animateProperty:@"alpha" targetValue:0];
        fadeOutTween.delay = fadeInTween.delay + fadeInTween.time + 8.0f;
        [mJuggler addObject:fadeOutTween];
    }
    
    [self updateWithIndex:mPotionCarousel.displayIndex];
    [self updateSelectedPotionSprite];
}

- (void)updateSelectedPotionSprite {
    if (mSelectedPotionSprite) {
        for (int i = 0; i < mSelectedPotionSprite.numChildren; ++i) {
            SPDisplayObject *child = [mSelectedPotionSprite childAtIndex:i];
            [mJuggler removeTweensWithTarget:child];
        }
        
        [mSelectedPotionSprite removeFromParent];
        [mSelectedPotionSprite release]; mSelectedPotionSprite = nil;
    }
    
    mSelectedPotionSprite = [[SPSprite alloc] init];
    
    NSArray *activePotions = [mScene activePotions];
    int i = 0;
    
    for (Potion *potion in activePotions) {
        SPSprite *potionSprite = [GuiHelper potionSpriteWithPotion:potion size:GuiSizeMed scene:mScene];
        potionSprite.x = i * (potionSprite.width + 8);
        [mSelectedPotionSprite addChild:potionSprite];
        ++i;
    }
    
    mSelectedPotionSprite.x = 355 - mSelectedPotionSprite.width / 2;
    mSelectedPotionSprite.y = 110;
    
    [mCostume addChild:mSelectedPotionSprite];
}

- (void)updateSelectedPotionSpriteOverTime:(float)duration {
    if (mAnimatedPotionSprite || mPotionCarousel == nil)
        return;
    
    SPDisplayObject *leftmostPotionBottle = nil;
    
    for (int i = 0; i < mSelectedPotionSprite.numChildren; ++i) {
        SPDisplayObject *potionBottle = [mSelectedPotionSprite childAtIndex:i];
        [mJuggler removeTweensWithTarget:potionBottle];
        
        if (leftmostPotionBottle == nil)
            leftmostPotionBottle = potionBottle;
        
        if (i < (mSelectedPotionSprite.numChildren-1)) {
            SPTween *tween = [SPTween tweenWithTarget:potionBottle time:duration];
            [tween animateProperty:@"x" targetValue:(i + 1) * (potionBottle.width + 8)];
            [mJuggler addObject:tween];
        } else {
            SPTween *tween = [SPTween tweenWithTarget:potionBottle time:duration];
            [tween animateProperty:@"x" targetValue:(i + 1) * (potionBottle.width + 8)];
            [mJuggler addObject:tween];
            
            tween = [SPTween tweenWithTarget:potionBottle time:duration transition:SP_TRANSITION_EASE_IN];
            [tween animateProperty:@"alpha" targetValue:0];
            [mJuggler addObject:tween];
        }
    }
    
    NSArray *activePotions = [mScene activePotions];

    if (activePotions.count > 0 && leftmostPotionBottle) {
        Potion *potion = (Potion *)[activePotions objectAtIndex:0];
        mAnimatedPotionSprite = [[GuiHelper potionSpriteWithPotion:potion size:GuiSizeLge scene:mScene] retain];
        int index = [mPotionCarousel displayIndex];
        SPPoint *point = [self globalToLocal:[mPotionCarousel spritePositionAtIndex:index]];
        mAnimatedPotionSprite.x = point.x;
        mAnimatedPotionSprite.y = point.y;
        [mCostume addChild:mAnimatedPotionSprite];
        
        point = [SPPoint pointWithX:leftmostPotionBottle.x y:leftmostPotionBottle.y];
        point = [leftmostPotionBottle localToGlobal:point];
        point = [self globalToLocal:point];
        
        SPTween *tween = [SPTween tweenWithTarget:mAnimatedPotionSprite time:duration];
        [tween animateProperty:@"x" targetValue:point.x];
        [tween animateProperty:@"y" targetValue:point.y];
        [tween animateProperty:@"scaleX" targetValue:leftmostPotionBottle.width / MAX(32,mAnimatedPotionSprite.width)];
        [tween animateProperty:@"scaleY" targetValue:leftmostPotionBottle.height / MAX(48,mAnimatedPotionSprite.height)];
        [tween addEventListener:@selector(onUpdatedSelectedPotionSprite:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
        [mJuggler addObject:tween];
    }
}

- (void)onUpdatedSelectedPotionSprite:(SPEvent *)event {
    [mAnimatedPotionSprite removeFromParent];
    [mAnimatedPotionSprite autorelease]; mAnimatedPotionSprite = nil;
    [self updateSelectedPotionSprite];
    [mScene.audioPlayer playSoundWithKey:@"PotionClink"];
}

- (void)updateWithIndex:(int)index {
    NSArray *potionTitles = [mPotionLabels objectForKey:@"PotionTitle"];
    NSArray *potionRanks = [mPotionLabels objectForKey:@"PotionRank"];
    NSArray *potionDescs = [mPotionLabels objectForKey:@"PotionDesc"];
    NSArray *potionKeys = [Potion potionKeys];
    
    for (SPTextField *label in potionTitles)
        label.visible = NO;
    for (SPTextField *label in potionRanks)
        label.visible = NO;
    for (SPTextField *label in potionDescs)
        label.visible = NO;
    
    
    if (index >= 0 && index < potionKeys.count) {
        uint potionKey = [(NSNumber *)[potionKeys objectAtIndex:index] unsignedIntValue];
        Potion *potion = [mScene potionForKey:potionKey];
        mSelectedPotionTick.visible = potion.isActive;
        
        if (index < potionTitles.count) {
            SPTextField *label = (SPTextField *)[potionTitles objectAtIndex:index];
            mSelectedPotionTick.x = 5 + label.x + label.textBounds.width + (label.width - label.textBounds.width) / 2;
            label.visible = YES;
        }
        
        if (index < potionRanks.count) {
            SPTextField *label = (SPTextField *)[potionRanks objectAtIndex:index];
            label.visible = YES;
        }
        
        if (index < potionDescs.count) {
            SPTextField *label = (SPTextField *)[potionDescs objectAtIndex:index];
            label.visible = YES;
        }
    }
}

- (void)selectCurrentPotion {
    if (mPotionCarousel == nil || mAnimatedPotionSprite)
        return;
    
    int index = [mPotionCarousel displayIndex];
    NSArray *potionKeys = [Potion potionKeys];
    
    if (index >= 0 && index < potionKeys.count) {
        uint potionKey = [(NSNumber *)[potionKeys objectAtIndex:index] unsignedIntValue];
        Potion *potion = [mScene potionForKey:potionKey];
        
        if (potion.isActive == NO) {
            if ([Potion requiredRankForPotion:potion] > mScene.objectivesManager.rank) {
                [mScene.audioPlayer playSoundWithKey:@"Locked"];
            } else {
                [GCTRL.gameStats activatePotion:YES forKey:potionKey];
                [self updateSelectedPotionSpriteOverTime:0.75f];
                [self updateWithIndex:index];
                mPotionWasSelected = YES;
                GCTRL.gameStats.potionsTimestamp = (double)CFAbsoluteTimeGetCurrent();
            }
        }
    }
}

- (void)onPotionCarouselIndexChanged:(NumericValueChangedEvent *)event {
    [self updateWithIndex:[event.value intValue]];
}

- (void)advanceTime:(double)time {
    [mPotionCarousel advanceTime:time];
    [mJuggler advanceTime:time];
}

- (void)destroyView {
    [mJuggler removeAllObjects];
    [mJuggler release]; mJuggler = nil;
}

@end
