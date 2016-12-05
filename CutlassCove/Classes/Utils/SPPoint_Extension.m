//
//  SPPoint_Extension.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 26/01/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "SPPoint_Extension.h"

#define SQ(x) ((x)*(x))

@implementation SPPoint (Extension)

+ (float)distanceSqFromPoint:(SPPoint*)p1 toPoint:(SPPoint*)p2
{
    return SQ(p2->mX - p1->mX) + SQ(p2->mY - p1->mY);
}

@end
