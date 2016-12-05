//
//  AchievementPanel.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 31/10/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "AchievementPanel.h"

@interface AchievementPanel ()

- (void)hide;
- (void)setIconImage:(SPImage *)image;
- (void)onAchievementHidden:(SPEvent *)event;

@end


@implementation AchievementPanel

@synthesize tier = mTier;
@synthesize duration = mDuration;
@dynamic busy,title,text;

- (id)initWithCategory:(int)category {
	if (self = [super initWithCategory:category]) {
		self.touchable = YES;
        mAdvanceable = YES;
        mSlowable = NO;
		mHiding = NO;
        mHideTimer = 0;
		self.tier = ACHIEVEMENT_TIER_SWABBY;
		mDuration = 15.0;
		mOriginY = 0.0f;
		mIcon = nil;
        mContainer = nil;
        mFlipCanvas = nil;
		[self setupProp];
	}
	return self;
}

- (void)setupProp {
    if (mContainer)
        return;
    
    mContainer = [[SPSprite alloc] init];
    [self addChild:mContainer];
    
	SPTexture *bgTexture = [mScene.achievementAtlas textureByName:@"achievement-banner"];
	SPImage *bgImage = [SPImage imageWithTexture:bgTexture];
	[mContainer addChild:bgImage];
	bgImage = [SPImage imageWithTexture:bgTexture];
	bgImage.scaleX = -1.0f;
	bgImage.x = 2 * bgImage.width - 1.0f;
	[mContainer addChild:bgImage];
	
	mTitle = [[SPTextField textFieldWithWidth:180.0f height:20.0f
				text:@"DEFAULT" fontName:mScene.fontKey fontSize:16.0f color:0x0072ff] retain];
	mTitle.x = (self.width - mTitle.width) / 2;
	mTitle.y = 8.0f;
	mTitle.hAlign = SPHAlignCenter;
	mTitle.vAlign = SPVAlignTop;
    mTitle.compiled = NO;
	[mContainer addChild:mTitle];
	
	mText = [[SPTextField textFieldWithWidth:195.0f height:42.0f
				text:@"DEFAULT DESCRIPTION" fontName:mScene.fontKey fontSize:13.0f color:0] retain];
	mText.x = 72.0f;
	mText.y = 29.0f;
	mText.hAlign = SPHAlignLeft;
	mText.vAlign = SPVAlignTop;
    mText.compiled = NO;
	[mContainer addChild:mText];
	
	mIcon = [[SPSprite alloc] init];
	mIcon.x = 34.0f;
	mIcon.y = 28.0f;
	[mContainer addChild:mIcon];
    
    mContainer.x = -mContainer.width / 2;

	ResOffset *offset = [RESM itemOffsetWithAlignment:RALowerCenter];
	self.x = 80.0 + offset.x + mContainer.width / 2;
	self.y = 330.0f + offset.y;
	mOriginY = self.y;
	self.visible = NO;
	[self addEventListener:@selector(onTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
}

- (BOOL)busy {
	return self.visible;
}

- (void)setTier:(uint)value {
	SPImage *image = nil;

	switch (value) {
		case ACHIEVEMENT_TIER_SWABBY:
			image = [SPImage imageWithTexture:[mScene.achievementAtlas textureByName:@"swabby-tier-complete"]];
			break;
		case ACHIEVEMENT_TIER_PIRATE:
			image = [SPImage imageWithTexture:[mScene.achievementAtlas textureByName:@"pirate-tier-complete"]];
			break;
		case ACHIEVEMENT_TIER_CAPTAIN:
			image = [SPImage imageWithTexture:[mScene.achievementAtlas textureByName:@"captain-tier-complete"]];
			break;
		default:
			assert(0);
			break;
	}
	mTier = 0;
	[self setIconImage:image];
}

- (NSString *)title {
	return mTitle.text;
}

- (NSString *)text {
	return mText.text;
}

- (void)setTitle:(NSString *)value {
	mTitle.text = value;
}

- (void)setText:(NSString *)value {
	mText.text = value;
}

- (void)setIconImage:(SPImage *)image {
	[mIcon removeAllChildren];
	[mIcon addChild:image];
	mIcon.scaleX = 32.0f / mIcon.width;
	mIcon.scaleY = 32.0f / mIcon.height;
}

- (void)moveToCategory:(int)category {
    if (self.visible)
        [super moveToCategory:category];
    else
        self.category = category;
}

- (void)flip:(BOOL)enable {
    self.scaleX = (enable) ? -1 : 1;
}

- (void)display {
	if (self.visible == YES)
		return;
	[mScene addProp:self];
	self.visible = YES;
	
	SPTween *tweenIn = [SPTween tweenWithTarget:self time:0.05f * mDuration transition:SP_TRANSITION_EASE_OUT_BACK];
	[tweenIn animateProperty:@"y" targetValue:mOriginY - 140.0f];
	[mScene.hudJuggler addObject:tweenIn];
    mHideTimer = 0.6 * mDuration;
}

- (void)hide {
	if (mHiding)
		return;
	mHiding = YES;
	[mScene.hudJuggler removeTweensWithTarget:self];
	
	SPTween *tweenOut = [SPTween tweenWithTarget:self time:0.05f * mDuration transition:SP_TRANSITION_EASE_IN_BACK];
	[tweenOut animateProperty:@"y" targetValue:mOriginY];
	[tweenOut addEventListener:@selector(onAchievementHidden:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
	[mScene.hudJuggler addObject:tweenOut];
}

- (void)onAchievementHidden:(SPEvent *)event {
	mHiding = NO;
	self.visible = NO;
	[mScene removeProp:self];
	[self dispatchEvent:[SPEvent eventWithType:CUST_EVENT_TYPE_ACHIEVEMENT_HIDDEN]];
}

- (void)advanceTime:(double)time {
    if (mHideTimer > 0) {
        mHideTimer -= time;
        
        if (mHideTimer <= 0)
            [self hide];
    }
}

- (void)onTouch:(SPTouchEvent *)event {
	if (self.busy == NO)
		return;
	SPTouch *touch = [[event touchesWithTarget:self andPhase:SPTouchPhaseEnded] anyObject];

	if (touch != nil)
		[self hide];
}

- (void)dealloc {
	[mIcon release]; mIcon = nil;
	[mTitle release]; mTitle = nil;
	[mText release]; mText = nil;
    [mContainer release]; mContainer = nil;
	[super dealloc];
}

@end
