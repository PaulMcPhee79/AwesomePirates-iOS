//
//  CannonSmoke.h
//  Pirates
//
//  Created by Paul McPhee on 19/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

@interface CannonSmoke : Prop {
	SPSprite *mBurstFrame;
	SPMovieClip *mBurst;
	SPSprite *mSmokeFrame;
	SPMovieClip *mSmoke;
}

- (id)initWithX:(float)x y:(float)y;
- (void)startWithAngle:(float)angle;

@end
