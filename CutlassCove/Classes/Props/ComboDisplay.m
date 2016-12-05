//
//  ComboDisplay.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 28/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ComboDisplay.h"

const float kCannonballScale = 1.1f;
const float kCannonballUnscaledWidth = 16.0f;
const float kCannonballWidth = kCannonballUnscaledWidth * kCannonballScale;
const int kComboMin = 0;
const int kComboMax = 3;
const float kComboWidth = 3 * kCannonballWidth;

@interface ComboDisplay ()

- (BOOL)isSrcClip:(NSArray *)src lowerPriorityThanOtherClip:(NSArray *)other;
- (void)pushClips:(NSArray *)clips;
- (void)popClips:(NSArray *)clips;
- (void)setCurrentCannonballClips:(NSArray *)clips;
- (void)setupClips:(NSMutableArray *)clips withPrefix:(NSString *)texturePrefix;
- (void)rollCannonballsTo:(int)value;
- (void)onCannonballRollingStopped:(SPEvent *)event;

@end


@implementation ComboDisplay

- (id)init {
    if (self = [super initWithCategory:-1]) {
		mAdvanceable = YES;
		mFlyingDutchman = NO;
		mProcActive = NO;
		mRolling = 0;
		mCannonballClips = nil;
		mProcClips = nil;
		mFlyingDutchmanClips = nil;
		mClipStack = [[NSMutableArray alloc] init];
		mCurrentClips = nil;
		mComboMultiplier = kComboMin;
        mCannonballs = nil;
		mJuggler = [[SPJuggler alloc] init];
    }
    return self;
}

- (void)loadFromDictionary:(NSDictionary *)dictionary withKeys:(NSArray *)keys {
	if (mCannonballs)
		return;
	NSDictionary *dict = [dictionary objectForKey:@"Combo"];
	float y = [(NSNumber *)[dict objectForKey:@"y"] floatValue];
	dict = [dictionary objectForKey:@"Types"];
	
	int i = 0;
	
	NSString *key = [keys objectAtIndex:i++];
	dict = [dict objectForKey:key];
	dict = [dict objectForKey:@"Textures"];
	NSString *textureName = [dict objectForKey:@"comboTexture"];
	NSArray *textureFrames = [mScene texturesStartingWith:textureName];
	
	if (mCannonballClips == nil) {
		mCannonballClips = [[NSMutableArray alloc] initWithCapacity:kComboMax];
		mCannonballs = [[NSMutableArray alloc] initWithCapacity:kComboMax];
		
		for (int i = 0; i < kComboMax; ++i) {
			SPSprite *sprite = [[SPSprite alloc] init];
			sprite.x = 0.5f * kCannonballWidth + i * kCannonballWidth;
            sprite.scaleX = sprite.scaleY = kCannonballScale;
			
			SPMovieClip *clip = [SPMovieClip movieWithFrames:textureFrames fps:1];
			clip.x = -clip.width / 2;
			clip.y = -clip.height / 2;
			
			[mCannonballClips addObject:clip];
			[mCannonballs addObject:sprite];
			[self addChild:sprite];
			[sprite release];
		}
	}
	
	self.x = mComboMultiplier * kCannonballWidth - kComboWidth;
	self.y = y - 0.5f * (kCannonballWidth - kCannonballUnscaledWidth);
	[self pushClips:mCannonballClips];
}

// Determined from the perspective of clipsSrc
- (BOOL)isSrcClip:(NSArray *)src lowerPriorityThanOtherClip:(NSArray *)other {
	BOOL result = NO;
	
	if (src == other || other == mCannonballClips)
		result = NO;
	else if (src == mFlyingDutchmanClips && other == mProcClips)
		result = YES;
	else
		result = NO;
	return result;
}

- (void)pushClips:(NSArray *)clips {
	if ([mClipStack containsObject:clips])
		[mClipStack removeObject:clips];
	int index = -1;
	
	for (int i = 0; i < mClipStack.count; ++i) {
		NSArray *clipIter = (NSArray *)[mClipStack objectAtIndex:i];
		
		if ([self isSrcClip:clips lowerPriorityThanOtherClip:clipIter]) {
			index = i;
			break;
		}
	}
	
	if (index == -1) {
		index = mClipStack.count;
		[self setCurrentCannonballClips:clips];
	}
	
	[mClipStack insertObject:clips atIndex:index];
}

- (void)popClips:(NSArray *)clips {
	[mClipStack removeObject:clips];
	
	if (mCurrentClips == clips) {
		NSArray *nextClips = (NSArray *)[mClipStack lastObject];
		[self setCurrentCannonballClips:nextClips];
	}
}

