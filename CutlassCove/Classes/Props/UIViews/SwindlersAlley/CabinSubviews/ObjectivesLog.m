//
//  ObjectivesLog.m
//  Cutlass Cove
//
//  Created by Paul McPhee on 9/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ObjectivesLog.h"
#import "ObjectivesHat.h"
#import "ObjectivesRank.h"
#import "ShadowTextField.h"
#import "GuiHelper.h"

//#define OBJECTIVES_LOG_DEBUG

@interface ObjectivesLog ()

#ifdef OBJECTIVES_LOG_DEBUG
- (void)onRankupPressed:(SPEvent *)event;
#endif

- (void)onPrevLogTab:(SPEvent *)event;
- (void)onNextLogTab:(SPEvent *)event;

@end


@implementation ObjectivesLog

@synthesize rank = mRank;

- (id)initWithCategory:(int)category rank:(uint)rank {
    if (self = [super initWithCategory:category]) {
        self.touchable = YES;
        mDirtyFlag = YES;
        mRank = rank;
        mLogBook = nil;
		[self setupProp];
	}
	return self;
}

- (id)initWithCategory:(int)category {
    return [self initWithCategory:category rank:0];
}

- (void)dealloc {
    [mPrevTab removeEventListener:@selector(onPrevLogTab:) atObject:self forType:CUST_EVENT_TYPE_LOG_TAB_TOUCHED];
    [mNextTab removeEventListener:@selector(onNextLogTab:) atObject:self forType:CUST_EVENT_TYPE_LOG_TAB_TOUCHED];
    
    [mHat release]; mHat = nil;
    [mRankTextField release]; mRankTextField = nil;
    [mMultiplierTextField release]; mMultiplierTextField = nil;
    [mMultiplierSprite release]; mMultiplierSprite = nil;
    [mMaxRankSprite release]; mMaxRankSprite = nil;
    [mIconImages release]; mIconImages = nil;
    [mRankDescTextFields release]; mRankDescTextFields = nil;
    
    [mLogPage release]; mLogPage = nil;
    [mLogBook release]; mLogBook = nil;
    [mPrevTab release]; mPrevTab = nil;
    [mNextTab release]; mNextTab = nil;
    [super dealloc];
}

#ifdef OBJECTIVES_LOG_DEBUG
- (void)onRankupPressed:(SPEvent *)event {
    [mScene.objectivesManager testRankup];
    [mScene.audioPlayer playSoundWithKey:@"Button"];
    self.rank = mScene.objectivesManager.rank;
    [self syncWithObjectives];
}
#endif

