//
//  GameSummary.m
//  Cutlass Cove
//
//  Created by Paul McPhee on 28/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GameSummary.h"
#import "GuiHelper.h"
#import "PlayerDetails.h"
#import "GameController.h"
#import "Globals.h"

@interface GameSummary ()

- (void)playSoundWithKey:(NSString *)key;
- (void)stampAnimationWithStamp:(SPSprite *)stamp duration:(float)duration delay:(float)delay;
- (void)shakeCanvas;
- (void)onStamping:(SPEvent *)event;
- (void)onStamped:(SPEvent *)event;
- (void)onRetryButtonPressed:(SPEvent *)event;
- (void)onMenuButtonPressed:(SPEvent *)event;
- (void)onSubmitButtonPressed:(SPEvent *)event;
- (void)destroyGameSummary;

@end


@implementation GameSummary

@dynamic stampsDelay;

- (id)initWithCategory:(int)category {
    if (self = [super initWithCategory:category]) {
        self.touchable = YES;
        mBestSprite = nil;
        mButtons = nil;
        [self setupProp];
    }
    return self;
}

- (void)setupProp {
    GameController *gc = GCTRL;

[RESM pushItemOffsetWithAlignment:RACenter];
    mCanvasSprite = [[SPSprite alloc] init];
    [self addChild:mCanvasSprite];
    
    // Background Scroll
    SPTexture *scrollTexture = [GuiHelper cachedScrollTextureByName:@"scroll-quarter-large" scene:mScene];
    SPImage *scrollImage = [SPImage imageWithTexture:scrollTexture];
    SPSprite *scrollSprite = [SPSprite sprite];
    [scrollSprite addChild:scrollImage];
    
    scrollSprite.scaleX = scrollSprite.scaleY = 300.0f / scrollSprite.width;
    scrollSprite.rx = 90;
    scrollSprite.ry = 32;
    [mCanvasSprite addChild:scrollSprite];
    
    // Shady
    SPSprite *shadySprite = [SPSprite sprite];
    shadySprite.rx = 106;
    shadySprite.ry = 88;
    
    SPImage *shadyImage = [SPImage imageWithTexture:[mScene textureByName:@"shady-end-of-turn"]];
    [shadySprite addChild:shadyImage];
    [mCanvasSprite addChild:shadySprite];
    
    // Buttons
    [self addMenuButtons];
    
    // Score
    SPSprite *scoreSprite = [SPSprite sprite];
    scoreSprite.touchable = NO;
    SPTextField *youScoredText = [SPTextField textFieldWithWidth:80
                                                          height:38
                                                            text:@"Score  "
                                                        fontName:mScene.fontKey
                                                        fontSize:32
                                                           color:0];
    youScoredText.hAlign = SPHAlignLeft;
    youScoredText.vAlign = SPVAlignTop;
    [scoreSprite addChild:youScoredText];
  
    NSString *scoreString = [GuiHelper commaSeparatedScore:gc.thisTurn.infamy];
    SPRectangle *textBounds = [GuiHelper boundsForText:scoreString maxWidth:150 fontSize:24 fontName:mScene.fontKey];
    
    mScoreText = [[SPTextField textFieldWithWidth:textBounds.width
                                           height:textBounds.height
                                             text:scoreString
                                         fontName:mScene.fontKey
                                         fontSize:24
                                            color:0]
                  retain];
    mScoreText.hAlign = SPHAlignLeft;
    mScoreText.vAlign = SPVAlignTop;
    mScoreText.x = youScoredText.x + youScoredText.width;
    mScoreText.y = youScoredText.y + 7;
    [scoreSprite addChild:mScoreText];
    
    scoreSprite.x = -scoreSprite.width / 2;
    scoreSprite.y = -scoreSprite.height / 2;
    
    mScoreSprite = [[SPSprite alloc] init];
    mScoreSprite.x = mScene.viewWidth / 2;
    mScoreSprite.ry = 75 + scoreSprite.height / 2;
    mScoreSprite.visible = NO;
    [mScoreSprite addChild:scoreSprite];
    [mCanvasSprite addChild:mScoreSprite];
    
    // New Best
    Score *hiScore = gc.playerDetails.hiScore;
    
    if (gc.thisTurn.infamy > hiScore.score) {
        SPImage *bestImage = [SPImage imageWithTexture:[mScene textureByName:@"new-best"]];
        bestImage.x = -bestImage.width / 2;
        bestImage.y = -bestImage.height / 2;
        
        mBestSprite = [[SPSprite alloc] init];
        mBestSprite.rx = 136;
        mBestSprite.ry = 70;
        mBestSprite.rotation = -PI / 6;
        mBestSprite.visible = NO;
        [mBestSprite addChild:bestImage];
        [mCanvasSprite addChild:mBestSprite];
    }
    
    // Stats
    SPSprite *statsSprite = [SPSprite sprite];
    statsSprite.touchable = NO;
    
        // Accuracy
    SPTextField *accuracyLabel = [SPTextField textFieldWithWidth:84
                                                          height:24
                                                            text:@"Accuracy"
                                                        fontName:mScene.fontKey
                                                        fontSize:20
                                                           color:0];
    accuracyLabel.hAlign = SPHAlignRight;
    accuracyLabel.vAlign = SPVAlignTop;
    [statsSprite addChild:accuracyLabel];
    
    mAccuracyText = [[SPTextField textFieldWithWidth:45
                                              height:24
                                                text:[NSString stringWithFormat:@"%.0f%%", 100.0f * gc.thisTurn.cannonAccuracy]
                                            fontName:mScene.fontKey
                                            fontSize:20
                                               color:0]
                     retain];
    mAccuracyText.hAlign = SPHAlignLeft;
    mAccuracyText.vAlign = SPVAlignTop;
    mAccuracyText.x = accuracyLabel.x + accuracyLabel.width + 16;
    mAccuracyText.y = accuracyLabel.y;
    [statsSprite addChild:mAccuracyText];
    
        // Plankings
    SPTextField *plankingsLabel = [SPTextField textFieldWithWidth:84
                                                           height:24
                                                             text:@"Ships Sunk"
                                                         fontName:mScene.fontKey
                                                         fontSize:20
                                                            color:0];
    plankingsLabel.hAlign = SPHAlignRight;
    plankingsLabel.vAlign = SPVAlignTop;
    plankingsLabel.y = accuracyLabel.y + 24;
    [statsSprite addChild:plankingsLabel];
    
    mPlankingsText = [[SPTextField textFieldWithWidth:45
                                               height:24
                                                 text:[NSString stringWithFormat:@"%u", gc.thisTurn.shipsSunk]
                                             fontName:mScene.fontKey
                                             fontSize:20
                                                color:0]
                      retain];
    mPlankingsText.hAlign = SPHAlignLeft;
    mPlankingsText.vAlign = SPVAlignTop;
    mPlankingsText.x = plankingsLabel.x + plankingsLabel.width + 16;
    mPlankingsText.y = plankingsLabel.y;
    [statsSprite addChild:mPlankingsText];
    
        // Days at Sea
    SPTextField *daysAtSeaLabel = [SPTextField textFieldWithWidth:84
                                                           height:24
                                                             text:@"Days at Sea"
                                                         fontName:mScene.fontKey
                                                         fontSize:20
                                                            color:0];
    daysAtSeaLabel.hAlign = SPHAlignRight;
    daysAtSeaLabel.vAlign = SPVAlignTop;
    daysAtSeaLabel.y = plankingsLabel.y + 24;
    [statsSprite addChild:daysAtSeaLabel];
    
    mDaysAtSeaText = [[SPTextField textFieldWithWidth:45
                                               height:24
                                                 text:[NSString stringWithFormat:@"%.2f", gc.thisTurn.daysAtSea]
                                             fontName:mScene.fontKey
                                             fontSize:20
                                                color:0]
                      retain];
    mDaysAtSeaText.hAlign = SPHAlignLeft;
    mDaysAtSeaText.vAlign = SPVAlignTop;
    mDaysAtSeaText.x = daysAtSeaLabel.x + daysAtSeaLabel.width + 16;
    mDaysAtSeaText.y = daysAtSeaLabel.y;
    [statsSprite addChild:mDaysAtSeaText];
    
    statsSprite.x = -statsSprite.width / 2;
    statsSprite.y = -statsSprite.height / 2;
    
    mStatsSprite = [[SPSprite alloc] init];
    mStatsSprite.x = mScene.viewWidth / 2;
    mStatsSprite.ry = 125 + statsSprite.height / 2;
    mStatsSprite.visible = NO;
    [mStatsSprite addChild:statsSprite];
    [mCanvasSprite addChild:mStatsSprite];
    
    // Death Sprite
	mDeathSprite = [[SPSprite alloc] init];
	mDeathSprite.touchable = NO;
	
	SPTexture *deathTexture = [mScene textureByName:@"death"];
	deathTexture = [Globals wholeTextureFromHalfHoriz:deathTexture];
	
	SPImage *deathImage = [SPImage imageWithTexture:deathTexture];
	deathImage.x = -deathImage.width / 2;
	deathImage.y = -deathImage.height / 2;
	[mDeathSprite addChild:deathImage];
	mDeathSprite.x = mScene.viewWidth / 2;
	mDeathSprite.y = mScene.viewHeight / 2;
	[self addChild:mDeathSprite];
	mDeathSprite.scaleX = 0.5f;
	mDeathSprite.scaleY = 0.5f;
[RESM popOffset];
}

