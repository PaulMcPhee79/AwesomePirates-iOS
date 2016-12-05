//
//  SpriteCarousel.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 6/10/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "SpriteCarousel.h"
#import "NumericValueChangedEvent.h"
#import "SPSprite_Extension.h"

const int kDragPathLength = 10;
const double kMinStopPeriod = 0.2;
const float kSpriteShadedAlpha = 0.5f;

@interface SpriteCarousel ()

- (void)turnToPosition:(float)position enableEvents:(BOOL)enableEvents;
- (int)nextDisplayIndex;
- (int)prevDisplayIndex;
- (int)nextPathIndex;
- (int)prevPathIndex;
- (int)pathIndexTransferred:(int)places;
- (float)calcTouchSpeed;
- (void)addToDragPath:(SPTouch *)touch;
- (void)setCurrentPos:(SPPoint *)pos;
- (void)setPreviousPos:(SPPoint *)pos;
- (void)resizeTouchableRegion;
- (void)onTouch:(SPTouchEvent *)event;

@end


@implementation SpriteCarousel

@synthesize displayIndex = mDisplayIndex;
@synthesize inertia = mInertia;
@synthesize sprites = mSprites;
@dynamic count;

- (id)initWithCategory:(int)category x:(float)x y:(float)y width:(float)width height:(float)height {
	if (self = [super initWithCategory:category]) {
		mAdvanceable = YES;
		mBeginTouch = NO;
		mPrevDir = 0;
		mInertia = 50.0f;
		mPosition = 0.0f;
		mWindUp = 0.0f;
		mDisplayIndex = 0;
		mSprites = [[NSMutableArray alloc] init];
		mDragPath.count = 0;
		mDragPath.index = 0;
		mDragPath.path = new dragPoint[kDragPathLength];
		
		for (int i = 0; i < kDragPathLength; ++i) {
			mDragPath.path[i].x = 0.0f;
			mDragPath.path[i].timestamp = 0.0;
		}
		
		self.x = x;
		self.y = y;
		mSpriteWidth = width;
		mSpriteHeight = height;
		mPreviousTimestamp = 0.0;
		mCurrentPos = nil;
		mPreviousPos = nil;
		mOrigin = [[SPPoint pointWithX:0.0f y:0.0f] retain];
		//mOrigin = [[SPPoint pointWithX:3 * width / 2 y:3 * height / 2] retain];
		[self setupProp];
	}
	return self;
}

