//
//  Explosion.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 8/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PointMovie.h"

@interface Explosion : PointMovie {
	
}

- (id)initWithX:(float)x y:(float)y;
+ (float)fps;

@end
