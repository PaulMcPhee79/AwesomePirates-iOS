//
//  VertexAnimator.h
//  CutlassCove
//
//  Created by Paul McPhee on 4/07/13.
//  Copyright (c) 2013 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VertexAnimator : NSObject {
    double mTimeAccum;
    float mAnimFactor;
    float mAnimRate;
    float mVertexCoordsCache[8];
    SPQuad *mQuad;
}

@property (nonatomic,assign) float animFactor;
@property (nonatomic,assign) float animRate;

- (id)initWithQuad:(SPQuad *)quad;
- (void)setAnimatedQuad:(SPQuad *)quad;
- (void)reset;
- (void)advanceTime:(double)time;

@end
