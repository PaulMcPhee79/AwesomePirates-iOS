//
//  SPPoint_Extension.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 26/01/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPPoint.h"

@interface SPPoint (Extension)

+ (float)distanceSqFromPoint:(SPPoint*)p1 toPoint:(SPPoint*)p2;

@end
