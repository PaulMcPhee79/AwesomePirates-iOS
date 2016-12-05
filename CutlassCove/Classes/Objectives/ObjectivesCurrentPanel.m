//
//  ObjectivesCurrentPanel.m
//  Cutlass Cove
//
//  Created by Paul McPhee on 6/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ObjectivesCurrentPanel.h"
#import "ObjectivesRank.h"
#import "ObjectivesHat.h"
#import "GuiHelper.h"

@interface ObjectivesCurrentPanel ()

- (void)playSoundWithKey:(NSString *)key;
- (void)setObjectiveCompletedIcon:(BOOL)completed atIndex:(uint)index;
- (void)setDescriptionText:(NSString *)text atIndex:(uint)index;
- (void)setQuotaText:(NSString *)text color:(uint)color atIndex:(uint)index;
- (void)setFailed:(BOOL)failed atIndex:(uint)index;
- (void)onContinuePressed:(SPEvent *)event;

@end


const uint kObjQuotaCompleteColor = 0x007e00;
const uint kObjQuotaIncompleteColor = 0xbd3100;
const uint kObjQuotaFailedColor = 0x9e1319;

@implementation ObjectivesCurrentPanel

- (id)initWithCategory:(int)category {
    if (self = [super initWithCategory:category]) {
        self.touchable = YES;
        mState = ObjCurrentStateObjectives;
        mCanvas = nil;
        mCanvasContent = nil;
        mObjectivesContent = nil;
        mMaxRankSprite = nil;
        mChallengeSprite = nil;
        [self setupProp];
    }
    return self;
}