- (void)setupProp {
    if (mLogBook)
        return;
    
    // Log Book
    SPTexture *logbookTexture = [mScene textureByName:@"logbook"];
    SPImage *leftPage = [SPImage imageWithTexture:logbookTexture];
    SPImage *rightPage = [SPImage imageWithTexture:logbookTexture];
    rightPage.scaleX = -1;
    rightPage.x = 2 * rightPage.width;
    
	mLogPage = [[SPSprite alloc] init];
    mLogPage.touchable = NO;
	[mLogPage addChild:leftPage];
    [mLogPage addChild:rightPage];
	mLogPage.x = -mLogPage.width / 2;
	mLogPage.y = -mLogPage.height / 2;
    
[RESM pushItemOffsetWithAlignment:RACenter];
	mLogBook = [[SPSprite alloc] init];
	mLogBook.rx = 240;
	mLogBook.ry = 156;
    [mLogBook addChild:mLogPage];
	[self addChild:mLogBook];
    
    // Tabs
    mPrevTab = [[LogTab alloc] initWithCategory:0];
    mPrevTab.x = [RESM resX:31] - mLogBook.x;
    mPrevTab.y = [RESM resY:90] - mLogBook.y;
    [mPrevTab addEventListener:@selector(onPrevLogTab:) atObject:self forType:CUST_EVENT_TYPE_LOG_TAB_TOUCHED];
    
    mNextTab = [[LogTab alloc] initWithCategory:0];
    mNextTab.x = [RESM resX:417] - mLogBook.x;
    mNextTab.y = [RESM resY:90] - mLogBook.y;
    [mNextTab addEventListener:@selector(onNextLogTab:) atObject:self forType:CUST_EVENT_TYPE_LOG_TAB_TOUCHED];
[RESM popOffset];    
    [mLogBook addChild:mPrevTab];
    [mLogBook addChild:mNextTab];

#ifdef OBJECTIVES_LOG_DEBUG
    SPButton *rankupButton = [SPButton buttonWithUpState:[mScene textureByName:@"yes-button"]];
    rankupButton.x = 32; rankupButton.y = 32;
    [rankupButton addEventListener:@selector(onRankupPressed:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    [self addChild:rankupButton];
#endif
    
    [self syncWithObjectives];
}

- (void)setRank:(uint)rank {
    if (mRank != rank)
        mDirtyFlag = YES;
    mRank = rank;
}

- (void)syncWithObjectives {
    if (mDirtyFlag == NO)
        return;
    
    mPrevTab.pageNo = mRank-1;
    mPrevTab.visible = (mRank > 0);
    
    mNextTab.visible = (mRank < mScene.objectivesManager.rank);
    mNextTab.pageNo = mRank+1;
    
    // Left Page
    if (mHat == nil) {
        mHat = [[ObjectivesHat alloc] initWithCategory:-1 hatType:ObjHatStraight text:mScene.objectivesManager.rankLabel];
        mHat.x = 111;
        mHat.y = 48;
        mHat.scaleX = mHat.scaleY = 48.0f / mHat.height;
        [mLogPage addChild:mHat];
    } else {
        [mHat setText:[mScene.objectivesManager rankLabelForRank:mRank]];
    }
    
    if (mRankTextField == nil) {
        mRankTextField = [[ShadowTextField alloc] initWithCategory:self.category width:160 height:32 fontSize:26];
        mRankTextField.x = 32;
        mRankTextField.y = 72;
        mRankTextField.fontColor = 0x797ca9;
        mRankTextField.text = [NSString stringWithFormat:@"%@", [ObjectivesRank titleForRank:mRank]];
        [mLogPage addChild:mRankTextField];
    } else {
        NSString *rankText = [NSString stringWithFormat:@"%@", [ObjectivesRank titleForRank:mRank]];
        
        if ([mRankTextField.text isEqualToString:rankText] == NO)
            mRankTextField.text = rankText;
    }
    
    if (mMultiplierTextField == nil) {
        mMultiplierTextField = [[SPTextField textFieldWithWidth:112
                                                         height:24 
                                                           text:@"Score Multiplier"
                                                       fontName:mScene.fontKey
                                                       fontSize:20
                                                          color:0] retain];
        mMultiplierTextField.x = 55;
        mMultiplierTextField.y = 121;
        mMultiplierTextField.hAlign = SPHAlignCenter;
        mMultiplierTextField.vAlign = SPVAlignTop;
        [mLogPage addChild:mMultiplierTextField];
    }
    
    if (mMultiplierSprite) {
        [mLogPage removeChild:mMultiplierSprite];
        [mMultiplierSprite release]; mMultiplierSprite = nil;
    }
    
    mMultiplierSprite = [[GuiHelper scoreMultiplierSpriteForValue:[ObjectivesRank multiplierForRank:mRank] scene:mScene] retain];
    mMultiplierSprite.x = mMultiplierTextField.x + (mMultiplierTextField.width - mMultiplierSprite.width) / 2;
    mMultiplierSprite.y = mMultiplierTextField.y + mMultiplierTextField.height + 6;
    [mLogPage addChild:mMultiplierSprite];
    
    // Right Page
    ObjectivesRank *syncedRank = [mScene.objectivesManager syncedObjectivesForRank:mRank];
    
    if (syncedRank.isMaxRank) {
        if (mMaxRankSprite == nil) {
            mMaxRankSprite = [[mScene.objectivesManager maxRankSprite] retain];
            mMaxRankSprite.x = 210;
            mMaxRankSprite.y = 36;
            [mLogPage addChild:mMaxRankSprite];
        }
        
        mMaxRankSprite.visible = YES;
    } else {
        mMaxRankSprite.visible = NO;
    }

    if (mIconImages == nil)
        mIconImages = [[NSMutableArray alloc] initWithCapacity:kNumObjectivesPerRank];
    if (mRankDescTextFields == nil)
        mRankDescTextFields = [[NSMutableArray alloc] initWithCapacity:kNumObjectivesPerRank];
    
    for (int i = 0; i < kNumObjectivesPerRank; ++i) {
        BOOL completed = [syncedRank isObjectiveCompletedAtIndex:i];
        SPImage *iconImage = nil;
        SPTexture *iconTexture = [mScene textureByName:((completed) ? @"objectives-tick" : @"objectives-cross")];
        
        if (mIconImages.count > i) {
            iconImage = (SPImage *)[mIconImages objectAtIndex:i];
            iconImage.texture = iconTexture;
        } else {
            iconImage = [SPImage imageWithTexture:iconTexture];
            iconImage.x = 205;
            iconImage.y = 48 + i * 62;
            [mIconImages addObject:iconImage];
            [mLogPage addChild:iconImage];
        }
        
        SPTextField *rankDescTextField = nil;
        NSString *rankDescText = [syncedRank objectiveLogbookTextAtIndex:i];
        
        if (mRankDescTextFields.count > i) {
            rankDescTextField = (SPTextField *)[mRankDescTextFields objectAtIndex:i];
            
            if ([rankDescTextField.text isEqualToString:rankDescText] == NO)
                rankDescTextField.text = rankDescText;
        } else {
            rankDescTextField = [SPTextField textFieldWithWidth:142
                                                         height:60
                                                           text:rankDescText
                                                       fontName:mScene.fontKey
                                                       fontSize:16
                                                          color:0];
            rankDescTextField.x = 228;
            rankDescTextField.y = 25 + i * 62;
            rankDescTextField.hAlign = SPHAlignLeft;
            rankDescTextField.vAlign = SPVAlignCenter;
            [mRankDescTextFields addObject:rankDescTextField];
            [mLogPage addChild:rankDescTextField];
        }
        
        iconImage.visible = (rankDescTextField.text != nil);
    }
}

- (void)onPrevLogTab:(SPEvent *)event {
    if (self.rank > 0) {
        --self.rank;
        [self syncWithObjectives];
        [mScene.audioPlayer playSoundWithKey:@"PageTurn"];
    }
}

- (void)onNextLogTab:(SPEvent *)event {
    if (self.rank < mScene.objectivesManager.rank) {
        ++self.rank;
        [self syncWithObjectives];
        [mScene.audioPlayer playSoundWithKey:@"PageTurn"];
    }
}

@end


@interface LogTab ()

- (void)onTouch:(SPTouchEvent *)event;

@end

@implementation LogTab

@synthesize pageNo = mPageNo;

- (id)initWithCategory:(int)category {
    if (self = [super initWithCategory:category]) {
        self.touchable = YES;
        mPageNo = 0;
        mText = nil;
        mTab = nil;
        [self setupProp];
    }
    
    return self;
}

- (void)dealloc {
    [self removeEventListener:@selector(onTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
    [mText release];
    [mTab release];
    [super dealloc];
}

- (void)setupProp {
    if (mTab)
        return;
    
    mTab = [[SPImage alloc] initWithTexture:[mScene textureByName:@"bookmark"]];
    mTab.color = 0xdddddd;
    [self addChild:mTab];
    
    mText = [[SPTextField textFieldWithWidth:24
                                      height:24
                                        text:@"0"
                                    fontName:mScene.fontKey
                                    fontSize:20
                                       color:0]
            retain];
    mText.hAlign = SPHAlignCenter;
    mText.vAlign = SPVAlignTop;
    mText.x = mTab.x + (mTab.width - mText.width) / 2;
    mText.y = mTab.y + (mTab.height - mText.height) / 2;
    [self addChild:mText];
    
    SPQuad *touchQuad = [SPQuad quadWithWidth:96 height:96];
    touchQuad.x = mTab.x - (touchQuad.width - mTab.width) / 2;
    touchQuad.y = mTab.y - (touchQuad.height - mTab.height) / 2;
    touchQuad.alpha = 0;
    [self addChild:touchQuad];
    
    [self addEventListener:@selector(onTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
}

- (void)setPageNo:(int)pageNo {
    mText.text = [NSString stringWithFormat:@"%d", pageNo];
    mPageNo = pageNo;
}

- (void)onTouch:(SPTouchEvent *)event {
    SPTouch *touch = [[event touchesWithTarget:self andPhase:SPTouchPhaseBegan] anyObject];
	
	if (touch)
        mTab.color = 0xffffff;
    
    touch = [[event touchesWithTarget:self andPhase:SPTouchPhaseEnded] anyObject];
    
    if (touch)
        [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_LOG_TAB_TOUCHED]];
    
    if (touch || [[event touchesWithTarget:self andPhase:SPTouchPhaseCancelled] anyObject])
        mTab.color = 0xdddddd;
}

@end

