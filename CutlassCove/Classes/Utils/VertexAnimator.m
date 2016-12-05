//
//  VertexAnimator.m
//  CutlassCove
//
//  Created by Paul McPhee on 4/07/13.
//  Copyright (c) 2013 Cheeky Mammoth. All rights reserved.
//

#import "VertexAnimator.h"
#import "SPQuad_Extension.h"

@implementation VertexAnimator

@synthesize animFactor = mAnimFactor;
@synthesize animRate = mAnimRate;

- (id)initWithQuad:(SPQuad *)quad {
    if (self = [super init])
    {
        mTimeAccum = 0;
        mAnimFactor = 1.0f;
        mAnimRate = 1.0f;
        mQuad = quad;
        if (mQuad)
            memcpy(mVertexCoordsCache, mQuad.vertexCoords, 8 * sizeof(mVertexCoordsCache[0]));
    }
    
    return self;
}

- (void)setAnimatedQuad:(SPQuad *)quad {
    mQuad = quad;
    if (mQuad)
        memcpy(mVertexCoordsCache, mQuad.vertexCoords, 8 * sizeof(mVertexCoordsCache[0]));
}

- (void)reset
{
    if (mQuad)
        memcpy(mQuad.vertexCoords, mVertexCoordsCache, 8 * sizeof(mVertexCoordsCache[0]));
    mTimeAccum = 0;
}

- (void)advanceTime:(double)time {
    if (mQuad == nil)
        return;
    
    mTimeAccum += time;
    
    float* vertexCoords = mQuad.vertexCoords;
    float adjustedTime = 0.25f * mAnimRate * mTimeAccum;
    for (int i = 0; i < 8; i+=2)
    {
        vertexCoords[i] = mVertexCoordsCache[i] + mAnimFactor * cos((i + 1) * adjustedTime);
        vertexCoords[i+1] = mVertexCoordsCache[i+1] + mAnimFactor * sin((i + 1) * adjustedTime);
    }
}

- (void)dealloc {
	mQuad = nil;
	[super dealloc];
}

@end
