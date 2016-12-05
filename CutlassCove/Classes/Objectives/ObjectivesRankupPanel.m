//
//  ObjectivesRankupPanel.m
//  Cutlass Cove
//
//  Created by Paul McPhee on 6/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ObjectivesRankupPanel.h"
#import "ObjectivesRank.h"
#import "ObjectivesHat.h"
#import "ShadowTextField.h"
#import "GuiHelper.h"
#import "Globals.h"

@interface ObjectivesRankupPanel ()

- (void)playSoundWithKey:(NSString *)key;
- (void)dropHatAfterDelay:(float)delay;
- (float)displayStampsAfterDelay:(float)delay;
- (void)stampAnimationWithStamp:(SPDisplayObject *)stamp duration:(float)duration delay:(float)delay shakes:(BOOL)shakes;
- (void)shakeCanvas;
- (void)onHatDropping:(SPEvent *)event;
- (void)onHatDropped:(SPEvent *)event;
- (void)onStamping:(SPEvent *)event;
- (void)onStamped:(SPEvent *)event;
- (void)onContinuePressed:(SPEvent *)event;

@end


@implementation ObjectivesRankupPanel

- (id)initWithCategory:(int)category rank:(uint)rank {
    if (self = [super initWithCategory:category]) {
        self.touchable = YES;
        mRank = rank;
        [self setupProp];
    }
    return self;
}

- (id)initWithCategory:(int)category {
    return [self initWithCategory:category rank:0];
}

