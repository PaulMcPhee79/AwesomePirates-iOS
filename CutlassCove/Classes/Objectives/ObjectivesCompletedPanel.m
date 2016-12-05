//
//  ObjectivesCompletedPanel.m
//  Cutlass Cove
//
//  Created by Paul McPhee on 6/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ObjectivesCompletedPanel.h"
#import "ObjectivesRank.h"

@interface ObjectivesCompletedPanel ()

- (void)onDisplayed:(SPEvent *)event;
- (void)onHidden:(SPEvent *)event;

@end


@implementation ObjectivesCompletedPanel

@synthesize isBusy = mBusy;
@synthesize isSilent = mIsSilent;
@synthesize showTargetY = mShowTargetY;

const float kShrinkScale = 0.6f;

- (id)initWithCategory:(int)category {
    if (self = [super initWithCategory:category]) {
        mBusy = NO;
        mIsSilent = NO;
        mShowTargetY = 25;
        mCanvas = nil;
        mFlipCanvas = nil;
        mCachedTextFields = nil;
        [self setupProp];
    }
    return self;
}

- (void)dealloc {
    [mScene.hudJuggler removeTweensWithTarget:mCanvas];
    [mCanvas release]; mCanvas = nil;
    [mFlipCanvas release]; mFlipCanvas = nil;
    [mTextField release]; mTextField = nil;
    [mCachedTextFields release]; mCachedTextFields = nil;
    [super dealloc];
}

- (void)setupProp {
    if (mCanvas)
        return;
    
    mFlipCanvas = [[SPSprite alloc] init];
    [self addChild:mFlipCanvas];
    
    mCanvas = [[SPSprite alloc] init];
    [mFlipCanvas addChild:mCanvas];
    
    SPImage *scrollImage = [SPImage imageWithTexture:[mScene textureByName:@"objectives-panel"]];
    [mCanvas addChild:scrollImage];
    
    SPImage *iconImage = [SPImage imageWithTexture:[mScene textureByName:@"objectives-tick"]];
    iconImage.x = 16;
    iconImage.y = 23;
    [mCanvas addChild:iconImage];
    
    mTextField = [[SPTextField textFieldWithWidth:185
                                           height:40 
                                             text:@""
                                         fontName:mScene.fontKey
                                         fontSize:16
                                            color:0]
             retain];
    mTextField.x = 40;
    mTextField.y = 10;
    mTextField.hAlign = SPHAlignLeft;
    mTextField.vAlign = SPVAlignCenter;
    mTextField.compiled = NO;
    [mCanvas addChild:mTextField];
    
    mCanvas.x = -mCanvas.width / 2;
    mCanvas.y = -mCanvas.height;
    mFlipCanvas.x = 120 + mCanvas.width / 2;
    
    self.visible = NO;
}

- (void)shrinkToSingleLine {
    if (mCanvas && mCanvas.numChildren > 1) {
        SPDisplayObject *displayObject = (SPImage *)[mCanvas childAtIndex:0];
        displayObject.scaleY = kShrinkScale;
        
        displayObject = (SPImage *)[mCanvas childAtIndex:1];
        displayObject.y = 10;
        
        if (mTextField)
            mTextField.y = 0;
    }
}

- (void)fillCacheWithRank:(ObjectivesRank *)objRank {
    [self hideOverTime:0];
    
    if (mCachedTextFields) {
        for (SPTextField *textField in mCachedTextFields)
            [mCanvas removeChild:textField];
        [mCachedTextFields removeAllObjects];
    }
    
    if (objRank == nil) // nil parameter empties cache
        return;
    
    if (mCachedTextFields == nil)
        mCachedTextFields = [[NSMutableArray alloc] initWithCapacity:kNumObjectivesPerRank];
    
    for (int i = 0; i < kNumObjectivesPerRank; ++i) {
        NSString *text = [objRank objectiveTextAtIndex:i];
        
        if (text == nil)
            text = @"";
        
        SPTextField *textField = [SPTextField textFieldWithWidth:185
                                                          height:40 
                                                            text:text
                                                        fontName:mScene.fontKey
                                                        fontSize:16
                                                           color:0];
        textField.x = 40;
        textField.y = 10;
        textField.hAlign = SPHAlignLeft;
        textField.vAlign = SPVAlignCenter;
        textField.compiled = YES;
        textField.visible = NO;
        [mCachedTextFields addObject:textField];
        [mCanvas addChild:textField];
    }
}

- (void)setText:(NSString *)text {
    SPTextField *selectedTextField = nil;
    
    // Try to get it from the cache
    for (SPTextField *textField in mCachedTextFields) {
        textField.visible = NO;
        
        if ([textField.text isEqualToString:text])
            selectedTextField = textField;
    }
    
    if (selectedTextField) {
        // Found in cache
        selectedTextField.visible = YES;
        mTextField.visible = NO;
    } else {
        // Not in cache - do long redraw
        mTextField.text = text;
        mTextField.visible = YES;
    }
}

- (void)flip:(BOOL)enable {
    mFlipCanvas.scaleX = (enable) ? -1 : 1;
}

- (void)displayForDuration:(float)duration {
    [mScene.hudJuggler removeTweensWithTarget:mCanvas];
    
    mCanvas.y = -mCanvas.height;
    self.visible = mBusy = YES;
    
    SPTween *displayTween = [SPTween tweenWithTarget:mCanvas time:0.35f];
    [displayTween animateProperty:@"y" targetValue:mShowTargetY];
    [displayTween addEventListener:@selector(onDisplayed:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
    [mScene.hudJuggler addObject:displayTween];
    
    SPTween *hideTween = [SPTween tweenWithTarget:mCanvas time:0.35f];
    [hideTween animateProperty:@"y" targetValue:-mCanvas.height];
    hideTween.delay = MAX(0.5f, duration);
    [hideTween addEventListener:@selector(onHidden:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
    [mScene.hudJuggler addObject:hideTween];
}

- (void)onDisplayed:(SPEvent *)event {
    if (self.isSilent == NO)
        [mScene.audioPlayer playSoundWithKey:@"CrewCelebrate"];
}

- (void)hide {
    self.visible = mBusy = NO;
    [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_OBJECTIVES_COMPLETED_PANEL_HIDDEN]];
}

- (void)hideOverTime:(float)duration {
    [mScene.hudJuggler removeTweensWithTarget:mCanvas];
    self.visible = mBusy = YES;
    
    SPTween *hideTween = [SPTween tweenWithTarget:mCanvas time:duration];
    [hideTween animateProperty:@"y" targetValue:-mCanvas.height];
    [hideTween addEventListener:@selector(onHidden:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
    [mScene.hudJuggler addObject:hideTween];
}

- (void)onHidden:(SPEvent *)event {
    self.visible = mBusy = NO;
    [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_OBJECTIVES_COMPLETED_PANEL_HIDDEN]];
}

@end
