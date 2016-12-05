//
//  SpriteCarousel.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 6/10/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

typedef struct {
	float x;
	double timestamp;
} dragPoint;

typedef struct {
	int count;
	int index;
	dragPoint *path;
} dragPath;

@interface SpriteCarousel : Prop {
	BOOL mBeginTouch;
	int mDisplayIndex;
	int mPrevDir;
	float mInertia;
	float mPosition;
	float mWindUp;
	float mSpriteWidth;
	float mSpriteHeight;
	double mPreviousTimestamp;
	
	SPPoint *mCurrentPos;
	SPPoint *mPreviousPos;
	SPPoint *mOrigin;
	SPQuad *mTouchQuad;
	dragPath mDragPath;
	NSMutableArray *mSprites;
}

@property (nonatomic,readonly) int count;
@property (nonatomic,assign) int displayIndex;
@property (nonatomic,assign) float inertia;
@property (nonatomic,readonly) NSArray *sprites;

- (id)initWithCategory:(int)category x:(float)x y:(float)y width:(float)width height:(float)height;
- (void)addSprite:(SPSprite *)sprite;
- (void)batchAddSprite:(SPSprite *)sprite;
- (void)batchAddCompleted;
- (void)removeSpriteAtIndex:(int)index;
- (void)turnToPosition:(float)position;
- (int)indexOfSprite:(SPSprite *)sprite;
- (SPSprite *)spriteAtIndex:(int)index;
- (SPPoint *)spritePositionAtIndex:(int)index;
- (BOOL)spriteShadedAtIndex:(int)index;
- (void)shadeSpriteAtIndex:(int)index;
- (void)unshadeSpriteAtIndex:(int)index;
- (void)shadeAllSprites;
- (void)unshadeAllSprites;

@end