- (void)advanceTime:(double)time {
	if (mRolling) {
		for (SPSprite *sprite in mCannonballs)
			sprite.rotation += mRolling * 0.1f;
	}
	[mJuggler advanceTime:time];
}

- (void)rollCannonballsTo:(int)value {
	[mScene.juggler removeTweensWithTarget:self];
	
	float targetValue = value * kCannonballWidth - kComboWidth;
	float duration = MIN(fabsf(targetValue - self.x) / (2 * kCannonballWidth), 1.0f);

	SPTween *tween = [SPTween tweenWithTarget:self time:duration];
	[tween animateProperty:@"x" targetValue:targetValue];
	[tween addEventListener:@selector(onCannonballRollingStopped:) atObject:self forType:SP_EVENT_TYPE_TWEEN_COMPLETED];
	[mScene.juggler addObject:tween];
	mRolling = (targetValue < self.x) ? -1 : 1;
}

- (void)onCannonballRollingStopped:(SPEvent *)event {
	mRolling = 0;
}

- (void)setComboMultiplier:(int)value {
	if (value != mComboMultiplier && value >= kComboMin && value <= mScene.achievementManager.comboMultiplierMax) {
		mComboMultiplier = value;
		self.x = value * kCannonballWidth - kComboWidth;
	}
}

- (void)setComboMultiplierAnimated:(int)value {
	if (value != mComboMultiplier && value >= kComboMin && value <= kComboMax) {
		[self rollCannonballsTo:value];
		mComboMultiplier = value;
	}
}

- (void)setCurrentCannonballClips:(NSArray *)clips {
	int index = 0;
	
	[mJuggler removeAllObjects];
	
	for (SPSprite *sprite in mCannonballs) {
		[sprite removeAllChildren];
		[sprite addChild:[clips objectAtIndex:index++]];
	}
	
	for (SPMovieClip *clip in clips)
		[mJuggler addObject:clip];
	mCurrentClips = clips;
}

- (void)setupClips:(NSMutableArray *)clips withPrefix:(NSString *)texturePrefix {
	assert(clips);
	NSArray *textureFrames = [mScene texturesStartingWith:texturePrefix];
	
	if (textureFrames) {
		for (int i = 0; i < kComboMax; ++i) {
			SPMovieClip *clip = [SPMovieClip movieWithFrames:textureFrames fps:8];
			clip.x = -clip.width / 2;
			clip.y = -clip.height / 2;
			clip.currentFrame = MIN(clip.numFrames-1,i);
			[clips addObject:clip];
		}
	}
}

- (void)setupProcWithTexturePrefix:(NSString *)texturePrefix {
	if (mProcClips == nil)
		mProcClips = [[NSMutableArray alloc] initWithCapacity:kComboMax];
	[mProcClips removeAllObjects];
	[self setupClips:mProcClips withPrefix:texturePrefix];
	
	if (mProcActive) {
		mProcActive = NO;
		[self activateProc];
	}
}

- (void)activateProc {
	if (mProcActive || mProcClips == nil)
		return;
	[self pushClips:mProcClips];
	mProcActive = YES;
}

- (void)deactivateProc {
	if (mProcActive == NO || mProcClips == nil)
		return;
	mProcActive = NO;
	[self popClips:mProcClips];
}

- (void)onComboMultiplierChanged:(NumericValueChangedEvent *)event {
	[self setComboMultiplierAnimated:[event.value intValue]];
}

- (void)activateFlyingDutchman {
	if (mFlyingDutchman == NO) {
		if (mFlyingDutchmanClips == nil) {
			mFlyingDutchmanClips = [[NSMutableArray alloc] initWithCapacity:kComboMax];
			[self setupClips:mFlyingDutchmanClips withPrefix:@"dutchman-shot_"];
		}
		[self pushClips:mFlyingDutchmanClips];
		mFlyingDutchman = YES;
	}
}

- (void)deactivateFlyingDutchman {
	if (mFlyingDutchman == YES) {
		mFlyingDutchman = NO;
		[self popClips:mFlyingDutchmanClips];
	}
}

- (void)destroyComboDisplay {
	[mJuggler removeAllObjects];
}

- (void)dealloc {
	mCurrentClips = nil;
	[mClipStack release]; mClipStack = nil;
	[mCannonballClips release]; mCannonballClips = nil;
	[mProcClips release]; mProcClips = nil;
	[mFlyingDutchmanClips release]; mFlyingDutchmanClips = nil;
	[mCannonballs release]; mCannonballs = nil;
	[mJuggler release]; mJuggler = nil;
    [super dealloc];
}

@end
