//
//  ClippedProp.h
//  Sparrow
//
//  Created by Shilo White on 5/30/11.
//  Copyright 2011 Shilocity Productions. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

@class SPStage;
@class SPQuad;

@interface ClippedProp : Prop {
    SPQuad *mClip;
    SPStage *mStage;
    BOOL mClipping;
}

@property (nonatomic, readonly) SPQuad *clip;
@property (nonatomic, assign) BOOL clipping;

+ (ClippedProp *)clippedProp;

@end
