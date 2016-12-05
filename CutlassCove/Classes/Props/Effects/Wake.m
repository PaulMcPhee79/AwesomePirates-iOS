//
//  Wake.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 13/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "Wake.h"
#import "WakeCache.h"
#import "RingBuffer.h"
#import "GameController.h"
#import "Globals.h"

@interface Wake ()

- (void)setState:(WakeState)state;
- (void)fadeRipplesAfterTime:(double)time;

@end


@implementation Wake

@synthesize ripplePeriod = mRipplePeriod;

+ (int)defaultWakeBufferSize {
	return 20;
}

+ (int)maxWakeBufferSize {
	return 10;
}

+ (double)defaultWakePeriod {
    return 16.0;
}

+ (double)defaultRipplePeriod {
	return 1.5;
}

+ (double)minRipplePeriod {
	return 0.75;
}

+ (double)maxRipplePeriod {
	return 2.0;
}

- (id)initWithCategory:(int)category numRipples:(int)count {
    if (self = [super initWithCategory:category]) {
		mAdvanceable = YES;
		mState = WakeStateIdle;
        mResourcePoolIndex = -1;
		mNumRipples = count;
		mRipplePeriod = [Wake defaultRipplePeriod];
		mVisibleRipples = 0;
		mRipples = [[RingBuffer alloc] initWithCapacity:count];
		mVisibleRipples = [[NSMutableArray alloc] initWithCapacity:count];
		[self setupProp];
    }
    return self;
}

- (id)initWithCategory:(int)category {
	return [self initWithCategory:category numRipples:[Wake defaultWakeBufferSize]];
}
- (id)init {
	return [self initWithCategory:0 numRipples:[Wake defaultWakeBufferSize]];
}

- (void)setupProp {
	if (mState != WakeStateIdle)
		return;
	
	SPSprite *rippleSprite = nil;
	SPImage *rippleImage = nil;
	SPTexture *wakeTexture = [mScene textureByName:@"wake" cacheGroup:TM_CACHE_SHIP_WAKES];
	float widthCache = wakeTexture.width, heightCache = wakeTexture.height;
	
	NSArray *cachedRipples = [(WakeCache *)[mScene cacheManagerByName:CACHE_WAKE] checkoutRipples:mNumRipples index:&mResourcePoolIndex];
	
	for (SPSprite *sprite in cachedRipples) {
        sprite.visible = NO;
		[self addChild:sprite];
    }
	[mRipples addItems:cachedRipples];
	
	// If this wake misses the cache, when it dies it will top up
	// the cache so that new wakes are less likely to miss it.
	for (int i = mRipples.count; i < mNumRipples; ++i) {
		if (i == mNumRipples-1)
			NSLog(@"_+_+_+_+_+_+_+_+_ MISSED WAKE CACHE _+_++_+_+_+_+_+_+");
		rippleSprite = [[SPSprite alloc] init];
		rippleSprite.visible = NO;
		rippleImage = [[SPImage alloc] initWithTexture:wakeTexture];
		rippleImage.x = -widthCache/2;
		rippleImage.y = -heightCache/2;
		[rippleSprite addChild:rippleImage];
		[mRipples addItem:rippleSprite];
		[self addChild:rippleSprite];
		[rippleImage release]; rippleImage = nil;
		[rippleSprite release]; rippleSprite = nil;
	}
	
	[self setState:WakeStateActive];
}

- (void)setState:(WakeState)state {
	if (state == mState)
		return;
	
	switch (state) {
		case WakeStateIdle:
			break;
		case WakeStateActive:
			break;
		case WakeStateDying:
			break;
		case WakeStateDead:
			[mScene removeProp:self];
			break;
		default:
			break;
	}
	
	mState = state;
}

- (void)setRipplePeriod:(double)time {
	mRipplePeriod = MAX([Wake minRipplePeriod],time);
}

- (void)nextRippleAtX:(float)x y:(float)y rotation:(float)rotation {
	if (mState != WakeStateActive)
		return;
	
	SPSprite *ripple = mRipples.nextItem;
	ripple.visible = YES;
	ripple.rotation = rotation;
	ripple.x = x;
	ripple.y = y;
	ripple.alpha = 1.0f;
	ripple.scaleX = 0.25f;
	
	if ([mVisibleRipples containsObject:ripple] == NO)
		[mVisibleRipples addObject:ripple];
}

- (void)fadeRipplesAfterTime:(double)time {
	BOOL performExpensiveTest = YES;
	float alphaAdjust = time / (2 * mRipplePeriod);
	float scaleAdjust = 1.75 * (time / mRipplePeriod);
	
	for (int i = mVisibleRipples.count-1; i >= 0; --i) {
		SPSprite *ripple = (SPSprite *)[mVisibleRipples objectAtIndex:i];
		ripple.alpha -= (1.75f - ripple.alpha) * alphaAdjust;
		ripple.scaleX = MIN(3.5f, ripple.scaleX + (0.6f / ripple.scaleX * ripple.scaleX * ripple.scaleX) * scaleAdjust);
		
        if (ripple.alpha > 0.925f)
            ripple.scaleX += 2.5f * scaleAdjust;
        
		if (performExpensiveTest) {
			if (SP_IS_FLOAT_EQUAL(0,ripple.alpha)) {
				ripple.visible = NO;
				[mVisibleRipples removeObjectAtIndex:i];
			} else {
				performExpensiveTest = NO;
			}
		}
	}
}

- (void)advanceTime:(double)time {
	if (mState == WakeStateDead)
		return;
	
	[self fadeRipplesAfterTime:time];
	
	if (mState == WakeStateDying && mVisibleRipples.count == 0)
		[self setState:WakeStateDead];
}

- (void)safeDestroy {
	[self setState:WakeStateDying];
}

- (void)dealloc {
    if (mResourcePoolIndex != -1)
        [(WakeCache *)[mScene cacheManagerByName:CACHE_WAKE] checkinRipples:[mRipples allItems] index:mResourcePoolIndex];
	[mRipples release]; mRipples = nil;
	[mVisibleRipples release]; mVisibleRipples = nil;
    [super dealloc];
}

@end