- (void)addMenuButtons {
    if (mButtons)
        return;
    
    mRetryButton = [[SPButton alloc] initWithUpState:[mScene textureByName:@"retry-button"]];
    mRetryButton.rx = 154;
    mRetryButton.ry = 212;
    [mRetryButton addEventListener:@selector(onRetryButtonPressed:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    [mCanvasSprite addChild:mRetryButton];
    
    mSubmitButton = [[SPButton alloc] initWithUpState:[mScene textureByName:@"submit-button"]];
    mSubmitButton.rx = 154;
    mSubmitButton.ry = 212;
    [mSubmitButton addEventListener:@selector(onSubmitButtonPressed:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    [mCanvasSprite addChild:mSubmitButton];
    
    mMenuButton = [[SPButton alloc] initWithUpState:[mScene textureByName:@"menu-button"]];
    mMenuButton.rx = 262;
    mMenuButton.ry = 212;
    [mMenuButton addEventListener:@selector(onMenuButtonPressed:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    [mCanvasSprite addChild:mMenuButton];
    
    mButtons = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                mRetryButton, @"Retry",
                mSubmitButton, @"Submit",
                mMenuButton, @"Menu",
                nil];
    
    [self setMenuButtonHidden:YES forKey:@"Submit"];
}

- (void)enableMenuButton:(BOOL)enable forKey:(NSString *)key {
    SPButton *button = (SPButton *)[mButtons objectForKey:key];
    button.enabled = enable;
}

- (void)setMenuButtonHidden:(BOOL)hidden forKey:(NSString *)key {
    SPButton *button = (SPButton *)[mButtons objectForKey:key];
    button.visible = !hidden;
}

- (void)playSoundWithKey:(NSString *)key {
	[mScene.audioPlayer playSoundWithKey:key];
}

- (void)displaySummaryScroll {
    mCanvasSprite.visible = YES;
}

- (void)hideSummaryScroll {
    mCanvasSprite.visible = NO;
}

- (float)displayGameOverSequence {
    [mScene.juggler removeTweensWithTarget:mDeathSprite];
	[self playSoundWithKey:@"Death"]; // Sound plays for ~4s
	
	float scaleDuration = 2.2f;
	
	SPTween *fadeTween = [SPTween tweenWithTarget:mDeathSprite time:1.0f transition:SP_TRANSITION_EASE_IN];
	[fadeTween animateProperty:@"alpha" targetValue:0.0f];
	fadeTween.delay = scaleDuration - scaleDuration / 8;
	[mScene.juggler addObject:fadeTween];
	
	SPTween *scaleTween = [SPTween tweenWithTarget:mDeathSprite time:scaleDuration transition:SP_TRANSITION_EASE_IN_OUT];
	[scaleTween animateProperty:@"scaleX" targetValue:2.0f];
	[scaleTween animateProperty:@"scaleY" targetValue:2.0f];
	[mScene.juggler addObject:scaleTween];
	return fadeTween.time + fadeTween.delay;
}

- (float)stampsDelay {
    float delay = 0;
    
    if (mScoreSprite) delay += 1.0f;
    if (mStatsSprite) delay += 1.0f;
    if (mBestSprite) delay += 1.0f;
    
    return delay;
}

- (float)displayStamps {
    [mScene.juggler removeTweensWithTarget:mBestSprite];
    [mScene.juggler removeTweensWithTarget:mScoreSprite];
    [mScene.juggler removeTweensWithTarget:mStatsSprite];
    
    float delay = 0;
    
    if (mScoreSprite) {
        [self stampAnimationWithStamp:mScoreSprite duration:0.1f delay:delay];
        delay += 1.0f;
    }
    
    if (mStatsSprite) {
        [self stampAnimationWithStamp:mStatsSprite duration:0.1f delay:delay];
        delay += 1.0f;
    }
    
    if (mBestSprite) {
        [self stampAnimationWithStamp:mBestSprite duration:0.1f delay:delay];
        delay += 1.0f;
    }
    
    return delay;
}

- (void)stampAnimationWithStamp:(SPSprite *)stamp duration:(float)duration delay:(float)delay {
    float oldScaleX = stamp.scaleX, oldScaleY = stamp.scaleY;
	
	stamp.scaleX = 3.0f;
	stamp.scaleY = 3.0f;
    
    [mScene.juggler removeTweensWithTarget:stamp];
	
	SPTween *tween = [SPTween tweenWithTarget:stamp time:duration];
	[tween animateProperty:@"scaleX" targetValue:oldScaleX];
	[tween animateProperty:@"scaleY" targetValue:oldScaleY];
    [tween addEventListener:@selector(onStamping:) atObject:self forType:SP_EVENT_TYPE_TWEEN_STARTED];
    [tween addEventListener:@selector(onStamped:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
    tween.delay = delay;
	[mScene.juggler addObject:tween];
}

- (void)shakeCanvas {
    [mScene.juggler removeTweensWithTarget:mCanvasSprite];
    
	float delay = 0.0f;
	float xTarget, yTarget;
	float xAccum = 0, yAccum = 0;
	
	for (int i = 0; i < 6; ++i) {
		if (i < 5) {
			xTarget = RANDOM_INT(-20,20);
			yTarget = RANDOM_INT(-20,20);
			
			xAccum += xTarget;
			yAccum += yTarget;
			
			// Don't let it shake too far from center
			if (fabsf(xAccum) > 30) {
				xTarget = -xTarget;
				xAccum += xTarget;
			}
			
			if (fabsf(yAccum) > 30) {
				yTarget = -yTarget;
				yAccum += yTarget;
			}
		} else {
			// Move it back to original position
			xTarget = 0;
			yTarget = 0;
		}
		
		SPTween *tween = [SPTween tweenWithTarget:mCanvasSprite time:0.05f transition:SP_TRANSITION_LINEAR];
		[tween animateProperty:@"x" targetValue:mCanvasSprite.x + xTarget];
		[tween animateProperty:@"y" targetValue:mCanvasSprite.y + yTarget];
		tween.delay = delay;
		delay += tween.time;
		[mScene.juggler addObject:tween];
	}
}

- (void)onStamping:(SPEvent *)event {
    SPTween *tween = (SPTween *)event.currentTarget;
    SPDisplayObject *target = (SPDisplayObject *)tween.target;
    target.visible = YES;
    [self playSoundWithKey:@"Stamp"];
}

- (void)onStamped:(SPEvent *)event {
    [self shakeCanvas];
    
    // Cheer for new best score
    SPTween *tween = (SPTween *)event.currentTarget;
    SPSprite *sprite = (SPSprite *)tween.target;
    
    if (sprite && sprite == mBestSprite)
        [self playSoundWithKey:@"CrowdCheer"];
}

- (void)onRetryButtonPressed:(SPEvent *)event {
    [self playSoundWithKey:@"Button"];
    [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_GAME_SUMMARY_RETRY]];
}

- (void)onMenuButtonPressed:(SPEvent *)event {
    [self playSoundWithKey:@"Button"];
    [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_GAME_SUMMARY_MENU]];
}

- (void)onSubmitButtonPressed:(SPEvent *)event {
    [self playSoundWithKey:@"Button"];
    [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_GAME_SUMMARY_SUBMIT]];
}

- (void)destroy {
    [self destroyGameSummary];
}

- (void)destroyGameSummary {
    [mScene.juggler removeTweensWithTarget:mBestSprite];
    [mScene.juggler removeTweensWithTarget:mScoreSprite];
    [mScene.juggler removeTweensWithTarget:mStatsSprite];
    [mScene.juggler removeTweensWithTarget:mDeathSprite];
    [mScene.juggler removeTweensWithTarget:mCanvasSprite];
}

- (void)dealloc {
    [self destroyGameSummary];
    [mRetryButton release]; mRetryButton = nil;
    [mMenuButton release]; mMenuButton = nil;
    [mSubmitButton release]; mSubmitButton = nil;
    [mButtons release]; mButtons = nil;
    [mScoreText release]; mScoreText = nil;
    [mAccuracyText release]; mAccuracyText = nil;
    [mPlankingsText release]; mPlankingsText = nil;
    [mDaysAtSeaText release]; mDaysAtSeaText = nil;
    [mBestSprite release]; mBestSprite = nil;
    [mScoreSprite release]; mScoreSprite = nil;
    [mStatsSprite release]; mStatsSprite = nil;
    [mDeathSprite release]; mDeathSprite = nil;
    [mCanvasSprite release]; mCanvasSprite = nil;
    [super dealloc];
}

@end
