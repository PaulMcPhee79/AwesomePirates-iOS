//
//  SharkWater.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 18/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "SharkWater.h"
#import "SharkCache.h"
#import "Globals.h"

const float kWaterRingDuration = 2.0f;

@interface SharkWater ()

- (void)waterRingFaded;
- (void)onWaterRingFaded:(SPEvent *)event;

@end

@implementation SharkWater

+ (int)numRipples {
	return 3;
}

+ (float)waterRingDuration {
    return kWaterRingDuration;
}

- (id)initWithX:(float)x y:(float)y {
	if (self = [super initWithCategory:CAT_PF_WAVES]) {
		self.x = x;
		self.y = y;
        mHasPlayedEffect = NO;
		mWaterRing = nil;
		mResources = nil;
		[self checkoutPooledResources];
		[self setupProp];
	}
	return self;
}

- (void)setupProp {
	mWaterRing = [[SPSprite alloc] init];
	
	if (mRipples == nil) {
		SPTexture *texture = [mScene textureByName:@"shark-white-water" cacheGroup:TM_CACHE_SHARK];
        NSMutableArray *ripples = [NSMutableArray arrayWithCapacity:[SharkWater numRipples]];
	
		for (int i = 0; i < [SharkWater numRipples]; ++i) {
			SPSprite *sprite = [SPSprite sprite];
			SPImage *image = [SPImage imageWithTexture:texture];
			image.x = -image.width / 2;
			image.y = -image.height / 2;
			sprite.scaleX = 0.01f;
			sprite.scaleY = 0.01f;
			[sprite addChild:image];
            [ripples addObject:sprite];
			[mWaterRing addChild:sprite];
		}
        
        mRipples = [[NSArray alloc] initWithArray:ripples];
	} else {
		for (SPSprite *ripple in mRipples) {
            ripple.scaleX = 0.01f;
            ripple.scaleY = 0.01f;
            ripple.alpha = 1;
			[mWaterRing addChild:ripple];
        }
	}
	
	mWaterRing.visible = NO;
	[self addChild:mWaterRing];
}

- (void)playEffect {
    if (mHasPlayedEffect)
        return;
    
	SPTween *tween = nil;
	float delay = 0.0f;
	
    uint index = 0;
    
	for (SPSprite *sprite in mRipples) {
        if (![mResources startTweenForKey:RESOURCE_KEY_SHARK_RIPPLES_TWEEN+index]) {
            tween = [SPTween tweenWithTarget:sprite time:kWaterRingDuration transition:SP_TRANSITION_LINEAR];
            [tween animateProperty:@"alpha" targetValue:0.0f];
            [tween animateProperty:@"scaleX" targetValue:1.0f];
            [tween animateProperty:@"scaleY" targetValue:1.0f];
            tween.delay = delay;
            [mScene.juggler addObject:tween];
            delay += 0.5f;
            
            if (index == mRipples.count-1)
                [tween addEventListener:@selector(onWaterRingFaded:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
        }
        ++index;
	}
		
	mWaterRing.visible = YES;
    mHasPlayedEffect = YES;
}

- (void)waterRingFaded {
    [mScene removeProp:self];
}

- (void)onWaterRingFaded:(SPEvent *)event {
	[self waterRingFaded];
}

- (void)resourceEventFiredWithKey:(uint)key type:(NSString *)type target:(NSObject *)target {
    switch (key) {
        case RESOURCE_KEY_SHARK_RIPPLES:
            break;
        case RESOURCE_KEY_SHARK_RIPPLES_TWEEN:
        default:
            if (key >= RESOURCE_KEY_SHARK_RIPPLES_TWEEN)
                [self waterRingFaded];
            break;
    }
}

- (void)checkoutPooledResources {
	if (mResources == nil)
		mResources = [[[mScene cacheManagerByName:CACHE_SHARK] checkoutPoolResourcesForKey:@"SharkWater"] retain];
	if (mResources == nil)
		NSLog(@"_+_+_+_+_+_+_+_+_ MISSED SHARK WATER CACHE _+_++_+_+_+_+_+_+");
    else {
        mResources.client = self;
        
        if (mRipples == nil)
            mRipples = [(NSArray *)[mResources miscResourceForKey:RESOURCE_KEY_SHARK_RIPPLES] retain];
    }
}

- (void)checkinPooledResources {
    if (mResources) {
        [[mScene cacheManagerByName:CACHE_SHARK] checkinPoolResources:mResources];
        [mResources release]; mResources = nil;
    }
}

- (void)dealloc {
    if (mRipples && mRipples.count > 0) {
        // Kill the tween that has us as an event listener.
        SPSprite *sprite = (SPSprite *)[mRipples lastObject];
        [mScene.juggler removeTweensWithTarget:sprite];
    }
        
	[self checkinPooledResources];
	[mWaterRing release]; mWaterRing = nil;
	[mRipples release]; mRipples = nil;
	[super dealloc];
	//NSLog(@"SharkWater dealloc'ed");
}

@end