- (void)setupProp {
	mTouchQuad = [[SPQuad alloc] init];
	mTouchQuad.alpha = 0;
	mTouchQuad.touchable = YES;
	[mTouchQuad addEventListener:@selector(onTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
	[self addChild:mTouchQuad];
}

- (id)initWithCategory:(int)category {
	return [self initWithCategory:category x:0.0f y:0.0f width:1.0f height:1.0f];
}

- (int)count {
	return mSprites.count;
}

- (NSArray *)sprites {
	return [NSArray arrayWithArray:mSprites];
}

- (void)setInertia:(float)value {
	mInertia = MAX(1.0f,value);
}

- (void)setDisplayIndex:(int)value {
	if (mSprites.count == 0)
		return;
	if (value >= mSprites.count)
		value %= mSprites.count;
	mDisplayIndex = value;
	float intervalX = TWO_PI / mSprites.count;
	[self turnToPosition:(mSprites.count - mDisplayIndex) * intervalX];
	[NumericValueChangedEvent dispatchEventWithDispatcher:self type:CUST_EVENT_TYPE_SPRITE_CAROUSEL_INDEX_CHANGED value:[NSNumber numberWithInt:mDisplayIndex] bubbles:NO];
}

- (void)setCurrentPos:(SPPoint *)pos {
	[mCurrentPos release];
	mCurrentPos = nil;
	mCurrentPos = [pos retain];
}

- (void)setPreviousPos:(SPPoint *)pos {
	[mPreviousPos release];
	mPreviousPos = nil;
	mPreviousPos = [pos retain];
}

- (void)resizeTouchableRegion {
	[self removeChild:mTouchQuad];
	mTouchQuad.width = self.width;
	mTouchQuad.height = self.height;
	mTouchQuad.x = -mTouchQuad.width / 2;
	mTouchQuad.y = -mTouchQuad.height / 2;
	[self addChild:mTouchQuad atIndex:0];
}

- (void)addSprite:(SPSprite *)sprite {
	sprite.touchable = NO;
	[mSprites addObject:sprite];
	[self addChild:sprite];
	[self turnToPosition:mPosition];
	[self resizeTouchableRegion];
}

- (void)batchAddSprite:(SPSprite *)sprite {
	sprite.touchable = NO;
	[mSprites addObject:sprite];
	[self addChild:sprite];
}

- (void)batchAddCompleted {
	[self turnToPosition:mPosition];
	[self resizeTouchableRegion];
}

- (void)removeSpriteAtIndex:(int)index {
	if (index >= mSprites.count)
		return;
	
	NSLog(@"Removing Sprite At Index: %d", index);
	
	SPSprite *sprite = [mSprites objectAtIndex:index];
	[self removeChild:sprite];
	[mSprites removeObjectAtIndex:index];
	
	if (mDisplayIndex == mSprites.count)
		mDisplayIndex = 0;
	
	// Spin to new position
	if (mSprites.count) {
		//float prevIntervalX = TWO_PI / (mSprites.count + 1);
		float intervalX = TWO_PI / mSprites.count;
		//[self turnToPosition:((mSprites.count - mDisplayIndex) * intervalX) + prevIntervalX];
		//[self turnToPosition:mDisplayIndex * intervalX + prevIntervalX];
		//mWindUp = prevIntervalX;
		[self turnToPosition:mDisplayIndex * intervalX + 0.4f * intervalX enableEvents:NO];
		mWindUp = 0.4f * intervalX;
		[NumericValueChangedEvent dispatchEventWithDispatcher:self
														 type:CUST_EVENT_TYPE_SPRITE_CAROUSEL_INDEX_CHANGED
														value:[NSNumber numberWithInt:mDisplayIndex]
													  bubbles:NO];
	}
}

- (void)turnToPosition:(float)position {
	[self turnToPosition:position enableEvents:YES];
}

- (void)turnToPosition:(float)position enableEvents:(BOOL)enableEvents {
	if (mSprites.count == 0)
		return;
	
	int i = 0;
	float intervalX = TWO_PI / mSprites.count;
	float intervalY = TWO_PI / mSprites.count;
	float divX, divY;
	
	for (SPSprite *sprite in mSprites) {
		divX = sinf(position + i * intervalX);
		divY = 1.0f - (1.0f + cosf(position + i * intervalY)) / 2;
		
		if (SP_IS_FLOAT_EQUAL(divX, 0))
			divX = 0.001f;
		if (SP_IS_FLOAT_EQUAL(divY, 0))
			divY = 0.001f;
		
		sprite.x = mOrigin.x - (2 * mSpriteWidth / 3) * divX;
		sprite.y = mOrigin.y - (3 * mSpriteHeight / 5) * divY;
		sprite.scaleX = (1.0f + cosf(position + i * intervalY)) / 2;
		
		if (sprite.scaleX < 0.5f)
			sprite.scaleX += (0.5f - sprite.scaleX) / 2;
		sprite.scaleY = sprite.scaleX;
		++i;
	}
	
	// Maintain appropriate Z-Ordering
	[self removeAllChildren];
	[self addChild:mTouchQuad];
	NSArray *array = [mSprites sortedArrayUsingSelector:@selector(yCompare:)];
	
	for (SPSprite *sprite in array)
		[self addChild:sprite];
	
	// clamp between [+360 deg, +720 deg]
	mPosition = position;
	
	if (mPosition < TWO_PI)
		mPosition += TWO_PI;
	else if (mPosition > 2 * TWO_PI)
		mPosition -= TWO_PI;
	
	// Update display index
	float subPosition = mPosition / TWO_PI;
	// Convert ratio to radians
	subPosition = TWO_PI * (subPosition - (int)subPosition);
	// Convert radians to display positions
	subPosition = subPosition / intervalX;
	// Get expected index for this position
	int subIndex = (int)subPosition;
	// Convert to ratio through this current display interval
	subPosition = subPosition - (int)subPosition;
	
	if (subIndex != 0)
		subIndex = mSprites.count - subIndex;
	
	if (subPosition < 0.5f && subIndex != mDisplayIndex)
		mDisplayIndex = subIndex;
	else if (subPosition >= 0.5f && subIndex == mDisplayIndex)
		mDisplayIndex -= 1;
	else
		return;	
	
	if (mDisplayIndex < 0) // TODO: because int vs uint, we must check for < 0 first or we interpret -1 as UINT_MAX. Fix this.
		mDisplayIndex += mSprites.count;
	else if (mDisplayIndex >= mSprites.count)
		mDisplayIndex -= mSprites.count;
	
	//NSLog(@"Display Index: %d", mDisplayIndex);
	
	// Notify listeners of display index change.
	if (enableEvents)
		[NumericValueChangedEvent dispatchEventWithDispatcher:self
														 type:CUST_EVENT_TYPE_SPRITE_CAROUSEL_INDEX_CHANGED
														value:[NSNumber numberWithInt:mDisplayIndex]
													  bubbles:NO];
}

- (int)indexOfSprite:(SPSprite *)sprite {
	int index = -1;
	
	if (sprite)
		index = [mSprites indexOfObject:sprite];
	return index;
}

- (SPSprite *)spriteAtIndex:(int)index {
	SPSprite *sprite = nil;
	
	if (index >= 0 && index < mSprites.count)
		sprite = (SPSprite *)[mSprites objectAtIndex:index];
	return sprite;
}

- (SPPoint *)spritePositionAtIndex:(int)index {
	SPPoint *point = [SPPoint point];
	
	if (index >= 0 && index < mSprites.count) {
		SPSprite *sprite = (SPSprite *)[mSprites objectAtIndex:index];
		point.x = sprite.x;
		point.y = sprite.y;
		point = [sprite.parent localToGlobal:point];
	}
	return point;
}

- (BOOL)spriteShadedAtIndex:(int)index {
	if (index < 0 || index >= mSprites.count)
		return NO;
	SPSprite *sprite = (SPSprite *)[mSprites objectAtIndex:index];
	return sprite.alpha < kSpriteShadedAlpha + 0.05f;
}

- (void)shadeSpriteAtIndex:(int)index {
	if (index < 0 || index >= mSprites.count)
		return;
	SPSprite *sprite = (SPSprite *)[mSprites objectAtIndex:index];
	sprite.alpha = kSpriteShadedAlpha;
}

- (void)unshadeSpriteAtIndex:(int)index {
	if (index < 0 || index >= mSprites.count)
		return;
	SPSprite *sprite = (SPSprite *)[mSprites objectAtIndex:index];
	sprite.alpha = 1;
}

- (void)shadeAllSprites {
	for (SPSprite *sprite in mSprites)
		sprite.alpha = 0.5f;
}

- (void)unshadeAllSprites {
	for (SPSprite *sprite in mSprites)
		sprite.alpha = 1.0f;
}
		
- (int)nextDisplayIndex {
	int index = mDisplayIndex + 1;
	
	if (index >= mSprites.count)
		index -= mSprites.count;
	return index;
}

- (int)prevDisplayIndex {
	int index = mDisplayIndex - 1;
	
	if (index < 0)
		index += mSprites.count;
	return index;
}

- (int)nextPathIndex {
	int index = mDragPath.index + 1;
	
	if (index >= kDragPathLength)
		index = 0;
	return index;
}

- (int)prevPathIndex {
	int index = mDragPath.index - 1;
	
	if (index < 0)
		index = mDragPath.count-1;
	return index;
}

- (int)pathIndexTransferred:(int)places {
	assert(mDragPath.count);
	
	if (mDragPath.count > 0 && fabsf(places) > mDragPath.count)
		places %= mDragPath.count;
	
	int index = mDragPath.index + places;
	
	if (index < 0) {
		index = mDragPath.count + index;
	} else if (index >= mDragPath.count) {
		index -= mDragPath.count;
	}
	return index;
}

- (float)calcTouchSpeed {
	if (mDragPath.count == 0)
		return 0.0f;
	
	int fromIndex = 0, toIndex = 0;
	
	if (mDragPath.count < kDragPathLength) {
		fromIndex = 0;
		toIndex = mDragPath.index - 1;
	} else {
		fromIndex = mDragPath.index;
		toIndex = mDragPath.index - 1;
		
		if (toIndex < 0)
			toIndex = mDragPath.count - 1;
	}
	
	double time = mDragPath.path[toIndex].timestamp - mDragPath.path[fromIndex].timestamp;
	float dist = mDragPath.path[toIndex].x - mDragPath.path[fromIndex].x;	
	return dist / MAX(0.01f,(float)time);
}

- (void)addToDragPath:(SPTouch *)touch {
	[self setCurrentPos:[touch locationInSpace:self]];
	[self setPreviousPos:[touch previousLocationInSpace:self]];
	
	if (mDragPath.count > 1) {
		int prevPrevIndex = [self pathIndexTransferred:-2];
		float previousDelta = mPreviousPos.x - mDragPath.path[prevPrevIndex].x;
		float currentDelta = mCurrentPos.x - mPreviousPos.x;
		
		if (previousDelta * currentDelta < 0.0f) {
			// Changed directions - reset drag path
			mDragPath.index = 0;
			mDragPath.count = 0;
		}
	} else if (mDragPath.count == 1) {
		// Dampen initial "jump" from begin phase to move phase
		if (mBeginTouch == YES) {
			float currentDelta = mCurrentPos.x - mPreviousPos.x;
			
			if (fabsf(currentDelta) > 1.0f) {
				mPreviousPos.x = mCurrentPos.x + currentDelta / fabsf(currentDelta);
				mDragPath.path[[self prevPathIndex]].x = mPreviousPos.x;
			}
			mBeginTouch = NO;
		}
	}
	
	mDragPath.path[mDragPath.index].x = mCurrentPos.x;
	mDragPath.path[mDragPath.index].timestamp = touch.timestamp;
	mDragPath.index = [self nextPathIndex];
	
	if (mDragPath.count < kDragPathLength)
		++mDragPath.count;
}

- (void)onTouch:(SPTouchEvent *)event {
	if (mSprites.count == 0)
		return;
	
	// Begin Phase
	SPTouch *touch = [[event touchesWithTarget:mTouchQuad andPhase:SPTouchPhaseBegan] anyObject];
	
	if (touch) {
		mBeginTouch = YES;
		mWindUp = 0.0f;
		mDragPath.index = 0;
		mDragPath.count = 0;
		[self setCurrentPos:[touch locationInSpace:self]];
		mDragPath.path[mDragPath.index].x = mCurrentPos.x;
		mDragPath.path[mDragPath.index].timestamp = touch.timestamp;
		++mDragPath.index;
		++mDragPath.count;
		mPreviousTimestamp = touch.timestamp;
		return;
	}
	
	// Move Phase
	touch = [[event touchesWithTarget:mTouchQuad andPhase:SPTouchPhaseMoved] anyObject];
	
	if (touch) {
		[self addToDragPath:touch];
		[self turnToPosition:mPosition - (mCurrentPos.x - mPreviousPos.x) / (MIN(5,mSprites.count) * mInertia)];
		mPreviousTimestamp = touch.timestamp;
		//NSLog(@"mPosition: %f", mPosition / (TWO_PI / mSprites.count));
	}
	
	// End Phase
	touch = [[event touchesWithTarget:mTouchQuad andPhase:SPTouchPhaseEnded] anyObject];
	
	if (touch == nil)
		touch = [[event touchesWithTarget:mTouchQuad andPhase:SPTouchPhaseCancelled] anyObject];
	
	if (touch) {
		float speed = [self calcTouchSpeed];
		int dir = (speed < 0.0f) ? -1 : 1;
		
		//NSLog(@"Speed: %f", speed);
		
		if (mPrevDir == 0)
			mPrevDir = dir;
		
		if (SP_IS_FLOAT_EQUAL(speed,0))
			dir = mPrevDir;
		speed = fabsf(speed) / (MIN(25,5*mSprites.count) * mInertia);
		
		float intervalX = TWO_PI / mSprites.count;
		float posOffset = (-dir * speed + mPosition) / intervalX;
		
		posOffset = posOffset - (int)posOffset;
		
		//if (fabsf(posOffset) > 0.02f) { // Commented out to prevent the carousel freezing in between positions in rare circumstances
			if (dir == -1)
				posOffset = 1.0f - posOffset;
			posOffset *= intervalX;
			mWindUp = dir * speed + dir * posOffset;
			mPrevDir = dir;
		//}
	}
}

- (void)advanceTime:(double)time {
	float newWindUp = mWindUp * 0.9f;
			
	if (SP_IS_FLOAT_EQUAL(0, mWindUp) == NO) {
		//if (fabsf(mWindUp) < 0.001f)
		//	newWindUp = 0.0f;
		
		[self turnToPosition:mPosition - (mWindUp - newWindUp)];
		mWindUp = newWindUp;
		
		if (SP_IS_FLOAT_EQUAL(0, mWindUp))
			NSLog(@"Carousel Position: %f", mPosition);
	}
}

- (void)dealloc {
	[mTouchQuad removeEventListener:@selector(onTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
	delete [] mDragPath.path;	
	[mSprites release];
	[mCurrentPos release];
	[mPreviousPos release];
	[mOrigin release];
	[mTouchQuad release];
	[super dealloc];
}

@end
