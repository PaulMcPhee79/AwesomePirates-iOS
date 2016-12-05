//
//  ClippedProp.m
//  Sparrow
//
//  Created by Shilo White on 5/30/11.
//  Copyright 2011 Shilocity Productions. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "ClippedProp.h"
#import "SPEvent.h"
#import "SPQuad.h"
#import "SPStage.h"
#import "SPDisplayObject.h"

@interface ClippedProp ()

@end

@implementation ClippedProp

@synthesize clip = mClip;
@synthesize clipping = mClipping;

+ (ClippedProp *)clippedProp {
    return [[[ClippedProp alloc] initWithCategory:-1] autorelease];
}

- (ClippedProp *)initWithCategory:(int)category {
    if ((self = [super initWithCategory:category])) {
        mClip = [[SPQuad alloc] init];
		mClip.visible = NO;
        mClip.width = 0;
        mClip.height = 0;
		[self addChild:mClip];
        mClipping = NO;
		mStage = [GameController GC].stage;
    }
    return self;
}

- (void)render:(SPRenderSupport *)support {
    if (mClipping) {
        glEnable(GL_SCISSOR_TEST);
        SPRectangle *clip = [mClip boundsInSpace:mStage];
        glScissor((clip.x*[SPStage contentScaleFactor]), (mStage.height*[SPStage contentScaleFactor])-(clip.y*[SPStage contentScaleFactor])-(clip.height*[SPStage contentScaleFactor]), (clip.width*[SPStage contentScaleFactor]), (clip.height*[SPStage contentScaleFactor]));
        [super render:support];
        glDisable(GL_SCISSOR_TEST);
    } else {
        [super render:support];
    }
}

- (SPRectangle *)boundsInSpace:(SPDisplayObject *)targetCoordinateSpace {    
    if (mClipping) {
        return [mClip boundsInSpace:targetCoordinateSpace];
    } else {
        return [super boundsInSpace:targetCoordinateSpace];
    }
}

- (SPDisplayObject*)hitTestPoint:(SPPoint*)localPoint forTouch:(BOOL)isTouch
{
    if (isTouch && (!self.visible || !self.touchable)) return nil;
    
    SPDisplayObject *parent = self.parent;
    while (parent) {
        if ([parent isKindOfClass:[ClippedProp class]] && ![[parent boundsInSpace:parent] containsPoint:localPoint])
            return nil;
        parent = parent.parent;
    }
    
    if ([[self boundsInSpace:self] containsPoint:localPoint]) return self; 
    else return nil;
}

- (void)dealloc {
    [mClip release]; mClip = nil;
    [super dealloc];
}

@end
