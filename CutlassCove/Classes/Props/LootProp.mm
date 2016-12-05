//
//  LootProp.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 28/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LootProp.h"
#import "GameController.h"

@interface LootProp ()

- (void)onLooted:(SPEvent *)event;

@end


@implementation LootProp

+ (float)lootAnimationDuration {
    return 1.25f;
}

- (id)initWithCategory:(int)category resourceKey:(NSString *)resourceKey {
	if (self = [super initWithCategory:category]) {
        mAdvanceable = YES;
		mLooted = NO;
		mAlphaFrom = 0.8f;
		mAlphaTo = 0;
		mScaleFrom = 0.01f;
		mScaleTo = 1.25f;
        mDuration = 1.0;
		mLootSfxKey = [[NSString stringWithFormat:@"Booty"] copy];
		mResourceKey = [resourceKey copy];
		mResources = nil;
        mWardrobe = nil;
		[self checkoutPooledResources];
	}
	return self;
}

- (void)dealloc {
    [mScene.juggler removeTweensWithTarget:mWardrobe];
	[self checkinPooledResources];
	[mCostume release]; mCostume = nil;
    [mWardrobe release]; mWardrobe = nil;
	[mLootSfxKey release]; mLootSfxKey = nil;
	[mResourceKey release]; mResourceKey = nil;
	[super dealloc];
}

- (void)setupProp {
    if (mWardrobe == nil)
        mWardrobe = [[SPSprite alloc] init];
    mWardrobe.scaleX = mWardrobe.scaleY = mScaleFrom;
    mWardrobe.alpha = mAlphaFrom;
    [mWardrobe addChild:mCostume];
    [self addChild:mWardrobe];
}

- (void)positionAtX:(float)x y:(float)y {
	if (mLooted == NO) {
		self.x = x;
		self.y = y;
	}
}

- (void)playLootSound {
	if (mLootSfxKey != nil)
		[mScene.audioPlayer playSoundWithKey:mLootSfxKey];
}

- (void)advanceTime:(double)time {
    if (mDuration > 0.0) {
        mDuration -= time;
        
        if (mDuration <= 0.0)
            [self loot];
    }
}

- (void)loot {
	if (mLooted)
		return;
	mLooted = YES;
	mWardrobe.alpha = mAlphaFrom;
	self.visible = YES;
	[self playLootSound];
	
    if ([mResources startTweenForKey:RESOURCE_KEY_LP_ALPHA_TWEEN]) {
        if (![mResources startTweenForKey:RESOURCE_KEY_LP_SCALE_TWEEN])
            [self destroyLoot];
    } else {
        float lootAnimationDuration = [LootProp lootAnimationDuration];
        
        SPTween *tween = [SPTween tweenWithTarget:mWardrobe time:lootAnimationDuration * 0.9f transition:SP_TRANSITION_EASE_IN];
        [tween animateProperty:@"alpha" targetValue:mAlphaTo];
        [mScene.juggler addObject:tween];
        
        tween = [SPTween tweenWithTarget:mWardrobe time:lootAnimationDuration transition:SP_TRANSITION_LINEAR];
        [tween animateProperty:@"scaleX" targetValue:mScaleTo];
        [tween animateProperty:@"scaleY" targetValue:mScaleTo];
        [tween addEventListener:@selector(onLooted:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
        [mScene.juggler addObject:tween];
    }
}

- (void)destroyLoot {
	[mScene removeProp:self];
	//mLooted = NO; // Allow re-use
}

- (void)onLooted:(SPEvent *)event {
    [self destroyLoot];
}

- (void)resourceEventFiredWithKey:(uint)key type:(NSString *)type target:(NSObject *)target {
    switch (key) {
        case RESOURCE_KEY_LP_SCALE_TWEEN:
            [self destroyLoot];
            break;
        default:
            break;
    }
}

- (void)checkoutPooledResources {
	if (mResources == nil)
		mResources = [[[mScene cacheManagerByName:CACHE_LOOT_PROP] checkoutPoolResourcesForKey:mResourceKey] retain];
	if (mResources == nil)
		NSLog(@"_+_+_+_+_+_+_+_+_ MISSED LOOT PROP CACHE _+_++_+_+_+_+_+_+");
    else {
        mResources.client = self;
        
        if (mCostume == nil)
            mCostume = [(SPImage *)[mResources displayObjectForKey:RESOURCE_KEY_LP_COSTUME] retain];
        if (mWardrobe == nil)
            mWardrobe = [(SPSprite *)[mResources displayObjectForKey:RESOURCE_KEY_LP_WARDROBE] retain];
    }
}

- (void)checkinPooledResources {
    if (mResources) {
        [[mScene cacheManagerByName:CACHE_LOOT_PROP] checkinPoolResources:mResources];
        [mResources release]; mResources = nil;
    }
}

@end
