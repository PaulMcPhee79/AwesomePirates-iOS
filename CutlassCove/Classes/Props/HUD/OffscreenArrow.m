//
//  OffscreenArrow.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 8/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "OffscreenArrow.h"
#import "Globals.h"


@interface OffscreenArrow ()

- (BOOL)isOutOfRange;

@end


@implementation OffscreenArrow

@synthesize enabled = mEnabled;

- (id)init {
    if (self = [super initWithCategory:CAT_PF_HUD]) {
        mEnabled = YES;
		mRealX = 0;
		mRealY = 0;
		mCachedArrowWidth = 0;
		mCachedArrowHeight = 0;
		[self setupProp];
    }
    return self;
}

- (void)setupProp {
    self.x = mScene.viewWidth / 2;
    self.y = mScene.viewHeight / 2;
    
    mCanvas = [[SPSprite alloc] init];
    mCanvas.x = -self.x;
    mCanvas.y = -self.y;
    [self addChild:mCanvas];
    
	mArrow = [[SPSprite alloc] init];
	SPImage *arrowImage = [SPImage imageWithTexture:[mScene textureByName:@"offscreen-arrow"]];
    arrowImage.x = -arrowImage.width / 2;
    arrowImage.y = -arrowImage.height / 2;
	[mArrow addChild:arrowImage];
	[mCanvas addChild:mArrow];
	self.visible = NO;
	
	mCachedArrowWidth = mArrow.width;
	mCachedArrowHeight = mArrow.height;
}

- (void)updateArrowLocationX:(float)arrowX arrowY:(float)arrowY {
    mRealX = arrowX;
    mArrow.x = MAX(mCachedArrowWidth / 2,MIN(mScene.viewWidth-mCachedArrowHeight / 2,arrowX));
    
    mRealY = arrowY;
    mArrow.y = MAX(mCachedArrowHeight / 2,MIN(RITMFY(285.0f)-mCachedArrowHeight / 2,arrowY));
    
    self.visible = (self.enabled && [self isOutOfRange]);
}

- (void)updateArrowRotation:(float)angle {
    mArrow.rotation = angle;
}

- (BOOL)isOutOfRange {
	return (mRealX < -10.0f || mRealX > RITMFX(490.0f) || mRealY < -10.0f || mRealY > RITMFY(295.0f));
}

- (void)flip:(BOOL)enable {
    self.scaleX = (enable) ? -1 : 1;
}

- (void)dealloc {
	[mArrow release]; mArrow = nil;
    [mCanvas release]; mCanvas = nil;
    [super dealloc];
}

@end

