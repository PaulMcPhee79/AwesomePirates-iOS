//
//  FastMath.h
//  CutlassCove
//
//  Created by Paul McPhee on 5/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef CutlassCove_FastMath_h
#define CutlassCove_FastMath_h

#include <cmath>
#include <cfloat>
#include <cstddef>
#include <limits>


static const int ATAN2_BITS = 7;
static const int ATAN2_BITS2 = ATAN2_BITS << 1;
static const int ATAN2_MASK = ~(-1 << ATAN2_BITS2);
static const int ATAN2_COUNT = ATAN2_MASK + 1;
static const int ATAN2_DIM = (int)sqrtf(ATAN2_COUNT);
static const float ATAN2_DIM_MINUS_1 = (ATAN2_DIM - 1);

class FastMath {
public:
	static float fastAtan2(float y, float x);    
    static void primeAtan2Lut(void);
    
    static bool s_isLutPrimed;
    static float s_atan2lut[];
};

#endif