- (void)dealloc {
    [mContinueButton removeEventListener:@selector(onContinuePressed:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    [mContinueButton release]; mContinueButton = nil;
    [mHat release]; mHat = nil;
    [mIcons release]; mIcons = nil;
    [mDescriptions release]; mDescriptions = nil;
    [mQuotas release]; mQuotas = nil;
    [mFails release]; mFails = nil;
    [mChallengeSprite release]; mChallengeSprite = nil;
    [mMaxRankSprite release]; mMaxRankSprite = nil;
    [mScrollSprite release]; mScrollSprite = nil;
    [mCanvasContent release]; mCanvasContent = nil;
    [mObjectivesContent release]; mObjectivesContent = nil;
    [mCanvas release]; mCanvas = nil;
    [mTickTexture release]; mTickTexture = nil;
    [mCrossTexture release]; mCrossTexture = nil;
    [super dealloc];
}

- (void)setupProp {
    if (mCanvas)
        return;
    mCanvas = [[SPSprite alloc] init];
    [self addChild:mCanvas];
    
    mTickTexture = [[mScene textureByName:@"objectives-tick"] retain];
    mCrossTexture = [[mScene textureByName:@"objectives-cross"] retain];
    
    // Decorations
    SPTexture *scrollTexture = [GuiHelper cachedScrollTextureByName:@"scroll-quarter-large" scene:mScene];
    SPImage *scrollImage = [SPImage imageWithTexture:scrollTexture];
    mScrollSprite = [[SPSprite alloc] init];
    [mScrollSprite addChild:scrollImage];
    mScrollSprite.scaleX = mScrollSprite.scaleY = 300.0f / mScrollSprite.width;
    mScrollSprite.x = 90;
    mScrollSprite.y = 32;
    [mCanvas addChild:mScrollSprite];
    
    // Content
    mObjectivesContent = [[SPSprite alloc] init];
    [mCanvas addChild:mObjectivesContent];
    
    mCanvasContent = [[SPSprite alloc] init];
    [mObjectivesContent addChild:mCanvasContent];
    
    SPImage *titleImage = [SPImage imageWithTexture:[mScene textureByName:@"objectives-text"]];
    titleImage.x = 195;
    titleImage.y = 41;
    [mCanvasContent addChild:titleImage];
    
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:kNumObjectivesPerRank];
    
    // Icons
    for (int i = 0; i < kNumObjectivesPerRank; ++i) {
        SPImage *iconImage = [SPImage imageWithTexture:mCrossTexture];
        iconImage.x = 120;
        iconImage.y = 84 + i * 45;
        [mCanvasContent addChild:iconImage];
        [tempArray addObject:iconImage];
    }
    
    mIcons = [[NSArray alloc] initWithArray:tempArray];
    [tempArray removeAllObjects];
    
    // Description TextFields
    for (int i = 0; i < kNumObjectivesPerRank; ++i) {
        SPTextField *textField = [SPTextField textFieldWithWidth:185
                                                          height:40 
                                                            text:@""
                                                        fontName:mScene.fontKey
                                                        fontSize:16
                                                           color:0];
        textField.x = 143;
        textField.y = 73 + i * 45;
        textField.hAlign = SPHAlignLeft;
        textField.vAlign = SPVAlignCenter;
        textField.compiled = NO;
        [mCanvasContent addChild:textField];
        [tempArray addObject:textField];
    }
    
    mDescriptions = [[NSArray alloc] initWithArray:tempArray];
    [tempArray removeAllObjects];
    
    // Quota TextFields
    for (int i = 0; i < kNumObjectivesPerRank; ++i) {
        SPTextField *textField = [SPTextField textFieldWithWidth:50
                                                          height:16 
                                                            text:@""
                                                        fontName:mScene.fontKey
                                                        fontSize:14
                                                           color:kObjQuotaCompleteColor];
        textField.x = 330;
        textField.y = 88 + i * 45;
        textField.hAlign = SPHAlignCenter;
        textField.vAlign = SPVAlignCenter;
        textField.compiled = NO;
        [mCanvasContent addChild:textField];
        [tempArray addObject:textField];
    }
    
    mQuotas = [[NSArray alloc] initWithArray:tempArray];
    [tempArray removeAllObjects];
    
    // Failed TextFields
    for (int i = 0; i < kNumObjectivesPerRank; ++i) {
        SPTextField *textField = [SPTextField textFieldWithWidth:50
                                                          height:14
                                                            text:@"Failed"
                                                        fontName:mScene.fontKey
                                                        fontSize:14
                                                           color:kObjQuotaFailedColor];
        textField.x = 330;
        textField.y = 102 + i * 45;
        textField.hAlign = SPHAlignCenter;
        textField.vAlign = SPVAlignCenter;
        textField.visible = NO;
        textField.compiled = NO;
        [mCanvasContent addChild:textField];
        [tempArray addObject:textField];
    }
    
    mFails = [[NSArray alloc] initWithArray:tempArray];
    [tempArray removeAllObjects];
    
    // Hat
    mHat = [[ObjectivesHat alloc] initWithCategory:-1 hatType:ObjHatAngled text:mScene.objectivesManager.rankLabel];
    mHat.x = 119;
    mHat.y = 5 + mHat.height / 2;
    [mObjectivesContent addChild:mHat];
    
    // Button
    mContinueButton = [[SPButton alloc] initWithUpState:[mScene textureByName:@"continue-button"]];
    mContinueButton.x = 212;
    mContinueButton.y = 213;
    [mContinueButton addEventListener:@selector(onContinuePressed:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    [mCanvasContent addChild:mContinueButton];
}

- (void)setState:(ObjCurrentState)state {
    if (state == mState)
        return;
    
    switch (state) {
        case ObjCurrentStateObjectives:
            mObjectivesContent.visible = YES;
            [mChallengeSprite removeFromParent];
            [mChallengeSprite release]; mChallengeSprite = nil;
            break;
        default:
            break;
    }
    
    mState = state;
}

- (void)playSoundWithKey:(NSString *)key {
	[mScene.audioPlayer playSoundWithKey:key];
}

- (void)setObjectiveCompletedIcon:(BOOL)completed atIndex:(uint)index {
    if (index < mIcons.count) {
        SPImage *iconImage = (SPImage *)[mIcons objectAtIndex:index];
        iconImage.texture = (completed) ? mTickTexture : mCrossTexture;
    }
}

- (void)setDescriptionText:(NSString *)text atIndex:(uint)index {
    if (index < mDescriptions.count) {
        SPTextField *textField = (SPTextField *)[mDescriptions objectAtIndex:index];
        
        if ([textField.text isEqualToString:text] == NO)
            textField.text = text;
    }
}

- (void)setQuotaText:(NSString *)text color:(uint)color atIndex:(uint)index {
    if (index < mQuotas.count) {
        SPTextField *textField = (SPTextField *)[mQuotas objectAtIndex:index];
        if ([textField.text isEqualToString:text] == NO)
            textField.text = text;
        textField.color = color;
    }
}

- (void)setFailed:(BOOL)failed atIndex:(uint)index {
    if (index < mFails.count) {
        SPTextField *textField = (SPTextField *)[mFails objectAtIndex:index];
        textField.visible = failed;
    }
}

- (void)enableButtons:(BOOL)enable {
    mContinueButton.visible = enable;
}

- (void)populateWithObjectivesRank:(ObjectivesRank *)objRank {
    if (objRank == nil)
        return;
    
    if (objRank.isMaxRank) {
        if (mMaxRankSprite == nil) {
            mMaxRankSprite = [[self maxRankSprite] retain];
            mMaxRankSprite.x = mScrollSprite.x + (mScrollSprite.width - mMaxRankSprite.width) / 2;
            mMaxRankSprite.y = mScrollSprite.y + mMaxRankSprite.height / 15;
            [mObjectivesContent addChild:mMaxRankSprite];
        }
        
        mCanvasContent.visible = NO;
        mMaxRankSprite.visible = YES;
    } else {
        mMaxRankSprite.visible = NO;
        mCanvasContent.visible = YES;
        
        for (int i = 0; i < kNumObjectivesPerRank; ++i) {
            // Icon
            [self setObjectiveCompletedIcon:[objRank isObjectiveCompletedAtIndex:i] atIndex:i];
            
            // Description
            [self setDescriptionText:[objRank objectiveTextAtIndex:i] atIndex:i];
            
            // Quota
            uint count = [objRank objectiveCountAtIndex:i], quota = [objRank objectiveQuotaAtIndex:i];
            uint color = ([objRank isObjectiveFailedAtIndex:i]) ? kObjQuotaFailedColor : ((count >= quota) ? kObjQuotaCompleteColor : kObjQuotaIncompleteColor);
            [self setQuotaText:[NSString stringWithFormat:@"%u/%u", count, quota] color:color atIndex:i];
            
            // Failed
            [self setFailed:[objRank isObjectiveFailedAtIndex:i] atIndex:i];
        }
    }
    
    [mHat setText:mScene.objectivesManager.rankLabel];
}

- (SPSprite *)maxRankSprite {
    float spriteWidth = 154, spriteHeight = 166;
    
    SPSprite *sprite = [SPSprite sprite];
    SPTextField *textField = [SPTextField textFieldWithWidth:140
                                                      height:28
                                                        text:@"Congratulations!"
                                                    fontName:mScene.fontKey
                                                    fontSize:24
                                                       color:0];
    textField.x = (spriteWidth - textField.width) / 2;
    textField.y = 0;
    textField.hAlign = SPHAlignCenter;
    textField.vAlign = SPVAlignTop;
    textField.compiled = YES;
    [sprite addChild:textField];

    SPImage *image = [SPImage imageWithTexture:[mScene textureByName:@"objectives-congrats"]];
    image.x = (spriteWidth - image.width) / 2;
    image.y = 34;
    [sprite addChild:image];
    
#ifdef CHEEKY_LITE_VERSION
    NSString *text = @"Get the full version for 24 ranks and a 34x score multiplier!";
#else
    NSString *text = @"You have achieved the highest rank. Now try^to beat the high score...";
#endif
    textField = [SPTextField textFieldWithWidth:spriteWidth
                                         height:64
                                           text:text
                                       fontName:mScene.fontKey
                                       fontSize:18
                                          color:0];
    textField.x = 4 + (spriteWidth - textField.width) / 2;
    textField.y = spriteHeight - textField.height;
    textField.hAlign = SPHAlignCenter;
    textField.vAlign = SPVAlignTop;
    textField.compiled = YES;
    [sprite addChild:textField];
    
    return sprite;
}

- (void)onContinuePressed:(SPEvent *)event {
    [self playSoundWithKey:@"Button"];
    [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_OBJECTIVES_CURRENT_PANEL_CONTINUED]];
}

@end
