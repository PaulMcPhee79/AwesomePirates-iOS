//
//  Helm.m
//  Pirates
//
//  Created by Paul McPhee on 17/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "Helm.h"
//#import "Ship.h"
#import "Globals.h"


@interface Helm ()

- (void)swapSpeedboatTextures;
- (void)swapFlyingDutchmanTextures;
- (void)onTouch:(SPTouchEvent *)event;

@end


@implementation Helm

@synthesize wheelImage = mWheelImage;
@synthesize wheel = mWheel;
@synthesize recoilRate = mRecoilRate;
@synthesize centerPoint = mCenterPoint;
@dynamic turnAngle;

- (id)initWithRotationIncrement:(float)rotationIncrement {
    if (self = [super initWithCategory:-1]) {
		mAdvanceable = YES;
		self.touchable = YES;
		mFlyingDutchman = NO;
        mSpeedboat = NO;
		mRecoilRate = 0.0f;
		mHelmRotation = 0.0f;
        mRotationIncrement = rotationIncrement;
		mCenterPoint = [[Globals centerPoint:self.bounds] retain];
		mFlyingDutchmanTexture = [[mScene textureByName:@"ghost-helm"] retain];
        mSpeedboatTexture = [[mScene textureByName:@"8-Speedboat-helm"] retain];
		[self addEventListener:@selector(onTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
    }
    return self;
}

- (id)init {
    // Does not account for varying FPS
    return [self initWithRotationIncrement:0.1f * PI];
}

- (void)loadFromDictionary:(NSDictionary *)dictionary withKeys:(NSArray *)keys {
	NSDictionary *dict = [dictionary objectForKey:@"Helm"];
	float x = [(NSNumber *)[dict objectForKey:@"x"] floatValue];
	float y = [(NSNumber *)[dict objectForKey:@"y"] floatValue];
	dict = [dictionary objectForKey:@"Types"];
	
	int i = 0;
	NSString *key = [keys objectAtIndex:i++];
	dict = [dict objectForKey:key];
	dict = [dict objectForKey:@"Textures"];
	NSString *wheel = [dict objectForKey:@"helmTexture"];
	
	self.x = x;
	self.y = y;
	mCenterPoint = [[Globals centerPoint:self.bounds] retain];
	
	SPTexture *texture = [mScene textureByName:wheel];
	
	if (mWheelImage == nil)
		mWheelImage = [SPImage imageWithTexture:texture];
	else
		mWheelImage.texture = texture;
	
	mWheelImage.scaleX = 1.0f;
	mWheelImage.scaleY = 1.0f;
	
	mWheelImage.x = -mWheelImage.width/2;
	mWheelImage.y = -mWheelImage.height/2;
	
	if (mWheel == nil) {
		mWheel = [[SPSprite alloc] init];
        mWheel.rotation = mHelmRotation;
		mWheel.touchable = NO;
		[mWheel addChild:mWheelImage];
		[self addChild:mWheel];
	}
	
	if (mTouchQuad == nil) {
		mTouchQuad = [[SPQuad quadWithWidth:mWheelImage.width height:mWheelImage.height] retain];
		mTouchQuad.x = -mTouchQuad.width / 2;
		mTouchQuad.y = -mTouchQuad.height / 2;
		mTouchQuad.alpha = 0;
		[self addChild:mTouchQuad];
	}
}

- (void)fpsFactorChanged:(float)value {
    mRotationIncrement = 0.1f * value * PI;
}

- (void)swapSpeedboatTextures {
	SPTexture *swap = [mWheelImage.texture retain];
	mWheelImage.texture = mSpeedboatTexture;
	[mSpeedboatTexture release];
	mSpeedboatTexture = swap;
}

- (void)activateSpeedboat {
    if (mSpeedboat == NO) {
		mSpeedboat = YES;
		[self swapSpeedboatTextures];
	}
}

- (void)deactivateSpeedboat {
    if (mSpeedboat == YES) {
		mSpeedboat = NO;
		[self swapSpeedboatTextures];
	}
}

- (void)swapFlyingDutchmanTextures {
	SPTexture *swap = [mWheelImage.texture retain];
	mWheelImage.texture = mFlyingDutchmanTexture;
	[mFlyingDutchmanTexture release];
	mFlyingDutchmanTexture = swap;
}

- (void)activateFlyingDutchman {
	if (mFlyingDutchman == NO) {
		mFlyingDutchman = YES;
		[self swapFlyingDutchmanTextures];
	}
}

- (void)deactivateFlyingDutchman {
	if (mFlyingDutchman == YES) {
		mFlyingDutchman = NO;
		[self swapFlyingDutchmanTextures];
	}
}

- (void)advanceTime:(double)time {
#if 1
	if (mPreviousRotation != 0.0f)
		[self addRotation:mPreviousRotation];
#else
	if (mRecoilRate != 0.0f) {
		if (mHelmRotation < 0.0f)
			mHelmRotation +=  MIN(mRecoilRate, fabsf(mHelmRotation));
		else if (mHelmRotation > 0.0f)
			mHelmRotation -= MIN(mRecoilRate, fabsf(mHelmRotation));
		mWheel.rotation = mHelmRotation;
	}
#endif
}

#if 1
-(void)onTouch:(SPTouchEvent *)event {
	[event stopImmediatePropagation];
	
    // Began/Moved touches
	SPTouch *touch = [[event touchesWithTarget:mTouchQuad andPhase:SPTouchPhaseBegan] anyObject];
	
	if (!touch)
		touch = [[event touchesWithTarget:mTouchQuad andPhase:SPTouchPhaseMoved] anyObject];
	
	if (touch) {
		float midPos = 0.5f * mTouchQuad.width;
		SPPoint *currentPos = [touch locationInSpace:mTouchQuad];
		
		currentPos.x = MAX(0.0f, currentPos.x);
		
		if ((currentPos.x > midPos && mPreviousRotation < 0) || (currentPos.x < midPos && mPreviousRotation > 0))
			mHelmRotation = 0.0f;
		
		if (currentPos.x >= midPos) {
			mPreviousRotation = mRotationIncrement;
		} else {
			mPreviousRotation = -mRotationIncrement;
		}
	}
    
    // Ended/Cancelled touches
	touch = [[event touchesWithTarget:mTouchQuad andPhase:SPTouchPhaseCancelled] anyObject];
	
    if (!touch)
        touch = [[event touchesWithTarget:mTouchQuad andPhase:SPTouchPhaseEnded] anyObject];
    
	if (touch) {
		mPreviousRotation = 0.0f;
		mHelmRotation = 0.0f;
	}
}

#else
// Recoil helm
-(void)onTouch:(SPTouchEvent *)event
{
	SPPoint *currentPos = nil;
	SPTouch *touch = [[event touchesWithTarget:self andPhase:SPTouchPhaseBegan] anyObject];
	
	if (touch) {
		mRecoilRate = 0.0f;

		currentPos = [touch locationInSpace:self];
		SPPoint *rotationVector = [SPPoint pointWithX:currentPos.x-mCenterPoint.x y:currentPos.y-mCenterPoint.y];
		mPreviousRotation = atan2f(rotationVector.y, rotationVector.x);
	} else {
		touch = [[event touchesWithTarget:self	andPhase:SPTouchPhaseEnded] anyObject];
		
		if (touch) {
			mRecoilRate = fabsf(mHelmRotation) / (PI*(PI+fabsf(mHelmRotation)));
		} else {
			touch = [[event touchesWithTarget:self andPhase:SPTouchPhaseMoved] anyObject];
			
			if (touch) {
				currentPos = [touch locationInSpace:self];
				
				SPPoint *rotationVector = [SPPoint pointWithX:currentPos.x-mCenterPoint.x y:currentPos.y-mCenterPoint.y];
				
				float currentRotation = atan2f(rotationVector.y, rotationVector.x);
				float deltaRotation = [Globals angleBetweenAngle:mPreviousRotation toAngle:currentRotation];
				
				if (fabsf(deltaRotation) < PI/16) {
					[self addRotation:deltaRotation];
				}
				mPreviousRotation = currentRotation;
			}
		}
	}
}
#endif

- (float)addRotation:(float)angle
{
	float newAngle = mHelmRotation + angle;
	
	if (newAngle > -TWO_PI && newAngle < TWO_PI) {
		mHelmRotation = newAngle;
		mWheel.rotation += angle;
	}
	return mWheel.rotation;
}

- (void)resetRotation {
    mHelmRotation = 0.0f;
    mWheel.rotation = mHelmRotation;
}

- (float)turnAngle {
    //return mHelmRotation / PI;
    
    // The wheel turns too fast for the human eye, so we slow it down but maintain ship turning rate (capped to old limit).
    float angle = MIN(2.0f, fabsf(mHelmRotation / PI_HALF));
	return (mHelmRotation < 0) ? -angle : angle;
}

- (void)dealloc {
	[mFlyingDutchmanTexture release]; mFlyingDutchmanTexture = nil;
    [mSpeedboatTexture release]; mSpeedboatTexture = nil;
	[mTouchQuad release]; mTouchQuad = nil;
	[mWheel release]; mWheel = nil;
	[mCenterPoint release]; mCenterPoint = nil;
    [super dealloc];
}

@end

