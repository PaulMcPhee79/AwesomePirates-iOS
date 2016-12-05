//
//  TutorialBooklet.m
//  Cutlass Cove
//
//  Created by Paul McPhee on 1/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TutorialBooklet.h"
#import "SPButton_Extension.h"
#import "Globals.h"

@interface TutorialBooklet ()

- (TitleSubview *)createCover;
- (SPButton *)createArrowButtonWithLabel:(NSString *)label dir:(int)dir;
- (void)playButtonSound;
- (void)updateNavigationButtons;
- (void)onPrevButtonPressed:(SPEvent *)event;
- (void)onNextButtonPressed:(SPEvent *)event;
- (void)onDoneButtonPressed:(SPEvent *)event;
- (void)onContinueButtonPressed:(SPEvent *)event;

@end


@implementation TutorialBooklet

@synthesize minIndex = mMinIndex;
@synthesize maxIndex = mMaxIndex;

- (id)initWithCategory:(int)category key:(NSString *)key minIndex:(uint)minIndex maxIndex:(uint)maxIndex {
	if (self = [super initWithCategory:category key:key]) {
		self.touchable = YES;
        mLoop = NO;
        mMinIndex = minIndex;
        mMaxIndex = maxIndex;
		[self setupProp];
	}
	return self;
}

- (void)setupProp {
	self.cover = [self createCover];
}

- (TitleSubview *)createCover {
	if (self.cover)
		return self.cover;
    // Cover
    TitleSubview *cover = [TitleSubview titleSubviewWtihCategory:-1];
    
    // Continue
    mContinueButton = [[SPButton alloc] initWithUpState:[mScene textureByName:@"continue-button"]];
    mContinueButton.x = (mScene.viewWidth - mContinueButton.width) / 2;
    mContinueButton.y = mScene.viewHeight - (110 - mContinueButton.height / 2);
    [mContinueButton addEventListener:@selector(onContinueButtonPressed:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    [self addChild:mContinueButton];
    
    mPrevButton = nil;
    mNextButton = nil;
    mDoneButton = nil;

/*
    // Prev
    mPrevButton = [[self createArrowButtonWithLabel:@"Back" dir:-1] retain];
    [mPrevButton addEventListener:@selector(onPrevButtonPressed:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    
    SPSprite *buttonContainer = [SPSprite sprite];
    [buttonContainer addChild:mPrevButton];
    buttonContainer.scaleX = buttonContainer.scaleY = 1.5f;
    buttonContainer.x = mScene.viewWidth / 2 - 0.6f * buttonContainer.width;
    buttonContainer.y = mScene.viewHeight - (100 - buttonContainer.height / 2);
    [self addChild:buttonContainer];
    
    // Next
    mNextButton = [[self createArrowButtonWithLabel:@"Next" dir:1] retain];
    [mNextButton addEventListener:@selector(onNextButtonPressed:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    
    SPSprite *buttonContainer = [SPSprite sprite];
    [buttonContainer addChild:mNextButton];
    buttonContainer.scaleX = buttonContainer.scaleY = 1.6f;
    buttonContainer.x = mScene.viewWidth / 2; // + 0.6f * buttonContainer.width;
    buttonContainer.y = mScene.viewHeight - (95 - buttonContainer.height / 2);
    [self addChild:buttonContainer];
    
    // Done
    mDoneButton = [[self createArrowButtonWithLabel:@"Done" dir:1] retain];
    [mDoneButton addEventListener:@selector(onDoneButtonPressed:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    
    buttonContainer = [SPSprite sprite];
    [buttonContainer addChild:mDoneButton];
    buttonContainer.scaleX = buttonContainer.scaleY = 1.6f;
    buttonContainer.x = mScene.viewWidth / 2; // + 0.6f * buttonContainer.width;
    buttonContainer.y = mScene.viewHeight - (95 - buttonContainer.height / 2);
    [self addChild:buttonContainer];
*/
	return cover;
}

- (SPButton *)createArrowButtonWithLabel:(NSString *)label dir:(int)dir {
    if (dir != 1 && dir != -1)
        dir = 1;
    SPButton *button = [[[SPButton alloc] initWithUpState:[mScene textureByName:@"arrow"]] autorelease];
    button.x = -dir * button.width / 2;
    button.y = -button.height / 2;
    button.scaleWhenDown = 0.9f;
    button.scaleX = dir;
    
    SPTextField *textField = [SPTextField textFieldWithWidth:32 
                                                      height:16 
                                                        text:label
                                                    fontName:mScene.fontKey
                                                    fontSize:14
                                                       color:SP_WHITE];
    textField.x = (dir == -1) ? textField.width : 10;
    textField.y = (button.height - textField.height) / 2;
    textField.scaleX = dir;
    textField.hAlign = SPHAlignLeft;
    textField.vAlign = SPVAlignCenter;
    
    [button.contents addChild:textField];
    return button;
}

- (void)playButtonSound {
	[mScene.audioPlayer playSoundWithKey:@"Button"];
}

- (void)turnToPage:(uint)page {
    if (page < mMinIndex || page > mMaxIndex)
        return;
    [super turnToPage:page];
    [self updateNavigationButtons];
}

- (void)nextPage {
    if (mPageIndex == mMaxIndex)
        [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_TUTORIAL_DONE_PRESSED]];
    [super nextPage];
}

- (void)updateNavigationButtons {
    mPrevButton.visible = (mPageIndex != mMinIndex);
    mNextButton.visible = (mPageIndex != mMaxIndex);
    mDoneButton.visible = (mPageIndex == mMaxIndex);
}

- (void)onPrevButtonPressed:(SPEvent *)event {
    [self playButtonSound];
    [self prevPage];
    [self updateNavigationButtons];
}

- (void)onNextButtonPressed:(SPEvent *)event {
    [self playButtonSound];
    [self nextPage];
    [self updateNavigationButtons];
}

- (void)onDoneButtonPressed:(SPEvent *)event {
    [self playButtonSound];
    [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_TUTORIAL_DONE_PRESSED]];
}

- (void)onContinueButtonPressed:(SPEvent *)event {
    [self playButtonSound];
    [self nextPage];
}

- (void)dealloc {
    //[mPrevButton removeEventListener:@selector(onPrevButtonPressed:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    //[mNextButton removeEventListener:@selector(onNextButtonPressed:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    //[mDoneButton removeEventListener:@selector(onDoneButtonPressed:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    [mContinueButton removeEventListener:@selector(onContinueButtonPressed:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    
    [mPrevButton release]; mPrevButton = nil;
    [mNextButton release]; mNextButton = nil;
    [mDoneButton release]; mDoneButton = nil;
    [mContinueButton release]; mContinueButton = nil;
	[super dealloc];
	
	//NSLog(@"Tutorial Booklet dealloc'ed");
}

@end
