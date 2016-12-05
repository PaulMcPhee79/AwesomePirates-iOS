//
//  FastMath.cpp
//  CutlassCove
//
//  Created by Paul McPhee on 5/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include "FastMath.h"

bool FastMath::s_isLutPrimed = false;
float FastMath::s_atan2lut[ATAN2_COUNT] = { 0 };

float FastMath::fastAtan2(float y, float x) {
    float add, mul;
    
    if (x == 0 && y == 0)
        return std::atan2(y, x);
    
    if (x < 0.0f) {
        if (y < 0.0f) {
            x = -x;
            y = -y;
            mul = 1.0f;
        } else {
            x = -x;
            mul = -1.0f;
        }
        
        add = -3.141592653;
    } else {
        if (y < 0.0f) {
            y = -y;
            mul = -1.0f;
        } else {
            mul = 1.0f;
        }
        
        add = 0.0f;
    }
    
    float invDiv = ATAN2_DIM_MINUS_1 / ((x < y) ? y : x);
    
    int xi = (int)(x * invDiv);
    int yi = (int)(y * invDiv);
    int index = yi * ATAN2_DIM + xi;
    
    if (index < 0 || index > (ATAN2_COUNT - 1))
        return std::atan2(y, x);
    return (s_atan2lut[index] + add) * mul;
}

void FastMath::primeAtan2Lut(void) {
    if (s_isLutPrimed)
        return;
    s_isLutPrimed = true;
    
    for (int i = 0; i < ATAN2_DIM; ++i) {
        for (int j = 0; j < ATAN2_DIM; ++j) {
            float x0 = (float)i / ATAN2_DIM;
            float y0 = (float)j / ATAN2_DIM;
            
            s_atan2lut[j * ATAN2_DIM + i] = (float)std::atan2(y0, x0);
        }
    }
}
