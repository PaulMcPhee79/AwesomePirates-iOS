//
//  TweenFilter.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 25/08/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TweenFilter : NSObject {
	float mX;
	float mY;
	float mRotation;
	float mScaleFactor;
	SPDisplayObject *mTarget;
}

@property (nonatomic,assign) float x;
@property (nonatomic,assign) float y;
@property (nonatomic,assign) float rotation;
@property (nonatomic,retain) SPDisplayObject *target;

- (id)initWithTarget:(SPDisplayObject *)target;

@end