- (void)dealloc {
    for (SPSprite *tickSprite in mTicks)
        [mScene.juggler removeTweensWithTarget:tickSprite];
    [mScene.juggler removeTweensWithTarget:mHat];
    [mScene.juggler removeTweensWithTarget:mMainSprite];
    [mScene.juggler removeTweensWithTarget:mCanvas];
    [mContinueButton removeEventListener:@selector(onContinuePressed:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    [mContinueButton release]; mContinueButton = nil;
    [mHat release]; mHat = nil;
    [mRankText release]; mRankText = nil;
    [mMainSprite release]; mMainSprite = nil;
    [mMultiplierSprite release]; mMultiplierSprite = nil;
    [mTouchBarrier release]; mTouchBarrier = nil;
    [mCanvas release]; mCanvas = nil;
    [mTicks release]; mTicks = nil;
    [super dealloc];
}

- (void)setupProp {
    if (mCanvas)
        return;
    mCanvas = [[SPSprite alloc] init];
    [self addChild:mCanvas];
    
    // Scroll
    SPTexture *scrollTexture = [GuiHelper cachedScrollTextureByName:@"scroll-quarter-large" scene:mScene];
    SPImage *scrollImage = [SPImage imageWithTexture:scrollTexture];
    SPSprite *scrollSprite = [SPSprite sprite];
    [scrollSprite addChild:scrollImage];
    scrollSprite.scaleX = scrollSprite.scaleY = 300.0f / scrollSprite.width;
    scrollSprite.x = 90;
    scrollSprite.y = 32;
    [mCanvas addChild:scrollSprite];
    
    // Button
    mContinueButton = [[SPButton alloc] initWithUpState:[mScene textureByName:@"continue-button"]];
    mContinueButton.x = 198;
    mContinueButton.y = 213;
    [mContinueButton addEventListener:@selector(onContinuePressed:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    [mCanvas addChild:mContinueButton];
    
    // Decorations
    SPTexture *skullTexture = [mScene textureByName:@"objectives-skull"];
    SPImage *skullImage = [SPImage imageWithTexture:skullTexture];
    skullImage.x = 107;
    skullImage.y = 195;
    [mCanvas addChild:skullImage];
    
    skullImage = [SPImage imageWithTexture:skullTexture];
    skullImage.x = 373;
    skullImage.y = 195;
    skullImage.scaleX = -1;
    [mCanvas addChild:skullImage];
    
    // Ticks
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:kNumObjectivesPerRank];
    SPTexture *tickTexture = [mScene textureByName:@"good-point"];
    
    for (int i = 0; i < kNumObjectivesPerRank; ++i) {
        SPImage *tickImage = [SPImage imageWithTexture:tickTexture];
        tickImage.x = -tickImage.width / 2;
        tickImage.y = -tickImage.height / 2;
        
        SPSprite *tickSprite = [SPSprite sprite];
        tickSprite.x = 183 + i * 43 + tickImage.width / 2;
        tickSprite.y = 181 + tickImage.height / 2;
        tickSprite.visible = NO;
        [tickSprite addChild:tickImage];
        
        [mCanvas addChild:tickSprite];
        [tempArray addObject:tickSprite];
    }
    
    mTicks = [[NSArray alloc] initWithArray:tempArray];
    [tempArray removeAllObjects];
    
    // Main Section
    mMainSprite = [[SPSprite alloc] init];
    mMainSprite.x = scrollSprite.x + scrollSprite.width / 2;
    mMainSprite.y = scrollSprite.y + scrollSprite.height / 2;
    mMainSprite.visible = NO;
    [mCanvas addChild:mMainSprite];
    
    // Title text
    SPSprite *mainSprite = [SPSprite sprite];
    mainSprite.x = -mMainSprite.x;
    mainSprite.y = -mMainSprite.y;
    [mMainSprite addChild:mainSprite];
    
    mRankText = [[ShadowTextField alloc] initWithCategory:self.category width:225 height:32 fontSize:30];
    mRankText.x = 128;
    mRankText.y = 50;
    mRankText.fontColor = 0x797ca9;
    mRankText.text = [NSString stringWithFormat:@"%@!", [ObjectivesRank titleForRank:mRank]];
    [mainSprite addChild:mRankText];
    
    // Body text
    SPTextField *textField = [SPTextField textFieldWithWidth:170
                                                      height:48 
                                                        text:@"Your score multiplier has increased to..."
                                                    fontName:mScene.fontKey
                                                    fontSize:20
                                                       color:0];
    textField.x = mRankText.x + (mRankText.width - textField.width) / 2;
    textField.y = 88;
    textField.hAlign = SPHAlignCenter;
    textField.vAlign = SPVAlignCenter;
    [mainSprite addChild:textField];
    
    // Left cutlass
    SPTexture *cutlassTexture = [mScene textureByName:@"pointer"];
    SPImage *leftCutlassImage = [SPImage imageWithTexture:cutlassTexture];
    leftCutlassImage.x = -leftCutlassImage.width / 2;
    leftCutlassImage.y = -leftCutlassImage.height / 2;
    
    SPSprite *leftCutlassSprite = [SPSprite sprite];
    leftCutlassSprite.x = 172;
    leftCutlassSprite.y = 140;
    leftCutlassSprite.rotation = SP_D2R(-45);
    [leftCutlassSprite addChild:leftCutlassImage];
    [mainSprite addChild:leftCutlassSprite];
    
    // Right cutlass
    SPImage *rightCutlassImage = [SPImage imageWithTexture:cutlassTexture];
    rightCutlassImage.x = -rightCutlassImage.width / 2;
    rightCutlassImage.y = -rightCutlassImage.height / 2;
    
    SPSprite *rightCutlassSprite = [SPSprite sprite];
    rightCutlassSprite.x = 307;
    rightCutlassSprite.y = 140;
    rightCutlassSprite.scaleX = -1;
    rightCutlassSprite.rotation = SP_D2R(45);
    [rightCutlassSprite addChild:rightCutlassImage];
    [mainSprite addChild:rightCutlassSprite];
    
    // Multiplier sprite
    mMultiplierSprite = [[GuiHelper scoreMultiplierSpriteForValue:[ObjectivesRank multiplierForRank:mRank] scene:mScene] retain];
    mMultiplierSprite.x = -mMultiplierSprite.width / 2;
    mMultiplierSprite.y = 0;
    
    SPSprite *multiplierContainer = [SPSprite sprite];
    multiplierContainer.x = 240;
    multiplierContainer.y = 139;
    [multiplierContainer addChild:mMultiplierSprite];
    [mainSprite addChild:multiplierContainer];
    
    // Hat
    ResOffset *offset = [RESM itemOffsetWithAlignment:RACenter];
    mHat = [[ObjectivesHat alloc] initWithCategory:-1 hatType:ObjHatAngled text:mScene.objectivesManager.rankLabel];
    mHat.x = 119;
    mHat.y = -(offset.y + mHat.height / 2);
    mHat.visible = NO;
    [mCanvas addChild:mHat];
    
    float delay = [self displayStampsAfterDelay:0.5f];
    [self dropHatAfterDelay:delay];
    
    // Touch Barrier
    mTouchBarrier = [[SPQuad alloc] initWithWidth:mScene.viewWidth height:mScene.viewHeight];
    mTouchBarrier.alpha = 0;
    mTouchBarrier.visible = NO;
    [mCanvas addChild:mTouchBarrier atIndex:0];
}

- (void)enableTouchBarrier:(BOOL)enable {
    mTouchBarrier.visible = enable;
}

- (void)playSoundWithKey:(NSString *)key {
	[mScene.audioPlayer playSoundWithKey:key];
}

- (void)dropHatAfterDelay:(float)delay {
    [mScene.juggler removeTweensWithTarget:mHat];
    
    ResOffset *offset = [RESM itemOffsetWithAlignment:RACenter];
    mHat.y = -(offset.y + mHat.height / 2);
    
    SPTween *tween = [SPTween tweenWithTarget:mHat time:0.5f transition:SP_TRANSITION_EASE_IN];
    [tween animateProperty:@"y" targetValue:5 + mHat.height / 2];
    tween.delay = delay;
    [tween addEventListener:@selector(onHatDropped:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
    [tween addEventListener:@selector(onHatDropping:) atObject:self forType:SP_EVENT_TYPE_TWEEN_STARTED];
    [mScene.juggler addObject:tween];
}

- (float)displayStampsAfterDelay:(float)delay {
    for (SPSprite *tickSprite in mTicks)
        [mScene.juggler removeTweensWithTarget:tickSprite];
    [mScene.juggler removeTweensWithTarget:mMainSprite];
    
    for (SPSprite *tickSprite in mTicks) {
        [self stampAnimationWithStamp:tickSprite duration:0.1f delay:delay shakes:NO];
        delay += 0.75f;
    }
    
    [self stampAnimationWithStamp:mMainSprite duration:0.1f delay:delay shakes:YES];
    delay += 1.0f;
    
    return delay;
}

- (void)stampAnimationWithStamp:(SPDisplayObject *)stamp duration:(float)duration delay:(float)delay shakes:(BOOL)shakes {
    float oldScaleX = stamp.scaleX, oldScaleY = stamp.scaleY;
	
	stamp.scaleX = 3.0f;
	stamp.scaleY = 3.0f;
    
    [mScene.juggler removeTweensWithTarget:stamp];
	
	SPTween *tween = [SPTween tweenWithTarget:stamp time:duration];
	[tween animateProperty:@"scaleX" targetValue:oldScaleX];
	[tween animateProperty:@"scaleY" targetValue:oldScaleY];
    [tween addEventListener:@selector(onStamping:) atObject:self forType:SP_EVENT_TYPE_TWEEN_STARTED];
    
    if (shakes)
        [tween addEventListener:@selector(onStamped:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
    tween.delay = delay;
	[mScene.juggler addObject:tween];
}

- (void)shakeCanvas {
    [mScene.juggler removeTweensWithTarget:mCanvas];
    
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
		
		SPTween *tween = [SPTween tweenWithTarget:mCanvas time:0.05f transition:SP_TRANSITION_LINEAR];
		[tween animateProperty:@"x" targetValue:mCanvas.x + xTarget];
		[tween animateProperty:@"y" targetValue:mCanvas.y + yTarget];
		tween.delay = delay;
		delay += tween.time;
		[mScene.juggler addObject:tween];
	}
}

- (void)onHatDropping:(SPEvent *)event {
    mHat.visible = YES;
}

- (void)onHatDropped:(SPEvent *)event {
    [self playSoundWithKey:@"CrowdCheer"];
}

- (void)onStamping:(SPEvent *)event {
    SPTween *tween = (SPTween *)event.currentTarget;
    SPDisplayObject *target = (SPDisplayObject *)tween.target;
    target.visible = YES;
    [self playSoundWithKey:@"Stamp"];
}

- (void)onStamped:(SPEvent *)event {
    [self shakeCanvas];
}

- (void)onContinuePressed:(SPEvent *)event {
    [self playSoundWithKey:@"Button"];
    [self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_OBJECTIVES_RANKUP_PANEL_CONTINUED]];
}

@end
